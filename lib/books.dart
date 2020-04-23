import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

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
    barcode = await BarcodeScanner.scan();

    Book book = await searchByIsbn(barcode);

    if (book != null) {
      onSuccess(book);
    } else {
      Firestore.instance.collection('noisbn').document(barcode).setData({
        'count': FieldValue.increment(1),
        'requested_by': FieldValue.arrayUnion([B.user.id])
      }, merge: true);
      //print("No record found for isbn: $barcode");
      showSnackBar(context, S.of(context).isbnNotFound);
      logAnalyticsEvent(name: 'book_noisbn', parameters: <String, dynamic>{
        'isbn': barcode,
      });
    }
  } on PlatformException catch (e, stack) {
    if (e.code == BarcodeScanner.CameraAccessDenied) {
      //TODO: Inform user
      print('The user did not grant the camera permission!');
      FlutterCrashlytics().logException(e, stack);
    } else {
      print('Unknown platform error in scanIsbn: $e');
      FlutterCrashlytics().logException(e, stack);
    }
  } on FormatException {
    print(
        'null (User returned using the "back"-button before scanning anything. Result)');
  } catch (e, stack) {
    FlutterCrashlytics().logException(e, stack);
    print('Unknown error in scanIsbn: $e');
  }

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
            style: Theme.of(context).textTheme.title.apply(color: C.titleText)),
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
                                File image = await ImagePicker.pickImage(
                                    source: ImageSource.gallery);
                                await recognizeImage(context, image);
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
                                File image = await ImagePicker.pickImage(
                                    source: ImageSource.camera);
                                await recognizeImage(context, image);
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
                              scanIsbn(context, (book) {
                                setState(() {
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
                                style: Theme.of(context).textTheme.title,
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
                                searchByTitleAuthor(textController.text)
                                    .then((b) {
                                  setState(() {
                                    suggestions = b;
                                  });
                                  logAnalyticsEvent(
                                      name: 'book_add_attempt',
                                      parameters: <String, dynamic>{
                                        'type': 'text',
                                        'search_term': textController.text,
                                        'results': b.length,
                                      });
                                });
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  side: BorderSide(color: C.buttonBorder)),
                            )),
                      ],
                    ),
                  ),
                ])),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight: 180,
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          Book book = suggestions[index];
          return Container(
              margin: EdgeInsets.all(3.0),
              child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      suggestions.clear();
                    });
                    addBookrecord(
                        context, book, B.user, false, await currentLocation(),
                        source: 'googlebooks');
                    //showSnackBar(context, S.of(context).bookAdded);
                  },
                  child: Row(children: <Widget>[
                    bookImage(book, 50, padding: EdgeInsets.all(5.0)),
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.only(left: 10.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${book.authors[0]}',
                                      style: Theme.of(context).textTheme.body1),
                                  Text('\"${book.title}\"',
                                      style: Theme.of(context).textTheme.body1)
                                ])))
                  ])));
        }, childCount: suggestions != null ? suggestions.length : 0),
      )
    ]);
  }

  Future recognizeImage(BuildContext context, File image) async {
    try {
      if (image == null) return;

      //print('!!!DEBUG: Recognize image: ${image.path}');

      String name = getTimestamp() + ".jpg";

      showSnackBar(context, S.of(context).snackRecgnitionStarted, duration: 6);

      final String storagePath = await uploadPicture(image, B.user.id, name);
      // !!!DEBUG
      //String storagePath = 'images/oyYUDByQGVdgP13T1nyArhyFkct1/1586749554453.jpg';

      //print('!!!DEBUG: Image cloud path: ${storagePath}');

      GeoFirePoint location = await currentLocation();
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      IdTokenResult idtoken = await user.getIdToken();

      String body = json.encode({
        'uid': user.uid,
        'uri': storagePath,
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
        logAnalyticsEvent(
            name: 'recognition_failed',
            parameters: <String, dynamic>{
              'type': 'response',
              'error': res.statusCode.toString(),
            });
      }
      //print('!!!DEBUG: ${res.body}');
      //print('!!!DEBUG: Request for recognition queued');
    } catch (ex, stack) {
      print("Failed to recognize image: " + ex.toString() + stack.toString());
      logAnalyticsEvent(
          name: 'recognition_failed',
          parameters: <String, dynamic>{
            'type': 'exception',
            'error': ex.toString(),
          });
      FlutterCrashlytics().logException(ex, stack);
    }
  }
}

