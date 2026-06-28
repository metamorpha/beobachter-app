import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/event_player.dart';
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

  /// Wenn gesetzt, wird das Formular im Bearbeitungsmodus geöffnet.
  final Event? initialEvent;

  const EventFormPanel({
    super.key,
    required this.gameId,
    required this.locationX,
    required this.locationY,
    required this.onClose,
    required this.onSaved,
    this.initialEvent,
  });

  @override
  ConsumerState<EventFormPanel> createState() => _EventFormPanelState();
}

class _EventFormPanelState extends ConsumerState<EventFormPanel> {
  late EventType? _type;
  late String? _customLabel;
  late RefDecision? _decision;
  late CardType? _card;
  late Assessment? _assessment;
  late String? _sceneNote;
  bool _noteExpanded = false;
  bool _saving = false;
  late int? _foulerNumber;
  late TeamSide? _foulerTeam;
  late int? _fouledNumber;
  late TeamSide? _fouledTeam;

  late final TextEditingController _noteCtrl;
  late final TextEditingController _customCtrl;

  bool get _isEditMode => widget.initialEvent != null;
  bool get _canSave => _type != null && !_saving;

  @override
  void initState() {
    super.initState();
    final e = widget.initialEvent;
    _type = e?.type;
    _customLabel = e?.customTypeLabel;
    _decision = e?.refDecision;
    _card = e?.card;
    _assessment = e?.assessment;
    _sceneNote = e?.sceneNote;
    _noteExpanded = e?.sceneNote != null;
    _foulerNumber = null;
    _foulerTeam = null;
    _fouledNumber = null;
    _fouledTeam = null;
    _noteCtrl = TextEditingController(text: e?.sceneNote ?? '');
    _customCtrl = TextEditingController(
        text: e?.type == EventType.custom ? (e?.customTypeLabel ?? '') : '');
  }

