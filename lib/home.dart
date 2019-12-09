import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_ui/flutter_firebase_ui.dart';
//import 'package:firebase_ui/utils.dart';
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
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/lifecycle.dart';
import 'package:biblosphere/payments.dart';
import 'package:biblosphere/books.dart';
import 'package:biblosphere/chat.dart';
import 'package:biblosphere/l10n.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  StreamSubscription<List<PurchaseDetails>> _subscription;

  _MyHomePageState({
    Key key,
  });

  @override
  void initState() {
    super.initState();

    assert(B.user != null);
    initDynamicLinks();

    // TODO: Didn't work on WEB
    if (!kIsWeb) {
      // Listen to in-app purchases update
      final Stream purchaseUpdates =
          InAppPurchaseConnection.instance.purchaseUpdatedStream;
      _subscription = purchaseUpdates.listen((purchases) {
        List<PurchaseDetails> details = purchases;

        // TODO: Redesign to accept multiple payments. It won't work in parallel.
        details.forEach((purchase) async {
          if (purchase.status == PurchaseStatus.purchased) {
            // Get product
            final ProductDetailsResponse response =
                await InAppPurchaseConnection.instance
                    .queryProductDetails({purchase.productID});

            if (!response.notFoundIDs.isEmpty) {
              // TODO: Process this more nicely
              throw ('Ids of in-app products not available');
            }

            ProductDetails p = response.productDetails.first;

            double amount = 0.0;
            if (Theme.of(context).platform == TargetPlatform.android) {
              amount = toXlm(p.skuDetail.priceAmountMicros / 1000000, currency: p.skuDetail.priceCurrencyCode);
            } else if (Theme.of(context).platform == TargetPlatform.iOS) {
              amount = toXlm(double.parse(p.skProduct.price), currency: p.skProduct.priceLocale.currencyCode);
            }

            // Create an operation and update user balance
            await payment(
                user: B.user, amount: amount, type: OperationType.InputInApp);

            logAnalyticsEvent(
                name: 'ecommerce_purchase',
                parameters: <String, dynamic>{
                  'amount': amount,
                  'channel': 'in-app',
                  'user': B.user.id,
                });
          } else if (purchase.status == PurchaseStatus.error) {
            showSnackBar(context, 'Purchase error: ${purchase.error.details}');
            print(
                '!!!DEBUG purchases error:  ${purchase.error.code} ${purchase.error.details} ${purchase.error.message}  ${purchase.error.source}');
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();

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
      if (userId == B.user.id) {
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
                    new ShowBooksWidget(filter: filter),
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
          if (B.user.beneficiary1 == null) {
            B.user.beneficiary1 = ref.id;
            B.user.feeShared = 0;
            B.user.beneficiary2 = ref.beneficiary1;

            // Update  beneficiary1, beneficiary2, feeShared
            B.user.ref.updateData(B.user.toJson());

            logAnalyticsEvent(
                name: 'referral_set',
                parameters: <String, dynamic>{
                  'user': B.user.id,
                  'surerior': ref.id,
                });
          }
        }

        // If user or ref defined go to user chat
        if (user != null) {
          Messages chat = Messages(from: user, to: B.user);

          // Open chat widget
          Chat.runChat(context, user, chat: chat, transit: bookrecordId);
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
                      context, null, new FindBookWidget(filter: book.title),
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
              context, book, B.user, wish, await currentLocation(),
              snackbar: false);

          // Open My Book Screen with filter
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => buildScaffold(
                      context,
                      S.of(context).mybooksTitle,
                      new ShowBooksWidget(filter: book.title),
                      appbar: false)));
        } else {
          // TODO: report missing book in the link
        }
      } else {
        // TODO: report broken link: bookId is null
      }
    } else if (deepLink.path == "/support") {
      String message = deepLink.queryParameters['msg'];
      Messages chat = Messages(from: B.user, system: true);

      Chat.runChat(context, null, chat: chat, message: message, send: true);
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
            new IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => buildScaffold(
                            context,
                            S.of(context).titleMessages,
                            new ChatListWidget())));
              },
              tooltip: S.of(context).hintChatOpen,
              icon: assetIcon(communication_100, size: 30),
            ),
