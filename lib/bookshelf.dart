import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biblosphere/chat.dart';
import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:math' as math;
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

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

void openMap(GeoPoint pos) async {
  final url =
      'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void openMsg(BuildContext context, String user, String currentUser) async {
  try {
    bool isBlocked = false;
    bool isNewChat = true;
    DocumentSnapshot chatSnap =
        await Firestore.instance
        .collection('messages')
        .document(chatId(currentUser, user)).get();
    if (chatSnap.exists) {
      isNewChat = false;
      if (chatSnap['blocked'] == 'yes') {
        isBlocked = true;
      }
    }

    if (isBlocked) {
      showBbsDialog(context, S.of(context).blockedChat);
      return;
    }

    DocumentSnapshot userSnap =
        await Firestore.instance.collection('users').document(user).get();
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Chat(
                  myId: currentUser,
                  peerId: user,
                  peerAvatar: userSnap["photoUrl"],
                  peerName: userSnap["name"],
                  isNewChat: isNewChat,
                )));
  } catch (ex, stack) {
    print("Chat screen failed: " + ex.toString());
    FlutterCrashlytics().logException(ex, stack);
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
/*                      Image(
                          image: new CachedNetworkImageProvider(
                              bookcopy.wisher.photo),
                          width: 50,
                          fit: BoxFit.cover),*/
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text('${widget.person.name}',
                              style: Theme.of(context).textTheme.title),
                        ),
                      ),
                    ]),
                margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
              ),
              wishlist == null || wishlist.isEmpty
                  ? Container()
                  : Container(margin: EdgeInsets.only(left: 5.0), alignment: Alignment.centerLeft, child: Text('Recent wishes:',
                  style: Theme.of(context).textTheme.body1)),
              wishlist == null || wishlist.isEmpty
                  ? Container()
                  : new Container(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: wishlist.map((book) {
                            return new Expanded(child: Container( padding: EdgeInsets.all(5.0),
                              alignment: Alignment.centerLeft,
                              child: Image(
                                  height: 80,
                                  image: new CachedNetworkImageProvider(
                                      book.image),
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
                                widget.currentUser.position.latitude,
                                widget.currentUser.position.longitude)
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
                            context, widget.currentUser.id, widget.person.id);
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

      if( mounted )
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
                          image:
                              new CachedNetworkImageProvider(book.book.image),
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
                      onPressed: () {},
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
                        openMsg(context, book.owner.id, currentUser.id);
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
                        showBbsConfirmation(context, S.of(context).confirmReportPhoto).then((confirmed) {
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
                        openMsg(context, shelf.user, currentUser.id);
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

Widget activityChip(
    BuildContext context, AppActivity a, String label, bool selected,
    {ValueChanged<bool> onSelected, Icon icon}) {
  return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ChoiceChip(
        avatar: icon,
        label: Text(label, style: Theme.of(context).textTheme.button),
        selected: selected,
        onSelected: onSelected,
      ));
}

class BookshelfList extends StatefulWidget {
  final User currentUser;
  final Area area;

  BookshelfList({Key key, this.currentUser, this.area}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _BookshelfListState createState() =>
      new _BookshelfListState(currentUser, area);
}

class _BookshelfListState extends State<BookshelfList> {
  final User currentUser;
  final Area area;
  AppActivity activity = AppActivity.books;

  @override
  void initState() {
    super.initState();
  }

  _BookshelfListState(this.currentUser, this.area);

  Stream<List<BookCard>> getBooks(area) {
    try {
      return getDataInArea(
              source: Firestore.instance.collection("bookcopies"),
              area: area,
              locationFieldNameInDB: 'position',
              mapper: (document) {
                var book = new Bookcopy.fromJson(document.data);
                // if you serializer does not pass types like GeoPoint through
                // you have to add that fields manually. If using `jaguar_serializer`
                // add @pass attribute to the GeoPoint field and you can omit this.
//            shelf._position = document.data['position'] as GeoPoint;
                return book;
              },
              locationAccessor: (book) => book.position,
              distanceMapper: (book, distance) {
                book.d = distance;
                return book;
              },
              distanceAccessor: (book) => book.d,
              sortDecending: true
//          clientSitefilters: (BookshelfCard => shelf._user != currentUserId)  // filer only future events
              )
          .map((list) => new List<BookCard>.generate(list.length,
              (int index) => new BookCard(list[index], currentUser)));
    } catch (ex, stack) {
      print("Sort and filter by distance failed: " + ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
    return null;
  }

  Stream<List<BookshelfCard>> getBookshelves(area) {
    try {
      return getDataInArea(
              source: Firestore.instance.collection("shelves"),
              area: area,
              locationFieldNameInDB: 'position',
              mapper: (document) {
                var shelf = new ShelfData(
                    document.documentID,
                    document.data['URL'],
                    document.data['position'],
                    document.data['user'],
                    document.data['userName'] != null
                        ? document.data['userName']
                        : "");
                // if you serializer does not pass types like GeoPoint through
                // you have to add that fields manually. If using `jaguar_serializer`
                // add @pass attribute to the GeoPoint field and you can omit this.
//            shelf._position = document.data['position'] as GeoPoint;
                return shelf;
              },
              locationAccessor: (shelf) => shelf.position,
              distanceMapper: (shelf, distance) {
                shelf.distance = distance;
                return shelf;
              },
              distanceAccessor: (shelf) => shelf.distance,
              sortDecending: true
//          clientSitefilters: (BookshelfCard => shelf._user != currentUserId)  // filer only future events
              )
          .map((list) => new List<BookshelfCard>.generate(list.length,
              (int index) => new BookshelfCard(list[index], currentUser)));
    } catch (ex, stack) {
      print("Sort and filter by distance failed: " + ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
    return null;
  }

  Widget buildActivityWidget(BuildContext context) {
    switch (activity) {
      case AppActivity.wished:
        return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('wishes')
              .where("wisher.id", isEqualTo: currentUser.id)
              .where("matched", isEqualTo: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text(S.of(context).loading);
              default:
                if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
                  return Container(padding: EdgeInsets.all(10), child: Text('Hey, right now nodody around you has the books from your wishlist. They will be shown here once someone registers them.\nSpread the word about Biblosphere to make it happen sooner. And add more books to your wishlist.', style: Theme.of(context).textTheme.body1,));
                }
                return new ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return readCard(context, new Wish.fromJson(document.data));
                  }).toList(),
                );
            }
          },
        );
        break;

      case AppActivity.books:
        return Container(
            child: Column(children: <Widget>[
          Expanded(
              child: StreamBuilder<List<BookCard>>(
            stream: getBooks(area),
            builder:
                (BuildContext context, AsyncSnapshot<List<BookCard>> snapshot) {
              if (!snapshot.hasData) return new Text(S.of(context).loading);
              return new ListView(
                children: snapshot.data.map((BookCard card) {
                  if (card.book.owner.id == currentUser.id) return Container();
                  return card;
                }).toList(),
              );
            },
          )),
        ]));
        break;

      case AppActivity.shelves:
        return Container(
            child: Column(children: <Widget>[
          Expanded(
              child: StreamBuilder<List<BookshelfCard>>(
            stream: getBookshelves(area),
            builder: (BuildContext context,
                AsyncSnapshot<List<BookshelfCard>> snapshot) {
              if (!snapshot.hasData) return new Text(S.of(context).loading);
              return new ListView(
                children: snapshot.data.map((BookshelfCard shelf) {
                  if (shelf.shelf.user == currentUser.id) return Container();
                  return shelf;
                }).toList(),
              );
            },
          )),
        ]));
        break;
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser?.id == null || currentPosition == null) return Container();

    return Column(children: <Widget>[
      Wrap(
          spacing: 1.0, // gap between adjacent chips
          runSpacing: 0.0, // gap between lines
          children: <Widget>[
            activityChip(context, AppActivity.books, 'Books',
                activity == AppActivity.books, onSelected: (bool selected) {
              setState(() {
                activity = AppActivity.books;
              });
            }, icon: new Icon(MyIcons.book)),
            activityChip(context, AppActivity.shelves, 'Shelves',
                activity == AppActivity.shelves, onSelected: (bool selected) {
              setState(() {
                activity = AppActivity.shelves;
              });
            }, icon: new Icon(MyIcons.open)),
            activityChip(context, AppActivity.wished, 'Wished',
                activity == AppActivity.wished, onSelected: (bool selected) {
              setState(() {
                activity = AppActivity.wished;
              });
            }, icon: new Icon(MyIcons.heart)),
          ]),
      Flexible(
          child:
              currentUser != null ? buildActivityWidget(context) : Container()),
    ]);
  }

  Widget readCard(context, Wish wish) {
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
                          image:
                              new CachedNetworkImageProvider(wish.book.image),
                          width: 50,
                          fit: BoxFit.cover),
                      Expanded(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(wish.book.authors.join(", "),
                                    style: Theme.of(context).textTheme.caption),
                                Text(wish.book.title,
                                    style:
                                        Theme.of(context).textTheme.subtitle),
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
                      onPressed: () {},
                      tooltip: S.of(context).favorite,
                      icon: new Icon(MyIcons.heart),
                    ),
                    new Expanded(child: Text(wish.owner.name)),
                    new Text(distanceBetween(
                                wish.bookcopyPosition.latitude,
                                wish.bookcopyPosition.longitude,
                                currentUser.position.latitude,
                                currentUser.position.longitude)
                            .round()
                            .toString() +
                        S.of(context).km),
                    new IconButton(
                      onPressed: () {
                        openMap(wish.bookcopyPosition);
                      },
                      tooltip: S.of(context).seeLocation,
                      icon: new Icon(MyIcons.navigation1),
                    ),
                    new IconButton(
                      onPressed: () {
                        openMsg(context, wish.wisher.id, wish.owner.id);
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

class PeopleList extends StatefulWidget {
  final User currentUser;
  final Area area;

  PeopleList({Key key, this.currentUser, this.area}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _PeopleState createState() => new _PeopleState(currentUser, area);
}

class _PeopleState extends State<PeopleList> {
  final User currentUser;
  final Area area;
  AppActivity activity = AppActivity.people;

  @override
  void initState() {
    super.initState();
  }

  _PeopleState(this.currentUser, this.area);

  Stream<List<PersonCard>> getPeople(area) {
    try {
      return getDataInArea(
              source: Firestore.instance
                  .collection("users")
                  .where('positioned', isEqualTo: true),
              area: area,
              locationFieldNameInDB: 'position',
              mapper: (document) {
                return new User(
                    id: document.documentID,
                    name: document.data['name'],
                    photo: document.data['photoUrl'],
                    position: document.data['position']);
              },
              locationAccessor: (user) => user.position,
              distanceMapper: (user, distance) {
                user.d = distance;
                return user;
              },
              distanceAccessor: (user) => user.d,
              sortDecending: true)
          .map((list) => new List<PersonCard>.generate(
              list.length,
              (int index) => new PersonCard(
                  person: list[index], currentUser: currentUser)));
    } catch (ex, stack) {
      print("Sort and filter by distance failed: " + ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
    return null;
  }

  Widget buildActivityWidget(BuildContext context) {
    switch (activity) {
      case AppActivity.give:
        return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('bookcopies')
              .where("owner.id", isEqualTo: currentUser.id)
              .where("matched", isEqualTo: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text(S.of(context).loading);
              default:
                if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
                  return Container(padding: EdgeInsets.all(10), child: Text('Here you\'ll see people who wish your books once they are registered. To make it happen add more books and spread the word about Biblosphere.', style: Theme.of(context).textTheme.body1,));
                }
                return new ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return meetCard(
                        context, new Bookcopy.fromJson(document.data));
                  }).toList(),
                );
            }
          },
        );
        break;

      case AppActivity.people:
        return Container(
            child: Column(children: <Widget>[
          Expanded(
              child: StreamBuilder<List<PersonCard>>(
            stream: getPeople(area),
            builder: (BuildContext context,
                AsyncSnapshot<List<PersonCard>> snapshot) {
              if (!snapshot.hasData) return new Text(S.of(context).loading);
              return new ListView(
                children: snapshot.data.map((PersonCard card) {
                  if (card.person.id == currentUser.id) return Container();
                  return card;
                }).toList(),
              );
            },
          )),
        ]));
        break;
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser?.id == null || currentPosition == null) return Container();

    return Column(children: <Widget>[
      Wrap(
          spacing: 1.0, // gap between adjacent chips
          runSpacing: 0.0, // gap between lines
          children: <Widget>[
            activityChip(context, AppActivity.people, 'People',
                activity == AppActivity.people, onSelected: (bool selected) {
              setState(() {
                activity = AppActivity.people;
              });
            }, icon: new Icon(MyIcons.people)),
            activityChip(
                context, AppActivity.give, 'Share', activity == AppActivity.give,
                onSelected: (bool selected) {
              setState(() {
                activity = AppActivity.give;
              });
            }, icon: new Icon(MyIcons.book)),
          ]),
      Flexible(
          child:
              currentUser != null ? buildActivityWidget(context) : Container()),
    ]);
  }

  Widget meetCard(context, Bookcopy bookcopy) {
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
                                      bookcopy.wisher.photo)))),
/*                      Image(
                          image: new CachedNetworkImageProvider(
                              bookcopy.wisher.photo),
                          width: 50,
                          fit: BoxFit.cover),*/
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                              '${bookcopy.wisher.name} wish to read your book \'${bookcopy.book.title}\'',
                              style: Theme.of(context).textTheme.body1),
                        ),
                      ),
                    ]),
                margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
              ),
              new Container(
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image(
                          image: new CachedNetworkImageProvider(
                              bookcopy.book.image),
                          width: 50,
                          fit: BoxFit.cover),
                      Expanded(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(bookcopy.book.authors.join(", "),
                                    style: Theme.of(context).textTheme.caption),
                                Text(bookcopy.book.title,
                                    style:
                                        Theme.of(context).textTheme.subtitle),
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
                    new Text(distanceBetween(
                                currentUser.position.latitude,
                                currentUser.position.longitude,
                                bookcopy.wisher.position.latitude,
                                bookcopy.wisher.position.longitude)
                            .round()
                            .toString() +
                        S.of(context).km),
                    new IconButton(
                      onPressed: () {
                        openMap(bookcopy.wisher.position);
                      },
                      tooltip: S.of(context).seeLocation,
                      icon: new Icon(MyIcons.navigation1),
                    ),
                    new IconButton(
                      onPressed: () {
                        openMsg(context, bookcopy.owner.id, bookcopy.wisher.id);
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
