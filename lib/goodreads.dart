import 'package:flutter/material.dart';
import 'dart:async';
import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:xml/xml.dart' as xml;
//Below two imports only needed due to bug in Oauth1 implementation in Goodreads
import 'package:biblosphere/oauth1.dart';
import 'package:http/http.dart' as http;

class Goodreads extends StatefulWidget {
  Goodreads({Key key}) : super(key: key);

  @override
  _GoodreadsState createState() => new _GoodreadsState();
}

class _GoodreadsState extends State<Goodreads> with WidgetsBindingObserver {
  static const String apiKey = 'SXMWtbHvcnbTgRTLT7isA';
  static const String apiSecret = 'O5gPi7aveTCmE7QbhfaRpovZOZxYDBdFNaeYmdbFIE';
  final oauth1.ClientCredentials clientCredentials =
      new oauth1.ClientCredentials(apiKey, apiSecret);
  oauth1.Credentials temporaryCredentials;
  oauth1.Credentials longliveCredentials;

  bool linked = false;
  bool authorizing = false;
  bool import = false;
  String userName;
  String userId;
  bool locationConfirmed = false;

  List<String> allShelves;
  Set<String> toWishlist;
  Set<String> toBooks;

  final oauth1.Platform platform = new oauth1.Platform(
      'https://www.goodreads.com/oauth/request_token',
      // temporary credentials request
      'https://www.goodreads.com/oauth/authorize',
      // resource owner authorization
      'https://www.goodreads.com/oauth/access_token',
      // token credentials request
      oauth1.SignatureMethods.hmacSha1 // signature method
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    checkLink(longliveCredentials).then((bool res) {
      if (res) getShelfList();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (authorizing && state == AppLifecycleState.resumed) {
      getGoodreadsCredentials().then((bool res) {
        if (res) getShelfList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: greyColor2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
            margin: EdgeInsets.all(10.0),
            child: new Column(children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(right: 5.0),
                        child: Image.asset(
                          'images/goodreads.png',
                          width: 25.0,
                        )),
                    Text(linked ? S.of(context).yourGoodreads : S.of(context).linkToGoodreads,
                        style: Theme.of(context).textTheme.subtitle),
                  ]),
              Row(children: <Widget>[
                Expanded(
                    child: Container(
                  margin: EdgeInsets.all(5.0),
                  child: Text(
                      linked
                          ? S.of(context).importYouBooks
                          : S.of(context).linkYourAccount,
                      style: Theme.of(context).textTheme.body1),
                )),
                RaisedButton(
                  color: Theme.of(context).colorScheme.secondary,
                  textColor: Colors.white,
                  disabledColor: Theme.of(context).colorScheme.secondaryVariant,
                  disabledTextColor: Colors.white70,
                  child: new Icon(linked ? MyIcons.synch : MyIcons.chain),
                  onPressed: !linked || linked && locationConfirmed
                      ? () {
                          if (!linked)
                            linkGoodreads(context);
                          else if (import && locationConfirmed) syncGoodreads();
                        }
                      : null,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0)),
                ),
              ]),
              import
                  ? Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: 30,
                                child: Checkbox(
                                    value: locationConfirmed,
                                    onChanged: (bool newValue) {
                                      if( mounted )
                                        setState(() {
                                        locationConfirmed = newValue;
                                      });
                                    })),
                            Expanded(
                                child: Container(
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text(S.of(context).useCurrentLocation,
                                  style: Theme.of(context).textTheme.body1),
                            ))
                          ]),
                    )
                  : Container(),
              import
                  ? Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.all(5.0),
                      child: Text(S.of(context).importToWishlist,
                          style: Theme.of(context).textTheme.body1),
                    )
                  : Container(),
              import
                  ? Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.all(5.0),
                      child: Wrap(
                          children: allShelves.map((String s) {
                        return InputChip(
                            label: Text(s),
                            selected: toWishlist.contains(s),
                            onSelected: (bool newValue) {
                              if( mounted )
                              setState(() {
                                if (newValue)
                                  toWishlist.add(s);
                                else
                                  toWishlist.remove(s);
                              });
                            });
                      }).toList()))
                  : Container(),
              import
                  ? Container(
                      margin: EdgeInsets.all(5.0),
                      alignment: Alignment.centerLeft,
                      child: Text(S.of(context).importToBooks,
                          style: Theme.of(context).textTheme.body1),
                    )
                  : Container(),
              import
                  ? Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.all(5.0),
                      child: Wrap(
                          children: allShelves.map((String s) {
                        return InputChip(
                            label: Text(s),
                            selected: toBooks.contains(s),
                            onSelected: (bool newValue) {
                              if( mounted )
                              setState(() {
                                if (newValue)
                                  toBooks.add(s);
                                else
                                  toBooks.remove(s);
                              });
                            });
                      }).toList()))
                  : Container(),
            ])));
  }

  Future<bool> checkLink(oauth1.Credentials credentials) async {
    String name;
    String id;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (credentials == null) {
      String token = prefs.getString('goodreadsToken');
      String tokenSecret = prefs.getString('goodreadsTokenSecret');

      if (token != null && tokenSecret != null) {
        credentials = new oauth1.Credentials(token, tokenSecret);
      }
    }

    if (credentials != null) {
      var client = new oauth1.Client(
          platform.signatureMethod, clientCredentials, credentials);

      var res = await client.get('https://www.goodreads.com/api/auth_user');

      var document = xml.parse(res.body);

      id = document.findAllElements('user')?.first?.getAttribute('id');
      name = document.findAllElements('name')?.first?.text;

      if (id != null && name != null) {
        if( mounted )
        setState(() {
          authorizing = false;
          linked = true;
          userName = name;
          userId = id;
          longliveCredentials = credentials;
        });
        await prefs.setString('goodreadsToken', credentials.token);
        await prefs.setString('goodreadsTokenSecret', credentials.tokenSecret);

        return true;
      }
    }

    authorizing = false;
    linked = false;
    longliveCredentials = null;
    temporaryCredentials = null;
    await prefs.remove('goodreadsToken');
    await prefs.remove('goodreadsTokenSecret');

    return false;
  }

  Future linkGoodreads(BuildContext context) async {
    try {
      // create Authorization object with client credentials and platform definition
      var auth = new GoodreadsAuthorization(
          clientCredentials, platform, http.Client());

      // request temporary credentials (request tokens)
      oauth1.AuthorizationResponse authRes =
          await auth.requestTemporaryCredentials(
              'https://biblosphere.page.link/oauthgoodreads');

      //Keep temporary credentials to use after user's authorization
      temporaryCredentials = authRes.credentials;
      authorizing = true;

      //Initiate user's authorization in browser
      if (authRes != null) {
        final url =
            '${auth.getResourceOwnerAuthorizationURI(authRes.credentials.token)}&mobile=1';

        //Use external browser. It will be back to the app by redirect to
        // callback deep link (firebase dynamic link)
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }
    } catch (e) {
      print('Unknown error: $e');
    }
  }

