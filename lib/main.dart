import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/camera.dart';
import 'package:biblosphere/bookshelf.dart';
import 'package:biblosphere/chat.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FacebookLogin _facebookLogin = FacebookLogin();
final GoogleSignIn _googleSignIn = new GoogleSignIn();

void signInWithFacebook() async {
  var facebookLoginResult =
      await _facebookLogin.logInWithReadPermissions(['email']);
  switch (facebookLoginResult.status) {
    case FacebookLoginStatus.error:
      print('Facebook login failed');
      break;
    case FacebookLoginStatus.cancelledByUser:
      print('Facebook login canceled');
      break;
    case FacebookLoginStatus.loggedIn:
      try {
        FirebaseUser firebaseUser = await _auth.signInWithFacebook(
            accessToken: facebookLoginResult.accessToken.token);
      } catch (ex, stack) {
        print(ex);
        //TODO: fix FlutterCrashlytics build issue, uncomment
        //FlutterCrashlytics().logException(ex, stack);
      }
      break;
  }
}

Future<FirebaseUser> signInWithGoogle() async {
  // Attempt to get the currently authenticated user
  GoogleSignInAccount currentUser = _googleSignIn.currentUser;
  if (currentUser == null) {
    // Attempt to sign in without user interaction
    currentUser = await _googleSignIn.signInSilently();
  }
  if (currentUser == null) {
    // Force the user to interactively sign in
    currentUser = await _googleSignIn.signIn();
  }

  final GoogleSignInAuthentication auth = await currentUser.authentication;

  // Authenticate with firebase
  final FirebaseUser user = await _auth.signInWithGoogle(
    idToken: auth.idToken,
    accessToken: auth.accessToken,
  );

  assert(user != null);
  assert(!user.isAnonymous);

  return user;
}

Future<Null> signOut() async {
  // Sign out with firebase and Facebook
  await _auth.signOut();
  // Sign out with google
  await _facebookLogin.logOut();
  await _googleSignIn.signOut();
}

void main() async {
  bool isInDebugMode = false;
  profile(() {
    isInDebugMode = true;
  });

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

  //await FlutterCrashlytics().initialize();

  runZoned<Future<Null>>(() async {
    runApp(new MyApp());
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Crashlytics depending on the environment.
    debugPrint(error.toString());
    //TODO: fix FlutterCrashlytics build issue, uncomment
    //await FlutterCrashlytics()
    //    .reportCrash(error, stackTrace, forceCrash: false);
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Biblosphere',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.teal,
      ),
      home: IntroPage(),
      routes: <String, WidgetBuilder>{
        '/main': (BuildContext context) => new MyHomePage(title: 'Biblosphere'),
      },
    );
  }
}

// Widget with into page
class IntroPage extends StatefulWidget {
  IntroPage({Key key}) : super(key: key);

