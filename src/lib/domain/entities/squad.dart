import '../enums/team_side.dart';

class Squad {
  final String gameId;
  final TeamSide team;
  final List<int> jerseyNumbers;

  const Squad({
    required this.gameId,
    required this.team,
    required this.jerseyNumbers,
  });

  Squad copyWith({List<int>? jerseyNumbers}) => Squad(
        gameId: gameId,
        team: team,
        jerseyNumbers: jerseyNumbers ?? this.jerseyNumbers,
      );
}
