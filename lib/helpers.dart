import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flushbar/flushbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';

import 'package:biblosphere/l10n.dart';
import 'package:biblosphere/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

showSnackBar(BuildContext context, String text, {FlatButton button}) {
  if (button != null)
    Flushbar(
      message: text,
      mainButton: button,
      duration: Duration(seconds: 3),
    )..show(context);
  else
    Flushbar(
      message: text,
      duration: Duration(seconds: 3),
    )..show(context);
}

Scaffold buildScaffold(BuildContext context, String title, Widget body,
    {appbar: true}) {
  if (appbar)
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            title,
            style: Theme.of(context).textTheme.title.apply(color: C.titleText),
          ),
          centerTitle: true,
        ),
        body: body);
  else
    return new Scaffold(body: body);
}

Widget bookImage(dynamic book, double size,
    {padding = 3.0, sameHeight = false, String tooltip = ''}) {
  String image;
  if (book is Book) {
    image = book.image;
    tooltip = book.authors.join(',') + '\n' + book.title;
  } else if (book is Bookrecord) {
    image = book.image;
    tooltip = book.authors.join(',') + '\n' + book.title;
  } else if (book is String) image = book;

  if (sameHeight)
    return new Container(
        margin: EdgeInsets.all(padding),
        child: new Tooltip(
            message: tooltip,
            child: Image(
                image: new CachedNetworkImageProvider(
                    (image != null && image.isNotEmpty && image != '')
                        ? image
                        : nocoverUrl),
                height: size,
                fit: BoxFit.cover)));
  else
    return new Container(
        margin: EdgeInsets.all(padding),
        child: new Tooltip(
            message: tooltip,
            child: Image(
                image: new CachedNetworkImageProvider(
                    (image != null && image.isNotEmpty && image != '')
                        ? image
                        : nocoverUrl),
                width: size,
                fit: BoxFit.cover)));
}

Widget userPhoto(dynamic user, double size, {double padding = 0.0}) {
  ImageProvider provider;

  if (user is AssetImage)
    provider = user;
  else if (user is User && user.photo != null)
    provider = CachedNetworkImageProvider(user.photo);
  else if (user is String && user != null)
    provider = CachedNetworkImageProvider(user);
  else
    provider = AssetImage(account_100);

  return Container(
      margin: EdgeInsets.all(padding),
      width: size,
      height: size,
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(fit: BoxFit.fill, image: provider)));
}

typedef BookrecordWidgetBuilder = Widget Function(
    BuildContext context, Bookrecord bookrecord);

class BookrecordWidget extends StatefulWidget {
  BookrecordWidget(
      {Key key,
      @required this.bookrecord,
      @required this.builder,
      this.filter = const {}})
      : super(key: key);

  final Bookrecord bookrecord;
  final BookrecordWidgetBuilder builder;
  final Set<String> filter;

  @override
  _BookrecordWidgetState createState() =>
      new _BookrecordWidgetState(bookrecord: bookrecord, builder: builder);
}

class _BookrecordWidgetState extends State<BookrecordWidget> {
  Bookrecord bookrecord;
  final BookrecordWidgetBuilder builder;
  StreamSubscription<Bookrecord> _listener;

  @override
  void initState() {
    super.initState();

    // Listen updated on bookrecord and refresh Widget
    _listener = bookrecord.snapshots().listen((rec) {
      setState(() {});
    });
  }

  _BookrecordWidgetState({
    Key key,
    @required this.bookrecord,
    @required this.builder,
  });

  @override
  void dispose() {
    if (_listener != null) _listener.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(BookrecordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.bookrecord.id != widget.bookrecord.id) {
      bookrecord = widget.bookrecord;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookrecord == null || !bookrecord.keys.containsAll(widget.filter)) {
      return Container(width: 0.0, height: 0.0);
    } else {
      return builder(context, bookrecord);
    }
  }
}

typedef UserWidgetBuilder = Widget Function(
    BuildContext context, User user, Wallet wallet);

class UserWidget extends StatefulWidget {
  UserWidget({Key key, @required this.user, @required this.builder})
      : super(key: key);

  final User user;
  final UserWidgetBuilder builder;

