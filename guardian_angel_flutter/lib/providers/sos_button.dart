import 'package:flutter/material.dart';
import 'package:guardian_angel_flutter/core/theme.dart';

// Emergency SOS Button (Enhanced for visual appeal)
class SOSButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final double size;
  final EdgeInsets? margin;

  const SOSButton({
    super.key,
    required this.onPressed,
    this.label = 'SOS EMERGENCY',
    this.size = 120,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: margin,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFFFF5252), // Brighter red
              GuardianTheme.primaryGradientStart,
              Color(0xFFB71C1C), // Darker red
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.6),
              blurRadius: 25,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sos,
              size: size * 0.35,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.09,
                letterSpacing: 1.2,
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}