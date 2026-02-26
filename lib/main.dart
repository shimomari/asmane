import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
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
  // --- 管理データ ---
  int _currentPeakFlow = 400;
  List<String> _mySymptoms = ['咳', 'たん', '息苦しさ', '喘鳴'];
  List<String> _myTriggers = ['埃・ハウスダスト', '気圧変化', '風邪', '運動'];
  String _relieverName = "メプチン";
  String _pillName = "プレドニン";

  // --- 状態（選択・回数） ---
  final Map<String, int> _symptomCounts = {}; 
  final Set<String> _selectedTriggers = {};
  final Set<String> _selectedSleep = {};
  int _relieverCount = 0;
  int _relieverStock = 60;
  int _pillCount = 0;

  // 設定画面からデータを引き継ぐ
  Future<void> _openRegistrationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainUIRegistrationPage(
          symptoms: _mySymptoms,
          triggers: _myTriggers,
          reliever: _relieverName,
          pill: _pillName,
        ),
      ),
    );

    if (result != null) {
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
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 日時表示
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now()), 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),

            _buildSectionTitle('3. ピークフローの記録'),
            _buildPeakFlowPicker(),
            const Divider(),

            _buildSectionTitle('4. 症状の記録 (タップで強度変更)'),
            _buildSymptomGrid(), // ← 修正ポイント：常時表示
            const Divider(),

            _buildSectionTitle('5. 睡眠'),
            _buildWrapChips(['就寝', '起床', '中途覚醒'], _selectedSleep, Colors.blue),
            const Divider(),

            _buildSectionTitle('6. トリガーの記録'),
            _buildWrapChips(_myTriggers, _selectedTriggers, Colors.green), // ← 修正ポイント：常時表示
            const Divider(),

            _buildSectionTitle('7&8. 緊急時の記録'),
            _buildEmergencySection(),
            const Divider(),

            _buildSectionTitle('9. 自由メモ'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(maxLength: 50, decoration: InputDecoration(border: OutlineInputBorder(), hintText: '50文字程度')),
            ),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- UI部品 ---

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.lightBlue),
            child: Text('アスマネ', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _drawerTile(Icons.bar_chart, "週のデータとグラフ", const WeeklyGraphPage()),
          _drawerTile(Icons.calendar_view_month, "4週間のデータ(ACT)", const MonthlyGraphPage()),
          _drawerTile(Icons.timeline, "年間のデータとグラフ", const YearlyGraphPage()),
          _drawerTile(Icons.phone_in_talk, "ワンタップ受診", const OneTapCallPage()),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("メインUI登録ページ"),
            onTap: () {
              Navigator.pop(context);
              _openRegistrationPage();
            },
          ),
          _drawerTile(Icons.person, "アカウントページ", const AccountPage()),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildPeakFlowPicker() {
    return SizedBox(height: 100, child: CupertinoPicker(itemExtent: 40, scrollController: FixedExtentScrollController(initialItem: (_currentPeakFlow - 100) ~/ 10), onSelectedItemChanged: (i) => setState(() => _currentPeakFlow = 100 + (i * 10)), children: List.generate(71, (i) => Center(child: Text('${100 + (i * 10)} L/min')))));
  }

  // 症状セクション（最初から並んでいる状態）
  Widget _buildSymptomGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _mySymptoms.map((s) {
          int count = _symptomCounts[s] ?? 0;
          Color bgColor = Colors.grey[200]!;
          if (count == 1) bgColor = Colors.orange[100]!;
          if (count == 2) bgColor = Colors.orange[300]!;
          if (count == 3) bgColor = Colors.red[400]!;
          return GestureDetector(
            onTap: () => setState(() => _symptomCounts[s] = (count + 1) % 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: count > 0 ? Colors.orange : Colors.grey.shade400),
              ),
              child: Text(
                count > 0 ? "$s(${['','軽','中','重'][count]})" : s,
                style: TextStyle(fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal),
              ),
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
        runSpacing: 8,
        children: list.map((item) => FilterChip(
          label: Text(item),
          selected: selectionSet.contains(item),
          selectedColor: color.withValues(alpha: 0.3),
          onSelected: (val) => setState(() => val ? selectionSet.add(item) : selectionSet.remove(item)),
        )).toList(),
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _emergencyButton(_relieverName, _relieverCount, Colors.red, () => setState(() { 
        _relieverCount = (_relieverCount + 1) % 5; 
        if (_relieverCount != 0 && _relieverStock > 0) _relieverStock--; 
      }), "残量: $_relieverStock"),
      _emergencyButton(_pillName, _pillCount, Colors.purple, () => setState(() => _pillCount = (_pillCount + 1) % 3), ""),
    ]);
  }

  Widget _emergencyButton(String name, int count, Color color, VoidCallback onTap, String sub) {
    return Column(children: [
      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 35,
          backgroundColor: color.withValues(alpha: count == 0 ? 0.1 : count * 0.25),
          child: Text(count == 0 ? "未" : "$count回", style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ),
      if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 11))
    ]);
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("登録しました"))),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text("この内容で登録する", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- 5. メインUI登録ページ ---
class MainUIRegistrationPage extends StatefulWidget {
  final List<String> symptoms;
  final List<String> triggers;
  final String reliever;
  final String pill;

  const MainUIRegistrationPage({super.key, required this.symptoms, required this.triggers, required this.reliever, required this.pill});

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

// --- スタブページ ---
class WeeklyGraphPage extends StatelessWidget {
  const WeeklyGraphPage({super.key});

  @override
  Widget build(BuildContext context) {
    // グラフに表示するサンプルの点（xが曜日、yがピークフロー値）
    final List<FlSpot> spots = [
      const FlSpot(0, 350), // 月曜
      const FlSpot(1, 380), // 火曜
      const FlSpot(2, 320), // 水曜
      const FlSpot(3, 400), // 木曜
      const FlSpot(4, 390), // 金曜
      const FlSpot(5, 420), // 土曜
      const FlSpot(6, 410), // 日曜
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("週のピークフローグラフ")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("1週間の推移", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 600,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true, // 線を滑らかにする
                      color: Colors.blue,
                      barWidth: 4,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("※現在はサンプルデータを表示しています"),
          ],
        ),
      ),
    );
  }
}

class MonthlyGraphPage extends StatelessWidget { const MonthlyGraphPage({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("4週間のデータ(ACT)")), body: const Center(child: Text("ACT自動計算ロジックをここに実装"))); } }
class YearlyGraphPage extends StatelessWidget { const YearlyGraphPage({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("年間のグラフ")), body: const Center(child: Text("年間の傾向をここに実装"))); } }
class OneTapCallPage extends StatelessWidget { const OneTapCallPage({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("ワンタップ受診")), body: const Center(child: Text("緊急連絡先ボタンをここに実装"))); } }
class AccountPage extends StatelessWidget { const AccountPage({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("アカウント")), body: const Center(child: Text("ユーザー情報をここに実装"))); } }