  @override
  _UserWidgetState createState() =>
      new _UserWidgetState(user: user, builder: builder);
}

class _UserWidgetState extends State<UserWidget> {
  User user;
  Wallet wallet;
  final UserWidgetBuilder builder;

  @override
  void initState() {
    super.initState();
    getUserDetails().whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  _UserWidgetState({
    Key key,
    @required this.user,
    @required this.builder,
  });

  @override
  void didUpdateWidget(UserWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.user.id != widget.user.id) {
      user = widget.user;
      getUserDetails().whenComplete(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Container(width: 0.0, height: 0.0);
    } else {
      return builder(context, user, wallet);
    }
  }

  Future<void> getUserDetails() async {
    wallet = Wallet(id: user.id);
    final DocumentSnapshot snap = await wallet.ref.get();

    if (snap.exists) wallet = Wallet.fromJson(snap.data);

    return;
  }
}

double dp(double val, int places) {
  double mod = math.pow(10.0, places);
  return ((val * mod).round().toDouble() / mod);
}

dynamic distance(double d) {
  if (d == null || d.isInfinite || d.isNaN)
    return 50000;
  else if (d < 0.1)
    return dp(d, 2);
  else if (d < 1.0)
    return dp(d, 1);
  else
    return d.round();
}

/* Template for SliverList

    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        // Provide a standard title.
        title: Text(S.of(context).addbookTitle),
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
                ])),
        // Make the initial height of the SliverAppBar larger than normal.
        expandedHeight: 200,
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Container();
        }, childCount: COUNT),
      )
    ]);
*/

// Function return chat record (create if needed) and transit book record
Future<Messages> doTransit(
    {@required BuildContext context,
    @required Messages chat,
    String bookrecordId}) async {
  assert(chat.complete && !chat.system && bookrecordId != null);

  Bookrecord rec;

  DocumentSnapshot snap = await Bookrecord.Ref(bookrecordId).get();

  if (!snap.exists) {
    showSnackBar(context, S.of(context).snackBookNotFound);
  } else {
    rec = Bookrecord.fromJson(snap.data);

    // If book belong to current user do nothing
    if (rec.holderId == chat.to)
      rec = null;
    else if (rec.transit == true) {
      // Book already in transit with another user
      showSnackBar(context, S.of(context).snackBookAlreadyInTransit);
      rec = null;
    }
  }

  if (rec != null) {
    // If previous deal is completed reset it
    if (chat.status == Messages.Complete) {
      chat.reset();
    }

    if (chat.status == Messages.Initial) {
      chat.books.add(bookrecordId);
      await chat.ref.updateData({
        'books': FieldValue.arrayUnion([bookrecordId]),
        'status': chat.status
      });
    } else {
      // Only add book in Initial status (in Handover fails - null)
      if (chat.toId == B.user.id)
        showSnackBar(context, S.of(context).snackBookNotConfirmed);
      else
        showSnackBar(context, S.of(context).snackBookPending);

      // Previous exchange not confirmed. Could not open a new one
      rec = null;
    }
  }

  // TODO: do it in transaction to avoid simultaneous update to transit
  // by different users

  // Update bookrecord (link to chat)
  if (rec != null) {
    showSnackBar(context, S.of(context).snackBookAddedToCart);

    await rec.ref.updateData({
      'transit': true,
      'transitId': chat.toId,
      'users': FieldValue.arrayUnion([chat.toId]),
      'chatId': chat.id
    });

    // Log book request ad return events
    logAnalyticsEvent(name: 'add_to_cart', parameters: <String, dynamic>{
      'isbn': rec.isbn,
      'type': (chat.toId == rec.owner) ? 'return' : 'request',
      'by': (B.user.id == rec.holderId) ? 'holder' : 'peer',
      'from': chat.fromId,
      'to': chat.toId,
      'distance': rec.distance == double.infinity ? 50000.0 : rec.distance,
    });
  }

  return chat;
}

Future<String> buildLink(String query,
    {String image, String title, String description}) async {
  SocialMetaTagParameters socialMetaTagParameters;

  if (image != null)
    socialMetaTagParameters = SocialMetaTagParameters(
        title: title, description: description, imageUrl: Uri.parse(image));

  final DynamicLinkParameters parameters = new DynamicLinkParameters(
    uriPrefix: 'https://biblosphere.page.link',
    link: Uri.parse('https://biblosphere.org/${query}'),
    androidParameters: AndroidParameters(
      packageName: 'com.biblosphere.biblosphere',
      minimumVersion: 0,
    ),
    dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
    ),
    iosParameters: IosParameters(
      bundleId: 'com.biblosphere.biblosphere',
      minimumVersion: '0',
    ),
    // TODO: S.of(context) does not work as it's a top Widget MyApp
    socialMetaTagParameters: socialMetaTagParameters,
    navigationInfoParameters:
        NavigationInfoParameters(forcedRedirectEnabled: true),
  );

