import 'package:flutter/material.dart';

class MainUIRegistrationPage extends StatefulWidget {
  final List<String> symptoms;
  final List<String> triggers;
  final String reliever;
  final String pill;

  const MainUIRegistrationPage({
    super.key,
    required this.symptoms,
    required this.triggers,
    required this.reliever,
    required this.pill,
  });

  @override
  State<MainUIRegistrationPage> createState() => _MainUIRegistrationPageState();
}

class _MainUIRegistrationPageState extends State<MainUIRegistrationPage> {
  // 編集用のコントローラー
  late TextEditingController _relieverController;
  late TextEditingController _pillController;
  late List<String> _currentSymptoms;

  @override
  void initState() {
    super.initState();
    _relieverController = TextEditingController(text: widget.reliever);
    _pillController = TextEditingController(text: widget.pill);
    _currentSymptoms = List<String>.from(widget.symptoms);
  }

  @override
  void dispose() {
    _relieverController.dispose();
    _pillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('項目の登録・編集'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('使用している薬', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _relieverController,
            decoration: const InputDecoration(labelText: '発作止め（リリーバー）'),
          ),
          TextField(
            controller: _pillController,
            decoration: const InputDecoration(labelText: '追加の薬（ステロイド等）'),
          ),
          const SizedBox(height: 20),
          const Text('チェック項目（症状）', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._currentSymptoms.map((symptom) => ListTile(
            title: Text(symptom),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() => _currentSymptoms.remove(symptom));
              },
            ),
          )),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // 変更した内容をメイン画面に返却
              Navigator.pop(context, {
                'reliever': _relieverController.text,
                'pill': _pillController.text,
                'symptoms': _currentSymptoms,
              });
            },
            child: const Text('変更を保存する'),
          ),
        ],
      ),
    );
  }
}