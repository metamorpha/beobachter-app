import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pressebericht_csv_parser.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/enums/team_side.dart';
import '../../providers/providers.dart';
import '../live/live_screen.dart';

class GameSetupScreen extends ConsumerStatefulWidget {
  final Game game;

  const GameSetupScreen({super.key, required this.game});

  @override
  ConsumerState<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
  late final TextEditingController _homeCtrl;
  late final TextEditingController _awayCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _ligaCtrl;
  late final TextEditingController _spieltagCtrl;
  List<int> _homeNumbers = [];
  List<int> _awayNumbers = [];
  DateTime? _importedDate;
  List<String> _importWarnings = [];

  @override
  void initState() {
    super.initState();
    _homeCtrl = TextEditingController(text: widget.game.homeTeamName);
    _awayCtrl = TextEditingController(text: widget.game.awayTeamName);
    _locationCtrl = TextEditingController(text: widget.game.location ?? '');
    _ligaCtrl = TextEditingController(text: widget.game.liga ?? '');
    _spieltagCtrl = TextEditingController(text: widget.game.spieltag ?? '');
    _loadSquads();
  }

  Future<void> _loadSquads() async {
    final repo = ref.read(squadRepositoryProvider);
    final home = await repo.getSquad(widget.game.id, TeamSide.home);
    final away = await repo.getSquad(widget.game.id, TeamSide.away);
    setState(() {
      _homeNumbers = home;
      _awayNumbers = away;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiel einrichten'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _onImportTap,
                icon: const Icon(Icons.upload_file),
                label: const Text('Aus Pressebericht importieren'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.green.shade700),
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ),
            if (_importWarnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              _ImportWarningBanner(
                warnings: _importWarnings,
                onDismiss: () => setState(() => _importWarnings = []),
              ),
            ],
            const SizedBox(height: 16),
            _SectionTitle('Spieldaten'),
            TextField(
              controller: _homeCtrl,
              decoration: const InputDecoration(labelText: 'Heimmannschaft'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _awayCtrl,
              decoration: const InputDecoration(labelText: 'Gastmannschaft'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ligaCtrl,
              decoration: const InputDecoration(labelText: 'Liga (optional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _spieltagCtrl,
              decoration: const InputDecoration(labelText: 'Spieltag (optional)'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'Spielort (optional)'),
            ),
            const SizedBox(height: 24),
            _SectionTitle('Aufstellung Heim'),
            _SquadInput(
              numbers: _homeNumbers,
              teamColor: Colors.blue,
              onAdd: (n) => _addNumber(TeamSide.home, n),
              onRemove: (n) => _removeNumber(TeamSide.home, n),
            ),
            const SizedBox(height: 16),
            _SectionTitle('Aufstellung Gast'),
            _SquadInput(
              numbers: _awayNumbers,
              teamColor: Colors.red,
              onAdd: (n) => _addNumber(TeamSide.away, n),
              onRemove: (n) => _removeNumber(TeamSide.away, n),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _startGame,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Spiel starten', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onImportTap() async {
    final hasData = _homeCtrl.text.isNotEmpty ||
        _awayCtrl.text.isNotEmpty ||
        _homeNumbers.isNotEmpty ||
        _awayNumbers.isNotEmpty;

    if (hasData) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Daten überschreiben?'),
          content: const Text(
              'Der Import überschreibt alle vorhandenen Spieldaten. Fortfahren?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Importieren'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await _doImport();
  }

  Future<void> _doImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.single.bytes;
    if (bytes == null) return;

    String content;
    try {
      content = utf8.decode(bytes);
    } catch (_) {
      content = latin1.decode(bytes);
    }

    CsvImportResult importResult;
    try {
      importResult = PresskBerichtCsvParser.parse(content);
    } on CsvFormatException catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Kein erkanntes Format'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final repo = ref.read(squadRepositoryProvider);
    await repo.saveSquad(widget.game.id, TeamSide.home, importResult.homeNumbers);
    await repo.saveSquad(widget.game.id, TeamSide.away, importResult.awayNumbers);

    setState(() {
      if (importResult.homeTeamName != null) {
        _homeCtrl.text = importResult.homeTeamName!;
      }
      if (importResult.awayTeamName != null) {
        _awayCtrl.text = importResult.awayTeamName!;
      }
      if (importResult.location != null) {
        _locationCtrl.text = importResult.location!;
      }
      if (importResult.liga != null) _ligaCtrl.text = importResult.liga!;
      if (importResult.spieltag != null) {
        _spieltagCtrl.text = importResult.spieltag!;
      }
      _importedDate = importResult.date;
      _homeNumbers = importResult.homeNumbers;
      _awayNumbers = importResult.awayNumbers;
      _importWarnings = importResult.warnings;
    });
  }

  Future<void> _addNumber(TeamSide team, int number) async {
    final repo = ref.read(squadRepositoryProvider);
    setState(() {
      if (team == TeamSide.home && !_homeNumbers.contains(number)) {
        _homeNumbers = [..._homeNumbers, number]..sort();
      } else if (team == TeamSide.away && !_awayNumbers.contains(number)) {
        _awayNumbers = [..._awayNumbers, number]..sort();
      }
    });
    await repo.saveSquad(widget.game.id, team,
        team == TeamSide.home ? _homeNumbers : _awayNumbers);
  }

  Future<void> _removeNumber(TeamSide team, int number) async {
    final repo = ref.read(squadRepositoryProvider);
    setState(() {
      if (team == TeamSide.home) {
        _homeNumbers = _homeNumbers.where((n) => n != number).toList();
      } else {
        _awayNumbers = _awayNumbers.where((n) => n != number).toList();
      }
    });
    await repo.saveSquad(widget.game.id, team,
        team == TeamSide.home ? _homeNumbers : _awayNumbers);
  }

  Future<void> _startGame() async {
    final updatedGame = Game(
      id: widget.game.id,
      date: _importedDate ?? widget.game.date,
      kickoffTime: widget.game.kickoffTime,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      homeTeamName: _homeCtrl.text.trim(),
      awayTeamName: _awayCtrl.text.trim(),
      liga: _ligaCtrl.text.trim().isEmpty ? null : _ligaCtrl.text.trim(),
      spieltag:
          _spieltagCtrl.text.trim().isEmpty ? null : _spieltagCtrl.text.trim(),
      createdAt: widget.game.createdAt,
    );
    await ref.read(gameRepositoryProvider).updateGame(updatedGame);
    ref.invalidate(gamesProvider);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LiveScreen(game: updatedGame)),
      );
    }
  }

  @override
  void dispose() {
    _homeCtrl.dispose();
    _awayCtrl.dispose();
    _locationCtrl.dispose();
    _ligaCtrl.dispose();
    _spieltagCtrl.dispose();
    super.dispose();
  }
}

class _ImportWarningBanner extends StatelessWidget {
  final List<String> warnings;
  final VoidCallback onDismiss;

  const _ImportWarningBanner({required this.warnings, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.amber.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber, color: Colors.amber.shade800, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nicht importiert:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    warnings.join(', '),
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                  ),
                  Text(
                    'Bitte manuell ergänzen.',
                    style: TextStyle(color: Colors.amber.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              color: Colors.amber.shade800,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
}

class _SquadInput extends StatefulWidget {
  final List<int> numbers;
  final Color teamColor;
  final void Function(int) onAdd;
  final void Function(int) onRemove;

  const _SquadInput({
    required this.numbers,
    required this.teamColor,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_SquadInput> createState() => _SquadInputState();
}

class _SquadInputState extends State<_SquadInput> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Rückennummer (1–99)',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final n = int.tryParse(_ctrl.text);
                if (n != null && n >= 1 && n <= 99) {
                  widget.onAdd(n);
                  _ctrl.clear();
                }
              },
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
    super.dispose();
  }
}
