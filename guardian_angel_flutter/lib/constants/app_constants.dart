class AppConstants {
  // Replace with your actual backend URL
  static const String baseUrl = 'http://localhost:5000/api'; // Use your backend's IP or domain
  static const String socketUrl = 'http://localhost:5000'; // Use your backend's IP or domain

  // Emergency Contacts
  static const String policeNumber = '100';
  static const String womenHelpline = '1098'; // Example: India's Women Helpline
  static const String ambulanceNumber = '112';

  // App Info
  static const String appName = 'Guardian Angel';
  static const String appVersion = '2.0.0';

  // Storage Keys
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';

  // Default Settings
  static const int defaultSosCountdownSeconds = 5;
}