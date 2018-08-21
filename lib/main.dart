import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'camera.dart';
import 'bookshelf.dart';

// TODO: Add Firebase authentication and change rules in Firebase Storge console

Position position;

void main() async {
  cameras = await availableCameras();

  runApp(new MyApp());
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
      home: new MyHomePage(title: 'Biblosphere'),
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

  final Geolocator _geolocator = Geolocator();
  Position _position;

  @override
  void initState() {
    super.initState();

    _initLocationState();

  //  initiateFacebookLogin();
  }

  /* Facebook login */
  /*
  bool isLoggedIn = false;

  void onLoginStatusChanged(bool isLoggedIn) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
    });
  }


  void initiateFacebookLogin() async {
    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
    await facebookLogin.logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        onLoginStatusChanged(true);
        break;
    }
  }
*/

  // Platform messages are asynchronous, so we initialize in an async method.
  void _initLocationState() async {
    Position position;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      position = await _geolocator.getLastKnownPosition(LocationAccuracy.high);
    } on PlatformException {
      position = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _position = position;
    });
  }

@override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final position = _position == null
        ? 'Unknown'
        : _position.latitude.toString() + ', ' + _position.longitude.toString();

    return new DefaultTabController(
        length: 3,
        child: Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add_a_photo)),
              Tab(icon: Icon(Icons.local_library)),
              Tab(icon: Icon(Icons.monetization_on)),
            ],
          ),
          title: new Text(widget.title),
          actions: <Widget>[
            new FlatButton(onPressed: () {}, child: Text("1 km")),
          ],
        ),
        body: TabBarView(
          children: <Widget> [
            // Camera tab
            CameraHome(),

            // Main tab with bookshelves
            new BookshelfList(),

            // Tab with Donate
            new Column(
              children: <Widget>[
                new Text("Here you will earn money by sharing your books. However to reach this stage we have to complete this app and do marketing to get high demand for book rental. Once people start renting books via Biblosphere it will be source of income for you. Please support us now to make this app source of your fun and income."
                          +"  \nPosition: $position",
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontWeight: FontWeight.bold),),
                new RaisedButton(onPressed: () {}, child: new Text ("Donate")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
