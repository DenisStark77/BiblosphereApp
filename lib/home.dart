import 'package:biblosphere/search.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:share/share.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/lifecycle.dart';
import 'package:biblosphere/books.dart';
import 'package:biblosphere/chat.dart';
import 'package:biblosphere/l10n.dart';

import 'helpers.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool unreadMessage = false;

  _MyHomePageState({
    Key key,
  });

  @override
  void initState() {
    super.initState();

    assert(B.user != null);
    initDynamicLinks();

    //print('!!!DEBUG INIT Firebase Messaging');
    FirebaseMessaging().configure(
      onMessage: (Map<String, dynamic> message) {
        Map<String, dynamic> payload;
        // Android and iOS has different format of messages
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          //print('!!!DEBUG: Message received (iOS) ${message}');
          payload = message;
        } else {
          payload = Map<String, dynamic>.from(message['data']);
        }

        if (payload['event'] == 'books_recognized') {
          //print('!!!DEBUG: Snacbar to show ${message['data']['count']} $context');
          showSnackBar(
              context, S.of(context).snackRecognitionDone(payload['count']));
        } else if (payload['event'] == 'new_message') {
          setState(() {
            unreadMessage = true;
          });
        }
        return;
      },
      onResume: (Map<String, dynamic> message) {
        return Future.delayed(Duration.zero, () {
          Map<String, dynamic> payload;
          // Android and iOS has different format of messages
          if (Theme.of(context).platform == TargetPlatform.iOS) {
            //print('!!!DEBUG: Message received (iOS) ${message}');
            payload = message;
          } else {
            payload = Map<String, dynamic>.from(message['data']);
          }
          //print('!!!DEBUG onResume $payload');

          Chat.runChatById(context, chatId: payload['chat']);
        });
      },
      onLaunch: (Map<String, dynamic> message) {
        return new Future.delayed(Duration.zero, () {
          Map<String, dynamic> payload;
          // Android and iOS has different format of messages
          if (Theme.of(context).platform == TargetPlatform.iOS) {
            //print('!!!DEBUG: Message received (iOS) ${message}');
            payload = message;
          } else {
            payload = Map<String, dynamic>.from(message['data']);
          }
          //print('!!!DEBUG onLaunch $payload');

          // TODO: Change sender to chat id
          Chat.runChatById(context, chatId: payload['chat']);
        });
      },
    );

    FirebaseMessaging().requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> processDeepLink(Uri deepLink) async {
    //print('!!!DEBUG Running DeepLink');

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
          Chat.runChat(context, user, chat: chat);
        }
      }
      // It was Navigator.pushNamed in original example. Don't know why...
      // Navigator.pushNamed(context, deepLink.path, arguments: user);
    } else if (deepLink.path == "/search") {
      // Deep link to go to the search results for the book.
      // Book have to be registered in Biblosphere
      String isbn = deepLink.queryParameters['isbn'];
      if (isbn != null) {
        pushSingle(
            context,
            new MaterialPageRoute(
                builder: (context) => buildScaffold(
                    context, null, new FindBookWidget(isbn: isbn),
                    appbar: false)),
            'search');
      } else {
        // TODO: report broken link: bookId is null
      }
    } else if (deepLink.path == "/addbook" || deepLink.path == "/addwish") {
      // Deep link to go add book/wish and go to My Books with filter for this book.
      // Book have to be registered in Biblosphere
      bool wish = (deepLink.path == "/addwish");
      String isbn = deepLink.queryParameters['isbn'];
      if (isbn != null) {
        Book book = await searchByIsbn(isbn);

        if (book != null) {
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
    }
    // TODO: Add Deep Link '/main'
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      processDeepLink(deepLink);
    }

    // TODO: Do I need to cancel/unsubscribe from onLink listener?
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) {
      return Future.delayed(Duration.zero, () async {
        final Uri deepLink = dynamicLink?.link;

        if (deepLink != null) {
          await processDeepLink(deepLink);
          //showSnackBar(context, 'Deep link 2');
        } else {
          //showSnackBar(context, 'Deep link 1');
        }
      });
    }, onError: (OnLinkErrorException e) {
      return Future.delayed(Duration.zero, () {
        // TODO: Add to Crashalitics
        //showSnackBar(context, 'onError: ${e.code} ${e.message} ${e.details}');
        print('onLinkError');
        print(e.message);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          actions: <Widget>[
            Stack(children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    unreadMessage = false;
                  });
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
              Positioned.fill(
                  child: Container(
                      padding: EdgeInsets.all(7.0),
                      alignment: Alignment.topRight,
                      child: ClipOval(
                        child: unreadMessage
                            ? Container(
                                color: Colors.green,
                                height: 12.0, // height of the button
                                width: 12.0, // width of the button
                              )
                            : Container(),
                      )))
            ])
          ],
          title: new Text(S.of(context).title,
              style:
                  Theme.of(context).textTheme.headline6.apply(color: C.titleText)),
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
                                              Theme.of(context).textTheme.headline6)
                                    ]))))),
                new Expanded(
                  child: new InkWell(
                    onTap: () async {
                      pushSingle(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => buildScaffold(
                                  context,
                                  S.of(context).findbookTitle,
                                  new FindBookWidget(),
                                  appbar: false)),
                          'search');
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
                                style: Theme.of(context).textTheme.headline6)
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
                                style: Theme.of(context).textTheme.headline6)
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
                                                      .headline6
                                                      .apply(
                                                          color: C.titleText))),
                                        ]))),
                          ]),
                      Container(
                          padding: EdgeInsets.only(top: 5.0),
                          child: Text(S.of(context).referralLink,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
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
                                        .bodyText2
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
                  setState(() {
                    unreadMessage = false;
                  });
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
                  pushSingle(
                      context,
                      new MaterialPageRoute(
                          //TODO: translation
                          builder: (context) => buildScaffold(
                              context,
                              S.of(context).titleSettings,
                              new SettingsWidget())),
                      'settings');
                },
              ),
              // TODO: Convert FinancialWidget into HistoryWidget
              //  to show books give/take history of the user
              /*
              ListTile(
                title: drawerMenuItem(
                    context, S.of(context).menuBalance, coins_100,
                    size: 28),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => buildScaffold(
                              context,
                              S
                                  .of(context)
                                  .financeTitle(money(B.wallet.getAvailable())),
                              new FinancialWidget(),
                              appbar: false)));
                },
              ),
              */
              // TODO: Convert it to FriendsWidget instead of referral
              /*
              ListTile(
                title: drawerMenuItem(
                    context, S.of(context).menuReferral, handshake_100,
                    size: 28),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => buildScaffold(
                              context,
                              S.of(context).referralTitle,
                              new ReferralWidget())));
                },
              ),
              */
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
  bool own = true, lent = true, borrowed = true, wish = true;
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
            style: Theme.of(context).textTheme.headline6.apply(color: C.titleText)),
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
                                style: Theme.of(context).textTheme.headline6,
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
              borrowed && rec.isBorrowed) {
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
    if (_listener != null) _listener.cancel();

    super.dispose();
  }

  _MyBookWidgetState(
      {Key key, @required this.bookrecord, @required this.filter});

  Future<void> deleteBook(BuildContext context) async {
    try {
      //Delete book record in Firestore database
      bookrecord.ref.delete();
      if (bookrecord.wish) {
        showSnackBar(context, S.of(context).snackWishDeleted);
        B.user.ref.updateData({'wishCount': FieldValue.increment(-1)});
      } else {
        showSnackBar(context, S.of(context).bookDeleted);
      }
    } catch (e, stack) {
      print('Bookrecord delete failed for [${bookrecord.id}, ${B.user.id}]: ' +
          e.toString());
      Crashlytics.instance.recordError(e, stack);
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
                          bookImage(bookrecord, 80,
                              padding: EdgeInsets.all(5.0)),
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
                                                .subtitle2)),
                                    B.user.id != bookrecord.ownerId
                                        ? Container(
                                            child: Text(
                                                S.of(context).bookOwner(
                                                    bookrecord.ownerName),
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2))
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
                                  // Open chat widget
                                  Chat.runChatWithBookRequest(
                                      context, bookrecord,
                                      message: S
                                          .of(context)
                                          .requestReturn(bookrecord.title));
                                },
                                tooltip: S.of(context).hintReturn,
                                icon: assetIcon(return_100, size: 25),
                              )
                            : Container(),
                        // Button to return book only it it's lent
                        bookrecord.isLent
                            ? new IconButton(
                                onPressed: () async {
                                  // Open chat widget
                                  Chat.runChatWithBookRequest(
                                      context, bookrecord,
                                      message: S
                                          .of(context)
                                          .requestReturnByOwner(
                                              bookrecord.title));
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
            style: Theme.of(context).textTheme.bodyText2);
      case BookrecordType.wish:
        return Text(S.of(context).youWishThisBook,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText2);
      case BookrecordType.lent:
        return Text(S.of(context).youLentThisBook(bookrecord.holderName),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText2);
      case BookrecordType.borrowed:
        return Text(S.of(context).youBorrowThisBook,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText2);
      case BookrecordType.none:
      default:
        return Container();
    }
  }
}