/*
          Container(
              margin: EdgeInsets.only(right: 10.0, left: 10.0),
              child: FlatButton(
                child: Row(children: <Widget>[
                  new Container(
                      margin: EdgeInsets.only(right: 5.0),
                      child: assetIcon(coins_100, size: 25)),
                  new Text(money(B.wallet.getAvailable()),
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .apply(color: C.titleText))
                ]),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => buildScaffold(
                              context,
                              S.of(context).financeTitle(
                                  money(B.wallet.getAvailable())),
                              new FinancialWidget(),
                              appbar: false)));
                },
                padding: EdgeInsets.all(0.0),
              )),
*/
/*
            new IconButton(
              onPressed: () async {
              // Convert CHAT ids
              QuerySnapshot snap = await Firestore.instance.collection('messages')
                  //.where('toName', isEqualTo: 'Женя Старк')
                  .getDocuments();
              await Future.forEach(snap.documents, (DocumentSnapshot doc) async {
                Messages chat = Messages.fromJson(doc.data, doc);

                if( chat.fromId != null && chat.toId != null || chat.system && chat.fromId != null )
                  return;

                if( chat.ids == null || chat.ids[0] == null || chat.ids[1] == null)
                  return;

                chat.fromId = chat.ids[0]; 
                chat.toId = chat.ids[1];

                await doc.reference.updateData({'fromId': chat.fromId, 'toId': chat.toId, 
                'fromName': null, 'fromImage': null, 
                'toName': null, 'toImage': null
                });
              });
                QuerySnapshot snap = await Firestore.instance
                    .collection('noisbn')
                    //.where('fromId', isEqualTo: 'oyYUDByQGVdgP13T1nyArhyFkct1')
                    .getDocuments();
                await Future.forEach(snap.documents,
                    (DocumentSnapshot doc) async {
                  String isbn = doc.data['isbn'];

                  await Firestore.instance
                      .collection('noisbn')
                      .document(isbn)
                      .setData({'isbn': isbn});

                  await Firestore.instance
                      .collection('noisbn')
                      .document(doc.documentID)
                      .delete();
                });

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
              },
              tooltip: S.of(context).settings,
              icon: assetIcon(settings_100, size: 30),
            ),
 */
          ],
          title: new Text(S.of(context).title,
              style:
                  Theme.of(context).textTheme.title.apply(color: C.titleText)),
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
                        onTap: () async {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => buildScaffold(
                                      context,
                                      S.of(context).addbookTitle,
                                      new AddBookWidget(),
                                      appbar: false)));
                          refreshLocation(context);
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
                    onTap: () async {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => buildScaffold(
                                  context,
                                  S.of(context).findbookTitle,
                                  new FindBookWidget(),
                                  appbar: false)));
                      refreshLocation(context);
                    },
                    child: new Card(
                      child: new Container(
                        padding: new EdgeInsets.all(10.0),
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                width: 60, child: Image.asset(search_100)),
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
                                  new ShowBooksWidget(),
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
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            userPhoto(B.user, 90),
                            Expanded(
                                child: Container(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 5.0),
                                              child: Text(B.user.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .title
                                                      .apply(
                                                          color: C.titleText))),
                                          Row(children: <Widget>[
                                            new Container(
                                                margin:
                                                    EdgeInsets.only(right: 5.0),
                                                child: assetIcon(coins_100,
                                                    size: 20)),
                                            new Text(
                                                money(B.wallet.getAvailable()),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1
                                                    .apply(color: C.titleText))
                                          ]),
                                        ]))),
                          ]),
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
                                  Clipboard.setData(
                                      new ClipboardData(text: B.user.link));
                                  //Navigator.pop(context);
                                  showSnackBar(
                                      context, S.of(context).linkCopied);

                                  logAnalyticsEvent(
                                      name: 'share',
                                      parameters: <String, dynamic>{
                                        'type': 'link',
                                        'screen': 'drawer',
                                        'user': B.user.id,
                                      });
                                },
                                child: Text(B.user.link,
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
                          builder: (context) => buildScaffold(
                              context,
                              S.of(context).titleMessages,
                              new ChatListWidget())));
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
                              new SettingsWidget())));
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
                              S
                                  .of(context)
                                  .financeTitle(money(B.wallet.getAvailable())),
                              new FinancialWidget(),
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
                              new ReferralWidget())));
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
        ));
  }
}

