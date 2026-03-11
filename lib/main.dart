import 'package:flutter/material.dart';
import 'main_screen.dart'; // 作成したファイル名に合わせてください

void main() {
  runApp(const AsmaneApp());
}

class AsmaneApp extends StatelessWidget {
  const AsmaneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asmane',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
      ),
      home: const MainScreen(), // ここでメイン画面を呼び出す
    );
  }
}