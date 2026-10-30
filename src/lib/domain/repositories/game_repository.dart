import '../entities/game.dart';
import '../enums/kit_color.dart';
import '../enums/team_side.dart';

abstract class GameRepository {
  Future<Game> createGame(Game game);
  Future<List<Game>> getGames();
  Future<Game?> getGame(String id);
  Future<void> updateGame(Game game);
  Future<void> deleteGame(String id);
  Future<void> updateCoachingNote(String gameId, String? note);
  Future<void> updateKitColor(String gameId, TeamSide team, KitColor kit);
}