// TODO: Make a HistoryWidget instead of FinancialWidget
/*
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
            style: Theme.of(context).textTheme.headline6.apply(color: C.titleText)),
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
            padding: EdgeInsets.all(3.0), tooltip: operation.bookTooltip),
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
*/

// TODO: Convert it to FriendsWidget instead of refferal
/*
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
                            style: Theme.of(context).textTheme.headline6)),
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
                                style: Theme.of(context).textTheme.bodyText2.apply(
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
                                style: Theme.of(context).textTheme.bodyText2,
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
*/

class SettingsWidget extends StatefulWidget {
  SettingsWidget({
    Key key,
  }) : super(key: key);

  @override
  _SettingsWidgetState createState() => new _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  Offerings offerings;
  PurchaserInfo purchaserInfo;
  PackageType upgradeChoice = PackageType.annual;
  int booksAllowance = 2;
  int wishesAllowance = 10;

  @override
  void initState() {
    super.initState();

    try {
      Purchases.getOfferings().then((Offerings res) {
        //print('!!!DEBUG get offerings: $res');
        if (res != null && res.current != null) {
          //print('!!!DEBUG: ${res}');
          setState(() {
            offerings = res;
          });
        }
      });

      Purchases.getPurchaserInfo().then((PurchaserInfo info) {
        //print('!!!DEBUG: PurchaserInfo ${info}');
        setState(() {
          purchaserInfo = info;
        });
      });
      // access latest purchaserInfo
    } on PlatformException catch (e, stack) {
      //print('!!!DEBUG: Exception on Purchases plug-in, $e, $stack');
      Crashlytics.instance.recordError(e, stack);
    }

    Purchases.addPurchaserInfoUpdateListener((info) {
      // handle any changes to purchaserInfo
      //print('!!!DEBUG NEW PURCHASESER $info');
      //print('!!!DEBUG OLD PURCHASESER $purchaserInfo');
      if (!purchaserInfo.entitlements.all["basic"].isActive &&
          info.entitlements.all["basic"].isActive) {
        // Unlock that great "pro" content
        //print('!!!DEBUG: Purchase completed');
        showSnackBar(context, S.of(context).snackPaidPlanActivated);
      }

      setState(() {
        purchaserInfo = info;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _SettingsWidgetState({
    Key key,
  });

  String currentPlan(BuildContext context) {
    // TODO: Translate TRIAL
    return isTrial() ? S.of(context).planTrial : S.of(context).planPaid;
  }

  bool isTrial() {
    // TODO: Translate TRIAL
    return purchaserInfo == null ||
        purchaserInfo.activeSubscriptions.length == 0;
  }

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
                              userPhoto(B.loginUser, 90),
                              Expanded(
                                  child: Container(
                                      padding: EdgeInsets.only(left: 10.0),
                                      child: Column(children: <Widget>[
                                        Text(B.loginUser.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6),
                                        Text(
                                            S.of(context).settingsPlan(
                                                currentPlan(context)),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2),
                                      ]))),
                            ])),
                    planInfoWidget(context),
                    isTrial() && offerings != null
                        ? upgradeWidget()
                        : Container(),
                    linkedUsersWidget(context),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget linkedUsersWidget(BuildContext context) {
    if (B.loginUser.linkedUsers != null && B.loginUser.linkedUsers.length > 0
    && B.linkedUsers != null && B.linkedUsers.length > 0) {
      return Container(child: 
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(S.of(context).currentUserSetting, style: Theme.of(context).textTheme.subtitle2),
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: DropdownButton(
            value: B.loginUser.currentUser ?? B.user.id,
            onChanged: (newValue) {
              // Refresh the UI
              setState(() {
                B.loginUser.currentUser = newValue;
              });
              // Update value of current user
              B.loginUser.ref.updateData({'currentUser': newValue});
            },
            items: B.linkedUsers.map((user) {
              return DropdownMenuItem(
                child: Center(child: Text(user.name, style: Theme.of(context).textTheme.bodyText2)),
                value: user.id,
              );
            }).toList(),
          )),
        ],
      ));
    } else {
      return Container();
    }

  }

  Widget planInfoWidget(BuildContext context) {
    if (isTrial()) {
      booksAllowance = 2;
      wishesAllowance = 10;
    } else {
      booksAllowance = 5;
      wishesAllowance = 100;
    }

    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          // Row with three plan options to choose
          Text(
              isTrial()
                  ? S.of(context).wishLimitTrial(wishesAllowance, 100)
                  : S.of(context).wishLimitPaid(wishesAllowance),
              style: Theme.of(context).textTheme.subtitle2),
          Container(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                  isTrial()
                      ? S.of(context).wishLimitTrialDesc(wishesAllowance, 100)
                      : S.of(context).wishLimitPaidDesc(wishesAllowance),
                  style: Theme.of(context).textTheme.bodyText1)),
          Text(
              isTrial()
                  ? S.of(context).bookLimitTrial(booksAllowance, 5)
                  : S.of(context).bookLimitPaid(booksAllowance),
              style: Theme.of(context).textTheme.subtitle2),
          Container(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                  isTrial()
                      ? S.of(context).bookLimitTrialDesc(booksAllowance, 5)
                      : S.of(context).bookLimitPaidDesc(booksAllowance),
                  style: Theme.of(context).textTheme.bodyText1)),
        ]));
  }

  Widget productWidget(Package package) {
    // Get rid of "(Biblosphere)" in the title of Google Play products
    String title = package.product.title.contains('(')
        ? package.product.title.split('(')[0]
        : package.product.title;

    // Only Annual and monthly psubscriptions supported
    String monthlyPrice = package.packageType == PackageType.annual
        ? package.product.currencyCode +
            ' ' +
            (package.product.price / 12.0).toStringAsFixed(2)
        : package.product.priceString;

    return Expanded(
        child: GestureDetector(
            onTap: () {
              setState(() {
                upgradeChoice = package.packageType;
              });
            },
            child: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    // Highlight user choice
                    decoration: package.packageType == upgradeChoice
                        ? BoxDecoration(
                            border: Border.all(
                              color: C.buttonBorder,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            color: C.background)
                        : BoxDecoration(),
                    child: Column(children: <Widget>[
                      //Container(child: Text(package.packageType.toString())),
                      Container(
                          child: Text(title,
                              style: Theme.of(context).textTheme.headline6)),
                      // Show per month price uness it's annual plan and it's choosen
                      upgradeChoice != PackageType.annual ||
                              package.packageType != PackageType.annual
                          ? Container(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(monthlyPrice,
                                  style: Theme.of(context).textTheme.bodyText2))
                          : Container(),
                      upgradeChoice != PackageType.annual ||
                              package.packageType != PackageType.annual
                          ? Container(
                              child: Text(S.of(context).perMonth,
                                  style: Theme.of(context).textTheme.bodyText1))
                          : Container(),
                      package.packageType == PackageType.annual &&
                              upgradeChoice == PackageType.annual
                          ? Container(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(package.product.priceString,
                                  style: Theme.of(context).textTheme.bodyText2))
                          : Container(),
                      package.packageType == PackageType.annual &&
                              upgradeChoice == PackageType.annual
                          ? Container(
                              child: Text(S.of(context).perYear,
                                  style: Theme.of(context).textTheme.bodyText1))
                          : Container(),
                    ])),
                // SUBSCRIBE button
                package.packageType == upgradeChoice
                    ? Row(children: <Widget>[
                        Expanded(
                            //constraints: BoxConstraints.loose(s),
                            //alignment: Alignment.center,
                            //padding: EdgeInsets.only(bottom: 20.0),
                            child: OutlineButton(
                                padding: EdgeInsets.all(0.0),
                                // TODO: Translation
                                child: Text(
                                  S
                                      .of(context)
                                      .buttonUpgrade, /*style: Theme.of(context).textTheme.subtitle2*/
                                ),
                                onPressed: () async {
                                  try {
                                    //PurchaserInfo purchaserInfo =
                                    await Purchases.purchasePackage(package);
                                    // print('!!!DEBUG: ${purchaserInfo}');
                                  } on PlatformException catch (e, stack) {
                                    var errorCode =
                                        PurchasesErrorHelper.getErrorCode(e);
                                    if (errorCode !=
                                        PurchasesErrorCode
                                            .purchaseCancelledError) {
                                      // TODO: Add analytics
                                      print('!!!DEBUG Purchase canceled');
                                    }
                                    Crashlytics.instance.recordError(e, stack);
                                  }
                                },
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0))))
                      ])
                    : Container(),
              ],
            ))));
  }

  Widget upgradeWidget() {
    if (offerings == null) return Container();

    String optionText = '';
    if (upgradeChoice == PackageType.monthly)
      optionText = S.of(context).monthlyDescription;
    else if (upgradeChoice == PackageType.annual)
      optionText = S.of(context).annualDescription;
    else if (upgradeChoice == PackageType.custom)
      optionText = S.of(context).patronDescription;

    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          // Row with three plan options to choose
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            //isSelected: planOptions,
            children: <Widget>[
              // Monthly option
              productWidget(offerings.current.monthly),
              // Annual option
              productWidget(offerings.current.annual),
              // Patron option
              productWidget(offerings.current.getPackage('Patron')),
            ],
          ),
          // Information about paid plan
          Text(optionText, style: Theme.of(context).textTheme.subtitle2),
          Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                  S.of(context).subscriptionDisclaimer(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? 'iTunes'
                          : 'Google Play'),
                  style: Theme.of(context).textTheme.bodyText1)),
          RichText(
              text: TextSpan(children: [
            new TextSpan(
              text: S.of(context).privacyPolicy,
              style: new TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: new TapGestureRecognizer()
                ..onTap = () async {
                  const url = 'https://biblosphere.org/pp.html';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch url $url';
                  }
                },
            ),
            new TextSpan(
              text: '  ',
            ),
            new TextSpan(
              text: S.of(context).termsOfService,
              style: new TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: new TapGestureRecognizer()
                ..onTap = () async {
                  const url = 'https://biblosphere.org/tos.html';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch url $url';
                  }
                },
            )
          ]))
        ]));
  }
}

class SupportWidget extends StatelessWidget {
  SupportWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: S.of(context).supportText,
      onTapLink: (url) async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch url $url';
        }
      },
    );
  }
}

void showUpgradeDialog(BuildContext context, String text) {
  showDialog<Null>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          child: Row(children: <Widget>[
            Material(
              child: Image.asset(
                online_support_100,
                width: 50.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            new Flexible(
              child: Container(
                child: new Container(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  alignment: Alignment.centerLeft,
                  margin: new EdgeInsets.only(top: 5.0),
                ),
                margin: EdgeInsets.only(left: 5.0),
              ),
            ),
          ]),
          constraints: BoxConstraints(maxHeight: 100.0),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(S.of(context).buttonUpgrade),
            onPressed: () {
              Navigator.of(context).pop();
              pushSingle(
                  context,
                  new MaterialPageRoute(
                      //TODO: translation
                      builder: (context) => buildScaffold(context,
                          S.of(context).titleSettings, new SettingsWidget())),
                  'settings');
            },
          ),
          FlatButton(
            child: Text(S.of(context).buttonSkip),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
