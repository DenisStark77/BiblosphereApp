import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookshelfCard extends StatelessWidget
{
  String _imageURL;
  GeoPoint _position;
  String _user;

  BookshelfCard(String image, String user, GeoPoint position){
    _imageURL = image;
    _user = user;
    _position = position;
  }

  @override
  Widget build(BuildContext context) {
    return new Stack (
      children: <Widget>[
        new Image(image: new CachedNetworkImageProvider(_imageURL), fit: BoxFit.cover),
        new Align(
          alignment: Alignment(1.0, 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new IconButton(
                onPressed: () {
                   openMap(_position);
                  },
                  tooltip: 'Increment',
                  icon: new Icon(Icons.location_on),
              ),
              new IconButton(
                onPressed: () {
                  openMsg(_user);
                },
                tooltip: 'Increment',
                icon: new Icon(Icons.message),
              ),
            ],
          ),
        ),
      ],
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

  void openMsg(String user) async {
    final url = 'https://m.me/$user';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class BookshelfList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('shelves').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            return new BookshelfCard(document['URL'], document['user'], document['position']);
          }).toList(),
        );
      },
    );
  }
}