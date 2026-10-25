import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/goal.dart';
import '../../../domain/entities/score.dart';
import '../../../domain/enums/game_phase.dart';
import '../../../domain/enums/goal_kind.dart';
import '../../../domain/enums/team_side.dart';
import '../../providers/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/form_factor.dart';
import '../../widgets/phone_dialog.dart';
import '../../widgets/section_header.dart';
import '../../widgets/select_tile.dart';

/// Tor erfassen oder bearbeiten (US-215). Das Team steht durch den
/// gedrückten Button fest; Torart und Torschütze sind optional.
class GoalDialog extends ConsumerStatefulWidget {
  final String gameId;

  /// Team, dem das Tor gutgeschrieben wird.
  final TeamSide team;

  /// Beim Button-Tap eingefrorene Spielzeit und Phase.
  final int elapsedMs;
  final GamePhase gamePhase;

  final String? teamName;
  final Goal? initialGoal;

  const GoalDialog({
    super.key,
    required this.gameId,
    required this.team,
    required this.elapsedMs,
    required this.gamePhase,
    this.teamName,
    this.initialGoal,
  });

  /// Neues Tor — [elapsedMs] und [gamePhase] stammen vom Button-Tap.
  static Future<void> show(
    BuildContext context, {
    required String gameId,
    required TeamSide team,
    required int elapsedMs,
    required GamePhase gamePhase,
    String? teamName,
  }) => showAppDialog<void>(
    context,
    builder: (_) => GoalDialog(
      gameId: gameId,
      team: team,
      elapsedMs: elapsedMs,
      gamePhase: gamePhase,
      teamName: teamName,
    ),
  );

  /// Bestehendes Tor bearbeiten — Zeit bleibt unverändert.
  static Future<void> edit(
    BuildContext context,
    Goal goal, {
    String? teamName,
  }) => showAppDialog<void>(
    context,
    builder: (_) => GoalDialog(
      gameId: goal.gameId,
      team: goal.team,
      elapsedMs: goal.elapsedMs,
      gamePhase: goal.gamePhase,
      teamName: teamName,
      initialGoal: goal,
    ),
  );

  @override
  ConsumerState<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends ConsumerState<GoalDialog> {
  late GoalKind _kind;
  late int? _scorerNumber;
  late final TextEditingController _numberCtrl;
  bool _saving = false;

  bool get _isEditMode => widget.initialGoal != null;

  /// Beim Eigentor schießt die verteidigende Mannschaft das Tor.
  TeamSide get _scorerTeam =>
      _kind == GoalKind.ownGoal ? widget.team.opponent : widget.team;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialGoal?.kind ?? GoalKind.regular;
    _scorerNumber = widget.initialGoal?.scorerNumber;
    _numberCtrl = TextEditingController(text: _scorerNumber?.toString() ?? '');
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  void _setKind(GoalKind kind) {
    if (kind == _kind) return;
    setState(() {
      // Wechselt das Team des Torschützen, passt die Nummer nicht mehr
      if ((kind == GoalKind.ownGoal) != (_kind == GoalKind.ownGoal)) {
        _scorerNumber = null;
        _numberCtrl.clear();
      }
      _kind = kind;
    });
  }

  void _setNumber(int? n) {
    _numberCtrl.text = n?.toString() ?? '';
    setState(() => _scorerNumber = n);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = ref.read(goalRepositoryProvider);
    final initial = widget.initialGoal;
    final goal = Goal(
      id: initial?.id ?? '',
      gameId: widget.gameId,
      elapsedMs: widget.elapsedMs,
      gamePhase: widget.gamePhase,
      team: widget.team,
      scorerNumber: _scorerNumber,
      kind: _kind,
      createdAt: initial?.createdAt ?? DateTime.now(),
    );
    if (initial != null) {
      await repo.updateGoal(goal);
    } else {
      await repo.createGoal(goal);
    }
    ref.invalidate(goalsProvider(widget.gameId));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final teamColor = context.colors.team(widget.team);
    final title = Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: teamColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode
                    ? 'Tor bearbeiten'
                    : 'Tor für ${widget.team.label.toUpperCase()}',
                key: const Key('goal_dialog_title'),
              ),
              if (widget.teamName != null && widget.teamName!.isNotEmpty)
                Text(
                  widget.teamName!,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        _TimeChip(
          label: GamePhaseX.formatMs(widget.elapsedMs, widget.gamePhase),
        ),
      ],
    );
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Torart'),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            for (final k in GoalKind.values) ...[
              if (k != GoalKind.values.first)
                const SizedBox(width: AppSpacing.s),
              Expanded(
                child: SelectTile(
                  key: Key('goal_kind_${k.name}'),
                  label: k.label,
                  dense: true,
                  selected: _kind == k,
                  color: context.scheme.inverseSurface,
                  onTap: () => _setKind(k),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        _scorerSection(),
        const SizedBox(height: AppSpacing.l),
        _preview(),
      ],
    );
    final actions = [
      TextButton(
        key: const Key('btn_cancel_goal'),
        style: TextButton.styleFrom(minimumSize: const Size(120, 52)),
        onPressed: () => Navigator.pop(context),
        child: const Text('Abbrechen'),
      ),
      FilledButton.icon(
        key: const Key('btn_save_goal'),
        style: FilledButton.styleFrom(minimumSize: const Size(160, 52)),
        onPressed: _saving ? null : _save,
        icon: const Icon(Icons.check_rounded),
        label: Text(_isEditMode ? 'Änderungen speichern' : 'Speichern'),
      ),
    ];

