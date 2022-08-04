import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:async';
import 'utils.dart';
import 'gallery.dart';
import 'main.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen(
      {super.key, required this.collection, required this.overlayImage});

  final String collection;
  final Image? overlayImage;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRearCameraSelected = true;

  @override
  void initState() {
    super.initState();
    initCamera(cameras[_isRearCameraSelected ? 0 : 1]);
  }

  Future initCamera(CameraDescription cameraDescription) async {
    WidgetsFlutterBinding.ensureInitialized();
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
    try {
      await _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    return CameraPreview(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: Stack(children: [
        Container(color: Colors.black),
        (_controller.value.isInitialized)
            ? _buildCameraPreview()
            : const Center(child: CircularProgressIndicator()),
        Opacity(
          opacity: 0.6,
          child: widget.overlayImage,
        ),
        Positioned(
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 1,
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: <Widget>[
                Container(
                  alignment: Alignment.bottomCenter,
                  color: Colors.black,
                ),
                Container(
                  alignment: Alignment.center,
                  child: IconButton(
                    iconSize: 80,
                    color: Colors.white,
                    icon: const Icon(CupertinoIcons.circle_filled),
                    onPressed: () async {
                      try {
                        await initCamera(
                            cameras[_isRearCameraSelected ? 0 : 1]);
                        final image = await _controller.takePicture();
                        if (!mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DisplayPictureScreen(
                              imagePath: image.path,
                              collection: widget.collection,
                            ),
                          ),
                        );
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ),
              ],
            )),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isRearCameraSelected = !_isRearCameraSelected;
            WidgetsFlutterBinding.ensureInitialized();
            initCamera(cameras[_isRearCameraSelected ? 0 : 1]);
          });
        },
        child: Icon(
          _isRearCameraSelected
              ? CupertinoIcons.switch_camera
              : CupertinoIcons.switch_camera_solid,
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String collection;

  const DisplayPictureScreen(
      {super.key, required this.imagePath, required this.collection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        body: Center(
          child: SizedBox(
              height: MediaQuery.of(context).size.height * 1,
              width: MediaQuery.of(context).size.width * 0.70,
              child: Column(
                children: [
                  Image.file(File(imagePath)),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                        onPressed: () {
                          copyImage(File(imagePath), collection);
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RouteOne(
                                collection: collection,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check)),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close)),
                  ]),
                ],
              )),
        ));
  }
}
