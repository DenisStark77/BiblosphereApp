import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:share/share.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

import 'package:biblosphere/const.dart';
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
                    new Text('Сканировать ISBN',
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
                                hintText: 'Автор или название'),
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
                  children: suggestions?.map((Book book) {
            return Container(
                margin: EdgeInsets.all(3.0),
                child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        suggestions.clear();
                      });
                      book = await enrichBookRecord(book);
                      addBookrecord(context, book, widget.currentUser, false,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${book.authors[0]}',
                                        style:
                                            Theme.of(context).textTheme.body1),
                                    Text('\"${book.title}\"',
                                        style:
                                            Theme.of(context).textTheme.body1)
                                  ])))
                    ])));
          }).toList()))
        ],
      ),
    );
  }

  Future searchByTitleAuthor(String text) async {
    List<Book> books = await searchByTitleAuthorBiblosphere(text);
    //List<Book> books = await searchByTitleAuthorGoogle(text);
    setState(() {
      suggestions = books;
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
                                hintText: 'Автор или название'),
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
                    new Text('Сканировать ISBN',
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
                      children: suggestions?.map((Book book) {
            return Container(
                margin: EdgeInsets.all(3.0),
                child: GestureDetector(
                    onTap: () async {
                      book = await enrichBookRecord(book);
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              //TODO: translation
                              builder: (context) => buildScaffold(
                                  context,
                                  "ПОЛУЧИ КНИГУ",
                                  new GetBookWidget(
                                      currentUser: widget.currentUser,
                                      book: book))));
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
                                        style:
                                            Theme.of(context).textTheme.body1),
                                    Text('\"${book.title}\"',
                                        style:
                                            Theme.of(context).textTheme.body1)
                                  ])))
                    ])));
          }).toList())))
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
  bool inNeigbourhood = false;
  bool inBiblosphere = false;
  bool inLibraries = true;
  bool inBookstores = true;

  @override
  void initState() {
    super.initState();
    searchBiblosphere();
    searchLibraries();
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
                          new Text('Эта книга есть у вас',
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
                      'users': [bookrecord.ownerId, bookrecord.holderId, widget.currentUser.id]
                    });
                    Chat.runChat(
                        context, widget.currentUser, bookrecord.holder, message: 'Можно взять у вас \"${widget.book.title}\"?');
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
                            new Text('Книга поблизости',
                                style: Theme.of(context).textTheme.body1),
                            new Text('У пользователя ${bookrecord.holder.name}',
                                style: Theme.of(context).textTheme.body1),
                            new Text(
                                'Расстояние: ${bookrecord.distance.round()} км',
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
                      'users': [bookrecord.ownerId, bookrecord.holderId, widget.currentUser.id]
                    });
                    Chat.runChat(
                        context, widget.currentUser, bookrecord.holder, message: 'Можно взять у вас \"${widget.book.title}\"?');
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
                            new Text('Получи по почте',
                                style: Theme.of(context).textTheme.body1),
                            new Text(
                                'от пользователя ${bookrecord.holder.name}',
                                style: Theme.of(context).textTheme.body1),
                            new Text(
                                'Расстояние: ${bookrecord.distance.round()} км',
                                style: Theme.of(context).textTheme.body1),
                          ],
                        ),
                      ),
                    ]),
                  ))
              : Container(),
          inLibraries
              ? new Card(
                  child: Row(children: <Widget>[
                    bookImage(widget.book, 50.0, padding: 10.0),                    //child: new Icon(MyIcons.library, size: 50)),
                    new Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text('Возьми в библиотеке',
                              style: Theme.of(context).textTheme.body1),
                          new Text('Пушкинская библиотека',
                              style: Theme.of(context).textTheme.body1),
                          new Text('Расстояние: 12 км',
                              style: Theme.of(context).textTheme.body1),
                        ],
                      ),
                    ),
                  ]),
                )
              : Container(),
          inBookstores
              ? new Card(
                  child: Row(children: <Widget>[
                    bookImage(widget.book, 50.0, padding: 10.0),
                    new Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text('Купи Online',
                              style: Theme.of(context).textTheme.body1),
                          new Text('на www.amazon.com',
                              style: Theme.of(context).textTheme.body1),
                          new Text('Цена: \$22',
                              style: Theme.of(context).textTheme.body1),
                        ],
                      ),
                    ),
                  ]),
                )
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
                    new Text('Если вы не нашли книгу вы можете:',
                        style: Theme.of(context).textTheme.body1),
                    new Text('Добавить её в wishlist',
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
    if (l.length > 0) {
      // There are books found
      List<Bookrecord> records = l.map((snap) {
        return new Bookrecord.fromJson(snap.data);
      }).toList();
      records.sort((a, b) {
        return (a.distance - b.distance).round();
      });
      if (records.first.ownerId == widget.currentUser.id ||
          records.first.holderId == widget.currentUser.id) {
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

  Future<void> searchLibraries() async {}
  Future<void> searchBookstores() async {}
}


// Class to show my books (own, wishlist and borrowed/lent)
class ShowBooksWidget extends StatefulWidget {
  ShowBooksWidget({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  final User currentUser;
  bool transit = true, own = true, lent = true, borrowed = true, wish = true;

  @override
  _ShowBooksWidgetState createState() => new _ShowBooksWidgetState();
}

class _ShowBooksWidgetState extends State<ShowBooksWidget> {
  Set<String> keys = {};
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

  _ShowBooksWidgetState();

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                new Container(
                  padding: new EdgeInsets.all(5.0),
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
                                  hintText: 'Автор или название'),
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
                              setState(() {
                                keys = getKeys(textController.text);
                              });
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0)),
                          )),
                    ],
                  ),
                ),
                new Container(
                    padding: new EdgeInsets.all(0.0),
                    child: new Wrap(spacing: 2.0, children: <Widget>[
                      FilterChip(
                        //avatar: icon,
                        label: Text('Мои книги',
                            style: Theme.of(context).textTheme.body1),
                        selected: widget.own,
                        onSelected: (bool s) {
                          setState(() {
                            widget.own = s;
                          });
                        },
                      ),
                      FilterChip(
                        //avatar: icon,
                        label: Text('Отданные',
                            style: Theme.of(context).textTheme.body1),
                        selected: widget.lent,
                        onSelected: (bool s) {
                          setState(() {
                            widget.lent = s;
                          });
                        },
                      ),
                      FilterChip(
                        //avatar: icon,
                        label: Text('Взятые',
                            style: Theme.of(context).textTheme.body1),
                        selected: widget.borrowed,
                        onSelected: (bool s) {
                          setState(() {
                            widget.borrowed = s;
                          });
                        },
                      ),
                      FilterChip(
                        //avatar: icon,
                        label: Text('Хочу',
                            style: Theme.of(context).textTheme.body1),
                        selected: widget.wish,
                        onSelected: (bool s) {
                          setState(() {
                            widget.wish = s;
                          });
                        },
                      ),
                      FilterChip(
                        //avatar: icon,
                        label: Text('Транзит',
                            style: Theme.of(context).textTheme.body1),
                        selected: widget.transit,
                        onSelected: (bool s) {
                          setState(() {
                            widget.transit = s;
                          });
                        },
                      ),
                    ]))
              ])),
          new Expanded(
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('bookrecords')
                      .where("users", arrayContains: widget.currentUser.id)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Text(S.of(context).loading);
                      default:
                        if (!snapshot.hasData ||
                            snapshot.data.documents.isEmpty) {
                          return Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'No books',
                                style: Theme.of(context).textTheme.body1,
                              ));
                        }
                        return new ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            Bookrecord rec =
                                new Bookrecord.fromJson(document.data);
                            if (widget.own && rec.isOwn(widget.currentUser.id))
                              return new MyBook(
                                  bookrecord: rec,
                                  currentUser: widget.currentUser,
                              filter: keys);
                            else if (widget.wish &&
                                rec.isWish(widget.currentUser.id))
                              //TODO: Change to MyWish
                              return new MyBook(
                                  bookrecord: rec,
                                  currentUser: widget.currentUser,
                                  filter: keys);
                            else if (widget.lent &&
                                rec.isLent(widget.currentUser.id))
                              //TODO: Change to MyLent
                              return new MyBook(
                                  bookrecord: rec,
                                  currentUser: widget.currentUser,
                                  filter: keys);
                            else if (widget.borrowed &&
                                rec.isBorrowed(widget.currentUser.id))
                              //TODO: Change to MyBorrowed
                              return new MyBook(
                                  bookrecord: rec,
                                  currentUser: widget.currentUser,
                                  filter: keys);
                            else if (widget.transit &&
                                rec.isTransit(widget.currentUser.id))
                              //TODO: Change to MyTransit
                              return new MyBook(
                                  bookrecord: rec,
                                  currentUser: widget.currentUser,
                                  filter: keys);
                            else
                              return Container();
                          }).toList(),
                        );
                    }
                  })),
        ],
      ),
    );
  }
}

