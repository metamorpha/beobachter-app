import '../enums/game_phase.dart';

class TimerState {
  final String gameId;
  final bool isRunning;
  final DateTime? startTimestamp;
  final int elapsedMs;
  final GamePhase phase;

  const TimerState({
    required this.gameId,
    required this.isRunning,
    this.startTimestamp,
    required this.elapsedMs,
    this.phase = GamePhase.bereit,
  });

  /// Aktuell abgelaufene Zeit in Millisekunden (background-safe).
  int get currentMs {
    if (isRunning && startTimestamp != null) {
      return elapsedMs + DateTime.now().difference(startTimestamp!).inMilliseconds;
    }
    return elapsedMs;
  }

  /// Phasenbewusste Zeitanzeige (MM:SS oder 45+X etc.).
  String get formattedTime => GamePhaseX.formatMs(currentMs, phase);

  /// Beschriftung der aktuellen Phase für die UI.
  String get phaseLabel => phase.label;

  TimerState start() => TimerState(
        gameId: gameId,
        isRunning: true,
        startTimestamp: DateTime.now(),
        elapsedMs: elapsedMs,
        phase: phase,
      );

  TimerState stop() => TimerState(
        gameId: gameId,
        isRunning: false,
        startTimestamp: null,
        elapsedMs: currentMs,
        phase: phase,
      );

  TimerState withPhase(GamePhase newPhase) => TimerState(
        gameId: gameId,
        isRunning: isRunning,
        startTimestamp: startTimestamp,
        elapsedMs: elapsedMs,
        phase: newPhase,
      );

  static TimerState initial(String gameId) =>
      TimerState(gameId: gameId, isRunning: false, elapsedMs: 0, phase: GamePhase.bereit);
}
