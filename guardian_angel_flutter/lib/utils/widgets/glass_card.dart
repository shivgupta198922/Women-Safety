// Since glassmorphism package may have issues, custom implementation

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme.dart' as theme;

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;
  final EdgeInsets padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.color = theme.GuardianTheme.glassWhite,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: color.withAlpha((color.alpha * 0.3).round()),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(color.red, color.green, color.blue, 0.2),
                Color.fromRGBO(color.red, color.green, color.blue, 0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

