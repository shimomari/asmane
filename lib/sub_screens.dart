import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'health_data.dart';

// ==========================================
// 1. 週のグラフ表示ページ
// ==========================================
class WeeklyGraphPage extends StatelessWidget {
  final List<PefRecord> pefRecords;
  final List<SleepSession> sleepSessions;

  const WeeklyGraphPage({
    super.key,
    required this.pefRecords,
    required this.sleepSessions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("週のデータとグラフ")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("ピークフロー推移（直近7日間）", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 800,
                  // 睡眠時間を背景に描画
                  rangeAnnotations: RangeAnnotations(
                    verticalRangeAnnotations: sleepSessions.map((session) {
                      return VerticalRangeAnnotation(
                        x1: session.bedTime.weekday.toDouble() - 1,
                        x2: (session.wakeUpTime ?? DateTime.now()).weekday.toDouble() - 1,
                        color: Colors.grey.withValues(alpha: 0.2),
                      );
                    }).toList(),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: pefRecords.map((record) {
                        return FlSpot(record.time.weekday.toDouble() - 1, record.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("※グレーの帯は睡眠時間を示します", 
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. メインUI登録設定ページ
// ==========================================
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
    required this.pill
  });

  @override
  State<MainUIRegistrationPage> createState() => _MainUIRegistrationPageState();
}

class _MainUIRegistrationPageState extends State<MainUIRegistrationPage> {
  late List<String> _tempSymptoms;
  late List<String> _tempTriggers;
  late TextEditingController _relieverCtrl;
  late TextEditingController _pillCtrl;

  @override
  void initState() {
    super.initState();
    _tempSymptoms = List.from(widget.symptoms);
    _tempTriggers = List.from(widget.triggers);
    _relieverCtrl = TextEditingController(text: widget.reliever);
    _pillCtrl = TextEditingController(text: widget.pill);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("メインUI登録設定")),
      body: ListView(
        children: [
          _buildHeader("① 症状のボタン管理"),
          _buildEditableList(_tempSymptoms, "症状"),
          const Divider(),
          _buildHeader("② トリガーのボタン管理"),
          _buildEditableList(_tempTriggers, "トリガー"),
          const Divider(),
          _buildHeader("③ お薬の名前設定"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(controller: _relieverCtrl, decoration: const InputDecoration(labelText: "リリーバー（吸入など）")),
                TextField(controller: _pillCtrl, decoration: const InputDecoration(labelText: "頓服（内服など）")),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'symptoms': _tempSymptoms,
                'triggers': _tempTriggers,
                'reliever': _relieverCtrl.text,
                'pill': _pillCtrl.text
              }),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue),
              child: const Text("保存して反映", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  }

  Widget _buildEditableList(List<String> list, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 8, children: list.map((e) => Chip(label: Text(e), onDeleted: () => setState(() => list.remove(e)))).toList()),
          TextButton.icon(onPressed: () => _showAddDialog(list), icon: const Icon(Icons.add), label: Text("$typeを追加")),
        ],
      ),
    );
  }

  void _showAddDialog(List<String> list) {
    TextEditingController c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("追加"),
      content: TextField(controller: c, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("キャンセル")),
        TextButton(onPressed: () { if(c.text.isNotEmpty) setState(() => list.add(c.text)); Navigator.pop(ctx); }, child: const Text("追加"))
      ]
    ));
  }
}