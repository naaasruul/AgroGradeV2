import 'dart:io';
import 'package:flutter/material.dart';
import '../services/db_service.dart'; // Kita akan buat file ni kejap lagi

class ResultPage extends StatefulWidget {
  final String prediction; // Contoh: "Epal_Rosak"
  final String imagePath;

  const ResultPage({super.key, required this.prediction, required this.imagePath});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final DbService _dbService = DbService();
  bool _isSaving = false;

  // Data tambahan untuk Nutrisi & Resipi
  Map<String, dynamic> getFruitInfo(String label) {
    if (label.contains('Rosak')) {
      return {
        "status": "Rosak / Hampir Rosak",
        "nutrisi": "Nutrisi berkurang disebabkan proses pengoksidaan.",
        "resipi": "Jangan buang! Boleh buat baja kompos atau jika sikit sahaja rosak, potong bahagian elok untuk buat jem/sos.",
        "color": Colors.red
      };
    } else {
      return {
        "status": "Elok / Segar",
        "nutrisi": "Tinggi serat dan vitamin aktif. Bagus untuk penghadaman.",
        "resipi": "Sesuai dimakan terus atau dibuat salad buah segar.",
        "color": Colors.green
      };
    }
  }

  Future<void> _handleConfirm() async {
    setState(() => _isSaving = true);

    // Simpan ke Firebase
    await _dbService.saveScanResult(widget.prediction);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berjaya disimpan ke Dashboard!")),
      );
      Navigator.pop(context); // Balik ke scanner
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = getFruitInfo(widget.prediction);

    return Scaffold(
      appBar: AppBar(title: const Text("Justifikasi Buah")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.prediction.replaceAll('_', ' '),
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: info['color']),
                  ),
                  const Divider(),
                  _buildInfoSection("Status", info['status'], Icons.info_outline),
                  _buildInfoSection("Nutrisi", info['nutrisi'], Icons.health_and_safety),
                  _buildInfoSection("Cadangan Resipi", info['resipi'], Icons.restaurant_menu),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Retake"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: _isSaving ? null : _handleConfirm,
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Confirm & Save", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(content, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}