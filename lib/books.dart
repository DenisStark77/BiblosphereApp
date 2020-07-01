import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/search.dart';
import 'package:biblosphere/lifecycle.dart';
import 'package:biblosphere/chat.dart';
import 'package:biblosphere/home.dart';
import 'package:biblosphere/l10n.dart';

Future<String> scanIsbn(BuildContext context, BookCallback onSuccess) async {
  String barcode = '';

  try {
    //print('!!!DEBUG Barcode scanner before');

    //ScanResult res = await BarcodeScanner.scan();
    String res = await BarcodeScanner.scan();

    //print('!!!DEBUG Barcode scanned: $res');

    //print('!!!DEBUG Barcode scanned: ${res.type}, ${res.rawContent}');

    //if (res.type == ResultType.Barcode) {
    if (res != null && res.isNotEmpty) {
      //barcode = res.rawContent;
      barcode = res;
      Book book = await searchByIsbn(barcode);

      if (book != null) {
        onSuccess(book);
      } else {
        print("!!!DEBUG No record found for isbn: $barcode. DO MANUAL");
        pushSingle(
            context,
            new MaterialPageRoute(
                builder: (context) => buildScaffold(
                    context,
                    null,
                    new BookDetailsWidget(
                        bookrecord: Bookrecord(
                            isbn: barcode, ownerId: B.user.id, wish: false),
                        mode: BookDetailsMode.Input),
                    appbar: false)),
            'book_details');

        showSnackBar(context, S.of(context).isbnNotFound);
        Firestore.instance.collection('noisbn').document(barcode).setData({
          'count': FieldValue.increment(1),
          'requested_by': FieldValue.arrayUnion([B.user.id])
        }, merge: true);
        logAnalyticsEvent(name: 'book_noisbn', parameters: <String, dynamic>{
          'isbn': barcode,
        });
      }
      /*  
    } else if (res.type == ResultType.Error) {
      logAnalyticsEvent(name: 'scan_error', parameters: <String, dynamic>{
        'error': res.rawContent,
      });
    } else if (res.type == ResultType.Cancelled) {
      logAnalyticsEvent(name: 'scan_canceled', parameters: <String, dynamic>{
        'error': res.rawContent,
      });
    */
    }
  } on PlatformException catch (e, stack) {
    /*
    if (e.code == BarcodeScanner.cameraAccessDenied) {
      //TODO: Inform user
      print('The user did not grant the camera permission!');
      Crashlytics.instance.recordError(e, stack);
    } else 
    */
    {
      print('Unknown platform error in scanIsbn: $e');
      Crashlytics.instance.recordError(e, stack);
    }
  } on FormatException {
    print(
        'null (User returned using the "back"-button before scanning anything. Result)');
  } catch (e, stack) {
    print('Unknown error in scanIsbn: $e');
    Crashlytics.instance.recordError(e, stack);
  }

  //print('!!!DEBUG BarCode scan finished');

  return barcode;
}

class AddBookWidget extends StatefulWidget {
  AddBookWidget({
    Key key,
  }) : super(key: key);

  @override
  _AddBookWidgetState createState() => new _AddBookWidgetState();
}

class _AddBookWidgetState extends State<AddBookWidget> {
  List<Book> suggestions = [];
  List<Shelf> shelves = [];

  bool recognition = false;
  bool progressBar = false;

  TextEditingController textController;

