import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/kit_colors.dart';

/// Farbpunkt für ein Team — helle Trikotfarben bekommen einen Rand (US-111).
class TeamDot extends StatelessWidget {
  final Color color;
  final double size;

  const TeamDot({super.key, required this.color, this.size = 10});

  @override
  Widget build(BuildContext context) {
    final outline = teamColorOutline(context, color);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: outline != null ? Border.fromBorderSide(outline) : null,
      ),
    );
  }
}

/// Quadratisches Team-Kürzel „H"/„G" in Teamfarbe (Nachbereitung).
class TeamBadge extends StatelessWidget {
  final Color color;
  final String label;

  const TeamBadge({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final outline = teamColorOutline(context, color);
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.s - 2),
        border: outline != null ? Border.fromBorderSide(outline) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: context.text.labelMedium?.copyWith(
          color: AppColors.onColor(color),
        ),
      ),
    );
  }
}
