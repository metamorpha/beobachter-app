import '../enums/assessment.dart';
import '../enums/card_type.dart';
import '../enums/event_type.dart';
import '../enums/game_phase.dart';
import '../enums/ref_decision.dart';

class Event {
  final String id;
  final String gameId;
  final int elapsedMs;
  final GamePhase gamePhase;
  final EventType type;
  final String? customTypeLabel;
  final double locationX;
  final double locationY;
  final RefDecision? refDecision;
  final CardType? card;
  final Assessment? assessment;
  final String? sceneNote;
  final bool coachingFlag;
  final String? coachingNote;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.gameId,
    required this.elapsedMs,
    this.gamePhase = GamePhase.ersteHalbzeit,
    required this.type,
    this.customTypeLabel,
    required this.locationX,
    required this.locationY,
    this.refDecision,
    this.card,
    this.assessment,
    this.sceneNote,
    this.coachingFlag = false,
    this.coachingNote,
    required this.createdAt,
  });

  /// Phasenbewusster Zeitstempel-String, z. B. "23:45", "45+02", "90+01".
  String get elapsedLabel => GamePhaseX.formatMs(elapsedMs, gamePhase);

  /// Spielminute (ganzzahlig) für Sortierung und einfache Anzeige.
  int get minute => elapsedMs ~/ 60000;

  Event copyWith({
    int? elapsedMs,
    GamePhase? gamePhase,
    EventType? type,
    String? customTypeLabel,
    double? locationX,
    double? locationY,
    RefDecision? refDecision,
    CardType? card,
    Assessment? assessment,
    String? sceneNote,
    bool? coachingFlag,
    String? coachingNote,
  }) =>
      Event(
        id: id,
        gameId: gameId,
        elapsedMs: elapsedMs ?? this.elapsedMs,
        gamePhase: gamePhase ?? this.gamePhase,
        type: type ?? this.type,
        customTypeLabel: customTypeLabel ?? this.customTypeLabel,
        locationX: locationX ?? this.locationX,
        locationY: locationY ?? this.locationY,
        refDecision: refDecision ?? this.refDecision,
        card: card ?? this.card,
        assessment: assessment ?? this.assessment,
        sceneNote: sceneNote ?? this.sceneNote,
        coachingFlag: coachingFlag ?? this.coachingFlag,
        coachingNote: coachingNote ?? this.coachingNote,
        createdAt: createdAt,
      );
}