class MyBook extends StatefulWidget {
  MyBook({
    Key key,
    @required this.bookrecord,
    @required this.currentUser,
    this.filter
  }) : super(key: key);

  Bookrecord bookrecord;
  final User currentUser;
  Set<String> filter = {};

  @override
  _MyBookWidgetState createState() => new _MyBookWidgetState();
}

class _MyBookWidgetState extends State<MyBook> {
  @override
  void initState() {
    super.initState();
    widget.bookrecord.getBookrecord(widget.currentUser).whenComplete(() {
      setState(() {});
    });
  }

  _MyBookWidgetState();

  Future<void> deleteBook(BuildContext context) async {
    try {
      //Delete bookshelf record in Firestore database
      DocumentReference doc = Firestore.instance
          .collection('bookcopies')
          .document("${widget.bookrecord.id}");
      await doc.delete();
      showSnackBar(context, S.of(context).bookDeleted);
    } catch (ex, stack) {
      print(
          'Bookcopy delete failed for [${widget.bookrecord.id}, ${widget.currentUser.id}]: ' +
              ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookrecord?.bookId == null || !widget.bookrecord.hasData || !widget.bookrecord.book.keys.containsAll(widget.filter))
      return Container();
    else
      return new Container(
          child: new Card(
            child: new Column(
              children: <Widget>[
                new Container(
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        bookImage(widget.bookrecord.book, 80, padding: 5.0),
                        Expanded(
                          child: Container(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      widget.bookrecord.book.authors.join(', '),
                                      style:
                                          Theme.of(context).textTheme.caption),
                                  Text(widget.bookrecord.book.title,
                                      style:
                                          Theme.of(context).textTheme.subtitle),
                                  bookCardText(),
                                ]),
                            margin: EdgeInsets.all(5.0),
                            alignment: Alignment.topLeft,
                          ),
                        ),
                      ]),
                  margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
                ),
                new Align(
                  alignment: Alignment(1.0, 1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      // Search button for the wishes
                      widget.bookrecord.isWish(widget.currentUser.id)
                          ? new IconButton(
                              //TODO: Search wished book
                              onPressed: () {},
                              tooltip: S.of(context).deleteShelf,
                              icon: new Icon(MyIcons.search),
                            )
                          : Container(),
                      // Button to return book only it it's borrowed
                      widget.bookrecord.isBorrowed(widget.currentUser.id)
                          ? new IconButton(
                              //TODO: Initiate book return
                              onPressed: () {
                                Firestore.instance.collection('bookrecords').document(widget.bookrecord.id).updateData({
                                  'transit': true,
                                  'transitId': widget.bookrecord.ownerId
                                });
                              },
                              tooltip: S.of(context).deleteShelf,
                              icon: new Icon(MyIcons.returning),
                            )
                          : Container(),
                      // Delete button only for OWN book and WISH
                      widget.bookrecord.isWish(widget.currentUser.id) ||
                              widget.bookrecord.isOwn(widget.currentUser.id)
                          ? new IconButton(
                              //TODO: Delete book/wish
                              onPressed: () => deleteBook(context),
                              tooltip: S.of(context).deleteShelf,
                              icon: new Icon(MyIcons.trash),
                            )
                          : Container(),
                      // Setting only for OWN books
                      widget.bookrecord.isOwn(widget.currentUser.id)
                          ? new IconButton(
                              //TODO: Add setting screen for a book
                              onPressed: () {},
                              tooltip: S.of(context).shelfSettings,
                              icon: new Icon(MyIcons.settings),
                            )
                          : Container(),
                      // Sharing button for everything
                      new IconButton(
                        //TODO: Modify dynamic link to point to seach screen for
                        // particular book
                        onPressed: () async {
                          final DynamicLinkParameters parameters =
                              new DynamicLinkParameters(
                            uriPrefix: 'biblosphere.page.link',
                            link: Uri.parse('https://biblosphere.org'),
                            androidParameters: AndroidParameters(
                              packageName: 'com.biblosphere.biblosphere',
                              minimumVersion: 0,
                            ),
                            dynamicLinkParametersOptions:
                                DynamicLinkParametersOptions(
                              shortDynamicLinkPathLength:
                                  ShortDynamicLinkPathLength.short,
                            ),
                            iosParameters: IosParameters(
                              bundleId: 'com.biblosphere.biblosphere',
                              minimumVersion: '0',
                            ),
                            socialMetaTagParameters: SocialMetaTagParameters(
                                title: S.of(context).title,
                                description: S.of(context).shareBooks,
                                imageUrl: Uri.parse(sharingUrl)),
                          );

                          final ShortDynamicLink shortLink =
                              await parameters.buildShortLink();

                          Share.share(shortLink.shortUrl.toString());
                        },
                        tooltip: S.of(context).shareShelf,
                        icon: new Icon(MyIcons.share1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            color: greyColor2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
          margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0));
  }

  Widget bookCardText() {
    switch (widget.bookrecord.type(widget.currentUser.id)) {
      case BookrecordType.own:
        return Text('Эта книга находится у вас',
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.wish:
        return Text('Эту книгу вы хотите почитать',
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.lent:
        return Text(
            'Эту книгу вы дали почитать пользователю ${widget.bookrecord.holder.name}',
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.borrowed:
        return Text(
            'Эту книгу вы взяли почитать у пользователя ${widget.bookrecord.owner.name}',
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.transit:
        return Text('По этой книге не завершён процесс передачи',
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.none:
      default:
        return Container();
    }
  }
}
