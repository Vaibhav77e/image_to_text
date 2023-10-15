// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_to_text/repo/GetCameraController.dart';
// import 'package:image_to_text/result_screen.dart';

// class ImageRecoginzerScreen extends StatefulWidget {
//    ImageRecoginzerScreen({super.key});

//   @override
//   State<ImageRecoginzerScreen> createState() => _ImageRecoginzerScreenState();
// }

// class _ImageRecoginzerScreenState extends State<ImageRecoginzerScreen> {
//   CameraController? _cameraController;
// final GetCameraController getCameraController = Get.put(GetCameraController());
//   final _textRecognizer = TextRecognizer();

//     Future<void> _scanImage() async {
//     if (_cameraController == null) return;

//     try {
//       final _pictureImage = await _cameraController!.takePicture();
//       final file = File(_pictureImage.path);
//       final inputImage = InputImage.fromFile(file);
//       final recognizedText = await _textRecognizer.processImage(inputImage);

//       await Navigator.of(context).push(MaterialPageRoute(
//           builder: (context) =>
//               ResultScreen(scannedResultText: recognizedText.text)));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: const Text('An error occured will scanning text')));
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => FutureBuilder(
//                   future: availableCameras(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       getCameraController._initCameraController(snapshot.data!);
//                       return Center(
//                         child: CameraPreview(_cameraController!),
//                       );
//                     } else {
//                       return const LinearProgressIndicator();
//                     }
//                   },
//                 );) 
//   }
// }
