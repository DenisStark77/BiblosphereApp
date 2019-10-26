import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/search.dart';
import 'package:biblosphere/lifecycle.dart';
import 'package:biblosphere/chat.dart';
import 'package:biblosphere/l10n.dart';

class AddBookWidget extends StatefulWidget {
  AddBookWidget({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  final User currentUser;

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
    return new Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Card(
            child: Column(children: <Widget>[
              new Container(
                padding: new EdgeInsets.all(10.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(S.of(context).scanISBN,
                        style: Theme.of(context).textTheme.title),
                    RaisedButton(
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.secondary,
                      child: new Icon(MyIcons.barcode, size: 30),
                      onPressed: () {
                        scanIsbn(context);
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
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
                                hintText: S.of(context).hintAuthorTitle),
                          )),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 20.0),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Theme.of(context).colorScheme.secondary,
                          child: new Icon(MyIcons.search, size: 30),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            searchByTitleAuthor(textController.text);
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                        )),
                  ],
                ),
              ),
            ]),
          ),
          new Expanded(
              child: ListView(
                  children: suggestions != null
                      ? suggestions.map((Book book) {
                          return Container(
                              margin: EdgeInsets.all(3.0),
                              child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      suggestions.clear();
                                    });
                                    book = await enrichBookRecord(book);
                                    addBookrecord(
                                        context,
                                        book,
                                        widget.currentUser,
                                        false,
                                        await currentLocation(),
                                        source: 'googlebooks');
                                    //showSnackBar(context, S.of(context).bookAdded);
                                  },
                                  child: Row(children: <Widget>[
                                    bookImage(book, 50, padding: 5.0),
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
                                                          .body1),
                                                  Text('\"${book.title}\"',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .body1)
                                                ])))
                                  ])));
                        }).toList()
                      : Container()))
        ],
      ),
    );
  }

  // TODO: resolve duplicate functions searchByTitleAuthor
  Future searchByTitleAuthor(String text) async {
    Set<Book> books = {};
    Set<String> keys = getKeys(text);

    List<Future> futures = <Future>[
      searchByTitleAuthorBiblosphere(text).then((list) {
        books.addAll(list);
      }),
      searchByTitleAuthorGoogle(text).then((list) {
        books.addAll(list.where((book) => book.keys.containsAll(keys)));
      }),
      searchByTitleAuthorGoodreads(text).then((list) {
        books.addAll(list.where((book) => book.keys.containsAll(keys)));
      })
    ];

    await Future.wait(futures);

    setState(() {
      suggestions = books.toList();
    });
  }

  Future scanIsbn(BuildContext context) async {
    try {
      String barcode = await BarcodeScanner.scan();

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
        book = await enrichBookRecord(book);
        setState(() {
          suggestions = <Book>[book];
        });
      } else {
        Firestore.instance.collection('noisbn').add({'isbn': barcode});
        //print("No record found for isbn: $barcode");
        showSnackBar(context, S.of(context).isbnNotFound);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        //TODO: Inform user
        print('The user did not grant the camera permission!');
      } else {
        print('Unknown platform error in scanIsbn: $e');
      }
    } on FormatException {
      print(
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      print('Unknown error in scanIsbn: $e');
    }
  }
}

