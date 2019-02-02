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

class BookshelfCard extends StatelessWidget {
  final ShelfData shelf;
  final String currentUser;
  final GeoPoint currentPosition;

  BookshelfCard(this.shelf, this.currentUser, this.currentPosition);

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
                                      title: new Text(S.of(context).zoom,
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      centerTitle: true,
                                    ),
                                    body: new PhotoView(
                                      imageProvider:
                                          CachedNetworkImageProvider(shelf.image),
                                      minScale:
                                          PhotoViewComputedScale.contained * 1.0,
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
                      icon: new Icon(Icons.report),
                    ),
                    new Expanded(child: Text(shelf.userName)),
                    new Text(distanceBetween(
                        shelf.position.latitude,
                        shelf.position.longitude,
                        currentPosition.latitude,
                        currentPosition.longitude)
                        .round()
                        .toString() +
                        S.of(context).km),
                    new IconButton(
                      onPressed: () {
                        openMap(shelf.position);
                      },
                      tooltip: S.of(context).seeLocation,
                      icon: new Icon(Icons.location_on),
                    ),
                    new IconButton(
                      onPressed: () {
                        openMsg(context, shelf.user);
                      },
                      tooltip: S.of(context).messageOwner,
                      icon: new Icon(Icons.message),
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

  void openMap(GeoPoint pos) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void openMsg(BuildContext context, String user) async {
    try {
      bool isBlocked = false;
      DocumentSnapshot chatSnap =
          await Firestore.instance
          .collection('messages')
          .document(chatId(currentUser, user)).get();
      if (chatSnap != null) {
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
                  )));
    } catch (ex, stack) {
      print("Chat screen failed: " + ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }
  void reportContent() async {
    try {
      Firestore.instance
          .collection('reports')
          .document(shelf.id)
          .setData({
        'shelf': shelf.id,
        'reportedBy': currentUser,
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

class BookshelfList extends StatelessWidget {
  final String currentUserId;
  final GeoPoint currentPosition;
  //TODO: Area is not final field in StatelessWidget. Should be refactored.
  final Area area;

  BookshelfList(this.currentUserId, this.currentPosition, this.area);

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
                document.data['userName']!=null?document.data['userName']:"");
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
          ).map((list) => new List<BookshelfCard>.generate(list.length, (int index) => new BookshelfCard(list[index], currentUserId, currentPosition)));
    } catch (ex, stack) {
      print("Sort and filter by distance failed: " + ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null || currentPosition == null) return Container();

    return StreamBuilder<List<BookshelfCard>>(
      stream: getBookshelves(area),
      builder:
          (BuildContext context, AsyncSnapshot<List<BookshelfCard>> snapshot) {
        if (!snapshot.hasData) return new Text(S.of(context).loading);
        return new ListView(
          children: snapshot.data.map((BookshelfCard shelf)  {
            if (shelf.shelf.user == currentUserId) return Container();
            return shelf;
          }).toList(),
        );
      },
    );
  }
}
