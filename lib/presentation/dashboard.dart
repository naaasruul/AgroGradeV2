import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/classifier_service.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AgroGrade Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back, Nas!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _buildStatCard("Total Scans Today", "24", Colors.green),
            SizedBox(height: 10),
            _buildStatCard("High Quality Fruits", "18", Colors.blue),
            SizedBox(height: 30),
            Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: [
                  ListTile(leading: Icon(Icons.apple), title: Text("Apple - Grade A"), subtitle: Text("2 minutes ago")),
                  ListTile(leading: Icon(Icons.lunch_dining), title: Text("Orange - Grade B"), subtitle: Text("1 hour ago")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}