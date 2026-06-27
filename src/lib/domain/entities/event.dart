import '../enums/assessment.dart';
import '../enums/card_type.dart';
import '../enums/event_type.dart';
import '../enums/ref_decision.dart';

class Event {
  final String id;
  final String gameId;
  final int elapsedMs;         // Zeit ab Spielstart in Millisekunden
  final EventType type;
  final String? customTypeLabel; // nur bei EventType.custom
  final double locationX;      // 0.0–1.0 (normalisiert)
  final double locationY;      // 0.0–1.0 (normalisiert)
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

  /// Spielzeit als lesbarer String, z. B. "47:23"
  String get elapsedLabel {
    final minutes = elapsedMs ~/ 60000;
    final seconds = (elapsedMs % 60000) ~/ 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Spielminute für die Anzeige in der Szenenliste
  int get minute => elapsedMs ~/ 60000;

  Event copyWith({
    int? elapsedMs,
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
