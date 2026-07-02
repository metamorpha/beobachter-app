import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:beobachter_app/core/timer_service.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/repositories/timer_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/game_list/game_list_screen.dart';
import 'package:beobachter_app/presentation/screens/live/event_form_panel.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';
import 'package:beobachter_app/presentation/widgets/pitch_canvas.dart';
import 'package:beobachter_app/presentation/widgets/timer_display.dart';

class MockTimerRepository extends Mock implements TimerRepository {}

/// In-Memory-Repository für Widget-Tests: persistiert und streamt TimerStates.
class FakeTimerRepository implements TimerRepository {
  final Map<String, TimerState> _states = {};
  final _controller = StreamController<void>.broadcast();

  @override
  Future<TimerState?> getTimerState(String gameId) async => _states[gameId];

  @override
  Future<void> saveTimerState(TimerState state) async {
    _states[state.gameId] = state;
    _controller.add(null);
  }

  @override
  Stream<TimerState?> watchTimerState(String gameId) async* {
    yield _states[gameId];
    await for (final _ in _controller.stream) {
      yield _states[gameId];
    }
  }
}

Game _game(String id) => Game(
      id: id,
      date: DateTime(2026, 7, 1),
      homeTeamName: 'Heim',
      awayTeamName: 'Gast',
      createdAt: DateTime(2026, 7, 1),
    );

TimerState _stateInPhase(String gameId, GamePhase phase) => TimerState(
      gameId: gameId,
      isRunning: false,
      elapsedMs: 93 * 60 * 1000,
      phase: phase,
    );

