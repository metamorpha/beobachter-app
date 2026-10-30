import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/kit_color.dart';
import '../../domain/enums/team_side.dart';
import '../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/form_factor.dart';
import '../theme/kit_colors.dart';
import 'kit_color_picker.dart';
import 'phone_dialog.dart';
import 'squad_input.dart';
import 'team_dot.dart';

/// Aufstellungen und Trikotfarben beider Teams während des Spiels korrigieren
/// (US-110, US-111). Jede Änderung wird sofort gespeichert; „Fertig" schließt
/// nur.
class SquadEditDialog extends ConsumerStatefulWidget {
  final String gameId;

  const SquadEditDialog({super.key, required this.gameId});

  static Future<void> show(BuildContext context, String gameId) =>
      showAppDialog<void>(
        context,
        builder: (_) => SquadEditDialog(gameId: gameId),
      );

  @override
  ConsumerState<SquadEditDialog> createState() => _SquadEditDialogState();
}

class _SquadEditDialogState extends ConsumerState<SquadEditDialog> {
  final Map<TeamSide, List<int>> _numbers = {
    TeamSide.home: [],
    TeamSide.away: [],
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(squadRepositoryProvider);
    final home = await repo.getSquad(widget.gameId, TeamSide.home);
    final away = await repo.getSquad(widget.gameId, TeamSide.away);
    if (!mounted) return;
    setState(() {
      _numbers[TeamSide.home] = [...home]..sort();
      _numbers[TeamSide.away] = [...away]..sort();
    });
  }

  Future<void> _save(TeamSide team, List<int> numbers) async {
    setState(() => _numbers[team] = numbers);
    await ref
        .read(squadRepositoryProvider)
        .saveSquad(widget.gameId, team, numbers);
    // Kader-Chips im Ereignisformular aktualisieren
    ref.invalidate(
      team == TeamSide.home
          ? homeSquadProvider(widget.gameId)
          : awaySquadProvider(widget.gameId),
    );
  }

  void _add(TeamSide team, int number) {
    final current = _numbers[team]!;
    if (current.contains(number)) return;
    _save(team, [...current, number]..sort());
  }

  void _remove(TeamSide team, int number) =>
      _save(team, _numbers[team]!.where((n) => n != number).toList());

  Future<void> _selectKit(TeamSide team, KitColor kit) async {
    await ref
        .read(gameRepositoryProvider)
        .updateKitColor(widget.gameId, team, kit);
    // Kopfzeile, Tor-Buttons und Chips färben sich über teamKitsProvider neu
    ref.invalidate(gameProvider(widget.gameId));
    ref.invalidate(gamesProvider);
  }

  Widget _teamColumn(TeamSide team, TeamKits kits) {
    final isHome = team == TeamSide.home;
    final color = kits.color(context, team);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TeamDot(color: color),
              const SizedBox(width: AppSpacing.s),
              Text(isHome ? 'Heim' : 'Gast', style: context.text.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          KitColorPicker(
            team: team,
            selected: kits.of(team),
            onSelected: (k) => _selectKit(team, k),
          ),
          const SizedBox(height: AppSpacing.m),
          SquadInput(
            keyPrefix: 'squad_${team.name}',
            numbers: _numbers[team]!,
            teamColor: color,
            onAdd: (n) => _add(team, n),
            onRemove: (n) => _remove(team, n),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kits = ref.watch(teamKitsProvider(widget.gameId)) ?? TeamKits.none;
    final teams = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _teamColumn(TeamSide.home, kits),
            const SizedBox(width: AppSpacing.xl),
            _teamColumn(TeamSide.away, kits),
          ],
        ),
        if (kits.clash) ...[
          const SizedBox(height: AppSpacing.l),
          const KitClashHint(),
        ],
      ],
    );
    final done = FilledButton(
      key: const Key('btn_squad_done'),
      style: FilledButton.styleFrom(minimumSize: const Size(140, 52)),
      onPressed: () => Navigator.pop(context),
      child: const Text('Fertig'),
    );

    // Smartphone: Vollbild statt Dialog fester Breite (US-701)
    if (FormFactor.isPhone(context)) {
      return PhoneDialogFrame(
        title: const Text('Aufstellung'),
        body: teams,
        actions: [done],
      );
    }
    return AlertDialog(
      icon: Icon(Icons.groups_rounded, color: context.scheme.primary),
      title: const Text('Aufstellung'),
      content: SizedBox(width: 720, child: SingleChildScrollView(child: teams)),
      actions: [done],
    );
  }
}
