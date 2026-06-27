import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/data/repositories/game_repository_impl.dart';
import 'package:beobachter_app/domain/entities/game.dart';

void main() {
  late AppDatabase db;
  late GameRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = GameRepositoryImpl(db);
  });

  tearDown(() => db.close());

  group('GameRepository', () {
    Game _testGame({String id = 'g-1'}) => Game(
          id: id,
          date: DateTime(2026, 4, 30),
          homeTeamName: 'FC Heim',
          awayTeamName: 'FC Gast',
          createdAt: DateTime(2026, 4, 30, 10, 0),
        );

    test('createGame speichert und gibt das Spiel zurück', () async {
      final game = await repo.createGame(_testGame());
      expect(game.id, 'g-1');
      expect(game.homeTeamName, 'FC Heim');
      expect(game.awayTeamName, 'FC Gast');
    });

    test('getGames gibt alle Spiele zurück', () async {
      await repo.createGame(_testGame(id: 'g-1'));
      await repo.createGame(_testGame(id: 'g-2'));
      final games = await repo.getGames();
      expect(games.length, 2);
    });

    test('getGames ist absteigend nach Datum sortiert', () async {
      await repo.createGame(_testGame(id: 'g-1')
          .copyWith(date: DateTime(2026, 4, 29)));
      await repo.createGame(_testGame(id: 'g-2')
          .copyWith(date: DateTime(2026, 4, 30)));
      final games = await repo.getGames();
      expect(games.first.id, 'g-2'); // neueres Spiel zuerst
    });

    test('getGame gibt null zurück wenn nicht gefunden', () async {
      final result = await repo.getGame('nicht-vorhanden');
      expect(result, isNull);
    });

    test('updateGame aktualisiert Teamname', () async {
      await repo.createGame(_testGame());
      final updated = _testGame().copyWith(homeTeamName: 'SV Neuer Name');
      await repo.updateGame(updated);
      final result = await repo.getGame('g-1');
      expect(result?.homeTeamName, 'SV Neuer Name');
    });

    test('deleteGame entfernt das Spiel', () async {
      await repo.createGame(_testGame());
      await repo.deleteGame('g-1');
      final result = await repo.getGame('g-1');
      expect(result, isNull);
    });
  });
}