  @override
  void initState() {
    super.initState();

    //refreshLocation(context);

    textController = new TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  _AddBookWidgetState();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title: Text(S.of(context).addbookTitle,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(color: C.titleText)),
        // Allows the user to reveal the app bar if they begin scrolling
        // back up the list of items.
        centerTitle: true,
        floating: true,
        pinned: true,
        snap: true,
        // Display a placeholder widget to visualize the shrinking size.
        flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: ListView(
                //crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Container(height: 42),
                  // Add book from gallery photo
                  new Container(
                    padding: new EdgeInsets.all(10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Tooltip(
                            message: S.of(context).recognizeFromGallery,
                            child: RaisedButton(
                              textColor: C.buttonText,
                              color: C.button,
                              child: assetIcon(image_gallery_100, size: 30),
                              onPressed: () async {
                                await recognizeImage(context,
                                    source: ImageSource.gallery);
                                logAnalyticsEvent(
                                    name: 'book_recognize_attempt',
                                    parameters: <String, dynamic>{
                                      'type': 'gallery',
                                      'results': suggestions.length,
                                    });
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  side: BorderSide(color: C.buttonBorder)),
                            )),
                        Tooltip(
                            message: S.of(context).recognizeFromCamera,
                            child: RaisedButton(
                              textColor: C.buttonText,
                              color: C.button,
                              child: assetIcon(compact_camera_100, size: 30),
                              onPressed: () async {
                                await recognizeImage(context,
                                    source: ImageSource.camera);
                                logAnalyticsEvent(
                                    name: 'book_recognize_attempt',
                                    parameters: <String, dynamic>{
                                      'type': 'camera',
                                      'results': suggestions.length,
                                    });
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  side: BorderSide(color: C.buttonBorder)),
                            )),
                        Tooltip(
                          message: S.of(context).scanISBN,
                          child: RaisedButton(
                            textColor: C.buttonText,
                            color: C.button,
                            child: assetIcon(barcode_scanner_100, size: 30),
                            onPressed: () {
                              setState(() {
                                progressBar = true;
                              });

                              scanIsbn(context, (book) {
                                setState(() {
                                  progressBar = false;
                                  //print('!!!DEBUG barcode scanned, book found');
                                  recognition = false;
                                  suggestions = <Book>[book];
                                });
                              }).then((barcode) {
                                logAnalyticsEvent(
                                    name: 'book_add_attempt',
                                    parameters: <String, dynamic>{
                                      'type': 'isbn',
                                      'search_term': barcode,
                                      'results': suggestions.length,
                                    });
                              });
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                side: BorderSide(color: C.buttonBorder)),
                          ),
                        )
                      ],
                    ),
                  ),
                  new Container(
                    padding: new EdgeInsets.all(10.0),
                    child: new Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        new Expanded(
                          child: Theme(
                              data: ThemeData(platform: TargetPlatform.android),
                              child: TextField(
                                maxLines: 1,
                                controller: textController,
                                style: Theme.of(context).textTheme.headline6,
                                decoration: InputDecoration(
                                    //border: InputBorder.none,
                                    hintStyle:
                                        C.hints.apply(color: C.inputHints),
                                    hintText: S.of(context).hintAuthorTitle),
                              )),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 20.0),
                            child: RaisedButton(
                              textColor: Colors.white,
                              color: C.button,
                              child: assetIcon(search_100, size: 30),
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  progressBar = true;
                                });
                                searchByTitleAuthor(textController.text)
                                    .then((b) {
                                  if (b == null || b.length == 0) {
                                    setState(() {
                                      progressBar = false;
                                      recognition = false;
                                      suggestions = [];
                                    });
                                    showSnackBar(context,
                                        S.of(context).snackBookNotFound);
                                    logAnalyticsEvent(
                                        name: 'search_not_found',
                                        parameters: <String, dynamic>{
                                          'type': 'text',
                                          'search_term': textController.text,
                                        });
                                  } else {
                                    setState(() {
                                      progressBar = false;
                                      recognition = false;
                                      suggestions = b;
                                    });
                                    logAnalyticsEvent(
                                        name: 'book_add_attempt',
                                        parameters: <String, dynamic>{
                                          'type': 'text',
                                          'search_term': textController.text,
                                          'results': b.length,
                                        });
                                  }
                                });
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  side: BorderSide(color: C.buttonBorder)),
                            )),
                      ],
                    ),
                  ),
                  progressBar
                      ? Container(
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: SizedBox(
                              height: 2.0,
                              child: LinearProgressIndicator(
                                  backgroundColor: C.titleBackground,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      C.buttonBorder))))
                      : Container(),
                ])),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight: 185,
      ),
      SliverList(
        delegate: recognition
            ? SliverChildBuilderDelegate((context, index) {
                return ShelfWidget(
                    shelf: shelves[index],
                    builder: (context, shelf, value) {
                      return Container(
                          child: Row(
                        children: <Widget>[
                          // Image
                          shelfImage(shelf, 100.0),
                          // Text and progress indicator
                          Expanded(
                              child: Column(
                            children: <Widget>[
                              Container(
                                  child: Text(
                                      S.of(context).recognitionProgressTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2)),
                              Container(
                                  child: Text(progressText(shelf),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2)),
                              Container(
                                  padding: EdgeInsets.only(
                                      top: 10.0, left: 10.0, right: 10.0),
                                  child: shelf.status ==
                                          RecognitionStatus.Completed
                                      ? Text(
                                          S
                                              .of(context)
                                              .recognitionProgressBooks(
                                                  shelf.total,
                                                  shelf.recognized),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1)
                                      : shelf.status !=
                                                  RecognitionStatus.None &&
                                              shelf.status !=
                                                  RecognitionStatus.Failed
                                          ? LinearProgressIndicator(
                                              value: value)
                                          : Container()),
                            ],
                          ))
                        ],
                      ));
                    });
              }, childCount: shelves.length)

            // List of books from Author/Title and ISBN search
            : SliverChildBuilderDelegate((context, index) {
                Book book = suggestions[index];
                return Container(
                    margin: EdgeInsets.all(3.0),
                    child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            suggestions.clear();
                          });
                          addBookrecord(context, book, B.user, false,
                              await currentLocation(),
                              source: 'googlebooks');
                          //showSnackBar(context, S.of(context).bookAdded);
                        },
                        child: Row(children: <Widget>[
                          bookImage(book, 50, padding: EdgeInsets.all(5.0)),
                          Expanded(
                              child: Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('${book.authors[0]}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2),
                                        Text('\"${book.title}\"',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2)
                                      ])))
                        ])));
              }, childCount: suggestions != null ? suggestions.length : 0),
      )
    ]);
  }

  String progressText(Shelf shelf) {
    RecognitionStatus status = shelf.status;
    switch (status) {
      case RecognitionStatus.None:
        return S.of(context).recognitionProgressNone;
        break;
      case RecognitionStatus.Upload:
        return S.of(context).recognitionProgressUpload;
        break;
      case RecognitionStatus.Scan:
        return S.of(context).recognitionProgressScan;
        break;
      case RecognitionStatus.Outline:
        return S.of(context).recognitionProgressOutline;
        break;
      case RecognitionStatus.CatalogsLookup:
        return S.of(context).recognitionProgressCatalogsLookup;
        break;
      case RecognitionStatus.Rescan:
        return S.of(context).recognitionProgressRescan;
        break;
      case RecognitionStatus.Store:
        return S.of(context).recognitionProgressStore;
        break;
      case RecognitionStatus.Completed:
        return S.of(context).recognitionProgressCompleted;
        break;
      case RecognitionStatus.Failed:
        return S.of(context).recognitionProgressFailed;
        break;
    }
    return '';
  }

  Future recognizeImage(BuildContext context,
      {ImageSource source = ImageSource.camera}) async {
    try {
      File image = await ImagePicker.pickImage(source: source);
      //print('!!!DEBUG: Recognize image: ${image.path}');

      if (image == null) return;

      // TODO: Do not use timestamp as global id (will be overlaps from different users)
      String id = getTimestamp() + ':' + B.user.id;
      String name = id + ".jpg";

      Shelf shelf = Shelf(
          id: id,
          localImage: image.path,
          userId: B.user.id,
          status: RecognitionStatus.Upload);

      await shelf.ref.setData(shelf.toJson());

      // Add shelf to the list and refresh
      setState(() {
        recognition = true;
        shelves.add(shelf);
      });

      Future.delayed(Duration(seconds: 7), () {
        showSnackBar(context, S.of(context).snackRecgnitionStarted,
            duration: 6);
      });

      final String storagePath =
          await uploadPicture(image, 'images/${B.user.id}/$name');
      // !!!DEBUG
      //String storagePath = 'images/oyYUDByQGVdgP13T1nyArhyFkct1/1586749554453.jpg';

      //print('!!!DEBUG: Image cloud path: ${storagePath}');
      shelf.ref.updateData({'status': RecognitionStatus.Scan.index});

      GeoFirePoint location = await currentLocation();
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      IdTokenResult idtoken = await user.getIdToken();

      String body = json.encode({
        'uid': user.uid,
        'uri': storagePath,
        'shelf': shelf.id,
        'location': {
          'lat': location.geoPoint.latitude,
          'lon': location.geoPoint.longitude,
          'geohash': location.hash,
        }
      });
      //print('!!!DEBUG: JSON body = $body');

      // Call Python service to recognize
      Response res = await LibConnect.getCloudFunctionClient().post(
          'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/add_user_books_from_image',
          body: body,
          headers: {
            HttpHeaders.authorizationHeader: "Bearer ${idtoken.token}",
            HttpHeaders.contentTypeHeader: "application/json"
          });

      if (res.statusCode != 200) {
        print('!!!DEBUG: Recognition request failed');
        shelf.ref.updateData({'status': RecognitionStatus.Failed.index});
        logAnalyticsEvent(
            name: 'recognition_failed',
            parameters: <String, dynamic>{
              'type': 'response',
              'error': res.statusCode.toString(),
            });
      }
      //print('!!!DEBUG: ${res.body}');
      //print('!!!DEBUG: Request for recognition queued');
    } catch (e, stack) {
      print("Failed to recognize image: " + e.toString() + stack.toString());
      logAnalyticsEvent(
          name: 'recognition_failed',
          parameters: <String, dynamic>{
            'type': 'exception',
            'error': e.toString(),
          });
      Crashlytics.instance.recordError(e, stack);
    }
  }
}

Future<String> uploadPicture(File image, String name) async {
  final StorageReference ref = FirebaseStorage.instance.ref().child(name);
  final StorageUploadTask uploadTask = ref.putFile(
    image,
    new StorageMetadata(
      contentType: 'image/jpeg',
      // To enable Client-side caching you can set the Cache-Control headers here. Uncomment below.
      cacheControl: 'public,max-age=3600',
      customMetadata: <String, String>{'activity': 'test'},
    ),
  );
  await uploadTask.onComplete;
  //StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
  // final String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();

  return ref.path;
}

// Class to progress with search of the book and stream updates what's found
class BookSearchData {
  String bookrecordId;
  Book book;
  List<Bookrecord> bookrecords;

  // If data has records in Biblosphere
  bool get hasRecords => bookrecords != null && bookrecords.length > 0;

  // Get the closest record
  Bookrecord get first => hasRecords ? bookrecords[0] : null;

  BookSearchData({this.book, this.bookrecordId, Bookrecord bookrecord}) {
    if (bookrecord != null) {
      bookrecords = [bookrecord];
      bookrecordId = bookrecord.id;
      book = Book(
          isbn: bookrecord.isbn,
          authors: bookrecord.authors,
          title: bookrecord.title,
          image: bookrecord.image);
    }
  }

