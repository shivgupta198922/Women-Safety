import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart'; // Corrected import
import 'package:permission_handler/permission_handler.dart'; // Corrected import
import 'dart:io';

class AudioRecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<bool> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (await _checkPermissions()) {
      try {
        if (await _audioRecorder.hasPermission()) {
          final directory = await getTemporaryDirectory();
          _currentRecordingPath = '${directory.path}/guardian_angel_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              numChannels: 1,
              sampleRate: 16000,
            ),
            path: _currentRecordingPath!,
          );
          _isRecording = true;
          print('Recording started: $_currentRecordingPath');
        }
      } catch (e) {
        print('Error starting recording: $e');
        _isRecording = false;
      }
    }
  }

  Future<String?> stopRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      _isRecording = false;
      print('Recording stopped. File: $_currentRecordingPath');
      return _currentRecordingPath;
    }
    return null;
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}
