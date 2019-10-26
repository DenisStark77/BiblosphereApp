import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui/flutter_firebase_ui.dart';
import 'package:firebase_ui/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:share/share.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/payments.dart';
import 'package:biblosphere/books.dart';
import 'package:biblosphere/chat.dart';
import 'package:biblosphere/l10n.dart';

class MyHomePage extends StatefulWidget {
  final User currentUser;

  MyHomePage({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  @override
  _MyHomePageState createState() =>
      new _MyHomePageState(currentUser: currentUser);
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  User currentUser;

  _MyHomePageState({
    Key key,
    @required this.currentUser,
  });

  @override
  void initState() {
    super.initState();

    initDynamicLinks();
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentUser != widget.currentUser) {
      currentUser = widget.currentUser;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null && deepLink.path == "/chat") {
      String userId = deepLink.queryParameters['user'];
      DocumentSnapshot doc =
          await Firestore.instance.collection('users').document(userId).get();
      if (doc.exists) {
        User user = new User.fromJson(doc.data);
        Navigator.pushNamed(context, deepLink.path, arguments: user);
      }
    }

    // TODO: Do I need to cancel/unsubscribe from onLink listener?
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null && deepLink.path == "/chat") {
        String userId = deepLink.queryParameters['user'];
        DocumentSnapshot doc =
            await Firestore.instance.collection('users').document(userId).get();
        if (doc.exists) {
          User user = new User.fromJson(doc.data);

          // If no beneficiary for the current user add one from reference
          if (currentUser.beneficiary1 == null) {
            currentUser.beneficiary1 = user.id;
            currentUser.feeShared = 0;
            currentUser.beneficiary2 = user.beneficiary1;
          }
          Firestore.instance
              .collection('users')
              .document(currentUser.id)
              .updateData({
            'beneficiary1': currentUser.beneficiary1,
            'beneficiary2': currentUser.beneficiary2,
            'feeShared': 0.0
          });

          Navigator.pushNamed(context, deepLink.path, arguments: user);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        actions: <Widget>[
          new IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      //TODO: translation
                      builder: (context) => buildScaffold(context, "СООБЩЕНИЯ",
                          new ChatListWidget(currentUser: currentUser))));
            },
            //TODO: Change tooltip
            tooltip: S.of(context).cart,
            icon: new Icon(MyIcons.chat),
          ),
          Container(
              margin: EdgeInsets.only(right: 5.0),
              child: FlatButton(
                child: Row(children: <Widget>[
                  new Container(
                      margin: EdgeInsets.only(right: 5.0),
                      child: new Icon(MyIcons.money, color: Colors.white)),
                  new Text(money(currentUser?.getAvailable()),
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .apply(color: Colors.white))
                ]),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          //TODO: translation
                          builder: (context) => buildScaffold(
                              context,
                              S.of(context).financeTitle(money(currentUser?.getAvailable())),
                              new FinancialWidget(currentUser: currentUser))));