// Class to show my books (own, wishlist and borrowed/lent)
class ShowBooksWidget extends StatefulWidget {
  ShowBooksWidget({Key key, this.filter}) : super(key: key);

  final String filter;

  @override
  _ShowBooksWidgetState createState() =>
      new _ShowBooksWidgetState(filter: filter);
}

class _ShowBooksWidgetState extends State<ShowBooksWidget> {
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
        .where("users", arrayContains: B.user.id)
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

  _ShowBooksWidgetState({this.filter});

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

          if (own && rec.isOwn ||
              wish && rec.isWish ||
              lent && rec.isLent ||
              borrowed && rec.isBorrowed ||
              transit && rec.isTransit) {
            return new MyBook(bookrecord: rec, filter: keys);
          } else {
            return Container(height: 0.0, width: 0.0);
          }
        }, childCount: books.length),
      )
    ]);
  }
}

class MyBook extends StatefulWidget {
  MyBook({Key key, @required this.bookrecord, this.filter = const {}})
      : super(key: key);

  final Bookrecord bookrecord;
  final Set<String> filter;

  @override
  _MyBookWidgetState createState() =>
      new _MyBookWidgetState(bookrecord: bookrecord, filter: filter);
}

class _MyBookWidgetState extends State<MyBook> {
  Bookrecord bookrecord;
  StreamSubscription<Bookrecord> _listener;
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
    _listener = bookrecord.snapshots().listen((rec) {
      setState(() {});
    });

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
    if (_listener != null) _listener.cancel();

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
      print('Bookrecord delete failed for [${bookrecord.id}, ${B.user.id}]: ' +
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
                                    B.user.id == bookrecord.ownerId &&
                                            !bookrecord.wish
                                        ? Container(
                                            child: Text(
                                                S.of(context).bookPrice(money(
                                                    bookrecord.getPrice())),
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1))
                                        : Container(),
                                    // Show income for lent books
                                    bookrecord.isLent
                                        ? Container(
                                            child: Text(
                                                S.of(context).bookIncome(money(
                                                    income(bookrecord
                                                        .getPrice()))),
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1))
                                        : Container(),
                                    // Show rent for borrowed books
                                    bookrecord.isBorrowed
                                        ? Container(
                                            child: Text(
                                                S.of(context).bookRent(money(
                                                    monthly(bookrecord
                                                        .getPrice()))),
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body1))
                                        : Container(),
                                    B.user.id != bookrecord.ownerId
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
                        bookrecord.isTransit
                            ? new IconButton(
                                onPressed: () async {
                                  // Open chat widget
                                  Chat.runChatById(context, null,
                                      chatId: bookrecord.chatId);
                                },
                                tooltip: S.of(context).hintChatOpen,
                                icon: assetIcon(communication_100, size: 30),
                              )
                            : Container(),
                        // Search button for the wishes
                        bookrecord.isWish
                            ? new IconButton(
                                //TODO: Search wished book
                                onPressed: () {},
                                tooltip: S.of(context).hintChatOpen,
                                icon: assetIcon(search_100, size: 25),
                              )
                            : Container(),
                        // Button to return book only it it's borrowed
                        bookrecord.isBorrowed
                            ? new IconButton(
                                onPressed: () async {
                                  Messages chat = new Messages(
                                      from: B.user, to: bookrecord.owner);

                                  // Open chat widget
                                  Chat.runChat(context, null,
                                      chat: chat,
                                      message: S
                                          .of(context)
                                          .requestReturn(bookrecord.title),
                                      transit: bookrecord.id);
                                },
                                tooltip: S.of(context).hintReturn,
                                icon: assetIcon(return_100, size: 25),
                              )
                            : Container(),
                        // Button to return book only it it's lent
                        bookrecord.isLent
                            ? new IconButton(
                                onPressed: () async {
                                  Messages chat = new Messages(
                                      from: bookrecord.holder, to: B.user);

                                  // Open chat widget
                                  Chat.runChat(context, null,
                                      chat: chat,
                                      message: S
                                          .of(context)
                                          .requestReturnByOwner(
                                              bookrecord.title),
                                      transit: bookrecord.id);
                                },
                                tooltip: S.of(context).hintRequestReturn,
                                icon: assetIcon(return_100, size: 25),
                              )
                            : Container(),
                        // Delete button only for OWN book and WISH
                        bookrecord.isWish || bookrecord.isOwn
                            ? new IconButton(
                                onPressed: () => deleteBook(context),
                                tooltip: S.of(context).hintDeleteBook,
                                icon: assetIcon(trash_100, size: 25),
                              )
                            : Container(),
                        // Setting only for OWN books
                        bookrecord.isOwn
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
                            if (bookrecord.isOwn)
                              link = await buildLink(
                                  'chat?ref=${B.user.id}&book=${bookrecord.id}',
                                  image: bookrecord.image,
                                  title: S.of(context).sharingMotto);
                            else
                              link = await buildLink(
                                  'search?ref=${B.user.id}&isbn=${bookrecord.isbn}',
                                  image: bookrecord.image,
                                  title: S.of(context).sharingMotto);

                            // Share link to the book
                            Share.share(link);

                            logAnalyticsEvent(
                                name: 'share',
                                parameters: <String, dynamic>{
                                  'type': 'share',
                                  'isbn': bookrecord.isbn,
                                  'user': B.user.id,
                                });
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

                                                showSnackBar(
                                                    context,
                                                    S
                                                        .of(context)
                                                        .snackBookImageChanged);

                                                logAnalyticsEvent(
                                                    name: 'book_image_set',
                                                    parameters: <String,
                                                        dynamic>{
                                                      'isbn': bookrecord.isbn,
                                                      'user': B.user.id,
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

                                        showSnackBar(
                                            context,
                                            S
                                                .of(context)
                                                .snackBookPriceChanged);

                                        logAnalyticsEvent(
                                            name: 'book_price_set',
                                            parameters: <String, dynamic>{
                                              'isbn': bookrecord.isbn,
                                              'user': B.user.id,
                                              'price': bookrecord.price,
                                            });
                                      },
                                      maxLines: 1,
                                      controller: _priceTextCtr,
                                      style: Theme.of(context).textTheme.body1,
                                      decoration: InputDecoration(
                                          prefix: Text(
                                              currencySymbol[B.currency],
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
    switch (bookrecord.type) {
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
  }) : super(key: key);

  @override
  _FinancialWidgetState createState() => new _FinancialWidgetState();
}

class _FinancialWidgetState extends State<FinancialWidget> {
  bool showIn = true;
  bool showOut = true;
  bool showRef = true;
  bool showRewards = true;
  bool showLeasing = true;

  StreamSubscription<QuerySnapshot> operationsSubscription;
  List<DocumentSnapshot> operations = [];

  @override
  void initState() {
    super.initState();

    operations = [];
    operationsSubscription = Firestore.instance
        .collection('operations')
        .where("users", arrayContains: B.user.id)
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
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title: Text(S.of(context).financeTitle(money(B.wallet.getAvailable())),
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

          if (op.isIn && showIn ||
              op.isLeasing && showLeasing ||
              op.isReward && showRewards ||
              op.isReferral && showRewards ||
              op.isOut && showOut) {
            return MyOperation(operation: op);
          } else {
            return Container(height: 0.0, width: 0.0);
          }
        }, childCount: operations.length),
      )
    ]);
  }
}

