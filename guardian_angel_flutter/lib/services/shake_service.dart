import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart'; // Corrected import

class ShakeService {
  StreamSubscription? _accelerometerSubscription;
  final double _shakeThreshold = 15.0; // Adjust as needed for sensitivity
  final int _shakeCountThreshold = 3; // Number of significant movements to count as a shake
  int _shakeCount = 0;
  DateTime? _lastShakeTime;
  final Duration _shakeDetectionWindow = const Duration(seconds: 2); // Time window to count shakes
  final Duration _cooldownDuration = const Duration(seconds: 5); // Cooldown to prevent false triggers
  DateTime? _lastTriggerTime;

  Function()? onShakeDetected;

  ShakeService({this.onShakeDetected});

  void startShakeDetection() {
    if (_accelerometerSubscription != null) return; // Already listening

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final double accelerationMagnitude = event.x * event.x + event.y * event.y + event.z * event.z;

      if (accelerationMagnitude > _shakeThreshold) {
        final now = DateTime.now();

        // Apply cooldown
        if (_lastTriggerTime != null && now.difference(_lastTriggerTime!) < _cooldownDuration) {
          return;
        }

        if (_lastShakeTime == null || now.difference(_lastShakeTime!) > const Duration(milliseconds: 500)) {
          _shakeCount++;
          _lastShakeTime = now;

          if (_shakeCount >= _shakeCountThreshold) {
            onShakeDetected?.call();
            _shakeCount = 0; // Reset count after detection
            _lastTriggerTime = now; // Set last trigger time for cooldown
          }
        }
      }
    });
  }

  void stopShakeDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _shakeCount = 0;
    _lastShakeTime = null;
  }
}