                  checkStellarPayments(currentUser).then((amount) {
                    if (amount > 0.0) setState(() {});
                  });
                },
                padding: EdgeInsets.all(0.0),
              )),
          /*
          new IconButton(
            onPressed: () async {
              /*
              // Code to migrate BOOKS
              QuerySnapshot snap = await Firestore.instance.collection('books').getDocuments();
              snap.documents.forEach((doc) async {
                print('!!!DEBUG book found ${doc.documentID}');
                if(doc.data["migrated"] != null && doc.data["migrated"])
                  return;

                Book book = new Book.fromJson(doc.data["book"]);

                await Firestore.instance.collection('books').document(doc.documentID).updateData(book.toJson()..addAll({'migrated': true}));
                print('!!!DEBUG: book updated ${doc.documentID}');
              });
                  // Code to migrate WISHES
                  QuerySnapshot snap = await Firestore.instance.collection('wishes').getDocuments();
                  snap.documents.forEach((doc) {
                    if(doc.data["migrated"] != null && doc.data["migrated"])
                      return;

                    GeoPoint pt = doc.data['wisher']['position'] as GeoPoint;
                    Bookrecord rec = new Bookrecord(ownerId: doc.data["book"]["id"],
                        bookId: doc.data["wisher"]["id"],
                        location: pt != null ? Geoflutterfire()
                            .point(latitude: pt.latitude, longitude: pt.longitude) : null);
                    rec.wish = true;
                    Firestore.instance.collection('bookrecords').document(rec.id).setData(rec.toJson());
                    Firestore.instance.collection('wishes').document(doc.documentID).updateData({'migrated': true});
                    print('!!!DEBUG: wish added ${rec.id}');
                  });

                  // Code to migrate BOOKCOPIES
                  QuerySnapshot snap = await Firestore.instance.collection('bookcopies').getDocuments();
                  snap.documents.forEach((doc) {
                    if(doc.data["migrated"] != null && doc.data["migrated"])
                      return;

                    GeoPoint pt = doc.data['position'] as GeoPoint;
                    Bookrecord rec = new Bookrecord(ownerId: doc.data["book"]["id"],
                              bookId: doc.data["owner"]["id"],
                        location: pt != null ? Geoflutterfire()
                        .point(latitude: pt.latitude, longitude: pt.longitude) : null);
                    Firestore.instance.collection('bookrecords').document(rec.id).setData(rec.toJson());
                    Firestore.instance.collection('bookcopies').document(doc.documentID).updateData({'migrated': true});
                    print('!!!DEBUG: bookrecord added ${rec.id}');
                  });
 */
            },
            tooltip: S.of(context).settings,
            icon: new Icon(MyIcons.settings),
          ),
