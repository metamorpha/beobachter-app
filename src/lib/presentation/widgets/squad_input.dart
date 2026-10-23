import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Rückennummern-Eingabe mit Chips — gemeinsam für Spiel-Setup und
/// Aufstellungs-Dialog im Live-Screen (US-102, US-110).
class SquadInput extends StatefulWidget {
  final List<int> numbers;
  final Color teamColor;
  final void Function(int) onAdd;
  final void Function(int) onRemove;

  /// Präfix für Test-Keys, z. B. „squad_home" → `squad_home_field`.
  final String? keyPrefix;

  const SquadInput({
    super.key,
    required this.numbers,
    required this.teamColor,
    required this.onAdd,
    required this.onRemove,
    this.keyPrefix,
  });

  @override
  State<SquadInput> createState() => _SquadInputState();
}

class _SquadInputState extends State<SquadInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  Key? _key(String suffix) =>
      widget.keyPrefix != null ? Key('${widget.keyPrefix}_$suffix') : null;

  void _submit() {
    final n = int.tryParse(_ctrl.text);
    if (n != null && n >= 1 && n <= 99) widget.onAdd(n);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final onTeam = AppColors.onColor(widget.teamColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: _key('field'),
                controller: _ctrl,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Rückennummer (1–99)',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                onSubmitted: (_) {
                  _submit();
                  // Fokus halten: mehrere Nummern hintereinander eintippen
                  _focus.requestFocus();
                },
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            FilledButton.tonal(
              key: _key('add'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(AppSizes.tap, 52),
              ),
              onPressed: _submit,
              child: const Text('+ Hinzufügen'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        AnimatedSize(
          duration: AppMotion.of(context, AppMotion.medium),
          curve: AppMotion.curve,
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: AppSpacing.s - 2,
            runSpacing: AppSpacing.s - 2,
            children: widget.numbers
                .map(
                  (n) => Chip(
                    key: _key('chip_$n'),
                    label: Text(
                      '#$n',
                      style: TextStyle(
                        color: onTeam,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    backgroundColor: widget.teamColor,
                    side: BorderSide.none,
                    deleteIconColor: onTeam.withValues(alpha: 0.8),
                    onDeleted: () => widget.onRemove(n),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }
}
