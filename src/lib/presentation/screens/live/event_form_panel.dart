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
import '../../widgets/assessment_grid.dart';

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
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          _buildTypeSection(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _type == null
                  ? const _EmptyHint(key: ValueKey('empty'))
                  : SingleChildScrollView(
                      key: const ValueKey('fields'),
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                      child: _buildFields(),
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
      color: Colors.grey.shade800,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 13, color: Colors.white38),
          const SizedBox(width: 4),
          Text(
            _elapsedLabel,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isEditMode ? 'Ereignis bearbeiten' : 'Ereignis erfassen',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            key: const Key('btn_close_event_form'),
            onTap: widget.onClose,
            child: const Icon(Icons.close, color: Colors.white54, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Ereignistyp'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: EventType.values.map((t) {
              final sel = _type == t;
              return _SelectChip(
                key: Key('event_type_${t.name}'),
                label: t.label,
                selected: sel,
                selectedColor: Colors.green.shade700,
                onTap: () => setState(() {
                  _type = sel ? null : t;
                  if (!sel) {
                    // Torentscheidung: „Tor" vorausgewählt (US-214)
                    _decision =
                        t == EventType.goalDecision ? RefDecision.goal : null;
                    _card = null;
                  }
                  _clearScorer();
                }),
              );
            }).toList(),
          ),
          if (_type == EventType.custom) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customCtrl,
              decoration: InputDecoration(
                hintText: 'Bezeichnung',
                hintStyle: const TextStyle(color: Colors.white38),
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade800,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
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
          _sectionLabel('Spieler'),
          const SizedBox(height: 6),
          _playerRow(PlayerRole.fouler),
          const SizedBox(height: 6),
          _playerRow(PlayerRole.fouled),
        ],
        if (_type == EventType.goalDecision) ...[
          _divider(),
          _sectionLabel('Tor'),
          const SizedBox(height: 6),
          _goalSection(),
        ],
        _divider(),
        _sectionLabel('Entscheidung'),
        const SizedBox(height: 6),
        _decisionGrid(),
        _divider(),
        _cardAndCoachingRow(),
        _divider(),
        _sectionLabel('Bewertung'),
        const SizedBox(height: 6),
        AssessmentGrid(
          selected: _assessment,
          onChanged: (v) => setState(() => _assessment = v),
        ),
        _divider(),
        _noteToggle(),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
      );

  Widget _sectionLabel(String title) => Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      );

  Widget _decisionGrid() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: RefDecision.values.map((d) {
        final sel = _decision == d;
        return _SelectChip(
          key: Key('decision_${d.name}'),
          label: d.label,
          selected: sel,
          selectedColor: Colors.blue.shade700,
          width: 72,
          onTap: () => setState(() => _decision = sel ? null : d),
        );
      }).toList(),
    );
  }

  Widget _cardAndCoachingRow() {
    return Row(
      children: [
        _sectionLabel('Karte'),
        const SizedBox(width: 8),
        ...CardType.values.map((c) {
          final sel = _card == c;
          final color = c == CardType.yellow
              ? Colors.yellow.shade700
              : c == CardType.yellowRed
                  ? Colors.orange.shade700
                  : Colors.red.shade700;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _SelectChip(
              key: Key('card_${c.name}'),
              label: c.label,
              selected: sel,
              selectedColor: color,
              unselectedColor: color.withValues(alpha: 0.25),
              onTap: () => setState(() => _card = sel ? null : c),
            ),
          );
        }),
        const Spacer(),
        _sectionLabel('Coaching'),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => setState(() => _coachingFlag = !_coachingFlag),
          child: Icon(
            _coachingFlag ? Icons.star_rounded : Icons.star_outline_rounded,
            color: _coachingFlag ? Colors.amber : Colors.white30,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _playerRow(PlayerRole role) {
    final isFouler = role == PlayerRole.fouler;
    return _teamNumberRow(
      label: role.label,
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

    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ),
        _teamToggle(TeamSide.home, team, onTeamChanged, keyPrefix),
        const SizedBox(width: 4),
        _teamToggle(TeamSide.away, team, onTeamChanged, keyPrefix),
        const SizedBox(width: 6),
        SizedBox(
          width: 42,
          child: TextField(
            key: keyPrefix != null ? Key('${keyPrefix}_number') : null,
            controller: numberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '#',
              hintStyle: const TextStyle(color: Colors.white30),
              isDense: true,
              filled: true,
              fillColor: Colors.grey.shade800,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            onChanged: (v) => onNumberChanged(int.tryParse(v)),
          ),
        ),
        if (squadNumbers.isNotEmpty) ...[
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: squadNumbers.map((n) {
                  final isSel = number == n;
                  final teamColor =
                      team == TeamSide.home ? Colors.blue : Colors.red;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () {
                        final newVal = isSel ? null : n;
                        numberController?.text = newVal?.toString() ?? '';
                        onNumberChanged(newVal);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: isSel
                              ? teamColor
                              : teamColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                          border: isSel
                              ? Border.all(color: Colors.white, width: 1)
                              : null,
                        ),
                        child: Text(
                          '#$n',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _teamToggle(TeamSide side, TeamSide? selected,
      ValueChanged<TeamSide?> onChanged, String? keyPrefix) {
    final isSelected = selected == side;
    final color = side == TeamSide.home ? Colors.blue : Colors.red;
    return GestureDetector(
      key: keyPrefix != null ? Key('${keyPrefix}_team_${side.name}') : null,
      onTap: () => onChanged(isSelected ? null : side),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          side.label,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
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
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 54),
          child: _SelectChip(
            key: const Key('toggle_own_goal'),
            label: '⚽ Eigentor',
            selected: _ownGoal,
            selectedColor: Colors.deepOrange.shade700,
            onTap: () => setState(() => _ownGoal = !_ownGoal),
          ),
        ),
        const SizedBox(height: 8),
        _goalPreview(),
      ],
    );
  }

  /// Zeigt vor dem Speichern, wem das Tor gutgeschrieben wird.
  Widget _goalPreview() {
    // Im Edit-Modus den bisherigen Beitrag dieses Ereignisses herausrechnen
    final events = ref.watch(eventsProvider(widget.gameId)).valueOrNull ?? [];
    final base = Score.fromEvents(
        events.where((e) => e.id != widget.initialEvent?.id).toList());

    final scorer = _scorerTeam;
    final String text;
    final Color color;
    if (_decision != RefDecision.goal) {
      text = 'Tor aberkannt – Spielstand bleibt ${base.label}';
      color = Colors.white38;
    } else if (scorer == null) {
      text = 'Team wählen, damit das Tor zählt';
      color = Colors.orange.shade300;
    } else {
      final forTeam = _ownGoal ? scorer.opponent : scorer;
      final after = base.plus(forTeam).label;
      final nr = _scorerNumber != null ? '#$_scorerNumber ' : '';
      text = _ownGoal
          ? 'Eigentor $nr(${scorer.label}) → Tor für '
              '${forTeam.label.toUpperCase()} · $after'
          : 'Tor für ${forTeam.label.toUpperCase()}'
              '${_scorerNumber != null ? ' · #$_scorerNumber' : ''} → $after';
      color = Colors.green.shade300;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        key: const Key('goal_preview'),
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _noteToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _noteExpanded = !_noteExpanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _noteExpanded ? Icons.expand_less : Icons.add,
                  color: Colors.white38,
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Notiz',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        if (_noteExpanded) ...[
          const SizedBox(height: 6),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Szenennotiz …',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.grey.shade800,
              contentPadding: const EdgeInsets.all(10),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          key: const Key('btn_save_event'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _canSave ? Colors.green.shade600 : Colors.grey.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _canSave ? _save : null,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text(
            _isEditMode ? 'Änderungen speichern' : 'Speichern',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_type == null || _saving) return;
    setState(() => _saving = true);

    final players = <EventPlayer>[];
    if (_foulerTeam != null && _foulerNumber != null) {
      players.add(EventPlayer(
        id: '',
        eventId: '',
        role: PlayerRole.fouler,
        team: _foulerTeam!,
        jerseyNumber: _foulerNumber!,
      ));
    }
    if (_fouledTeam != null && _fouledNumber != null) {
      players.add(EventPlayer(
        id: '',
        eventId: '',
        role: PlayerRole.fouled,
        team: _fouledTeam!,
        jerseyNumber: _fouledNumber!,
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
    return const Center(
      child: Text(
        'Typ auswählen, dann speichern',
        style: TextStyle(color: Colors.white24, fontSize: 12),
      ),
    );
  }
}

// ── Wiederverwendbarer selektierbarer Chip ────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color? unselectedColor;
  final VoidCallback onTap;
  final double? width;

  const _SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.selectedColor,
    this.unselectedColor,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? selectedColor
        : (unselectedColor ?? Colors.grey.shade700);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Material(
        color: bg,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1.5),
                  )
                : null,
            alignment: width != null ? Alignment.center : null,
            child: Text(
              label,
              textAlign: width != null ? TextAlign.center : null,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