  @override
  Widget build(BuildContext context) {
    final timerService = ref.read(timerServiceProvider(widget.gameId));

    return Container(
      color: Colors.grey.shade900,
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  _isEditMode ? 'Ereignis bearbeiten' : 'Ereignis erfassen',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  key: const Key('btn_close_event_form'),
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: widget.onClose,
                  tooltip: 'Abbrechen',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section('Ereignistyp'),
                  _typeGrid(),
                  if (_type == EventType.custom) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Bezeichnung',
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFF424242),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (v) => _customLabel = v,
                    ),
                  ],
                  if (_showPlayerSection) ...[
                    const SizedBox(height: 12),
                    _section('Spieler'),
                    _playerRow(PlayerRole.fouler),
                    const SizedBox(height: 6),
                    _playerRow(PlayerRole.fouled),
                  ],
                  const SizedBox(height: 12),
                  _section('Entscheidung'),
                  _decisionGrid(),
                  const SizedBox(height: 12),
                  _section('Karte'),
                  _cardRow(),
                  const SizedBox(height: 12),
                  _section('Bewertung'),
                  AssessmentGrid(
                    selected: _assessment,
                    onChanged: (v) => setState(() => _assessment = v),
                  ),
                  const SizedBox(height: 12),
                  _noteToggle(),
                ],
              ),
            ),
          ),
          // Speichern-Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canSave ? Colors.green.shade600 : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                key: const Key('btn_save_event'),
                onPressed: _canSave
                    ? () => _save(timerService.currentMs, timerService.current.phase)
                    : null,
                icon: const Icon(Icons.save),
                label: Text(
                  _isEditMode ? 'Änderungen speichern' : 'Speichern',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _showPlayerSection =>
      _type != null &&
      [
        EventType.footFoul,
        EventType.bodyFoul,
        EventType.handball,
        EventType.unsporting,
        EventType.violent,
      ].contains(_type);

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
      );

  Widget _typeGrid() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: EventType.values.map((t) {
        final sel = _type == t;
        return GestureDetector(
          key: Key('event_type_${t.name}'),
          onTap: () => setState(() => _type = sel ? null : t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? Colors.green.shade700 : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(6),
              border:
                  sel ? Border.all(color: Colors.white, width: 1.5) : null,
            ),
            child: Text(t.label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight:
                        sel ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  Widget _decisionGrid() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: RefDecision.values.map((d) {
        final sel = _decision == d;
        return GestureDetector(
          key: Key('decision_${d.name}'),
          onTap: () => setState(() => _decision = sel ? null : d),
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: sel ? Colors.blue.shade700 : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(6),
              border:
                  sel ? Border.all(color: Colors.white, width: 1.5) : null,
            ),
            alignment: Alignment.center,
            child: Text(d.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                        sel ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  Widget _cardRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: CardType.values.map((c) {
        final sel = _card == c;
        final color = c == CardType.yellow
            ? Colors.yellow.shade700
            : c == CardType.yellowRed
                ? Colors.orange.shade700
                : Colors.red.shade700;
        return GestureDetector(
          key: Key('card_${c.name}'),
          onTap: () => setState(() => _card = sel ? null : c),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? color : color.withOpacity(0.35),
              borderRadius: BorderRadius.circular(6),
              border: sel
                  ? Border.all(color: Colors.white, width: 1.5)
                  : null,
            ),
            child: Text(c.label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _playerRow(PlayerRole role) {
    final isHome = TeamSide.home;
    final isAway = TeamSide.away;
    final selectedTeam =
        role == PlayerRole.fouler ? _foulerTeam : _fouledTeam;

    final homeAsync = ref.watch(homeSquadProvider(widget.gameId));
    final awayAsync = ref.watch(awaySquadProvider(widget.gameId));
    final homeNumbers = homeAsync.valueOrNull ?? [];
    final awayNumbers = awayAsync.valueOrNull ?? [];

    // Zeige Chips aus vorerfasster Aufstellung des gewählten Teams
    final squadNumbers = selectedTeam == TeamSide.home
        ? homeNumbers
        : selectedTeam == TeamSide.away
            ? awayNumbers
            : <int>[];

    final selectedNumber =
        role == PlayerRole.fouler ? _foulerNumber : _fouledNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(role.label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 8),
            _teamChip(isHome, role, selectedTeam),
            const SizedBox(width: 4),
            _teamChip(isAway, role, selectedTeam),
            const SizedBox(width: 8),
            // Manuelle Nummern-Eingabe
            SizedBox(
              width: 52,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '#',
                  hintStyle: const TextStyle(color: Colors.white38),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade800,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) {
                  final n = int.tryParse(v);
                  setState(() {
                    if (role == PlayerRole.fouler) _foulerNumber = n;
                    else _fouledNumber = n;
                  });
                },
              ),
            ),
          ],
        ),
        // Squad-Chips
        if (squadNumbers.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: squadNumbers.map((n) {
              final isSel = selectedNumber == n;
              final teamColor = selectedTeam == TeamSide.home
                  ? Colors.blue
                  : Colors.red;
              return GestureDetector(
                onTap: () => setState(() {
                  final newVal = isSel ? null : n;
                  if (role == PlayerRole.fouler) _foulerNumber = newVal;
                  else _fouledNumber = newVal;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSel
                        ? teamColor
                        : teamColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: isSel
                        ? Border.all(color: Colors.white, width: 1)
                        : null,
                  ),
                  child: Text('#$n',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11)),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _teamChip(TeamSide side, PlayerRole role, TeamSide? selected) {
    final isSelected = selected == side;
    final color = side == TeamSide.home ? Colors.blue : Colors.red;
    return GestureDetector(
      onTap: () => setState(() {
        if (role == PlayerRole.fouler) {
          _foulerTeam = isSelected ? null : side;
          _foulerNumber = null; // Team-Wechsel setzt Nummer zurück
        } else {
          _fouledTeam = isSelected ? null : side;
          _fouledNumber = null;
        }
      }),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(side.label,
            style:
                const TextStyle(color: Colors.white, fontSize: 11)),
      ),
    );
  }

  Widget _noteToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _noteExpanded = !_noteExpanded),
          child: Row(
            children: [
              Icon(_noteExpanded ? Icons.expand_less : Icons.add,
                  color: Colors.white54, size: 18),
              const SizedBox(width: 4),
              const Text('Notiz',
                  style:
                      TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        if (_noteExpanded) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Szenennotiz …',
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Color(0xFF424242),
            ),
            style:
                const TextStyle(color: Colors.white, fontSize: 13),
            onChanged: (v) => _sceneNote = v.isEmpty ? null : v,
          ),
        ],
      ],
    );
  }

  Future<void> _save(int elapsedMs, GamePhase gamePhase) async {
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

    if (_isEditMode) {
      final updated = widget.initialEvent!.copyWith(
        type: _type,
        customTypeLabel: _customLabel,
        refDecision: _decision,
        card: _card,
        assessment: _assessment,
        sceneNote: _sceneNote,
      );
      await repo.updateEvent(updated, players);
      widget.onSaved(updated);
    } else {
      final savedEvent = await repo.createEvent(
        Event(
          id: '',
          gameId: widget.gameId,
          elapsedMs: elapsedMs,
          gamePhase: gamePhase,
          type: _type!,
          customTypeLabel:
              _type == EventType.custom ? _customLabel : null,
          locationX: widget.locationX,
          locationY: widget.locationY,
          refDecision: _decision,
          card: _card,
          assessment: _assessment,
          sceneNote: _sceneNote,
          coachingFlag: false,
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
    super.dispose();
  }
}