  final ShortDynamicLink shortLink = await parameters.buildShortLink();

  return shortLink.shortUrl.toString();
}

Future<void> injectChatbotMessage(
    BuildContext context, String myId, Messages chat, String content) async {
  DateTime time = DateTime.now();
  time = time.add(time.timeZoneOffset);
  // ToAdd 1 to avoid same id for chatbot response
  int timestamp = time.millisecondsSinceEpoch + 1;

  // Add message
  var msgRef = Firestore.instance
      .collection('messages')
      .document(chat.id)
      .collection(chat.id)
      .document(timestamp.toString());

  Firestore.instance.runTransaction((transaction) async {
    await transaction.set(msgRef, {
      'idTo': myId,
      'idFrom': 'system',
      'timestamp': timestamp.toString(),
      'content': content,
      'type': 0
    });
  });

  Firestore.instance.runTransaction((transaction) async {
    DocumentSnapshot snap = await chat.ref.get();
    if (snap.exists) {
      await transaction.update(
        chat.ref,
        {
          'message': content.length < 20
              ? content
              : content.substring(0, 20) + '\u{2026}',
          'timestamp': timestamp.toString(),
          'unread': {myId: chat.unread[myId] + 1, 'system': 0}
        },
      );
    }
  });

  return;
}

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FacebookLogin _facebookLogin = FacebookLogin();

Future<void> signOutProviders() async {
  var currentUser = await FirebaseAuth.instance.currentUser();
  if (currentUser != null) {
    await signOut(currentUser.providerData);
  }

  return await FirebaseAuth.instance.signOut();
}

Future<dynamic> signOut(Iterable providers) async {
  return Future.forEach(providers, (p) async {
    switch (p.providerId) {
      case 'facebook.com':
        await _facebookLogin.logOut();
        break;
      case 'google.com':
        await _googleSignIn.signOut();
        break;
    }
  });
}

Future<void> refreshLocation(BuildContext context) {
  return Geolocator().checkGeolocationPermissionStatus().then((status) async {
    if (status == GeolocationStatus.denied ||
        status == GeolocationStatus.unknown)
      showSnackBar(context, S.of(context).snackAllowLocation,
          button: FlatButton(
              child: Text('OK',
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .apply(color: Colors.white)),
              onPressed: AppSettings.openAppSettings));

    if (status == GeolocationStatus.granted ||
        status == GeolocationStatus.denied ||
        status == GeolocationStatus.unknown) {
      GeoPoint position = await currentPosition();

      if (position == null && status == GeolocationStatus.unknown) {
        status = await Geolocator().checkGeolocationPermissionStatus();
        position = await currentPosition();
      }

      if (position != null) {
        B.user = (B.user..position = position);

        if (B.locality == null || B.country == null) {
          Geolocator()
              .placemarkFromCoordinates(position.latitude, position.longitude,
                  localeIdentifier: 'en')
              .then((placemarks) {
            B.locality = placemarks.first.locality;
            B.country = placemarks.first.country;
          });
        }
      }
    }
  });
}

void logAnalyticsEvent({String name, Map<String, dynamic> parameters}) {
  if (B.position != null)
    parameters.addAll({
      'latitude': B?.position?.latitude,
      'longitude': B?.position?.longitude
    });

  if (B.locality != null) parameters.addAll({'locality': B?.locality});

  if (B.country != null)
    parameters.addAll({
      'country': B.country,
    });

  analytics.logEvent(name: name, parameters: parameters);
}
