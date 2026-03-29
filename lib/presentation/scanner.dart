import 'package:agrograde/presentation/result_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/classifier_service.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override


  _ScannerPageState createState() => _ScannerPageState();
}

// ignore: library_private_types_in_public_api

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _controller;
  final ClassifierService _classifier = ClassifierService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupScanner();
  }

  Future<void> _setupScanner() async {
    await _classifier.loadModel();
    final available = await availableCameras();
    _controller = CameraController(available[0], ResolutionPreset.medium); // Medium is better for snapshots
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _captureAndAnalyze() async {
    if (_isProcessing || _controller == null || !_controller!.value.isInitialized) return;

    setState(() { _isProcessing = true; });

    try {
      // 1. Capture the image
      final XFile photo = await _controller!.takePicture();

      // 2. Convert file to image object
      final Uint8List bytes = await photo.readAsBytes();
      final img.Image? capturedImage = img.decodeImage(bytes);

      if (capturedImage != null) {
        // 3. Resize and Predict
        final resizedImage = img.copyResize(capturedImage, width: 224, height: 224);
        final prediction = _classifier.predict(resizedImage);

        // 4. Navigate to Result Screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                prediction: prediction,
                imagePath: photo.path,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text("AgroGrade Scanner")),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          // Overlay UI
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _captureAndAnalyze,
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.camera, color: Colors.green, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}