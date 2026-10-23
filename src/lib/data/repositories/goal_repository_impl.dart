import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/goal.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/enums/goal_kind.dart';
import '../../domain/enums/team_side.dart';
import '../../domain/repositories/goal_repository.dart';
import '../database/app_database.dart';

class GoalRepositoryImpl implements GoalRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  GoalRepositoryImpl(this._db);

  @override
  Future<Goal> createGoal(Goal goal) async {
    final id = goal.id.isEmpty ? _uuid.v4() : goal.id;
    await _db.into(_db.goals).insert(_toCompanion(goal, id));
    final row = await (_db.select(_db.goals)..where((t) => t.id.equals(id)))
        .getSingle();
    return _toEntity(row);
  }

  @override
  Future<List<Goal>> getGoals(String gameId) async {
    final rows = await (_db.select(_db.goals)
          ..where((t) => t.gameId.equals(gameId))
          ..orderBy([(t) => OrderingTerm.asc(t.elapsedMs)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    await (_db.update(_db.goals)..where((t) => t.id.equals(goal.id)))
        .write(_toCompanion(goal, goal.id));
  }

  @override
  Future<void> deleteGoal(String id) async {
    await (_db.delete(_db.goals)..where((t) => t.id.equals(id))).go();
  }

  GoalsCompanion _toCompanion(Goal g, String id) => GoalsCompanion(
        id: Value(id),
        gameId: Value(g.gameId),
        elapsedMs: Value(g.elapsedMs),
        gamePhase: Value(g.gamePhase.name),
        team: Value(g.team.name),
        scorerNumber: Value(g.scorerNumber),
        kind: Value(g.kind.name),
        createdAt: Value(g.createdAt),
      );

  Goal _toEntity(GoalRow row) => Goal(
        id: row.id,
        gameId: row.gameId,
        elapsedMs: row.elapsedMs,
        gamePhase: _parsePhase(row.gamePhase),
        team: TeamSide.values.byName(row.team),
        scorerNumber: row.scorerNumber,
        kind: GoalKind.values.asNameMap()[row.kind] ?? GoalKind.regular,
        createdAt: row.createdAt,
      );

  static GamePhase _parsePhase(String name) {
    try {
      return GamePhase.values.byName(name);
    } catch (_) {
      return GamePhase.ersteHalbzeit;
    }
  }
}
