import '../enums/kit_color.dart';

class Game {
  final String id;
  final DateTime date;
  final DateTime? kickoffTime;
  final String? location;
  final String homeTeamName;
  final String awayTeamName;
  final String? liga;
  final String? spieltag;
  final String? coachingNote;
  final DateTime createdAt;

  /// Trikotfarben (US-111) — `null` = Standardfarbe (Heim Blau, Gast Rot).
  final KitColor? homeKitColor;
  final KitColor? awayKitColor;

  const Game({
    required this.id,
    required this.date,
    this.kickoffTime,
    this.location,
    required this.homeTeamName,
    required this.awayTeamName,
    this.liga,
    this.spieltag,
    this.coachingNote,
    required this.createdAt,
    this.homeKitColor,
    this.awayKitColor,
  });

  Game copyWith({
    DateTime? date,
    DateTime? kickoffTime,
    String? location,
    String? homeTeamName,
    String? awayTeamName,
    String? liga,
    String? spieltag,
    KitColor? homeKitColor,
    KitColor? awayKitColor,
  }) =>
      Game(
        id: id,
        date: date ?? this.date,
        kickoffTime: kickoffTime ?? this.kickoffTime,
        location: location ?? this.location,
        homeTeamName: homeTeamName ?? this.homeTeamName,
        awayTeamName: awayTeamName ?? this.awayTeamName,
        liga: liga ?? this.liga,
        spieltag: spieltag ?? this.spieltag,
        coachingNote: coachingNote,
        createdAt: createdAt,
        homeKitColor: homeKitColor ?? this.homeKitColor,
        awayKitColor: awayKitColor ?? this.awayKitColor,
      );
}