  @override
  _IntroPageState createState() => new _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final pages = [
    new PageViewModel(
        pageColor: const Color(0xFF03A9F4),
        iconImageAssetPath: 'images/home.png',
        iconColor: null,
        bubbleBackgroundColor: null,
        body: Text(
          'Shoot your bookcase and share to neighbours and tourists. Your books attract likeminded people.',
        ),
        title: Text(
          'Shoot',
        ),
        textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
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
      bubbleBackgroundColor: null,
      body: Text(
        'App shows bookcases in 200 km around you sorted by distance. Get access to wide variaty of books.',
      ),
      title: Text('Surf'),
      mainImage: Image.asset(
        'images/surf.png',
//        height: 285.0,
//        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
    new PageViewModel(
      pageColor: const Color(0xFF607D8B),
      iconImageAssetPath: 'images/message.png',
      iconColor: null,
      bubbleBackgroundColor: null,
      body: Text(
        'Contact owner of the books you like and arrange appointment to get new books to read.',
      ),
      title: Text('Meet'),
      mainImage: Image.asset(
        'images/meet.png',
//        height: 285.0,
//        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
  ];

  StreamSubscription authStateChange;

  @override
  void initState() {
    super.initState();

    // Listen for our auth event (on reload or start)
    // Go to our /todos page once logged in
    authStateChange = _auth.onAuthStateChanged.listen((user) {
      print("IntroPage onAuthStateChanged User: " + user.toString());
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    });
  }

  @override
  void dispose() {
    authStateChange.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return new Builder(
      builder: (context) => new IntroViewsFlutter(
            pages,
            onTapDoneButton: () {
              Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                  builder: (context) => new LoginPage(),
                ), //MaterialPageRoute
              );
            },
            onTapSkipButton: () {
              Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                  builder: (context) => new LoginPage(),
                ), //MaterialPageRoute
              );
            },
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

// Widget with login buttons to manage Facebook, Google and SMS logins
class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  StreamSubscription authStateChange;

  @override
  void initState() {
    super.initState();

    // Listen for our auth event (on reload or start)
    // Go to our /todos page once logged in
    authStateChange = _auth.onAuthStateChanged.listen((user) {
      print("LoginPage onAuthStateChanged User: " + user.toString());
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    });
  }

  @override
  void dispose() {
    authStateChange.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return new Container(
      color: Colors.amber.shade400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GoogleSignInButton(onPressed: () {
              signInWithGoogle();
            }),
            FacebookSignInButton(onPressed: () {
              signInWithFacebook();
            }),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GeoPoint _position;
  String currentUserId;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FirebaseUser firebaseUser;
  bool unreadMessage = false;

  StreamSubscription authStateChange;

  @override
  void initState() {
    super.initState();

    _initLocationState();

    authStateChange = _auth.onAuthStateChanged.listen((user) async {
      print('Home onAuthStateChanged: USER: ' + user.toString());
      firebaseUser = await _auth.currentUser();
      currentUserId = (firebaseUser != null) ? firebaseUser.uid : null;
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("DEBUG: message received: " + message.toString());
        setState(() {
          unreadMessage = true;
        });
      },
      onResume: (Map<String, dynamic> message) {
        new Future.delayed(Duration.zero, () {
          Chat.runChat(context, currentUserId, message['sender']);
        });
      },
      onLaunch: (Map<String, dynamic> message) {
        new Future.delayed(Duration.zero, () {
          Chat.runChat(context, currentUserId, message['sender']);
        });
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    // To get new position after app became active after background
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == 'AppLifecycleState.resumed') {
        new Future.delayed(Duration.zero, () {
          _initLocationState();
        });
      }
    });

    _initUserRecord();
  }

  void _initUserRecord() async {
    try {
      //TODO: Do we need to reinitiate it each re-login. Where?
      firebaseUser = await _auth.currentUser();
      currentUserId = firebaseUser.uid;

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
      }

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
      //TODO: fix FlutterCrashlytics build issue, uncomment
      //FlutterCrashlytics().logException(ex, stack);
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _initLocationState() async {
    Position position;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      position = await Geolocator().getLastKnownPosition();
    } on PlatformException {
      position = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (position != null) {
      setState(() {
        _position = new GeoPoint(position.latitude, position.longitude);
      });
    }
  }

  Future<DocumentSnapshot> _fetchUser(String peerId) async {
    DocumentSnapshot userSnap =
        await Firestore.instance.collection('users').document(peerId).get();

    return userSnap;
  }

  @override
  void dispose() {
    authStateChange.cancel();
    super.dispose();
  }

  Widget buildItem(BuildContext context, DocumentSnapshot userSnap) {
    return Container(
      child: FlatButton(
        child: Row(children: <Widget>[
          Material(
            child: CachedNetworkImage(
              placeholder: Container(
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
                width: 50.0,
                height: 50.0,
                padding: EdgeInsets.all(15.0),
              ),
              imageUrl: userSnap['photoUrl'],
              width: 50.0,
              height: 50.0,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          new Flexible(
              child: Container(
            child: Text(
              userSnap['name'],
              style: TextStyle(color: themeColor),
            ),
            alignment: Alignment.centerLeft,
            margin: new EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 20.0),
          )),
        ]),
        onPressed: () {
          setState(() {
            unreadMessage = false;
          });
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new Chat(
                        myId: currentUserId,
                        peerId: userSnap.documentID,
                        peerAvatar: userSnap['photoUrl'],
                        peerName: userSnap['name'],
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

    return new DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          actions: <Widget>[
            new IconButton(
              onPressed: () async {
                await signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
              tooltip: 'Logout',
              icon: new Icon(Icons.exit_to_app),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.local_library)),
              Tab(
                  icon: unreadMessage
                      ? Icon(Icons.outlined_flag)
                      : Icon(Icons.message)),
            ],
          ),
          title: new Text(widget.title),
        ),
        body: TabBarView(
          children: <Widget>[
            // Camera tab
            Home(currentUserId: currentUserId),

            // Main tab with bookshelves
            new BookshelfList(currentUserId, _position),

            // Tab for chat
            Container(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('messages')
                    .where("ids", arrayContains: currentUserId)
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                        String peerId = snapshot.data.documents[index]['ids']
                            .firstWhere((id) => id != currentUserId,
                                orElse: () => null);

                        return FutureBuilder(
                          future: _fetchUser(peerId),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.active:
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return Align(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator());
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
