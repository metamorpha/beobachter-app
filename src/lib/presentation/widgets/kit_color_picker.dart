import 'package:flutter/material.dart';

import '../../domain/enums/kit_color.dart';
import '../../domain/enums/team_side.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/kit_colors.dart';

/// Auswahl der Trikotfarbe eines Teams aus der festen Palette (US-111) —
/// gemeinsam für Spiel-Setup und Aufstellungs-Dialog im Live-Screen.
class KitColorPicker extends StatelessWidget {
  final TeamSide team;
  final KitColor? selected;
  final ValueChanged<KitColor> onSelected;

  static const double swatchSize = 40;

  const KitColorPicker({
    super.key,
    required this.team,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trikotfarbe',
          style: context.text.labelMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final kit in KitColor.values)
              _Swatch(
                key: Key('kit_${team.name}_${kit.name}'),
                kit: kit,
                team: team,
                selected: kit == selected,
                onTap: () {
                  if (kit != selected) onSelected(kit);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final KitColor kit;
  final TeamSide team;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({
    super.key,
    required this.kit,
    required this.team,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = kit.color;
    final outline = teamColorOutline(context, color);
    final border = selected
        ? Border.all(color: context.scheme.primary, width: 3)
        : outline != null
        ? Border.fromBorderSide(outline)
        : null;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Trikotfarbe ${team.label}: ${kit.label}',
      child: Tooltip(
        message: kit.label,
        excludeFromSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: KitColorPicker.swatchSize / 2 + 4,
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            width: KitColorPicker.swatchSize,
            height: KitColorPicker.swatchSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: border,
            ),
            child: selected
                ? Icon(
                    Icons.check_rounded,
                    size: 22,
                    color: AppColors.onColor(color),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// Hinweis bei gleicher Trikotfarbe beider Teams — blockiert nichts.
class KitClashHint extends StatelessWidget {
  const KitClashHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('kit_clash_hint'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: context.colors.warningContainer,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: context.colors.onWarningContainer,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Beide Teams haben dieselbe Trikotfarbe',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onWarningContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
