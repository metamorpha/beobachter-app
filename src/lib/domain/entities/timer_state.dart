class TimerState {
  final String gameId;
  final bool isRunning;
  final DateTime? startTimestamp; // Zeitpunkt des letzten Starts
  final int elapsedMs;            // Akkumulierte Zeit vor letztem Stop

  const TimerState({
    required this.gameId,
    required this.isRunning,
    this.startTimestamp,
    required this.elapsedMs,
  });

  /// Aktuell abgelaufene Zeit in Millisekunden (background-safe)
  int get currentMs {
    if (isRunning && startTimestamp != null) {
      return elapsedMs + DateTime.now().difference(startTimestamp!).inMilliseconds;
    }
    return elapsedMs;
  }

  TimerState start() => TimerState(
        gameId: gameId,
        isRunning: true,
        startTimestamp: DateTime.now(),
        elapsedMs: elapsedMs,
      );

  TimerState stop() => TimerState(
        gameId: gameId,
        isRunning: false,
        startTimestamp: null,
        elapsedMs: currentMs,
      );

  static TimerState initial(String gameId) =>
      TimerState(gameId: gameId, isRunning: false, elapsedMs: 0);
}
