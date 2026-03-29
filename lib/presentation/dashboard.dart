import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Format ID dokumen harian (Contoh: 2026-03-28)
    String todayDocId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("AgroGrade Dashboard"),
        backgroundColor: Colors.green.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "Welcome back",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),

            // --- BAHAGIAN STATISTIK HARIAN ---
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('daily_stats')
                  .doc(todayDocId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Row(
                    children: [
                      Expanded(child: _buildStatCard("Elok Hari Ini", "0", Colors.green)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard("Rosak Hari Ini", "0", Colors.red)),
                    ],
                  );
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                int elok = data['Elok'] ?? 0;
                int rosak = data['Rosak'] ?? 0;

                return Row(
                  children: [
                    Expanded(child: _buildStatCard("Elok Hari Ini", "$elok", Colors.green)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard("Rosak Hari Ini", "$rosak", Colors.red)),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
            const Text(
                "Recent Activity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),

            // --- BAHAGIAN SENARAI AKTIVITI TERKINI ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('scans')
                    .orderBy('timestamp', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Tiada aktiviti imbasan setakat ini."));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var data = doc.data() as Map<String, dynamic>;

                      String fruit = data['fruit'] ?? "Buah";
                      String status = data['status'] ?? "Unknown";
                      Timestamp? time = data['timestamp'] as Timestamp?;

                      String formattedTime = time != null
                          ? DateFormat('hh:mm a').format(time.toDate())
                          : "Baru sahaja";

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: status == 'Elok' ? Colors.green : Colors.red,
                            child: Icon(
                              status == 'Elok' ? Icons.check : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                          title: Text("$fruit - $status"),
                          subtitle: Text(formattedTime),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)
            ),
          ],
        ),
      ),
    );
  }
}