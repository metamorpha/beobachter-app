import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/timer_state.dart';

void main() {
  group('TimerState', () {
    test('initial state hat elapsedMs = 0 und isRunning = false', () {
      final state = TimerState.initial('game-1');
      expect(state.elapsedMs, 0);
      expect(state.isRunning, false);
      expect(state.currentMs, 0);
    });

    test('currentMs gibt elapsedMs zurück wenn nicht läuft', () {
      const state = TimerState(
        gameId: 'game-1',
        isRunning: false,
        elapsedMs: 5000,
      );
      expect(state.currentMs, 5000);
    });

    test('currentMs addiert vergangene Zeit wenn läuft', () {
      final startTime = DateTime.now().subtract(const Duration(seconds: 10));
      final state = TimerState(
        gameId: 'game-1',
        isRunning: true,
        startTimestamp: startTime,
        elapsedMs: 0,
      );
      // Ungefähr 10 Sekunden sollten vergangen sein (±500ms Toleranz)
      expect(state.currentMs, greaterThanOrEqualTo(9500));
      expect(state.currentMs, lessThanOrEqualTo(10500));
    });

    test('start() setzt isRunning = true und startTimestamp', () {
      final state = TimerState.initial('game-1');
      final started = state.start();
      expect(started.isRunning, true);
      expect(started.startTimestamp, isNotNull);
      expect(started.elapsedMs, 0);
    });

    test('stop() akkumuliert elapsedMs korrekt', () {
      final startTime = DateTime.now().subtract(const Duration(seconds: 30));
      final state = TimerState(
        gameId: 'game-1',
        isRunning: true,
        startTimestamp: startTime,
        elapsedMs: 60000, // 1 Minute bereits gestopped
      );
      final stopped = state.stop();
      expect(stopped.isRunning, false);
      expect(stopped.startTimestamp, isNull);
      // ~90 Sekunden total (60s + ~30s)
      expect(stopped.elapsedMs, greaterThanOrEqualTo(89500));
      expect(stopped.elapsedMs, lessThanOrEqualTo(90500));
    });

    test('stop().start() behält elapsedMs bei', () {
      const stopped = TimerState(
        gameId: 'game-1',
        isRunning: false,
        elapsedMs: 45000,
      );
      final restarted = stopped.start();
      expect(restarted.elapsedMs, 45000);
      expect(restarted.isRunning, true);
    });
  });
}
