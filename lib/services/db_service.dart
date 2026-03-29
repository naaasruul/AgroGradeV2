import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveScanResult(String label) async {
    final now = DateTime.now();
    final String status = label.contains('Rosak') ? 'Rosak' : 'Elok';
    final String fruitName = label.split('_')[0];

    // 1. Simpan history (untuk list aktiviti)
    await _db.collection('scans').add({
      'fruit': fruitName,
      'label': label,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Update Counter untuk Dashboard (Harian)
    // Document ID format: 2026-03-28
    String dayDoc = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    await _db.collection('daily_stats').doc(dayDoc).set({
      status: FieldValue.increment(1),
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}