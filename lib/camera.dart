import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
//import 'dart:convert';
//import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:biblosphere/const.dart';

final FirebaseStorage storage = new FirebaseStorage();
final Geolocator _geolocator = Geolocator();

class MyBookshelf extends StatelessWidget {
  MyBookshelf({Key key, @required this.currentUserId, @required this.shelfId, @required this.imageURL, @required this.position, @required this.fileName});

  String shelfId;
  String imageURL;
  GeoPoint position;
  String currentUserId;
  String fileName;

  Future<void> deleteShelf () async {
    //TODO: Delete bookshelf record in Firestore database
    DocumentReference doc = Firestore.instance.collection('shelves').document("$shelfId");
    await doc.delete();
    print("Record deleted");

    //TODO: Delete image file from Firebase storage
    print("TO be DELETED: currentUserId: $currentUserId, fileName: $fileName");
    final StorageReference ref = storage.ref().child('images').child(currentUserId).child(fileName);
    await ref.delete();
    print("Image deleted");
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Card(
        child: new Column (
        children: <Widget>[
          new Container (
        child: Image(image: new CachedNetworkImageProvider(imageURL), fit: BoxFit.cover),
        margin: EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0) ),
          new Align(
            alignment: Alignment(1.0, 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new IconButton(
                  onPressed: deleteShelf,
                  tooltip: 'Increment',
                  icon: new Icon(Icons.delete),
                ),
                new IconButton(
                  onPressed: () {},
                  tooltip: 'Increment',
                  icon: new Icon(Icons.share),
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
}

class MyBookshelfList extends StatelessWidget {
  MyBookshelfList({Key key, @required this.currentUserId});

  String currentUserId;

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('shelves').where("user", isEqualTo: currentUserId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            print("PATH-PATH-PATH: " + document.reference.path);
            return new MyBookshelf(currentUserId: currentUserId, shelfId: document.documentID, imageURL: document['URL'], position: document['position'], fileName: document['file']);
          }).toList(),
        );
      },
    );
  }
}

class Home extends StatelessWidget {
  Home({Key key, @required this.currentUserId});

  String imagePath;
  String currentUserId;

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    print("DEBUG: Picture taken to $image");

    //TODO: catch exteptions
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();

    String name = timestamp()+".jpg";

    //TODO: catch exteptions
    final String storageUrl = await uploadPicture(image, user, name);
    print("DEBUG: Picture uploaded $storageUrl");

    // TODO: catch exceptions
    final position = await _geolocator.getLastKnownPosition();
    print("DEBUG: Picture location ($position.latitude, $position.longitude)");

    //TODO: Create record in Firestore database with location, URL, and user
    DocumentReference doc = await Firestore.instance.collection('shelves').add({ "user": currentUserId, 'URL': storageUrl,
      'position': new GeoPoint(position.latitude, position.longitude), 'file': name });
    print("Record in Firestore created");
  }

  @override
  Widget build(BuildContext context) {
    return new Stack (
         children: <Widget> [
            new MyBookshelfList(currentUserId: currentUserId),
            new Align (
              alignment: Alignment(0.0, 1.0),
              child: new FloatingActionButton(
                onPressed: getImage,
                tooltip: 'Make a photo',
                child: new Icon(Icons.photo_camera),
              ),
            ),
          ],
        );
  }

  Future<String> uploadPicture(File image, FirebaseUser user, String name) async {
    final StorageReference ref = storage.ref().child('images').child(user.uid).child(name);
    final StorageUploadTask uploadTask = ref.putFile(
      image,
      new StorageMetadata(
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    final String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }
}