  Stream<BookSearchData> snapshots() async* {
    // Check if book available in Biblosphere
    try {
      if (bookrecords != null && bookrecords.length > 0) {
        // If bookrecords are there yield it
        yield this;
      } else if (bookrecordId != null && book == null) {
        // Search for particular bookrecord ()
        DocumentSnapshot doc = await Bookrecord.Ref(bookrecordId).get();

        if (doc.exists) {
          bookrecords = [Bookrecord.fromJson(doc.data)];
          book = Book(
              isbn: bookrecords.first.isbn,
              authors: bookrecords.first.authors,
              title: bookrecords.first.title,
              image: bookrecords.first.image);
          yield this;
        }
      } else if (book != null) {
        // Return data with book only
        yield this;

        // Try to find bookrecords and return updated data
        QuerySnapshot snap = await Firestore.instance
            .collection('bookrecords')
            .where('isbn', isEqualTo: book.isbn)
            .where('wish', isEqualTo: false)
            .getDocuments();

        List<Bookrecord> list =
            snap.documents.map((doc) => Bookrecord.fromJson(doc.data)).toList();
        list.sort((b1, b2) => ((b1.distance - b2.distance) * 1000).round());

        if (list.length > 0) {
          bookrecords = list;
          yield this;
        }
      }
    } catch (e, stack) {
      Crashlytics.instance.recordError(e, stack);
      print('Unknown error in BookSearchData:snapshots: $e');
    }

    // TODO: Check if book available at stores Ozon/Amazon

    // TODO: Check if book available in libraries
  }
}

class Scale {
  static const int Neighborhod = 3;
  static const int City = 50;
  static const int Country = 1000;
  static const int Continent = 10000;

  static String text(BuildContext context, int scale) {
    if (scale == Neighborhod)
      return S.of(context).inNeighborhod;
    else if (scale == City)
      return S.of(context).inCity;
    else if (scale == Country)
      return S.of(context).inCountry;
    else if (scale == Continent)
      return S.of(context).onContinent;
    else
      return '';
  }
}

enum FindWidgetMode { All, Search }

class FindBookWidget extends StatefulWidget {
  FindBookWidget({Key key, this.query, this.isbn, this.id}) : super(key: key);

  // Search filter by title/authors
  final String query;

  // Search filter by isbn
  final String isbn;

  // Search filter by bookrecord id
  final String id;

  @override
  _FindBookWidgetState createState() =>
      new _FindBookWidgetState(query: query, isbn: isbn, id: id);
}

class _FindBookWidgetState extends State<FindBookWidget> {
  // Search filter by title/authors
  final String query;

  // Search filter by isbn
  final String isbn;

  // Search filter by bookrecord id
  final String id;

  List<int> scales = [
    Scale.Neighborhod,
    Scale.City,
    Scale.Country,
    Scale.Continent
  ];
  int scaleIndex = 1;
  int availableBooks = 0;

  FindWidgetMode mode = FindWidgetMode.All;
  int rescaleLimit = 3;
  StreamSubscription<List<DocumentSnapshot>> areaSubscription;

  List<BookSearchData> books = [];

  TextEditingController textController;
  bool progressBar = false;

  @override
  void initState() {
    super.initState();

    //refreshLocation(context);

    textController = new TextEditingController();

    if (query != null) {
      // Show book by query
      textController.text = query;
      searchByTitleAuthor(query).then((b) {
        if (b == null || b.length == 0) {
          showSnackBar(context, S.of(context).snackBookNotFound);
          setState(() {
            books = [];
          });
        } else {
          setState(() {
            mode = FindWidgetMode.Search;
            books = b.map((x) => BookSearchData(book: x));
          });
        }
      });
    } else if (isbn != null) {
      // Show book by ISBN
      searchByIsbn(isbn).then((b) {
        if (b == null) {
          showSnackBar(context, S.of(context).isbnNotFound);
          Firestore.instance.collection('noisbn').document(isbn).setData({
            'count': FieldValue.increment(1),
            'requested_by': FieldValue.arrayUnion([B.user.id])
          }, merge: true);
          //print("No record found for isbn: $barcode");
          logAnalyticsEvent(name: 'book_noisbn', parameters: <String, dynamic>{
            'isbn': isbn,
          });
        } else {
          setState(() {
            mode = FindWidgetMode.Search;
            books = [BookSearchData(book: b)];
          });
        }
      });
    } else if (id != null) {
      // Show book by id
      setState(() {
        mode = FindWidgetMode.Search;
        books = [BookSearchData(bookrecordId: id)];
      });
    } else {
      // Show books close to location
      mode = FindWidgetMode.All;
      displayNearBooks();
    }
  }

  @override
  void dispose() {
    textController.dispose();
    if (areaSubscription != null) areaSubscription.cancel();
    super.dispose();
  }

  _FindBookWidgetState({this.query, this.isbn, this.id});

