import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biblosphere/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:biblosphere/const.dart';
import 'dart:math' as math;

class BookshelfCard extends StatelessWidget {
  String _imageURL;
  GeoPoint _position;
  String _user;
  String currentUserId;
  GeoPoint myPosition;

  BookshelfCard(String currentUser, String image, String user, GeoPoint position, GeoPoint currentPosition){
    _imageURL = image;
    _user = user;
    _position = position;
    currentUserId = currentUser;
    myPosition = currentPosition;
  }

  double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    double R = 6378.137; // Radius of earth in KM
    double dLat = lat2 * math.pi / 180 - lat1 * math.pi / 180;
    double dLon = lon2 * math.pi / 180 - lon1 * math.pi / 180;
    double a = math.sin(dLat/2) * math.sin(dLat/2) +
      math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
          math.sin(dLon/2) * math.sin(dLon/2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
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
            child: Image(image: new CachedNetworkImageProvider(_imageURL), fit: BoxFit.cover),
            margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0)
        ),
        new Align(
          alignment: Alignment(1.0, 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Text(distanceBetween(_position.latitude, _position.longitude, myPosition.latitude, myPosition.longitude).round().toString() + " km"),
              new IconButton(
                onPressed: () {
                   openMap(_position);
                  },
                  tooltip: 'Increment',
                  icon: new Icon(Icons.location_on),
              ),
              new IconButton(
                onPressed: () {
                  openMsg(context, _user);
                },
                tooltip: 'Increment',
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
    final url = 'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void openMsg(BuildContext context, String user) async {
      //TODO: Handle exceptions
      Firestore.instance.collection('users').document(user).get().then((DocumentSnapshot userSnap) {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) =>
                  new Chat(
                    myId: currentUserId,
                    peerId: user,
                    peerAvatar: userSnap["photoUrl"],
                    peerName: userSnap["name"],
                  )));
      });
    }
  }

class BookshelfList extends StatelessWidget {
  String currentUserId;
  GeoPoint  myPosition;
  Area area;

  BookshelfList (String user, GeoPoint position) {
    currentUserId = user;
    myPosition = position;
    area = new Area(myPosition, 200.0);
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('shelves').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            if (document['user'] == currentUserId) return Container();
            return new BookshelfCard(currentUserId, document['URL'], document['user'], document['position'], myPosition);
          }).toList(),
        );
      },
    );
  }
}