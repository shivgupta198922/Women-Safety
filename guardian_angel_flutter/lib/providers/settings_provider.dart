import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Corrected import
import 'package:guardian_angel_flutter/providers/auth_provider.dart'; // Corrected import

class SettingsProvider with ChangeNotifier {
  // Example settings, these would ideally be fetched from/synced with backend User settings
  bool _rakshakMode = false;
  bool _notifications = true;
  bool _enableShakeSos = true;
  bool _enableVoiceSos = false; // New setting for Voice SOS
  ThemeMode _themeMode = ThemeMode.system; // This should ideally be managed by ThemeProvider
  bool _enableAIDetection = false; // New setting for AI Danger Detection
  bool _autoAlertAIDetection = false; // New setting for auto-alert on AI detection
  double _screamDetectionThreshold = -20.0; // Example threshold
  double _fallDetectionSensitivity = 1.0; // Example sensitivity
  int _defaultCheckInIntervalMinutes = 15; // New setting for default check-in interval

  bool get rakshakMode => _rakshakMode;
  bool get notifications => _notifications;
  ThemeMode get themeMode => _themeMode;
  bool get enableShakeSos => _enableShakeSos;
  bool get enableVoiceSos => _enableVoiceSos;
  bool get enableAIDetection => _enableAIDetection;
  bool get autoAlertAIDetection => _autoAlertAIDetection;
  double get screamDetectionThreshold => _screamDetectionThreshold;
  double get fallDetectionSensitivity => _fallDetectionSensitivity;
  int get defaultCheckInIntervalMinutes => _defaultCheckInIntervalMinutes;

  // SOS specific settings from User model
  int get sosCountdownSeconds => _authProvider?.user?.settings['sosPreferences']?['countdownSeconds'] ?? 5;
  bool get autoRecordAudioOnSos => _authProvider?.user?.settings['sosPreferences']?['autoRecordAudio'] ?? true;
  bool get autoRecordVideoOnSos => _authProvider?.user?.settings['sosPreferences']?['autoRecordVideo'] ?? false; // New getter

  AuthProvider? _authProvider;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
    // When AuthProvider updates, reload settings that depend on user data
    _loadSettings();
  }

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _rakshakMode = prefs.getBool('rakshakMode') ?? false;
    _notifications = prefs.getBool('notifications') ?? true;
    _enableShakeSos = prefs.getBool('enableShakeSos') ?? true; // Load Shake SOS setting
    _enableVoiceSos = prefs.getBool('enableVoiceSos') ?? false; // Load Voice SOS setting
    _enableAIDetection = prefs.getBool('enableAIDetection') ?? false;
    _autoAlertAIDetection = prefs.getBool('autoAlertAIDetection') ?? false;
    _defaultCheckInIntervalMinutes = prefs.getInt('defaultCheckInIntervalMinutes') ?? 15;
    // autoRecordAudioOnSos and autoRecordVideoOnSos are read directly from AuthProvider.user.settings
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  void toggleRakshakMode(bool newValue) async {
    _rakshakMode = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rakshakMode', newValue);
    notifyListeners();
    // TODO: Implement backend call to update user settings
  }

  void setNotifications(bool newValue) async {
    _notifications = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', newValue);
    notifyListeners();
    // TODO: Implement backend call to update user settings
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
    // TODO: Implement backend call to update user settings
  }

  void setEnableShakeSos(bool newValue) async {
    _enableShakeSos = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableShakeSos', newValue);
    notifyListeners();
    // TODO: Implement backend call to update user settings
  }

  void setEnableVoiceSos(bool newValue) async {
    _enableVoiceSos = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableVoiceSos', newValue);
    notifyListeners();
  }

  // Methods to update auto-recording settings (will update backend in future phase)
  void setAutoRecordAudioOnSos(bool newValue) {
    // This would ideally update the backend user settings
    // For now, it's a local state change reflecting the UI toggle
    // _authProvider?.user?.settings['sosPreferences']['autoRecordAudio'] = newValue; // This is immutable
    // You'd need a way to update the UserModel and notify AuthProvider
    notifyListeners();
  }

  void setAutoRecordVideoOnSos(bool newValue) {
    // This would ideally update the backend user settings
    // For now, it's a local state change reflecting the UI toggle
    // _authProvider?.user?.settings['sosPreferences']['autoRecordVideo'] = newValue; // This is immutable
    notifyListeners();
  }

  void setEnableAIDetection(bool newValue) async {
    _enableAIDetection = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableAIDetection', newValue);
    notifyListeners();
    // TODO: Update backend user settings
  }

  void setAutoAlertAIDetection(bool newValue) async {
    _autoAlertAIDetection = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoAlertAIDetection', newValue);
    notifyListeners();
    // TODO: Update backend user settings
  }

  void setDefaultCheckInIntervalMinutes(int newValue) async {
    _defaultCheckInIntervalMinutes = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultCheckInIntervalMinutes', newValue);
    notifyListeners();
  }
}