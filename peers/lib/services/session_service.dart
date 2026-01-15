import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyDisplayName = 'display_name';
  static const _keyUserId = 'user_id';

  Future<void> setDisplayName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyDisplayName, name.trim());
  }

  Future<String?> getDisplayName() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_keyDisplayName);
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  Future<void> setUserId(String uid) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyUserId, uid);
  }

  Future<String?> getUserId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyUserId);
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyDisplayName);
    await p.remove(_keyUserId);
  }
}

