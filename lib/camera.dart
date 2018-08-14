import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras;

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
    return filePath;
  }
}