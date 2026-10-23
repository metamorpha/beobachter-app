import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/event_player.dart';
import '../../../domain/entities/score.dart';
import '../../../domain/enums/assessment.dart';
import '../../../domain/enums/card_type.dart';
import '../../../domain/enums/event_type.dart';
import '../../../domain/enums/game_phase.dart';
import '../../../domain/enums/player_role.dart';
import '../../../domain/enums/ref_decision.dart';
import '../../../domain/enums/team_side.dart';
import '../../providers/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/event_type_style.dart';
import '../../widgets/assessment_grid.dart';
import '../../widgets/section_header.dart';
import '../../widgets/select_tile.dart';

class EventFormPanel extends ConsumerStatefulWidget {
  final String gameId;
  final double locationX;
  final double locationY;
  final VoidCallback onClose;
  final void Function(Event) onSaved;
  final Event? initialEvent;

  /// Spieler des zu bearbeitenden Events (nur im Edit-Modus befüllt).
  final List<EventPlayer> initialPlayers;

  const EventFormPanel({
    super.key,
    required this.gameId,
    required this.locationX,
    required this.locationY,
    required this.onClose,
    required this.onSaved,
    this.initialEvent,
    this.initialPlayers = const [],
  });

  @override
  ConsumerState<EventFormPanel> createState() => _EventFormPanelState();
}

class _EventFormPanelState extends ConsumerState<EventFormPanel> {
  late EventType? _type;
  late RefDecision? _decision;
  late CardType? _card;
  late Assessment? _assessment;
  late bool _coachingFlag;
  bool _noteExpanded = false;
  bool _saving = false;
  late int? _foulerNumber;
  late TeamSide? _foulerTeam;
  late int? _fouledNumber;
  late TeamSide? _fouledTeam;
  late TeamSide? _scorerTeam;
  late int? _scorerNumber;
  late bool _ownGoal;

  // Zeitstempel wird beim Öffnen eingefroren (UX-Spec: Tap-Zeitpunkt, nicht Save-Zeitpunkt)
  late final int _elapsedMs;
  late final GamePhase _gamePhase;

  late final TextEditingController _noteCtrl;
  late final TextEditingController _customCtrl;
  late final TextEditingController _scorerCtrl;

  bool get _isEditMode => widget.initialEvent != null;
  bool get _canSave => _type != null && !_saving;

  bool get _showPlayerSection =>
      _type != null &&
      const [
        EventType.footFoul,
        EventType.bodyFoul,
        EventType.handball,
        EventType.unsporting,
        EventType.violent,
      ].contains(_type);

  @override
  void initState() {
    super.initState();
    final e = widget.initialEvent;
    _type = e?.type;
    _decision = e?.refDecision;
    _card = e?.card;
    _assessment = e?.assessment;
    _coachingFlag = e?.coachingFlag ?? false;
    _noteExpanded = e?.sceneNote != null;
    _noteCtrl = TextEditingController(text: e?.sceneNote ?? '');
    _customCtrl = TextEditingController(
        text: e?.type == EventType.custom ? (e?.customTypeLabel ?? '') : '');

    // Spieler aus initialPlayers vorausfüllen (Edit-Modus)
    final fouler =
        widget.initialPlayers.where((p) => p.role == PlayerRole.fouler).firstOrNull;
    final fouled =
        widget.initialPlayers.where((p) => p.role == PlayerRole.fouled).firstOrNull;
    _foulerTeam = fouler?.team;
    _foulerNumber = fouler?.jerseyNumber;
    _fouledTeam = fouled?.team;
    _fouledNumber = fouled?.jerseyNumber;

    _scorerTeam = e?.goalScorerTeam;
    _scorerNumber = e?.goalScorerNumber;
    _ownGoal = e?.ownGoal ?? false;
    _scorerCtrl =
        TextEditingController(text: _scorerNumber?.toString() ?? '');

    if (_isEditMode) {
      _elapsedMs = e!.elapsedMs;
      _gamePhase = e.gamePhase;
    } else {
      final timer = ref.read(timerServiceProvider(widget.gameId));
      _elapsedMs = timer.currentMs;
      _gamePhase = timer.current.phase;
    }
  }

