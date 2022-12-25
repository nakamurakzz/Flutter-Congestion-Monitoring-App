import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  String _imagePath = 'No Image';

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Camera Preview'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
              child: Column(children: [
            Text(
              'Camera Preview',
              style: Theme.of(context).textTheme.headline5,
            ),
            Container(
              height: 300,
              width: 300,
              child: CameraPreview(controller),
            ),
            IconButton(
              onPressed: takePicture,
              icon: const Icon(Icons.camera_alt_outlined),
            ),
            // _imagePathの画像を表示する
            _imagePath != 'No Image'
                ? Image.file(
                    File(_imagePath),
                    width: 300,
                    height: 300,
                  )
                : Container(),
          ])),
        ),
      ),
    );
  }

  void takePicture() async {
    try {
      final path = await controller.takePicture();
      print(path.path);
      setState(() {
        _imagePath = path.path;
      });
    } catch (e) {
      print(e);
    }
  }
}
