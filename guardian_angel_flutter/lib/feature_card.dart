import 'package:flutter/material.dart';

import '../core/theme.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? gradientStart;
  final Color? gradientEnd;
  final ImageProvider? imageProvider;
  final bool compact;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
    this.gradientStart,
    this.gradientEnd,
    this.imageProvider,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGradientStart = isDark ? GuardianTheme.darkGradientStart : GuardianTheme.primaryGradientStart;
    final defaultGradientEnd = isDark ? GuardianTheme.darkGradientEnd : GuardianTheme.primaryGradientEnd;
    final start = gradientStart ?? defaultGradientStart;
    final end = gradientEnd ?? defaultGradientEnd;
    final badgeIconColor = Color.lerp(Colors.black, end, 0.35) ?? end;
    final radius = compact ? 18.0 : 28.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [start, end],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.34 : 0.16),
                blurRadius: compact ? 12 : 22,
                offset: Offset(0, compact ? 7 : 12),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 8 : 18, compact ? 6 : 14, compact ? 8 : 18, compact ? 10 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: compact ? 2 : 12, bottom: compact ? 8 : 14),
                    child: _IconBadge(
                      icon: icon,
                      imageProvider: imageProvider,
                      badgeIconColor: badgeIconColor,
                      accentColor: Color.lerp(start, Colors.white, 0.18) ?? start,
                      compact: compact,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: compact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: compact ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 11.5 : 18,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final ImageProvider? imageProvider;
  final Color badgeIconColor;
  final Color accentColor;
  final bool compact;

  const _IconBadge({
    required this.icon,
    required this.imageProvider,
    required this.badgeIconColor,
    required this.accentColor,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 74 : 142,
      height: compact ? 78 : 146,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: compact ? 10 : 20,
            right: compact ? 10 : 20,
            bottom: compact ? 5 : 10,
            height: compact ? 16 : 34,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.28),
                    Colors.black.withOpacity(0.04),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: compact ? 10 : 22,
                    offset: Offset(0, compact ? 6 : 13),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: compact ? 8 : 16,
            left: compact ? 6 : 12,
            right: compact ? 6 : 12,
            bottom: compact ? 9 : 18,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Color(0xFFFFFFFF),
                    Color(0xFFF7EFFF),
                    Color(0xFFEBDCF9),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.82), width: compact ? 1.0 : 1.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.36),
                    blurRadius: compact ? 4 : 9,
                    offset: Offset(compact ? -1 : -2, compact ? -1 : -3),
                  ),
                  BoxShadow(
                    color: accentColor.withOpacity(0.28),
                    blurRadius: compact ? 10 : 20,
                    offset: Offset(0, compact ? 5 : 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: compact ? 7 : 16,
                    offset: Offset(0, compact ? 4 : 10),
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: compact ? 12 : 24,
            left: compact ? 10 : 20,
            right: compact ? 10 : 20,
            bottom: compact ? 13 : 26,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.55),
                  width: compact ? 0.8 : 1.2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.45),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: compact ? 14 : 28,
            left: compact ? 12 : 24,
            right: compact ? 12 : 24,
            bottom: compact ? 15 : 30,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    const Color(0xFFF7F4FB),
                    Color.lerp(const Color(0xFFF7F4FB), accentColor, 0.08) ?? const Color(0xFFF7F4FB),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: compact ? 4 : 10,
                    offset: Offset(compact ? -1 : -2, compact ? -1 : -2),
                    spreadRadius: -1,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: compact ? 4 : 10,
                    offset: Offset(0, compact ? 2 : 6),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (imageProvider != null)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.06,
                        child: ClipOval(
                          child: Image(
                            image: imageProvider!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: compact ? 5 : 10,
                    left: compact ? 8 : 16,
                    right: compact ? 8 : 16,
                    height: compact ? 10 : 22,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.95),
                            Colors.white.withOpacity(0.12),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: compact ? 9 : 20,
                    left: compact ? 14 : 28,
                    width: compact ? 13 : 28,
                    height: compact ? 8 : 18,
                    child: Transform.rotate(
                      angle: -0.35,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.92),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, compact ? 3 : 7),
                    child: Container(
                      width: compact ? 34 : 68,
                      height: compact ? 34 : 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.95),
                            accentColor.withOpacity(0.16),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.75),
                          width: compact ? 0.7 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.16),
                            blurRadius: compact ? 7 : 16,
                            offset: Offset(0, compact ? 3 : 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: compact ? 3 : 8,
                            offset: Offset(compact ? -1 : -2, compact ? -1 : -2),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, compact ? 4 : 8),
                    child: Icon(
                      icon,
                      size: compact ? 34 : 70,
                      color: badgeIconColor.withOpacity(0.18),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(Colors.white, badgeIconColor, 0.15) ?? badgeIconColor,
                          badgeIconColor,
                          Color.lerp(badgeIconColor, Colors.black, 0.12) ?? badgeIconColor,
                        ],
                      ).createShader(bounds);
                    },
                    child: Icon(
                      icon,
                      size: compact ? 33 : 68,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
