import 'package:flutter/material.dart';
import 'package:asmane_project/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 入力欄を制御するためのコントローラー
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 画面が開いたときに保存された値を読み込む
  }

  // 保存されている値を読み込んで、入力欄に表示する
  Future<void> _loadSettings() async {
    final min = await SettingsService.loadMin();
    final max = await SettingsService.loadMax();
    setState(() {
      _minController.text = min.toString();
      _maxController.text = max.toString();
    });
  }

  // 入力された値を保存する
  Future<void> _saveSettings() async {
    final min = double.tryParse(_minController.text) ?? 200.0;
    final max = double.tryParse(_maxController.text) ?? 600.0;
    
    await SettingsService.saveMin(min);
    await SettingsService.saveMax(max);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('設定を保存しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _minController,
              decoration: const InputDecoration(labelText: 'グラフの最小値'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _maxController,
              decoration: const InputDecoration(labelText: 'グラフの最大値'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('保存する'),
            ),
          ],
        ),
      ),
    );
  }
}