    // Smartphone: Vollbild statt Dialog fester Breite (US-701)
    if (FormFactor.isPhone(context)) {
      return PhoneDialogFrame(title: title, body: body, actions: actions);
    }
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        0,
      ),
      title: title,
      content: SizedBox(width: 560, child: SingleChildScrollView(child: body)),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      actions: actions,
    );
  }

  Widget _scorerSection() {
    final scorerTeam = _scorerTeam;
    final numbers =
        ref
            .watch(
              scorerTeam == TeamSide.home
                  ? homeSquadProvider(widget.gameId)
                  : awaySquadProvider(widget.gameId),
            )
            .valueOrNull ??
        const <int>[];
    final color = context.colors.team(scorerTeam);
    final suffix = _kind == GoalKind.ownGoal ? ' · Eigentor' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Torschütze (${scorerTeam.label}$suffix)',
          key: const Key('goal_scorer_header'),
          trailing: Text(
            'optional',
            style: context.text.labelMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 64,
              child: TextField(
                key: const Key('goal_scorer_number'),
                controller: _numberCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '#',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.l,
                  ),
                ),
                style: context.text.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                onChanged: (v) =>
                    setState(() => _scorerNumber = int.tryParse(v)),
              ),
            ),
            if (numbers.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final n in numbers)
                      SelectTile(
                        key: Key('goal_scorer_chip_$n'),
                        label: '#$n',
                        dense: true,
                        width: AppSizes.tap + 4,
                        minHeight: AppSizes.tap,
                        selected: _scorerNumber == n,
                        color: color,
                        onTap: () => _setNumber(_scorerNumber == n ? null : n),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Zeigt vor dem Speichern das Ergebnis, z. B. „Tor für HEIM · #9 → 2 : 1".
  Widget _preview() {
    // Im Edit-Modus das bisherige Tor herausrechnen
    final goals = ref.watch(goalsProvider(widget.gameId)).valueOrNull ?? [];
    final base = Score.fromGoals(
      goals.where((g) => g.id != widget.initialGoal?.id).toList(),
    );
    final team = widget.team.label.toUpperCase();
    final after = base.plus(widget.team).label;
    final nr = _scorerNumber != null ? '#$_scorerNumber' : null;
    final text = switch (_kind) {
      GoalKind.ownGoal =>
        'Eigentor ${nr != null ? '$nr ' : ''}'
            '(${_scorerTeam.label}) → Tor für $team · $after',
      GoalKind.penalty =>
        'Tor für $team${nr != null ? ' · $nr' : ''} (Strafstoß) → $after',
      GoalKind.regular => 'Tor für $team${nr != null ? ' · $nr' : ''} → $after',
    };
    final color = context.colors.correct;

    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.fast),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s + 2,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: 0.10),
          context.scheme.surface,
        ),
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.sports_soccer, size: 18, color: color),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              text,
              key: const Key('goal_preview'),
              style: context.text.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;

  const _TimeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 16,
            color: context.scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.text.labelLarge?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
