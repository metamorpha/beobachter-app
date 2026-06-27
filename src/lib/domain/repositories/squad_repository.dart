import '../enums/team_side.dart';

abstract class SquadRepository {
  Future<void> saveSquad(String gameId, TeamSide team, List<int> numbers);
  Future<List<int>> getSquad(String gameId, TeamSide team);
}
