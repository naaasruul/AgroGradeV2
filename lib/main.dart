import 'package:agrograde/presentation/dashboard.dart';
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

// lib/main.dart (Updated Home)
class AgroGradeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [DashboardPage(), ScannerPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scanner'),
        ],
      ),
    );
  }
}