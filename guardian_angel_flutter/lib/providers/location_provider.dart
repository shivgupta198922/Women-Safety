import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian_angel_flutter/services/location_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/socket_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/api_service.dart'; // Corrected import

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  String? _errorMessage;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  String? get errorMessage => _errorMessage;

  Future<void> getCurrentLocation() async {
    _errorMessage = null;
    try {
      _currentPosition = await LocationService.getCurrentLocation();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void startLiveLocationSharing() {
    if (_isTracking) return;
    _isTracking = true;
    notifyListeners();

    LocationService.startLocationUpdates((position) async {
      _currentPosition = position;
      notifyListeners();

      // Emit to Socket.IO for real-time updates
      SocketService().emit('updateLocation', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': position.timestamp?.toIso8601String(),
      });

      // Also update backend via API for persistence/last known location
      try {
        await ApiService.post('/location/update', {
          'lat': position.latitude,
          'lng': position.longitude,
        });
      } catch (e) {
        print('Error updating location to backend: $e');
      }
    });
  }

  void stopLiveLocationSharing() {
    if (!_isTracking) return;
    _isTracking = false;
    notifyListeners();
    LocationService.stopLocationUpdates();
    // Optionally, send a "stopped sharing" event via Socket.IO
    SocketService().emit('stopLocationSharing', {
      'message': 'User stopped sharing location',
    });
  }

  @override
  void dispose() {
    LocationService.stopLocationUpdates();
    super.dispose();
  }
}