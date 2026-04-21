import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _rakshakMode = false;
  bool _notifications = true;

  ThemeMode get themeMode => _themeMode;
  bool get rakshakMode => _rakshakMode;
  bool get notifications => _notifications;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index];
    _rakshakMode = prefs.getBool('rakshakMode') ?? false;
    _notifications = prefs.getBool('notifications') ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> toggleRakshakMode() async {
    _rakshakMode = !_rakshakMode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('rakshakMode', _rakshakMode);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _notifications = value;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications', value);
    notifyListeners();
  }
}

