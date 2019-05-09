import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/flutter_firebase_ui.dart';
import 'package:firebase_ui/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
//Temporary for visual debugging
//import 'package:flutter/rendering.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/camera.dart';
import 'package:biblosphere/bookshelf.dart';
import 'package:biblosphere/chat.dart';
import 'package:biblosphere/l10n.dart';

//TODO: Credit page with link to author of icons:  Icon made by Freepik (http://www.freepik.com/) from www.flaticon.com

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() async {
  bool isInDebugMode = false;
//  debugPaintSizeEnabled=true;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Crashlytics.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  await FlutterCrashlytics().initialize();

  runZoned<Future<Null>>(() async {
    runApp(new MyApp());
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Crashlytics depending on the environment.
    debugPrint(error.toString());
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      // Uncomment to make screenshots in simulator without debug banner
      // debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [Locale("en"), Locale("ru")],
      onGenerateTitle: (BuildContext context) => S.of(context).title,
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
//        fontFamily: 'AmaticSc',
        textTheme: TextTheme(
          headline: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'AmaticSc'),
          subhead: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'AmaticSc'),
          title: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              //color: Colors.white,
              fontFamily: 'AmaticSc'),
          subtitle: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'AmaticSc'),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Oswald'),
          button: TextStyle(fontSize: 22.0, fontFamily: 'AmaticSc'),
        ),
        colorScheme: ColorScheme(
            primary: Colors.teal[800],
            primaryVariant: Colors.teal[600],
            secondary: Colors.teal[600],
            secondaryVariant: Colors.teal[200],
            surface: Colors.black12,
            error: Colors.red,
            background: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: Colors.black,
            onError: Colors.yellow,
            onSurface: Colors.lightBlueAccent,
            brightness: Brightness.light),
        brightness: Brightness.light,
        primaryColor: Colors.teal[800],
        accentColor: Colors.teal[600],
//        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

// Widget with into page
class IntroPage extends StatelessWidget {
  final VoidCallback onTapDoneButton;
  final VoidCallback onTapSkipButton;

  IntroPage({Key key, this.onTapDoneButton, this.onTapSkipButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final pages = [
      new PageViewModel(
          pageColor: const Color(0xFF03A9F4),
          iconImageAssetPath: 'images/home.png',
          iconColor: null,
          bubbleBackgroundColor: const Color(0x88FFFFFF),
          body: Text(S.of(context).introShootHint),
          title: Text(S.of(context).introShoot),
          textStyle: TextStyle(fontFamily: 'AmaticSc', color: Colors.white),
          mainImage: Image.asset(
            'images/shoot.png',
//          height: 285.0,
//          width: 285.0,
            alignment: Alignment.center,
          )),
      new PageViewModel(
        pageColor: const Color(0xFF8BC34A),
        iconImageAssetPath: 'images/local_library.png',
        iconColor: null,
        bubbleBackgroundColor: Color(0x88FFFFFF),
        body: Text(S.of(context).introSurfHint),
        title: Text(S.of(context).introSurf),
        mainImage: Image.asset(
          'images/surf.png',
//        height: 285.0,
//        width: 285.0,
          alignment: Alignment.center,
        ),
        textStyle: TextStyle(fontFamily: 'AmaticSc', color: Colors.white),
      ),
      new PageViewModel(
        pageColor: const Color(0xFF607D8B),
        iconImageAssetPath: 'images/message.png',
        iconColor: null,
        bubbleBackgroundColor: Color(0x88FFFFFF),
        body: Text(S.of(context).introMeetHint),
        title: Text(S.of(context).introMeet),
        mainImage: Image.asset(
          'images/meet.png',
//        height: 285.0,
//        width: 285.0,
          alignment: Alignment.center,
        ),
        textStyle: TextStyle(fontFamily: 'AmaticSc', color: Colors.white),
      ),
    ];

    return new Builder(
      builder: (context) => new IntroViewsFlutter(
            pages,
            doneText: Text(S.of(context).introDone),
            skipText: Text(S.of(context).introSkip),
            onTapDoneButton: onTapDoneButton,
            onTapSkipButton: onTapSkipButton,
            showSkipButton:
                true, //Whether you want to show the skip button or not.
            pageButtonTextStyles: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ), //IntroViewsFlutter
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  User currentUser;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  StreamSubscription<FirebaseUser> _listener;
  FirebaseUser firebaseUser;
  bool unreadMessage = false;
  bool firstRun = true;
  bool skipIntro = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _checkCurrentUser();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        setState(() {
          unreadMessage = true;
        });
      },
      onResume: (Map<String, dynamic> message) {
        new Future.delayed(Duration.zero, () {
          Chat.runChat(context, currentUser?.id, message['sender']);
        });
      },
      onLaunch: (Map<String, dynamic> message) {
        new Future.delayed(Duration.zero, () {
          Chat.runChat(context, currentUser?.id, message['sender']);
        });
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    // TODO: build function executed 3 times: after initState, after setState in
    //       _initUserRecord and after setState in _initLocationState.
    //       Better to minimize rebuilding. For example by providing currentUser
    //       as parameter on widget push (is it possible?).
  }

  @override
  void dispose() {
    _listener.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      new Future.delayed(Duration.zero, () async {
        final position = await currentPosition();
        setState(() {
          currentUser.position = position;
        });
      });
    }
  }

  void _checkCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    firstRun = prefs.getBool('firstRun') ?? true;

    setState(() {
      skipIntro = prefs.getBool('skipIntro') ?? false;
    });

    if (firstRun) {
      signOutProviders();
      await prefs.setBool('firstRun', false);
      firstRun = false;
    }

    firebaseUser = await _auth.currentUser();
    firebaseUser?.getIdToken(refresh: true);

    _listener = _auth.onAuthStateChanged.listen((FirebaseUser user) {
      setState(() {
        firebaseUser = user;

        if (firebaseUser != null) {
          // That's async function so need to refresh widget as soon as it completes
          _initUserRecord().then((_) {
            setState(() {});
          });
        }
      });
    });
  }

