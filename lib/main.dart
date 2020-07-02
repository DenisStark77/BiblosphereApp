import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
//import 'package:firebase_ui/flutter_firebase_ui.dart';
//import 'package:firebase_ui/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
// Debug analytics:
// adb shell setprop debug.firebase.analytics.app <package_name>
// adb shell setprop debug.firebase.analytics.app .none.

//Temporary for visual debugging
import 'package:flutter/rendering.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/home.dart';
import 'package:biblosphere/chat.dart';
import 'package:biblosphere/l10n.dart';
import 'package:biblosphere/search.dart';

//TODO: Credit page with link to author of icons:  Icon made by Freepik (http://www.freepik.com/) from www.flaticon.com

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
final FacebookLogin _facebookLogin = FacebookLogin();
final FirebaseAuth _auth = FirebaseAuth.instance;

void main() async {
  debugPaintSizeEnabled = false; //true;

  WidgetsFlutterBinding.ensureInitialized();

  await Firestore.instance.settings(persistenceEnabled: true);

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZonedGuarded<Future<Null>>(() async {
    runApp(new MyApp());
  }, (e, stack) {
    print('Exception: $e');
    print(stack);
    Crashlytics.instance.recordError(e, stack);
  });

  Purchases.setDebugLogsEnabled(true);
  // TODO: Keep API Key in security values in Firebase (Security)
  await Purchases.setup("QbXpgCrBDfUvMAEMyvVwBzhUGlIfbtdL");
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // Subscription for in-app purchases
  StreamSubscription<FirebaseUser> _listener;
  //StreamSubscription<stellar.OperationResponse> _stellar;
  // Subscription to changes for user balance
  StreamSubscription<DocumentSnapshot> _userSubscription;
  FirebaseUser firebaseUser;
  bool firstRun = true;
  bool skipIntro = false;

  @override
  void initState() {
    super.initState();

    _checkInitialState();

    _listener =
        FirebaseAuth.instance.onAuthStateChanged.listen((FirebaseUser user) {
      firebaseUser = user;

      if (firebaseUser != null) {
        firebaseUser.getIdToken(refresh: true);
        FirebaseAnalytics().setUserId(firebaseUser.uid);

        // Identify user with Purchases for In-App subscriptions
        Purchases.identify(firebaseUser.uid);

        // That's async function so need to refresh widget as soon as it completes
        _initUserRecord().then((_) {
          setState(() {});
        });
      } else {
        setState(() {
          B.user = null;
        });
      }
    });

    // TODO: build function executed 3 times: after initState, after setState in
    //       _initUserRecord and after setState in _initLocationState.
    //       Better to minimize rebuilding. For example by providing currentUser
    //       as parameter on widget push (is it possible?).
  }

  @override
  void dispose() {
    _listener.cancel();
    _userSubscription.cancel();
    //_stellar.cancel();
    super.dispose();
  }

  void _checkInitialState() async {
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
  }

  Future<void> _initUserRecord() async {
    try {
      if (firebaseUser == null)
        throw "CurrentUserId is null, login failed or not completed";

      User user = new User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName,
          photo: firebaseUser.photoUrl);

      setState(() {
        B.user = user;
      });

      // Check if user record exist
      final DocumentSnapshot userSnap = await user.ref.get();

      if (!userSnap.exists) {
        // Create user and wallet if user is not there
        await user.ref.setData(user.toJson());
      } else {
        // Update user fields from Firestore
        user = User.fromJson(userSnap.data);

        B.loginUser = user;

        // Add list of linked users
        if (user.linkedUsers != null && user.linkedUsers.length > 0) {
          List<User> list = [];

          user.linkedUsers.forEach((id) async { 
            DocumentSnapshot doc = await User.Ref(id).get();
            list.add(User.fromJson(doc.data));
          });
          
          B.linkedUsers = list;
        }

        // To suport library accounts: read library user record if currentUser is there
        if (user.currentUser != null && user.currentUser != user.id) {
          DocumentSnapshot doc = await User.Ref(user.currentUser).get();
          user = User.fromJson(doc.data);
        }

        B.user = user;
      }

      // Listen on changes to user record in Firestore and update to B.user
      _userSubscription = B.loginUser.ref.snapshots().listen((DocumentSnapshot doc) async {
        // To suport library accounts: read library user record if currentUser is there
        User user = User.fromJson(doc.data);
        B.loginUser = user;

        // Add list of linked users
        if (user.linkedUsers != null && user.linkedUsers.length > 0) {
          List<User> list = [];

          user.linkedUsers.forEach((id) async { 
            DocumentSnapshot doc = await User.Ref(id).get();
            list.add(User.fromJson(doc.data));
          });

          B.linkedUsers = list;
        }

        if (user.currentUser != null && user.currentUser != user.id) {
          DocumentSnapshot doc = await User.Ref(user.currentUser).get();
          user = User.fromJson(doc.data);
        }

        setState(() {
            B.user = user;
        });
      });

      // TODO: Listen on tokenRefresh to update token in Firestore
      // Update FCM token for notifications
      FirebaseMessaging().getToken().then((token) {
        user.ref.updateData({
          'token': token,
        });
      });

      // If refferal program link is empty generate one
      if (user.link == null) {
        // TODO: Make this call async to minimize waiting time for login
        String link = await buildLink('chat?user=${user.id}');
        user.ref.updateData({
          'link': link,
        });
      }

      // Search a book to warm Google serverless (both entries)
      searchByTitleAuthor('Not a book which exist');
      searchByIsbn('9785990174764');
    } catch (ex, stack) {
      print(ex);
      Crashlytics.instance.recordError(ex, stack);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      // Uncomment to make screenshots in simulator without debug banner
      // debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [Locale("en"), Locale("ru")],
      //onGenerateTitle: (BuildContext context) => S.of(context).title,
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
        scaffoldBackgroundColor: C.background, // Background of Scaffolds
        cardColor: C.cardBackground,
        cardTheme: CardTheme(color: C.cardBackground),
        buttonColor: C.button,
        //primaryColorLight: C.title,
        chipTheme: ChipThemeData(
            backgroundColor: C.chipUnselected, //C.chipUnselected,
            selectedColor: C.chipSelected, //C.chipSelected,
            disabledColor: Colors.red, // TODO: define color
            secondarySelectedColor: C.chipSelected, // TODO: define color
            labelPadding: EdgeInsets.all(0.0),
            padding: EdgeInsets.only(left: 7.0, right: 10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13.0),
                side: BorderSide(color: C.buttonBorder)),
            labelStyle: TextStyle(
                fontSize: 14.0, fontWeight: FontWeight.w300, color: C.chipText),
            secondaryLabelStyle: TextStyle(
                fontSize: 14.0, fontWeight: FontWeight.w300, color: C.chipText),
            brightness: Brightness.light),
        textTheme: TextTheme(
          headline5: TextStyle(fontSize: 48.0, fontWeight: FontWeight.w200),
          subtitle1: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w200),
          headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
          subtitle2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
          bodyText2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
          bodyText1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w200),
          button: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
        ),
        colorScheme: ColorScheme(
            primary: C.titleBackground,
            primaryVariant: C.titleBackground,
            secondary: C.titleBackground,
            secondaryVariant: C.titleBackground,
            surface: Colors.black12,
            error: Colors.red,
            background: C.titleBackground,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: Colors.black,
            onError: Colors.yellow,
            onSurface: Colors.lightBlueAccent,
            brightness: Brightness.light),
        brightness: Brightness.light,
        primaryColor: C.titleBackground,
        backgroundColor: C.background,
        accentColor: Colors.teal[600],