//Working wit credentials and OAuth
  Future<bool> getGoodreadsCredentials() async {
    try {
      final PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.retrieveDynamicLink();
      final Uri deepLink = data?.link;

      print('DEEP LINK: ${deepLink.path}');

      if (deepLink?.path != '/oauthgoodreads') {
        return false;
      }

      // create Authorization object with client credentials and platform definition
      var auth = new GoodreadsAuthorization(
          clientCredentials, platform, http.Client());

      oauth1.AuthorizationResponse res =
          await auth.requestTokenCredentials(temporaryCredentials, '');

      //Check credentials and if successful store in shared preferences
      return await checkLink(res.credentials);
    } catch (e) {
      print('Unknown error: $e');
      return false;
    }
  }

  Future getShelfList() async {
    if (linked && longliveCredentials != null) {
      var client = new oauth1.Client(
          platform.signatureMethod, clientCredentials, longliveCredentials);

      var res = await client
          .get('https://www.goodreads.com/shelf/list.xml?user_id=$userId');

      var document = xml.parse(res.body);
      List<String> shelves =
          document.findAllElements('user_shelf')?.map((xml.XmlElement e) {
        return e.findElements("name")?.first?.text?.toString();
        //e.findElements("book_count")?.first?.text?.toString()
      })?.toList();

      if( mounted )
        setState(() {
        allShelves = shelves;
        toWishlist = shelves.where((s) => s.startsWith('to-read')).toSet();
        toBooks = shelves
            .where((s) =>
                s.startsWith('read') || s.startsWith('currently-reading'))
            .toSet();
        import = true;
      });
    }
  }

  Future syncGoodreads() async {
    print('SYNCHRONIZATION STARTED!');
    GeoPoint position = await currentPosition();
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();

    User user = new User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName,
        photo: firebaseUser.photoUrl,
        position: position);


    var client = new oauth1.Client(
        platform.signatureMethod, clientCredentials, longliveCredentials);

    for (String shelf in toBooks) {
      var res = await client.get(
          'https://www.goodreads.com/review/list?v=2&format=xml&user_id=$userId&shelf=$shelf&sort=date_updated&order=d');

      var document = xml.parse(res.body);

      List<Book> books =
          document.findAllElements('book')?.map((xml.XmlElement e) { return new Book.goodreads(e); })?.toList();

      //books.forEach((b) => addBook(context, b, user, position, snackbar: false));
    }

    for (String shelf in toWishlist) {
      var res = await client.get(
          'https://www.goodreads.com/review/list?v=2&format=xml&user_id=$userId&shelf=$shelf&sort=date_updated&order=d');

      var document = xml.parse(res.body);

      List<Book> books =
      document.findAllElements('book')?.map((xml.XmlElement e) {return new Book.goodreads(e);
      })?.toList();

      //books.forEach((b) => addWish(context, b, user, position, snackbar: false));
    }

    //DEBUG ONLY
    /*
    Book book = new Book(title: 'XXX', authors: ['YYY'], image: 'ZZZ', isbn: '1234567890');
    User kris = new User(
        id: firebaseUser.uid,
        name: 'Kris',
        photo: firebaseUser.photoUrl,
        position: new GeoPoint(position.latitude+5, position.longitude+5));

    User peter = new User(
        id: firebaseUser.uid,
        name: 'Peter',
        photo: firebaseUser.photoUrl,
        position: new GeoPoint(position.latitude-2, position.longitude-2));

    await addBook(book, user, position);
    await addWish(book, kris, kris.position);
    await addWish(book, peter, peter.position);
    print('SYNCHRONIZATION FINISHED!');
    */
    //TODO: implement paging for Goodreads
  }
}
