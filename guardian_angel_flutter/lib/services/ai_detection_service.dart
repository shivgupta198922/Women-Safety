import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart'; // Corrected import
import 'package:permission_handler/permission_handler.dart';

enum DangerType {
  scream,
  panicRunning,
  suddenFall,
  abnormalMovement,
  none,
}

class AIDetectionService {
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _audioStreamSubscription;
  final AudioRecorder _audioRecorder = AudioRecorder();

  // Accelerometer thresholds
  final double _fallThresholdLow = 0.5; // g (approx. freefall)
  final double _fallThresholdHigh = 2.5; // g (impact)
  final Duration _fallDetectionWindow = const Duration(milliseconds: 300); // Time between low and high acceleration
  DateTime? _lastLowAccelerationTime;

  final double _runningThreshold = 1.5; // g (sustained high acceleration)
  final double _abnormalMovementThreshold = 2.0; // g (any sudden, high movement)

  // Audio thresholds (simplified)
  final double _screamVolumeThreshold = -20.0; // dBFS (decibels relative to full scale)
  final Duration _screamDurationThreshold = const Duration(milliseconds: 500); // Sustained loud noise
  DateTime? _screamStartTime;

  // Cooldown to prevent rapid re-triggering of alerts
  final Duration _alertCooldown = const Duration(seconds: 10);
  DateTime? _lastAlertTime;

  Function(DangerType)? onDangerDetected;

  AIDetectionService({this.onDangerDetected});

  Future<void> initSensors() async {
    // Request permissions
    await Permission.microphone.request();
    await Permission.sensors.request(); // For accelerometer
  }

  void startDetection() {
    _startAccelerometerDetection();
    _startAudioDetection();
  }

  void stopDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _stopAudioDetection();
  }

  void _startAccelerometerDetection() {
    if (_accelerometerSubscription != null) return;

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final double accelerationMagnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      final now = DateTime.now();

      // Apply global cooldown
      if (_lastAlertTime != null && now.difference(_lastAlertTime!) < _alertCooldown) {
        return;
      }

      // 1. Detect Sudden Fall
      if (accelerationMagnitude < _fallThresholdLow) {
        _lastLowAccelerationTime = now;
      } else if (accelerationMagnitude > _fallThresholdHigh && _lastLowAccelerationTime != null) {
        if (now.difference(_lastLowAccelerationTime!) < _fallDetectionWindow) {
          _triggerDanger(DangerType.suddenFall);
          _lastLowAccelerationTime = null; // Reset
        }
      }

      // 2. Detect Panic Running (sustained high acceleration)
      // This is a simplified heuristic. A more robust solution would involve
      // analyzing patterns over time, step detection, etc.
      if (accelerationMagnitude > _runningThreshold) {
        // If high acceleration is sustained for a short period, it could be running
        // For simplicity, we'll just trigger on high magnitude for now.
        // A more advanced approach would track average magnitude over a window.
        // _triggerDanger(DangerType.panicRunning); // Too sensitive without more context
      }

      // 3. Detect Abnormal Movement (any sudden, high acceleration)
      if (accelerationMagnitude > _abnormalMovementThreshold) {
        _triggerDanger(DangerType.abnormalMovement);
      }
    });
  }

  Future<void> _startAudioDetection() async {
    if (!await Permission.microphone.isGranted) {
      print('Microphone permission not granted for audio detection.');
      return;
    }
    if (_audioStreamSubscription != null) return;

    try {
      if (!await _audioRecorder.isRecording()) { // Added await
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            numChannels: 1,
            sampleRate: 16000,
          ),
          path: '${(await getTemporaryDirectory()).path}/ai_audio_temp_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );
      }

      _audioStreamSubscription = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amplitude) {
        final now = DateTime.now();

        // Apply global cooldown
        if (_lastAlertTime != null && now.difference(_lastAlertTime!) < _alertCooldown) {
          return;
        }

        // 4. Detect Scream Sound (simplified: sudden loud noise)
        if (amplitude.current > _screamVolumeThreshold) {
          if (_screamStartTime == null) {
            _screamStartTime = now;
          } else if (now.difference(_screamStartTime!) > _screamDurationThreshold) {
            _triggerDanger(DangerType.scream);
            _screamStartTime = null; // Reset
          }
        } else {
          _screamStartTime = null; // Reset if sound drops below threshold
        }
      });
    } catch (e) {
      print('Error starting audio detection: $e');
    }
  }

  Future<void> _stopAudioDetection() async {
    _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }
  }

  void _triggerDanger(DangerType type) {
    final now = DateTime.now();
    if (_lastAlertTime == null || now.difference(_lastAlertTime!) >= _alertCooldown) {
      print('Danger Detected: $type');
      onDangerDetected?.call(type);
      _lastAlertTime = now; // Set cooldown
    }
  }

  Future<void> dispose() async {
    stopDetection();
    await _audioRecorder.dispose();
  }
}
