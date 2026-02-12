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
            // 1. ハンバーガーメニューを実装
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
           
           // 5. 睡眠の記録セクション
            const Divider(),
            const SleepSection(),
            const Divider(),

           // 6. トリガーの記録セクション

            const TriggerSection(), // 6. トリガーの記録を追加
            const Divider(),        // 次の項目との仕切り線

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
//タイトルの見た目を作る//
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
//症状ボタンのセクション
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
// 睡眠セクションのボタンをまとめて作る部品
class SleepSection extends StatefulWidget {
  const SleepSection({super.key});

  @override
  State<SleepSection> createState() => _SleepSectionState();
}

class _SleepSectionState extends State<SleepSection> {
  // それぞれのボタンが押されているかどうかを覚えておく変数
  bool isAsleep = false;
  bool isAwake = false;
  bool isMidAwake = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(title: "5．睡眠"), // タイトルを表示
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToggleButton("就寝", isAsleep, () => setState(() => isAsleep = !isAsleep)),
            _buildToggleButton("起床", isAwake, () => setState(() => isAwake = !isAwake)),
            _buildToggleButton("中途覚醒", isMidAwake, () => setState(() => isMidAwake = !isMidAwake)),
          ],
        ),
      ],
    );
  }

  // ボタンひとつひとつを作るためのレシピ
  Widget _buildToggleButton(String label, bool active, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: (bool value) => onTap(),
      selectedColor: Colors.blue[200], // 押した時の色
    );
  }
}  

// --- 6. トリガー（要因）のセクションの本体 ---
class TriggerSection extends StatefulWidget {
  const TriggerSection({super.key});

  @override
  State<TriggerSection> createState() => _TriggerSectionState();
}

class _TriggerSectionState extends State<TriggerSection> {
  // 表示する項目リスト
  final Map<String, bool> _triggers = {
    '埃・ハウスダスト': false,
    '気圧変化': false,
    '風邪': false,
    '運動': false,
    'タバコ': false,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(title: "6.トリガー（要因）の記録"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8.0,
            children: _triggers.keys.map((String key) {
              return FilterChip(
                label: Text(key),
                selected: _triggers[key]!,
                onSelected: (bool value) {
                  setState(() {
                    _triggers[key] = value;
                  });
                },
                selectedColor: Colors.orange[200], // トリガーはオレンジ色に
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}