import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Karte mit Titel und Inhalt für das Statistik-Dashboard (US-605).
class StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const StatCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: context.scheme.primary),
                const SizedBox(width: AppSpacing.s),
                Text(title, style: context.text.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
