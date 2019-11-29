import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/search.dart';
import 'package:biblosphere/lifecycle.dart';
import 'package:biblosphere/payments.dart';
import 'package:biblosphere/chat.dart';
import 'package:biblosphere/home.dart';
import 'package:biblosphere/l10n.dart';

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
                  new Container(
                    padding: new EdgeInsets.all(10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(S.of(context).scanISBN,
                            style: Theme.of(context).textTheme.title),
                        RaisedButton(
                          textColor: C.buttonText,
                          color: C.button,
                          child: assetIcon(barcode_scanner_100, size: 30),
                          onPressed: () async {
                            String barcode = await BarcodeScanner.scan();
                            await scanIsbn(context, barcode);
                            FirebaseAnalytics().logEvent(
                                name: 'book_add_attempt',
                                parameters: <String, dynamic>{
                                  'type': 'isbn',
                                  'search_term': barcode,
                                  'results': suggestions.length,
                                  'locality': B.locality,
                                  'country': B.country,
                                  'latitude': B.position?.latitude,
                                  'longitude': B.position?.longitude
                                });
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15.0),
                              side: BorderSide(color: C.buttonBorder)),
                        ),
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
                                await searchByTitleAuthor(textController.text);
                                FirebaseAnalytics().logEvent(
                                    name: 'book_add_attempt',
                                    parameters: <String, dynamic>{
                                      'type': 'text',
                                      'search_term': textController.text,
                                      'results': suggestions.length,
                                      'locality': B.locality,
                                      'country': B.country,
                                      'latitude': B.position?.latitude,
                                      'longitude': B.position?.longitude
                                    });
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(15.0),
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
                    bookImage(book, 50, padding: 5.0),
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

  // TODO: resolve duplicate functions searchByTitleAuthor
  Future searchByTitleAuthor(String text) async {
    Map<String, Book> books = {};
    Set<String> keys = getKeys(text);

    List<Future> futures = <Future>[
      searchByTitleAuthorBiblosphere(text).then((list) {
        list.forEach((b) {
          if (books[b.isbn] == null) {
            books.addAll({b.isbn: b});
          } else {
            if (books[b.isbn].image == null) books[b.isbn].image = b.image;
            if (books[b.isbn].copies == 0) books[b.isbn].copies = b.copies;
            if (books[b.isbn].wishes == 0) books[b.isbn].wishes = b.wishes;
          }
        });
      }),
      searchByTitleAuthorGoogle(text).then((list) {
        list.where((book) => book.keys.containsAll(keys)).forEach((b) {
          if (books[b.isbn] == null) {
            books.addAll({b.isbn: b});
          } else {
            if (books[b.isbn].image == null) books[b.isbn].image = b.image;
            if (books[b.isbn].copies == 0) books[b.isbn].copies = b.copies;
            if (books[b.isbn].wishes == 0) books[b.isbn].wishes = b.wishes;
          }
        });
      }),
      searchByTitleAuthorGoodreads(text).then((list) {
        list.where((book) => book.keys.containsAll(keys)).forEach((b) {
          if (books[b.isbn] == null) {
            books.addAll({b.isbn: b});
          } else {
            if (books[b.isbn].image == null) books[b.isbn].image = b.image;
            if (books[b.isbn].copies == 0) books[b.isbn].copies = b.copies;
            if (books[b.isbn].wishes == 0) books[b.isbn].wishes = b.wishes;
          }
        });
      })
    ];

    await Future.wait(futures);

    setState(() {
      suggestions = books.values.toList();
    });
  }

  Future scanIsbn(BuildContext context, String barcode) async {
    try {
      Book book = await searchByIsbn(barcode);

      if (book == null) {
        book = await searchByIsbnGoodreads(barcode);
      }

      if (book == null) {
        if (barcode.startsWith('9785'))
          book = await searchByIsbnRsl(barcode);
        else
          book = await searchByIsbnGoogle(barcode);
      }

      if (book != null) {
        //Many books on goodreads does not have images. Enreach it from Google
        //book = await enrichBookRecord(book);
        setState(() {
          suggestions = <Book>[book];
        });
      } else {
        Firestore.instance.collection('noisbn').document(barcode).setData({
          'count': FieldValue.increment(1),
          'requested_by': FieldValue.arrayUnion([B.user.id])
        }, merge: true);
        //print("No record found for isbn: $barcode");
        showSnackBar(context, S.of(context).isbnNotFound);
        FirebaseAnalytics()
            .logEvent(name: 'book_noisbn', parameters: <String, dynamic>{
          'isbn': barcode,
          'locality': B.locality,
          'country': B.country,
          'latitude': B.position?.latitude,
          'longitude': B.position?.longitude
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
  }
}

class FindBookWidget extends StatefulWidget {
  FindBookWidget({Key key, this.filter}) : super(key: key);

  final String filter;

  @override
  _FindBookWidgetState createState() =>
      new _FindBookWidgetState(filter: filter);
}

class _FindBookWidgetState extends State<FindBookWidget> {
  String filter;
  Map<String, dynamic> books = {};

  TextEditingController textController;

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

    if (filter != null) {
      textController.text = filter;
      searchByTitleAuthor(textController.text);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  _FindBookWidgetState({this.filter});

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
                                await searchByTitleAuthor(textController.text);
                                final List<dynamic> biblos = books.values
                                    .where((t) => t is Bookrecord)
                                    .toList();
                                FirebaseAnalytics().logEvent(
                                    name: 'search',
                                    parameters: <String, dynamic>{
                                      'type': 'text',
                                      'search_term': textController.text,
                                      'results': books.length,
                                      'in_biblosphere': biblos.length,
                                      'locality': B.locality,
                                      'country': B.country,
                                      'latitude': B.position?.latitude,
                                      'longitude': B.position?.longitude
                                    });

                                if (biblos.length > 0)
                                  FirebaseAnalytics().logEvent(
                                      name: 'book_found',
                                      parameters: <String, dynamic>{
                                        'type': 'text',
                                        'search_term': textController.text,
                                        'isbn':
                                            (biblos.first as Bookrecord).isbn,
                                        'results': books.length,
                                        'in_biblosphere': biblos.length,
                                        'distance': (biblos.first as Bookrecord)
                                            .distance,
                                        'locality': B.locality,
                                        'country': B.country,
                                        'latitude': B.position?.latitude,
                                        'longitude': B.position?.longitude
                                      });
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
                          onPressed: () async {
                            String barcode = await BarcodeScanner.scan();
                            await scanIsbn(context, barcode);
                            final List<dynamic> biblos = books.values
                                .where((t) => t is Bookrecord)
                                .toList();
                            FirebaseAnalytics().logEvent(
                                name: 'search',
                                parameters: <String, dynamic>{
                                  'type': 'isbn',
                                  'search_term': barcode,
                                  'results': books.length,
                                  'in_biblosphere': biblos.length,
                                  'locality': B.locality,
                                  'country': B.country,
                                  'latitude': B.position?.latitude,
                                  'longitude': B.position?.longitude
                                });

                            if (biblos.length > 0)
                              FirebaseAnalytics().logEvent(
                                  name: 'book_found',
                                  parameters: <String, dynamic>{
                                    'type': 'isbn',
                                    'search_term': barcode,
                                    'isbn': (biblos.first as Bookrecord).isbn,
                                    'results': books.length,
                                    'in_biblosphere': biblos.length,
                                    'distance':
                                        (biblos.first as Bookrecord).distance,
                                    'locality': B.locality,
                                    'country': B.country,
                                    'latitude': B.position?.latitude,
                                    'longitude': B.position?.longitude
                                  });
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
          var book = books.values.elementAt(index);
          if (book is Book) {
            return GestureDetector(
                    onTap: () async {
                      FirebaseAnalytics().logEvent(
                          name: 'search_elsewhere',
                          parameters: <String, dynamic>{
                            'user': B.user.id,
                            'isbn': book.isbn,
                            'locality': B.locality,
                            'country': B.country,
                            'latitude': B.position?.latitude,
                            'longitude': B.position?.longitude
                          });

                      //book = await enrichBookRecord(book);
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => buildScaffold(
                                  context, null, new GetBookWidget(book: book),
                                  appbar: false)));
                    },
                    child: Container(
                      color: C.cardBackground,
                margin: EdgeInsets.all(3.0),
                child: Row(children: <Widget>[
                      bookImage(book, 60, padding: 5.0),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(book.authors[0],
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            Theme.of(context)
                                                .textTheme
                                                .caption),
                                    Text(book.title,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            Theme.of(context)
                                                .textTheme
                                                .subtitle),
                                  ]))),
                      Container(child: assetIcon(search_100, size: 40, padding: 5.0))
                    ])));
          } else if (book is Bookrecord) {
            Bookrecord rec = book;
            return GestureDetector(
                    onTap: () async {
                      if (rec.holderId == B.user.id) {
                        // For user own books open in My Book screen
                        Navigator.pop(context);

                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => buildScaffold(context,
                                    null, ShowBooksWidget(filter: rec.isbn),
                                    appbar: false)));
                      } else {
                        // For other users books open chat and transit
                        Messages chat =
                            new Messages(from: rec.holder, to: B.user);

                        // Open chat widget
                        Chat.runChat(context, null,
                            chat: chat,
                            transit: rec.id,
                            message: S.of(context).requestBook(rec.title));
                      }
                    },
                    child: Container(
                      color: C.cardBackground,
                margin: EdgeInsets.all(3.0),
                child: Row(children: <Widget>[
                      bookImage(rec, 60, padding: 5.0),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(rec.authors[0],
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            Theme.of(context)
                                                .textTheme
                                                .caption),
                                    Text(rec.title,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            Theme.of(context)
                                                .textTheme
                                                .subtitle),
                                    Text(rec.distance.isFinite ?
                                        S.of(context).distanceLine(distance(rec.distance)) :
                                        S.of(context).distanceUnknown,
                                        style:
                                            Theme.of(context).textTheme.body1),
                                    B.user.id != rec.ownerId && !rec.wish ? Text(
                                            S.of(context).bookRent(money(monthly(
                                                    rec.getPrice()))),
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body1) : Container(),
                                    Text(
                                        (rec.holderId == B.user.id)
                                            ? S.of(context).youHaveThisBook
                                            : S
                                                .of(context)
                                                .bookWith(rec.holderName),
                                        style:
                                            Theme.of(context).textTheme.body1)
                                  ]))),
                      Container(
                          child: (rec.holderId == B.user.id)
                              ? assetIcon(books_100, size: 40, padding: 5.0)
                              : assetIcon(shopping_cart_100, size: 40, padding: 5.0))
                    ])));
          }
          return Container();
        }, childCount: books != null ? books.values.length : 0),
      )
    ]);
  }

  int compare(dynamic b1, dynamic b2) {
    if (b1 is Bookrecord && b2 is Bookrecord)
      return b1.distance.compareTo(b2.distance);
    else if (b1 is Bookrecord && b2 is Book)
      return -1;
    else if (b1 is Book && b2 is Bookrecord)
      return 1;
    else if (b1 is Book && b2 is Book)
      return b1.title.compareTo(b2.title);
    else
      return 0;
  }

  Map<String, dynamic> mergeBooks(books, list) {
    list.forEach((b) {
      if (books[b.isbn] == null) {
        books.addAll(<String, dynamic>{b.isbn: b});
      } else {
        if (books[b.isbn] is Book && b is Bookrecord ||
            books[b.isbn] is Bookrecord &&
                b is Bookrecord &&
                b.distance < books[b.isbn].distance) {
          books[b.isbn] = b;
        } else if (books[b.isbn] is Book) {
          if (books[b.isbn].image == null) books[b.isbn].image = b.image;
          if (books[b.isbn].copies == 0) books[b.isbn].copies = b.copies;
          if (books[b.isbn].wishes == 0) books[b.isbn].wishes = b.wishes;
        } else if (books[b.isbn] is Bookrecord) {
          if (books[b.isbn].image == null) books[b.isbn].image = b.image;
        }
      }
    });

    var sortedKeys = books.keys.toList(growable: false)
      ..sort((k1, k2) => compare(books[k1], books[k2]));

    LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => books[k]);

    return sortedMap.cast<String, dynamic>();
  }

  Future searchByTitleAuthor(String text) async {
    Set<String> keys = getKeys(text);
    books = <String, dynamic>{};

    List<Future> futures = <Future>[
      // Search in Bookrecords
      searchByTitleAuthorBiblosphere(text, actual: true).then((list) {
        books = mergeBooks(books, list);
        setState(() {});
      }),

      // Search in Books
      searchByTitleAuthorBiblosphere(text).then((list) {
        books = mergeBooks(books, list);
        setState(() {});
      }),

      searchByTitleAuthorGoogle(text).then((list) {
        list = list.where((book) => book.keys.containsAll(keys)).toList();
        books = mergeBooks(books, list);
        setState(() {});
      }),

      searchByTitleAuthorGoodreads(text).then((list) {
        list = list.where((book) => book.keys.containsAll(keys)).toList();
        books = mergeBooks(books, list);
        setState(() {});
      }),
    ];

    await Future.wait(futures);
  }

  //TODO: Same code reuse function with AddBookWidget
  Future scanIsbn(BuildContext context, String barcode) async {
    try {
      books = <String, dynamic>{};

      // TODO: Avoid unnecessary search if book found in Biblosphere

      List<Future> futures = <Future>[
        // Search in Bookrecords
        searchByIsbnBookrecords(barcode).then((list) {
          books = mergeBooks(books, list);
          setState(() {});
        }),

        // Search in Books
        searchByIsbn(barcode).then((list) {
          books = mergeBooks(books, [list]);
          setState(() {});
        }),

        searchByIsbnGoodreads(barcode).then((list) {
          books = mergeBooks(books, [list]);
          setState(() {});
        }),

        barcode.startsWith('9785')
            ? searchByIsbnRsl(barcode).then((list) {
                books = mergeBooks(books, [list]);
                setState(() {});
              })
            : searchByIsbnGoogle(barcode).then((list) {
                books = mergeBooks(books, [list]);
                setState(() {});
              }),
      ];

      await Future.wait(futures);

      if (books.values.length == 0) {
        Firestore.instance.collection('noisbn').add({'isbn': barcode});
        //print("No record found for isbn: $barcode");
        showSnackBar(context, S.of(context).isbnNotFound);
      }
    } on PlatformException catch (e, stack) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        FlutterCrashlytics().logException(e, stack);
        print('The user did not grant the camera permission!');
      } else {
        FlutterCrashlytics().logException(e, stack);
        print('Unknown platform error in scanIsbn: $e');
      }
    } on FormatException {
      print(
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e, stack) {
      FlutterCrashlytics().logException(e, stack);
      print('Unknown error in scanIsbn: $e');
    }
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
            bookImage(widget.book, 50.0, padding: 10.0),
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
                  FirebaseAnalytics().logEvent(
                      name: 'library_click',
                      parameters: <String, dynamic>{
                        'isbn': widget.book.isbn,
                        'user': B.user.id,
                        'library': libraryQuery,
                        'locality': B.locality,
                        'country': B.country,
                        'latitude': B.position?.latitude,
                        'longitude': B.position?.longitude
                      });

                  if (await canLaunch(libraryQuery)) {
                    await launch(libraryQuery);
                  }
                },
                child: new Card(
                  child: Row(children: <Widget>[
                    bookImage(widget.book, 50.0,
                        padding:
                            10.0), //child: new Icon(MyIcons.library, size: 50)),
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

                  FirebaseAnalytics().logEvent(
                      name: 'bookstore_click',
                      parameters: <String, dynamic>{
                        'isbn': widget.book.isbn,
                        'user': B.user.id,
                        'store': bookstore,
                        'locality': B.locality,
                        'country': B.country,
                        'latitude': B.position?.latitude,
                        'longitude': B.position?.longitude
                      });

                  var encoded = Uri.encodeFull(url);
                  if (await canLaunch(encoded)) {
                    await launch(encoded);
                  }
                },
                child: new Card(
                  child: Row(children: <Widget>[
                    bookImage(widget.book, 50.0, padding: 10.0),
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
