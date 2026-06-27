import 'package:drift/drift.dart';

import '../../domain/entities/timer_state.dart';
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
          ),
        );
  }

  @override
  Future<TimerState?> getTimerState(String gameId) async {
    final rows = await (_db.select(_db.timerStates)
          ..where((t) => t.gameId.equals(gameId)))
        .get();
    if (rows.isEmpty) return null;
    final row = rows.first;
    return TimerState(
      gameId: row.gameId,
      isRunning: row.isRunning,
      startTimestamp: row.startTimestamp,
      elapsedMs: row.elapsedMs,
    );
  }
}
