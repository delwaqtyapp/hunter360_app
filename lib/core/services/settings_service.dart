import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyDarkMode = 'settings_dark_mode';
  static const _keyLanguage = 'settings_language';
  static const _keyServerUrl = 'settings_server_url';
  static const _keyAutoLogout = 'settings_auto_logout_minutes';
  static const _keyNotifications = 'settings_notifications_enabled';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'en';
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, code);
  }

  Future<String> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyServerUrl) ?? 'http://10.10.8.60:49110';
  }

  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerUrl, url);
  }

  Future<int> getAutoLogoutMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAutoLogout) ?? 0;
  }

  Future<void> setAutoLogoutMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAutoLogout, minutes);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifications) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }

  Future<Map<String, dynamic>> exportAll() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'darkMode': prefs.getBool(_keyDarkMode) ?? false,
      'language': prefs.getString(_keyLanguage) ?? 'en',
      'serverUrl': prefs.getString(_keyServerUrl) ?? 'http://10.10.8.60:49110',
      'autoLogoutMinutes': prefs.getInt(_keyAutoLogout) ?? 0,
      'notificationsEnabled': prefs.getBool(_keyNotifications) ?? true,
    };
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDarkMode);
    await prefs.remove(_keyLanguage);
    await prefs.remove(_keyServerUrl);
    await prefs.remove(_keyAutoLogout);
    await prefs.remove(_keyNotifications);
  }
}