  Future<void> _initUserRecord() async {
    try {
      if (firebaseUser == null)
        throw "CurrentUserId is null, login failed or not completed";

      currentUser = new User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName,
          photo: firebaseUser.photoUrl,
          position: await currentPosition());

      // Check if user record exist
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'name': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid
        });
      } else {
        currentUser.balance = documents[0].data['balance'] != null ? (documents[0].data['balance'] as num).toDouble() : 0;
        currentUser.wishCount = documents[0].data['wishCount'] ?? 0;
        currentUser.bookCount = documents[0].data['bookCount'] ?? 0;
        currentUser.shelfCount = documents[0].data['shelfCount'] ?? 0;
      }

      DocumentReference userRef = Firestore.instance
          .collection('users')
          .document(firebaseUser.uid);
      
      userRef.snapshots().listen((DocumentSnapshot doc) {
        setState(() {
          currentUser.balance = doc.data['balance'] != null ? (doc.data['balance'] as num).toDouble() : 0;
          currentUser.wishCount = doc.data['wishCount'] ?? 0;
          currentUser.bookCount = doc.data['bookCount'] ?? 0;
          currentUser.shelfCount = doc.data['shelfCount'] ?? 0;
        });
      });

      _firebaseMessaging.getToken().then((token) {
        // Update FCM token for notifications
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .updateData({
          'token': token,
        });
      });
    } catch (ex, stack) {
      print(ex);
      FlutterCrashlytics().logException(ex, stack);
    }
  }

  Future<DocumentSnapshot> _fetchUser(String peerId) async {
    DocumentSnapshot userSnap =
        await Firestore.instance.collection('users').document(peerId).get();

    return userSnap;
  }

  void blockUser(String blockingUser, String blockedUser) {
    Firestore.instance
        .collection('messages')
        .document(chatId(blockingUser, blockedUser))
        .updateData({'blocked': 'yes'});
  }

  Widget buildItem(BuildContext context, DocumentSnapshot userSnap) {
    return Container(
      child: FlatButton(
        child: Row(children: <Widget>[
          Container(
              width: 50.0,
              height: 50.0,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: new CachedNetworkImageProvider(
                          userSnap['photoUrl'])))),
          new Flexible(
              child: Container(
            child: Text(
              userSnap['name'],
              style: TextStyle(color: themeColor),
            ),
            alignment: Alignment.centerLeft,
            margin: new EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 20.0),
          )),
          new IconButton(
            onPressed: () {
              showBbsConfirmation(context, S.of(context).confirmBlockUser)
                  .then((confirmed) {
                if (confirmed) {
                  blockUser(currentUser?.id, userSnap['id']);
                }
              });
            },
            tooltip: S.of(context).blockUser,
            icon: new Icon(MyIcons.stop),
          ),
        ]),
        onPressed: () {
          setState(() {
            unreadMessage = false;
          });
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new Chat(
                        myId: currentUser?.id,
                        peerId: userSnap.documentID,
                        peerAvatar: userSnap['photoUrl'],
                        peerName: userSnap['name'],
                        isNewChat: false,
                      )));
        },
        color: greyColor2,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    if (!skipIntro && firebaseUser == null) {
      return new IntroPage(onTapDoneButton: () {
        setState(() {
          skipIntro = true;
        });
      }, onTapSkipButton: () async {
        setState(() {
          skipIntro = true;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('skipIntro', true);
      });
    } else if (firebaseUser == null) {
      return new SignInScreen(
        title: S.of(context).welcome,
        header: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Container(
              padding: EdgeInsets.all(5.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: new TextSpan(
                  style: Theme.of(context).textTheme.body1,
                  children: [
                    new TextSpan(
                      text: S.of(context).loginAgree1,
                      style: new TextStyle(color: Colors.black),
                    ),
                    new TextSpan(
                      text: S.of(context).loginAgree2,
                      style: new TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () async {
                          const url = 'https://biblosphere.org/eula.html';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch url $url';
                          }
                        },
                    ),
                    new TextSpan(
                      text: S.of(context).loginAgree3,
                      style: new TextStyle(color: Colors.black),
                    ),
                    new TextSpan(
                      text: S.of(context).loginAgree4,
                      style: new TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
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
                      text: '.',
                      style: new TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        providers: [
          ProvidersTypes.google,
          ProvidersTypes.facebook,
          ProvidersTypes.twitter,
//          ProvidersTypes.phone,
//          ProvidersTypes.email
        ],
      );
    } else {
      return new DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: new AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            actions: <Widget>[
              FlatButton(
                child: Row(children: <Widget>[
                  new Container(margin: EdgeInsets.only(right: 5.0), child: new Icon(MyIcons.money, color: Colors.white)),
                  new Text('${(new NumberFormat("##0.00")).format(currentUser?.balance??0)} \u{03BB}', style: Theme.of(context).textTheme.body1
                      .apply(color: Colors.white))
                ]),
                onPressed: () {},
                padding: EdgeInsets.all(0.0),
              ),
              new IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      cardListPage(
                          user: currentUser,
                          stream: Firestore.instance
                              .collection('transit')
                              .where("from.id", isEqualTo: currentUser.id)
                              .snapshots(),
                          mapper: (doc, user) {
                            //TODO: Change MyBook to MyOutbox
                            return new MyOutbox(
                                new Transit.fromJson(doc.data), currentUser);
                          },
                          title: S.of(context).myOutboxTitle,
                          empty: S.of(context).noItemsInOutbox));
                },
                tooltip: S.of(context).outbox,
                icon: new Icon(MyIcons.outbox),
              ),
              new IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      cardListPage(
                          user: currentUser,
                          stream: Firestore.instance
                              .collection('transit')
                              .where("to.id", isEqualTo: currentUser.id)
                              .snapshots(),
                          mapper: (doc, user) {
                            //TODO: Change MyBook to MyCart
                            return new MyCart(
                                new Transit.fromJson(doc.data), currentUser);
                          },
                          title: S.of(context).myCartTitle,
                          empty: S.of(context).noItemsInCart));
                },
                tooltip: S.of(context).cart,
                icon: new Icon(MyIcons.cart),
              ),
/*
              new IconButton(
                onPressed: () {
//                  Navigator.of(context).pushReplacementNamed('/set');
                },
                tooltip: S.of(context).settings,
                icon: new Icon(MyIcons.settings),
              ),
*/
              new IconButton(
                onPressed: () => signOutProviders(),
                tooltip: S.of(context).logout,
                icon: new Icon(MyIcons.exit),
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(MyIcons.home)),
                Tab(icon: Icon(MyIcons.book)),
                Tab(icon: Icon(MyIcons.people)),
                Tab(
                    icon: unreadMessage
                        ? Icon(MyIcons.girl)
                        : Icon(MyIcons.chat)),
              ],
            ),
            title: new Text(S.of(context).title,
                style: Theme.of(context)
                    .textTheme
                    .title
                    .apply(color: Colors.white)),
          ),
          body: TabBarView(
            children: <Widget>[
              // Camera tab
              Home(
                currentUser: currentUser,
              ),

              // Main tab with bookshelves
              new BookshelfList(
                  currentUser: currentUser,
                  area: currentUser?.position != null
                      ? new Area(currentUser.position, 200.0)
                      : null),

              // Main tab with bookshelves
              new PeopleList(
                  currentUser: currentUser,
                  area: currentUser?.position != null
                      ? new Area(currentUser.position, 5000.0)
                      : null),

              // Tab for chat
              Container(
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('messages')
                      .where("ids", arrayContains: currentUser?.id)
                      .where("blocked", isEqualTo: "no")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.teal),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) {
                          String peerId = snapshot.data.documents[index]['ids']
                              .firstWhere((id) => id != currentUser?.id,
                                  orElse: () => null);

                          return FutureBuilder(
                            future: _fetchUser(peerId),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.active:
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return Container();
                                case ConnectionState.done:
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return buildItem(context, snapshot.data);
                                  }
                              }
                            },
                          );
                        },
                        itemCount: snapshot.data.documents.length,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
