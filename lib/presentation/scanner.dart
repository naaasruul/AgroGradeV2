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
  bool _isModelReady = false; // Tambah variable ni kat atas class _ScannerPageState

  CameraController? _controller;
  final ClassifierService _classifier = ClassifierService();
  String result = "Sila halakan kamera ke buah";
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupScanner();
  }

  DateTime? _lastRun; // Tambah ni kat atas


  Future<void> _setupScanner() async {
    setState(() { result = "Loading model..."; });

    try {
      await _classifier.loadModel();
      _isModelReady = true; // Set true bila dah habis await
      print("DEBUG: Model confirm dah ready!");
    } catch (e) {
      print("DEBUG ERROR: Model gagal load: $e");
      setState(() { result = "Model Error!"; });
      return;
    }

    final available = await availableCameras();
    _controller = CameraController(available[0], ResolutionPreset.low);
    await _controller!.initialize();

    _controller!.startImageStream((cameraImage) {
      // TAMBAH CHECK NI: Kalau model belum ready, jangan buat apa-apa
      if (!_isModelReady) return;

      final now = DateTime.now();
      if (!isProcessing && (_lastRun == null || now.difference(_lastRun!).inMilliseconds > 1000)) {
        isProcessing = true;
        _lastRun = now;
        _analyzeFrame(cameraImage).then((_) => isProcessing = false);
      }
    });

    if (mounted) setState(() {});
  }
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _analyzeFrame(CameraImage cameraImage) async {
    try {
      print("DEBUG: Memulakan analisa frame...");

      // 1. Convert (Punca utama lag)
      final image = _convertYUV420ToImage(cameraImage);

      // 2. Predict
      final prediction = _classifier.predict(image);

      if (mounted) {
        setState(() {
          result = "Dikesan: $prediction";
        });
      }
      print("DEBUG: Analisa selesai. Hasil: $prediction");

    } catch (e) {
      print("DEBUG ERROR dalam _analyzeFrame: $e");
    }
  }

  // Helper utk convert format kamera phone ke format Image
  img.Image _convertYUV420ToImage(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;

      // Plane 0 adalah Y (Luminance/Hitam-Putih)
      // Kita buat Image kosong dulu
      var converted = img.Image(width: width, height: height);

      // Ambil bytes dari Plane 0
      final Uint8List plane0 = image.planes[0].bytes;

      // Isi pixel satu-satu (Cara ni lambat sikit tapi TAKKAN crash)
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int index = y * width + x;
          if (index < plane0.length) {
            final int grey = plane0[index];
            // Set pixel sebagai grayscale (R=G=B)
            converted.setPixelRgb(x, y, grey, grey, grey);
          }
        }
      }

      // Resize terus ke saiz yang AI nak (224x224)
      return img.copyResize(converted, width: 224, height: 224);
    } catch (e) {
      print("DEBUG ERROR dalam conversion: $e");
      // Return image kosong 1x1 supaya tak crash kat predict
      return img.Image(width: 1, height: 1);
    }
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