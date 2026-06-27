import 'package:flutter/material.dart';

import '../../domain/enums/assessment.dart';

/// 2×2-Grid für die Szenen-Bewertung.
/// Ein Tap wählt Korrekt/Falsch + Erwartbar/Komplex gleichzeitig.
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
            _cell(Assessment.correctExpected, Colors.green.shade700),
            const SizedBox(width: 4),
            _cell(Assessment.correctComplex, Colors.green.shade900),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _cell(Assessment.wrongExpected, Colors.red.shade700),
            const SizedBox(width: 4),
            _cell(Assessment.wrongComplex, Colors.red.shade900),
          ],
        ),
      ],
    );
  }

  Widget _cell(Assessment value, Color color) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        key: Key('assessment_${value.name}'),
        onTap: () => onChanged(isSelected ? null : value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.25),
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            value.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
