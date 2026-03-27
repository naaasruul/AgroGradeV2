import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/classifier_service.dart';
import 'package:image/image.dart' as img;

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _controller;
  final ClassifierService _classifier = ClassifierService();
  String result = "Sila halakan kamera ke buah";
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupScanner();
  }

  Future<void> _setupScanner() async {
    await _classifier.loadModel();
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();

    _controller!.startImageStream((image) {
      if (!isProcessing) {
        isProcessing = true;
        _analyzeFrame(image);
      }
    });
    if (mounted) setState(() {});
  }

  Future<void> _analyzeFrame(CameraImage cameraImage) async {
    // Convert CameraImage ke format Image (Logic ni agak berat, run dlm isolate kalau lag)
    final image = _convertYUV420ToImage(cameraImage);
    final prediction = _classifier.predict(image);

    setState(() {
      result = prediction;
      isProcessing = false;
    });
  }

  // Helper utk convert format kamera phone ke format Image
  img.Image _convertYUV420ToImage(CameraImage image) {
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer, // Simplified for example
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text("AgroGrade Scanner")),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller!)),
          Container(
            padding: EdgeInsets.all(20),
            child: Text(result, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
          )
        ],
      ),
    );
  }
}