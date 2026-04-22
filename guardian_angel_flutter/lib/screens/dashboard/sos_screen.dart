import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/sos_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:guardian_angel_flutter/utils/app_utils.dart'; // Corrected import
import 'package:guardian_angel_flutter/core/theme.dart' hide GlassCard; // Corrected import
import 'package:guardian_angel_flutter/widgets/glass_card.dart'; // Corrected import
import 'package:guardian_angel_flutter/widgets/custom_button.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/audio_recording_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/video_recording_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/constants/app_constants.dart'; // Corrected import

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  Timer? _countdownTimer;
  int _countdownSeconds = AppConstants.defaultSosCountdownSeconds; // Use default from AppConstants
  bool _isCountdownActive = false;
  late AudioRecordingService _audioRecordingService;
  late VideoRecordingService _videoRecordingService;

  @override
  void initState() {
    super.initState();
    _audioRecordingService = AudioRecordingService();
    _videoRecordingService = VideoRecordingService();
    // Initialize countdown from settings if available
    _countdownSeconds = context.read<SettingsProvider>().sosCountdownSeconds; // Replaced Provider.of with context.read
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioRecordingService.dispose();
    _videoRecordingService.dispose();
    super.dispose();
  }

  void _startSosCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdownSeconds = context.read<SettingsProvider>().sosCountdownSeconds; // Replaced Provider.of with context.read
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdownSeconds == 0) {
        timer.cancel();
        await _triggerSos();
        setState(() {
          _isCountdownActive = false;
        });
      } else {
        setState(() {
          _countdownSeconds--;
        });
      }
    });
  }

  Future<void> _triggerSos() async {
    // Vibrate phone immediately
    HapticFeedback.heavyImpact();

    // Start audio/video recording if enabled in settings
    final settingsProvider = context.read<SettingsProvider>(); // Replaced Provider.of with context.read
    String? audioPath;
    String? videoPath;

    if (settingsProvider.autoRecordAudioOnSos) {
      await _audioRecordingService.startRecording();
      audioPath = _audioRecordingService.currentRecordingPath;
    }
    if (settingsProvider.autoRecordVideoOnSos) {
      await _videoRecordingService.startVideoRecording();
      videoPath = _videoRecordingService.currentRecordingPath;
    }

    // Trigger SOS alert
    final sosProvider = context.read<SosProvider>(); // Replaced Provider.of with context.read
    try {
      await sosProvider.sendSos(
        type: "SOS_PANIC",
        audioRecordingUrl: audioPath,
        videoRecordingUrl: videoPath,
      );
      if (mounted) {
        AppUtils.showSnackBar(context, sosProvider.sosMessage ?? 'SOS sent!');
        Navigator.pop(context); // Go back after sending SOS
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, sosProvider.sosMessage ?? 'Failed to send SOS.', isError: true);
      }
    } finally {
      // Stop recording after SOS is sent or failed
      if (_audioRecordingService.isRecording) await _audioRecordingService.stopRecording();
      if (_videoRecordingService.isRecording) await _videoRecordingService.stopVideoRecording();
    }
  }

  void _cancelSos() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountdownActive = false;
      _countdownSeconds = context.read<SettingsProvider>().sosCountdownSeconds; // Replaced Provider.of with context.read
    });
    AppUtils.showSnackBar(context, 'SOS cancelled.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Emergency'),
        backgroundColor: isDark ? GuardianTheme.darkGradientStart : GuardianTheme.primaryGradientStart,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [GuardianTheme.darkGradientStart, GuardianTheme.darkGradientEnd]
                : [GuardianTheme.primaryGradientStart, GuardianTheme.primaryGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Consumer<SosProvider>(
              builder: (context, sosProvider, child) {
                return GlassCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 100,
                        color: Colors.redAccent.shade100,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'SOS Alert',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Press the button below to send an immediate emergency alert to your trusted contacts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      if (_isCountdownActive)
                        Text(
                          'Sending in $_countdownSeconds...',
                          style: const TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 16), // Corrected to use CustomButton
                      CustomButton(
                        text: _isCountdownActive
                            ? 'CANCEL SOS'
                            : (sosProvider.isSendingSos ? 'SENDING...' : 'SEND SOS NOW'),
                        onPressed: _isCountdownActive
                            ? _cancelSos
                            : (sosProvider.isSendingSos
                            ? null
                            : _startSosCountdown),
                        backgroundColor: _isCountdownActive ? Colors.orange.shade700 : Colors.red.shade700,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _isCountdownActive ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
