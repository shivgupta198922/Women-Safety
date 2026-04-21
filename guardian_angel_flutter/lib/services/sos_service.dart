import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:torch_light/torch_light.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class SOSService {
  static final SOSService _instance = SOSService._internal();
  factory SOSService() => _instance;
  SOSService._internal();

  final FlutterTts tts = FlutterTts();
  Timer? _countdownTimer;
  bool _isListeningShake = false;
  bool _isListeningVoice = false;
  AccelerometerEvent? _lastAccelerometerEvent;

  Future<void> init() async {
    await tts.speak('Guardian Angel ready');
    accelerometerEvents.listen((AccelerometerEvent event) {
      _lastAccelerometerEvent = event;
    });
  }

  Future<void> startShakeSOS() async {
    _isListeningShake = true;
    await _playSiren();
  }

  Future<void> startVoiceSOS() async {
    _isListeningVoice = true;
    // Speech recognition stub
  }

  Future<void> triggerSOS({String type = 'manual'}) async {
    Position position = await Geolocator.getCurrentPosition();
    final data = {
      'type': type,
      'location': {'lat': position.latitude, 'lng': position.longitude},
      'message': 'Emergency! Help!',
    };
    await ApiService.post('/sos', data);
    SocketService.sosAlert(data);
    _startCountdown(10);
    _playSiren();
    _flashStrobe();
  }

  void _startCountdown(int seconds) {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick >= seconds) {
        timer.cancel();
        // Cancel window closed, confirm SOS
      }
    });
  }

  Future<void> _playSiren() async {
    TorchLight.enableTorch();
    await tts.speak('Emergency! SOS activated!');
  }

  void _flashStrobe() {
    // Flashlight strobe animation
  }

  void stopSOS() {
    _isListeningShake = false;
    _isListeningVoice = false;
    _countdownTimer?.cancel();
    TorchLight.disableTorch();
  }
}

