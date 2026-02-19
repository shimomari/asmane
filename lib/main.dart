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
  List<String> _mySymptoms = ['咳', 'たん', '息苦しさ'];
  List<String> _myTriggers = ['埃', '気圧変化', '運動'];
  String _relieverName = "メプチン";
  String _pillName = "プレドニン";

  final Map<String, int> _symptomCounts = {};
  final Set<String> _selectedTriggers = {};
  final Set<String> _selectedSleep = {};
  int _relieverCount = 0;
  int _relieverStock = 60;
  int _pillCount = 0;

  String getNowTime() {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());
  }

  Future<void> _goToSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          initialSymptoms: _mySymptoms,
          initialTriggers: _myTriggers,
          initialReliever: _relieverName,
          initialPill: _pillName,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _mySymptoms = result['symptoms'];
        _myTriggers = result['triggers'];
        _relieverName = result['reliever'];
        _pillName = result['pill'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アスマネ')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue),
              child: Text('メニュー', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            _menuItem(Icons.settings, "メインUI登録用設定", onTap: _goToSettings),
            _menuItem(Icons.show_chart, "週のデータとグラフ"),
            _menuItem(Icons.local_hospital, "ワンタップ受診"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(getNowTime(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            const SectionTitle(title: '3. ピークフローの記録'),
            _buildPeakFlowPicker(),
            const Divider(),
            const SectionTitle(title: '4. 症状の記録 (タップで強度変更)'),
            _buildSymptomSection(),
            const Divider(),
            const SectionTitle(title: '5. 睡眠'),
            _buildWrapChips(['就寝', '起床', '中途覚醒'], _selectedSleep, Colors.blue),
            const Divider(),
            const SectionTitle(title: '6. トリガーの記録'),
            _buildWrapChips(_myTriggers, _selectedTriggers, Colors.green),
            const Divider(),
            const SectionTitle(title: '7&8. 緊急時の記録'),
            _buildEmergencySection(),
            const Divider(),
            const SectionTitle(title: '9. 自由メモ'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(maxLength: 50, decoration: InputDecoration(border: OutlineInputBorder())),
            ),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) onTap();
      },
    );
  }

  Widget _buildPeakFlowPicker() {
    return SizedBox(
      height: 100,
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(initialItem: (_currentPeakFlow - 100) ~/ 10),
        onSelectedItemChanged: (i) => setState(() => _currentPeakFlow = 100 + (i * 10)),
        children: List.generate(71, (i) => Center(child: Text('${100 + (i * 10)} L/min'))),
      ),
    );
  }

  Widget _buildSymptomSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _mySymptoms.map((s) {
          int count = _symptomCounts[s] ?? 0;
          Color bgColor = Colors.grey[200]!;
          String label = s;
          if (count == 1) { bgColor = Colors.orange[100]!; label = "$s(軽)"; }
          if (count == 2) { bgColor = Colors.orange[300]!; label = "$s(中)"; }
          if (count == 3) { bgColor = Colors.red[400]!; label = "$s(重)"; }

          return GestureDetector(
            onTap: () => setState(() => _symptomCounts[s] = (count + 1) % 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: count > 0 ? Colors.orange : Colors.grey),
              ),
              child: Text(label, style: TextStyle(fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWrapChips(List<String> list, Set<String> selectionSet, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: list.map((item) {
          final isSel = selectionSet.contains(item);
          return FilterChip(
            label: Text(item),
            selected: isSel,
            selectedColor: color.withValues(alpha: 0.3),
            onSelected: (val) => setState(() => val ? selectionSet.add(item) : selectionSet.remove(item)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _emergencyButton(_relieverName, _relieverCount, Colors.red, () {
          setState(() {
            _relieverCount = (_relieverCount + 1) % 5;
            if (_relieverCount != 0 && _relieverStock > 0) _relieverStock--;
          });
        }, "残量: $_relieverStock"),
        _emergencyButton(_pillName, _pillCount, Colors.purple, () {
          setState(() => _pillCount = (_pillCount + 1) % 3);
        }, ""),
      ],
    );
  }

  Widget _emergencyButton(String name, int count, Color color, VoidCallback onTap, String subText) {
    double alpha = count == 0 ? 0.1 : (count * 0.25);
    return Column(
      children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 35,
            backgroundColor: color.withValues(alpha: alpha),
            child: Text(count == 0 ? "未" : "$count回", style: const TextStyle(color: Colors.black, fontSize: 12)),
          ),
        ),
        if (subText.isNotEmpty) Text(subText, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("登録しました"))),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("この内容で登録する", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final List<String> initialSymptoms;
  final List<String> initialTriggers;
  final String initialReliever;
  final String initialPill;

  const SettingsPage({super.key, required this.initialSymptoms, required this.initialTriggers, required this.initialReliever, required this.initialPill});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late List<String> syms;
  late List<String> trigs;
  late TextEditingController relCtrl;
  late TextEditingController pillCtrl;

  @override
  void initState() {
    super.initState();
    syms = List.from(widget.initialSymptoms);
    trigs = List.from(widget.initialTriggers);
    relCtrl = TextEditingController(text: widget.initialReliever);
    pillCtrl = TextEditingController(text: widget.initialPill);
  }

  void _addItem(List<String> list) {
    TextEditingController c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("項目追加"),
        content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(hintText: "名前を入力")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("キャンセル")),
          TextButton(onPressed: () { if (c.text.isNotEmpty) setState(() => list.add(c.text)); Navigator.pop(ctx); }, child: const Text("追加")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UI登録用設定")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _editSection("表示する症状", syms),
          const Divider(),
          _editSection("表示するトリガー", trigs),
          const Divider(),
          const Text("薬剤名設定", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: relCtrl, decoration: const InputDecoration(labelText: "リリーバー薬")),
          TextField(controller: pillCtrl, decoration: const InputDecoration(labelText: "頓服薬")),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {'symptoms': syms, 'triggers': trigs, 'reliever': relCtrl.text, 'pill': pillCtrl.text}),
            child: const Text("設定を保存して戻る"),
          ),
        ],
      ),
    );
  }

  Widget _editSection(String title, List<String> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title), IconButton(onPressed: () => _addItem(list), icon: const Icon(Icons.add))]),
        Wrap(spacing: 8, children: list.map((e) => Chip(label: Text(e), onDeleted: () => setState(() => list.remove(e)))).toList()),
      ],
    );
  }
}