import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share/share.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:biblosphere/const.dart';
import 'package:biblosphere/l10n.dart';

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
    } catch (ex, stack) {
      print('Shelf delete failed for [$shelfId, $currentUserId, $fileName]: ' + ex.toString());
      FlutterCrashlytics().logException(ex, stack);
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
                  tooltip: S.of(context).deleteShelf,
                  icon: new Icon(Icons.delete),
                ),
                new IconButton(
                  onPressed: () async {

                    final DynamicLinkParameters parameters = DynamicLinkParameters(
                      domain: 'biblosphere.page.link',
                      link: Uri.parse('https://biblosphere.org/shelf?id=$shelfId#download'),
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
                    );


                    final ShortDynamicLink shortLink = await parameters.buildShortLink();

                    Share.share(shortLink.shortUrl.toString());
                  },
                  tooltip: S.of(context).shareShelf,
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
    if (currentUserId == null)
      return Container();

    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('shelves').where("user", isEqualTo: currentUserId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text(S.of(context).loading);
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

  Future getImage(BuildContext context) async {
    try {
      File image = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 1024.0);

      if (image == null) return;

      bool imageAccepted = await isBookcase(image);

      if (! imageAccepted) {
        showBbsDialog(context, S.of(context).notBooks);
        return;
      }

      String name = timestamp() + ".jpg";

      final String storageUrl = await uploadPicture(image, currentUserId, name);

      final position = await Geolocator().getLastKnownPosition();

      //Create record in Firestore database with location, URL, and user
      await Firestore.instance.collection('shelves')
          .add({
        "user": currentUserId,
        'URL': storageUrl,
        'position': new GeoPoint(position.latitude, position.longitude),
        'file': name
      });
    } catch (ex, stack) {
      print("Failed to take image: " + ex.toString());
      FlutterCrashlytics().logException(ex, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Stack (
         children: <Widget> [
            new MyBookshelfList(currentUserId: currentUserId),
            Container(
    child: new FloatingActionButton(
      onPressed: () => getImage(context),
      tooltip: S.of(context).addShelf,
      child: new Icon(Icons.photo_camera),
    ),
    alignment: Alignment.bottomCenter,
    margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
    ),
          ],
        );
  }

  Future<bool> isBookcase(File imageFile) async {

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);

    // Cloud detection
    FirebaseVisionDetector detector = FirebaseVision.instance.cloudLabelDetector();
    //On-device detection
    //FirebaseVisionDetector detector = FirebaseVision.instance.labelDetector();

    final List<Label> results = await detector.detectInImage(visionImage);

    if (results != null) {
      var books = results.where((label) => label.label.toLowerCase() == 'bookcase' || label.label.toLowerCase() == 'book');
      return books.length > 0;
    }

    return false;
  }

  Future<String> uploadPicture(File image, String user, String name) async {
    final StorageReference ref = FirebaseStorage.instance.ref().child('images').child(user).child(name);
    final StorageUploadTask uploadTask = ref.putFile(
      image,
      new StorageMetadata(
        contentType: 'image/jpeg',
        // To enable Client-side caching you can set the Cache-Control headers here. Uncomment below.
        cacheControl: 'public,max-age=3600',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    final String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();

    return imageUrl;
  }
}
