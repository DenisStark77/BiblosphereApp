import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flushbar/flushbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
                  Theme.of(context).textTheme.headline6.apply(color: Colors.white),
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
                            style: Theme.of(context).textTheme.bodyText2,
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

showSnackBar(BuildContext context, String text, {FlatButton button, int duration=3}) {
  if (button != null)
    Flushbar(
      message: text,
      mainButton: button,
      duration: Duration(seconds: duration),
    )..show(context);
  else
    Flushbar(
      message: text,
      duration: Duration(seconds: 3),
    )..show(context);
}

Map<String, Route> singleRoutes = {};

pushSingle(BuildContext context, Route route, String key) {
  if (singleRoutes[key] != null)
    try {
      Navigator.removeRoute(context, singleRoutes[key]);
      //print('!!!DEBUG: route removed');
    } catch (e, stack) {
      //print('!!!DEBUG: failed to removeRoute');
      Crashlytics.instance.recordError(e, stack);
    }

  // Keep Route for the key
  singleRoutes[key] = route;

  // Remove key if Route completed in a normal way
  return Navigator.push(context, route).then((value) {
    //print('!!!DEBUG push completed: $value');
    singleRoutes[key] = null;
  });
}


Scaffold buildScaffold(BuildContext context, String title, Widget body,
    {appbar: true}) {
  if (appbar)
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            title,
            style: Theme.of(context).textTheme.headline6.apply(color: C.titleText),
          ),
          centerTitle: true,
        ),
        body: body);
  else
    return new Scaffold(body: body);
}

Widget bookImage(dynamic book, double size,
    {padding = const EdgeInsets.all(3.0), sameHeight = false, String tooltip = ''}) {
  String image;
  if (book is Book) {
    image = book.image;
    if (book.authors != null && book.title != null)
      tooltip = book.authors.join(',') + '\n' + book.title;
  } else if (book is Bookrecord) {
    image = book.image;
    if (book.authors != null && book.title != null)
      tooltip = book.authors.join(',') + '\n' + book.title;
  } else if (book is String) image = book;

  if (sameHeight)
    return new Container(
        margin: padding,
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
        margin: padding,
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

Widget shelfImage(Shelf shelf, double size,
    {padding = const EdgeInsets.all(3.0)}) {
  String image;

  return new Container(
        margin: padding,
            child: Image(
                image: shelf.localImage != null ? FileImage(File(shelf.localImage))
                   :  new CachedNetworkImageProvider(
                    (image != null && image.isNotEmpty && image != '')
                        ? image
                        : nocoverUrl),
                width: size,
                fit: BoxFit.cover));
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
    BuildContext context, User user);

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
  final UserWidgetBuilder builder;

  @override
  void initState() {
    super.initState();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Container(width: 0.0, height: 0.0);
    } else {
      return builder(context, user);
    }
  }
}

typedef ShelfWidgetBuilder = Widget Function(
    BuildContext context, Shelf bookrecord, double value);

class ShelfWidget extends StatefulWidget {
  ShelfWidget(
      {Key key,
      @required this.shelf,
      @required this.builder})
      : super(key: key);

  final Shelf shelf;
  final ShelfWidgetBuilder builder;

  @override
  _ShelfWidgetState createState() =>
      new _ShelfWidgetState(shelf: shelf, builder: builder);
}

class _ShelfWidgetState extends State<ShelfWidget> {
  Shelf shelf;
  final ShelfWidgetBuilder builder;
  StreamSubscription<DocumentSnapshot> _listener;
  Timer timer;
  double value = 0.0;

  Map<RecognitionStatus, double> limits = {
    RecognitionStatus.None: 0.0, 
    RecognitionStatus.Upload: 0.3,
    RecognitionStatus.Scan: 0.5, 
    RecognitionStatus.Outline: 0.62,
    RecognitionStatus.CatalogsLookup: 0.75, 
    RecognitionStatus.Rescan: 0.95, 
    RecognitionStatus.Store: 1.0,
    RecognitionStatus.Completed: 1.0, 
    RecognitionStatus.Failed: 1.0, 
  };

  Map<RecognitionStatus, double> initial = {
    RecognitionStatus.None: 0.0, 
    RecognitionStatus.Upload: 0.0,
    RecognitionStatus.Scan: 0.3, 
    RecognitionStatus.Outline: 0.5,
    RecognitionStatus.CatalogsLookup: 0.62, 
    RecognitionStatus.Rescan: 0.75, 
    RecognitionStatus.Store: 0.95,
    RecognitionStatus.Completed: 1.0, 
    RecognitionStatus.Failed: 1.0, 
  };