*/
/*
            new IconButton(
              onPressed: () => signOutProviders(),
              tooltip: S.of(context).logout,
              icon: new Icon(MyIcons.exit),
            ),
*/
        ],
        title: new Text(S.of(context).title,
            style:
                Theme.of(context).textTheme.title.apply(color: Colors.white)),
      ),
      body: new Container(child: new OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
        return new Flex(
            direction: orientation == Orientation.landscape
                ? Axis.horizontal
                : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Expanded(
                  child: new InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => buildScaffold(
                                    context,
                                    S.of(context).addbookTitle,
                                    new AddBookWidget(
                                        currentUser: currentUser))));
                      },
                      child: new Card(
                          child: new Container(
                              padding: new EdgeInsets.all(10.0),
                              child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Icon(MyIcons.add, size: 60),
                                    new Text(S.of(context).addBook,
                                        style:
                                            Theme.of(context).textTheme.title)
                                  ]))))),
              new Expanded(
                child: new InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => buildScaffold(
                                context,
                                S.of(context).findbookTitle,
                                new FindBookWidget(currentUser: currentUser))));
                  },
                  child: new Card(
                    child: new Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new Icon(MyIcons.search, size: 60),
                          new Text(S.of(context).findBook,
                              style: Theme.of(context).textTheme.title)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Expanded(
                child: new InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => buildScaffold(
                                context,
                                S.of(context).mybooksTitle,
                                new ShowBooksWidget(
                                    currentUser: currentUser))));
                  },
                  child: new Card(
                    child: new Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new Icon(MyIcons.book, size: 60),
                          new Text(S.of(context).myBooks,
                              style: Theme.of(context).textTheme.title)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]);
      })),
      drawer: Scaffold(
        // The extra Scaffold needed to show Snackbar above the Drawer menu.
        // Stack and GestureDetector are workaround to return to app if tap
        // outside Drawer.
        backgroundColor: Colors.transparent,
        body: Stack(//fit: StackFit.expand,
            children: <Widget>[
          GestureDetector(onTap: () {
            Navigator.pop(context);
          }),
          Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //TODO: Explore why currentUser is null at start
                        currentUser != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                    userPhoto(currentUser, 90),
                                    Expanded(
                                        child: Container(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(currentUser.name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .title
                                                          .apply(
                                                              color: Colors
                                                                  .white)),
                                                  Row(children: <Widget>[
                                                    new Container(
                                                        margin: EdgeInsets.only(
                                                            right: 5.0),
                                                        child: new Icon(
                                                            MyIcons.money,
                                                            color:
                                                                Colors.white)),
                                                    new Text(
                                                        money(currentUser
                                                            ?.getAvailable()),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .body1
                                                            .apply(
                                                                color: Colors
                                                                    .white))
                                                  ]),
                                                ]))),
                                  ])
                            : Container(),
                        Container(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text(S.of(context).referralLink,
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .apply(color: Colors.white))),
                        Container(
                            padding: EdgeInsets.all(0.0),
                            child: Builder(
                                // Create an inner BuildContext so that the onPressed methods
                                // can refer to the Scaffold with Scaffold.of().
                                builder: (BuildContext context) {
                              return InkWell(
                                  onTap: () {
                                    Clipboard.setData(new ClipboardData(
                                        text: currentUser.link));
                                    //Navigator.pop(context);
                                    showSnackBar(context, S.of(context).linkCopied);
                                  },
                                  child: Text(currentUser.link,
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .apply(
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline)));
                            })),
                      ]),
                  decoration: BoxDecoration(
                    color: Colors.teal[800],
                  ),
                ),
                ListTile(
                  title: Text(S.of(context).menuMessages, style: Theme.of(context).textTheme.body1),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            //TODO: translation
                            builder: (context) => buildScaffold(
                                context,
                                S.of(context).titleMessages,
                                new ChatListWidget(currentUser: currentUser))));
                  },
                ),
                ListTile(
                  title: Text(S.of(context).menuSettings, style: Theme.of(context).textTheme.body1),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            //TODO: translation
                            builder: (context) => buildScaffold(
                                context,
                                S.of(context).titleSettings,
                                new SettingsWidget(currentUser: currentUser))));
                    checkStellarPayments(currentUser).then((amount) {
                      if (amount > 0.0) setState(() {});
                    });
                  },
                ),
                ListTile(
                  title: Text(S.of(context).menuBalance, style: Theme.of(context).textTheme.body1),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            //TODO: translation
                            builder: (context) => buildScaffold(
                                context,
                                S.of(context).financeTitle(money(currentUser?.getAvailable())),
                                new FinancialWidget(
                                    currentUser: currentUser))));
                    checkStellarPayments(currentUser).then((amount) {
                      if (amount > 0.0) setState(() {});
                    });
                  },
                ),
                ListTile(
                  title: Text(S.of(context).menuReferral, style: Theme.of(context).textTheme.body1),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            //TODO: translation
                            builder: (context) => buildScaffold(
                                context,
                                S.of(context).referralTitle,
                                new ReferralWidget(currentUser: currentUser))));
                  },
                ),
                ListTile(
                  title: Text(S.of(context).menuSupport, style: Theme.of(context).textTheme.body1),
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                          //TODO: translation
                            builder: (context) => buildScaffold(
                                context,
                                S.of(context).supportTitle,
                                new SupportWidget())));
                  },
                ),
                ListTile(
                  title: Text(S.of(context).logout, style: Theme.of(context).textTheme.body1),
                  onTap: () {
                    signOutProviders();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// Class to show my books (own, wishlist and borrowed/lent)
class ShowBooksWidget extends StatefulWidget {
  ShowBooksWidget({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _ShowBooksWidgetState createState() => new _ShowBooksWidgetState();
}

class _ShowBooksWidgetState extends State<ShowBooksWidget> {
  Set<String> keys = {};
  List<Book> suggestions = [];
  TextEditingController textController;
  bool transit = true, own = true, lent = true, borrowed = true, wish = true;

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
                        label: Text(S.of(context).chipMyBooks,
                            style: Theme.of(context).textTheme.body1),
                        selected: own,
                        onSelected: (bool s) {
                          setState(() {
                            own = s;
                          });
                        },
                      ),
                      FilterChip(
                        //avatar: icon,
                        label: Text(S.of(context).chipLent,
                            style: Theme.of(context).textTheme.body1),
                        selected: lent,
                        onSelected: (bool s) {
                          setState(() {
                            lent = s;
                          });
                        },
                      ),
                      FilterChip(
                        //avatar: icon,
                        label: Text(S.of(context).chipBorrowed,
                            style: Theme.of(context).textTheme.body1),
                        selected: borrowed,
                        onSelected: (bool s) {
                          setState(() {
                            borrowed = s;
                          });
                        },
                      ),
                      FilterChip(
                        //avatar: icon,
                        label: Text(S.of(context).chipWish,
                            style: Theme.of(context).textTheme.body1),
                        selected: wish,
                        onSelected: (bool s) {
                          setState(() {
                            wish = s;
                          });
                        },
                      ),
                      FilterChip(
                        //avatar: icon,
                        label: Text(S.of(context).chipTransit,
                            style: Theme.of(context).textTheme.body1),
                        selected: transit,
                        onSelected: (bool s) {
                          setState(() {
                            transit = s;
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
                              child: Text(S.of(context).noBooks,
                                style: Theme.of(context).textTheme.body1,
                              ));
                        }
                        return new ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            Bookrecord rec =
                                new Bookrecord.fromJson(document.data);
                            if (own && rec.isOwn(widget.currentUser.id))
                              return new MyBook(
                                  bookrecord: rec,
                                  currentUser: widget.currentUser,
                                  filter: keys);
                            else if (wish && rec.isWish(widget.currentUser.id))
                              //TODO: Change to MyWish
                              return new MyBook(
                                  bookrecord: rec,
                                  currentUser: widget.currentUser,
                                  filter: keys);
                            else if (lent && rec.isLent(widget.currentUser.id))
                              //TODO: Change to MyLent
                              return new MyBook(
                                  bookrecord: rec,
                                  currentUser: widget.currentUser,
                                  filter: keys);
                            else if (borrowed &&
                                rec.isBorrowed(widget.currentUser.id))
                              //TODO: Change to MyBorrowed
                              return new MyBook(
                                  bookrecord: rec,
                                  currentUser: widget.currentUser,
                                  filter: keys);
                            else if (transit &&
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
  MyBook(
      {Key key,
      @required this.bookrecord,
      @required this.currentUser,
      this.filter = const {}})
      : super(key: key);

  final Bookrecord bookrecord;
  final User currentUser;
  final Set<String> filter;

  @override
  _MyBookWidgetState createState() =>
      new _MyBookWidgetState(bookrecord: bookrecord, filter: filter);
}

class _MyBookWidgetState extends State<MyBook> {
  Bookrecord bookrecord;
  Set<String> filter = {};

  @override
  void initState() {
    super.initState();
    bookrecord.getBookrecord(widget.currentUser).whenComplete(() {
      setState(() {});
    });
  }

  _MyBookWidgetState(
      {Key key, @required this.bookrecord, @required this.filter});

  Future<void> deleteBook(BuildContext context) async {
    try {
      //Delete bookshelf record in Firestore database
      DocumentReference doc = Firestore.instance
          .collection('bookcopies')
          .document("${bookrecord.id}");
      await doc.delete();
      showSnackBar(context, S.of(context).bookDeleted);
    } catch (ex, stack) {
      print(
          'Bookcopy delete failed for [${bookrecord.id}, ${widget.currentUser.id}]: ' +
              ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookrecord?.bookId == null ||
        !bookrecord.hasData ||
        !bookrecord.book.keys.containsAll(filter))
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
                        bookImage(bookrecord.book, 80, padding: 5.0),
                        Expanded(
                          child: Container(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(bookrecord.book.authors.join(', '),
                                      style:
                                          Theme.of(context).textTheme.caption),
                                  Text(bookrecord.book.title,
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
                      bookrecord.isWish(widget.currentUser.id)
                          ? new IconButton(
                              //TODO: Search wished book
                              onPressed: () {},
                              tooltip: S.of(context).deleteShelf,
                              icon: new Icon(MyIcons.search),
                            )
                          : Container(),
                      // Button to return book only it it's borrowed
                      bookrecord.isBorrowed(widget.currentUser.id)
                          ? new IconButton(
                              //TODO: Initiate book return
                              onPressed: () {
                                Firestore.instance
                                    .collection('bookrecords')
                                    .document(bookrecord.id)
                                    .updateData({
                                  'transit': true,
                                  'transitId': bookrecord.ownerId
                                });
                              },
                              tooltip: S.of(context).deleteShelf,
                              icon: new Icon(MyIcons.returning),
                            )
                          : Container(),
                      // Delete button only for OWN book and WISH
                      bookrecord.isWish(widget.currentUser.id) ||
                              bookrecord.isOwn(widget.currentUser.id)
                          ? new IconButton(
                              //TODO: Delete book/wish
                              onPressed: () => deleteBook(context),
                              tooltip: S.of(context).deleteShelf,
                              icon: new Icon(MyIcons.trash),
                            )
                          : Container(),
                      // Setting only for OWN books
                      bookrecord.isOwn(widget.currentUser.id)
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
    switch (bookrecord.type(widget.currentUser.id)) {
      case BookrecordType.own:
        return Text(S.of(context).youHaveThisBook,
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.wish:
        return Text(S.of(context).youWishThisBook,
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.lent:
        return Text(S.of(context).youLentThisBook(bookrecord.holder.name),
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.borrowed:
        return Text(S.of(context).youBorrowThisBook(bookrecord.owner.name),
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.transit:
        return Text(S.of(context).youTransitThisBook,
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.none:
      default:
        return Container();
    }
  }
}

class FinancialWidget extends StatefulWidget {
  FinancialWidget({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _FinancialWidgetState createState() =>
      new _FinancialWidgetState(currentUser: currentUser);
}

class _FinancialWidgetState extends State<FinancialWidget> {
  bool showIn = true;
  bool showOut = true;
  bool showRef = true;
  bool showRewards = true;
  bool showLeasing = true;

  User currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _FinancialWidgetState({
    Key key,
    @required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Card(
              child: new Container(
                  padding: new EdgeInsets.all(10.0),
                  child: new Wrap(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: FilterChip(
                          //avatar: icon,
                          label: Text(S.of(context).chipPayin,
                              style: Theme.of(context).textTheme.button),
                          selected: showIn,
                          onSelected: (bool s) {
                            setState(() {
                              showIn = s;
                            });
                          },
                        )),
                    Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: FilterChip(
                          //avatar: icon,
                          label: Text(S.of(context).chipPayout,
                              style: Theme.of(context).textTheme.button),
                          selected: showOut,
                          onSelected: (bool s) {
                            setState(() {
                              showOut = s;
                            });
                          },
                        )),
                    Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: FilterChip(
                          //avatar: icon,
                          label: Text(S.of(context).chipLeasing,
                              style: Theme.of(context).textTheme.button),
                          selected: showLeasing,
                          onSelected: (bool s) {
                            setState(() {
                              showLeasing = s;
                            });
                          },
                        )),
                    Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: FilterChip(
                          //avatar: icon,
                          label: Text(S.of(context).chipReward,
                              style: Theme.of(context).textTheme.button),
                          selected: showRewards,
                          onSelected: (bool s) {
                            setState(() {
                              showRewards = s;
                            });
                          },
                        )),
                    Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: FilterChip(
                          //avatar: icon,
                          label: Text(S.of(context).chipReferrals,
                              style: Theme.of(context).textTheme.button),
                          selected: showRef,
                          onSelected: (bool s) {
                            setState(() {
                              showRef = s;
                            });
                          },
                        )),
                  ]))),
          new Expanded(
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('operations')
                      .where("users", arrayContains: widget.currentUser.id)
                      .orderBy('date', descending: true)
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
                                S.of(context).noOperations,
                                style: Theme.of(context).textTheme.body1,
                              ));
                        }
                        return new ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            Operation op =
                                new Operation.fromJson(document.data);

                            if (op.isIn(currentUser) && showIn ||
                                op.isLeasing(currentUser) && showLeasing ||
                                op.isReward(currentUser) && showRewards ||
                                op.isReferral(currentUser) && showRewards ||
                                op.isOut(currentUser) && showOut) {
                              return MyOperation(
                                  operation: op, currentUser: currentUser);
                            } else {
                              return Container();
                            }
                          }).toList(),
                        );
                    }
                  })),
        ],
      ),
    );
  }
}