  String get _elapsedLabel {
    final totalSeconds = _elapsedMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Nur Kopf und Speichern stehen fest; Typen und Felder scrollen gemeinsam,
    // damit das Formular bei jeder Höhe und Breite passt (auch beim Einblenden).
    return ColoredBox(
      color: context.scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTypeSection(),
                  AnimatedSwitcher(
                    duration: AppMotion.of(context, AppMotion.fast),
                    child: _type == null
                        ? const _EmptyHint(key: ValueKey('empty'))
                        : Padding(
                            key: const ValueKey('fields'),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.l),
                            child: _buildFields(),
                          ),
                  ),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.scheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Container(
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
                  _elapsedLabel,
                  style: context.text.labelLarge?.copyWith(
                    color: context.scheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              _isEditMode ? 'Ereignis bearbeiten' : 'Ereignis erfassen',
              overflow: TextOverflow.ellipsis,
              style: context.text.titleMedium,
            ),
          ),
          IconButton(
            key: const Key('btn_close_event_form'),
            onPressed: widget.onClose,
            tooltip: 'Schließen',
            icon: Icon(
              Icons.close_rounded,
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Ereignistyp'),
          const SizedBox(height: AppSpacing.s),
          _Grid(
            minTileWidth: 140,
            maxColumns: 5,
            children: EventType.values.map((t) {
              final sel = _type == t;
              return SelectTile(
                key: Key('event_type_${t.name}'),
                label: t.label,
                icon: t.icon,
                horizontal: true,
                dense: true,
                selected: sel,
                color: context.scheme.primary,
                onTap: () => setState(() {
                  _type = sel ? null : t;
                  if (!sel) {
                    // Torentscheidung: „Tor" vorausgewählt (US-214)
                    _decision = t == EventType.goalDecision
                        ? RefDecision.goal
                        : null;
                    _card = null;
                  }
                  _clearScorer();
                }),
              );
            }).toList(),
          ),
          if (_type == EventType.custom) ...[
            const SizedBox(height: AppSpacing.s),
            TextField(
              controller: _customCtrl,
              decoration: const InputDecoration(hintText: 'Bezeichnung'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showPlayerSection) ...[
          _divider(),
          const SectionHeader('Spieler'),
          const SizedBox(height: AppSpacing.s),
          _playerRow(PlayerRole.fouler),
          const SizedBox(height: AppSpacing.s),
          _playerRow(PlayerRole.fouled),
        ],
        if (_type == EventType.goalDecision) ...[
          _divider(),
          const SectionHeader('Tor'),
          const SizedBox(height: AppSpacing.s),
          _goalSection(),
        ],
        _divider(),
        const SectionHeader('Entscheidung'),
        const SizedBox(height: AppSpacing.s),
        _decisionGrid(),
        _divider(),
        _cardAndCoachingRow(),
        _divider(),
        const SectionHeader('Bewertung'),
        const SizedBox(height: AppSpacing.s),
        AssessmentGrid(
          selected: _assessment,
          onChanged: (v) => setState(() => _assessment = v),
        ),
        _divider(),
        _noteToggle(),
      ],
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
    child: Divider(height: 1),
  );

  Widget _decisionGrid() {
    return _Grid(
      minTileWidth: 76,
      maxColumns: 6,
      children: RefDecision.values.map((d) {
        final sel = _decision == d;
        return SelectTile(
          key: Key('decision_${d.name}'),
          label: d.label,
          dense: true,
          selected: sel,
          color: context.scheme.inverseSurface,
          onTap: () => setState(() => _decision = sel ? null : d),
        );
      }).toList(),
    );
  }

  Widget _cardAndCoachingRow() {
    final colors = context.colors;
    // Bricht bei schmaler Breite um (z. B. während das Panel einblendet)
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.xs),
                child: SectionHeader('Karte'),
              ),
              ...CardType.values.map((c) {
                final sel = _card == c;
                final color = colors.card(c);
                return SelectTile(
                  key: Key('card_${c.name}'),
                  label: c.label,
                  dense: true,
                  width: 64,
                  selected: sel,
                  color: color,
                  unselectedColor: Color.alphaBlend(
                    color.withValues(alpha: 0.18),
                    context.scheme.surface,
                  ),
                  onTap: () => setState(() => _card = sel ? null : c),
                );
              }),
            ],
          ),
        ),
        const SectionHeader('Coaching'),
        IconButton(
          tooltip: 'Für Coaching markieren',
          onPressed: () => setState(() => _coachingFlag = !_coachingFlag),
          iconSize: 30,
          constraints: const BoxConstraints(
            minWidth: AppSizes.liveTap,
            minHeight: AppSizes.liveTap,
          ),
          icon: Icon(
            _coachingFlag ? Icons.star_rounded : Icons.star_outline_rounded,
            color: _coachingFlag
                ? colors.coaching
                : context.scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _playerRow(PlayerRole role) {
    final isFouler = role == PlayerRole.fouler;
    return _teamNumberRow(
      label: role.label,
      keyPrefix: role.name,
      team: isFouler ? _foulerTeam : _fouledTeam,
      number: isFouler ? _foulerNumber : _fouledNumber,
      onTeamChanged: (t) => setState(() {
        if (isFouler) {
          _foulerTeam = t;
          _foulerNumber = null;
        } else {
          _fouledTeam = t;
          _fouledNumber = null;
        }
      }),
      onNumberChanged: (n) => setState(() {
        if (isFouler) {
          _foulerNumber = n;
        } else {
          _fouledNumber = n;
        }
      }),
    );
  }

  /// Team-Auswahl + Rückennummer (Freitext und Kader-Chips) — gemeinsam für
  /// Fouler, Gefoulter und Torschütze.
  Widget _teamNumberRow({
    required String label,
    required TeamSide? team,
    required int? number,
    required ValueChanged<TeamSide?> onTeamChanged,
    required ValueChanged<int?> onNumberChanged,
    TextEditingController? numberController,
    String? keyPrefix,
  }) {
    final homeAsync = ref.watch(homeSquadProvider(widget.gameId));
    final awayAsync = ref.watch(awaySquadProvider(widget.gameId));
    final homeNumbers = homeAsync.valueOrNull ?? [];
    final awayNumbers = awayAsync.valueOrNull ?? [];

    final squadNumbers = team == TeamSide.home
        ? homeNumbers
        : team == TeamSide.away
        ? awayNumbers
        : <int>[];
    final teamColor = team != null ? context.colors.team(team) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.labelMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            _teamToggle(TeamSide.home, team, onTeamChanged, keyPrefix),
            const SizedBox(width: AppSpacing.xs),
            _teamToggle(TeamSide.away, team, onTeamChanged, keyPrefix),
            const SizedBox(width: AppSpacing.s),
            SizedBox(
              width: 60,
              child: TextField(
                key: keyPrefix != null ? Key('${keyPrefix}_number') : null,
                controller: numberController,
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
                onChanged: (v) => onNumberChanged(int.tryParse(v)),
              ),
            ),
            if (squadNumbers.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: _FadeEdge(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: AppSpacing.xl),
                    child: Row(
                      children: squadNumbers.map((n) {
                        final isSel = number == n;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: SelectTile(
                            key: keyPrefix != null
                                ? Key('${keyPrefix}_chip_$n')
                                : null,
                            label: '#$n',
                            dense: true,
                            width: AppSizes.tap + 4,
                            minHeight: AppSizes.liveTap,
                            selected: isSel,
                            color: teamColor,
                            onTap: () {
                              final newVal = isSel ? null : n;
                              numberController?.text = newVal?.toString() ?? '';
                              onNumberChanged(newVal);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _teamToggle(
    TeamSide side,
    TeamSide? selected,
    ValueChanged<TeamSide?> onChanged,
    String? keyPrefix,
  ) {
    final isSelected = selected == side;
    return SelectTile(
      key: keyPrefix != null ? Key('${keyPrefix}_team_${side.name}') : null,
      label: side.label,
      dense: true,
      width: 64,
      selected: isSelected,
      color: context.colors.team(side),
      onTap: () => onChanged(isSelected ? null : side),
    );
  }

  // ── Tor-Abschnitt (US-214) ──────────────────────────────────────────────────

  void _clearScorer() {
    _scorerTeam = null;
    _scorerNumber = null;
    _ownGoal = false;
    _scorerCtrl.clear();
  }

  Widget _goalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _teamNumberRow(
          label: 'Torschütze',
          keyPrefix: 'scorer',
          team: _scorerTeam,
          number: _scorerNumber,
          numberController: _scorerCtrl,
          onTeamChanged: (t) => setState(() {
            _scorerTeam = t;
            _scorerNumber = null;
            _scorerCtrl.clear();
          }),
          onNumberChanged: (n) => setState(() => _scorerNumber = n),
        ),
        const SizedBox(height: AppSpacing.s),
        Align(
          alignment: Alignment.centerLeft,
          child: SelectTile(
            key: const Key('toggle_own_goal'),
            label: '⚽ Eigentor',
            dense: true,
            selected: _ownGoal,
            color: context.colors.yellowRedCard,
            onTap: () => setState(() => _ownGoal = !_ownGoal),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        _goalPreview(),
      ],
    );
  }

  /// Zeigt vor dem Speichern, wem das Tor gutgeschrieben wird.
  Widget _goalPreview() {
    // Im Edit-Modus den bisherigen Beitrag dieses Ereignisses herausrechnen
    final events = ref.watch(eventsProvider(widget.gameId)).valueOrNull ?? [];
    final base = Score.fromEvents(
      events.where((e) => e.id != widget.initialEvent?.id).toList(),
    );

    final scorer = _scorerTeam;
    final String text;
    final Color color;
    final IconData icon;
    if (_decision != RefDecision.goal) {
      text = 'Tor aberkannt – Spielstand bleibt ${base.label}';
      color = context.scheme.onSurfaceVariant;
      icon = Icons.block_rounded;
    } else if (scorer == null) {
      text = 'Team wählen, damit das Tor zählt';
      color = context.colors.warning;
      icon = Icons.info_outline_rounded;
    } else {
      final forTeam = _ownGoal ? scorer.opponent : scorer;
      final after = base.plus(forTeam).label;
      final nr = _scorerNumber != null ? '#$_scorerNumber ' : '';
      text = _ownGoal
          ? 'Eigentor $nr(${scorer.label}) → Tor für '
                '${forTeam.label.toUpperCase()} · $after'
          : 'Tor für ${forTeam.label.toUpperCase()}'
                '${_scorerNumber != null ? ' · #$_scorerNumber' : ''} → $after';
      color = context.colors.correct;
      icon = Icons.check_circle_outline_rounded;
    }

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
          Icon(icon, size: 18, color: color),
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

  Widget _noteToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _noteExpanded = !_noteExpanded),
          style: TextButton.styleFrom(
            foregroundColor: context.scheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
          ),
          icon: Icon(
            _noteExpanded ? Icons.expand_less_rounded : Icons.add_rounded,
            size: 20,
          ),
          label: const Text('Notiz'),
        ),
        AnimatedSize(
          duration: AppMotion.of(context, AppMotion.medium),
          curve: AppMotion.curve,
          alignment: Alignment.topCenter,
          child: _noteExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s),
                  child: TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Szenennotiz …',
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.l,
      ),
      decoration: BoxDecoration(
        color: context.scheme.surface,
        border: Border(top: BorderSide(color: context.scheme.outlineVariant)),
      ),
      child: FilledButton.icon(
        key: const Key('btn_save_event'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.primaryAction),
          textStyle: context.text.labelLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: _canSave ? _save : null,
        icon: const Icon(Icons.check_rounded, size: 24),
        label: Text(_isEditMode ? 'Änderungen speichern' : 'Speichern'),
      ),
    );
  }

  Future<void> _save() async {
    if (_type == null || _saving) return;
    setState(() => _saving = true);

    final players = <EventPlayer>[];
    // Team wird auch ohne Rückennummer gespeichert (US-404)
    if (_foulerTeam != null) {
      players.add(EventPlayer(
        id: '',
        eventId: '',
        role: PlayerRole.fouler,
        team: _foulerTeam!,
        jerseyNumber: _foulerNumber,
      ));
    }
    if (_fouledTeam != null) {
      players.add(EventPlayer(
        id: '',
        eventId: '',
        role: PlayerRole.fouled,
        team: _fouledTeam!,
        jerseyNumber: _fouledNumber,
      ));
    }

    final repo = ref.read(eventRepositoryProvider);
    final sceneNote = _noteCtrl.text.isEmpty ? null : _noteCtrl.text;
    final customLabel =
        _type == EventType.custom ? (_customCtrl.text.isEmpty ? null : _customCtrl.text) : null;

    final isGoal = _type == EventType.goalDecision;

    if (_isEditMode) {
      // Explizit aufgebaut statt copyWith, damit Felder auch auf null
      // zurückgesetzt werden können (z. B. Torschütze entfernt).
      final initial = widget.initialEvent!;
      final updated = Event(
        id: initial.id,
        gameId: initial.gameId,
        elapsedMs: initial.elapsedMs,
        gamePhase: initial.gamePhase,
        type: _type!,
        customTypeLabel: customLabel,
        locationX: initial.locationX,
        locationY: initial.locationY,
        refDecision: _decision,
        card: _card,
        assessment: _assessment,
        sceneNote: sceneNote,
        coachingFlag: _coachingFlag,
        coachingNote: initial.coachingNote,
        goalScorerTeam: isGoal ? _scorerTeam : null,
        goalScorerNumber: isGoal ? _scorerNumber : null,
        ownGoal: isGoal && _ownGoal,
        createdAt: initial.createdAt,
      );
      await repo.updateEvent(updated, players);
      widget.onSaved(updated);
    } else {
      final savedEvent = await repo.createEvent(
        Event(
          id: '',
          gameId: widget.gameId,
          elapsedMs: _elapsedMs,
          gamePhase: _gamePhase,
          type: _type!,
          customTypeLabel: customLabel,
          locationX: widget.locationX,
          locationY: widget.locationY,
          refDecision: _decision,
          card: _card,
          assessment: _assessment,
          sceneNote: sceneNote,
          coachingFlag: _coachingFlag,
          goalScorerTeam: isGoal ? _scorerTeam : null,
          goalScorerNumber: isGoal ? _scorerNumber : null,
          ownGoal: isGoal && _ownGoal,
          createdAt: DateTime.now(),
        ),
        players,
      );
      widget.onSaved(savedEvent);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _customCtrl.dispose();
    _scorerCtrl.dispose();
    super.dispose();
  }
}

// ── Platzhalter wenn kein Typ gewählt ────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined,
              size: 32, color: context.scheme.outline),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Typ auswählen, dann speichern',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium
                ?.copyWith(color: context.scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Ausblend-Rand als Hinweis auf weitere Rückennummern ──────────────────────

class _FadeEdge extends StatelessWidget {
  final Widget child;

  const _FadeEdge({required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        colors: [Colors.black, Colors.black, Colors.transparent],
        stops: [0, 0.88, 1],
      ).createShader(rect),
      child: child,
    );
  }
}

// ── Raster mit gleich breiten Kacheln ────────────────────────────────────────

/// Verteilt Kacheln gleich breit auf so viele Spalten, wie die Breite bei
/// [minTileWidth] zulässt (höchstens [maxColumns]).
class _Grid extends StatelessWidget {
  final double minTileWidth;
  final int maxColumns;
  final List<Widget> children;

  const _Grid({
    required this.minTileWidth,
    required this.maxColumns,
    required this.children,
  });

  static const _gap = AppSpacing.s - 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = ((w + _gap) / (minTileWidth + _gap)).floor().clamp(
          1,
          maxColumns,
        );
        final tileW = (w - _gap * (cols - 1)) / cols;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final c in children) SizedBox(width: tileW, child: c),
          ],
        );
      },
    );
  }
}
