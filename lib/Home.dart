import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_to_text/result_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

// WidgetsBindingObserver provides information about app life cycle like app is background or not.
class _HomeState extends State<Home> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  CameraController? _cameraController;
  final _textRecognizer = TextRecognizer();

  late final Future<void> _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textRecognizer.close();
    _stopCamera();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

// to initialize which cameraController should be accessed front or back

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }
    //select the camera we need
    CameraDescription? camera;

    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription currentCamera = cameras[i];
      if (currentCamera.lensDirection == CameraLensDirection.back) {
        camera = currentCamera;
        break;
      }
    }
    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController =
        CameraController(camera, ResolutionPreset.max, enableAudio: false);
    // add this method to initialize the camera
    await _cameraController?.initialize();

    // helps to refersh the state while the camera is already intialized
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null && !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    try {
      final _pictureImage = await _cameraController!.takePicture();
      final file = File(_pictureImage.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ResultScreen(scannedResultText: recognizedText.text)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('An error occured will scanning text')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          return Stack(
            children: [
              if (_isPermissionGranted)
                FutureBuilder(
                  future: availableCameras(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _initCameraController(snapshot.data!);
                      return Center(
                        child: CameraPreview(_cameraController!),
                      );
                    } else {
                      return const LinearProgressIndicator();
                    }
                  },
                ),
              Scaffold(
                appBar: AppBar(
                  title: const Text('Image to Text'),
                ),
                backgroundColor:
                    _isPermissionGranted ? Colors.transparent : null,
                body: _isPermissionGranted
                    ? Column(
                        children: [
                          Expanded(child: Container()),
                          Container(
                            child: ElevatedButton(
                              onPressed: _scanImage,
                              child: const Text('Scan Text'),
                            ),
                          )
                        ],
                      )
                    : Center(
                        child: Container(
                          child: Text('Camera permission denied'),
                        ),
                      ),
              ),
            ],
          );
        });
  }
}
