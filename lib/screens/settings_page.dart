import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("設定"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildItem(Icons.person_outline, "プロフィール設定"),
          _buildItem(Icons.notifications_none, "通知設定"),
          _buildItem(Icons.help_outline, "ヘルプ"),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}