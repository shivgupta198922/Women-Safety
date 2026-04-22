import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  final List<Map<String, String>> safetyTips = const [
    {
      'title': 'Be Aware of Your Surroundings',
      'description': 'Always pay attention to what\'s happening around you. Avoid distractions like your phone when walking alone.'
    },
    {
      'title': 'Trust Your Instincts',
      'description': 'If a situation or person feels off, trust your gut feeling and remove yourself from the situation.'
    },
    {
      'title': 'Share Your Location',
      'description': 'Use the live location sharing feature with trusted contacts, especially when traveling alone or to new places.'
    },
    {
      'title': 'Have Emergency Contacts Ready',
      'description': 'Keep your emergency contacts updated and easily accessible in your Guardian Angel app.'
    },
    {
      'title': 'Learn Basic Self-Defense',
      'description': 'Knowing a few basic self-defense techniques can boost your confidence and help in critical situations.'
    },
    {
      'title': 'Use Well-Lit and Populated Routes',
      'description': 'Whenever possible, choose routes that are well-lit and have more people, especially at night.'
    },
    {
      'title': 'Inform Someone of Your Plans',
      'description': 'Let a friend or family member know where you\'re going, who you\'re with, and when you expect to return.'
    },
    {
      'title': 'Secure Your Home',
      'description': 'Always lock your doors and windows, even if you\'re just stepping out for a short while.'
    },
    {
      'title': 'Avoid Displaying Valuables',
      'description': 'Keep expensive items out of sight to avoid attracting unwanted attention.'
    },
    {
      'title': 'Emergency Siren',
      'description': 'In an emergency, activate the siren feature to draw attention and deter attackers.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Tips'),
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
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: safetyTips.length,
            itemBuilder: (context, index) {
              final tip = safetyTips[index];
              return GlassCard(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    tip['title']!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        tip['description']!,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}