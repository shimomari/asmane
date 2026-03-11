import 'package:flutter/material.dart';
import 'settings_service.dart'; // 保存・読み込み機能
import 'health_data.dart';    // 共有変数 graphMinY, graphMaxY

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 入力フォームを制御するためのコントローラー
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    // 現在の数値をテキストボックスにセット
    _minController = TextEditingController(text: graphMinY.toStringAsFixed(0));
    _maxController = TextEditingController(text: graphMaxY.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  // 設定を保存する処理
  Future<void> _saveSettings() async {
    final double? newMin = double.tryParse(_minController.text);
    final double? newMax = double.tryParse(_maxController.text);

    if (newMin != null && newMax != null && newMin < newMax) {
      // 1. 共有変数を更新
      graphMinY = newMin;
      graphMaxY = newMax;

      // 2. スマホ本体に保存
      await SettingsService.saveMin(newMin);
      await SettingsService.saveMax(newMax);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('設定を保存しました')),
        );
        Navigator.pop(context); // 前の画面に戻る
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正しい数値を入力してください（最小 < 最大）')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('グラフ表示設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('ピークフローの表示範囲を設定できます。', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            TextField(
              controller: _minController,
              decoration: const InputDecoration(labelText: 'グラフの最小値 (L/min)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _maxController,
              decoration: const InputDecoration(labelText: 'グラフの最大値 (L/min)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('設定を保存して戻る'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}