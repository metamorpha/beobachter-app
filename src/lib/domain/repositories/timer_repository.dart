import '../entities/timer_state.dart';

abstract class TimerRepository {
  Future<void> saveTimerState(TimerState state);
  Future<TimerState?> getTimerState(String gameId);
}
