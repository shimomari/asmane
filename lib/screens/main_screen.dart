import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ui_config_provider.dart';
import 'ui_config_page.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _pefValue = 420;
  final Map<String, int> _symptomLevels = {};
  // 睡眠のボタン名。かすれ対策のため、はっきりした文字を使用
  final Map<String, bool> _sleepStates = {'就寝': false, '起床': false, '中途覚醒': false};
  final Set<String> _selectedTriggers = {};
  
  int _relieverCount = 0;
  int _pillCount = 0;
  int _relieverStock = 192; 
  final TextEditingController _memoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(uiConfigProvider);
    String now = DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());
    const primaryBlue = Color(0xFF0056D2);

    // 「夜間の目覚め」を除去した症状リスト
    final filteredSymptoms = config.symptoms.where((s) => s != '夜間の目覚め').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Asmane', style: TextStyle(fontWeight: FontWeight.w900, color: primaryBlue)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: primaryBlue),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: primaryBlue),
              child: Text('メニュー', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: primaryBlue),
              title: const Text('表示項目の編集'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UIConfigPage()));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(now, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 16),
            
            // 1. ピークフロー (青文字)
            _buildCard(
              title: 'ピークフロー値 (L/min)',
              child: Container(
                height: 80,
                // ignore: deprecated_member_use
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: _pefValue ~/ 10),
                  onSelectedItemChanged: (v) => setState(() => _pefValue = v * 10),
                  children: List.generate(81, (i) => Center(
                    child: Text('${i * 10}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryBlue)),
                  )),
                ),
              ),
            ),

            // 2. 症状の強さ (夜間の目覚めを削除)
            _buildCard(
              title: '症状の強さ',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredSymptoms.map((s) => _buildSymptomChip(
                  s, 
                  _symptomLevels[s] ?? 0, 
                  () => setState(() => _symptomLevels[s] = ((_symptomLevels[s] ?? 0) + 1) % 4),
                )).toList(),
              ),
            ),
            
            // 3. 要因・誘因
            _buildCard(
              title: '要因・誘因',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: config.triggers.map((t) => _buildToggleButton(
                  t, 
                  _selectedTriggers.contains(t), 
                  Colors.orange, 
                  () => setState(() => _selectedTriggers.contains(t) ? _selectedTriggers.remove(t) : _selectedTriggers.add(t)),
                )).toList(),
              ),
            ),

            // 4. 睡眠 (文字がはっきり見えるようにサイズと太さを調整)
            _buildCard(
              title: '睡眠',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _sleepStates.keys.map((k) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildSleepButton(k, _sleepStates[k]!, primaryBlue, () => setState(() => _sleepStates[k] = !_sleepStates[k]!)),
                )).toList(),
              ),
            ),

            // 5. 薬剤使用 (睡眠の下、メモの上に配置)
            _buildCard(
              title: '薬剤使用 (タップで追加)',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMedicineChip(
                    config.relieverName, 
                    '残: $_relieverStock', 
                    _relieverCount, 
                    4, 
                    primaryBlue, 
                    () => setState(() {
                      _relieverCount = (_relieverCount + 1) % 5;
                      if (_relieverCount > 0) _relieverStock--;
                    }),
                  ),
                  const SizedBox(width: 16),
                  _buildMedicineChip(
                    config.pillName, 
                    '頓服薬', 
                    _pillCount, 
                    2, 
                    Colors.purple, 
                    () => setState(() => _pillCount = (_pillCount + 1) % 3),
                  ),
                ],
              ),
            ),

            // 6. メモ
            _buildCard(
              title: 'メモ',
              child: TextField(
                controller: _memoController,
                decoration: const InputDecoration(border: InputBorder.none, hintText: '体調の変化など...'),
                maxLines: 2,
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('記録を保存しました')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: const Text('保存する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 共通UIパーツ ---

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          Center(child: child), 
        ],
      ),
    );
  }

  // 睡眠用の大きなボタン
  Widget _buildSleepButton(String label, bool active, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 50,
      width: 100, // かすれ対策：ボタンの幅をしっかり確保
      child: FilterChip(
        label: Center(child: Text(label)),
        selected: active,
        onSelected: (_) => onTap(),
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.black87, 
          fontWeight: FontWeight.w900, // 文字を太く
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMedicineChip(String name, String sub, int level, int max, Color base, VoidCallback onTap) {
    // ignore: deprecated_member_use
    final colors = [Colors.grey.shade100, base.withOpacity(0.3), base.withOpacity(0.6), base.withOpacity(0.8), base];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colors[level],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: level == 0 ? Colors.grey.shade300 : Colors.transparent),
        ),
        child: Column(
          children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: level > 1 ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(
              level == 0 ? sub : '$level回 ($sub)', 
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: level > 1 ? Colors.white : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomChip(String label, int level, VoidCallback onTap) {
    final colors = [Colors.grey.shade100, Colors.blue.shade100, Colors.blue.shade400, Colors.indigo.shade800];
    return ActionChip(
      label: Text(label),
      backgroundColor: colors[level],
      labelStyle: TextStyle(color: level > 1 ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
      onPressed: onTap,
    );
  }

  Widget _buildToggleButton(String label, bool active, Color color, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
    );
  }
}