import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme.dart'; // For GlassCard and GradientContainer
import '../widgets/feature_card.dart'; // For the reusable feature cards
import 'package:url_launcher/url_launcher.dart'; // For Women Helpline
import '../utils/app_utils.dart'; // For snackbars

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Any initial setup for the home screen can go here
  }

  Future<void> _launchHelpline(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      AppUtils.showSnackBar(context, 'Could not launch $phoneNumber', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows body to go behind transparent app bar
      appBar: AppBar(
        title: const Text(
          'Guardian Angel Premium',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
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
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      'Welcome, ${authProvider.user?.fullName ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const Text(
                  'Your safety is our priority.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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
                          Navigator.pushNamed(context, '/women_helpline'); // Navigate to dedicated screen
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
                        title: 'Profile',
                        icon: Icons.person,
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}