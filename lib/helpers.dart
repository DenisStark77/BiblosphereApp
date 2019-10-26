import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

import 'package:biblosphere/l10n.dart';
import 'package:biblosphere/const.dart';


final themeColor = new Color(0xfff5a623);
final primaryColor = new Color(0xff203152);
final greyColor = new Color(0xffaeaeae);
final greyColor2 = new Color(0xffE8E8E8);

void showBbsDialog(BuildContext context, String text) {
  showDialog<Null>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          child: Row(children: <Widget>[
            Material(
              child: Image.asset(
                'images/Librarian50x50.jpg',
                width: 50.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            new Flexible(
              child: Container(
                child: new Container(
                  child: Text(
                    text,
                    style: TextStyle(color: themeColor),
                  ),
                  alignment: Alignment.centerLeft,
                  margin: new EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                ),
                margin: EdgeInsets.only(left: 5.0),
              ),
            ),
          ]),
          height: 50.0,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(S.of(context).ok),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

String chatId(String user1, String user2) {
  if (user1.hashCode <= user2.hashCode) {
    return '$user1-$user2';
  } else {
    return '$user2-$user1';
  }
}

Future<bool> showBbsConfirmation(BuildContext context, String text) async {
  return (await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          child: Row(children: <Widget>[
            Material(
              child: Image.asset(
                'images/Librarian50x50.jpg',
                width: 50.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            new Flexible(
              child: Container(
                child: new Container(
                  child: Text(
                    text,
                    style: TextStyle(color: themeColor),
                  ),
                  alignment: Alignment.centerLeft,
                  margin: new EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                ),
                margin: EdgeInsets.only(left: 5.0),
              ),
            ),
          ]),
          height: 50.0,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(S.of(context).yes),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          FlatButton(
            child: Text(S.of(context).no),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  ));
}

Future<GeoPoint> currentPosition() async {
  try {
    final position = await Geolocator().getLastKnownPosition();
    return new GeoPoint(position.latitude, position.longitude);
  } on PlatformException {
    print("POSITION: GeoPisition failed");
    return null;
  }
}

Future<GeoFirePoint> currentLocation() async {
  try {
    final position = await Geolocator().getLastKnownPosition();
    return Geoflutterfire()
        .point(latitude: position.latitude, longitude: position.longitude);
  } on PlatformException {
    print("POSITION: GeoPisition failed");
    return null;
  }
}

typedef Widget CardCallback(DocumentSnapshot document, User user);

MaterialPageRoute cardListPage(
    {User user,
      Stream stream,
      CardCallback mapper,
      String title,
      String empty}) {
  return new MaterialPageRoute(
      builder: (context) => new Scaffold(
          appBar: new AppBar(
            title: new Text(
              title,
              style:
              Theme.of(context).textTheme.title.apply(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: new StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text(S.of(context).loading);
                  default:
                    if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
                      return Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            empty,
                            style: Theme.of(context).textTheme.body1,
                          ));
                    }
                    return new ListView(
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return mapper(document, user);
                      }).toList(),
                    );
                }
              })));
}

showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    /*
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change!
      },
    ),
    */
  );

// Find the Scaffold in the Widget tree and use it to show a SnackBar!
  Scaffold.of(context).showSnackBar(snackBar);
}

Scaffold buildScaffold(BuildContext context, String title, Widget body) {
  return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          title,
          style: Theme.of(context).textTheme.title.apply(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: body);
}

double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
  double R = 6378.137; // Radius of earth in KM
  double dLat = lat2 * math.pi / 180 - lat1 * math.pi / 180;
  double dLon = lon2 * math.pi / 180 - lon1 * math.pi / 180;
  double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  double d = R * c;
  return d; // meters
}

Widget bookImage(Book book, double size, {padding = 3.0}) {
  if (book == null)
    return Container(width: size + 2*padding,);
  else
    return new Container(
        margin: EdgeInsets.all(padding),
        child: Image(
            image: new CachedNetworkImageProvider(
                (book.image != null && book.image.isNotEmpty)
                    ? book.image
                    : nocoverUrl),
            width: size,
            fit: BoxFit.cover));
}

Widget userPhoto(User user, double size, {double padding = 0.0}) {
  if (user == null) {
    return Container();
  } else {
    return Container(
        margin: EdgeInsets.all(padding),
        width: size,
        height: size,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image: new CachedNetworkImageProvider(user.photo))));
  }
}

typedef BookrecordWidgetBuilder = Widget Function(
    BuildContext context, Bookrecord bookrecord);

class BookrecordWidget extends StatefulWidget {
  BookrecordWidget(
      {Key key,
        @required this.bookrecord,
        @required this.currentUser,
        @required this.builder,
        this.filter = const {}})
      : super(key: key);

  final Bookrecord bookrecord;
  final User currentUser;
  final BookrecordWidgetBuilder builder;
  final Set<String> filter;

  @override
  _BookrecordWidgetState createState() => new _BookrecordWidgetState(
      bookrecord: bookrecord, currentUser: currentUser, builder: builder);
}

class _BookrecordWidgetState extends State<BookrecordWidget> {
  Bookrecord bookrecord;
  User currentUser;
  final BookrecordWidgetBuilder builder;

  @override
  void initState() {
    super.initState();
    bookrecord.getBookrecord(currentUser).whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  _BookrecordWidgetState({
    Key key,
    @required this.bookrecord,
    @required this.currentUser,
    @required this.builder,
  });

  @override
  void didUpdateWidget(BookrecordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentUser.id != widget.currentUser.id) {
      currentUser = widget.currentUser;
    }

    if (oldWidget.bookrecord.id != widget.bookrecord.id) {
      bookrecord = widget.bookrecord;
      if (!bookrecord.hasData)
        bookrecord.getBookrecord(currentUser).whenComplete(() {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookrecord == null ||
        !bookrecord.hasData ||
        bookrecord.book == null ||
        bookrecord.book.keys == null ||
        !bookrecord.book.keys.containsAll(widget.filter)) {
      return Container(width: 0.0, height: 0.0);
    } else {
      return builder(context, bookrecord);
    }
  }
}

double dp(double val, int places){
  double mod = math.pow(10.0, places);
  return ((val * mod).round().toDouble() / mod);
}

String money(double amount) {
  return '${(new NumberFormat("##0.00")).format(amount ?? 0)} \u{03BB}';
}
