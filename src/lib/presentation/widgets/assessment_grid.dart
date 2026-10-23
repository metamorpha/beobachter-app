import 'package:flutter/material.dart';

import '../../domain/enums/assessment.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'select_tile.dart';

/// 2×2-Grid für die Szenen-Bewertung.
/// Ein Tap wählt Korrekt/Falsch + Erwartbar/Komplex gleichzeitig.
/// ✓/✗ machen die Felder auch ohne Farbwahrnehmung unterscheidbar (US-603).
class AssessmentGrid extends StatelessWidget {
  final Assessment? selected;
  final ValueChanged<Assessment?> onChanged;

  const AssessmentGrid({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _cell(context, Assessment.correctExpected),
            const SizedBox(width: AppSpacing.s - 2),
            _cell(context, Assessment.correctComplex),
          ],
        ),
        const SizedBox(height: AppSpacing.s - 2),
        Row(
          children: [
            _cell(context, Assessment.wrongExpected),
            const SizedBox(width: AppSpacing.s - 2),
            _cell(context, Assessment.wrongComplex),
          ],
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, Assessment value) {
    final isSelected = selected == value;
    final color =
        value.isCorrect ? context.colors.correct : context.colors.wrong;
    return Expanded(
      child: SelectTile(
        key: Key('assessment_${value.name}'),
        label: value.label,
        icon: value.isCorrect ? Icons.check : Icons.close,
        horizontal: true,
        dense: true,
        minHeight: AppSizes.primaryAction,
        selected: isSelected,
        color: color,
        unselectedColor:
            Color.alphaBlend(color.withValues(alpha: 0.08), context.scheme.surface),
        onTap: () => onChanged(isSelected ? null : value),
      ),
    );
  }
}
