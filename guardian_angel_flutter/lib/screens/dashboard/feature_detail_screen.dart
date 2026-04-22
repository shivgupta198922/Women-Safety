import 'package:flutter/material.dart';
import 'package:guardian_angel_flutter/core/app_features.dart';
import 'package:guardian_angel_flutter/core/feature_art.dart';
import 'package:guardian_angel_flutter/core/theme.dart' hide GlassCard;
import 'package:guardian_angel_flutter/widgets/glass_card.dart';

class FeatureDetailScreen extends StatelessWidget {
  final AppFeature feature;

  const FeatureDetailScreen({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(feature.title),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              FeatureArt.bytesFor(feature.artKey),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                feature.icon,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              feature.subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.78),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GlassCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusBadge(status: feature.status),
                      const SizedBox(height: 16),
                      Text(
                        feature.details,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Category: ${feature.category}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (feature.control != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'This feature has a related control in Settings.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.78),
                          ),
                        ),
                      ],
                    ],
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

class _StatusBadge extends StatelessWidget {
  final AppFeatureStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;

    switch (status) {
      case AppFeatureStatus.available:
        label = 'Available';
        color = Colors.greenAccent.shade400;
        break;
      case AppFeatureStatus.partial:
        label = 'Partially Available';
        color = Colors.amberAccent.shade400;
        break;
      case AppFeatureStatus.planned:
        label = 'Planned';
        color = Colors.white70;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