Widget _timerDisplayApp(FakeTimerRepository repo) => ProviderScope(
      overrides: [timerRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: TimerDisplay(gameId: 'g1'),
        ),
      ),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(TimerState.initial('fallback'));
  });

  group('TimerService — Spiel beenden (US-212)', () {
    late MockTimerRepository repo;
    late TimerService service;

    setUp(() {
      repo = MockTimerRepository();
      when(() => repo.saveTimerState(any())).thenAnswer((_) async {});
      when(() => repo.getTimerState(any())).thenAnswer((_) async => null);
      service = TimerService(repo, gameId: 'g-test');
    });

    tearDown(() => service.dispose());

    Future<void> bisAbpfiff() async {
      await service.startGame();
      await service.setHalbzeit();
      await service.startZweiteHalbzeit();
      await service.setAbpfiff();
    }

    test('TC-1501: spielBeenden() setzt abgeschlossen und stoppt Uhr',
        () async {
      await bisAbpfiff();
      await service.spielBeenden();
      expect(service.current.phase, GamePhase.abgeschlossen);
      expect(service.current.isRunning, false);
      verify(() => repo.saveTimerState(any(
              that: isA<TimerState>().having(
                  (s) => s.phase, 'phase', GamePhase.abgeschlossen))))
          .called(1);
    });

    test('TC-1502: spielBeenden() aus beendetVerlaengerung', () async {
      await bisAbpfiff();
      await service.startVerlaengerung();
      await service.setHalbzeitVerlaengerung();
      await service.startZweiteVerlaengerung();
      await service.setAbpfiffVerlaengerung();
      await service.spielBeenden();
      expect(service.current.phase, GamePhase.abgeschlossen);
      expect(service.current.isRunning, false);
    });

    test('TC-1503: abgeschlossenes Spiel kann nicht erneut gestartet werden',
        () async {
      await bisAbpfiff();
      await service.spielBeenden();
      clearInteractions(repo);

      await service.startGame();
      await service.startVerlaengerung();
      await service.start();

      expect(service.current.phase, GamePhase.abgeschlossen);
      expect(service.current.isRunning, false);
      verifyNever(() => repo.saveTimerState(any()));
    });

    test('TC-1504: load() stellt abgeschlossen wieder her, kein Ticker',
        () async {
      when(() => repo.getTimerState('g-test')).thenAnswer(
          (_) async => _stateInPhase('g-test', GamePhase.abgeschlossen));
      await service.load();
      expect(service.current.phase, GamePhase.abgeschlossen);
      expect(service.current.isRunning, false);
    });
  });

  group('TimerDisplay — Buttons nach Abpfiff (US-212)', () {
    testWidgets('TC-1505: Phase beendet zeigt Verlängerung + Spiel beenden',
        (tester) async {
      final repo = FakeTimerRepository();
      await repo.saveTimerState(_stateInPhase('g1', GamePhase.beendet));
      await tester.pumpWidget(_timerDisplayApp(repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('btn_verlaengerung')), findsOneWidget);
      expect(find.byKey(const Key('btn_spiel_beenden')), findsOneWidget);
    });

    testWidgets(
        'TC-1506: Phase beendetVerlaengerung zeigt nur Spiel beenden',
        (tester) async {
      final repo = FakeTimerRepository();
      await repo
          .saveTimerState(_stateInPhase('g1', GamePhase.beendetVerlaengerung));
      await tester.pumpWidget(_timerDisplayApp(repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('btn_spiel_beenden')), findsOneWidget);
      expect(find.byKey(const Key('btn_verlaengerung')), findsNothing);
    });

    testWidgets('TC-1507: Dialog erscheint, Abbrechen ändert nichts',
        (tester) async {
      final repo = FakeTimerRepository();
      await repo.saveTimerState(_stateInPhase('g1', GamePhase.beendet));
      await tester.pumpWidget(_timerDisplayApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_spiel_beenden')));
      await tester.pumpAndSettle();
      expect(find.text('Spiel endgültig beenden?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dialog_btn_beenden_cancel')));
      await tester.pumpAndSettle();

      expect((await repo.getTimerState('g1'))!.phase, GamePhase.beendet);
      expect(find.byKey(const Key('btn_verlaengerung')), findsOneWidget);
      expect(find.byKey(const Key('btn_spiel_beenden')), findsOneWidget);
    });

    testWidgets('TC-1508: Dialog bestätigen schließt das Spiel ab',
        (tester) async {
      final repo = FakeTimerRepository();
      await repo.saveTimerState(_stateInPhase('g1', GamePhase.beendet));
      await tester.pumpWidget(_timerDisplayApp(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_spiel_beenden')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dialog_btn_beenden_confirm')));
      await tester.pumpAndSettle();

      expect(
          (await repo.getTimerState('g1'))!.phase, GamePhase.abgeschlossen);
      expect(find.text('Abgeschlossen'), findsOneWidget);
      expect(find.byKey(const Key('btn_spiel_beenden')), findsNothing);
      expect(find.byKey(const Key('btn_verlaengerung')), findsNothing);
    });

    testWidgets('TC-1509: Phase abgeschlossen zeigt keinen Phasen-Button',
        (tester) async {
      final repo = FakeTimerRepository();
      await repo.saveTimerState(_stateInPhase('g1', GamePhase.abgeschlossen));
      await tester.pumpWidget(_timerDisplayApp(repo));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.text('Abgeschlossen'), findsOneWidget);
    });
  });

  group('LiveScreen und Spielliste (US-212)', () {
    testWidgets('TC-1510: Feldtipp im abgeschlossenen Spiel öffnet kein Formular',
        (tester) async {
      final repo = FakeTimerRepository();
      await repo.saveTimerState(_stateInPhase('g1', GamePhase.abgeschlossen));

      await tester.pumpWidget(ProviderScope(
        overrides: [
          timerRepositoryProvider.overrideWithValue(repo),
          eventsProvider.overrideWith((ref, gameId) async => []),
        ],
        child: MaterialApp(home: LiveScreen(game: _game('g1'))),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PitchCanvas));
      await tester.pumpAndSettle();

      expect(find.byType(EventFormPanel), findsNothing);
      expect(find.text('Letzte Ereignisse'), findsOneWidget);
    });

    testWidgets('TC-1511: Spielliste zeigt Beendet-Badge nur für abgeschlossenes Spiel',
        (tester) async {
      final repo = FakeTimerRepository();
      await repo.saveTimerState(_stateInPhase('g1', GamePhase.abgeschlossen));
      await repo.saveTimerState(_stateInPhase('g2', GamePhase.zweiteHalbzeit));

      await tester.pumpWidget(ProviderScope(
        overrides: [
          timerRepositoryProvider.overrideWithValue(repo),
          gamesProvider.overrideWith((ref) async => [_game('g1'), _game('g2')]),
          eventCountProvider.overrideWith((ref, gameId) async => 0),
        ],
        child: const MaterialApp(home: GameListScreen()),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('badge_beendet_g1')), findsOneWidget);
      expect(find.byKey(const Key('badge_beendet_g2')), findsNothing);
    });
  });
}