  @override
  void initState() {
    super.initState();

    initListener();

    timer = Timer.periodic(Duration(seconds: 3), (time) {
      value += 0.025;
      if (value > limits[shelf.status])
         value = limits[shelf.status]; 
      //print('!!!DEBUG ticker value: ${value} with ${shelf.status}');
      setState(() {});
    });
  }

  void initListener() {
    if (_listener != null) _listener.cancel();

    // Listen updated on bookrecord and refresh Widget
    _listener = shelf.ref.snapshots().listen((doc) {
      if (doc.data['status'] != null && doc.data['status'] is int) {
        shelf.status = RecognitionStatus.values.elementAt(doc.data['status']);
        value = initial[shelf.status];
        if (shelf.status == RecognitionStatus.Failed || shelf.status == RecognitionStatus.Completed || shelf.status == RecognitionStatus.None )
           timer.cancel();
      }
      shelf.total = doc.data['total'] ?? 0;
      shelf.recognized = doc.data['recognized'] ?? 0;
      setState(() {});
    });
  }


  _ShelfWidgetState({
    Key key,
    @required this.shelf,
    @required this.builder,
  });

  @override
  void dispose() {
    if (_listener != null) _listener.cancel();
    if(timer.isActive) 
        timer.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ShelfWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shelf.id != widget.shelf.id) {
      shelf = widget.shelf;
      initListener();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (shelf == null) {
      return Container(width: 0.0, height: 0.0);
    } else {
      return builder(context, shelf, value);
    }
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

Future<String> buildLink(String query,
    {String image, String title, String description}) async {
  SocialMetaTagParameters socialMetaTagParameters;

  if (image != null)
    socialMetaTagParameters = SocialMetaTagParameters(
        title: title, description: description, imageUrl: Uri.parse(image));

  final DynamicLinkParameters parameters = new DynamicLinkParameters(
    uriPrefix: 'https://biblosphere.org/link',
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
                      .bodyText2
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


double total(double price) {
  return price * 1.2;
}

double monthly(double price) {
  return total(price) * 30 / rentDuration();
}

// Monthly income for the book owner
double income(double price) {
  return price * 30 / rentDuration();
}

double first(double price) {
  return price / 6;
}

double fee(double price) {
  return price * 0.2;
}

double bbsFee(double fee) {
  return fee * 0.5;
}

double beneficiary1(double fee) {
  return fee * 0.15;
}

double beneficiary2(double fee) {
  return fee * 0.10;
}

int rentDuration() {
  return 183;
}

double payout(amount) => amount * 0.8;

double payoutFee(amount) => amount * 0.2;

Future<int> wishlistAllowance() async {
  try {
    PurchaserInfo info = await Purchases.getPurchaserInfo();
    return info.activeSubscriptions.contains('basic') ? 100 : 10;
  } catch(e, stack) {
      Crashlytics.instance.recordError(e, stack);
    return 10;
  }
}

Future<int> booksAllowance() async {
  try {
    PurchaserInfo info = await Purchases.getPurchaserInfo();
    return info.activeSubscriptions.contains('basic') ? 5 : 2;
  } catch(e, stack) {
      Crashlytics.instance.recordError(e, stack);
    return 2;
  }
}

Future<String> upgradePrice() async {
  try {
    Offerings offerings = await Purchases.getOfferings();
    return offerings != null ? offerings.current.monthly.product.priceString : 'USD 3.99';
  } catch(e, stack) {
      Crashlytics.instance.recordError(e, stack);
    return 'USD 2.99';
  }
}

String deviceLang(BuildContext context) {
  return Localizations.localeOf(context).languageCode;
}

Future<Map<String, dynamic>> translateGoogle(String text, String lang) async {
  // TODO: Keep in secrets
  String apiKey = 'AIzaSyAvOO1D5rRxNW4JI8gzUMBUbBxjeUFEijs';

  Uri uri = Uri.https(
          'translation.googleapis.com',  
          '/language/translate/v2', 
          {
            'target': lang,
            'key': apiKey,
            'q': text,
            'format': 'text'
          });

  Response res = await LibConnect.getClient().get(uri);

  if (res.statusCode == 200) {
    //print('!!!DEBUG message translated: ${json.decode(res.body)}');
    return json.decode(res.body)['data']['translations'][0];
  } else  {
    // TODO: Log to crashalityc
    print('!!!DEBUG request for translation failed ${res.statusCode}');
    return null;
  }  

  //{
  //"data": {
  //  "translations": [
  //    {
  //      "translatedText": "TRANSLATED TEXT",
  //      "detectedSourceLanguage": "DETECTED SOURCE LANGUAGE"
  //    }
  // ]
  //}
}
