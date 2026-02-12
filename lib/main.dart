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
  int _currentPeakFlow = 400;

  String getNowTime() {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());
  }

  // 🔧 修正：ダイアログをクラス内に移動
  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("登録完了"),
          content: const Text("今日の体調をしっかり記録しました！"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アスマネ'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
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

            // 3. ピークフロー
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
                        fontWeight: _currentPeakFlow == v
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _currentPeakFlow == v
                            ? Colors.blue
                            : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(),

            // 4. 症状
            const SectionTitle(title: '今の症状'),
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
            const SleepSection(),
            const Divider(),

            const TriggerSection(),
            const Divider(),

            const RelieverSection(),
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

            const SizedBox(height: 30),

            // 🔧 修正：クラス内メソッドを呼ぶ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _showSaveDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "この内容で登録する",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// --- 以下、設計図（クラス）たち ---

class SleepSection extends StatelessWidget {
  const SleepSection({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      SectionTitle(title: "睡眠"),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SymptomButton(label: "就"),
          SymptomButton(label: "起"),
          SymptomButton(label: "中途"),
        ],
      ),
    ]);
  }
}

class TriggerSection extends StatelessWidget {
  const TriggerSection({super.key});
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      SectionTitle(title: "トリガー（要因）の記録"),
      Wrap(
        spacing: 8,
        children: [
          SymptomButton(label: "埃・ハウスダスト"),
          SymptomButton(label: "気圧変化"),
          SymptomButton(label: "風邪"),
          SymptomButton(label: "運動"),
          SymptomButton(label: "タバコ"),
        ],
      ),
    ]);
  }
}

class RelieverSection extends StatefulWidget {
  const RelieverSection({super.key});
  @override
  State<RelieverSection> createState() => _RelieverSectionState();
}

class _RelieverSectionState extends State<RelieverSection> {
  int _relieverCount = 0;
  int _stockCount = 60;
  int _pillCount = 0;

  @override
  Widget build(BuildContext context) {
    Color relieverColor = _relieverCount > 0
        ? Colors.red[100 * (_relieverCount > 9 ? 9 : _relieverCount)]!
        : Colors.grey[200]!;

    Color pillColor = _pillCount > 0
        ? Colors.purple[100 * (_pillCount > 9 ? 9 : _pillCount)]!
        : Colors.grey[200]!;

    return Column(children: [
      const SectionTitle(title: "7．緊急時の記録（吸入・内服）"),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(children: [
            const Text("吸入"),
            GestureDetector(
              onTap: () => setState(() {
                _relieverCount++;
                if (_stockCount > 0) _stockCount--;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: relieverColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text("$_relieverCount回")),
              ),
            ),
            Text("残量: $_stockCount回"),
          ]),
          Column(children: [
            const Text("内服"),
            GestureDetector(
              onTap: () => setState(() {
                _pillCount++;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: pillColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text("$_pillCount回")),
              ),
            ),
            const Text(" "),
          ]),
        ],
      ),
    ]);
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        onSelected: (bool value) {},
      ),
    );
  }
}