class MyOperation extends StatefulWidget {
  MyOperation({Key key, @required this.operation}) : super(key: key);

  final Operation operation;

  @override
  _MyOperationWidgetState createState() =>
      new _MyOperationWidgetState(operation: operation);
}

class _MyOperationWidgetState extends State<MyOperation> {
  Operation operation;
  StreamSubscription<Operation> _listener;

  @override
  void initState() {
    super.initState();

    _listener = operation.snapshots().listen((op) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (_listener != null) _listener.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(MyOperation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.operation != widget.operation) {
      operation = widget.operation;
      _listener = operation.snapshots().listen((op) {
        if (mounted) setState(() {});
      });
    }
  }

  _MyOperationWidgetState({Key key, @required this.operation});

  @override
  Widget build(BuildContext context) {
    if (operation.isLeasing) {
      return new Container(
          child: Row(children: <Widget>[
        bookImage(operation.bookImage, 25,
            padding: 3.0, tooltip: operation.bookTooltip),
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
    } else if (operation.isReward) {
      return new Container(
          child: Row(children: <Widget>[
        bookImage(operation.bookImage, 25,
            padding: 3.0, tooltip: operation.bookTooltip),
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
    } else if (operation.isInPurchase) {
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
    } else if (operation.isInStellar) {
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
    } else if (operation.isOutStellar) {
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
    } else if (operation.isReferral) {
      return new Container(
          child: Row(children: <Widget>[
        userPhoto(operation.referralUser, 25, padding: 3.0),
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
              Text('+${money(operation.referralAmount)}'), // Amount
            ])))
      ]));
    } else {
      return Container();
    }
  }
}

class ReferralWidget extends StatefulWidget {
  ReferralWidget({
    Key key,
  }) : super(key: key);

  @override
  _ReferralWidgetState createState() => new _ReferralWidgetState();
}

class _ReferralWidgetState extends State<ReferralWidget> {
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
                                  new ClipboardData(text: B.user.link));
                              //Navigator.pop(context);
                              showSnackBar(context, S.of(context).linkCopied);

                              logAnalyticsEvent(
                                  name: 'share',
                                  parameters: <String, dynamic>{
                                    'type': 'link',
                                    'screen': 'referral',
                                    'user': B.user.id,
                                  });
                            },
                            child: Text(B.user.link,
                                style: Theme.of(context).textTheme.body1.apply(
                                    decoration: TextDecoration.underline))))
                  ]),
            ),
          ),
          new Expanded(
              child: new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('users')
                      .where("beneficiary1", isEqualTo: B.user.id)
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
                                builder: (context, user, wallet) {
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
                                              wallet
                                                  .getAvailable()))), // Amount
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
  }) : super(key: key);

  @override
  _SettingsWidgetState createState() => new _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  TextEditingController amountTextCtr;
  TextEditingController payoutTextCtr;
  TextEditingController payoutMemoCtr;
  String _accountErrorText;
  String _amountErrorText;

  List<ProductDetails> products;

  @override
  void initState() {
    super.initState();

    payoutTextCtr = new TextEditingController();
    if (B.user.payoutId != null) payoutTextCtr.text = B.user.payoutId;
    payoutMemoCtr = new TextEditingController();
    amountTextCtr = new TextEditingController();

    initInAppPurchase();
  }

  Future<void> initInAppPurchase() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();

    if (!available) {
      // TODO: Process this more nicely
      throw ('In-App store not available');
    }

    // Only show bigger amounts
    Set<String> _kIds = {'50', '100', '200', '500', '1000', '2000'};
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(_kIds);

    if (!response.notFoundIDs.isEmpty) {
      // TODO: Process this more nicely
      throw ('Ids of in-app products not available');
    }

    products = response.productDetails;
    
    if (Theme.of(context).platform == TargetPlatform.android) {
      products.sort((p2, p1) =>
          p1.skuDetail.priceAmountMicros - p2.skuDetail.priceAmountMicros);
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      products.sort((p2, p1) =>
          (double.parse(p1.skProduct.price)*100).round() - (double.parse(p2.skProduct.price)*100).round());
    }
    products.forEach( (p) => print('!!!DEBUG ${p.price} ${p.title}'));
  
    setState(() {
    });
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
                    Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              userPhoto(B.user, 90),
                              Expanded(
                                  child: Container(
                                      padding: EdgeInsets.only(left: 10.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(B.user.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .title),
                                            Row(children: <Widget>[
                                              new Container(
                                                  margin: EdgeInsets.only(
                                                      right: 5.0),
                                                  child: assetIcon(coins_100,
                                                      size: 20)),
                                              new Text(
                                                  money(
                                                      B.wallet.getAvailable()),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .body1)
                                            ]),
                                          ]))),
                            ])),
                    ExpansionTile(
                        title: Text(S.of(context).settingsTitleGeneral,
                            style: Theme.of(context).textTheme.title),
                        children: <Widget>[
                          Container(child: Text(S.of(context).referralLink)),
                          Container(
                              padding: EdgeInsets.only(bottom: 20.0),
                              child: Builder(
                                  // Create an inner BuildContext so that the onPressed methods
                                  // can refer to the Scaffold with Scaffold.of().
                                  builder: (BuildContext context) {
                                return InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                          new ClipboardData(text: B.user.link));
                                      //Navigator.pop(context);
                                      showSnackBar(
                                          context, S.of(context).linkCopied);

                                      logAnalyticsEvent(
                                          name: 'share',
                                          parameters: <String, dynamic>{
                                            'type': 'link',
                                            'screen': 'settings',
                                            'user': B.user.id,
                                          });
                                    },
                                    child: Text(B.user.link,
                                        style: Theme.of(context)
                                            .textTheme
                                            .body1
                                            .apply(
                                                decoration:
                                                    TextDecoration.underline)));
                              })),
                          Container(child: Text(S.of(context).displayCurrency)),
                          Container(
                            width: 230.0,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: DropdownButton(
                              isExpanded: true,
                              isDense: true,
                              hint: Text(S
                                  .of(context)
                                  .selectDisplayCurrency), // Not necessary for Option 1
                              value: B.currency,
                              onChanged: (newValue) {
                                setState(() {
                                  B.currency = newValue;
                                });
                                // Update preferred currency for user
                                B.user = B.user..currency = newValue;
                                B.user.ref.updateData(B.user.toJson());
                              },
                              items: currencySymbol.entries.map((entry) {
                                return DropdownMenuItem(
                                  child: Container(alignment: Alignment.center, child: Text(entry.key,
                                      style: Theme.of(context).textTheme.body1,
                                      textAlign: TextAlign.center)),
                                  value: entry.key,
                                );
                              }).toList(),
                            ),
                          )
                        ]),
                    products != null ? ExpansionTile(
                        title: Text(S.of(context).settingsTitleIn,
                            style: Theme.of(context).textTheme.title),
                        children: <Widget>[
                          Container(
                            //width: 230.0,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: DropdownButton(
                              isExpanded: true,
                              isDense: true,
                              //hint: , // Not necessary for Option 1
                              value: products.first,
                              onChanged: (product) async {
                                final PurchaseParam purchaseParam =
                                    PurchaseParam(
                                        productDetails: product,
                                        sandboxTesting: false);
                                bool res = await InAppPurchaseConnection
                                    .instance
                                    .buyConsumable(
                                        purchaseParam: purchaseParam);
                                print('!!!DEBUG result ${res}');
                              },
                              items: products.map((p) {
                                return DropdownMenuItem(
                                  child: Container(alignment: Alignment.center, child: Text(purchaseProductText(p),
                                      style: Theme.of(context).textTheme.body1,
                                      textAlign: TextAlign.center)),
                                  value: p,
                                );
                              }).toList(),
                            ),
                          )
                        ]) : Container(),
                    ExpansionTile(
                        title: Text(S.of(context).settingsTitleInStellar,
                            style: Theme.of(context).textTheme.title),
                        children: <Widget>[
                          Text(S.of(context).inputStellarAcount),
                          new Container(
                              alignment: Alignment.centerLeft,
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
                                          new ClipboardData(text: B.user.id));
                                      //Navigator.pop(context);
                                      showSnackBar(
                                          context, S.of(context).memoCopied);
                                    },
                                    child: Text(B.user.id,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .body1
                                            .apply(
                                                decoration:
                                                    TextDecoration.underline)));
                              })),
                        ]),
                    ExpansionTile(
                        title: Text(S.of(context).settingsTitleOutStellar,
                            style: Theme.of(context).textTheme.title),
                        children: <Widget>[
                          Text(S.of(context).outputStellarAccount),
                          new Container(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Theme(
                                data:
                                    ThemeData(platform: TargetPlatform.android),
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

                                    // Update Payout Stellar Account for user
                                    B.user = B.user..payoutId = value;
                                    await B.user.ref
                                        .updateData(B.user.toJson());
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
                                data:
                                    ThemeData(platform: TargetPlatform.android),
                                child: TextField(
                                  maxLines: 1,
                                  controller: payoutMemoCtr,
                                  style: Theme.of(context).textTheme.body1,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(2.0),
                                      hintText: S.of(context).hintOutputMemo,
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
                                                platform:
                                                    TargetPlatform.android),
                                            child: TextField(
                                              maxLines: 1,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                WhitelistingTextInputFormatter(
                                                    RegExp(
                                                        r'((\d+(\.\d*)?)|(\.\d+))'))
                                              ],
                                              controller: amountTextCtr,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body1,
                                              decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.all(2.0),
                                                  hintText: S
                                                      .of(context)
                                                      .hintNotMore(money(B
                                                          .wallet
                                                          .getAvailable())),
                                                  errorText: _amountErrorText),
                                            )))),
                                IconButton(
                                    onPressed: () async {
                                      try {
                                        if (!await checkStellarAccount(
                                            B.user.payoutId)) {
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
                                            B.wallet.getAvailable()) {
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

                                        await payoutStellar(B.user, amount,
                                            memo: payoutMemoCtr.text);

                                        showSnackBar(context,
                                            S.of(context).successfulPayment);
                                      } catch (ex, stack) {
                                        FlutterCrashlytics()
                                            .logException(ex, stack);

                                        // TODO: Log event for administrator to investigate
                                        showSnackBar(context,
                                            S.of(context).paymentError);
                                      }
                                    },
                                    icon: assetIcon(paper_plane_100, size: 30))
                                    //child: Text(S.of(context).buttonTransfer))
                              ])),
                        ]),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

