import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ClassifierService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      // Baca labels.txt dari assets
      final labelData = await File('assets/labels.txt').readAsLines();
      _labels = labelData;
      print("Model & Labels loaded!");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  String predict(img.Image image) {
    if (_interpreter == null) return "Model not loaded";

    // 1. Resize gambar ke 224x224 (Standard Teachable Machine)
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // 2. Tukar jadi Float32 List (Normalisasi 0.0 - 1.0 atau -1.0 - 1.0)
    var input = _imageToByteList(resizedImage);
    
    // 3. Output array (Ikut jumlah label kau, contoh: 4 labels)
    var output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

    _interpreter!.run(input, output);

    // 4. Cari result paling tinggi
    double highestProb = -1.0;
    int highestIndex = 0;
    
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > highestProb) {
        highestProb = output[0][i];
        highestIndex = i;
      }
    }

    return _labels![highestIndex];
  }

  List<dynamic> _imageToByteList(img.Image image) {
    var input = List.generate(1, (index) => 
        List.generate(224, (index) => 
        List.generate(224, (index) => 
        List.generate(3, (index) => 0.0))));

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        var pixel = image.getPixel(x, y);
        input[0][y][x][0] = (pixel.r / 127.5) - 1.0;
        input[0][y][x][1] = (pixel.g / 127.5) - 1.0;
        input[0][y][x][2] = (pixel.b / 127.5) - 1.0;
      }
    }
    return input;
  }
}