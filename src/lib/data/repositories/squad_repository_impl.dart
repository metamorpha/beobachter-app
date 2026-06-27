import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/enums/team_side.dart';
import '../../domain/repositories/squad_repository.dart';
import '../database/app_database.dart';

class SquadRepositoryImpl implements SquadRepository {
  final AppDatabase _db;

  SquadRepositoryImpl(this._db);

  @override
  Future<void> saveSquad(
      String gameId, TeamSide team, List<int> numbers) async {
    await _db.into(_db.squads).insertOnConflictUpdate(
          SquadsCompanion(
            gameId: Value(gameId),
            team: Value(team.name),
            jerseyNumbers: Value(jsonEncode(numbers)),
          ),
        );
  }

  @override
  Future<List<int>> getSquad(String gameId, TeamSide team) async {
    final rows = await (_db.select(_db.squads)
          ..where(
              (t) => t.gameId.equals(gameId) & t.team.equals(team.name)))
        .get();
    if (rows.isEmpty) return [];
    final raw = jsonDecode(rows.first.jerseyNumbers) as List;
    return raw.cast<int>();
  }
}
