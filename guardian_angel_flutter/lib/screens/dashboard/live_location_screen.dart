import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/app_utils.dart';
import 'package:guardian_angel_flutter/core/theme.dart' hide GlassCard; // Corrected import
import 'package:guardian_angel_flutter/widgets/custom_button.dart'; // Corrected import
import 'package:guardian_angel_flutter/widgets/glass_card.dart'; // Corrected import

class LiveLocationScreen extends StatelessWidget {
  const LiveLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Sharing'),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                return GlassCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        locationProvider.isTracking ? Icons.location_on : Icons.location_off,
                        size: 80,
                        color: locationProvider.isTracking ? Colors.greenAccent : Colors.white70,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        locationProvider.isTracking ? 'Sharing Live Location' : 'Live Location Sharing Off',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        locationProvider.isTracking
                            ? 'Your real-time location is being shared with your emergency contacts.'
                            : 'Start sharing your live location with your emergency contacts for added safety.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      if (locationProvider.currentPosition != null)
                        Text(
                          'Current Location: Lat ${locationProvider.currentPosition!.latitude.toStringAsFixed(4)}, Lng ${locationProvider.currentPosition!.longitude.toStringAsFixed(4)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      if (locationProvider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Error: ${locationProvider.errorMessage}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade300, fontSize: 14),
                          ),
                        ),
                      const SizedBox(height: 32), // Corrected to use CustomButton
                      CustomButton(
                        text: locationProvider.isTracking ? 'STOP SHARING' : 'START SHARING',
                        onPressed: () {
                          if (locationProvider.isTracking) {
                            locationProvider.stopLiveLocationSharing();
                            if (context.mounted) AppUtils.showSnackBar(context, 'Live location sharing stopped.');
                          } else {
                            locationProvider.startLiveLocationSharing();
                            if (context.mounted) AppUtils.showSnackBar(context, 'Live location sharing started!');
                          }
                        },
                        backgroundColor: locationProvider.isTracking ? Colors.redAccent : Colors.green,
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