class MyOperation extends StatefulWidget {
  MyOperation({Key key, @required this.operation, @required this.currentUser})
      : super(key: key);

  final Operation operation;
  final User currentUser;

  @override
  _MyOperationWidgetState createState() => new _MyOperationWidgetState(
      operation: operation, currentUser: currentUser);
}

class _MyOperationWidgetState extends State<MyOperation> {
  Operation operation;
  User currentUser;
  Book book;
  User peer;
  bool hasData = false;

  @override
  void initState() {
    super.initState();
    getDetails().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(MyOperation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentUser != widget.currentUser ||
        oldWidget.operation != widget.operation) {
      currentUser = widget.currentUser;
      operation = widget.operation;
      hasData = false;
      getDetails().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  _MyOperationWidgetState(
      {Key key, @required this.operation, @required this.currentUser});

  @override
  Widget build(BuildContext context) {
    if (operation.isLeasing(currentUser)) {
      return new Container(
          child: Row(children: <Widget>[
        bookImage(book, 25, padding: 3.0),
        Expanded(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(S.of(context).opLeasing), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(DateFormat('H:m MMMd')
                            .format(operation.date))), // Date
                  ]),
              Text('-${money(operation.amount)}'), // Amount
            ])))
      ]));
    } else if (operation.isReward(currentUser)) {
      return new Container(
          child: Row(children: <Widget>[
        bookImage(book, 25, padding: 3.0),
        Expanded(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(S.of(context).opReward), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(DateFormat('H:m MMMd')
                            .format(operation.date))), // Date
                  ]),
              Text('+${money(operation.amount)}'), // Amount
            ])))
      ]));
    } else if (operation.isInPurchase(currentUser)) {
      return new Container(
          child: Row(children: <Widget>[
        Container(
            margin: EdgeInsets.all(3.0), child: Icon(MyIcons.money, size: 25)),
        Expanded(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(S.of(context).opInAppPurchase), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(DateFormat('H:m MMMd')
                            .format(operation.date))), // Date
                  ]),
              Text('+${money(operation.amount)}'), // Amount
            ])))
      ]));
    } else if (operation.isInStellar(currentUser)) {
      return new Container(
          child: Row(children: <Widget>[
        Container(
            margin: EdgeInsets.all(3.0), child: Icon(MyIcons.money, size: 25)),
        Expanded(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(S.of(context).opInStellar), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(DateFormat('H:m MMMd')
                            .format(operation.date))), // Date
                  ]),
              Text('+${money(operation.amount)}'), // Amount
            ])))
      ]));
    } else if (operation.isOutStellar(currentUser)) {
      return new Container(
          child: Row(children: <Widget>[
            Container(
                margin: EdgeInsets.all(3.0), child: Icon(MyIcons.money, size: 25)),
            Expanded(
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(S.of(context).opOutStellar), // Description
                                Container(
                                    margin: EdgeInsets.only(right: 10.0),
                                    child: Text(DateFormat('H:m MMMd')
                                        .format(operation.date))), // Date
                              ]),
                          Text('-${money(operation.amount)}'), // Amount
                        ])))
          ]));
    } else if (operation.isReferral(currentUser)) {
      return new Container(
          child: Row(children: <Widget>[
        userPhoto(peer, 25, padding: 3.0),
        Expanded(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(S.of(context).opReferral), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(DateFormat('H:m MMMd')
                            .format(operation.date))), // Date
                  ]),
              Text(
                  '+${money(operation.referralAmount(currentUser))}'), // Amount
            ])))
      ]));
    } else {
      return Container();
    }
  }

  Future<void> getDetails() async {
    if (hasData) {
      return this;
    } else {
      // Read book and peer details for reward and leasing
      if (operation.type == OperationType.Reward ||
          operation.type == OperationType.Leasing) {
        DocumentSnapshot bookSnap = await Book.Ref(operation.bookId).get();
        book = new Book.fromJson(bookSnap.data);

        DocumentSnapshot userSnap = await User.Ref(operation.peerId).get();
        peer = new User.fromJson(userSnap.data);
      }

      hasData = true;
    }
  }
}

