import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuardianTheme {
  static const Color primaryGradientStart = Color(0xFFE91E63); // Emergency red
  static const Color primaryGradientEnd = Color(0xFF7B2CBF); // Purple
  static const Color primaryColor = Color(0xFFE91E63); // Define primaryColor for general use
  static const Color darkGradientStart = Color(0xFF1A1A2E); // Dark theme background start
  static const Color darkGradientEnd = Color(0xFF16213E); // Dark theme background end
  static const Color accentGold = Color(0xFFFFC107);
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassBlack = Color(0xCC000000);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor, // Explicitly set primaryColor
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryGradientStart, brightness: Brightness.light),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryGradientStart),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16),
      ),
    ).apply(bodyColor: Colors.black87),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 12,
      shadowColor: Color(0x26000000),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 8,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: glassWhite,
      selectedItemColor: primaryGradientStart,
      unselectedItemColor: Colors.grey,
      elevation: 8,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: glassWhite,
      foregroundColor: primaryGradientStart,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGradientStart,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      ),
    ).apply(bodyColor: Colors.white),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 12,
      shadowColor: Color(0x24FFFFFF),
      surfaceTintColor: glassBlack,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryGradientStart,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 8,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: glassBlack,
      selectedItemColor: primaryGradientStart,
      unselectedItemColor: Colors.white54,
      elevation: 8,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: glassBlack,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    ),
  );
}

// Custom Glass Card with BackdropFilter
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
    this.color = GuardianTheme.glassWhite,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed direct padding here, it's applied inside BackdropFilter
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
          child: Padding(padding: padding, child: child), // Apply padding inside the blurred area, fixed duplicate
        ),
      ),
    );
  }
}

// Premium Gradient Container
class GradientContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  const GradientContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          colors: [
            GuardianTheme.primaryGradientStart,
            GuardianTheme.primaryGradientEnd,
            GuardianTheme.accentGold.withAlpha(204), // 0.8 * 255
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

// Emergency SOS Button
class SOSButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const SOSButton({
    super.key,
    required this.onPressed,
    this.label = 'SOS EMERGENCY',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              GuardianTheme.primaryGradientStart,
              GuardianTheme.primaryGradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: GuardianTheme.primaryGradientStart.withAlpha(153), // 0.6 * 255
              blurRadius: 30,
              spreadRadius: 8,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sos, 
              size: 40, 
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 8,
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