  Future<void> displayNearBooks() async {
    // Skip function if no geo-location
    if (B.position == null) {
      return;
    }

    // Query books with given scale
    CollectionReference ref = db
        .collection('bookrecords')
        .where('wish', isEqualTo: false)
        .reference();

    Stream<List<DocumentSnapshot>> stream = Geoflutterfire()
        .collection(collectionRef: ref)
        .within(
            center: GeoFirePoint(B.position.latitude, B.position.longitude),
            radius: scales[scaleIndex].toDouble(),
            field: 'location');

    if (areaSubscription != null) areaSubscription.cancel();

    areaSubscription = stream.listen((List<DocumentSnapshot> list) {
      // Exclude books belong to me (not possible to do on server side as Firestore doesn't support != conditions)
      list = list.where((rec) => rec.data['ownerId'] != B.user.id).toList();

      availableBooks = list.length;

      // Sort by distance and display first 100 books
      if (mode == FindWidgetMode.All && list.isNotEmpty) {
        // Map JSON to Bookrecords
        List<Bookrecord> results =
            list.map((doc) => Bookrecord.fromJson(doc.data)).toList();

        // TODO: What if bookrecords has null location? Should not be as it wont returned by geohash
        results.sort((a, b) => a.distance.compareTo(b.distance));

        books = results
            .take(100)
            .map((rec) => BookSearchData(bookrecord: rec))
            .toList();

        setState(() {});

        // If too many books reduce scale
        if (list.length > 200 && scaleIndex > 0) {
          // First 25 items are within smaller scale range
          if (results[20].distance < scales[scaleIndex - 1].toDouble() &&
              rescaleLimit > 0) {
            // Reduce scale
            scaleIndex -= 1;
            // Reduce left attempts to rescale
            rescaleLimit -= 1;
            // Run search for the near books again
            displayNearBooks();

            //TODO: Report to Analytic reduce of the scale
          }
        } else if (list.length < 10 && scaleIndex < scales.length - 1) {
          // If too few books increase scale
          // First 25 items are within smaller scale range
          if (rescaleLimit > 0) {
            // Increase scale
            scaleIndex += 1;
            // Reduce left attempts to rescale
            rescaleLimit -= 1;
            // Run search for the near books again
            displayNearBooks();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title: Text(S.of(context).findbookTitle,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(color: C.titleText)),
        centerTitle: true,
        // Allows the user to reveal the app bar if they begin scrolling
        // back up the list of items.
        floating: true,
        pinned: true,
        snap: true,
        // Display a placeholder widget to visualize the shrinking size.
        flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: ListView(
                //crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Container(height: 42),
                  new Container(
                    padding: new EdgeInsets.all(10.0),
                    child: new Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        new Expanded(
                          child: Theme(
                              data: ThemeData(platform: TargetPlatform.android),
                              child: TextField(
                                maxLines: 1,
                                controller: textController,
                                style: Theme.of(context).textTheme.headline6,
                                decoration: InputDecoration(
                                    //border: InputBorder.none,
                                    hintStyle:
                                        C.hints.apply(color: C.inputHints),
                                    hintText: S.of(context).hintAuthorTitle),
                              )),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 20.0),
                            child: RaisedButton(
                              textColor: Colors.white,
                              color: C.button,
                              child: assetIcon(search_100, size: 30),
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                mode = FindWidgetMode.Search;
                                setState(() {
                                  progressBar = true;
                                });
                                searchByTitleAuthor(textController.text)
                                    .then((b) {
                                  setState(() {
                                    progressBar = false;
                                  });
                                  if (b == null || b.length == 0) {
                                    setState(() {
                                      books.clear();
                                    });
                                    showSnackBar(context,
                                        S.of(context).snackBookNotFound);
                                    logAnalyticsEvent(
                                        name: 'search_not_found',
                                        parameters: <String, dynamic>{
                                          'type': 'text',
                                          'search_term': textController.text,
                                        });
                                  } else {
                                    setState(() {
                                      books = List<BookSearchData>.from(b
                                          .map((x) => BookSearchData(book: x)));
                                    });
                                    logAnalyticsEvent(
                                        name: 'search',
                                        parameters: <String, dynamic>{
                                          'type': 'text',
                                          'search_term': textController.text,
                                          'results': b.length,
                                        });
                                  }
                                });

                                // TODO: Find the way to report percentage of queries which found available books
                                /*
                                if (biblos.length > 0) {
                                  double distance =
                                      (biblos.first as Bookrecord).distance;
                                  logAnalyticsEvent(
                                      name: 'book_found',
                                      parameters: <String, dynamic>{
                                        'type': 'text',
                                        'search_term': textController.text,
                                        'isbn':
                                            (biblos.first as Bookrecord).isbn,
                                        'results': books.length,
                                        'in_biblosphere': biblos.length,
                                        'distance': distance == double.infinity
                                            ? 50000.0
                                            : distance,
                                      });
                                }
                                */
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  side: BorderSide(color: C.buttonBorder)),
                            )),
                      ],
                    ),
                  ),
                  new Container(
                    padding: new EdgeInsets.all(10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(S.of(context).scanISBN,
                            style: Theme.of(context).textTheme.headline6),
                        RaisedButton(
                          textColor: Colors.white,
                          color: C.button,
                          child: assetIcon(barcode_scanner_100, size: 30),
                          onPressed: () {
                            setState(() {
                              progressBar = true;
                            });

                            scanIsbn(context, (book) {
                              setState(() {
                                progressBar = false;
                                mode = FindWidgetMode.Search;
                                books = <BookSearchData>[
                                  BookSearchData(book: book)
                                ];
                              });
                            }).then((barcode) {
                              logAnalyticsEvent(
                                  name: 'search',
                                  parameters: <String, dynamic>{
                                    'type': 'isbn',
                                    'search_term': barcode,
                                    'results': books.length,
                                  });
                            });

                            // TODO: Find the way to report if found book is available in Biblosphere
                            /*
                            if (biblos.length > 0) {
                              double distance =
                                  (biblos.first as Bookrecord).distance;

                              logAnalyticsEvent(
                                  name: 'book_found',
                                  parameters: <String, dynamic>{
                                    'type': 'isbn',
                                    'search_term': barcode,
                                    'isbn': (biblos.first as Bookrecord).isbn,
                                    'results': books.length,
                                    'in_biblosphere': biblos.length,
                                    'distance': distance == double.infinity
                                        ? 50000.0
                                        : distance,
                                  });
                            }
                            */
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15.0),
                              side: BorderSide(color: C.buttonBorder)),
                        ),
                      ],
                    ),
                  ),
                  !progressBar &&
                          mode == FindWidgetMode.All &&
                          availableBooks > 0
                      ? Container(
                          padding: new EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                              S.of(context).booksAvailableForSearch(
                                  availableBooks,
                                  Scale.text(context, scales[scaleIndex])),
                              style: Theme.of(context).textTheme.bodyText2))
                      : Container(width: 0.0, height: 0.0),
                  progressBar
                      ? Container(
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: SizedBox(
                              height: 2.0,
                              child: LinearProgressIndicator(
                                  backgroundColor: C.titleBackground,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      C.buttonBorder))))
                      : Container(),
                ])),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight:
            !progressBar && mode == FindWidgetMode.All && availableBooks > 0
                ? 200
                : 185,
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          var book = books.elementAt(index);
          return StreamBuilder(
            stream: book.snapshots().asBroadcastStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData && book.book == null) {
                return Container();
              } else {
                // Choose icon based on conditions
                Widget buttons;
                if (!book.hasRecords) {
                  // Book not found in Biblosphere (=> screen to Stores/Libs)
                  buttons = Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Tooltip(
                            // TODO: Correct text search in stores/libraries
                            message: S.of(context).findBook,
                            child: RaisedButton(
                              textColor: C.buttonText,
                              color: C.cardBackground,
                              child: Text(S.of(context).buttonSearchThirdParty,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .apply(color: C.titleText)),
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => buildScaffold(
                                            context,
                                            null,
                                            new GetBookWidget(book: book.book),
                                            appbar: false)));

                                logAnalyticsEvent(
                                    name: 'search_elsewhere',
                                    parameters: <String, dynamic>{
                                      'user': B.user.id,
                                      'isbn': book.book.isbn,
                                    });
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  side: BorderSide(color: C.cardBackground)),
                            )),
                        Tooltip(
                            message: S.of(context).hintAddToWishlist,
                            child: IconButton(
                              color: C.cardBackground,
                              // TODO: Makes icon filled if book already in wishlist
                              icon:
                                  assetIcon(heart_100, size: 30, padding: 0.0),
                              onPressed: () async {
                                if (B.user.wishCount >=
                                    await wishlistAllowance()) {
                                  // TODO: Add translation & get a price for monthly plan
                                  showUpgradeDialog(
                                      context,
                                      S.of(context).dialogWishLimit(
                                          await upgradePrice()));

                                  logAnalyticsEvent(
                                      name: 'limit_reached',
                                      parameters: <String, dynamic>{
                                        'limit': 'wishlist',
                                        'user': B.user.id,
                                        'isbn': book.book.isbn,
                                      });
                                } else {
                                  // Add book into user's wishlist
                                  await addBookrecord(context, book.book,
                                      B.user, true, await currentLocation(),
                                      snackbar: true);

                                  logAnalyticsEvent(
                                      name: 'add_to_wish_list_attempt',
                                      parameters: <String, dynamic>{
                                        'user': B.user.id,
                                        'isbn': book.book.isbn,
                                      });
                                }
                              },
                            ))
                      ]);
                } else if (book.first.holderId == B.user.id) {
                  // Book found in user's own catalog (=> MyBooks)
                  buttons = Tooltip(
                      message: S.of(context).hintManageBook,
                      child: RaisedButton(
                        textColor: C.buttonText,
                        color: C.cardBackground,
                        child: Row(children: <Widget>[
                          Text(S.of(context).buttonManageBook,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .apply(color: C.titleText))
                        ]),
                        onPressed: () async {
                          logAnalyticsEvent(
                              name: 'find_my_book',
                              parameters: <String, dynamic>{
                                'user': B.user.id,
                                'isbn': book.book.isbn,
                              });

                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => buildScaffold(
                                      context,
                                      null,
                                      ShowBooksWidget(filter: book.book.isbn),
                                      appbar: false)));
                        },
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(15.0),
                            side: BorderSide(color: C.cardBackground)),
                      ));
                } else {
                  // Book found in Biblosphere (=> Get book and Chat)
                  buttons = Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Tooltip(
                            message: S.of(context).hintConfirmHandover,
                            child: RaisedButton(
                              textColor: C.buttonText,
                              color: C.cardBackground,
                              child: Text(S.of(context).buttonConfirmBooks,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .apply(color: C.titleText)),
                              onPressed: () async {
                                if (B.user.balance <= -await booksAllowance()) {
                                  // TODO: Add translation & get a price for monthly plan
                                  showUpgradeDialog(
                                      context,
                                      S.of(context).dialogBookLimit(
                                          await upgradePrice()));

                                  logAnalyticsEvent(
                                      name: 'limit_reached',
                                      parameters: <String, dynamic>{
                                        'limit': 'books',
                                        'user': B.user.id,
                                        'isbn': book.book.isbn,
                                      });
                                } else {
                                  // Update holder of the book
                                  handover(book.first, B.user);
                                }
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  side: BorderSide(color: C.cardBackground)),
                            )),
                        Tooltip(
                            message: S.of(context).hintHolderChatOpen,
                            child: IconButton(
                              color: C.cardBackground,
                              icon: assetIcon(communication_100,
                                  size: 30, padding: 0.0),
                              onPressed: () async {
                                Chat.runChatWithBookRequest(
                                    context, book.first);

                                logAnalyticsEvent(
                                    name: 'book_request_attempt',
                                    parameters: <String, dynamic>{
                                      'user': B.user.id,
                                      'isbn': book.book.isbn,
                                    });
                              },
                            ))
                      ]);
                }

                return GestureDetector(
                    onTap: () async {},
                    child: Container(
                        color: C.cardBackground,
                        margin: EdgeInsets.all(3.0),
                        child: Row(children: <Widget>[
                          bookImage(book.book, 80,
                              padding: EdgeInsets.all(5.0)),
                          Expanded(
                              child: Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(book.book.authors[0],
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption),
                                        Text(book.book.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2),
                                        book.hasRecords
                                            ? Text(
                                                book.first.distance.isFinite
                                                    ? S
                                                        .of(context)
                                                        .distanceLine(distance(
                                                            book.first
                                                                .distance))
                                                    : S
                                                        .of(context)
                                                        .distanceUnknown,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2)
                                            : Container(),
                                        book.hasRecords
                                            ? Text(
                                                (book.first.holderId ==
                                                        B.user.id)
                                                    ? S
                                                        .of(context)
                                                        .youHaveThisBook
                                                    : S.of(context).bookWith(
                                                        book.first.holderName),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2)
                                            : Container(),
                                        // Buttons for book: Search, MyBooks, Chat
                                        buttons
                                      ]))),
                        ])));
              }
            },
          );
        }, childCount: books != null ? books.length : 0),
      )
    ]);
  }
}

