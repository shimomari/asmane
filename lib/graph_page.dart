import 'package:flutter/material.dart';
import 'health_data.dart'; // PEF記録や睡眠データの定義を読み込む

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
      appBar: AppBar(
        title: const Text('週間グラフ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ピークフロー推移',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // グラフ描画エリア
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: PefGraphPainter(
                    pefRecords: pefRecords,
                    minY: graphMinY, // main.dart等で定義されている最小値
                    maxY: graphMaxY, // main.dart等で定義されている最大値
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 凡例などの補助情報
            const Text('※ 青線：朝の測定 / 緑線：夜の測定', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// グラフを実際に描く専門のクラス
class PefGraphPainter extends CustomPainter {
  final List<PefRecord> pefRecords;
  final double minY;
  final double maxY;

  PefGraphPainter({
    required this.pefRecords,
    required this.minY,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pefRecords.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // ここに以前作成した「ドラムロール直接表示」や「グラフ曲線」の
    // 具体的な描画ロジックが安全に格納されます。
    // ファイルを分けたことで、ここの計算を修正しても他の画面を壊す心配がありません。
    
    // 簡易的な枠線描画（動作確認用）
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}