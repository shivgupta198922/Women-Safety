import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/location_provider.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Profile
          GlassCard(
            child: ListTile(
              leading: CircleAvatar(child: Text('A')),
              title: Consumer<AuthProvider>(
                builder: (context, auth, child) => Text(auth.user?.name ?? 'User'),
              ),
              trailing: Icon(Icons.edit),
              subtitle: Text('Tap to edit profile'),
            ),
          ),
          SizedBox(height: 16),
          // Theme toggle
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => SwitchListTile(
              title: Text('Dark Mode'),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (value) => settings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          SwitchListTile(
            title: Text('Rakshak Mode'),
            value: context.watch<SettingsProvider>().rakshakMode,
            onChanged: context.read<SettingsProvider>().toggleRakshakMode,
          ),
          SwitchListTile(
            title: Text('Push Notifications'),
            value: context.watch<SettingsProvider>().notifications,
            onChanged: context.read<SettingsProvider>().setNotifications,
          ),
          // SOS Preferences
          ListTile(
            title: Text('SOS Settings'),
            leading: Icon(Icons.sos),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => showSOSSettings(context),
          ),
          // Privacy & Permissions
          ListTile(
            title: Text('Privacy & Permissions'),
            leading: Icon(Icons.privacy_tip),
            trailing: Icon(Icons.arrow_forward),
          ),
          ListTile(
            title: Text('Backup & Restore'),
            leading: Icon(Icons.backup),
            trailing: Icon(Icons.arrow_forward),
          ),
          // Logout
          Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => context.read<AuthProvider>().logout(),
            ),
          ),
        ],
      ),
    );
  }

  void showSOSSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('SOS Preferences'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Shake to SOS'),
              value: true,
              onChanged: (v) {},
            ),
            SwitchListTile(
              title: Text('Voice Commands'),
              value: true,
              onChanged: (v) {},
            ),
            TextField(decoration: InputDecoration(labelText: 'Countdown (seconds)')),
            SwitchListTile(
              title: Text('Auto Record Evidence'),
              value: true,
              onChanged: (v) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: Text('Cancel')),
          ElevatedButton(onPressed: Navigator.of(context).pop, child: Text('Save')),
        ],
      ),
    );
  }
}

