import '../entities/game.dart';

abstract class GameRepository {
  Future<Game> createGame(Game game);
  Future<List<Game>> getGames();
  Future<Game?> getGame(String id);
  Future<void> updateGame(Game game);
  Future<void> deleteGame(String id);
}
