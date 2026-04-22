import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:guardian_angel_flutter/core/theme.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? gradientStart;
  final Color? gradientEnd;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
    this.gradientStart,
    this.gradientEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGradientStart = isDark ? GuardianTheme.darkGradientStart : GuardianTheme.primaryGradientStart;
    final defaultGradientEnd = isDark ? GuardianTheme.darkGradientEnd : GuardianTheme.primaryGradientEnd;

    return GestureDetector(
      onTap: onPressed,
      child: Glassmorphism(
        blur: 10,
        opacity: 0.2,
        radius: 16,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart ?? defaultGradientStart, gradientEnd ?? defaultGradientEnd],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: iconColor),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}