String purchaseProductText(ProductDetails p) {
  if (Theme.of(context).platform == TargetPlatform.android) {
      String title = p.title;
      if (title.indexOf('(') != -1)
        title = title.substring(0, p.title.indexOf('(') - 1);
      return '${title} (${p.price})';
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      String title = p.title;
      if (title == null) {
      if (p.id == '50')
        title = 'Power package';
      else if (p.id == '100')
        title = 'Order package';
      else if (p.id == '200')
        title = 'Success package';
      else if (p.id == '500')
        title = 'Community package';
      else if (p.id == '1000')
        title = 'Synergy package';
      else if (p.id == '2000')
        title = 'Holistic package';
      }
      return '${title} (${p.price})';
    } else
      return null;
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
          child: Text(S.of(context).supportTitleGetBooks,
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(S.of(context).supportGetBooks,
              style: Theme.of(context).textTheme.body1)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(S.of(context).supportTitleGetBalance,
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(S.of(context).supportGetBalance,
              style: Theme.of(context).textTheme.body1)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(S.of(context).supportTitleReferrals,
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(S.of(context).supportReferrals,
              style: Theme.of(context).textTheme.body1)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(S.of(context).supportTitlePayout,
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(S.of(context).supportPayout,
              style: Theme.of(context).textTheme.body1)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: Text(S.of(context).supportTitleChatbot,
              style: Theme.of(context).textTheme.subtitle)),
      Container(
          margin: EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
                text: S.of(context).supportChatbot,
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
          child: Text(S.of(context).supportSignature,
              style: Theme.of(context).textTheme.body1)),
    ]));
  }
}
