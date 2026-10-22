import 'package:flutter/material.dart';

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
                  isDense: true,
                ),
                onSubmitted: (_) {
                  _submit();
                  // Fokus halten: mehrere Nummern hintereinander eintippen
                  _focus.requestFocus();
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              key: _key('add'),
              onPressed: _submit,
              child: const Text('+ Hinzufügen'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.numbers
              .map((n) => Chip(
                    key: _key('chip_$n'),
                    label: Text('#$n',
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: widget.teamColor,
                    deleteIconColor: Colors.white70,
                    onDeleted: () => widget.onRemove(n),
                  ))
              .toList(),
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
