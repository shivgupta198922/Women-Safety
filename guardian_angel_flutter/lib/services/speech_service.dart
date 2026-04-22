import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart'; // Corrected import

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  Function(String)? onWordsRecognized;

  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;

  SpeechService({this.onWordsRecognized});

  Future<void> initSpeechState() async {
    // Request microphone permission
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      _speechEnabled = await _speechToText.initialize(
        onError: (errorNotification) {
          print('Speech recognition error: ${errorNotification.errorMsg}');
          _isListening = false;
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'notListening' && _speechEnabled) {
            // If it stops listening unexpectedly, try to restart
            if (_isListening) {
              _isListening = false; // Mark as not listening before restarting
              startListening();
            }
          }
        },
      );
    } else {
      print('Microphone permission denied.');
      _speechEnabled = false;
    }
  }

  void startListening() async {
    if (_speechEnabled && !_isListening) {
      _isListening = true;
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(minutes: 1), // Listen for a longer duration
        pauseFor: const Duration(seconds: 3), // Pause before stopping if no speech
        partialResults: false,
        localeId: 'en_US', // You can make this configurable
      );
    }
  }

  void stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      onWordsRecognized?.call(result.recognizedWords.toLowerCase());
      // Restart listening after a final result
      if (_isListening) { // Check if still intended to be listening
        _isListening = false; // Mark as not listening before restarting
        startListening();
      }
    }
  }
}