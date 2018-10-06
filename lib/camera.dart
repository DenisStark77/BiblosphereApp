import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

List<CameraDescription> cameras;
final FirebaseStorage storage = new FirebaseStorage();
final Geolocator _geolocator = Geolocator();

class CameraHome extends StatefulWidget {
  @override
  _CameraAppState createState() => new _CameraAppState();
}

class _CameraAppState extends State<CameraHome> {
  CameraController controller;
  String imagePath;

  @override
  void initState() {
    super.initState();
    controller = new CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return new Container();
    }
    return new AspectRatio(
        aspectRatio:
        controller.value.aspectRatio,
        child: new Stack (
         children: <Widget> [
            new CameraPreview(controller),
            new Align (
              alignment: Alignment(0.0, 1.0),
              child: new FloatingActionButton(
                onPressed: controller != null &&
                    controller.value.isInitialized
                    ? onTakePictureButtonPressed
                    : null,
                tooltip: 'Make a photo',
                child: new Icon(Icons.photo_camera),
              ),
            ),
          ],
        ),
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
//        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }


  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  // Take picture and upload it to Firebase storage
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      print(e.toString());
      return null;
    }
    print("Picture taken to $filePath");

    //TODO: catch exteptions
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();

    //TODO: catch exteptions
    final String storageUrl = await uploadPicture(filePath, user);

    // TODO: catch exceptions
    final position = await _geolocator.getLastKnownPosition(LocationAccuracy.high);

    // Get Facebook profile id
    // TODO: Catch exceptions
    final token = await FacebookLogin().currentAccessToken;
    var graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token.token}');
    var profile = json.decode(graphResponse.body);


    //TODO: Create record in Firestore database with location, URL, and user
    DocumentReference doc = await Firestore.instance.collection('shelves').add({ 'user': profile["id"], 'URL': storageUrl,
      'position': new GeoPoint(position.latitude, position.longitude) });

    return storageUrl;
  }

  Future<String> uploadPicture(String pictureFile, FirebaseUser user) async {
    final File file = new File(pictureFile);
    final StorageReference ref = storage.ref().child('images').child(user.uid).child('${timestamp()}.jpg');
    final StorageUploadTask uploadTask = ref.putFile(
      file,
      new StorageMetadata(
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    final Uri downloadUrl = (await uploadTask.future).downloadUrl;
        print("Picture uploaded to ${downloadUrl.toString()}");

    return downloadUrl.toString();
  }
}
