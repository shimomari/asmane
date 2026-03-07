//main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'health_data.dart';
import 'sub_screens.dart'; // グラフや設定画面をここから読み込む

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ==========================================
  // 1. 管理データ・状態 (State)
  // ==========================================
  int _currentPeakFlow = 400;
  List<String> _mySymptoms = ['咳', 'たん', '息苦しさ', '喘鳴'];
  List<String> _myTriggers = ['埃・ハウスダスト', '気圧変化', '風邪', '運動'];
  String _relieverName = "メプチン";
  String _pillName = "プレドニン";

  final Map<String, int> _symptomCounts = {}; 
  final Set<String> _selectedTriggers = {};
  final Set<String> _selectedSleep = {};
  int _relieverCount = 0;
  int _relieverStock = 60;
  int _pillCount = 0;
  SleepSession? activeSleepSession;

  // ==========================================
  // 2. ロジック（画面遷移など）
  // ==========================================
  
  // 設定画面（登録ページ）を開き、結果を受け取る
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

    // 設定画面からデータが戻ってきたら反映する
    if (result != null) {
      setState(() {
        _mySymptoms = result['symptoms'];
        _myTriggers = result['triggers'];
        _relieverName = result['reliever'];
        _pillName = result['pill'];
      });
    }
  }

  // ==========================================
  // 3. メインUI構成 (buildメソッド)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アスマネ')),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTimeHeader(),         // 日時表示
            const Divider(),
            
            _buildSectionTitle('3. ピークフローの記録'),
            _buildPeakFlowPicker(),     // 数値選択
            const Divider(),
            
            _buildSectionTitle('4. 症状の記録 (タップで強度変更)'),
            _buildSymptomGrid(),        // 症状ボタン群
            const Divider(),
            
            _buildSectionTitle('5. 睡眠'),
            _buildSleepChips(),         // 睡眠（就寝・起床）
            const Divider(),
            
            _buildSectionTitle('6. トリガーの記録'),
            _buildTriggerChips(),       // トリガー選択
            const Divider(),
            
            _buildSectionTitle('7&8. 緊急時の記録'),
            _buildEmergencySection(),   // 緊急ボタン
            const Divider(),
            
            _buildSectionTitle('9. 自由メモ'),
            _buildMemoField(),          // テキスト入力
            
            const SizedBox(height: 20),
            _buildSubmitButton(),       // 最終登録ボタン
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. 各セクションのUI部品
  // ==========================================

  // --- 共通: セクションタイトル ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft, 
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))
      ),
    );
  }

  // --- ヘッダー: 現在時刻 ---
  Widget _buildTimeHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now()), 
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
      ),
    );
  }

  // --- セクション3: ピークフローピッカー ---
  Widget _buildPeakFlowPicker() {
    return SizedBox(
      height: 100,
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: FixedExtentScrollController(initialItem: (_currentPeakFlow - 100) ~/ 10),
        onSelectedItemChanged: (i) => setState(() => _currentPeakFlow = 100 + (i * 10)),
        children: List.generate(71, (i) => Center(
          child: Text(
            '${100 + (i * 10)} L/min', 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)
          ),
        )),
      ),
    );
  }

  // --- セクション4: 症状グリッド ---
  Widget _buildSymptomGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10, runSpacing: 10,
        children: _mySymptoms.map((s) {
          int count = _symptomCounts[s] ?? 0;
          return GestureDetector(
            onTap: () => setState(() => _symptomCounts[s] = (count + 1) % 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: [Colors.grey[200]!, Colors.orange[100]!, Colors.orange[300]!, Colors.red[400]!][count],
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

  // --- セクション5&6: チップUI (睡眠・トリガー) ---
  Widget _buildSleepChips() => _buildWrapChips(['就寝', '起床', '中途覚醒'], _selectedSleep, Colors.blue, isSleep: true);
  Widget _buildTriggerChips() => _buildWrapChips(_myTriggers, _selectedTriggers, Colors.green);

  // --- セクション7&8: 緊急ボタン ---
  Widget _buildEmergencySection() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _emergencyButton(_relieverName, _relieverCount, Colors.blue, () => setState(() { 
        _relieverCount = (_relieverCount + 1) % 5; 
        if (_relieverCount != 0 && _relieverStock > 0) _relieverStock--; 
      }), "残量: $_relieverStock"),
      _emergencyButton(_pillName, _pillCount, Colors.purple, () => setState(() => _pillCount = (_pillCount + 1) % 3), ""),
    ]);
  }

  // --- セクション9: メモ入力 ---
  Widget _buildMemoField() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        maxLength: 50, 
        decoration: InputDecoration(border: OutlineInputBorder(), hintText: '50文字程度')
      ),
    );
  }

  // --- 登録ボタン ---
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            pefRecords.add(PefRecord(time: DateTime.now(), value: _currentPeakFlow.toDouble()));
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("登録しました")));
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

  // ==========================================
  // 5. 補助用UIメソッド (共通パーツ)
  // ==========================================
  
  // 汎用チップ作成
  Widget _buildWrapChips(List<String> list, Set<String> selectionSet, Color color, {bool isSleep = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: list.map((item) => FilterChip(
          label: Text(item),
          selected: selectionSet.contains(item),
          onSelected: (val) {
            setState(() {
              if (val) {
                selectionSet.add(item);
                if (isSleep && item == '就寝') activeSleepSession = SleepSession(bedTime: DateTime.now());
                if (isSleep && item == '起床' && activeSleepSession != null) {
                  sleepSessions.add(SleepSession(bedTime: activeSleepSession!.bedTime, wakeUpTime: DateTime.now()));
                  activeSleepSession = null;
                }
              } else {
                selectionSet.remove(item);
              }
            });
          }, 
        )).toList(),
      ),
    );
  }

// --- 段階的に色（Color）そのものを変化させる緊急ボタンUI ---
  Widget _emergencyButton(String name, int count, Color baseColor, VoidCallback onTap, String sub) {
    // 回数に応じた「具体的な色」の指定
    Color displayColor;
    
    if (count == 0) {
      displayColor = Colors.grey[100]!; // 未使用：薄いグレー
    } else if (count == 1) {
      displayColor = Colors.blue[100]!; // 1回：薄い水色
    } else if (count == 2) {
      displayColor = Colors.blue[400]!; // 2回：標準的な青
    } else if (count == 3) {
      displayColor = Colors.blue[800]!; // 3回：濃い青
    } else {
      displayColor = const Color(0xFF000080); // 4回以上：紺色 (Navy)
    }

    return Column(children: [
      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 35,
          backgroundColor: displayColor,
          child: Text(
            count == 0 ? "未使用" : "$count回", 
            style: TextStyle(
              // 2回目以降は白文字にしたほうが視認性が高まります
              color: count >= 2 ? Colors.white : Colors.black87,
              fontSize: 12, 
              fontWeight: FontWeight.bold
            )
          ),
        ),
      ),
      if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 11))
    ]);
  }



  // サイドメニュー (Drawer)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.lightBlue),
            child: Text('アスマネ', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("週のデータとグラフ"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => WeeklyGraphPage(pefRecords: pefRecords, sleepSessions: sleepSessions)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("メインUI登録ページ"),
            onTap: () {
              Navigator.pop(context);
              _openRegistrationPage();
            },
          ),
        ],
      ),
    );
  }
}