class ReferralWidget extends StatefulWidget {
  ReferralWidget({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _ReferralWidgetState createState() =>
      new _ReferralWidgetState(currentUser: currentUser);
}

class _ReferralWidgetState extends State<ReferralWidget> {
  User currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _ReferralWidgetState({
    Key key,
    @required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Card(
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text(S.of(context).referralLink,
                            style: Theme.of(context).textTheme.title)),
                    Container(
                        child: InkWell(
                            onTap: () {
                              //TODO: replace with real link
                              Clipboard.setData(
                                  new ClipboardData(text: currentUser.link));
                              //Navigator.pop(context);
                              showSnackBar(
                                  context, S.of(context).linkCopied);
                            },
                            child: Text(currentUser.link,
                                style: Theme.of(context).textTheme.body1.apply(
                                    decoration: TextDecoration.underline))))
                  ]),
            ),
          ),
          new Expanded(
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('users')
                      .where("beneficiary1", isEqualTo: currentUser.id)
                      .orderBy('feeShared', descending: true)
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
                                S.of(context).noReferrals,
                                style: Theme.of(context).textTheme.body1,
                              ));
                        }
                        return new ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            User user = new User.fromJson(document.data);

                            return new Container(
                                child: Row(children: <Widget>[
                              userPhoto(user, 40, padding: 3.0),
                              Expanded(
                                  child: Container(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                              user.name), // Description
                                          Container(
                                              margin:
                                                  EdgeInsets.only(right: 10.0),
                                              child: Text(
                                                  money(user.getAvailable()))), // Date
                                        ]),
                                    Text(S.of(context).sharedFeeLine(money(user.feeShared))), // Amount
                                  ])))
                            ]));
                          }).toList(),
                        );
                    }
                  })),
        ],
      ),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  SettingsWidget({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  _SettingsWidgetState createState() =>
      new _SettingsWidgetState(currentUser: currentUser);
}

class _SettingsWidgetState extends State<SettingsWidget> {
  User currentUser;
  TextEditingController amountTextCtr;
  TextEditingController payoutTextCtr;
  String _accountErrorText;
  String _amountErrorText;

  @override
  void initState() {
    super.initState();

    payoutTextCtr = new TextEditingController();
    if (currentUser.payoutId != null) payoutTextCtr.text = currentUser.payoutId;

    amountTextCtr = new TextEditingController();
  }

  @override
  void dispose() {
    payoutTextCtr.dispose();
    amountTextCtr.dispose();

    super.dispose();
  }

  _SettingsWidgetState({
    Key key,
    @required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: ListView(
        //mainAxisSize: MainAxisSize.min,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Card(
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: <
                        Widget>[
                      userPhoto(currentUser, 90),
                      Expanded(
                          child: Container(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(currentUser.name,
                                        style:
                                            Theme.of(context).textTheme.title),
                                    Row(children: <Widget>[
                                      new Container(
                                          margin: EdgeInsets.only(right: 5.0),
                                          child: new Icon(MyIcons.money)),
                                      new Text(
                                          money(currentUser?.getAvailable()),
                                          style:
                                              Theme.of(context).textTheme.body1)
                                    ]),
                                  ]))),
                    ]),
                    Container(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(S.of(context).referralLink)),
                    Container(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Builder(
                            // Create an inner BuildContext so that the onPressed methods
                            // can refer to the Scaffold with Scaffold.of().
                            builder: (BuildContext context) {
                          return InkWell(
                              onTap: () {
                                Clipboard.setData(
                                    new ClipboardData(text: currentUser.link));
                                //Navigator.pop(context);
                                showSnackBar(context,
                                    S.of(context).linkCopied);
                              },
                              child: Text(currentUser.link,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .apply(
                                          decoration:
                                              TextDecoration.underline)));
                        })),
                    Text(S.of(context).inputStellarAcount),
                    new Container(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Builder(
                            // Create an inner BuildContext so that the onPressed methods
                            // can refer to the Scaffold with Scaffold.of().
                            builder: (BuildContext context) {
                          return InkWell(
                              onTap: () {
                                Clipboard.setData(new ClipboardData(
                                    text: currentUser.accountId));
                                //Navigator.pop(context);
                                showSnackBar(
                                    context, S.of(context).accountCopied);
                              },
                              child: Text(currentUser.accountId,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .apply(
                                          decoration:
                                              TextDecoration.underline)));
                        })),
                    Text(S.of(context).outputStellarAccount),
                    new Container(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Theme(
                          data: ThemeData(platform: TargetPlatform.android),
                          child: TextField(
                            onSubmitted: (value) async {
                              if (!await checkStellarAccount(value))
                                setState(() {
                                  _accountErrorText = S.of(context).wrongAccount;
                                });
                              else
                                setState(() {
                                  _accountErrorText = null;
                                });

                              currentUser.payoutId = value;
                              await currentUser
                                  .ref()
                                  .updateData({'payoutId': value});
                            },
                            maxLines: 1,
                            controller: payoutTextCtr,
                            style: Theme.of(context).textTheme.body1,
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(2.0),
                                hintText: S.of(context).hintOutptAcount,
                                errorText: _accountErrorText),
                          )),
                    ),
                    Text(S.of(context).stellarOutput),
                    new Container(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Row(children: <Widget>[
                          Flexible(
                              child: Container(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Theme(
                                      data: ThemeData(
                                          platform: TargetPlatform.android),
                                      child: TextField(
                                        maxLines: 1,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          WhitelistingTextInputFormatter(RegExp(
                                              r'((\d+(\.\d*)?)|(\.\d+))'))
                                        ],
                                        controller: amountTextCtr,
                                        style:
                                            Theme.of(context).textTheme.body1,
                                        decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.all(2.0),
                                            hintText: S.of(context).hintNotMore(money(currentUser.getAvailable())),
                                            errorText: _amountErrorText),
                                      )))),
                          RaisedButton(
                              onPressed: () async {
                                try {
                                  if (!await checkStellarAccount(
                                      currentUser.payoutId)) {
                                    setState(() {
                                      _accountErrorText = S.of(context).wrongAccount;
                                    });
                                    return;
                                  }
                                  if (amountTextCtr.text == null ||
                                      amountTextCtr.text.isEmpty) {
                                    setState(() {
                                      _amountErrorText = S.of(context).emptyAmount;
                                    });
                                    return;
                                  }

                                  double amount =
                                      double.tryParse(amountTextCtr.text);

                                  if (amount == null || amount <= 0.0) {
                                    setState(() {
                                      _amountErrorText = S.of(context).negativeAmount;
                                    });
                                    return;
                                  }

                                  if (amount > currentUser.getAvailable()) {
                                    setState(() {
                                      _amountErrorText = S.of(context).exceedAmount;
                                    });
                                    return;
                                  }

                                  if (_amountErrorText != null ||
                                      _accountErrorText != null)
                                    setState(() {
                                      _amountErrorText = null;
                                      _accountErrorText = null;
                                    });

                                  FocusScope.of(context).unfocus();
                                  amount = dp(amount, 5);

                                  await payoutStellar(currentUser, amount);

                                  showSnackBar(
                                      context, S.of(context).successfulPayment);
                                } catch (ex) {
                                  // TODO: Log event for administrator to investigate
                                  showSnackBar(context,S.of(context).paymentError);
                                }
                              },
                              child: Text(S.of(context).buttonTransfer))
                        ])),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportWidget extends StatelessWidget {
  SupportWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        /*child:
        ListView(children: <Widget>[
          Text('Display 4', style: Theme.of(context).textTheme.display4),
          Text('Display 3', style: Theme.of(context).textTheme.display3),
          Text('Display 2', style: Theme.of(context).textTheme.display2),
          Text('Display 1', style: Theme.of(context).textTheme.display1),
          Text('Заглавие', style: Theme.of(context).textTheme.headline),
          Text('Подзаглавие', style: Theme.of(context).textTheme.subhead),
          Text('Заголовок', style: Theme.of(context).textTheme.title),
          Text('Подзаголовок', style: Theme.of(context).textTheme.subtitle),
          Text('Кнопка', style: Theme.of(context).textTheme.button),
          Text('Подпись', style: Theme.of(context).textTheme.caption),
          Text('Сноски', style: Theme.of(context).textTheme.overline),
          Text('Текст абзаца 1', style: Theme.of(context).textTheme.body1),
          Text('Текст абзаца 2', style: Theme.of(context).textTheme.body2)
        ]) */
    );
  }
}
