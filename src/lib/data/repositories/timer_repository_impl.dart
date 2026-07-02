import 'package:drift/drift.dart';

import '../../domain/entities/timer_state.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/repositories/timer_repository.dart';
import '../database/app_database.dart';

class TimerRepositoryImpl implements TimerRepository {
  final AppDatabase _db;

  TimerRepositoryImpl(this._db);

  @override
  Future<void> saveTimerState(TimerState state) async {
    await _db.into(_db.timerStates).insertOnConflictUpdate(
          TimerStatesCompanion(
            gameId: Value(state.gameId),
            isRunning: Value(state.isRunning),
            startTimestamp: Value(state.startTimestamp),
            elapsedMs: Value(state.elapsedMs),
            phase: Value(state.phase.name),
          ),
        );
  }

  @override
  Future<TimerState?> getTimerState(String gameId) async {
    final rows = await (_db.select(_db.timerStates)
          ..where((t) => t.gameId.equals(gameId)))
        .get();
    if (rows.isEmpty) return null;
    return _toState(rows.first);
  }

  @override
  Stream<TimerState?> watchTimerState(String gameId) {
    return (_db.select(_db.timerStates)
          ..where((t) => t.gameId.equals(gameId)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toState(row));
  }

  static TimerState _toState(TimerStateRow row) => TimerState(
        gameId: row.gameId,
        isRunning: row.isRunning,
        startTimestamp: row.startTimestamp,
        elapsedMs: row.elapsedMs,
        phase: _parsePhase(row.phase),
      );

  static GamePhase _parsePhase(String name) {
    try {
      return GamePhase.values.byName(name);
    } catch (_) {
      return GamePhase.bereit;
    }
  }
}
