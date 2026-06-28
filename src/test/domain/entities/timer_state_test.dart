import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';

void main() {
  group('TimerState — Basisfunktionen', () {
    test('initial state hat elapsedMs = 0 und isRunning = false', () {
      final state = TimerState.initial('game-1');
      expect(state.elapsedMs, 0);
      expect(state.isRunning, false);
      expect(state.currentMs, 0);
      expect(state.phase, GamePhase.bereit);
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
        elapsedMs: 60000,
      );
      final stopped = state.stop();
      expect(stopped.isRunning, false);
      expect(stopped.startTimestamp, isNull);
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

  group('TimerState — Phasen', () {
    test('withPhase() ändert nur die Phase, nicht den Timer-Zustand', () {
      final state = const TimerState(
        gameId: 'g',
        isRunning: true,
        elapsedMs: 1000,
        phase: GamePhase.ersteHalbzeit,
      );
      final ns = state.withPhase(GamePhase.ersteHalbzeitNachspielzeit);
      expect(ns.phase, GamePhase.ersteHalbzeitNachspielzeit);
      expect(ns.isRunning, true);
      expect(ns.elapsedMs, 1000);
    });

    test('start() behält Phase bei', () {
      const state = TimerState(
        gameId: 'g',
        isRunning: false,
        elapsedMs: 0,
        phase: GamePhase.zweiteHalbzeit,
      );
      final started = state.start();
      expect(started.phase, GamePhase.zweiteHalbzeit);
    });

    test('stop() behält Phase bei', () {
      final state = TimerState(
        gameId: 'g',
        isRunning: true,
        startTimestamp: DateTime.now(),
        elapsedMs: 0,
        phase: GamePhase.ersteHalbzeitNachspielzeit,
      );
      final stopped = state.stop();
      expect(stopped.phase, GamePhase.ersteHalbzeitNachspielzeit);
    });
  });

  group('TimerState — formattedTime', () {
    test('reguläre Halbzeit zeigt MM:SS', () {
      const state = TimerState(
        gameId: 'g',
        isRunning: false,
        elapsedMs: 23 * 60000 + 45 * 1000, // 23:45
        phase: GamePhase.ersteHalbzeit,
      );
      expect(state.formattedTime, '23:45');
    });

    test('1. HZ Nachspielzeit zeigt 45+XX', () {
      const state = TimerState(
        gameId: 'g',
        isRunning: false,
        elapsedMs: 46 * 60000, // 46:00 → 45+02
        phase: GamePhase.ersteHalbzeitNachspielzeit,
      );
      expect(state.formattedTime, '45+02');
    });

    test('2. HZ Nachspielzeit zeigt 90+XX', () {
      const state = TimerState(
        gameId: 'g',
        isRunning: false,
        elapsedMs: 91 * 60000, // 91:00 → 90+02
        phase: GamePhase.zweiteHalbzeitNachspielzeit,
      );
      expect(state.formattedTime, '90+02');
    });

    test('VL 1. HZ Nachspielzeit zeigt 105+XX', () {
      const state = TimerState(
        gameId: 'g',
        isRunning: false,
        elapsedMs: 106 * 60000, // 106:00 → 105+02
        phase: GamePhase.verlaengerungErsteHalbzeitNachspielzeit,
      );
      expect(state.formattedTime, '105+02');
    });

    test('VL 2. HZ Nachspielzeit zeigt 120+XX', () {
      const state = TimerState(
        gameId: 'g',
        isRunning: false,
        elapsedMs: 121 * 60000, // 121:00 → 120+02
        phase: GamePhase.verlaengerungZweiteHalbzeitNachspielzeit,
      );
      expect(state.formattedTime, '120+02');
    });

    test('Nachspielzeit bei exakt 45:00 zeigt 45+01', () {
      const state = TimerState(
        gameId: 'g',
        isRunning: false,
        elapsedMs: 45 * 60000, // genau 45:00
        phase: GamePhase.ersteHalbzeitNachspielzeit,
      );
      expect(state.formattedTime, '45+01');
    });

    test('phaseLabel gibt korrekten Text zurück', () {
      const state = TimerState(
        gameId: 'g',
        isRunning: false,
        elapsedMs: 0,
        phase: GamePhase.halbzeit,
      );
      expect(state.phaseLabel, 'Halbzeitpause');
    });
  });
}