class FindBookWidget extends StatefulWidget {
  FindBookWidget({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _FindBookWidgetState createState() => new _FindBookWidgetState();
}

class _FindBookWidgetState extends State<FindBookWidget> {
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

  _FindBookWidgetState();

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Card(
            child: Column(children: <Widget>[
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
                                hintText: S.of(context).hintAuthorTitle),
                          )),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 20.0),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Theme.of(context).colorScheme.secondary,
                          child: new Icon(MyIcons.search, size: 30),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            searchByTitleAuthor(textController.text);
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
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
                      color: Theme.of(context).colorScheme.secondary,
                      child: new Icon(MyIcons.barcode, size: 30),
                      onPressed: () {
                        scanIsbn(context);
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          new Expanded(
              child: Scrollbar(
                  child: ListView(
                      children: suggestions != null
                          ? suggestions.map((Book book) {
                              return Container(
                                  margin: EdgeInsets.all(3.0),
                                  child: GestureDetector(
                                      onTap: () async {
                                        book = await enrichBookRecord(book);
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                //TODO: translation
                                                builder: (context) =>
                                                    buildScaffold(
                                                        context,
                                                        S.of(context).titleGetBook,
                                                        new GetBookWidget(
                                                            currentUser: widget
                                                                .currentUser,
                                                            book: book))));
                                      },
                                      child: Row(children: <Widget>[
                                        bookImage(book, 50, padding: 5.0),
                                        Expanded(
                                            child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 10.0),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text('${book.authors[0]}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .body1),
                                                      Text('\"${book.title}\"',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .body1)
                                                    ])))
                                      ])));
                            }).toList()
                          : Container())))
        ],
      ),
    );
  }

  Future searchByTitleAuthor(String text) async {
    Set<Book> books = {};
    Set<String> keys = getKeys(text);

    List<Future> futures = <Future>[
      searchByTitleAuthorBiblosphere(text).then((list) {
        books.addAll(list);
      }),
      searchByTitleAuthorGoogle(text).then((list) {
        books.addAll(list.where((book) => book.keys.containsAll(keys)));
      }),
      searchByTitleAuthorGoodreads(text).then((list) {
        books.addAll(list.where((book) => book.keys.containsAll(keys)));
      })
    ];

    await Future.wait(futures);

    setState(() {
      suggestions = books.toList();
    });
  }

  //TODO: Same code reuse function with AddBookWidget
  Future scanIsbn(BuildContext context) async {
    try {
      String barcode = await BarcodeScanner.scan();

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
        book = await enrichBookRecord(book);
        setState(() {
          suggestions = <Book>[book];
        });
      } else {
        Firestore.instance.collection('noisbn').add({'isbn': barcode});
        //print("No record found for isbn: $barcode");
        showSnackBar(context, S.of(context).isbnNotFound);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        print('The user did not grant the camera permission!');
      } else {
        print('Unknown platform error in scanIsbn: $e');
      }
    } on FormatException {
      print(
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      print('Unknown error in scanIsbn: $e');
    }
  }
}

class GetBookWidget extends StatefulWidget {
  GetBookWidget({
    Key key,
    @required this.currentUser,
    @required this.book,
  }) : super(key: key);

  final User currentUser;
  final Book book;

  @override
  _GetBookWidgetState createState() => new _GetBookWidgetState();
}

class _GetBookWidgetState extends State<GetBookWidget> {
  //List<Book> suggestions = [];
  Bookrecord bookrecord;
  bool inMyBooks = false;
  bool inMyWishes = false;
  bool inNeigbourhood = false;
  bool inBiblosphere = false;
  bool inLibraries = false;
  bool inBookstores = true;
  String libraryService;
  String libraryQuery;

