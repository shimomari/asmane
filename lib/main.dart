//ルールと変数（1行目〜）
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const AsmaneApp());
}

class AsmaneApp extends StatelessWidget {
  const AsmaneApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPeakFlow = 400; // ピークフローの値を保存する変数

  String getNowTime() {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());
  }

  //メイン画面の見た目
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アスマネ')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(getNowTime(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            const SectionTitle(title: 'ピークフローの記録'),
            
            // --- ここにドラムロールが直接入ります ---
            SizedBox(
              height: 120,
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: (_currentPeakFlow - 100) ~/ 10,
                ),
                onSelectedItemChanged: (int index) {
                  setState(() {
                    _currentPeakFlow = 100 + (index * 10);
                  });
                },
                children: List.generate(71, (i) => 100 + (i * 10)).map((v) {
                  return Center(
                    child: Text(
                      '$v L/min',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: _currentPeakFlow == v ? FontWeight.bold : FontWeight.normal,
                        color: _currentPeakFlow == v ? Colors.blue : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const Divider(),
            const SectionTitle(title: '今日の症状'),
            const Wrap(
              spacing: 10,
              children: [
                SymptomButton(label: '咳'),
                SymptomButton(label: 'たん'),
                SymptomButton(label: '息苦しさ'),
                SymptomButton(label: '倦怠感'),
              ],
            ),
            const Divider(),
            const SectionTitle(title: '自由メモ'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(decoration: InputDecoration(hintText: '50字程度で入力...')),
            ),
          ],
        ),
      ),
    );
  }
}

//自作部品
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class SymptomButton extends StatelessWidget {
  final String label;
  const SymptomButton({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    return FilterChip(label: Text(label), onSelected: (bool value) {});
  }
}