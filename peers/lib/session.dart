import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _keyDisplayName = 'display_name';

  static Future<void> setDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplayName, name.trim());
  }

  static Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyDisplayName);
    if (name == null || name.trim().isEmpty) return null;
    return name.trim();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDisplayName);
  }
}
