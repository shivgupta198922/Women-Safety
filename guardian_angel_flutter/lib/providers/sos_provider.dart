import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:guardian_angel_flutter/services/api_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/location_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/socket_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/models/contact_model.dart'; // Corrected import

class SosProvider with ChangeNotifier {
  bool _isSendingSos = false;
  String? _sosMessage;

  bool get isSendingSos => _isSendingSos;
  String? get sosMessage => _sosMessage;

  Future<Map<String, dynamic>> _loadCurrentUserProfile() async {
    final response = await ApiService.get('/auth/me');
    return Map<String, dynamic>.from(ApiService.handleResponse(response) as Map<String, dynamic>);
  }

  Future<void> sendSos({String message = "I need help! Please track my location.", String type = "SOS_PANIC", String? audioRecordingUrl, String? videoRecordingUrl}) async {
    _isSendingSos = true;
    _sosMessage = null;
    notifyListeners();

    try {
      Position? position = await LocationService.getCurrentLocation();

      if (position == null) {
        throw Exception("Could not get current location for SOS.");
      }

      final locationData = {
        'lat': position.latitude,
        'lng': position.longitude,
        'timestamp': position.timestamp?.toIso8601String(),
      };
      final currentUser = await _loadCurrentUserProfile();
      final userId = (currentUser['_id'] ?? '').toString();
      final senderName = (currentUser['fullName'] ?? 'A user').toString();

      // 1. Send to backend API (for logging, potential SMS/Email integration)
      await ApiService.post('/sos/send', {
        'type': type,
        'location': locationData,
        'message': message,
        if (audioRecordingUrl != null) 'audioRecordingUrl': audioRecordingUrl,
        if (videoRecordingUrl != null) 'videoRecordingUrl': videoRecordingUrl,
      });

      // 2. Emit via Socket.IO for real-time alerts to connected clients
      SocketService().emit('sendSOS', {
        'userId': userId,
        'senderName': senderName,
        'type': type,
        'location': locationData,
        'message': message,
        if (audioRecordingUrl != null) 'audioRecordingUrl': audioRecordingUrl,
        if (videoRecordingUrl != null) 'videoRecordingUrl': videoRecordingUrl,
      });

      _sosMessage = "SOS sent successfully! Emergency contacts have been notified.";
    } catch (e) {
      _sosMessage = "Failed to send SOS: $e";
      print('SOS Error: $e');
      rethrow;
    } finally {
      _isSendingSos = false;
      notifyListeners();
    }
  }
}
