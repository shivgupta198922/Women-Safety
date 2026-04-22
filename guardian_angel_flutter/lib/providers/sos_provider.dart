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
        'type': type,
        'location': locationData,
        'message': message,
        if (audioRecordingUrl != null) 'audioRecordingUrl': audioRecordingUrl,
        if (videoRecordingUrl != null) 'videoRecordingUrl': videoRecordingUrl,
        // You might want to include user ID here if not handled by backend auth
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