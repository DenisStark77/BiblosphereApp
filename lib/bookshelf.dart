import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biblosphere/chat.dart';
import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:math' as math;
import 'package:biblosphere/const.dart';

class BookshelfCard extends StatelessWidget {
  final String id;
  final String image;
  final GeoPoint position;
  final String user;
  final String currentUser;
  final GeoPoint currentPosition;
  //TODO: non final field in the StatelessWidget. Should be refactored.
  double distance;

  BookshelfCard(this.id, this.currentUser, this.image, this.user,
      this.position, this.currentPosition);

  double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    double R = 6378.137; // Radius of earth in KM
    double dLat = lat2 * math.pi / 180 - lat1 * math.pi / 180;
    double dLon = lon2 * math.pi / 180 - lon1 * math.pi / 180;
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double d = R * c;
    return d; // meters
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Card(
          child: new Column (
            children: <Widget>[
              new Container(
                  child: GestureDetector(
                    onTap: () {
                      print("onTap called.");
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                              new PhotoView(
                                  imageProvider: CachedNetworkImageProvider(image)
                              )));


                    },
                    child: Image(image: new CachedNetworkImageProvider(image),
                        fit: BoxFit.cover),
                  ),
                  margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0)
              ),
              new Align(
                alignment: Alignment(1.0, 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new Text(distanceBetween(
                        position.latitude, position.longitude,
                        currentPosition.latitude, currentPosition.longitude)
                        .round()
                        .toString() + " km"),
                    new IconButton(
                      onPressed: () {
                        openMap(position);
                      },
                      tooltip: 'See location',
                      icon: new Icon(Icons.location_on),
                    ),
                    new IconButton(
                      onPressed: () {
                        openMsg(context, user);
                      },
                      tooltip: 'Message owner',
                      icon: new Icon(Icons.message),
                    ),
                  ],
                ),
              ),
            ],
          ),
          color: greyColor2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0)
    );
  }

  void openMap(GeoPoint pos) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${pos
        .latitude},${pos.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void openMsg(BuildContext context, String user) async {
    try {
      DocumentSnapshot userSnap = await Firestore.instance.collection('users')
          .document(user)
          .get();
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) =>
              new Chat(
                myId: currentUser,
                peerId: user,
                peerAvatar: userSnap["photoUrl"],
                peerName: userSnap["name"],
              )));
    } on Exception catch (ex) {
      print("Chat screen failed: " + ex.toString());
    }
  }
}

class BookshelfList extends StatelessWidget {
  final String currentUserId;
  final GeoPoint  currentPosition;
  //TODO: Area is not final field in StatelessWidget. Should be refactored.
  Area area;

  BookshelfList (this.currentUserId, this.currentPosition) {
    if (currentPosition != null)
       area = new Area(currentPosition, 200.0);
  }

  Stream<List<BookshelfCard>> getBookshelves(area) {
    try {
      return getDataInArea(
          source: Firestore.instance.collection("shelves"),
          area: area,
          locationFieldNameInDB: 'position',
          mapper: (document) {
            var shelf = new BookshelfCard(document.documentID, currentUserId, document.data['URL'], document.data['user'], document.data['position'], currentPosition);
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
      );
    } on Exception catch (ex) {
      print("Sort and filter by distance failed: " + ex.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null || currentPosition == null)
      return Container();

    return new StreamBuilder<List<BookshelfCard>>(
      stream: getBookshelves(area),
      builder: (BuildContext context, AsyncSnapshot<List<BookshelfCard>> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.map((BookshelfCard shelf) {
            if (shelf.user == currentUserId) return Container();
            return shelf;
          }).toList(),
        );
      },
    );
  }
}