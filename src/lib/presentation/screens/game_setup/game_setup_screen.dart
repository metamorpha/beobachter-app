import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pressebericht_csv_parser.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/enums/kit_color.dart';
import '../../../domain/enums/team_side.dart';
import '../../providers/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/form_factor.dart';
import '../../theme/kit_colors.dart';
import '../../widgets/kit_color_picker.dart';
import '../../widgets/squad_input.dart';
import '../../widgets/team_dot.dart';
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
  late TeamKits _kits;
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
    _kits = TeamKits.fromGame(widget.game);
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
    final homeColor = _kits.color(context, TeamSide.home);
    final awayColor = _kits.color(context, TeamSide.away);
    final gameData = _SetupCard(
      title: 'Spieldaten',
      icon: Icons.info_outline_rounded,
      children: [
        TextField(
          key: const Key('tf_home_team'),
          controller: _homeCtrl,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Heimmannschaft',
            prefixIcon: Center(
              widthFactor: 1,
              child: TeamDot(color: homeColor, size: 12),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        TextField(
          key: const Key('tf_away_team'),
          controller: _awayCtrl,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Gastmannschaft',
            prefixIcon: Center(
              widthFactor: 1,
              child: TeamDot(color: awayColor, size: 12),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _ligaCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Liga (optional)'),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _spieltagCtrl,
                decoration: const InputDecoration(
                  labelText: 'Spieltag (optional)',
                ),
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        TextField(
          controller: _locationCtrl,
          decoration: const InputDecoration(
            labelText: 'Spielort (optional)',
            prefixIcon: Icon(Icons.place_outlined),
          ),
        ),
      ],
    );

    final squads = _SetupCard(
      title: 'Aufstellungen',
      icon: Icons.groups_outlined,
      children: [
        _SectionTitle('Aufstellung Heim', color: homeColor),
        KitColorPicker(
          team: TeamSide.home,
          selected: _kits.home,
          onSelected: (k) => _selectKit(TeamSide.home, k),
        ),
        const SizedBox(height: AppSpacing.m),
        SquadInput(
          numbers: _homeNumbers,
          teamColor: homeColor,
          onAdd: (n) => _addNumber(TeamSide.home, n),
          onRemove: (n) => _removeNumber(TeamSide.home, n),
        ),
        const SizedBox(height: AppSpacing.xl),
        _SectionTitle('Aufstellung Gast', color: awayColor),
        KitColorPicker(
          team: TeamSide.away,
          selected: _kits.away,
          onSelected: (k) => _selectKit(TeamSide.away, k),
        ),
        const SizedBox(height: AppSpacing.m),
        SquadInput(
          numbers: _awayNumbers,
          teamColor: awayColor,
          onAdd: (n) => _addNumber(TeamSide.away, n),
          onRemove: (n) => _removeNumber(TeamSide.away, n),
        ),
        if (_kits.clash) ...[
          const SizedBox(height: AppSpacing.l),
          const KitClashHint(),
        ],
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Spiel einrichten')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              // Smartphone: schmalere Ränder (US-703)
              padding: EdgeInsets.all(
                FormFactor.isPhone(context) ? AppSpacing.l : AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ImportCard(onTap: _onImportTap),
                  if (_importWarnings.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.m),
                    _ImportWarningBanner(
                      warnings: _importWarnings,
                      onDismiss: () => setState(() => _importWarnings = []),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.l),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Querformat: Spieldaten links, Aufstellungen rechts
                      if (constraints.maxWidth < 840) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            gameData,
                            const SizedBox(height: AppSpacing.l),
                            squads,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: gameData),
                          const SizedBox(width: AppSpacing.l),
                          Expanded(child: squads),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Fest sichtbare Startleiste unten rechts (US-604)
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.m,
              AppSpacing.xl,
              AppSpacing.l,
            ),
            decoration: BoxDecoration(
              color: context.scheme.surface,
              border: Border(
                top: BorderSide(color: context.scheme.outlineVariant),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  key: const Key('btn_start_game'),
                  style: FilledButton.styleFrom(
                    // Smartphone: volle Breite (US-703)
                    minimumSize: Size(
                      FormFactor.isPhone(context) ? double.infinity : 260,
                      AppSizes.primaryAction,
                    ),
                    textStyle: context.text.labelLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: const Text('Spiel starten'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onImportTap() async {
    final hasData =
        _homeCtrl.text.isNotEmpty ||
        _awayCtrl.text.isNotEmpty ||
        _homeNumbers.isNotEmpty ||
        _awayNumbers.isNotEmpty;

    if (hasData) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Daten überschreiben?'),
          content: const Text(
            'Der Import überschreibt alle vorhandenen Spieldaten. Fortfahren?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
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
    // FileType.custom mit allowedExtensions: ['csv'] graut auf macOS (Sandbox +
    // UTI-Filterung) alle Dateien aus. FileType.any + manuelle Extension-Prüfung
    // ist das zuverlässige Cross-Platform-Workaround.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if ((file.extension ?? '').toLowerCase() != 'csv') {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Falsches Dateiformat'),
          content: const Text(
            'Bitte eine CSV-Datei aus dem DFB/FLVW-Pressebericht auswählen.',
          ),
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

    final bytes = file.bytes;
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
    await repo.saveSquad(
      widget.game.id,
      TeamSide.home,
      importResult.homeNumbers,
    );
    await repo.saveSquad(
      widget.game.id,
      TeamSide.away,
      importResult.awayNumbers,
    );

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

    // Spieldaten sofort persistieren — Aufstellungen werden oben bereits via
    // saveSquad gespeichert; ohne diesen updateGame-Aufruf gingen Teamnamen,
    // Ort, Liga usw. beim Zurücknavigieren ohne "Spiel starten" verloren.
    final importedGame = Game(
      id: widget.game.id,
      date: importResult.date ?? widget.game.date,
      kickoffTime: widget.game.kickoffTime,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      homeTeamName: _homeCtrl.text.trim(),
      awayTeamName: _awayCtrl.text.trim(),
      liga: _ligaCtrl.text.trim().isEmpty ? null : _ligaCtrl.text.trim(),
      spieltag: _spieltagCtrl.text.trim().isEmpty
          ? null
          : _spieltagCtrl.text.trim(),
      createdAt: widget.game.createdAt,
      homeKitColor: _kits.home,
      awayKitColor: _kits.away,
    );
    await ref.read(gameRepositoryProvider).updateGame(importedGame);
    ref.invalidate(gamesProvider);
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
    await repo.saveSquad(
      widget.game.id,
      team,
      team == TeamSide.home ? _homeNumbers : _awayNumbers,
    );
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
    await repo.saveSquad(
      widget.game.id,
      team,
      team == TeamSide.home ? _homeNumbers : _awayNumbers,
    );
  }

  /// Wie die Rückennummern sofort gespeichert (US-111).
  Future<void> _selectKit(TeamSide team, KitColor kit) async {
    setState(() {
      _kits = team == TeamSide.home
          ? TeamKits(home: kit, away: _kits.away)
          : TeamKits(home: _kits.home, away: kit);
    });
    await ref
        .read(gameRepositoryProvider)
        .updateKitColor(widget.game.id, team, kit);
    ref.invalidate(gameProvider(widget.game.id));
    ref.invalidate(gamesProvider);
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
      spieltag: _spieltagCtrl.text.trim().isEmpty
          ? null
          : _spieltagCtrl.text.trim(),
      createdAt: widget.game.createdAt,
      homeKitColor: _kits.home,
      awayKitColor: _kits.away,
    );
    await ref.read(gameRepositoryProvider).updateGame(updatedGame);
    ref.invalidate(gameProvider(widget.game.id));
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

class _ImportCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ImportCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.scheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.l),
        side: BorderSide(color: context.scheme.primary.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.scheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Icon(
                  Icons.upload_file_rounded,
                  color: context.scheme.onPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aus Pressebericht importieren',
                      style: context.text.titleMedium?.copyWith(
                        color: context.scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Spieldaten und Aufstellungen aus der CSV-Datei '
                      'des DFB/FLVW-Presseberichts übernehmen',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.scheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SetupCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          FormFactor.isPhone(context) ? AppSpacing.l : AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: context.scheme.primary),
                const SizedBox(width: AppSpacing.s),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ImportWarningBanner extends StatelessWidget {
  final List<String> warnings;
  final VoidCallback onDismiss;

  const _ImportWarningBanner({required this.warnings, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.warningContainer,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: c.warning.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.xs,
        AppSpacing.m,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.warning_amber_rounded, color: c.warning),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nicht importiert:',
                  style: context.text.titleSmall?.copyWith(
                    color: c.onWarningContainer,
                  ),
                ),
                Text(
                  warnings.join(', '),
                  style: context.text.bodyMedium?.copyWith(
                    color: c.onWarningContainer,
                  ),
                ),
                Text(
                  'Bitte manuell ergänzen.',
                  style: context.text.bodyMedium?.copyWith(
                    color: c.onWarningContainer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Hinweis schließen',
            onPressed: onDismiss,
            color: c.onWarningContainer,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionTitle(this.text, {required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.s),
    child: Row(
      children: [
        TeamDot(color: color),
        const SizedBox(width: AppSpacing.s),
        Text(text, style: context.text.titleMedium),
      ],
    ),
  );
}
