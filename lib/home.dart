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
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/lifecycle.dart';
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

    if (currentUser != null) initDynamicLinks();
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentUser != widget.currentUser) {
      currentUser = widget.currentUser;
    }

    if (currentUser != null) initDynamicLinks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> processDeepLink(Uri deepLink) async {
    deepLink.queryParameters.forEach((k, v) => print('$k: $v'));

    if (deepLink.path == "/chat") {
      String userId = deepLink.queryParameters['user'];
      String refId = deepLink.queryParameters['ref'];
      String bookrecordId = deepLink.queryParameters['book'];

      // Use ref and user as defaults for each other
      if (refId == null && userId != null) refId = userId;
      if (userId == null && refId != null) userId = refId;

      // If link for the book of the same user open MyBooks
      if (userId == currentUser.id) {
        String filter = '';
        if (bookrecordId != null) {
          DocumentSnapshot snap = await Bookrecord.Ref(bookrecordId).get();

          if (snap.exists) filter = snap.data['title'];
        }

        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => buildScaffold(
                    context,
                    S.of(context).mybooksTitle,
                    new ShowBooksWidget(
                        currentUser: currentUser, filter: filter),
                    appbar: false)));
      } else {
        User user, ref;

        if (userId != null) {
          DocumentSnapshot doc = await Firestore.instance
              .collection('users')
              .document(userId)
              .get();

          if (doc.exists) {
            user = new User.fromJson(doc.data);
          }
        }

        if (refId != null) {
          DocumentSnapshot doc = await Firestore.instance
              .collection('users')
              .document(refId)
              .get();

          if (doc.exists) {
            ref = new User.fromJson(doc.data);
          }
        }

        // Use ref and user as defaults for each other
        if (ref == null && user != null) ref = user;
        if (user == null && ref != null) user = ref;

        if (ref != null) {
          // If no beneficiary for the current user add one from reference
          if (currentUser.beneficiary1 == null) {
            currentUser.beneficiary1 = ref.id;
            currentUser.feeShared = 0;
            currentUser.beneficiary2 = ref.beneficiary1;
          }

          Firestore.instance
              .collection('users')
              .document(currentUser.id)
              .updateData({
            'beneficiary1': currentUser.beneficiary1,
            'beneficiary2': currentUser.beneficiary2,
            'feeShared': 0.0
          });
        }

        // If user or ref defined go to user chat
        if (user != null) {
          Messages chat = await getChatAndTransit(
              context: context,
              currentUserId: currentUser.id,
              from: user.id,
              to: widget.currentUser.id,
              bookrecordId: bookrecordId);

          // Open chat widget
          Chat.runChat(context, widget.currentUser, user, chat: chat);
        }
      }
      // It was Navigator.pushNamed in original example. Don't know why...
      // Navigator.pushNamed(context, deepLink.path, arguments: user);
    } else if (deepLink.path == "/search") {
      // Deep link to go to the search results for the book.
      // Book have to be registered in Biblosphere
      String isbn = deepLink.queryParameters['isbn'];
      if (isbn != null) {
        DocumentSnapshot snap = await Book.Ref(isbn).get();

        if (snap.exists) {
          Book book = new Book.fromJson(snap.data);

          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => buildScaffold(
                      context,
                      null,
                      new FindBookWidget(
                          currentUser: widget.currentUser, filter: book.title),
                      appbar: false)));
        } else {
          // TODO: report missing book in the link
        }
      } else {
        // TODO: report broken link: bookId is null
      }
    } else if (deepLink.path == "/addbook" || deepLink.path == "/addwish") {
      // Deep link to go add book/wish and go to My Books with filter for this book.
      // Book have to be registered in Biblosphere
      bool wish = (deepLink.path == "/addwish");
      String isbn = deepLink.queryParameters['isbn'];
      if (isbn != null) {
        DocumentSnapshot snap = await Book.Ref(isbn).get();
        if (snap.exists) {
          Book book = new Book.fromJson(snap.data);
          await addBookrecord(
              context, book, widget.currentUser, wish, await currentLocation(),
              snackbar: false);

          // Open My Book Screen with filter
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => buildScaffold(
                      context,
                      S.of(context).mybooksTitle,
                      new ShowBooksWidget(
                          currentUser: currentUser, filter: book.title),
                      appbar: false)));
        } else {
          // TODO: report missing book in the link
        }
      } else {
        // TODO: report broken link: bookId is null
      }
    } else if (deepLink.path == "/support") {
      String message = deepLink.queryParameters['msg'];
      Messages chat = await getChatAndTransit(
          context: context,
          currentUserId: currentUser.id,
          from: widget.currentUser.id,
          system: true);

      Chat.runChat(context, widget.currentUser, null,
          chat: chat, message: message, send: true);
    }
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) processDeepLink(deepLink);

    // TODO: Do I need to cancel/unsubscribe from onLink listener?
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) processDeepLink(deepLink);
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
/*
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
            icon: assetIcon(communication_100, size: 30),
          ),
          Container(
              margin: EdgeInsets.only(right: 10.0, left: 10.0),
              child: FlatButton(
                child: Row(children: <Widget>[
                  new Container(
                      margin: EdgeInsets.only(right: 5.0),
                      child: assetIcon(coins_100, size: 25)),
                  new Text(money(currentUser?.getAvailable()),
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .apply(color: C.titleText))
                ]),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          //TODO: translation
                          builder: (context) => buildScaffold(
                              context,
                              S.of(context).financeTitle(
                                  money(currentUser?.getAvailable())),
                              new FinancialWidget(currentUser: currentUser),
                              appbar: false)));

                  checkStellarPayments(currentUser).then((amount) {
                    if (amount > 0.0) setState(() {});
                  });
                },
                padding: EdgeInsets.all(0.0),
              )),
*/
          new IconButton(
            onPressed: () async {
              QuerySnapshot snap = await Firestore.instance
                  .collection('messages')
                  //.where('fromId', isEqualTo: 'oyYUDByQGVdgP13T1nyArhyFkct1')
                  .getDocuments();
              await Future.forEach(snap.documents,
                  (DocumentSnapshot doc) async {
                Messages chat = Messages.fromJson(doc.data, doc);

                // Skip already
                if (chat.fromName != null) return;

                String from, to;
                if (chat.fromId != null)
                  from = chat.fromId;
                else
                  from = chat.ids[0];

                if (!chat.system) {
                  if (chat.toId != null)
                    to = chat.toId;
                  else
                    to = chat.ids[1];
                }

                Map<String, String> data = {};

                if (from != null) {
                  DocumentSnapshot snap = await User.Ref(from).get();
                  if (snap.exists) {
                    User user = new User.fromJson(snap.data);
                    data.addAll(
                        {'fromName': user.name, 'fromImage': user.photo});
                  } else {
                    print('!!!DEBUG: from user does not exist: ${from}');
                  }
                }

                if (to != null) {
                  DocumentSnapshot snap = await User.Ref(to).get();
                  if (snap.exists) {
                    User user = new User.fromJson(snap.data);
                    data.addAll({'toName': user.name, 'toImage': user.photo});
                  } else {
                    print('!!!DEBUG: to user does not exist: ${to}');
                  }
                }

                if (data.length > 0) await doc.reference.updateData(data);
              });

/*
              // Convert CHAT ids
              QuerySnapshot snap = await Firestore.instance.collection('messages')
                  //.where('fromId', isEqualTo: 'oyYUDByQGVdgP13T1nyArhyFkct1')
                  .getDocuments();
              await Future.forEach(snap.documents, (DocumentSnapshot doc) async {
                Messages chat = Messages.fromJson(doc.data);

                // Skip old chats
                if( ! (chat.system != null && chat.system && chat.fromId != null
                    || (chat.system == null || !chat.system) && chat.fromId != null && chat.toId != null))
                  return;

                // Skip if already converted
                if (doc.documentID == chat.ref.documentID)
                  return;

                await chat.ref.setData(chat.toJson());

                await Firestore.instance.collection('messages').document(doc.documentID)
                    .delete();

                print('!!!DEBUG: chat converted ${doc.documentID} -> ${chat.ref.documentID}');
              });
              QuerySnapshot snap = await Firestore.instance.collection('bookrecords')
              //.where('id', isEqualTo: 'b:0lCFhlFm4pUhMnaUfbB3bDjw1pW2:9785080057250')
                  .getDocuments();
              await Future.forEach(snap.documents, (DocumentSnapshot doc) async {
                Bookrecord rec = Bookrecord.fromJson(doc.data);

                String ownerId = rec.ownerId;
                String holderId = rec.holderId;
                String ownerName;
                String holderName;

                if (rec.ownerName != null && rec.holderName != null)
                  return;

                if (ownerId == null) {
                  print('!!!DEBUG: Owner id is NULL: ${doc.documentID}');
                  return;
                }

                if (holderId == null)
                  holderId = ownerId;

                if (ownerId != null) {
                  DocumentSnapshot doc = await User.Ref(ownerId).get();
                  if (doc.exists) {
                    ownerName = doc.data['name'];
                  } else {
                    print('!!!DEBUG: Owner user record missing: ${ownerId}');
                    return;
                  }
                }

                if (holderId == ownerId) {
                  holderName = ownerName;
                } else {
                  DocumentSnapshot doc = await User.Ref(holderId).get();
                  if (doc.exists) {
                    holderName = doc.data['name'];
                  } else {
                    print('!!!DEBUG: Holder user record missing: ${holderId}');
                    return;
                  }
                }

                rec.id = rec.ref.documentID;
                await rec.ref.updateData({'ownerName': ownerName, 'holderName': holderName});
              });
      // Update ids to isbn for books
      QuerySnapshot snap = await Firestore.instance.collection('bookrecords')
          //.where('id', isEqualTo: '09tVTryOarysiwG4OZdc')
          .getDocuments();
      await Future.forEach(snap.documents, (DocumentSnapshot doc) async {
        Bookrecord rec = Bookrecord.fromJson(doc.data);

        // Skip books without isbn , owner, wish
        if( doc.documentID.startsWith(r'w:') || doc.documentID.startsWith(r'b:') || rec.isbn == null || rec.isbn.isEmpty || rec.isbn == 'NA' || rec.ownerId == null || rec.wish == null)
          return;

        rec.id = rec.ref.documentID;
        await rec.ref.setData(rec.toJson());

        await Firestore.instance.collection('bookrecords').document(doc.documentID)
            .delete();
      });

              // Update ids to isbn for books
              int count = 0;

              QuerySnapshot snap = await Firestore.instance.collection('books')
                  .where('isbn', isEqualTo: '9785366006125')
                  .getDocuments();
              await Future.forEach(snap.documents, (DocumentSnapshot doc) async {
                Book book = Book.fromJson(doc.data);

                // Skip books without isbn and with price
                if( doc.documentID.startsWith('9') || book.isbn == null || book.isbn.isEmpty || book.isbn == 'NA')
                  return;

                await Firestore.instance.collection('books').document(book.isbn)
                    .setData(book.toJson());

                await Firestore.instance.collection('books').document(doc.documentID)
                    .delete();
              });

              // Update bookId to ISBN
              snap = await Firestore.instance
                  .collection('bookrecords')
                  //.where('isbn', isEqualTo: '9781609942960')
                  .getDocuments();

              await Future.forEach(snap.documents, (DocumentSnapshot doc) async {
                String isbn = doc.data['isbn'];

                if (isbn == null) {
                  print('!!!DEBUG: missing isbn: ${doc.documentID}');
                }

                await Firestore.instance
                      .collection('bookrecords')
                      .document(doc.documentID)
                      .updateData({'bookId': isbn});
              });

              // Enrich bookrecords
              QuerySnapshot snap = await Firestore.instance
                  .collection('bookrecords')
                  //.where('bookId', isEqualTo: '-LbY_2ANWs4BoZhPpdHa')
                  .getDocuments();

              await Future.forEach(snap.documents, (doc) async {
                String bookId = doc.data['bookId'];

                if (bookId == null) {
                  print('!!!DEBUG: book missing: ${bookId}');
                }

                DocumentSnapshot bookSnap = await Firestore.instance
                    .collection('books')
                    .document(bookId)
                    .get();

                if (bookSnap.exists) {
                  Book book = new Book.fromJson(bookSnap.data);

                  await Firestore.instance
                      .collection('bookrecords')
                      .document(doc.documentID)
                      .updateData({
                    'isbn': book.isbn,
                    'image': book.image,
                    'title': book.title,
                    'authors': book.authors,
                    'keys': book.keys.toList(),
                    'price': book.price,
                  });
                }
              });

              // Update price for books
              int count = 0;
              QuerySnapshot snap = await Firestore.instance.collection('books')
                  //.where('isbn', isEqualTo: '9781609942960')
                  .getDocuments();
              for(DocumentSnapshot doc in snap.documents) {
                Book book = Book.fromJson(doc.data);

                // Skip books without isbn and with price
                if( book.isbn == null || book.isbn.startsWith('9785') || book.isbn.isEmpty || book.isbn == 'NA' || book.price != null && book.price > 0)
                  continue;

                double price = await getPriceFromWeb(book);

                await Firestore.instance.collection('books').document(
                    doc.documentID).updateData({'price': price});

                if (price != 0.0) {
                  print('!!!DEBUG: ${book.title}: ${money(price)} ');
                } else {
                  print('!!!DEBUG: isbn:${book.isbn} \"${book.title}\": NOT FOUND ');
                  count++;
                }

                await Future.delayed(Duration(seconds: 3));
              }
              print('!!!DEBUG: NOT FOUND count: ${count}');
              // Books statistics
              QuerySnapshot snap = await Firestore.instance.collection('books').where('isbn', isEqualTo: '9785699761784').getDocuments();
              int books = 0, rus = 0, withprice = 0, noisbn = 0;
              await Future.forEach(snap.documents, (doc) async {
                Book book = Book.fromJson(doc.data);

                books++;

                if( book.isbn == null || book.isbn == 'NA' || book.isbn == '' || !book.isbn.startsWith('9'))
                  noisbn++;
                else if(book.isbn.startsWith('9785'))
                  rus++;

                if(book.price != null && book.price > 0.0)
                  withprice++;
              });
              print('!!!DEBUG: statistics: books: ${books}, with price: ${withprice}, no isbn: ${noisbn}, russian: ${rus}');

              // Code to fill ids for BOOKS
              QuerySnapshot snap = await Firestore.instance
                  .collection('bookrecords')
                  .getDocuments();
              snap.documents.forEach((doc) async {
                // Skip books with counters
                if (doc.data['confirmed'] != null) return;

                await Firestore.instance
                    .collection('bookrecords')
                    .document(doc.documentID)
                    .updateData({'confirmed': false});
                print('!!!DEBUG: bookrecord updated ${doc.documentID}');
              });
              // Code to fill ids for BOOKS
              QuerySnapshot snap = await Firestore.instance.collection('books').getDocuments();
              snap.documents.forEach((doc) async {
                // Skip books with counters
                if( doc.data['id'] != null)
                  return;

                await Firestore.instance.collection('books').document(doc.documentID).updateData({'id': doc.documentID});
                print('!!!DEBUG: book updated ${doc.documentID}');
              });
              // Code to fill counters for BOOKS
              QuerySnapshot snap = await Firestore.instance.collection('books').getDocuments();
              snap.documents.forEach((doc) async {
                // Skip books with counters
                QuerySnapshot records = await Firestore.instance.collection('bookrecords')
                    .where('bookId', isEqualTo: doc.documentID)
                    .where('wish', isEqualTo: false)
                    .getDocuments();

                int copies = records?.documents?.length ?? 0;

                records = await Firestore.instance.collection('bookrecords')
                    .where('bookId', isEqualTo: doc.documentID)
                    .where('wish', isEqualTo: true)
                    .getDocuments();

                int wishes = records?.documents?.length ?? 0;

                await Firestore.instance.collection('books').document(doc.documentID).updateData({'copies': copies, 'wishes': wishes});
                print('!!!DEBUG: book updated ${doc.documentID} copies/wishes ${copies}/${wishes}');
              });
              // Code to migrate BOOKS
              QuerySnapshot snap = await Firestore.instance.collection('books').getDocuments();
              snap.documents.forEach((doc) async {
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
                    //if(doc.data["migrated"] != null && doc.data["migrated"])
                    //  return;

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
            icon: assetIcon(settings_100, size: 30),
          ),
        ],
        title: new Text(S.of(context).title,
            style: Theme.of(context).textTheme.title.apply(color: C.titleText)),
        centerTitle: true,
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
                                    new AddBookWidget(currentUser: currentUser),
                                    appbar: false)));
                      },
                      child: new Card(
                          child: new Container(
                              padding: new EdgeInsets.all(10.0),
                              child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Container(
                                        width: 60,
                                        child: Image.asset(add_book_100)),
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
                                new FindBookWidget(currentUser: currentUser),
                                appbar: false)));
                  },
                  child: new Card(
                    child: new Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(width: 60, child: Image.asset(search_100)),
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
                                new ShowBooksWidget(currentUser: currentUser),
                                appbar: false)));
                  },
                  child: new Card(
                    child: new Container(
                      padding: new EdgeInsets.all(10.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(width: 60, child: Image.asset(books_100)),
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
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 5.0),
                                                      child: Text(
                                                          currentUser.name,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .title
                                                              .apply(
                                                                  color: C
                                                                      .titleText))),
                                                  Row(children: <Widget>[
                                                    new Container(
                                                        margin: EdgeInsets.only(
                                                            right: 5.0),
                                                        child: assetIcon(
                                                            coins_100,
                                                            size: 20)),
                                                    new Text(
                                                        money(currentUser
                                                            ?.getAvailable()),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .body1
                                                            .apply(
                                                                color: C
                                                                    .titleText))
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
                                    .apply(color: C.titleText))),
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
                                    showSnackBar(
                                        context, S.of(context).linkCopied);
                                  },
                                  child: Text(currentUser.link,
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .apply(
                                              color: C.titleText,
                                              decoration:
                                                  TextDecoration.underline)));
                            })),
                      ]),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  title: drawerMenuItem(
                      context, S.of(context).menuMessages, communication_100,
                      size: 30),
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
                  title: drawerMenuItem(
                      context, S.of(context).menuSettings, settings_100,
                      size: 28),
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
                  },
                ),
                ListTile(
                  title: drawerMenuItem(
                      context, S.of(context).menuBalance, coins_100,
                      size: 28),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            //TODO: translation
                            builder: (context) => buildScaffold(
                                context,
                                S.of(context).financeTitle(
                                    money(currentUser?.getAvailable())),
                                new FinancialWidget(currentUser: currentUser),
                                appbar: false)));
                  },
                ),
                ListTile(
                  title: drawerMenuItem(
                      context, S.of(context).menuReferral, handshake_100,
                      size: 28),
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
                  title: drawerMenuItem(
                      context, S.of(context).menuSupport, online_support_100,
                      size: 28),
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
                  title: drawerMenuItem(context, S.of(context).logout, exit_100,
                      size: 27),
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
  ShowBooksWidget({Key key, @required this.currentUser, this.filter})
      : super(key: key);

  final User currentUser;
  final String filter;

  @override
  _ShowBooksWidgetState createState() =>
      new _ShowBooksWidgetState(currentUser: currentUser, filter: filter);
}

class _ShowBooksWidgetState extends State<ShowBooksWidget> {
  User currentUser;
  String filter;
  Set<String> keys = {};
  List<Book> suggestions = [];
  TextEditingController textController;
  bool transit = true, own = true, lent = true, borrowed = true, wish = true;
  StreamSubscription<QuerySnapshot> bookSubscription;

  bool showClearFilters = false;

  List<DocumentSnapshot> books = [];

  @override
  void initState() {
    super.initState();

    textController = new TextEditingController();

    if (filter != null) {
      textController.text = filter;
      keys = getKeys(filter);
    }

    books = [];
    bookSubscription = Firestore.instance
        .collection('bookrecords')
        .where("users", arrayContains: widget.currentUser.id)
        .snapshots()
        .listen((snap) async {
      // Update list of document snapshots
      books = snap.documents;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    textController.dispose();
    bookSubscription.cancel();
    super.dispose();
  }

  _ShowBooksWidgetState({this.currentUser, this.filter});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title: Text(S.of(context).mybooksTitle,
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
                    //decoration: BoxDecoration(color: Colors.transparent),
                    color: Colors.transparent,
                    padding: new EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 15.0, right: 5.0),
                    child: new Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        new Expanded(
                          child: Theme(
                              data: ThemeData(platform: TargetPlatform.android),
                              child: TextField(
                                onChanged: (_) {
                                  setState(() {
                                    showClearFilters = false;
                                  });
                                },
                                onSubmitted: (value) {
                                  setState(() {
                                    showClearFilters = true;
                                    keys = getKeys(textController.text);
                                  });
                                },
                                maxLines: 1,
                                controller: textController,
                                style: Theme.of(context).textTheme.title,
                                decoration: InputDecoration(
                                  //border: InputBorder.none,
                                  hintText: S.of(context).hintAuthorTitle,
                                  hintStyle: C.hints.apply(color: C.inputHints),
                                ),
                              )),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 0.0),
                            child: IconButton(
                              color: Colors.white,
                              icon: showClearFilters
                                  ? assetIcon(clear_filters_100, size: 30)
                                  : assetIcon(search_100, size: 30),
                              onPressed: () {
                                if (showClearFilters) {
                                  textController.text = '';
                                  showClearFilters = false;
                                } else if (textController.text.isNotEmpty) {
                                  showClearFilters = true;
                                }

                                FocusScope.of(context).unfocus();
                                setState(() {
                                  keys = getKeys(textController.text);
                                });
                              },
                            )),
                      ],
                    ),
                  ),
                  new Container(
                      color: Colors.transparent,
                      padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                          //mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new Expanded(
                                child: new Wrap(
                                    alignment: WrapAlignment.start,
                                    spacing: 2.0,
                                    runSpacing: 0.0,
                                    children: <Widget>[
                                  FilterChip(
                                    //avatar: icon,
                                    label: Text(S.of(context).chipMyBooks),
                                    selected: own,
                                    onSelected: (bool s) {
                                      setState(() {
                                        own = s;
                                      });
                                    },
                                  ),
                                  FilterChip(
                                    //avatar: icon,
                                    label: Text(S.of(context).chipLent),
                                    selected: lent,
                                    onSelected: (bool s) {
                                      setState(() {
                                        lent = s;
                                      });
                                    },
                                  ),
                                  FilterChip(
                                    //avatar: icon,
                                    label: Text(S.of(context).chipBorrowed),
                                    selected: borrowed,
                                    onSelected: (bool s) {
                                      setState(() {
                                        borrowed = s;
                                      });
                                    },
                                  ),
                                  FilterChip(
                                    //avatar: icon,
                                    label: Text(S.of(context).chipWish),
                                    selected: wish,
                                    onSelected: (bool s) {
                                      setState(() {
                                        wish = s;
                                      });
                                    },
                                  ),
                                  FilterChip(
                                    //avatar: icon,
                                    label: Text(S.of(context).chipTransit),
                                    selected: transit,
                                    onSelected: (bool s) {
                                      setState(() {
                                        transit = s;
                                      });
                                    },
                                  ),
                                ]))
                          ]))
                ])),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight: 200,
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          Bookrecord rec = new Bookrecord.fromJson(books[index].data);

          if (own && rec.isOwn(widget.currentUser.id) ||
              wish && rec.isWish(widget.currentUser.id) ||
              lent && rec.isLent(widget.currentUser.id) ||
              borrowed && rec.isBorrowed(widget.currentUser.id) ||
              transit && rec.isTransit(widget.currentUser.id)) {
            return new MyBook(
                bookrecord: rec, currentUser: widget.currentUser, filter: keys);
          } else {
            return Container(height: 0.0, width: 0.0);
          }
        }, childCount: books.length),
      )
    ]);
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

  // Flag to show book settings controls
  bool settings = false;

  // Text editor Controllers for settings
  TextEditingController _linkTextCtr;
  String _linkError;

  TextEditingController _priceTextCtr;
  String _priceError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(MyBook oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.filter != widget.filter) {
      setState(() {
        filter = widget.filter;
      });
    }

    if (oldWidget.bookrecord.id != widget.bookrecord.id) {
      if (mounted)
        setState(() {
          bookrecord = widget.bookrecord;
        });
    }
  }

  @override
  void dispose() {
    if (_linkTextCtr != null) _linkTextCtr.dispose();
    if (_priceTextCtr != null) _priceTextCtr.dispose();

    super.dispose();
  }

  _MyBookWidgetState(
      {Key key, @required this.bookrecord, @required this.filter});

  Future<void> deleteBook(BuildContext context) async {
    try {
      //Delete book record in Firestore database
      bookrecord.ref.delete();
      showSnackBar(context, S.of(context).bookDeleted);

      // Update book with counter for copies/wishes
      await Book.Ref(bookrecord.isbn).updateData(
          {(bookrecord.wish ? 'wishes' : 'copies'): FieldValue.increment(-1)});
    } catch (ex, stack) {
      print(
          'Bookrecord delete failed for [${bookrecord.id}, ${widget.currentUser.id}]: ' +
              ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookrecord?.isbn == null || !bookrecord.keys.containsAll(filter))
      return Container(height: 0.0, width: 0.0);
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
                          bookImage(bookrecord, 80, padding: 5.0),
                          Expanded(
                            child: Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        child: Text(
                                            bookrecord.authors.join(', '),
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption)),
                                    Container(
                                        child: Text(bookrecord.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle)),
                                    // Show price without fee for the book owners
                                    Container(
                                        child: Text(
                                            S.of(context).bookPrice(widget
                                                            .currentUser.id ==
                                                        bookrecord.ownerId &&
                                                    !bookrecord.wish
                                                ? money(bookrecord.getPrice())
                                                : money(total(
                                                    bookrecord.getPrice()))),
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body1)),
                                    // Show income without system fee for book owners
                                    Container(
                                        child: Text(
                                            S.of(context).bookRent(widget
                                                            .currentUser.id ==
                                                        bookrecord.ownerId &&
                                                    !bookrecord.wish
                                                ? money(income(
                                                    bookrecord.getPrice()))
                                                : money(monthly(
                                                    bookrecord.getPrice()))),
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body1)),
                                    widget.currentUser.id != bookrecord.ownerId
                                        ? Container(
                                            child: Text(
                                                S.of(context).bookOwner(
                                                    bookrecord.ownerName),
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1))
                                        : Container(width: 0.0, height: 0.0),
                                    Container(
                                        margin: EdgeInsets.only(top: 10.0),
                                        child: bookCardText()),
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
                        // Chat button for transit
                        bookrecord.isTransit(widget.currentUser.id)
                            ? new IconButton(
                                onPressed: () async {
                                  // Open chat widget
                                  Chat.runChatById(
                                      context, widget.currentUser, null,
                                      chatId: bookrecord.chatId);
                                },
                                tooltip: S.of(context).deleteShelf,
                                icon: assetIcon(communication_100, size: 30),
                              )
                            : Container(),
                        // Search button for the wishes
                        bookrecord.isWish(widget.currentUser.id)
                            ? new IconButton(
                                //TODO: Search wished book
                                onPressed: () {},
                                tooltip: S.of(context).hintChatOpen,
                                icon: assetIcon(search_100, size: 25),
                              )
                            : Container(),
                        // Button to return book only it it's borrowed
                        bookrecord.isBorrowed(widget.currentUser.id)
                            ? new IconButton(
                                onPressed: () async {
                                  Messages chat = await getChatAndTransit(
                                      context: context,
                                      currentUserId: widget.currentUser.id,
                                      from: widget.currentUser.id,
                                      to: bookrecord.ownerId,
                                      bookrecordId: bookrecord.id);

                                  // Open chat widget
                                  Chat.runChat(
                                      context, widget.currentUser, null,
                                      message: S
                                          .of(context)
                                          .requestReturn(bookrecord.title),
                                      chat: chat);
                                },
                                tooltip: S.of(context).hintReturn,
                                icon: assetIcon(return_100, size: 25),
                              )
                            : Container(),
                        // Button to return book only it it's lent
                        bookrecord.isLent(widget.currentUser.id)
                            ? new IconButton(
                                onPressed: () async {
                                  Messages chat = await getChatAndTransit(
                                      context: context,
                                      currentUserId: widget.currentUser.id,
                                      from: bookrecord.holderId,
                                      to: widget.currentUser.id,
                                      bookrecordId: bookrecord.id);

                                  print(
                                      '!!!DEBUG: Chat status ${chat.status} ${bookrecord.id}');
                                  // Open chat widget
                                  Chat.runChat(
                                      context, widget.currentUser, null,
                                      message: S
                                          .of(context)
                                          .requestReturnByOwner(
                                              bookrecord.title),
                                      chat: chat);
                                },
                                tooltip: S.of(context).hintRequestReturn,
                                icon: assetIcon(return_100, size: 25),
                              )
                            : Container(),
                        // Delete button only for OWN book and WISH
                        bookrecord.isWish(widget.currentUser.id) ||
                                bookrecord.isOwn(widget.currentUser.id)
                            ? new IconButton(
                                //TODO: Delete book/wish
                                onPressed: () => deleteBook(context),
                                tooltip: S.of(context).hintDeleteBook,
                                icon: assetIcon(trash_100, size: 25),
                              )
                            : Container(),
                        // Setting only for OWN books
                        bookrecord.isOwn(widget.currentUser.id)
                            ? new IconButton(
                                //TODO: Add setting screen for a book
                                onPressed: () {
                                  if (!settings) {
                                    if (_linkTextCtr == null)
                                      _linkTextCtr =
                                          new TextEditingController();

                                    if (_priceTextCtr == null)
                                      _priceTextCtr =
                                          new TextEditingController();

                                    // Set price and link
                                    double price = bookrecord.price;
                                    if (price == null || price == 0.0)
                                      price = bookrecord.getPrice();
                                    _priceTextCtr.text =
                                        dp(toCurrency(price), 2).toString();

                                    setState(() {
                                      settings = true;
                                    });
                                  } else {
                                    setState(() {
                                      settings = false;
                                    });
                                  }
                                },
                                tooltip: S.of(context).hintBookDetails,
                                icon: assetIcon(settings_100, size: 25),
                              )
                            : Container(),
                        // Sharing button for everything
                        new IconButton(
                          //TODO: Modify dynamic link to point to seach screen for
                          // particular book
                          onPressed: () async {
                            String link;
                            // For own books share link to particular book
                            // For other books link to search this book in Biblosphere
                            if (bookrecord.isOwn(widget.currentUser.id))
                              link = await buildLink(
                                  'chat?ref=${widget.currentUser.id}&book=${bookrecord.id}',
                                  image: bookrecord.image,
                                  title: S.of(context).sharingMotto);
                            else
                              link = await buildLink(
                                  'search?ref=${widget.currentUser.id}&isbn=${bookrecord.isbn}',
                                  image: bookrecord.image,
                                  title: S.of(context).sharingMotto);

                            // Share link to the book
                            Share.share(link);
                          },
                          tooltip: S.of(context).hintShareBook,
                          icon: assetIcon(share_100, size: 27),
                        ),
                      ],
                    ),
                  ),
                  settings
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              bookrecord.image == null ||
                                      bookrecord.image.isEmpty
                                  ? Container(
                                      padding: EdgeInsets.only(
                                          left: 12.0, right: 12.0, top: 10.0),
                                      child: Text(S.of(context).bookImageLabel))
                                  : Container(),
                              bookrecord.image == null ||
                                      bookrecord.image.isEmpty
                                  ? new Container(
                                      padding: EdgeInsets.only(
                                          left: 12.0,
                                          right: 12.0,
                                          bottom: 10.0),
                                      child: Theme(
                                          data: ThemeData(
                                              platform: TargetPlatform.android),
                                          child: TextField(
                                            onSubmitted: (value) async {
                                              if (!Uri.parse(value)
                                                  .isAbsolute) {
                                                setState(() {
                                                  _linkError = S
                                                      .of(context)
                                                      .wrongImageUrl;
                                                });
                                              } else {
                                                bookrecord.image = value;
                                                setState(() {
                                                  _linkError = null;
                                                });

                                                await Book.Ref(bookrecord.isbn)
                                                    .updateData({
                                                  'image': value,
                                                  'userImage': true
                                                });

                                                await bookrecord.ref
                                                    .updateData({
                                                  'image': value,
                                                });
                                              }
                                            },
                                            maxLines: 1,
                                            controller: _linkTextCtr,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body1,
                                            decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.all(2.0),
                                                hintText:
                                                    S.of(context).imageLinkHint,
                                                errorText: _linkError),
                                          )),
                                    )
                                  : Container(),
                              Container(
                                  padding: EdgeInsets.only(
                                      left: 12.0, right: 12.0, top: 10.0),
                                  child: Text(S.of(context).bookPriceLabel)),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 12.0, right: 12.0, bottom: 10.0),
                                child: Theme(
                                    data: ThemeData(
                                        platform: TargetPlatform.android),
                                    child: TextField(
                                      onSubmitted: (value) async {
                                        if (_priceTextCtr.text == null ||
                                            _priceTextCtr.text.isEmpty) {
                                          setState(() {
                                            _priceError =
                                                S.of(context).emptyAmount;
                                          });
                                          return;
                                        }

                                        double amount =
                                            double.tryParse(_priceTextCtr.text);

                                        if (amount == null || amount <= 0.0) {
                                          setState(() {
                                            _priceError =
                                                S.of(context).negativeAmount;
                                          });
                                          return;
                                        }

                                        if (_priceError != null)
                                          _priceError = null;

                                        FocusScope.of(context).unfocus();

                                        setState(() {
                                          bookrecord.price =
                                              dp(toXlm(amount), 5);
                                        });

                                        bookrecord.ref.updateData(
                                            {'price': bookrecord.price});
                                      },
                                      maxLines: 1,
                                      controller: _priceTextCtr,
                                      style: Theme.of(context).textTheme.body1,
                                      decoration: InputDecoration(
                                          prefix: Text(
                                              currencySymbol[preferredCurrency],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body1),
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(2.0),
                                          hintText: S.of(context).bookPriceHint,
                                          errorText: _priceError),
                                    )),
                              )
                            ])
                      : Container(),
                ],
              ),
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              margin: EdgeInsets.all(2.0)),
          margin:
              EdgeInsets.only(top: 5.0, bottom: 0.0, left: 0.0, right: 0.0));
  }

  Widget bookCardText() {
    switch (bookrecord.type(widget.currentUser.id)) {
      case BookrecordType.own:
        return Text(S.of(context).youHaveThisBook,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.wish:
        return Text(S.of(context).youWishThisBook,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.lent:
        return Text(S.of(context).youLentThisBook(bookrecord.holderName),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.borrowed:
        return Text(S.of(context).youBorrowThisBook,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.body1);
      case BookrecordType.transit:
        return Text(S.of(context).youTransitThisBook,
            overflow: TextOverflow.ellipsis,
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
  StreamSubscription<QuerySnapshot> operationsSubscription;
  List<DocumentSnapshot> operations = [];

  @override
  void initState() {
    super.initState();

    operations = [];
    operationsSubscription = Firestore.instance
        .collection('operations')
        .where("users", arrayContains: widget.currentUser.id)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) async {
      // Update list of document snapshots
      operations = snap.documents;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    operationsSubscription.cancel();

    super.dispose();
  }

  _FinancialWidgetState({
    Key key,
    @required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title: Text(
            S.of(context).financeTitle(money(currentUser?.getAvailable())),
            style: Theme.of(context).textTheme.title.apply(color: C.titleText)),
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
                      child: new Wrap(children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: FilterChip(
                              //avatar: icon,
                              label: Text(S.of(context).chipPayin),
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
                              label: Text(S.of(context).chipPayout),
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
                              label: Text(S.of(context).chipLeasing),
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
                              label: Text(S.of(context).chipReward),
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
                              label: Text(S.of(context).chipReferrals),
                              selected: showRef,
                              onSelected: (bool s) {
                                setState(() {
                                  showRef = s;
                                });
                              },
                            )),
                      ]))
                ])),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight: 160,
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          Operation op = new Operation.fromJson(operations[index].data);

          if (op.isIn(currentUser) && showIn ||
              op.isLeasing(currentUser) && showLeasing ||
              op.isReward(currentUser) && showRewards ||
              op.isReferral(currentUser) && showRewards ||
              op.isOut(currentUser) && showOut) {
            return MyOperation(operation: op, currentUser: currentUser);
          } else {
            return Container(height: 0.0, width: 0.0);
          }
        }, childCount: operations.length),
      )
    ]);
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
                    Expanded(
                        child: Text(S.of(context).opLeasing,
                            overflow: TextOverflow.ellipsis)), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(
                            DateFormat('MMMd').format(operation.date))), // Date
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
                    Expanded(
                        child: Text(S.of(context).opReward,
                            overflow: TextOverflow.ellipsis)), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(
                            DateFormat('MMMd').format(operation.date))), // Date
                  ]),
              Text('+${money(operation.amount)}'), // Amount
            ])))
      ]));
    } else if (operation.isInPurchase(currentUser)) {
      return new Container(
          child: Row(children: <Widget>[
        Container(
            margin: EdgeInsets.all(3.0),
            child: assetIcon(bank_cards_100, size: 25)),
        Expanded(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).opInAppPurchase,
                            overflow: TextOverflow.ellipsis)), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(
                            DateFormat('MMMd').format(operation.date))), // Date
                  ]),
              Text('+${money(operation.amount)}'), // Amount
            ])))
      ]));
    } else if (operation.isInStellar(currentUser)) {
      return new Container(
          child: Row(children: <Widget>[
        Container(
            margin: EdgeInsets.all(3.0),
            child: assetIcon(wallet_100, size: 25)),
        Expanded(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).opInStellar,
                            overflow: TextOverflow.ellipsis)), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(
                            DateFormat('MMMd').format(operation.date))), // Date
                  ]),
              Text('+${money(operation.amount)}'), // Amount
            ])))
      ]));
    } else if (operation.isOutStellar(currentUser)) {
      return new Container(
          child: Row(children: <Widget>[
        Container(
            margin: EdgeInsets.all(3.0),
            child: assetIcon(receive_cash_100, size: 25)),
        Expanded(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        child: Text(S.of(context).opOutStellar,
                            overflow: TextOverflow.ellipsis)), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(
                            DateFormat('MMMd').format(operation.date))), // Date
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
                    Expanded(
                        child: Text(S.of(context).opReferral,
                            overflow: TextOverflow.ellipsis)), // Description
                    Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Text(
                            DateFormat('MMMd').format(operation.date))), // Date
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
        DocumentSnapshot bookSnap = await Book.Ref(operation.isbn).get();
        if (!bookSnap.exists)
          throw "Book missing in db: isbn ${operation.isbn}, operation ${operation.id}";

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
                              Clipboard.setData(
                                  new ClipboardData(text: currentUser.link));
                              //Navigator.pop(context);
                              showSnackBar(context, S.of(context).linkCopied);
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

                            return new UserWidget(
                                user: user,
                                builder: (context, user) {
                                  return Container(
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(user.name), // Description
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        right: 10.0),
                                                    child: Text(money(user
                                                        .feeShared))), // Date
                                              ]),
                                          Text(S.of(context).userBalance(money(
                                              user.getAvailable()))), // Amount
                                        ])))
                                  ]));
                                });
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
  TextEditingController payoutMemoCtr;
  String _accountErrorText;
  String _amountErrorText;

  @override
  void initState() {
    super.initState();

    payoutTextCtr = new TextEditingController();
    if (currentUser.payoutId != null) payoutTextCtr.text = currentUser.payoutId;
    payoutMemoCtr = new TextEditingController();
    amountTextCtr = new TextEditingController();
  }

  @override
  void dispose() {
    payoutTextCtr.dispose();
    payoutMemoCtr.dispose();
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
                                          child:
                                              assetIcon(coins_100, size: 20)),
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
                                showSnackBar(context, S.of(context).linkCopied);
                              },
                              child: Text(currentUser.link,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .apply(
                                          decoration:
                                              TextDecoration.underline)));
                        })),
                    Container(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text(S.of(context).displayCurrency)),
                    Container(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: DropdownButton(
                        isExpanded: true,
                        isDense: true,
                        hint: Text(S
                            .of(context)
                            .selectDisplayCurrency), // Not necessary for Option 1
                        value: preferredCurrency,
                        onChanged: (newValue) {
                          setState(() {
                            preferredCurrency = newValue;
                          });
                          // Update preferred currency for user
                          currentUser.ref.updateData({'currency': newValue});
                        },
                        items: currencySymbol.entries.map((entry) {
                          return DropdownMenuItem(
                            child: new Text(
                              entry.key,
                              style: Theme.of(context).textTheme.body1,
                            ),
                            value: entry.key,
                          );
                        }).toList(),
                      ),
                    ),
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
                                    text: biblosphereAccountId));
                                //Navigator.pop(context);
                                showSnackBar(
                                    context, S.of(context).accountCopied);
                              },
                              child: Text(biblosphereAccountId,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .apply(
                                          decoration:
                                              TextDecoration.underline)));
                        })),
                    Text(S.of(context).inputStellarMemo),
                    new Container(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Builder(
                            // Create an inner BuildContext so that the onPressed methods
                            // can refer to the Scaffold with Scaffold.of().
                            builder: (BuildContext context) {
                          return InkWell(
                              onTap: () {
                                Clipboard.setData(
                                    new ClipboardData(text: currentUser.id));
                                //Navigator.pop(context);
                                showSnackBar(context, S.of(context).memoCopied);
                              },
                              child: Text(currentUser.id,
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
                                  _accountErrorText =
                                      S.of(context).wrongAccount;
                                });
                              else
                                setState(() {
                                  _accountErrorText = null;
                                });

                              currentUser.payoutId = value;
                              await currentUser.ref
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
                    Text(S.of(context).outputStellarMemo),
                    new Container(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Theme(
                          data: ThemeData(platform: TargetPlatform.android),
                          child: TextField(
                            maxLines: 1,
                            controller: payoutMemoCtr,
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
                                            hintText: S.of(context).hintNotMore(
                                                money(currentUser
                                                    .getAvailable())),
                                            errorText: _amountErrorText),
                                      )))),
                          RaisedButton(
                              onPressed: () async {
                                try {
                                  if (!await checkStellarAccount(
                                      currentUser.payoutId)) {
                                    setState(() {
                                      _accountErrorText =
                                          S.of(context).wrongAccount;
                                    });
                                    return;
                                  }
                                  if (amountTextCtr.text == null ||
                                      amountTextCtr.text.isEmpty) {
                                    setState(() {
                                      _amountErrorText =
                                          S.of(context).emptyAmount;
                                    });
                                    return;
                                  }

                                  double amount =
                                      double.tryParse(amountTextCtr.text);

                                  if (amount == null || amount <= 0.0) {
                                    setState(() {
                                      _amountErrorText =
                                          S.of(context).negativeAmount;
                                    });
                                    return;
                                  }

                                  if (toXlm(amount) >
                                      currentUser.getAvailable()) {
                                    setState(() {
                                      _amountErrorText =
                                          S.of(context).exceedAmount;
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
                                  amount = dp(toXlm(amount), 5);

                                  await payoutStellar(currentUser, amount,
                                      memo: payoutMemoCtr.text);

                                  showSnackBar(
                                      context, S.of(context).successfulPayment);
                                } catch (ex) {
                                  // TODO: Log event for administrator to investigate
                                  showSnackBar(
                                      context, S.of(context).paymentError);
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
        child: ListView(children: <Widget>[
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text('Как брать книги',
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(
              'Найдите книгу, которую Вы хотите почитать, и напишите её хозяину, '
              'чтобы договориться о встрече. При получении книг вам нужно будет оплатить депозит. '
              'Вы можете пополнить свой баланс по карточке или криптовалютой Stellar, а '
              'можете заработать в Библосфере, давая свои книги почитать. Вы также можете зарабатывать '
              'через партнёрскую программу, приглашая других участников.',
              style: Theme.of(context).textTheme.body1)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text('Пополнение счёта',
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(
              'Пополнить счёт можно двумя способами: через покупку в приложении по карточке, '
              'зарегистрированной в Google Play или App Store. Или сделать перевод криптовалюты '
              'Stellar (XLM) на счёт, указанный в настройках.',
              style: Theme.of(context).textTheme.body1)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text('Партнёрская программа',
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(
              'Организуйте обмен книгами через Библосферу в своём сообществе или '
              'офисе и получайте комиссию за каждую сделку. Для этого поделитесь с друзьями и '
              'коллегами ссылкой на приложение (Вашей партнёрской ссылкой).',
              style: Theme.of(context).textTheme.body1)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text('Вывод средств',
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(
              'Если у Вас большой баланс в Библосфере, Вы можете вывести эти средства. '
              'Вывести средства можно на свой кошелёк Stellar или через Stellar на любой кошелёк, карту или счёт. '
              'Для вывода на карту или кошелёк воспользуйстесь услугами online-обменников.',
              style: Theme.of(context).textTheme.body1)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text('Чат-бот Библосферы',
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
                text:
                    'Во вкладке Сообщения есть чат с ботом Библосферы, он может ответить на любые вопросы о '
                    'приложении. Если понадобится связаться напрямую со мной, пишите в telegram ',
                style: Theme.of(context).textTheme.body1,
                children: [
                  TextSpan(
                      text: '+995599002198',
                      style: Theme.of(context).textTheme.body1.apply(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          const url = 'https://t.me/DenisStark77';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch url $url';
                          }
                        })
                ]),
          )),
      Container(
          margin: EdgeInsets.fromLTRB(8.0, 8.0, 30.0, 8.0),
          alignment: Alignment.topRight,
          child: Text('Денис Старк', style: Theme.of(context).textTheme.body1)),
    ]));
  }
}
