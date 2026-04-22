import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../../providers/sos_provider.dart';
import '../../utils/app_utils.dart';
import '../../core/theme.dart';
import '../../widgets/custom_button.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

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
                        'Tap to Send SOS',
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
                      CustomButton(
                        text: sosProvider.isSendingSos ? 'SENDING SOS...' : 'SEND SOS NOW',
                        onPressed: sosProvider.isSendingSos
                            ? null
                            : () async {
                                // Vibrate phone immediately
                                if (await Vibrate.canVibrate) {
                                  Vibrate.vibrate();
                                }
                                try {
                                  await sosProvider.sendSos(type: "SOS_PANIC");
                                  AppUtils.showSnackBar(context, sosProvider.sosMessage ?? 'SOS sent!');
                                  // Optionally navigate back or show a confirmation screen
                                  Navigator.pop(context);
                                } catch (e) {
                                  AppUtils.showSnackBar(context, sosProvider.sosMessage ?? 'Failed to send SOS.', isError: true);
                                }
                              },
                        backgroundColor: Colors.red.shade700,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
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
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Emergency')),
      body: const Center(child: Text('SOS Emergency Details (Coming Soon)')),
    );
  }
}