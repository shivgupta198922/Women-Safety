import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sos_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:guardian_angel_flutter/core/theme.dart'; // Corrected import
import 'package:guardian_angel_flutter/widgets/feature_card.dart'; // Corrected import
import 'package:url_launcher/url_launcher.dart';
import 'package:guardian_angel_flutter/utils/app_utils.dart'; // Corrected import
import 'package:animate_do/animate_do.dart';
import 'package:guardian_angel_flutter/services/shake_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/audio_recording_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/video_recording_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/ai_detection_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/services/speech_service.dart'; // Corrected import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ShakeService _shakeService;
  late SpeechService _speechService;
  late AudioRecordingService _audioRecordingService;
  late VideoRecordingService _videoRecordingService;
  late AIDetectionService _aiDetectionService;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
    _initializeVideoRecording();
    _initializeShakeDetection();
    _initializeAIDetection();
    _requestLocationPermission();
  }

  void _initializeShakeDetection() {
    _shakeService = ShakeService(onShakeDetected: _triggerShakeSos);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SettingsProvider>(); // Replaced Provider.of with context.read
      if (settingsProvider.enableShakeSos) {
        _shakeService.startShakeDetection();
      }
    });
  }

  void _initializeVideoRecording() {
    _videoRecordingService = VideoRecordingService();
    _videoRecordingService.initializeCamera(); // Initialize camera early
  }

  void _initializeAIDetection() {
    _aiDetectionService = AIDetectionService(onDangerDetected: _onAIDangerDetected);
    _aiDetectionService.initSensors().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        if (settingsProvider.enableAIDetection) {
          _aiDetectionService.startDetection();
        }
      });
    });
  }

  void _initializeSpeechRecognition() {
    _audioRecordingService = AudioRecordingService();
    _speechService = SpeechService(onWordsRecognized: _onSpeechWordsRecognized);
    _speechService.initSpeechState().then((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (settingsProvider.enableVoiceSos) {
        _speechService.startListening();
      }
    });
  }

  void _onSpeechWordsRecognized(String words) {
    print('Recognized words: $words');
    if (words.contains('help me') || words.contains('save me') || words.contains('emergency')) {
      _triggerVoiceSos();
    }
  }

  Future<void> _launchHelpline(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Could not launch $phoneNumber', isError: true);
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    final locationProvider = context.read<LocationProvider>(); // Replaced Provider.of with context.read
    try {
      await locationProvider.getCurrentLocation();
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  Future<void> _triggerSos({String type = "SOS_PANIC"}) async {
    // Vibrate phone
    HapticFeedback.heavyImpact();

    final settingsProvider = context.read<SettingsProvider>(); // Replaced Provider.of with context.read
    String? audioPath;
    String? videoPath;

    // Start audio recording
    if (settingsProvider.autoRecordAudioOnSos) {
      await _audioRecordingService.startRecording();
      audioPath = _audioRecordingService.currentRecordingPath;
    }
    // Start video recording
    if (settingsProvider.autoRecordVideoOnSos) {
      await _videoRecordingService.startVideoRecording();
      videoPath = _videoRecordingService.currentRecordingPath;
    }

    // Trigger SOS alert
    final sosProvider = context.read<SosProvider>(); // Replaced Provider.of with context.read
    try {
      await sosProvider.sendSos(
        type: type,
        audioRecordingUrl: audioPath,
        videoRecordingUrl: videoPath,
      );
      if (mounted) {
        AppUtils.showSnackBar(context, sosProvider.sosMessage ?? 'SOS sent!');
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

  void _triggerShakeSos() async {
    _showEmergencyPopup(title: 'Shake SOS Triggered!', message: 'Shake gesture detected. SOS sent and recording started.');
    await _triggerSos(type: "SHAKE_SOS");
  }

  void _triggerVoiceSos() async {
    _showEmergencyPopup(title: 'Voice SOS Triggered!', message: 'Voice command detected. SOS sent and recording started.');
    await _triggerSos(type: "VOICE_SOS");
  }

  void _onAIDangerDetected(DangerType type) async {
    print('AI Detected Danger: $type');
    final settingsProvider = context.read<SettingsProvider>(); // Replaced Provider.of with context.read

    if (settingsProvider.autoAlertAIDetection) {
      _showEmergencyPopup(title: 'AI Danger Detected!', message: 'Automatically sending SOS due to $type detection.');
      await _triggerSos(type: type.toString().split('.').last.toUpperCase());
    } else {
      _showEmergencyPopup(
        title: 'AI Danger Detected!',
        message: 'Potential danger ($type) detected. Do you want to send an SOS?',
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            Navigator.of(context).pop();
            await _triggerSos(type: type.toString().split('.').last.toUpperCase());
          }, child: const Text('Send SOS')),
        ],
      );
    }
  }

  void _showEmergencyPopup({String title = 'Emergency Alert!', String message = 'An emergency alert has been sent.', List<Widget>? actions}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: actions ?? <Widget>[TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settingsProvider = context.watch<SettingsProvider>(); // Replaced Provider.of with context.watch

    if (settingsProvider.enableShakeSos) {
      _shakeService.startShakeDetection();
    } else {
      _shakeService.stopShakeDetection();
    }

    if (settingsProvider.enableVoiceSos) {
      _speechService.startListening();
    } else {
      _speechService.stopListening();
    }

    if (settingsProvider.enableAIDetection) {
      _aiDetectionService.startDetection();
    } else {
      _aiDetectionService.stopDetection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: const Text(
            'Guardian Angel Premium',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
          FadeInRight(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await context.read<AuthProvider>().logout(); // Replaced Provider.of with context.read
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ],
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                FadeInLeft(
                  duration: const Duration(milliseconds: 700),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Text(
                        'Welcome, ${authProvider.user?.fullName.split(' ').first ?? 'User'}!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                FadeInLeft(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Your safety is our priority.',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    delay: const Duration(milliseconds: 200),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16, // Corrected to use FeatureCard
                      children: [
                        FeatureCard(
                          title: 'SOS Panic',
                          icon: Icons.sos,
                          onPressed: () {
                            Navigator.pushNamed(context, '/sos');
                          },
                          gradientStart: Colors.red.shade700,
                          gradientEnd: Colors.red.shade900,
                        ),
                        FeatureCard(
                          title: 'Fake Call',
                          icon: Icons.phone_callback,
                          onPressed: () {
                            Navigator.pushNamed(context, '/fake_call');
                          },
                        ),
                        FeatureCard(
                          title: 'Live Location',
                          icon: Icons.location_on,
                          onPressed: () {
                            Navigator.pushNamed(context, '/live_location');
                          },
                        ),
                        FeatureCard(
                          title: 'Emergency Contacts',
                          icon: Icons.people,
                          onPressed: () {
                            Navigator.pushNamed(context, '/contacts');
                          },
                        ),
                        FeatureCard(
                          title: 'Women Helpline',
                          icon: Icons.call,
                          onPressed: () {
                            Navigator.pushNamed(context, '/women_helpline');
                          },
                          gradientStart: Colors.purple.shade700,
                          gradientEnd: Colors.purple.shade900,
                        ),
                        FeatureCard(
                          title: 'Nearby Police',
                          icon: Icons.local_police,
                          onPressed: () {
                            Navigator.pushNamed(context, '/nearby_police');
                          },
                        ),
                        FeatureCard(
                          title: 'Safety Tips',
                          icon: Icons.lightbulb_outline,
                          onPressed: () {
                            Navigator.pushNamed(context, '/safety_tips');
                          },
                        ),
                        FeatureCard(
                          title: 'Safe Journey',
                          icon: Icons.alt_route,
                          onPressed: () {
                            Navigator.pushNamed(context, '/safe_journey');
                          },
                        ),
                        FeatureCard(
                          title: 'Profile',
                          icon: Icons.person,
                          onPressed: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shakeService.stopShakeDetection();
    _speechService.stopListening();
    _videoRecordingService.dispose();
    _audioRecordingService.dispose();
    _aiDetectionService.dispose();
    super.dispose();
  }
}