import '../enums/assessment.dart';
import '../enums/card_type.dart';
import '../enums/event_type.dart';
import '../enums/game_phase.dart';
import '../enums/ref_decision.dart';
import '../enums/team_side.dart';

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

  /// Team des Torschützen (nur bei Torentscheidung, US-214).
  final TeamSide? goalScorerTeam;

  /// Rückennummer des Torschützen — optional.
  final int? goalScorerNumber;

  /// Eigentor: Tor zählt für das gegnerische Team von [goalScorerTeam].
  final bool ownGoal;

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
    this.goalScorerTeam,
    this.goalScorerNumber,
    this.ownGoal = false,
    required this.createdAt,
  });

  /// Phasenbewusster Zeitstempel-String, z. B. "23:45", "45+02", "90+01".
  String get elapsedLabel => GamePhaseX.formatMs(elapsedMs, gamePhase);

  /// Spielminute (ganzzahlig) für Sortierung und einfache Anzeige.
  int get minute => elapsedMs ~/ 60000;

  /// Team, dem dieses Ereignis ein Tor gutschreibt — oder null (US-214).
  /// Zählt nur bei Torentscheidung mit Entscheidung „Tor" und gewähltem Team.
  TeamSide? get goalForTeam {
    final scorer = goalScorerTeam;
    if (type != EventType.goalDecision ||
        refDecision != RefDecision.goal ||
        scorer == null) {
      return null;
    }
    return ownGoal ? scorer.opponent : scorer;
  }

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
        goalScorerTeam: goalScorerTeam,
        goalScorerNumber: goalScorerNumber,
        ownGoal: ownGoal,
        createdAt: createdAt,
      );
}