//        primarySwatch: Colors.green,
      ),
      home: new Builder(builder: (context) {
        if (!skipIntro && B.user == null) {
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
        } else if (B.user == null) {
          return new Scaffold(
              appBar: AppBar(
                  title: Text(S.of(context).welcome,
                      style: Theme.of(context).textTheme.headline6),
                  centerTitle: true),
              body: Center(
                  child: Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        style: Theme.of(context).textTheme.bodyText2,
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
                    )),
                SignInButton(
                  Buttons.Google,
                  padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                  onPressed: () {
                    _handleGoogleSignIn(context);
                  },
                ),
                SignInButton(
                  Buttons.Facebook,
                  padding: EdgeInsets.all(10.0),
                  onPressed: () {
                    _handleFBSignIn(context);
                  },
                ),
              ])));

/*
          return new SignInScreen(
            avoidBottomInset: true,
            bottomPadding: 10.0,
            horizontalPadding: 20.0,
            title: S.of(context).welcome,
            showBar: true,
            header: new Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new Container(
                  padding: EdgeInsets.all(5.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: new TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
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
              ProvidersTypes.email,
              ProvidersTypes.phone,
//          ProvidersTypes.twitter,
//          ProvidersTypes.phone,
//          ProvidersTypes.email
            ],
          );
*/
        } else {
          return MyHomePage();
        }
      }),
      onGenerateRoute: _getRoute,
    );
  }

  Future<FirebaseUser> _handleGoogleSignIn(BuildContext context) async {
    try {
      // If connected to Firebase sign out
      if (await _auth.currentUser() != null) {
        await signOutProviders();
      }

      // If not connected to Firebase but signed in to Google then sign out
      if (await _auth.currentUser() == null &&
          await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // If Google current user is not null but not signed-in then sign out (warkaround)
      if (_googleSignIn.currentUser != null &&
          !await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;
        if (googleAuth.accessToken != null) {
          AuthCredential credential = GoogleAuthProvider.getCredential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
          AuthResult authResult = await _auth.signInWithCredential(credential);
          FirebaseUser user = authResult.user;
          return user;
        }
      }
    } catch (e, stack) {
      print('Sign-in failed: ${e}');
      showSnackBar(context, 'Sign-in failed: ${e}');
      Crashlytics.instance.recordError(e, stack);
    }
    return null;
  }

  Future<FirebaseUser> _handleFBSignIn(BuildContext context) async {
    try {
      // If connected to Firebase sign out
      if (await _auth.currentUser() != null) {
        await signOutProviders();
      }
      // Logout from FB if not signed in to Firebase
      // (to ensure that previous incomplete login is canceled)
      if (await _auth.currentUser() == null &&
          await _facebookLogin.isLoggedIn) {
        await _facebookLogin.logOut();
      }

      FacebookLoginResult facebookLoginResult =
          await _facebookLogin.logIn(['email']);
      switch (facebookLoginResult.status) {
        case FacebookLoginStatus.cancelledByUser:
          break;
        case FacebookLoginStatus.error:
          showSnackBar(
              context, 'Sign-in error: ${facebookLoginResult.errorMessage}');
          break;
        case FacebookLoginStatus.loggedIn:
          break;
      }

      if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
        final accessToken = facebookLoginResult.accessToken.token;
        AuthCredential facebookAuthCred =
            FacebookAuthProvider.getCredential(accessToken: accessToken);
        AuthResult authResult =
            await _auth.signInWithCredential(facebookAuthCred);
        return authResult.user;
      }
    } catch (e, stack) {
      print('Sign-in failed: ${e}');
      showSnackBar(context, 'Sign-in failed: ${e}');
      Crashlytics.instance.recordError(e, stack);
    }
    return null;
  }

  Route _getRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/chat':
        return _buildRoute(
            settings,
            new Chat(
              partner: settings.arguments as User,
            ));
      default:
        return null;
    }
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return new MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
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
          body: Text(S.of(context).introShootHint,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .apply(color: Colors.white)),
          title: Text(S.of(context).introShoot,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(color: Colors.white)),
          textStyle: TextStyle(color: Colors.white),
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
        body: Text(S.of(context).introSurfHint,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .apply(color: Colors.white)),
        title: Text(S.of(context).introSurf,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .apply(color: Colors.white)),
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
        body: Text(S.of(context).introMeetHint,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .apply(color: Colors.white)),
        title: Text(S.of(context).introMeet,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .apply(color: Colors.white)),
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
        showSkipButton: true, //Whether you want to show the skip button or not.
        pageButtonTextStyles: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ), //IntroViewsFlutter
    );
  }
}
