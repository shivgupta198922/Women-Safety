import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_angel_flutter/core/app_features.dart';
import 'package:guardian_angel_flutter/core/feature_art.dart';
import 'package:guardian_angel_flutter/core/theme.dart';
import 'package:guardian_angel_flutter/services/ai_detection_service.dart';
import 'package:guardian_angel_flutter/services/audio_recording_service.dart';
import 'package:guardian_angel_flutter/services/shake_service.dart';
import 'package:guardian_angel_flutter/services/speech_service.dart';
import 'package:guardian_angel_flutter/services/video_recording_service.dart';
import 'package:guardian_angel_flutter/utils/app_utils.dart';
import 'package:guardian_angel_flutter/widgets/feature_card.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sos_provider.dart';
import 'feature_detail_screen.dart';

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

  void _openFeature(AppFeature feature) {
    if (feature.routeName != null) {
      Navigator.pushNamed(context, feature.routeName!);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeatureDetailScreen(feature: feature),
      ),
    );
  }

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
      final settingsProvider = context.read<SettingsProvider>();
      if (settingsProvider.enableShakeSos) {
        _shakeService.startShakeDetection();
      }
    });
  }

  void _initializeVideoRecording() {
    _videoRecordingService = VideoRecordingService();
    _videoRecordingService.initializeCamera();
  }

  void _initializeAIDetection() {
    _aiDetectionService = AIDetectionService(onDangerDetected: _onAIDangerDetected);
    _aiDetectionService.initSensors().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider = context.read<SettingsProvider>();
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
      final settingsProvider = context.read<SettingsProvider>();
      if (settingsProvider.enableVoiceSos) {
        _speechService.startListening();
      }
    });
  }

  void _onSpeechWordsRecognized(String words) {
    if (words.contains('help me') || words.contains('save me') || words.contains('emergency')) {
      _triggerVoiceSos();
    }
  }

  Future<void> _requestLocationPermission() async {
    final locationProvider = context.read<LocationProvider>();
    try {
      await locationProvider.getCurrentLocation();
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  Future<void> _triggerSos({String type = 'SOS_PANIC'}) async {
    HapticFeedback.heavyImpact();

    final settingsProvider = context.read<SettingsProvider>();
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

    final sosProvider = context.read<SosProvider>();
    try {
      await sosProvider.sendSos(
        type: type,
        audioRecordingUrl: audioPath,
        videoRecordingUrl: videoPath,
      );
      if (mounted) {
        AppUtils.showSnackBar(context, sosProvider.sosMessage ?? 'SOS sent!');
      }
    } catch (_) {
      if (mounted) {
        AppUtils.showSnackBar(context, sosProvider.sosMessage ?? 'Failed to send SOS.', isError: true);
      }
    } finally {
      if (_audioRecordingService.isRecording) {
        await _audioRecordingService.stopRecording();
      }
      if (_videoRecordingService.isRecording) {
        await _videoRecordingService.stopVideoRecording();
      }
    }
  }

  void _triggerShakeSos() async {
    _showEmergencyPopup(
      title: 'Shake SOS Triggered!',
      message: 'Shake gesture detected. SOS sent and recording started.',
    );
    await _triggerSos(type: 'SHAKE_SOS');
  }

  void _triggerVoiceSos() async {
    _showEmergencyPopup(
      title: 'Voice SOS Triggered!',
      message: 'Voice command detected. SOS sent and recording started.',
    );
    await _triggerSos(type: 'VOICE_SOS');
  }

  void _onAIDangerDetected(DangerType type) async {
    final settingsProvider = context.read<SettingsProvider>();

    if (settingsProvider.autoAlertAIDetection) {
      _showEmergencyPopup(
        title: 'AI Danger Detected!',
        message: 'Automatically sending SOS due to $type detection.',
      );
      await _triggerSos(type: type.toString().split('.').last.toUpperCase());
    } else {
      _showEmergencyPopup(
        title: 'AI Danger Detected!',
        message: 'Potential danger ($type) detected. Do you want to send an SOS?',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _triggerSos(type: type.toString().split('.').last.toUpperCase());
            },
            child: const Text('Send SOS'),
          ),
        ],
      );
    }
  }

  void _showEmergencyPopup({
    String title = 'Emergency Alert!',
    String message = 'An emergency alert has been sent.',
    List<Widget>? actions,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: actions ??
              <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settingsProvider = context.watch<SettingsProvider>();

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
    final size = MediaQuery.of(context).size;
    final isCompactMobile = size.width <= 480;
    final isTablet = size.width > 480 && size.width <= 760;
    final crossAxisCount = isCompactMobile ? 4 : size.width > 1100 ? 4 : size.width > 760 ? 3 : 2;
    final maxFeaturesPerCategory = isCompactMobile
        ? 8
        : isTablet
            ? 10
            : 999;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: const Text(
            'Guardian Angel Premium',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
          FadeInRight(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(isCompactMobile ? 12 : 18, isCompactMobile ? 12 : 18, isCompactMobile ? 12 : 18, 12),
                  child: FadeInLeft(
                    duration: const Duration(milliseconds: 700),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Container(
                          padding: EdgeInsets.all(isCompactMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(isCompactMobile ? 22 : 30),
                            color: Colors.white.withOpacity(isDark ? 0.08 : 0.12),
                            border: Border.all(color: Colors.white.withOpacity(0.14)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: isCompactMobile ? 12 : 18,
                                offset: Offset(0, isCompactMobile ? 6 : 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: isCompactMobile ? 48 : 58,
                                height: isCompactMobile ? 48 : 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(isCompactMobile ? 14 : 18),
                                  color: Colors.white.withOpacity(0.14),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isCompactMobile ? 6 : 7),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(isCompactMobile ? 10 : 14),
                                    child: Image.memory(
                                      FeatureArt.bytesFor('sos'),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.shield_rounded,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: isCompactMobile ? 10 : 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, ${authProvider.user?.fullName.split(' ').first ?? 'User'}',
                                      style: TextStyle(
                                        fontSize: isCompactMobile ? 16 : 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: isCompactMobile ? 2 : 4),
                                    if (!isCompactMobile)
                                      Text(
                                        'One tap to protect, call, track, and share your journey with confidence.',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.white.withOpacity(0.78),
                                          height: 1.28,
                                        ),
                                      ),
                                  ],
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(isCompactMobile ? 12 : 18, 8, isCompactMobile ? 12 : 18, isCompactMobile ? 14 : 18),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 850),
                    delay: const Duration(milliseconds: 100),
                    child: Center(
                      child: Container(
                        width: isCompactMobile ? 220 : 260,
                        height: isCompactMobile ? 220 : 260,
                        padding: EdgeInsets.all(isCompactMobile ? 16 : 18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(isDark ? 0.08 : 0.12),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _QuickSosCircle(
                              compact: isCompactMobile,
                              onTap: () => Navigator.pushNamed(context, '/sos'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Quick SOS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isCompactMobile ? 14 : 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Emergency help in one tap',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                fontSize: isCompactMobile ? 10 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              for (int categoryIndex = 0; categoryIndex < AppFeatures.categories.length; categoryIndex++) ...[
                ...() {
                  final category = AppFeatures.categories[categoryIndex];
                  final categoryFeatures = AppFeatures.byCategory(category);
                  final visibleFeatures = categoryFeatures.take(maxFeaturesPerCategory).toList();
                  final hiddenCount = categoryFeatures.length - visibleFeatures.length;

                  return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isCompactMobile ? 12 : 18, categoryIndex == 0 ? 0 : 8, isCompactMobile ? 12 : 18, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompactMobile ? 16 : 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          hiddenCount > 0 ? '${visibleFeatures.length}/${categoryFeatures.length} shown' : '${categoryFeatures.length} features',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: isCompactMobile ? 10 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(isCompactMobile ? 12 : 18, 0, isCompactMobile ? 12 : 18, isCompactMobile ? 14 : 18),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isCompactMobile ? 8 : 16,
                      mainAxisSpacing: isCompactMobile ? 8 : 16,
                      childAspectRatio: isCompactMobile ? 0.74 : size.width > 760 ? 1.0 : 0.96,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final feature = visibleFeatures[index];
                        return FadeInUp(
                          duration: const Duration(milliseconds: 650),
                          delay: Duration(milliseconds: 90 + (index * 35)),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: FeatureCard(
                                  title: feature.title,
                                  subtitle: feature.subtitle,
                                  icon: feature.icon,
                                  imageProvider: MemoryImage(FeatureArt.bytesFor(feature.artKey)),
                                  gradientStart: feature.gradientStart,
                                  gradientEnd: feature.gradientEnd,
                                  compact: isCompactMobile,
                                  onPressed: () => _openFeature(feature),
                                ),
                              ),
                              Positioned(
                                left: isCompactMobile ? 6 : 14,
                                top: isCompactMobile ? 6 : 14,
                                child: _FeatureStatusPill(status: feature.status, compact: isCompactMobile),
                              ),
                              if (feature.control != null && !isCompactMobile)
                                Positioned(
                                  right: 14,
                                  bottom: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                                    ),
                                    child: const Text(
                                      'In Settings',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      childCount: visibleFeatures.length,
                    ),
                  ),
                ),
                if (hiddenCount > 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isCompactMobile ? 12 : 18, -4, isCompactMobile ? 12 : 18, isCompactMobile ? 14 : 18),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompactMobile ? 10 : 12,
                            vertical: isCompactMobile ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(isDark ? 0.07 : 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Text(
                            '+$hiddenCount more on larger screens',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.76),
                              fontSize: isCompactMobile ? 9.5 : 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ];
                }(),
              ],
            ],
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

class _FeatureStatusPill extends StatelessWidget {
  final AppFeatureStatus status;
  final bool compact;

  const _FeatureStatusPill({required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;

    switch (status) {
      case AppFeatureStatus.available:
        label = 'Live';
        color = Colors.greenAccent.shade400;
        break;
      case AppFeatureStatus.partial:
        label = 'Partial';
        color = Colors.amberAccent.shade400;
        break;
      case AppFeatureStatus.planned:
        label = 'Planned';
        color = Colors.white70;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 3 : 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: compact ? 8 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.1),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _QuickActionIcon(icon: icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _QuickActionIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            right: 8,
            bottom: 3,
            height: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            top: 2,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF6F4FB),
                    Color(0xFFE8E1F6),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.8)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 6,
                    left: 8,
                    right: 8,
                    height: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.95),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Icon(icon, color: Color.lerp(Colors.black, color, 0.55), size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSosCircle extends StatelessWidget {
  final bool compact;
  final VoidCallback onTap;

  const _QuickSosCircle({
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 108.0 : 128.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 4,
                child: Container(
                  width: size * 0.62,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.black.withOpacity(0.24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFF3F3),
                      Color(0xFFFFD8D8),
                      Color(0xFFFFC1C1),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(-2, -3),
                    ),
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: size * 0.78,
                height: size * 0.78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFFF1F1),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: size * 0.16,
                child: Container(
                  width: size * 0.34,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.95),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: size * 0.42,
                height: size * 0.42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.98),
                      Colors.redAccent.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 4),
                child: Icon(
                  Icons.warning_rounded,
                  size: compact ? 42 : 50,
                  color: Colors.red.withOpacity(0.16),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF8A80),
                      Color(0xFFE53935),
                      Color(0xFF8E0000),
                    ],
                  ).createShader(bounds);
                },
                child: Icon(
                  Icons.warning_rounded,
                  size: compact ? 40 : 48,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
