import 'package:flutter/material.dart';
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
      ), // Replaced Provider.of with context.read
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Section
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              const Divider(),
              // Theme Toggle
              ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: settingsProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    settingsProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
              // Rakshak Mode Toggle
              ListTile(
                title: const Text('Rakshak Mode'),
                trailing: Switch(
                  value: settingsProvider.rakshakMode,
                  onChanged: (value) => settingsProvider.toggleRakshakMode(value), // Assuming toggleRakshakMode takes a bool
                ),
              ),
              // Shake SOS Toggle
              ListTile(
                title: const Text('Enable Shake SOS'),
                trailing: Switch(
                  value: settingsProvider.enableShakeSos,
                  onChanged: (value) => settingsProvider.setEnableShakeSos(value),
                ),
              ),
              // Voice SOS Toggle
              ListTile(
                title: const Text('Enable Voice SOS ("Help me")'),
                trailing: Switch(
                  value: settingsProvider.enableVoiceSos,
                  onChanged: (value) => settingsProvider.setEnableVoiceSos(value),
                ),
              ),
              // Auto Record Audio on SOS
              ListTile(
                title: const Text('Auto Record Audio on SOS'),
                trailing: Switch(
                  value: settingsProvider.autoRecordAudioOnSos,
                  onChanged: (value) => settingsProvider.setAutoRecordAudioOnSos(value),
                ),
              ),
              // Auto Record Video on SOS
              ListTile(
                title: const Text('Auto Record Video on SOS'),
                trailing: Switch(
                  value: settingsProvider.autoRecordVideoOnSos,
                  onChanged: (value) => settingsProvider.setAutoRecordVideoOnSos(value),
                ),
              ),
              const Divider(),
              // AI Danger Detection
              ListTile(
                title: const Text('Enable AI Danger Detection'),
                trailing: Switch(
                  value: settingsProvider.enableAIDetection,
                  onChanged: (value) => settingsProvider.setEnableAIDetection(value),
                ),
              ),
              ListTile(
                title: const Text('Auto Alert on AI Danger'),
                trailing: Switch(
                  value: settingsProvider.autoAlertAIDetection,
                  onChanged: (value) => settingsProvider.setAutoAlertAIDetection(value),
                ),
              ),
              const Divider(),
              // Check-in Interval Setting
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
              // Notifications Toggle
              ListTile(
                title: const Text('Push Notifications'),
                trailing: Switch(
                  value: settingsProvider.notifications,
                  onChanged: (value) => settingsProvider.setNotifications(value), // Assuming setNotifications takes a bool
                ),
              ),
              const Divider(),
              // Logout Button
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await context.read<AuthProvider>().logout(); // Replaced Provider.of with context.read
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