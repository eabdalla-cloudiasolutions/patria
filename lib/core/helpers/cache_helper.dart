// lib/core/helpers/cache_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences _prefs;

  // Call this once in main() before runApp()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Keys ───────────────────────────────────────────
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _onboardingKey = 'onboarding_done';

  // ─── Token ──────────────────────────────────────────
  static Future<void> saveToken(String token) =>
      _prefs.setString(_tokenKey, token);

  static String? getToken() => _prefs.getString(_tokenKey);

  static bool get hasToken {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // ─── User ────────────────────────────────────────────
  static Future<void> saveUserId(String id) => _prefs.setString(_userIdKey, id);

  static String? getUserId() => _prefs.getString(_userIdKey);

  // ─── Onboarding ──────────────────────────────────────
  static Future<void> setOnboardingDone() =>
      _prefs.setBool(_onboardingKey, true);

  static bool get isOnboardingDone => _prefs.getBool(_onboardingKey) ?? false;

  // ─── Logout / Clear ──────────────────────────────────
  static Future<void> clearAll() => _prefs.clear();

  static Future<void> clearToken() => _prefs.remove(_tokenKey);
}
