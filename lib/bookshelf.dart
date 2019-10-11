import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biblosphere/chat.dart';
//import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:math' as math;
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:intl/intl.dart';

import 'package:biblosphere/const.dart';
import 'package:biblosphere/l10n.dart';

class ShelfData {
  String id;
  String image;
  GeoPoint position;
  String user;
  String userName;

  double distance;

  ShelfData(this.id, this.image, this.position, this.user, this.userName);
}

void openMap(GeoPoint pos) async {
  final url =
      'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class PersonCard extends StatefulWidget {
  final User person;
  final User currentUser;

  PersonCard({Key key, this.person, this.currentUser}) : super(key: key);

  @override
  _PersonCardState createState() => new _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  List<Book> wishlist;

  @override
  void initState() {
    super.initState();

    retriveData();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Card(
          child: new Column(
            children: <Widget>[
              new Container(
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new CachedNetworkImageProvider(
                                      widget.person.photo)))),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 20.0, bottom: 5.0, right: 5.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('${widget.person.name}',
                                    style: Theme.of(context).textTheme.title),
                                Text(
                                    S.of(context)
                                        .userBalance((new NumberFormat("##0.00")).format(widget.person.balance??0)),
                                    style: Theme.of(context).textTheme.body1),
                                Text(
                                    S
                                        .of(context)
                                        .bookCount(widget.person.bookCount),
                                    style: Theme.of(context).textTheme.body1),
                                Text(
                                    S
                                        .of(context)
                                        .shelfCount(widget.person.shelfCount),
                                    style: Theme.of(context).textTheme.body1),
                                Text(
                                    S
                                        .of(context)
                                        .wishCount(widget.person.wishCount),
                                    style: Theme.of(context).textTheme.body1),
                              ]),
                        ),
                      ),
                    ]),
                margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
              ),
              wishlist == null || wishlist.isEmpty
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(left: 5.0),
                      alignment: Alignment.centerLeft,
                      child: Text(S.of(context).recentWishes,
                          style: Theme.of(context).textTheme.body1)),
              wishlist == null || wishlist.isEmpty
                  ? Container()
                  : new Container(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: wishlist.map((book) {
                            return new Expanded(
                                child: Container(
                              padding: EdgeInsets.all(5.0),
                              alignment: Alignment.centerLeft,
                              child: Image(
                                  height: 80,
                                  image: new CachedNetworkImageProvider(
                                      (book.image != null && book.image.isNotEmpty) ? book.image : nocoverUrl),
                                  fit: BoxFit.cover),
                            ));
                          }).toList()),
                      margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
                    ),
              new Align(
                alignment: Alignment(1.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new Text(distanceBetween(
                                widget.currentUser.position.latitude,
                                widget.currentUser.position.longitude,
                                widget.person.position.latitude,
                                widget.person.position.longitude)
                            .round()
                            .toString() +
                        S.of(context).km),
                    new IconButton(
                      onPressed: () {
                        openMap(widget.person.position);
                      },
                      tooltip: S.of(context).seeLocation,
                      icon: new Icon(MyIcons.navigation1),
                    ),
                    new IconButton(
                      onPressed: () {
                        openMsg(
                            context, widget.person.id, widget.currentUser);
                      },
                      tooltip: S.of(context).messageOwner,
                      icon: new Icon(MyIcons.chat),
                    ),
                  ],
                ),
              ),
            ],
          ),
          color: greyColor2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0));
  }

  Future retriveData() async {
    if (widget.person != null) {
      QuerySnapshot q = await Firestore.instance
          .collection('wishes')
          .where('wisher.id', isEqualTo: widget.person.id)
          .orderBy('created', descending: true)
          .limit(5)
          .getDocuments();

      if (mounted)
        setState(() {
          wishlist = q.documents.map((doc) {
            return new Book.fromJson(doc.data['book']);
          }).toList();
        });
    }
  }
}

class BookCard extends StatelessWidget {
  final Bookcopy book;
  final User currentUser;

