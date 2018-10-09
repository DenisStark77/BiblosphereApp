import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/camera.dart';
import 'package:biblosphere/bookshelf.dart';
import 'package:biblosphere/chat.dart';

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
  String currentUserId;

  @override
  void initState() {
    super.initState();

    _initLocationState();

    initiateFacebookLogin();
  }

  /* Facebook login */
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
        FirebaseUser firebaseUser = await FirebaseAuth.instance.signInWithFacebook(accessToken: facebookLoginResult.accessToken.token);
        onLoginStatusChanged(true);
        if (firebaseUser != null) {
          // Check is already sign up
          final QuerySnapshot result =
          await Firestore.instance.collection('users').where(
              'id', isEqualTo: firebaseUser.uid).getDocuments();
          final List<DocumentSnapshot> documents = result.documents;
          if (documents.length == 0) {
            // Update data to server if new user
            Firestore.instance.collection('users')
                .document(firebaseUser.uid)
                .setData(
                {
                  'name': firebaseUser.displayName,
                  'photoUrl': firebaseUser.photoUrl,
                  'id': firebaseUser.uid
                });
          }
          currentUserId = firebaseUser.uid;
        }
        break;
    }
  }

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

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
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
                  imageUrl: document['photoUrl'],
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
              new Flexible(
                child: Container(
                  child: new Column(
                    children: <Widget>[
                      new Container(
                        child: Text(
                          'Name: ${document['name']}',
                          style: TextStyle(color: themeColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: new EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      new Container(
                        child: Text(
                          '...',
                          style: TextStyle(color: themeColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: new EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new Chat(
                      myId: currentUserId,
                      peerId: document.documentID,
                      peerAvatar: document['photoUrl'],
                    )));
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
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
              Tab(icon: Icon(Icons.message)),
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

            // Tab for chat
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
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
                      itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
            ),
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
