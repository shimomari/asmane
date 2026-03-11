import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pefValue = 420;
  final Map<String, int> _symptomLevels = {'咳': 0, 'たん': 0, '喘鳴': 0, '息苦しさ': 0};
  final Map<String, bool> _sleepStates = {'就寝': false, '起床': false, '中途覚醒': false};
  final List<String> _allTriggers = ['埃', '低気圧', '疲れ', '煙草', '天候']; 
  final Set<String> _selectedTriggers = {};
  
  int _relieverCount = 0; 
  int _relieverStock = 192; 
  int _pillLevel = 0; 

  final TextEditingController _memoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String now = DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Asmane', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildDateTimeHeader(now),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildPeakFlowCard(),
                  _buildSymptomCard(),
                  _buildTriggerCard(),
                  
                  // 薬剤使用：コンパクトな横幅半分サイズ
                  _buildCard(
                    title: '薬剤使用 (タップで追加)',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ
                      children: [
                        SizedBox(
                          width: 140, // 横幅を限定
                          child: _buildMedicineChip(
                            name: 'メプチン',
                            subtitle: '残: $_relieverStock',
                            level: _relieverCount,
                            maxLevel: 4,
                            baseColor: Colors.blue,
                            onTap: () => setState(() {
                              _relieverCount = (_relieverCount + 1) % 5;
                              if (_relieverCount > 0) _relieverStock--;
                            }),
                          ),
                        ),
                        const SizedBox(width: 20), // ボタン間の隙間
                        SizedBox(
                          width: 140, // 横幅を限定
                          child: _buildMedicineChip(
                            name: 'プレドニン',
                            subtitle: '頓服薬',
                            level: _pillLevel,
                            maxLevel: 2,
                            baseColor: Colors.purple,
                            onTap: () => setState(() => _pillLevel = (_pillLevel + 1) % 3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildSleepCard(),
                  _buildMemoCard(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineChip({
    required String name, 
    required String subtitle, 
    required int level, 
    required int maxLevel,
    required Color baseColor, 
    required VoidCallback onTap
  }) {
    Color bgColor;
    Color textColor;

    if (level == 0) {
      bgColor = Colors.grey.shade100;
      textColor = Colors.black54;
    } else if (level >= maxLevel) {
      // プレドニン最大時は「くっきりした赤紫」
      bgColor = (name == 'プレドニン') ? const Color(0xFFD81B60) : const Color(0xFF3F51B5);
      textColor = Colors.white;
    } else {
      final List<double> opacities = [0.0, 0.15, 0.5, 0.85];
      bgColor = baseColor.withValues(alpha: opacities[level]);
      // 1-2回目は黒、3回目以上は白
      textColor = (level <= 2) ? Colors.black87 : Colors.white;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: level == 0 ? Colors.grey.shade300 : Colors.transparent),
        ),
        child: Column(
          children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
            const SizedBox(height: 4),
            Text(level == 0 ? subtitle : '$level回', 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.8))
            ),
            if (level > 0 && name == 'メプチン')
              Text('残$_relieverStock',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textColor)
              ),
          ],
        ),
      ),
    );
  }

  // --- その他のパーツは安定版を維持 ---
  Widget _buildSymptomCard() => _buildCard(title: '症状の強さ', child: Center(child: Wrap(spacing: 8, runSpacing: 8, children: _symptomLevels.keys.map((s) => _buildSymptomChip(label: s, level: _symptomLevels[s]!, onTap: () => setState(() => _symptomLevels[s] = (_symptomLevels[s]! + 1) % 4))).toList())));
  Widget _buildTriggerCard() => _buildCard(title: '要因・誘因', child: Center(child: Wrap(spacing: 8, runSpacing: 8, children: _allTriggers.map((t) => _buildToggleButton(label: t, isActive: _selectedTriggers.contains(t), activeColor: Colors.orange.shade400, onTap: () => setState(() => _selectedTriggers.contains(t) ? _selectedTriggers.remove(t) : _selectedTriggers.add(t)))).toList())));
  Widget _buildSleepCard() => _buildCard(title: '睡眠', child: Center(child: Wrap(spacing: 12, children: _sleepStates.keys.map((key) => _buildToggleButton(label: key, isActive: _sleepStates[key]!, activeColor: Colors.indigo.shade600, onTap: () => setState(() => _sleepStates[key] = !_sleepStates[key]!))).toList())));
  Widget _buildMemoCard() => _buildCard(title: '自由メモ', child: TextField(controller: _memoController, maxLength: 50, decoration: InputDecoration(hintText: '体調の変化など...', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), counterText: "")));
  Widget _buildSaveButton() => SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('記録を保存しました'))), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('記録を保存する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  Widget _buildPeakFlowCard() => _buildCard(title: 'ピークフロー値 (L/min)', child: Container(height: 80, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)), child: CupertinoPicker(itemExtent: 40, scrollController: FixedExtentScrollController(initialItem: _pefValue ~/ 10), onSelectedItemChanged: (v) => setState(() => _pefValue = v * 10), children: List.generate(81, (i) => Center(child: Text('${i * 10}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: (i * 10 == _pefValue) ? Colors.blue.shade700 : Colors.black12)))))));
  Widget _buildCard({required String title, required Widget child}) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blueGrey.shade300)), const SizedBox(height: 10), child]));
  Widget _buildSymptomChip({required String label, required int level, required VoidCallback onTap}) { final List<Color> bgColors = [Colors.grey.shade100, Colors.blue.shade100, Colors.blue.shade400, Colors.indigo.shade600]; final List<Color> textColors = [Colors.black54, Colors.blue.shade900, Colors.white, Colors.white]; return InkWell(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), constraints: const BoxConstraints(minWidth: 65), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), decoration: BoxDecoration(color: bgColors[level], borderRadius: BorderRadius.circular(10)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColors[level])))); }
  Widget _buildToggleButton({required String label, required bool isActive, required Color activeColor, required VoidCallback onTap}) => InkWell(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: isActive ? activeColor : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black54))));
  Widget _buildDateTimeHeader(String now) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.access_time, size: 14, color: Colors.blueGrey.shade300), const SizedBox(width: 6), Text(now, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 13))])));
}