class GetBookWidget extends StatefulWidget {
  GetBookWidget({
    Key key,
    @required this.book,
  }) : super(key: key);

  final Book book;

  @override
  _GetBookWidgetState createState() => new _GetBookWidgetState();
}

class _GetBookWidgetState extends State<GetBookWidget> {
  //List<Book> suggestions = [];
  Bookrecord bookrecord;
  bool inLibraries = false;
  bool inBookstores = true;
  String libraryService;
  String libraryQuery;

  @override
  void initState() {
    super.initState();
    searchLibraries(widget.book).then((providers) {
      if (providers != null) {
        setState(() {
          inLibraries = true;
          libraryService = providers.keys.first;
          libraryQuery = providers[libraryService];
        });
      }
    });
    searchBookstores();
  }

  _GetBookWidgetState();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title: Text(S.of(context).titleGetBook,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(color: C.titleText)),
        // Allows the user to reveal the app bar if they begin scrolling
        // back up the list of items.
        floating: true,
        pinned: true,
        snap: true,
        // Display a placeholder widget to visualize the shrinking size.
        bottom: PreferredSize(
            child: Container(
                margin: EdgeInsets.all(5.0),
                alignment: Alignment.topLeft,
                child: Text(S.of(context).bookNotFound)),
            preferredSize: Size.fromHeight(30.0)),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight: 110,
      ),
      SliverToBoxAdapter(
        child: Card(
            child: GestureDetector(
          onTap: () async {
            addBookrecord(
                context, widget.book, B.user, true, await currentLocation(),
                source: 'googlebooks');
          },
          child: Row(children: <Widget>[
            bookImage(widget.book, 50.0, padding: EdgeInsets.all(10.0)),
            Expanded(
                child: Container(
              padding: new EdgeInsets.all(10.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Container(
                      child: Text(S.of(context).addToWishlist,
                          style: Theme.of(context).textTheme.bodyText2)),
                ],
              ),
            )),
          ]),
        )),
      ),
      SliverToBoxAdapter(
        child: inLibraries
            ? new GestureDetector(
                onTap: () async {
                  logAnalyticsEvent(
                      name: 'library_click',
                      parameters: <String, dynamic>{
                        'isbn': widget.book.isbn,
                        'user': B.user.id,
                        'library': libraryQuery,
                      });

                  if (await canLaunch(libraryQuery)) {
                    await launch(libraryQuery);
                  }
                },
                child: new Card(
                  child: Row(children: <Widget>[
                    bookImage(widget.book, 50.0,
                        padding: EdgeInsets.all(
                            10.0)), //child: new Icon(MyIcons.library, size: 50)),
                    Expanded(
                        child: Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(S.of(context).bookInLibrary,
                              style: Theme.of(context).textTheme.bodyText2),
                          new Text(libraryService,
                              style: Theme.of(context).textTheme.bodyText2),
                          new Text('',
                              style: Theme.of(context).textTheme.bodyText2),
                        ],
                      ),
                    )),
                  ]),
                ))
            : Container(),
      ),
      SliverToBoxAdapter(
        child: inBookstores
            ? new GestureDetector(
                onTap: () async {
                  String url;
                  String bookstore;
                  if (widget.book.isbn.startsWith('9785')) {
                    bookstore = 'www.ozon.ru';
                    url =
                        'https://www.ozon.ru/category/knigi-16500/?text=${widget.book.title + ' ' + widget.book.authors.join(' ')}';
                  } else {
                    bookstore = 'www.amazon.com';
                    url =
                        'https://www.amazon.com/s?k=${widget.book.title + ' ' + widget.book.authors.join(' ')}';
                  }

                  logAnalyticsEvent(
                      name: 'bookstore_click',
                      parameters: <String, dynamic>{
                        'isbn': widget.book.isbn,
                        'user': B.user.id,
                        'store': bookstore,
                      });

                  var encoded = Uri.encodeFull(url);
                  if (await canLaunch(encoded)) {
                    await launch(encoded);
                  }
                },
                child: new Card(
                  child: Row(children: <Widget>[
                    bookImage(widget.book, 50.0, padding: EdgeInsets.all(10.0)),
                    Expanded(
                        child: Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(S.of(context).buyBook,
                              style: Theme.of(context).textTheme.bodyText2),
                          new Text(
                              widget.book.isbn.startsWith('9785')
                                  ? 'www.ozon.ru'
                                  : 'www.amazon.com',
                              style: Theme.of(context).textTheme.bodyText2),
                          new Text('',
                              style: Theme.of(context).textTheme.bodyText2),
                        ],
                      ),
                    )),
                  ]),
                ))
            : Container(),
      ),
    ]);
  }

  List<Provider> libraryServers = [
    // Russia, Sankt-Peterburg
    Provider(
        name: 'www.spblib.ru',
        query:
            'https://spblib.ru/catalog?p_p_id=ru_spb_iac_esbo_portal_catalog_CatalogPortlet&p_p_lifecycle=0&p_p_lifecycle=1&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-SUBJECT=&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-SERIES=&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-SUBJECT-type=CONTAIN&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-PUBLISHER-type=CONTAIN&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_javax.portlet.action=%2F&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-PUBLISHER=&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_formDate=1572000758655&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-TITLE=%TITLE%&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-TITLE-type=CONTAIN&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_LIBRARY=&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_publicationType=BOOK&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-QUERY=&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-AUTHOR=%AUTHOR%&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-PERSONALITY-type=CONTAIN&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-AUTHOR-type=CONTAIN&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-YEAR-to=&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_checkboxNames=availableOnly&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-YEAR-from=&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_availableOnly=true&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-LANGUAGE=&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-SERIES-type=CONTAIN&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-full=1&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-PERSONALITY=&_ru_spb_iac_esbo_portal_catalog_CatalogPortlet_book-TYPE=books#search-results',
        country: 'RU',
        area: 'Sankt-Peterburg'),
    // Russia, Ekaterinburg
    Provider(
        name: 'webirbis.ekmob.org',
        query: 'https://webirbis.ekmob.org/?db=0&v=0&q=%TITLE% %AUTHOR%',
        country: 'RU',
        area: 'Yekaterinburg'),
    // Global
    Provider(
        name: 'www.worldcat.org',
        query:
            'https://www.worldcat.org/search?q=ti:%TITLE%+au:%AUTHOR%&fq=x0:book+x4:printbook&qt=advanced',
        country: 'ALL'),
  ];

  Future<Map<String, String>> searchLibraries(Book book) async {
    Provider provider;
    if (B.position != null) {
      List<Placemark> placemarks = await Geolocator()
          .placemarkFromCoordinates(B.position.latitude, B.position.longitude);

      // Sankt-Peterburg  (59.9343, 30.3351, localeIdentifier: 'en')
      // Ekaterinburg  (56.8389, 60.6057, localeIdentifier: 'en')
      //List<Placemark> placemarks = await Geolocator()
      //    .placemarkFromCoordinates(59.9343, 30.3351, localeIdentifier: 'en');

      String country, area;

      placemarks.forEach((p) {
        if (p.isoCountryCode != null) country = p.isoCountryCode;
        if (p.administrativeArea != null) area = p.subAdministrativeArea;
        if (area == null || area.isEmpty) area = p.administrativeArea;
      });

      List<Provider> providers = libraryServers
          .where((p) => p.country == country && p.area == area)
          .toList();

      if (providers != null && providers.isNotEmpty) {
        provider = providers.first;
      }
    }

    if (provider == null) {
      provider = libraryServers.firstWhere((p) => p.country == 'ALL');
    }

    if (provider != null) {
      String query = provider.query;
      query = query.replaceAll(r'%TITLE%', book.title);
      query = query.replaceAll(r'%AUTHOR%', book.authors.join(' '));
      String encoded = Uri.encodeFull(query);
      return {provider.name: encoded};
    }
    return null;
  }

  Future<void> searchBookstores() async {}
}

