import 'package:flutter/material.dart';
import 'package:guardian_angel_flutter/services/ai_detection_service.dart'; // Corrected import

class AIDetectionProvider with ChangeNotifier {
  final AIDetectionService _aiDetectionService = AIDetectionService();
  bool _isDetecting = false;
  DangerType _lastDetectedDanger = DangerType.none;

  bool get isDetecting => _isDetecting;
  DangerType get lastDetectedDanger => _lastDetectedDanger;

  AIDetectionProvider() {
    _aiDetectionService.onDangerDetected = (type) {
      _lastDetectedDanger = type;
      notifyListeners();
      // Here you would typically integrate with SOSProvider or show a UI prompt
      print('AI Detection Provider: Danger detected: $type');
    };
  }

  void startDetection() {
    _aiDetectionService.startDetection();
    _isDetecting = true;
    notifyListeners();
  }

  void stopDetection() {
    _aiDetectionService.stopDetection();
    _isDetecting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _aiDetectionService.dispose();
    super.dispose();
  }
}