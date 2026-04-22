import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../utils/app_utils.dart';

class WomenHelplineScreen extends StatelessWidget {
  const WomenHelplineScreen({super.key});

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      AppUtils.showSnackBar(context as BuildContext, 'Could not launch $phoneNumber', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> helplines = [
      {'name': 'National Women\'s Helpline', 'number': '1098'},
      {'name': 'Police Emergency', 'number': '100'},
      {'name': 'Childline India', 'number': '1098'},
      {'name': 'Domestic Abuse Hotline', 'number': '181'},
      {'name': 'Cyber Crime Helpline', 'number': '155260'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Women Helplines'),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Immediate Assistance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reach out to these helplines for quick support.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: helplines.length,
                    itemBuilder: (context, index) {
                      final helpline = helplines[index];
                      return GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(Icons.phone, color: Theme.of(context).primaryColor),
                          title: Text(
                            helpline['name']!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            helpline['number']!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.call, color: Colors.greenAccent),
                            onPressed: () => _launchPhoneCall(helpline['number']!),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}