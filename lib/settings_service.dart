import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _minKey = 'graph_min_value';
  static const String _maxKey = 'graph_max_value';

  static Future<void> saveMin(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_minKey, value);
  }

  static Future<void> saveMax(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_maxKey, value);
  }

  static Future<double> loadMin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_minKey) ?? 200.0;
  }

  static Future<double> loadMax() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_maxKey) ?? 600.0;
  }
}