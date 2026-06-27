import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/data/repositories/game_repository_impl.dart';
import 'package:beobachter_app/data/repositories/squad_repository_impl.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';

void main() {
  late AppDatabase db;
  late SquadRepositoryImpl repo;
  const gameId = 'g-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SquadRepositoryImpl(db);
    await GameRepositoryImpl(db).createGame(Game(
      id: gameId,
      date: DateTime(2026, 4, 30),
      homeTeamName: 'Heim',
      awayTeamName: 'Gast',
      createdAt: DateTime(2026, 4, 30),
    ));
  });

  tearDown(() => db.close());

  group('SquadRepository', () {
    test('getSquad gibt leere Liste zurück wenn keine Aufstellung', () async {
      final numbers = await repo.getSquad(gameId, TeamSide.home);
      expect(numbers, isEmpty);
    });

    test('saveSquad und getSquad roundtrip', () async {
      await repo.saveSquad(gameId, TeamSide.home, [1, 5, 7, 9, 11]);
      final result = await repo.getSquad(gameId, TeamSide.home);
      expect(result, containsAll([1, 5, 7, 9, 11]));
    });

    test('Heim- und Gast-Aufstellung sind getrennt', () async {
      await repo.saveSquad(gameId, TeamSide.home, [1, 7]);
      await repo.saveSquad(gameId, TeamSide.away, [2, 8]);
      expect(await repo.getSquad(gameId, TeamSide.home), containsAll([1, 7]));
      expect(await repo.getSquad(gameId, TeamSide.away), containsAll([2, 8]));
    });

    test('saveSquad überschreibt bestehende Aufstellung (upsert)', () async {
      await repo.saveSquad(gameId, TeamSide.home, [1, 5, 7]);
      await repo.saveSquad(gameId, TeamSide.home, [2, 9, 11]);
      final result = await repo.getSquad(gameId, TeamSide.home);
      expect(result, containsAll([2, 9, 11]));
      expect(result, isNot(contains(1)));
    });
  });
}
