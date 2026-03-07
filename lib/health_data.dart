//health_data.dart
//ピークフローの記録用データ
class PefRecord {
  final DateTime time; // 記録した日時
  final double value;  // 数値

  PefRecord({required this.time, required this.value});
}

/// 睡眠区間の記録用データ
class SleepSession {
  final DateTime bedTime;    // 就寝ボタンを押した時間
  final DateTime? wakeUpTime; // 起床ボタンを押した時間（まだならnull）

  SleepSession({required this.bedTime, this.wakeUpTime});
}

// データの保存場所
List<PefRecord> pefRecords = [];
List<SleepSession> sleepSessions = [];


// health_data.dart の一番下に追加
double graphMinY = 200.0; // グラフの底を200にする
double graphMaxY = 600.0; // グラフの天井を600にする