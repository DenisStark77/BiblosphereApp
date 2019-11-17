import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/flutter_firebase_ui.dart';
import 'package:firebase_ui/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
//Temporary for visual debugging
import 'package:flutter/rendering.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/helpers.dart';
import 'package:biblosphere/lifecycle.dart';
import 'package:biblosphere/payments.dart';
import 'package:biblosphere/home.dart';
import 'package:biblosphere/chat.dart';
import 'package:biblosphere/l10n.dart';

//TODO: Credit page with link to author of icons:  Icon made by Freepik (http://www.freepik.com/) from www.flaticon.com

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() async {
  bool isInDebugMode = false;
  debugPaintSizeEnabled = false; //true;

  WidgetsFlutterBinding.ensureInitialized();

  await Firestore.instance.settings(persistenceEnabled: true);

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

  // TODO: Didn't work on WEB
  if (!kIsWeb) {
    await FlutterCrashlytics().initialize();
  }

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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // Subscription for in-app purchases
  StreamSubscription<List<PurchaseDetails>> _subscription;
  StreamSubscription<FirebaseUser> _listener;
  //StreamSubscription<stellar.OperationResponse> _stellar;
  // Subscription to changes for user balance
  StreamSubscription<DocumentSnapshot> _walletSubscription;
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
        return;
      },
      onResume: (Map<String, dynamic> message) {
        return new Future.delayed(Duration.zero, () {
          // TODO: Change sender to chat id
          Chat.runChatById(context, null, chatId: message['chat']);
        });
      },
      onLaunch: (Map<String, dynamic> message) {
        return new Future.delayed(Duration.zero, () {
          // TODO: Change sender to chat id
          Chat.runChatById(context, null, chatId: message['chat']);
        });
      },
    );

    // TODO: Didn't work on WEB
    if (!kIsWeb) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));

      // TODO: build function executed 3 times: after initState, after setState in
      //       _initUserRecord and after setState in _initLocationState.
      //       Better to minimize rebuilding. For example by providing currentUser
      //       as parameter on widget push (is it possible?).
    }

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
            double amount = double.parse(purchase.productID);

            // Create an operation and update user balance
            await payment(
                user: B.user,
                amount: amount,
                type: OperationType.InputInApp);
          }
        });
      });
    }

    getPaymentContext();
  }

  @override
  void dispose() {
    _listener.cancel();
    _subscription.cancel();
    _walletSubscription.cancel();
    //_stellar.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && B.user != null) {
      new Future.delayed(Duration.zero, () async {
        final position = await currentPosition();
        setState(() {
          // Update position after the resume
          B.user = B.user..position = position;
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

        firebaseUser = user;

        if (firebaseUser != null) {
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
  }

  Future<void> _initUserRecord() async {
    try {
      if (firebaseUser == null)
        throw "CurrentUserId is null, login failed or not completed";

      User user = new User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName,
          photo: firebaseUser.photoUrl,
          position: await currentPosition());

      Wallet wallet = new Wallet(id: firebaseUser.uid);

      // Check if user record exist
      final DocumentSnapshot userSnap = await user.ref.get();

      if (!userSnap.exists) {
        // Create user and wallet if user is not there
        await B.user.ref.setData(user.toJson());

        // TODO: ensure if it works with data persistently
        await wallet.ref.setData(wallet.toJson());
      } else {
        // Update user fields from Firestore
        user = User.fromJson(userSnap.data);

        if (user.currency != null &&
            xlmRates[B.currency] != null) {
          B.currency = user.currency;
        }

        // Update balance and blocked
        final DocumentSnapshot walletSnap = await wallet.ref.get();

        if (!walletSnap.exists) {
          // Create wallet if not exist (case for old users)
          await wallet.ref.setData(wallet.toJson());
        } else {
          // Read wallet if exist
          wallet = Wallet.fromJson(walletSnap.data);
        }
      }

      // TODO: Cancel subscription befor log out (Exception PERMISSION_DENIED)
      _walletSubscription =
          wallet.ref.snapshots().listen((DocumentSnapshot doc) {
        setState(() {
          B.wallet = Wallet.fromJson(doc.data);
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

      // If refferal program link is empty generate one
      if (user.link == null) {
        // TODO: Make this call async to minimize waiting time for login
        user.link = await buildLink('chat?user=${user.id}');
      }

      // Set global value to user
      B.wallet = wallet;
      B.user = user;

      user.ref.updateData(user.toJson());
    } catch (ex, stack) {
      print(ex);
      FlutterCrashlytics().logException(ex, stack);
    }
  }

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
            selectedColor: C.chipSelected,//C.chipSelected,
            disabledColor: Colors.red, // TODO: define color
            secondarySelectedColor: Colors.black, // TODO: define color
            labelPadding: EdgeInsets.all(0.0),
            padding: EdgeInsets.only(left: 7.0, right: 10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            labelStyle: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: C.chipText),
            secondaryLabelStyle:
                TextStyle(fontSize: 14.0, fontWeight: FontWeight.w200, color: Colors.white),
            brightness: Brightness.light),
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 48.0, fontWeight: FontWeight.w700),
          subhead: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w500),
          title: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
          subtitle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
          body1: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
          body2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w200),
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
          return MyHomePage();
        }
      }),
      onGenerateRoute: _getRoute,
    );
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
          body: Text(S.of(context).introShootHint),
          title: Text(S.of(context).introShoot),
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
        showSkipButton: true, //Whether you want to show the skip button or not.
        pageButtonTextStyles: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ), //IntroViewsFlutter
    );
  }
}
