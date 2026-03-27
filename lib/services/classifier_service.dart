import 'dart:io';
import 'package:flutter/services.dart'; // Tambah ni untuk load dari rootBundle
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ClassifierService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      print("DEBUG: Sedang cuba muatkan model dari assets...");

      // 1. Cuba load interpreter
      _interpreter = await Interpreter.fromAsset('model.tflite');
      print("DEBUG: Interpreter berjaya di-load!");

      // 2. Cuba load labels
      final labelString = await rootBundle.loadString('assets/labels.txt');
      _labels = labelString.split('\n').where((s) => s.isNotEmpty).toList();
      print("DEBUG: Labels berjaya di-load! Senarai: $_labels");

      if (_interpreter != null && _labels != null) {
        print("DEBUG: >>> MODEL READY UNTUK DIGUNAKAN <<<");
      }
    } catch (e) {
      // SINI PUNCANYA. Tengok kat terminal keluar error apa nanti.
      print("DEBUG FATAL ERROR masa loadModel: $e");
    }
  }

  String predict(img.Image image) {
    if (_interpreter == null) {
      print("DEBUG: Predict gagal sebab interpreter NULL");
      return "Model not loaded";
    }

    try {
      // 1. Resize
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // 2. Normalization (Teachable Machine guna 0.0 hingga 1.0 selalunya)
      var input = _imageToByteList(resizedImage);

      // 3. Output array
      var output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

      // 4. Run!
      _interpreter!.run(input, output);

      print("DEBUG: Raw Output Model: ${output[0]}"); // Tengok confidence level setiap label

      // 5. Cari result paling tinggi
      double highestProb = -1.0;
      int highestIndex = 0;

      for (int i = 0; i < output[0].length; i++) {
        if (output[0][i] > highestProb) {
          highestProb = output[0][i];
          highestIndex = i;
        }
      }

      String finalResult = _labels![highestIndex];
      print("DEBUG: Hasil Prediksi: $finalResult (Confidence: ${(highestProb * 100).toStringAsFixed(2)}%)");

      return finalResult;
    } catch (e) {
      print("DEBUG ERROR masa predict: $e");
      return "Error";
    }
  }

  // Teachable Machine standard normalization (0.0 to 1.0)
  List<dynamic> _imageToByteList(img.Image image) {
    var input = List.generate(1, (index) =>
        List.generate(224, (index) =>
            List.generate(224, (index) =>
                List.generate(3, (index) => 0.0))));

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        var pixel = image.getPixel(x, y);
        // Tukar ke 0.0 - 1.0 (Ni paling common untuk Teachable Machine)
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return input;
  }
}