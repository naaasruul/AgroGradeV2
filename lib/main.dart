import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Wajib import
import 'presentation/scanner.dart';
import 'presentation/dashboard.dart';

// Simpan list camera secara global supaya senang diakses oleh ScannerPage
List<CameraDescription> cameras = [];

Future<void> main() async {
  // 1. Pastikan binding di-initialize sebelum Firebase atau Camera diakses
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Setup Firebase
  try {
    await Firebase.initializeApp();
    print("DEBUG: Firebase berjaya di-load!");
  } catch (e) {
    print("DEBUG ERROR: Firebase gagal load: $e");
    // Tips: Pastikan fail google-services.json dah ada dalam android/app/
  }

  // 3. Dapatkan list camera yang ada pada peranti
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error Camera: ${e.code}\nMessage: ${e.description}');
  }

  runApp(const AgroGradeApp());
}

class AgroGradeApp extends StatelessWidget {
  const AgroGradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroGrade AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Senarai skrin utama untuk Bottom Navigation
  final List<Widget> _pages = [
    DashboardPage(),
    const ScannerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack digunakan supaya state page (seperti camera) tidak reset
      // setiap kali kita tukar tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_enhance_rounded),
            label: 'Scanner',
          ),
        ],
      ),
    );
  }
}