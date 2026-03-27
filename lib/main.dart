import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'presentation/scanner.dart'; // Import page scanner tadi

// Global variable untuk simpan list camera (optional, tapi senang)
List<CameraDescription> cameras = [];

Future<void> main() async {
  // 1. Wajib ada ni kalau ada async process sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Dapatkan list camera yang ada kat phone (depan/belakang)
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }

  // 3. Jalankan app
  runApp(AgroGradeApp());
}

class AgroGradeApp extends StatelessWidget {
  const AgroGradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroGrade AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green, // Tema Agro, mestilah hijau
        useMaterial3: true,
      ),
      // 4. Terus buka ScannerPage sebagai main screen
      home: ScannerPage(), 
    );
  }
}