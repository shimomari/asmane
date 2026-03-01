import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'health_data.dart'; // さっき作った魔法のファイル
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

// --- 27行目から34行目の直前までをこれに差し替えてください ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// --- ここまで ---
class _MainScreenState extends State<MainScreen> {
  List<PefRecord> pefRecords = [];
  List<SleepSession> sleepSessions = [];
  SleepSession? activeSleepSession;
  // --- 管理データ ---
  int _currentPeakFlow = 400;
  List<String> _mySymptoms = ['咳', 'たん', '息苦しさ', '喘鳴'];
  Map<String, int> _symptomCounts = {'咳': 0, 'たん': 0, '息苦しさ': 0, '喘鳴': 0}; // ★この行を追加！
  List<String> _myTriggers = ['埃・ハウスダスト', '気圧変化', '風邪', '運動'];
  String _relieverName = "メプチン";
  String _pillName = "プレドニン";

  // --- 状態（選択・回数） ---
  
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
         _drawerTile(Icons.bar_chart, "週のデータとグラフ", WeeklyGraphPage(
          pefRecords: pefRecords,
          sleepSessions: sleepSessions,
        )),


          //_drawerTile(Icons.calendar_view_month, "4週間のデータ(ACT)", const MonthlyGraphPage()),
          //_drawerTile(Icons.timeline, "年間のデータとグラフ", const YearlyGraphPage()),
          //_drawerTile(Icons.phone_in_talk, "ワンタップ受診", const OneTapCallPage()),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("メインUI登録ページ"),
            onTap: () {
              Navigator.pop(context);
              _openRegistrationPage();
            },
          ),
         // _drawerTile(Icons.person, "アカウントページ", const AccountPage()),
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
    return SizedBox(
      height: 120,
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(
          initialItem: (_currentPeakFlow - 100) ~/ 10,
        ),
        onSelectedItemChanged: (i) => setState(() => _currentPeakFlow = 100 + (i * 10)),
        children: List.generate(71, (i) {
          return Center(
            child: Text(
              '${100 + (i * 10)} L/min',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 23, 226),
              ),
            ),
          );
        }),
      ),
    );
  }

 Widget _buildSymptomGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _symptomCounts.keys.map((s) {
          final count = _symptomCounts[s] ?? 0;
          
          // 強度によって色を分ける設定
          Color bgColor = Colors.transparent;
          Color borderColor = Colors.grey.shade400;
          if (count == 1) { bgColor = Colors.orange.shade100; borderColor = Colors.orange.shade200; } // 軽度：薄い
          if (count == 2) { bgColor = Colors.orange.shade400; borderColor = Colors.orange.shade600; } // 中度：オレンジ
          if (count == 3) { bgColor = Colors.orange.shade800; borderColor = Colors.orange.shade900; } // 重度：濃いオレンジ

          return GestureDetector(
            onTap: () => setState(() => _symptomCounts[s] = (count + 1) % 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                count > 0 ? "${['', '軽', '中', '重'][count]} : $s" : s,
                style: TextStyle(
                  fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                  color: count >= 2 ? Colors.white : Colors.black87, // 濃い色の時は文字を白くして見やすく
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  // ★ 101行目のエラーを消し、症状ボタンを復活させる重要なパーツです
  
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
        onSelected: (val) {
                setState(() {
                  if (val) {
                    selectionSet.add(item);
                    // ここから追加
                    if (item == '就寝') {
                      activeSleepSession = SleepSession(bedTime: DateTime.now());
                    } else if (item == '起床') {
                      if (activeSleepSession != null) {
                        sleepSessions.add(SleepSession(
                          bedTime: activeSleepSession!.bedTime,
                          wakeUpTime: DateTime.now(),
                        ));
                        activeSleepSession = null;
                      }
                    }
                    // ここまで
                  } else {
                    selectionSet.remove(item);
                  }
                });
              }, 
        )).toList(),
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _emergencyButton(_relieverName, _relieverCount, const Color.fromARGB(255, 9, 32, 240), () => setState(() { 
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
        onPressed: () {
          setState(() {
            // ★ピークフローをリストに保存
            pefRecords.insert(0, PefRecord(
              time: DateTime.now(),
              value: _currentPeakFlow.toDouble(),
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("登録しました")),
          );
        },
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
  // メイン画面から記録データを受け取るための「窓口」
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
                  // --- 睡眠セクションを背景に描画 ---
                  rangeAnnotations: RangeAnnotations(
                    verticalRangeAnnotations: sleepSessions.map((session) {
                      return VerticalRangeAnnotation(
                        // 開始（就寝）から終了（起床）までを薄いグレーで塗る
                        x1: session.bedTime.weekday.toDouble() - 1,
                        x2: (session.wakeUpTime ?? DateTime.now()).weekday.toDouble() - 1,
                        color: Colors.grey.withValues(alpha: 0.2),
                      );
                    }).toList(),
                  ),
                  // --- 目標値のライン ---
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 500, // ここは後で設定の自己ベスト値と連動
                        color: Colors.green.withOpacity(0.5),
                        strokeWidth: 3,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          labelResolver: (line) => '目標(500)',
                        ),
                      ),
                    ],
                  ),
                  // --- 実際のピークフローの線 ---
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
            const Text("※グレーの帯は睡眠時間（就寝〜起床）を示します", 
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}