  @override
  void initState() {
    super.initState();
    searchBiblosphere();
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
    return new Container(
      child: ListView(
//        mainAxisSize: MainAxisSize.min,
//        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // If book available near
          inMyWishes
              ? new Card(
            child: Row(children: <Widget>[
              bookImage(widget.book, 50.0, padding: 10.0),
              //new Icon(MyIcons.home, size: 50)),
              new Container(
                padding: new EdgeInsets.all(10.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(S.of(context).inMyWishes,
                        style: Theme.of(context).textTheme.subtitle),
                  ],
                ),
              ),
            ]),
          )
              : Container(),
          inMyBooks
              ? new Card(
                  child: Row(children: <Widget>[
                    bookImage(widget.book, 50.0, padding: 10.0),
                    //new Icon(MyIcons.home, size: 50)),
                    new Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(S.of(context).inMyBooks,
                              style: Theme.of(context).textTheme.subtitle),
                        ],
                      ),
                    ),
                  ]),
                )
              : Container(),
          inNeigbourhood
              ? new GestureDetector(
                  onTap: () async {
                    await Firestore.instance
                        .collection('bookrecords')
                        .document(bookrecord.id)
                        .updateData({
                      'transit': true,
                      'transitId': widget.currentUser.id,
                      'users': [
                        bookrecord.ownerId,
                        bookrecord.holderId,
                        widget.currentUser.id
                      ]
                    });
                    Chat.runChat(context, widget.currentUser, bookrecord.holder,
                        message: S.of(context).requestBook(widget.book.title));
                  },
                  child: Card(
                    child: Row(children: <Widget>[
                      bookImage(widget.book, 50.0, padding: 10.0),
                      //new Icon(MyIcons.face, size: 50)),
                      new Container(
                        padding: new EdgeInsets.all(10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(S.of(context).bookAround,
                                style: Theme.of(context).textTheme.body1),
                            new Text(S.of(context).userHave(bookrecord.holder.name),
                                style: Theme.of(context).textTheme.body1),
                            new Text(
                                S.of(context).distanceLine(bookrecord.distance.round()),
                                style: Theme.of(context).textTheme.body1),
                          ],
                        ),
                      ),
                    ]),
                  ))
              : Container(),
          inBiblosphere
              ? new GestureDetector(
                  onTap: () async {
                    await Firestore.instance
                        .collection('bookrecords')
                        .document(bookrecord.id)
                        .updateData({
                      'transit': true,
                      'transitId': widget.currentUser.id,
                      'users': [
                        bookrecord.ownerId,
                        bookrecord.holderId,
                        widget.currentUser.id
                      ]
                    });
                    Chat.runChat(context, widget.currentUser, bookrecord.holder,
                        message: S.of(context).requestPost(widget.book.title));
                  },
                  child: Card(
                    child: Row(children: <Widget>[
                      bookImage(widget.book, 50.0, padding: 10.0),
                      //child: new Icon(MyIcons.envelop, size: 50)),
                      new Container(
                        padding: new EdgeInsets.all(10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(S.of(context).bookByPost,
                                style: Theme.of(context).textTheme.body1),
                            new Text(
                                S.of(context).userHave(bookrecord.holder.name),
                                style: Theme.of(context).textTheme.body1),
                            new Text(S.of(context).distanceLine(bookrecord.distance.round()),
                                style: Theme.of(context).textTheme.body1),
                          ],
                        ),
                      ),
                    ]),
                  ))
              : Container(),
          inLibraries
              ? new GestureDetector(
                  onTap: () async {
                    if (await canLaunch(libraryQuery)) {
                      await launch(libraryQuery);
                    }
                  },
                  child: new Card(
                    child: Row(children: <Widget>[
                      bookImage(widget.book, 50.0,
                          padding:
                              10.0), //child: new Icon(MyIcons.library, size: 50)),
                      new Container(
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
                      ),
                    ]),
                  ))
              : Container(),
          inBookstores
              ? new GestureDetector(
                  onTap: () async {
                    String url;
                    if (widget.book.isbn.startsWith('9785')) {
                      url =
                          'https://www.ozon.ru/category/knigi-16500/?text=${widget.book.title + ' ' + widget.book.authors.join(' ')}';
                    } else {
                      url =
                          'https://www.amazon.com/s?k=${widget.book.title + ' ' + widget.book.authors.join(' ')}';
                    }

                    var encoded = Uri.encodeFull(url);
                    if (await canLaunch(encoded)) {
                      await launch(encoded);
                    }
                  },
                  child: new Card(
                    child: Row(children: <Widget>[
                      bookImage(widget.book, 50.0, padding: 10.0),
                      new Container(
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
                      ),
                    ]),
                  ))
              : Container(),
          new Card(
              child: GestureDetector(
            onTap: () async {
              setState(() {
                print('s');
              });
              addBookrecord(context, widget.book, widget.currentUser, true,
                  await currentLocation(),
                  source: 'googlebooks');
              //showSnackBar(context, S.of(context).bookAdded);
            },
            child: Row(children: <Widget>[
              bookImage(widget.book, 50.0, padding: 10.0),
              new Container(
                padding: new EdgeInsets.all(10.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(S.of(context).ifNotFound,
                        style: Theme.of(context).textTheme.body1),
                    new Text(S.of(context).addToWishlist,
                        style: Theme.of(context).textTheme.body1),
                  ],
                ),
              ),
            ]),
          )),
        ],
      ),
    );
  }

  Future<void> searchBiblosphere() async {
    // Create a geoFirePoint
    GeoFirePoint center = await currentLocation();

// get the collection reference or query
    var collectionReference = Firestore.instance
        .collection('bookrecords')
        .where("bookId", isEqualTo: widget.book.id);

    Stream<List<DocumentSnapshot>> stream = Geoflutterfire()
        .collection(collectionRef: collectionReference)
        .within(
            center: center, radius: 100.0, field: 'location', strictMode: true);

    List<DocumentSnapshot> l = await stream.first;
    l.forEach((doc) {
      print('!!!DEBUG ${doc.data}');
    });

    if (l.length > 0) {
      print('!!!DEBUG ${l.length} books found');
      // There are books found
      List<Bookrecord> records = l.map((snap) {
        return new Bookrecord.fromJson(snap.data);
      }).toList();
      records.sort((a, b) {
        return (a.distance - b.distance).round();
      });
      if (records.first.ownerId == widget.currentUser.id ||
          records.first.holderId == widget.currentUser.id) {
        print(
            '!!!DEBUG in my book 1 ${records.first.bookId} ${records.first.ownerId} ${records.first.holderId}');
        // Book belong to me. Show widget that it's in my library
        setState(() {
          inMyBooks = true;
        });
      } else {
        // Book available from neighbours
        bookrecord = records.first;
        await bookrecord.getBookrecord(widget.currentUser);
        setState(() {
          inNeigbourhood = true;
        });
      }
    } else {
      // Books are not found in neighbourhood. Search without distance filter
      QuerySnapshot docs = await collectionReference.limit(10).getDocuments();
      if (docs.documents.length > 0) {
        List<Bookrecord> records = docs.documents.map((snap) {
          return new Bookrecord.fromJson(snap.data);
        }).toList();
        records.sort((a, b) {
          a.distance = distanceBetween(
              widget.currentUser.position.latitude,
              widget.currentUser.position.longitude,
              a.location.latitude,
              a.location.longitude);
          b.distance = distanceBetween(
              widget.currentUser.position.latitude,
              widget.currentUser.position.longitude,
              b.location.latitude,
              b.location.longitude);
          return (a.distance - b.distance).round();
        });
        if (records.first.ownerId == widget.currentUser.id ||
            records.first.holderId == widget.currentUser.id) {
          // Book belong to me. Show widget that it's in my library
          print(
              '!!!DEBUG in my book 2 ${records.first.bookId} ${records.first.ownerId} ${records.first.holderId}');
          setState(() {
            inMyBooks = true;
          });
        } else {
          // Book available by post
          bookrecord = records.first;
          await bookrecord.getBookrecord(widget.currentUser);
          setState(() {
            inBiblosphere = true;
          });
        }
      }
    }
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
/*
    List<Placemark> placemarks = await Geolocator().placemarkFromPosition(
        await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high));
*/
    // Sankt-Peterburg  (59.9343, 30.3351, localeIdentifier: 'en')
    // Ekaterinburg  (56.8389, 60.6057, localeIdentifier: 'en')
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(59.9343, 30.3351, localeIdentifier: 'en');


    String country, area;

    placemarks.forEach((p) {
      print(
          '!!!DEBUG location ${p.isoCountryCode}, ${p.administrativeArea} ${p.subAdministrativeArea}, ${p.locality}');
      if (p.isoCountryCode != null) country = p.isoCountryCode;
      if (p.administrativeArea != null) area = p.subAdministrativeArea;
      if (area == null || area.isEmpty) area = p.administrativeArea;
    });

    List<Provider> providers = libraryServers
        .where((p) => p.country == country && p.area == area)
        .toList();
    Provider provider;

    if (providers != null && providers.isNotEmpty) {
      provider = providers.first;
    } else {
      provider = libraryServers.firstWhere((p) => p.country == 'ALL');
    }

    if (provider != null) {
      String query = provider.query;
      query = query.replaceAll(r'%TITLE%', book.title);
      query = query.replaceAll(r'%AUTHOR%', book.authors.join(' '));
      String encoded = Uri.encodeFull(query);
      print('!!!DEBUG URL  ${encoded}');
      return {provider.name: encoded};
    }
    return null;
  }

  Future<void> searchBookstores() async {}
}
