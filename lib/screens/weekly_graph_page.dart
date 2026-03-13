import 'package:flutter/material.dart';

class WeeklyGraphPage extends StatelessWidget {
  const WeeklyGraphPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(title: const Text("週間統計"), backgroundColor: Colors.white),
      body: const Center(child: Text("統計グラフ表示エリア")),
    );
  }
}