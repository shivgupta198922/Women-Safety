import 'package:flutter/material.dart';
import 'package:guardian_angel_flutter/core/app_features.dart';
import 'package:provider/provider.dart';
import 'package:guardian_angel_flutter/providers/settings_provider.dart'; // Corrected import
import 'package:guardian_angel_flutter/providers/auth_provider.dart'; // Corrected import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionTitle('Profile'),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              const Divider(),
              const _SectionTitle('Appearance & Core'),
              ListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Available in dashboard feature list'),
                trailing: Switch(
                  value: settingsProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    settingsProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
              ListTile(
                title: const Text('Rakshak Mode'),
                subtitle: const Text('Guardian help mode'),
                trailing: Switch(
                  value: settingsProvider.rakshakMode,
                  onChanged: (value) => settingsProvider.toggleRakshakMode(value),
                ),
              ),
              const Divider(),
              const _SectionTitle('Emergency Triggers'),
              ListTile(
                title: const Text('Enable Shake SOS'),
                subtitle: const Text('Shake phone to trigger help'),
                trailing: Switch(
                  value: settingsProvider.enableShakeSos,
                  onChanged: (value) => settingsProvider.setEnableShakeSos(value),
                ),
              ),
              ListTile(
                title: const Text('Enable Voice SOS ("Help me")'),
                subtitle: const Text('Voice command emergency trigger'),
                trailing: Switch(
                  value: settingsProvider.enableVoiceSos,
                  onChanged: (value) => settingsProvider.setEnableVoiceSos(value),
                ),
              ),
              ListTile(
                title: const Text('Auto Record Audio on SOS'),
                subtitle: const Text('Evidence capture during emergency'),
                trailing: Switch(
                  value: settingsProvider.autoRecordAudioOnSos,
                  onChanged: (value) => settingsProvider.setAutoRecordAudioOnSos(value),
                ),
              ),
              ListTile(
                title: const Text('Auto Record Video on SOS'),
                subtitle: const Text('Video evidence during emergency'),
                trailing: Switch(
                  value: settingsProvider.autoRecordVideoOnSos,
                  onChanged: (value) => settingsProvider.setAutoRecordVideoOnSos(value),
                ),
              ),
              const Divider(),
              const _SectionTitle('AI Detection'),
              ListTile(
                title: const Text('Enable AI Danger Detection'),
                subtitle: const Text('Scream, fall, and abnormal motion heuristics'),
                trailing: Switch(
                  value: settingsProvider.enableAIDetection,
                  onChanged: (value) => settingsProvider.setEnableAIDetection(value),
                ),
              ),
              ListTile(
                title: const Text('Auto Alert on AI Danger'),
                subtitle: const Text('Send SOS automatically on detected risk'),
                trailing: Switch(
                  value: settingsProvider.autoAlertAIDetection,
                  onChanged: (value) => settingsProvider.setAutoAlertAIDetection(value),
                ),
              ),
              const Divider(),
              const _SectionTitle('Journey & Notifications'),
              ListTile(
                title: const Text('Default Check-in Interval (minutes)'),
                trailing: DropdownButton<int>(
                  value: settingsProvider.defaultCheckInIntervalMinutes,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      settingsProvider.setDefaultCheckInIntervalMinutes(newValue);
                    }
                  },
                  items: <int>[5, 10, 15, 20, 30, 60].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(value: value, child: Text('$value min'));
                  }).toList(),
                ),
              ),
              ListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Check-in and real-time app alerts'),
                trailing: Switch(
                  value: settingsProvider.notifications,
                  onChanged: (value) => settingsProvider.setNotifications(value),
                ),
              ),
              const Divider(),
              const _SectionTitle('Features Available In Settings'),
              ...AppFeatures.controllableInSettings().map(
                (feature) => Card(
                  child: ListTile(
                    leading: Icon(feature.icon),
                    title: Text(feature.title),
                    subtitle: Text(feature.subtitle),
                    trailing: Icon(
                      feature.status == AppFeatureStatus.available
                          ? Icons.check_circle_rounded
                          : feature.status == AppFeatureStatus.partial
                              ? Icons.pending_rounded
                              : Icons.schedule_rounded,
                    ),
                  ),
                ),
              ),
              const Divider(),
              const _SectionTitle('Session'),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
