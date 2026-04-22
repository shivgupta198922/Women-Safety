import 'package:flutter/material.dart';
import 'dart:ui' as ui; // Keep this import here as GlassCard uses it
import 'package:guardian_angel_flutter/core/theme.dart';

// Custom Glass Card with BackdropFilter
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;
  final EdgeInsets? margin; // Added margin for spacing
  final EdgeInsets padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.color = GuardianTheme.glassWhite,
    this.margin,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container( // Added Container for margin
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.15),
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.02)
                : Colors.white.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur), // Apply blur to the background
          child: Padding(padding: padding, child: child), // Apply padding inside the blurred area
        ),
      ),
    );
  }
}