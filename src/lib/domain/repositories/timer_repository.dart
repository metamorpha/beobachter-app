import '../entities/timer_state.dart';

abstract class TimerRepository {
  Future<void> saveTimerState(TimerState state);
  Future<TimerState?> getTimerState(String gameId);

  /// Reaktiver Stream des TimerState — emittiert bei jeder Änderung
  /// (z. B. für das „Beendet"-Badge in der Spielliste).
  Stream<TimerState?> watchTimerState(String gameId);
}