enum BookDetailsMode { Input, Edit, View }

class BookDetailsWidget extends StatefulWidget {
  BookDetailsWidget(
      {Key key, @required this.bookrecord, this.mode = BookDetailsMode.Edit})
      : super(key: key);

  final Bookrecord bookrecord;
  final BookDetailsMode mode;

  @override
  _BookDetailsWidgetState createState() =>
      new _BookDetailsWidgetState(bookrecord: bookrecord, mode: mode);
}

class _BookDetailsWidgetState extends State<BookDetailsWidget> {
  //List<Book> suggestions = [];
  Bookrecord bookrecord;
  BookDetailsMode mode;

  TextEditingController authorsTextController;
  TextEditingController titleTextController;
  TextEditingController descriptionTextController;
  bool editDescription = false;

  // List of global list tags matching the query
  List<String> matching_tags = [];

  Map<String, dynamic> languages;
  List<String> preferredLanguages = [
    'eng',
    'rus',
    'spa',
    'fra',
    'kor',
    'jpn',
    'ara',
    'hin',
    'zho',
    'deu'
  ];

  @override
  void initState() {
    super.initState();

    authorsTextController = new TextEditingController();
    titleTextController = new TextEditingController();
    descriptionTextController = new TextEditingController();

    // Read language codes from JSON
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String data = await rootBundle.loadString('assets/languages.json');
      setState(() {
        languages = json.decode(data);
      });
      print(languages);
    });
  }

  @override
  void dispose() {
    print('!!!DEBUG: Store data in Firestore and MySQL');
    if (bookrecord != null) {
      bookrecord.ref.setData(bookrecord.toJson(), merge: true);
      if (mode == BookDetailsMode.Input) 
        print('!!!DEBUG adding book to catalog');
        addBookToCatalog([bookrecord]);
    }

    authorsTextController.dispose();
    titleTextController.dispose();
    descriptionTextController.dispose();

    super.dispose();
  }

  _BookDetailsWidgetState(
      {Key key, @required this.bookrecord, this.mode = BookDetailsMode.Edit});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title: Text(S.of(context).titleBookDetails,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(color: C.titleText)),
        // Allows the user to reveal the app bar if they begin scrolling
        // back up the list of items.
        floating: false,
        pinned: true,
        snap: false,
        // Display a placeholder widget to visualize the shrinking size.
      ),
      SliverToBoxAdapter(
        child: BookrecordWidget(
            bookrecord: bookrecord,
            builder: (context, rec) {
              // Screen with bookrecord details
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Message with guidance (only in input mode)
                  guidanceMessage(context),

                  // Book cover, Author, Title and ISBN
                  // First cover has to be added (author & title are inactive)
                  Row(children: <Widget>[
                    Stack(children: <Widget>[
                      Container(child: bookImage(bookrecord, 80, padding: EdgeInsets.all(5.0))),
                      bookrecord.hasCover
                          ? Container()
                          : Positioned.fill(child: Container(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(child: Tooltip(
                                    message:
                                        S.of(context).recognizeCoverFromGallery,
                                    child: IconButton(
                                      color: C.button,
                                      icon: assetIcon(image_gallery_100,
                                          size: 30, padding: 0.0),
                                      onPressed: () async {
                                        recognizeCover(context,
                                            source: ImageSource.gallery);
                                      },
                                    ))),
                                Expanded(child: Tooltip(
                                    message:
                                        S.of(context).recognizeCoverFromCamera,
                                    child: IconButton(
                                      color: C.button,
                                      icon: assetIcon(compact_camera_100,
                                          size: 30, padding: 0.0),
                                      onPressed: () async {
                                        recognizeCover(context,
                                            source: ImageSource.camera);
                                      },
                                    ))),
                              ],
                            )))
                    ]),
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.only(left: 10.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // TODO: Add editing by taping the field
                                  bookrecord.hasAuthor
                                      ?
                                      // Show authors if present
                                      Text('${bookrecord.authors[0]}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2)
                                      :
                                      // Show input field if author is empty
                                      TextField(
                                          maxLines: 1,
                                          controller: authorsTextController,
                                          onEditingComplete: () {
                                            // TODO: Save authors to Firestore
                                            setState(() {
                                              bookrecord.authors =
                                                  List<String>.from(
                                                      authorsTextController.text
                                                          .split(','));
                                              bookrecord.ref.setData(bookrecord.toJson(), merge: true);
                                            });
                                          },
                                          style: Theme.of(context).textTheme.bodyText2,
                                          decoration: InputDecoration(
                                              //border: InputBorder.none,
                                              hintStyle: C.hints
                                                  .apply(color: C.inputHints),
                                              hintText:
                                                  S.of(context).hintAuthor),
                                        ),
                                  // TODO: Add editing by taping the field
                                  bookrecord.hasTitle
                                      ?
                                      // Show title if present
                                      Text('\"${bookrecord.title}\"',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2)
                                      :
                                      // Show input field if author is empty
                                      TextField(
                                          maxLines: 1,
                                          controller: titleTextController,
                                          onEditingComplete: () {
                                            // TODO: Save title to Firestore
                                            setState(() {
                                              bookrecord.title =
                                                  titleTextController.text;
                                              bookrecord.ref.setData(bookrecord.toJson(), merge: true);
                                            });
                                          },
                                          style: Theme.of(context).textTheme.bodyText2,
                                          decoration: InputDecoration(
                                              //border: InputBorder.none,
                                              hintStyle: C.hints
                                                  .apply(color: C.inputHints),
                                              hintText:
                                                  S.of(context).hintTitle),
                                        ),
                                ])))
                  ]),

                  // Cover text (only show in input mode if either of author/title is empty)
                    mode == BookDetailsMode.Input &&
                          bookrecord.hasCoverText &&
                          (!bookrecord.hasAuthor || !bookrecord.hasTitle)
                      ? Container(margin: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0),
                          child: Column(children: <Widget>[
                            Text(S.of(context).labelCoverText,
                          style: Theme.of(context).textTheme.bodyText2.apply(fontWeightDelta: 2)),
                            SelectableText(bookrecord.coverText,
                              style: Theme.of(context).textTheme.bodyText2)]))
                      : Container(),

                  // TODO: Add bookspine text (only show in input mode if author/title are empty)

                  // Language dropdown
                  Container(margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(S.of(context).labelLanguage,
                          style: Theme.of(context).textTheme.bodyText2.apply(fontWeightDelta: 2)),
                          Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: DropdownButton(
                                  value: bookrecord.language,
                                  items: languages == null
                                      ? []
                                      : languages.values
                                          .where((element) => preferredLanguages
                                              .contains(element['lng']))
                                          .map((value) => DropdownMenuItem(
                                              value: value['lng'],
                                              child: Text(value['endonym'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2)))
                                          .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      bookrecord.language = value;
                                      bookrecord.ref.setData(bookrecord.toJson(), merge: true);
                                    });
                                    print('!!!DEBUG value selected: $value');
                                  }))
                    ],
                  )),

                  // Genre dropdown
                  Container(margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(S.of(context).labelGenre,
                          style: Theme.of(context).textTheme.bodyText2.apply(fontWeightDelta: 2)),
                        Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: DropdownButton(
                        value: bookrecord.genre,
                        items: S
                            .of(context)
                            .genres
                            .keys
                            .map((key) => DropdownMenuItem(
                                value: key,
                                child: ['fiction', 'nonfiction'].contains(key) ? Text(
                                        S.of(context).genre(key),
                                    style:
                                        Theme.of(context).textTheme.bodyText2.apply(fontWeightDelta: 2)): Text(
                                        '     ' + S.of(context).genre(key),
                                    style:
                                        Theme.of(context).textTheme.bodyText2)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            bookrecord.genre = value;
                            bookrecord.ref.setData(bookrecord.toJson(), merge: true);
                          });
                          print(
                              '!!!DEBUG value selected: $value, ${S.of(context).genres[value]}');
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return S
                              .of(context)
                              .genres
                              .keys
                              .map<Widget>((String item) {
                            return Center(child: Text(S.of(context).genre(item),
                                style: Theme.of(context).textTheme.bodyText2));
                          }).toList();
                        },
                      ))
                    ],
                  )),

                  // Description
                  Container(margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0),
                    child: Text(S.of(context).labelDescription,
                    style: Theme.of(context).textTheme.bodyText2.apply(fontWeightDelta: 2))),
                  Container(margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: bookrecord.hasDescription && !editDescription
                                      ?
                                      // Show description if present
                                      GestureDetector(onTap: () {

                                        setState(() {
                                          editDescription = true;
                                        });
                                      },  
                                        child: Text('${bookrecord.description}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2))
                                      :
                                      // Show input field if description is empty
                                      Stack(children: <Widget> [
                                        TextField(
                                          minLines: 3,
                                          maxLines: 10,
                                          controller: descriptionTextController,
                                          keyboardType: TextInputType.multiline,
                                          textInputAction: TextInputAction.done,
                                          onEditingComplete: () {
                                            // TODO: Save description to Firestore
                                            FocusScope.of(context).unfocus();
                                            setState(() {
                                              editDescription = false;
                                              bookrecord.description = descriptionTextController.text;
                                              bookrecord.ref.setData(bookrecord.toJson(), merge: true);
                                            });
                                          },
                                          style: Theme.of(context).textTheme.bodyText2,
                                          decoration: InputDecoration(
                                              //border: InputBorder.none,
                                              hintStyle: C.hints
                                                  .apply(color: C.inputHints),
                                              hintText:
                                                  S.of(context).hintDescription),
                                        ),
                                        Positioned.fill(child: Container(alignment: Alignment.bottomRight,
                                        child: Tooltip(
                                    message:
                                        S.of(context).recognizeBackFromCamera,
                                    child: IconButton(
                                      color: C.button,
                                      icon: assetIcon(compact_camera_100,
                                          size: 30),
                                      onPressed: () async {
                                        recognizeBack(context,
                                            source: ImageSource.camera);
                                      },
                                    ))))
                                        ])),

                  // User tags
                  Container(margin: EdgeInsets.only(left: 5.0, top: 10.0, right: 5.0),
                    child: Text(S.of(context).labelUserTags,
                    style: Theme.of(context).textTheme.bodyText2.apply(fontWeightDelta: 2))),
                  Container(margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: ChipsInput(
                      initialValue: bookrecord != null && bookrecord.tags != null ? bookrecord.tags : [],
                      //decoration: InputDecoration(
                      //    labelText: "Add #tags",
                      //),
                      maxChips: 5,
                      findSuggestions: (String query) {
                          if (query.length != 0) {
                              String lowercaseQuery = query.toLowerCase();
                              if (query.length >= 2)
                                // Query API and assign result to global list of tags
                                getTagList(lowercaseQuery).then((value) => matching_tags = value);

                              List<String> options = [];

                              // Check tags in local tags of the book
                              if (bookrecord != null && bookrecord.allTags != null)
                                options = bookrecord.allTags.where((tag) => tag.toLowerCase().contains(query.toLowerCase())).toList(growable: false)
                                    ..sort((a, b) => a
                                        .toLowerCase()
                                        .indexOf(lowercaseQuery)
                                        .compareTo(b.toLowerCase().indexOf(lowercaseQuery)));

                              // None of the book tags matches the query
                              if (options.length == 0)
                                options = matching_tags.where((tag) => tag.toLowerCase().contains(query.toLowerCase())).toList(growable: false)
                                    ..sort((a, b) => a
                                        .toLowerCase()
                                        .indexOf(lowercaseQuery)
                                        .compareTo(b.toLowerCase().indexOf(lowercaseQuery)));

                              // In case no suggestions offer what's typed
                              if (options.length == 0)
                                options = <String>[lowercaseQuery];

                              return options;
                          } else {
                              return const <String>[];
                          }
                      },
                      onChanged: (data) {
                          print('!!!DEBUG: ON CHANGE $data');
                          bookrecord.tags = List<String>.from(data);
                          bookrecord.allTags = List<String>.from(data);
                          bookrecord.ref.setData(bookrecord.toJson(), merge: true);
                      },
                      chipBuilder: (context, state, tag) {
                          return InputChip(
                              key: ObjectKey(tag),
                              label: Text(tag),
                              avatar: CircleAvatar(
                                  child: Text('#'),
                              ),
                              onDeleted: () => state.deleteChip(tag),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                      },
                      suggestionBuilder: (context, state, tag) {
                          return ListTile(
                              key: ObjectKey(tag),
                              leading: CircleAvatar(
                                  child: Text('#'),
                              ),
                              title: Text(tag),
                              onTap: () => state.selectSuggestion(tag),
                          );
                      },
                  ))
                ],
              );
           }),
      ),
    ]);
  }

  Widget guidanceMessage(BuildContext context) {
    String direction;
    if (mode != BookDetailsMode.Input)
      return Container();
    else if (bookrecord.isEmpty)
      direction = S.of(context).entryGuidanceEmptyBook;
    else if (!bookrecord.hasCover)
      direction = S.of(context).entryGuidanceNoCover;
    else if (bookrecord.hasCover &&
        (!bookrecord.hasAuthor || !bookrecord.hasTitle))
      direction = S.of(context).entryGuidanceCoverButIncomplete;
    else if (!bookrecord.isComplete)
      direction = S.of(context).entryGuidanceNotComplete;
    else
      direction = S.of(context).entryGuidanceComplete;

    return Container(
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), border: Border.all(color: Colors.red)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
      Text(direction, style: Theme.of(context).textTheme.bodyText2),
      GestureDetector(
          onTap: () async {
            String url =
                'https://www.google.com/search?q=isbn+${bookrecord.isbn}';

            if (bookrecord.hasAuthor) url += '+' + bookrecord.authors.join('+');

            if (bookrecord.hasTitle) url += '+' + bookrecord.title;

            String encoded = Uri.encodeFull(url);

            if (await canLaunch(encoded)) {
              await launch(encoded);
            } else {
              throw 'Could not launch url $encoded';
            }
          },
          child: Text(S.of(context).clickToGoogleBook,
              style: Theme.of(context).textTheme.bodyText1.apply(
                  color: Colors.blue, decoration: TextDecoration.underline)))
    ]));
  }

  Future recognizeCover(BuildContext context,
      {ImageSource source = ImageSource.camera}) async {
    // Check that record is not empty
    if (bookrecord.isbn == null || bookrecord.isbn.isEmpty) {
      print('!!!DEBUG: Empty ISBN');
      return;
    }

    try {
      // Limit size of the photo to improve speed 
      File image = await ImagePicker.pickImage(source: source, maxWidth: 800.0);
      //print('!!!DEBUG: Recognize image: ${image.path}');

      // Check that image is selected
      if (image == null) {
        print('!!!DEBUG: No image selected');
        return;
      }

      String name = 'covers_full/' + bookrecord.isbn + "-" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";

      //final String storagePath = await uploadPicture(image, name);
      // !!!DEBUG
      String storagePath = 'covers_full/9785389015234.jpg';

      print('!!!DEBUG: Storage path: $storagePath');

      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      IdTokenResult idtoken = await user.getIdToken();

      String body = json.encode({
        'uid': user.uid,
        'uri': storagePath,
        'isbn': bookrecord.isbn,
        'ocr': bookrecord.isEmpty,
      });

      // Call Python service to recognize
      Response res = await LibConnect.getCloudFunctionClient().post(
          'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/add_cover',
          body: body,
          headers: {
            HttpHeaders.authorizationHeader: "Bearer ${idtoken.token}",
            HttpHeaders.contentTypeHeader: "application/json"
          });

      if (res.statusCode != 200) {
        print('!!!DEBUG: Recognition request failed');
        logAnalyticsEvent(
            name: 'cover_recognition_failed',
            parameters: <String, dynamic>{
              'type': 'response',
              'error': res.statusCode.toString(),
            });
      }
      print('!!!DEBUG: Cover recognition result: ${res.body}');

      final resJson = json.decode(res.body);

      if (resJson is Map && resJson.containsKey('error')) {
        print('!!!DEBUG: add_cover error ${resJson['error']['message']}');
      } else {
        print('!!!DEBUG: Response cover text ${resJson[0]['cover_text']}');

        setState(() {
          if (resJson[0]['cover_text'] != null &&
              resJson[0]['cover_text'].isNotEmpty)
            bookrecord.coverText = resJson[0]['cover_text'];

          if (!bookrecord.hasLanguage && 
              resJson[0]['language'] != null &&
              resJson[0]['language'].isNotEmpty)
            bookrecord.language = resJson[0]['language'];

          if (!bookrecord.hasCover &&
              resJson[0]['image'] != null &&
              resJson[0]['image'].isNotEmpty)
            bookrecord.image = resJson[0]['image'];
        });
      }
    } catch (e, stack) {
      print("Failed to recognize cover: " + e.toString() + stack.toString());
      logAnalyticsEvent(
          name: 'cover_recognition_failed',
          parameters: <String, dynamic>{
            'type': 'exception',
            'error': e.toString(),
          });
      Crashlytics.instance.recordError(e, stack);
    }
  }

  Future recognizeBack(BuildContext context,
      {ImageSource source = ImageSource.camera}) async {
    // Check that record is not empty
    if (bookrecord.isbn == null || bookrecord.isbn.isEmpty) {
      print('!!!DEBUG: Empty ISBN');
      return;
    }

    try {
      File image = await ImagePicker.pickImage(source: source);
      //print('!!!DEBUG: Recognize image: ${image.path}');

      // Check that image is selected
      if (image == null) {
        print('!!!DEBUG: No image selected');
        return;
      }

      String name = 'bookback/' + bookrecord.isbn + "-" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";

      //final String storagePath = await uploadPicture(image, name);
      // !!!DEBUG
      String storagePath = 'bookback/9785389015234-1592676485108.jpg';

      print('!!!DEBUG: Storage path: $storagePath');

      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      IdTokenResult idtoken = await user.getIdToken();

      String body = json.encode({
        'uid': user.uid,
        'uri': storagePath,
        'isbn': bookrecord.isbn,
        'ocr': ! bookrecord.hasDescription,
      });

      // Call Python service to recognize
      Response res = await LibConnect.getCloudFunctionClient().post(
          'https://biblosphere-api-ihj6i2l2aq-uc.a.run.app/add_back',
          body: body,
          headers: {
            HttpHeaders.authorizationHeader: "Bearer ${idtoken.token}",
            HttpHeaders.contentTypeHeader: "application/json"
          });

      if (res.statusCode != 200) {
        print('!!!DEBUG: Book back recognition request failed');
        logAnalyticsEvent(
            name: 'back_recognition_failed',
            parameters: <String, dynamic>{
              'type': 'response',
              'error': res.statusCode.toString(),
            });
      }
      print('!!!DEBUG: Back recognition result: ${res.body}');

      final resJson = json.decode(res.body);

      if (resJson is Map && resJson.containsKey('error')) {
        print('!!!DEBUG: add_back error ${resJson['error']['message']}');
      } else {
        print('!!!DEBUG: Response back text ${resJson[0]['cover_text']}');

        setState(() {
          if (!bookrecord.hasLanguage && 
              resJson[0]['language'] != null &&
              resJson[0]['language'].isNotEmpty)
            bookrecord.language = resJson[0]['language'];

          if (resJson[0]['back_text'] != null &&
              resJson[0]['back_text'].isNotEmpty) {
                bookrecord.description = resJson[0]['back_text'];
                descriptionTextController.text = bookrecord.description;
              }
        });
      }
    } catch (e, stack) {
      print("Failed to recognize back: " + e.toString() + stack.toString());
      logAnalyticsEvent(
          name: 'back_recognition_failed',
          parameters: <String, dynamic>{
            'type': 'exception',
            'error': e.toString(),
          });
      Crashlytics.instance.recordError(e, stack);
    }
  }
}
