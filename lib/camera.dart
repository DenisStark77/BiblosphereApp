import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share/share.dart';
import 'package:biblosphere/const.dart';

class MyBookshelf extends StatelessWidget {
  MyBookshelf({Key key, @required this.currentUserId, @required this.shelfId, @required this.imageURL, @required this.position, @required this.fileName});

  final String shelfId;
  final String imageURL;
  final GeoPoint position;
  final String currentUserId;
  final String fileName;

  Future<void> deleteShelf () async {
    try {
      //Delete bookshelf record in Firestore database
      DocumentReference doc = Firestore.instance.collection('shelves').document(
          "$shelfId");
      await doc.delete();

      //Delete image file from Firebase storage
      final StorageReference ref = FirebaseStorage.instance.ref().child(
          'images').child(currentUserId).child(fileName);
      await ref.delete();
    } on Exception catch (ex) {
      print('Shelf delete failed for [$shelfId, $currentUserId, $fileName]: ' + ex.toString());
    }
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
                  tooltip: 'Delete your bookshelf',
                  icon: new Icon(Icons.delete),
                ),
                new IconButton(
                  onPressed: () {
                    //TODO: Add sharing image only text sharing at the moment
                    Share.share('I\'ve published my bookshelf on Biblosphere \n $imageURL');
                  },
                  tooltip: 'Share your bookshelf',
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

  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('shelves').where("user", isEqualTo: currentUserId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            return new MyBookshelf(currentUserId: currentUserId, shelfId: document.documentID, imageURL: document['URL'], position: document['position'], fileName: document['file']);
          }).toList(),
        );
      },
    );
  }
}

class Home extends StatelessWidget {
  Home({Key key, @required this.currentUserId});

  final String currentUserId;

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  Future getImage() async {
    try {
      File image = await ImagePicker.pickImage(source: ImageSource.camera);
      String name = timestamp() + ".jpg";

      final String storageUrl = await uploadPicture(image, currentUserId, name);

      final position = await Geolocator().getLastKnownPosition();

      //Create record in Firestore database with location, URL, and user
      DocumentReference doc = await Firestore.instance.collection('shelves')
          .add({
        "user": currentUserId,
        'URL': storageUrl,
        'position': new GeoPoint(position.latitude, position.longitude),
        'file': name
      });
    } on Exception catch (ex) {
      print("Failed to take image: " + ex.toString());
    }
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
                tooltip: 'Add your bookshelf',
                child: new Icon(Icons.photo_camera),
              ),
            ),
          ],
        );
  }

  Future<String> uploadPicture(File image, String user, String name) async {
    final StorageReference ref = FirebaseStorage.instance.ref().child('images').child(user).child(name);
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
