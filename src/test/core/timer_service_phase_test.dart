import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:beobachter_app/core/timer_service.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/repositories/timer_repository.dart';

class MockTimerRepository extends Mock implements TimerRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TimerState.initial('fallback'));
  });

  late MockTimerRepository repo;
  late TimerService service;

  setUp(() {
    repo = MockTimerRepository();
    when(() => repo.saveTimerState(any())).thenAnswer((_) async {});
    when(() => repo.getTimerState(any())).thenAnswer((_) async => null);
    service = TimerService(repo, gameId: 'g-test');
  });

  tearDown(() {
    service.dispose();
  });

  group('Spielphasen — manuelle Übergänge', () {
    test('startGame() setzt Phase ersteHalbzeit und startet Timer', () async {
      await service.startGame();
      expect(service.current.phase, GamePhase.ersteHalbzeit);
      expect(service.current.isRunning, true);
    });

    test('setHalbzeit() stoppt Timer und setzt Phase halbzeit', () async {
      await service.startGame();
      await service.setHalbzeit();
      expect(service.current.phase, GamePhase.halbzeit);
      expect(service.current.isRunning, false);
    });

    test('startZweiteHalbzeit() startet Timer mit Phase zweiteHalbzeit', () async {
      await service.startGame();
      await service.setHalbzeit();
      await service.startZweiteHalbzeit();
      expect(service.current.phase, GamePhase.zweiteHalbzeit);
      expect(service.current.isRunning, true);
    });

    test('setAbpfiff() stoppt Timer und setzt Phase beendet', () async {
      await service.startGame();
      await service.setHalbzeit();
      await service.startZweiteHalbzeit();
      await service.setAbpfiff();
      expect(service.current.phase, GamePhase.beendet);
      expect(service.current.isRunning, false);
    });

    test('startVerlaengerung() startet Timer mit Phase verlaengerungErsteHalbzeit', () async {
      await service.startGame();
      await service.setHalbzeit();
      await service.startZweiteHalbzeit();
      await service.setAbpfiff();
      await service.startVerlaengerung();
      expect(service.current.phase, GamePhase.verlaengerungErsteHalbzeit);
      expect(service.current.isRunning, true);
    });

    test('setHalbzeitVerlaengerung() stoppt und setzt Phase verlaengerungHalbzeit', () async {
      await service.startGame();
      await service.setHalbzeit();
      await service.startZweiteHalbzeit();
      await service.setAbpfiff();
      await service.startVerlaengerung();
      await service.setHalbzeitVerlaengerung();
      expect(service.current.phase, GamePhase.verlaengerungHalbzeit);
      expect(service.current.isRunning, false);
    });

    test('startZweiteVerlaengerung() startet mit Phase verlaengerungZweiteHalbzeit', () async {
      await service.startGame();
      await service.setHalbzeit();
      await service.startZweiteHalbzeit();
      await service.setAbpfiff();
      await service.startVerlaengerung();
      await service.setHalbzeitVerlaengerung();
      await service.startZweiteVerlaengerung();
      expect(service.current.phase, GamePhase.verlaengerungZweiteHalbzeit);
      expect(service.current.isRunning, true);
    });

    test('setAbpfiffVerlaengerung() setzt Phase beendetVerlaengerung', () async {
      await service.startGame();
      await service.setHalbzeit();
      await service.startZweiteHalbzeit();
      await service.setAbpfiff();
      await service.startVerlaengerung();
      await service.setHalbzeitVerlaengerung();
      await service.startZweiteVerlaengerung();
      await service.setAbpfiffVerlaengerung();
      expect(service.current.phase, GamePhase.beendetVerlaengerung);
      expect(service.current.isRunning, false);
    });
  });

  group('Spielphasen — elapsedMs Kontinuität', () {
    test('elapsedMs nach Halbzeit und 2. HZ Start ist größer als 45 Min', () async {
      // Simuliere Timer, der 50 ms gelaufen ist
      await service.startGame();
      await Future.delayed(const Duration(milliseconds: 50));
      await service.setHalbzeit();
      final atHalbzeit = service.current.elapsedMs;
      expect(atHalbzeit, greaterThan(0));

      await service.startZweiteHalbzeit();
      await Future.delayed(const Duration(milliseconds: 50));
      final afterStart = service.current.currentMs;
      expect(afterStart, greaterThan(atHalbzeit));
    });
  });

  group('Spielphasen — Stream', () {
    test('Stream emittiert nach jedem Phasenübergang', () async {
      final phases = <GamePhase>[];
      final sub = service.stream.listen((s) => phases.add(s.phase));

      await service.startGame();
      await service.setHalbzeit();
      await service.startZweiteHalbzeit();

      await Future.delayed(Duration.zero);
      sub.cancel();

      expect(phases, containsAll([
        GamePhase.ersteHalbzeit,
        GamePhase.halbzeit,
        GamePhase.zweiteHalbzeit,
      ]));
    });
  });

  group('Spielphasen — Persistenz', () {
    test('saveTimerState wird bei jedem Phasenübergang aufgerufen', () async {
      await service.startGame();
      await service.setHalbzeit();
      await service.startZweiteHalbzeit();
      await service.setAbpfiff();

      verify(() => repo.saveTimerState(any())).called(4);
    });

    test('load() stellt gespeicherte Phase wieder her', () async {
      when(() => repo.getTimerState('g-restore')).thenAnswer(
        (_) async => const TimerState(
          gameId: 'g-restore',
          isRunning: false,
          elapsedMs: 48 * 60000,
          phase: GamePhase.halbzeit,
        ),
      );
      final svc2 = TimerService(repo, gameId: 'g-restore');
      await svc2.load();
      expect(svc2.current.phase, GamePhase.halbzeit);
      expect(svc2.current.elapsedMs, 48 * 60000);
      svc2.dispose();
    });
  });

  group('GamePhaseX — Nachspielzeit-Schwellen', () {
    test('ersteHalbzeit Schwelle ist 45 Min', () {
      expect(GamePhase.ersteHalbzeit.nachspielzeitSchwelle, 45 * 60 * 1000);
    });

    test('zweiteHalbzeit Schwelle ist 90 Min', () {
      expect(GamePhase.zweiteHalbzeit.nachspielzeitSchwelle, 90 * 60 * 1000);
    });

    test('verlaengerungErsteHalbzeit Schwelle ist 105 Min', () {
      expect(
        GamePhase.verlaengerungErsteHalbzeit.nachspielzeitSchwelle,
        105 * 60 * 1000,
      );
    });

    test('verlaengerungZweiteHalbzeit Schwelle ist 120 Min', () {
      expect(
        GamePhase.verlaengerungZweiteHalbzeit.nachspielzeitSchwelle,
        120 * 60 * 1000,
      );
    });

    test('halbzeit hat keine Schwelle', () {
      expect(GamePhase.halbzeit.nachspielzeitSchwelle, isNull);
    });

    test('beendet hat keine Schwelle', () {
      expect(GamePhase.beendet.nachspielzeitSchwelle, isNull);
    });
  });

  group('GamePhaseX — formatMs', () {
    test('reguläre Phase: MM:SS', () {
      expect(GamePhaseX.formatMs(23 * 60000 + 45000, GamePhase.ersteHalbzeit), '23:45');
    });

    test('ersteHalbzeitNachspielzeit: 45+XX', () {
      expect(GamePhaseX.formatMs(46 * 60000, GamePhase.ersteHalbzeitNachspielzeit), '45+02');
    });

    test('zweiteHalbzeitNachspielzeit: 90+XX', () {
      expect(GamePhaseX.formatMs(91 * 60000, GamePhase.zweiteHalbzeitNachspielzeit), '90+02');
    });

    test('verlaengerungErsteHalbzeitNachspielzeit: 105+XX', () {
      expect(
        GamePhaseX.formatMs(106 * 60000, GamePhase.verlaengerungErsteHalbzeitNachspielzeit),
        '105+02',
      );
    });

    test('verlaengerungZweiteHalbzeitNachspielzeit: 120+XX', () {
      expect(
        GamePhaseX.formatMs(121 * 60000, GamePhase.verlaengerungZweiteHalbzeitNachspielzeit),
        '120+02',
      );
    });

    test('Sekunden-Padding bei einstelligen Werten', () {
      expect(GamePhaseX.formatMs(1 * 60000 + 5000, GamePhase.ersteHalbzeit), '01:05');
    });
  });
}
