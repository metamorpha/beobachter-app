class Game {
  final String id;
  final DateTime date;
  final DateTime? kickoffTime;
  final String? location;
  final String homeTeamName;
  final String awayTeamName;
  final String? liga;
  final String? spieltag;
  final DateTime createdAt;

  const Game({
    required this.id,
    required this.date,
    this.kickoffTime,
    this.location,
    required this.homeTeamName,
    required this.awayTeamName,
    this.liga,
    this.spieltag,
    required this.createdAt,
  });

  Game copyWith({
    DateTime? date,
    DateTime? kickoffTime,
    String? location,
    String? homeTeamName,
    String? awayTeamName,
    String? liga,
    String? spieltag,
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
        createdAt: createdAt,
      );
}
