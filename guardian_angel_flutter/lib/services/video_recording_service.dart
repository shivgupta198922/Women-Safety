import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart'; // Corrected import
import 'package:permission_handler/permission_handler.dart'; // Corrected import
import 'dart:io'; // Corrected import

class VideoRecordingService {
  CameraController? _cameraController;
  String? _currentRecordingPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<void> initializeCamera() async {
    // Request camera permission
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras found.');
        return;
      }
      // Prefer back camera for less intrusive recording
      final CameraDescription backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.low, // Low resolution for less storage/processing
        enableAudio: true, // Record audio with video
      );

      try {
        await _cameraController!.initialize();
        print('Camera initialized.');
      } catch (e) {
        print('Error initializing camera: $e');
        _cameraController = null;
      }
    } else {
      print('Camera permission denied.');
    }
  }

  Future<void> startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await initializeCamera(); // Try to initialize if not already
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        print('Camera not initialized, cannot start video recording.');
        return;
      }
    }

    if (_isRecording) return;

    try {
      final directory = await getTemporaryDirectory();
      _currentRecordingPath = '${directory.path}/guardian_angel_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _cameraController!.startVideoRecording();
      _isRecording = true;
      print('Video recording started: $_currentRecordingPath');
    } catch (e) {
      print('Error starting video recording: $e');
      _isRecording = false;
    }
  }

  Future<String?> stopVideoRecording() async {
    if (!_isRecording || _cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      final XFile file = await _cameraController!.stopVideoRecording();
      _isRecording = false;
      print('Video recording stopped. File: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error stopping video recording: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<void> dispose() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }
}