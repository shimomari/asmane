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
      title: 'アスマネ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
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
  // --- 状態管理変数 ---
  int _currentPeakFlow = 400;

  // --- 便利関数 ---
  String getNowTime() {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アスマネ'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // 今後ハンバーガーメニューを実装
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. 現在時刻の表示
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                getNowTime(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),

            // 3. ピークフローの記録（常時表示ドラムロール）
            const SectionTitle(title: 'ピークフローの記録'),
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

            // 4. 症状の記録
            const SectionTitle(title: '今日の症状'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SymptomButton(label: '咳'),
                  SymptomButton(label: 'たん'),
                  SymptomButton(label: '息苦しさ'),
                  SymptomButton(label: '倦怠感'),
                ],
              ),
            ),
            const Divider(),

            // 9. 自由メモ
            const SectionTitle(title: '自由メモ'),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                maxLength: 50,
                decoration: InputDecoration(
                  hintText: '50字程度で入力...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- カスタムウィジェット（部品） ---

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class SymptomButton extends StatelessWidget {
  final String label;
  const SymptomButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      onSelected: (bool selected) {
        // 今後選択状態を管理
      },
    );
  }
}