  BookCard(this.book, this.currentUser);

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Card(
          child: new Column(
            children: <Widget>[
              new Container(
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image(
                          width: 120,
                          image:
                              new CachedNetworkImageProvider((book.book.image != null && book.book.image.isNotEmpty) ? book.book.image : nocoverUrl),
                          fit: BoxFit.cover),
                      Expanded(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(book.book.authors.join(', '),
                                    style: Theme.of(context).textTheme.caption),
                                Text(book.book.title,
                                    style:
                                        Theme.of(context).textTheme.subtitle),
                                book.book.language == null ? Container() : Text(S.of(context).bookLanguage(book.book.language.toUpperCase()),
                                    style:
                                    Theme.of(context).textTheme.caption),
                              ]),
                          margin: EdgeInsets.all(5.0),
                          alignment: Alignment.topLeft,
                        ),
                      ),
                    ]),
                margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
              ),
              new Align(
                alignment: Alignment(1.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new IconButton(
                      onPressed: () async {
                        //addWish(context, book.book, currentUser, await currentPosition());
                      },
                      tooltip: S.of(context).favorite,
                      icon: new Icon(MyIcons.heart),
                    ),
                    new Expanded(child: Text(book.owner.name)),
                    new Text(distanceBetween(
                                book.position.latitude,
                                book.position.longitude,
                                currentUser.position.latitude,
                                currentUser.position.longitude)
                            .round()
                            .toString() +
                        S.of(context).km),
                    new IconButton(
                      onPressed: () {
                        openMap(book.position);
                      },
                      tooltip: S.of(context).seeLocation,
                      icon: new Icon(MyIcons.navigation1),
                    ),
                    new IconButton(
                      onPressed: () {
                        print('DEBUG: Initiate transit');
                        //startTransit(context, book.id, book.holder, currentUser, Transit.Request);
                      },
                      tooltip: S.of(context).addToCart,
                      icon: new Icon(MyIcons.cart),
                    ),
                    new IconButton(
                      onPressed: () {
                        openMsg(context, book.owner.id, currentUser);
                      },
                      tooltip: S.of(context).messageOwner,
                      icon: new Icon(MyIcons.chat),
                    ),
                  ],
                ),
              ),
            ],
          ),
          color: greyColor2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0));
  }
}

class BookshelfCard extends StatelessWidget {
  final ShelfData shelf;
  final User currentUser;

  BookshelfCard(this.shelf, this.currentUser);

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Card(
          child: new Column(
            children: <Widget>[
              new Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new Scaffold(
                                    appBar: new AppBar(
                                      title: new Text(
                                        S.of(context).zoom,
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      centerTitle: true,
                                    ),
                                    body: new PhotoView(
                                      imageProvider: CachedNetworkImageProvider(
                                          shelf.image),
                                      minScale:
                                          PhotoViewComputedScale.contained *
                                              1.0,
                                      maxScale:
                                          PhotoViewComputedScale.covered * 2.0,
//                                      initialScale:
//                                          PhotoViewComputedScale.contained * 1.1,
                                    ),
                                  )));
                    },
                    child: Image(
                        image: new CachedNetworkImageProvider(shelf.image),
                        fit: BoxFit.cover),
                  ),
                  margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0)),
              new Align(
                alignment: Alignment(1.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new IconButton(
                      onPressed: () {
                        showBbsConfirmation(
                                context, S.of(context).confirmReportPhoto)
                            .then((confirmed) {
                          if (confirmed) {
                            reportContent();
                          }
                        });
                        //showBbsDialog(context, S.of(context).reportedPhoto);
                      },
                      tooltip: S.of(context).reportShelf,
                      icon: new Icon(MyIcons.thumbdown),
                    ),
                    new IconButton(
                      onPressed: () {},
                      tooltip: S.of(context).favorite,
                      icon: new Icon(MyIcons.heart),
                    ),
                    new Expanded(child: Text(shelf.userName)),
                    new Text(distanceBetween(
                                shelf.position.latitude,
                                shelf.position.longitude,
                                currentUser.position.latitude,
                                currentUser.position.longitude)
                            .round()
                            .toString() +
                        S.of(context).km),
                    new IconButton(
                      onPressed: () {
                        openMap(shelf.position);
                      },
                      tooltip: S.of(context).seeLocation,
                      icon: new Icon(MyIcons.navigation1),
                    ),
                    new IconButton(
                      onPressed: () {
                        openMsg(context, shelf.user, currentUser);
                      },
                      tooltip: S.of(context).messageOwner,
                      icon: new Icon(MyIcons.chat),
                    ),
                  ],
                ),
              ),
            ],
          ),
          color: greyColor2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0));
  }

  void reportContent() async {
    try {
      Firestore.instance.collection('reports').document(shelf.id).setData({
        'shelf': shelf.id,
        'reportedBy': currentUser.id,
        'image': shelf.image,
        'user': shelf.user,
        'userName': shelf.userName
      });
    } catch (ex, stack) {
      print("Content report failed: " + ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }
}

