import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../services/api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Corrected import
import '../services/location_service.dart';
import '../services/socket_service.dart';
import '../models/journey_model.dart';
import '../models/contact_model.dart'; // Corrected import

import 'package:guardian_angel_flutter/providers/settings_provider.dart'; // Corrected import
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class JourneyProvider with ChangeNotifier {
  JourneyModel? _currentJourney;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _checkInTimer;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  JourneyModel? get currentJourney => _currentJourney;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isJourneyActive => _currentJourney != null && _currentJourney!.isActive;

  JourneyProvider() {
    _initializeNotifications();
    _loadActiveJourney(); // Attempt to load any active journey on startup
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadActiveJourney() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/journey/active');
      final responseData = ApiService.handleResponse(response);
      if (responseData != null && responseData is Map<String, dynamic> && responseData.isNotEmpty) {
        _currentJourney = JourneyModel.fromJson(responseData);
        _startCheckInTimer(); // Restart timer if journey is active
      }
    } catch (e) {
      print('No active journey found or error loading: $e');
      _currentJourney = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startJourney({
    required List<ContactModel> watchers,
    LatLng? endLocation,
    int checkInIntervalMinutes = 15,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Position? startPosition = await LocationService.getCurrentLocation();
      if (startPosition == null) {
        throw Exception("Could not get current location to start journey.");
      }

      final response = await ApiService.post('/journey/start', {
        'watchers': watchers.map((c) => c.id).toList(),
        'startLocation': {'lat': startPosition.latitude, 'lng': startPosition.longitude},
        'endLocation': endLocation != null ? {'lat': endLocation.latitude, 'lng': endLocation.longitude} : null,
        'checkInIntervalMinutes': checkInIntervalMinutes,
      });
      _currentJourney = JourneyModel.fromJson(ApiService.handleResponse(response));
      LocationService.startLocationUpdates(_onLocationUpdate); // Start live location tracking
      _startCheckInTimer();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error starting journey: $_errorMessage');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onLocationUpdate(Position position) {
    // Update backend with current location (handled by LocationProvider already)
    // SocketService().emit('updateLocation', ...); // This is already done by LocationProvider
    // Here, you might want to update the journey's current location in the backend
    // or check if the user has arrived at the destination.
  }

  void _startCheckInTimer() {
    _checkInTimer?.cancel(); // Cancel any existing timer
    if (_currentJourney == null || !_currentJourney!.isActive) return;

    _checkInTimer = Timer.periodic(Duration(minutes: _currentJourney!.checkInIntervalMinutes), (timer) {
      _showCheckInNotification();
      _currentJourney!.nextCheckInTime = DateTime.now().add(Duration(minutes: _currentJourney!.checkInIntervalMinutes));
      notifyListeners();
    });
    _currentJourney!.nextCheckInTime = DateTime.now().add(Duration(minutes: _currentJourney!.checkInIntervalMinutes));
    notifyListeners();
  }

  Future<void> _showCheckInNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'check_in_channel',
      'Check-in Reminders',
      channelDescription: 'Reminders to check in during a safe journey.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Safe Journey Check-in',
      'Are you safe? Tap to confirm arrival or check in.',
      platformChannelSpecifics,
      payload: 'check_in_payload',
    );
  }

  Future<void> checkIn() async {
    if (_currentJourney == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('/journey/${_currentJourney!.id}/checkin', {});
      _currentJourney = JourneyModel.fromJson(ApiService.handleResponse(response));
      _startCheckInTimer(); // Reset timer
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error checking in: $_errorMessage');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> arrivedSafely() async {
    if (_currentJourney == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('/journey/${_currentJourney!.id}/arrived', {});
      _currentJourney = JourneyModel.fromJson(ApiService.handleResponse(response));
      _checkInTimer?.cancel();
      LocationService.stopLocationUpdates();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error marking arrival: $_errorMessage');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _checkInTimer?.cancel();
    LocationService.stopLocationUpdates();
    super.dispose();
  }
}