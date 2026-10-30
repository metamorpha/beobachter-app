import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/game.dart';
import '../../domain/enums/kit_color.dart';
import '../../domain/enums/team_side.dart';
import '../../domain/repositories/game_repository.dart';
import '../database/app_database.dart';

class GameRepositoryImpl implements GameRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  GameRepositoryImpl(this._db);

  @override
  Future<Game> createGame(Game game) async {
    final row = GamesCompanion(
      id: Value(game.id.isEmpty ? _uuid.v4() : game.id),
      date: Value(game.date),
      kickoffTime: Value(game.kickoffTime),
      location: Value(game.location),
      homeTeamName: Value(game.homeTeamName),
      awayTeamName: Value(game.awayTeamName),
      liga: Value(game.liga),
      spieltag: Value(game.spieltag),
      createdAt: Value(game.createdAt),
      homeKitColor: Value(game.homeKitColor?.name),
      awayKitColor: Value(game.awayKitColor?.name),
    );
    await _db.into(_db.games).insert(row);
    return _toEntity(await (_db.select(_db.games)
          ..where((t) => t.id.equals(row.id.value)))
        .getSingle());
  }

  @override
  Future<List<Game>> getGames() async {
    final rows = await (_db.select(_db.games)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<Game?> getGame(String id) async {
    final rows = await (_db.select(_db.games)
          ..where((t) => t.id.equals(id)))
        .get();
    return rows.isEmpty ? null : _toEntity(rows.first);
  }

  @override
  Future<void> updateGame(Game game) async {
    await (_db.update(_db.games)..where((t) => t.id.equals(game.id))).write(
      GamesCompanion(
        date: Value(game.date),
        kickoffTime: Value(game.kickoffTime),
        location: Value(game.location),
        homeTeamName: Value(game.homeTeamName),
        awayTeamName: Value(game.awayTeamName),
        liga: Value(game.liga),
        spieltag: Value(game.spieltag),
        homeKitColor: Value(game.homeKitColor?.name),
        awayKitColor: Value(game.awayKitColor?.name),
      ),
    );
  }

  @override
  Future<void> deleteGame(String id) async {
    await (_db.delete(_db.games)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> updateCoachingNote(String gameId, String? note) async {
    await (_db.update(_db.games)..where((t) => t.id.equals(gameId))).write(
      GamesCompanion(coachingNote: Value(note)),
    );
  }

  @override
  Future<void> updateKitColor(
    String gameId,
    TeamSide team,
    KitColor kit,
  ) async {
    await (_db.update(_db.games)..where((t) => t.id.equals(gameId))).write(
      team == TeamSide.home
          ? GamesCompanion(homeKitColor: Value(kit.name))
          : GamesCompanion(awayKitColor: Value(kit.name)),
    );
  }

  Game _toEntity(GameRow row) => Game(
        id: row.id,
        date: row.date,
        kickoffTime: row.kickoffTime,
        location: row.location,
        homeTeamName: row.homeTeamName,
        awayTeamName: row.awayTeamName,
        liga: row.liga,
        spieltag: row.spieltag,
        coachingNote: row.coachingNote,
        createdAt: row.createdAt,
        homeKitColor: KitColorLabel.tryParse(row.homeKitColor),
        awayKitColor: KitColorLabel.tryParse(row.awayKitColor),
      );
}
