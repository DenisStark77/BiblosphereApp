import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

class CameraHome extends StatefulWidget {
  @override
  _CameraAppState createState() => new _CameraAppState();
}

class _CameraAppState extends State<CameraHome> {
  CameraController controller;

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
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
                onPressed: () {},
                tooltip: 'Make a photo',
                child: new Icon(Icons.photo_camera),
              ),
            ),
          ],
        ),
    );
  }
}