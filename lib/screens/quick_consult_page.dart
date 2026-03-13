import 'package:flutter/material.dart';

class QuickConsultPage extends StatelessWidget {
  const QuickConsultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(title: const Text("受診サマリー"), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: const Center(child: Text("医師に見せる画面")),
    );
  }
}