Future<String> uploadPicture(File image, String user, String name) async {
  final StorageReference ref =
      FirebaseStorage.instance.ref().child('images').child(user).child(name);
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

  BookSearchData({this.book, this.bookrecordId});

  Stream<BookSearchData> snapshots() async* {
    // Check if book available in Biblosphere
    try {
      // Search for particular bookrecord ()
      if (bookrecordId != null && book == null) {
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
      FlutterCrashlytics().logException(e, stack);
      print('Unknown error in BookSearchData:snapshots: $e');
    }

    // TODO: Check if book available at stores Ozon/Amazon

    // TODO: Check if book available in libraries
  }
}

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

  List<BookSearchData> books = [];

  TextEditingController textController;

  @override
  void initState() {
    super.initState();

    //refreshLocation(context);

    textController = new TextEditingController();

    if (query != null) {
      textController.text = query;
      searchByTitleAuthor(query).then((b) {
        setState(() {
          books = b.map((x) => BookSearchData(book: x));
        });
      });
    } else if (isbn != null) {
      searchByIsbn(isbn).then((b) {
        setState(() {
          books = [BookSearchData(book: b)];
        });
      });
    } else if (id != null) {
      setState(() {
        books = [BookSearchData(bookrecordId: id)];
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  _FindBookWidgetState({this.query, this.isbn, this.id});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title: Text(S.of(context).findbookTitle,
            style: Theme.of(context).textTheme.title.apply(color: C.titleText)),
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
                                style: Theme.of(context).textTheme.title,
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
                                searchByTitleAuthor(textController.text)
                                    .then((b) {
                                  setState(() {
                                    books = List<BookSearchData>.from(
                                        b.map((x) => BookSearchData(book: x)));
                                  });
                                  logAnalyticsEvent(
                                      name: 'search',
                                      parameters: <String, dynamic>{
                                        'type': 'text',
                                        'search_term': textController.text,
                                        'results': b.length,
                                      });
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
                            style: Theme.of(context).textTheme.title),
                        RaisedButton(
                          textColor: Colors.white,
                          color: C.button,
                          child: assetIcon(barcode_scanner_100, size: 30),
                          onPressed: () {
                            scanIsbn(context, (book) {
                              setState(() {
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
                ])),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight: 180,
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          var book = books.elementAt(index);
          return StreamBuilder(
            stream: book.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              } else {
                BookSearchData data = snapshot.data;

                // Choose icon based on conditions
                Widget buttons;
                if (!data.hasRecords) {
                  // Book not found in Biblosphere (=> screen to Stores/Libs)
                  buttons = Row(children: <Widget>[
                    Tooltip(
                        // TODO: Correct text search in stores/libraries
                        message: S.of(context).findBook,
                        child: RaisedButton(
                          textColor: C.buttonText,
                          color: C.cardBackground,
                          child: Text(S.of(context).buttonSearchThirdParty,
                              style: Theme.of(context)
                                  .textTheme
                                  .body2
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
                          icon: assetIcon(heart_100, size: 30, padding: 0.0),
                          onPressed: () async {
                            if (B.user.wishCount >= await wishlistAllowance()) {
                              // TODO: Add translation & get a price for monthly plan
                              showUpgradeDialog(context, S.of(context).dialogWishLimit(await upgradePrice()));

                              logAnalyticsEvent(
                                  name: 'limit_reached',
                                  parameters: <String, dynamic>{
                                    'limit': 'wishlist',
                                    'user': B.user.id,
                                    'isbn': book.book.isbn,
                                  });
                            } else {
                              // Add book into user's wishlist
                              await addBookrecord(context, book.book, B.user,
                                  true, await currentLocation(),
                                  snackbar: true);

                              logAnalyticsEvent(
                                  name: 'book_received',
                                  parameters: <String, dynamic>{
                                    'user': B.user.id,
                                    'isbn': book.book.isbn,
                                  });
                            }
                          },
                        ))
                  ]);
                } else if (data.first.holderId == B.user.id) {
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
                                  .body2
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
                                      ShowBooksWidget(filter: data.book.isbn),
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
                                      .body2
                                      .apply(color: C.titleText)),
                              onPressed: () async {
                                if (B.user.balance <= -await booksAllowance()) {
                                  // TODO: Add translation & get a price for monthly plan
                                  showUpgradeDialog(context, S.of(context).dialogBookLimit(await upgradePrice()));

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
                                    context, data.first);

                                logAnalyticsEvent(
                                    name: 'book_received',
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
                          bookImage(data.book, 80,
                              padding: EdgeInsets.all(5.0)),
                          Expanded(
                              child: Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(data.book.authors[0],
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption),
                                        Text(data.book.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle),
                                        data.hasRecords
                                            ? Text(
                                                data.first.distance.isFinite
                                                    ? S
                                                        .of(context)
                                                        .distanceLine(distance(
                                                            data.first
                                                                .distance))
                                                    : S
                                                        .of(context)
                                                        .distanceUnknown,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1)
                                            : Container(),
                                        data.hasRecords
                                            ? Text(
                                                (data.first.holderId ==
                                                        B.user.id)
                                                    ? S
                                                        .of(context)
                                                        .youHaveThisBook
                                                    : S.of(context).bookWith(
                                                        data.first.holderName),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1)
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
            style: Theme.of(context).textTheme.title.apply(color: C.titleText)),
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
                          style: Theme.of(context).textTheme.body1)),
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
                              style: Theme.of(context).textTheme.body1),
                          new Text(libraryService,
                              style: Theme.of(context).textTheme.body1),
                          new Text('',
                              style: Theme.of(context).textTheme.body1),
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
                              style: Theme.of(context).textTheme.body1),
                          new Text(
                              widget.book.isbn.startsWith('9785')
                                  ? 'www.ozon.ru'
                                  : 'www.amazon.com',
                              style: Theme.of(context).textTheme.body1),
                          new Text('',
                              style: Theme.of(context).textTheme.body1),
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
