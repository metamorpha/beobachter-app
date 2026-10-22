import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/repositories/timer_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/game_list/game_list_screen.dart';
import 'package:beobachter_app/presentation/screens/game_setup/game_setup_screen.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

/// In-Memory-Repository: persistiert und streamt TimerStates.
class _FakeTimerRepository implements TimerRepository {
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

// ── Hilfsfunktionen ──────────────────────────────────────────────────────────

Game _game(String id) => Game(
      id: id,
      date: DateTime(2026, 10, 22),
      homeTeamName: 'Heim $id',
      awayTeamName: 'Gast $id',
      createdAt: DateTime(2026, 10, 22),
    );

TimerState _state(String gameId, GamePhase phase,
        {bool running = false, DateTime? start, int minutes = 50}) =>
    TimerState(
      gameId: gameId,
      isRunning: running,
      startTimestamp: start,
      elapsedMs: minutes * 60 * 1000,
      phase: phase,
    );

Widget _listApp(_FakeTimerRepository repo, List<Game> games) => ProviderScope(
      overrides: [
        timerRepositoryProvider.overrideWithValue(repo),
        gamesProvider.overrideWith((ref) async => games),
        eventCountProvider.overrideWith((ref, gameId) async => 0),
        eventsProvider.overrideWith((ref, gameId) async => []),
        homeSquadProvider.overrideWith((ref, gameId) async => []),
        awaySquadProvider.overrideWith((ref, gameId) async => []),
      ],
      child: const MaterialApp(home: GameListScreen()),
    );

/// Kurz pumpen statt pumpAndSettle — eine laufende Uhr tickt endlos.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _tapGame(WidgetTester tester, String id) async {
  await tester.tap(find.byKey(Key('game_tile_$id')));
  await _settle(tester);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  test('TC-1091: Nur bereit und abgeschlossen gelten nicht als laufend', () {
    for (final phase in GamePhase.values) {
      final expected =
          phase != GamePhase.bereit && phase != GamePhase.abgeschlossen;
      expect(phase.istLaufend, expected, reason: phase.name);
    }
  });

  group('Spielliste (US-109)', () {
    setUp(() {
      // Querformat-Tablet, damit der Live-Screen ohne Overflow rendert
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize =
          const Size(1280, 800);
      binding.platformDispatcher.views.first.devicePixelRatio = 1;
    });

    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    testWidgets('TC-1092: Badge „Läuft" nur für laufende Spiele',
        (tester) async {
      final repo = _FakeTimerRepository();
      await repo.saveTimerState(_state('g1', GamePhase.zweiteHalbzeit));
      await repo.saveTimerState(_state('g2', GamePhase.abgeschlossen));

      await tester.pumpWidget(
          _listApp(repo, [_game('g1'), _game('g2'), _game('g3')]));
      await _settle(tester);

      expect(find.byKey(const Key('badge_laeuft_g1')), findsOneWidget);
      expect(find.byKey(const Key('badge_beendet_g1')), findsNothing);
      expect(find.byKey(const Key('badge_laeuft_g2')), findsNothing);
      expect(find.byKey(const Key('badge_beendet_g2')), findsOneWidget);
      expect(find.byKey(const Key('badge_laeuft_g3')), findsNothing);
      expect(find.byKey(const Key('badge_beendet_g3')), findsNothing);
      expect(find.text('Läuft'), findsOneWidget);
    });

    testWidgets('TC-1093: Tap auf laufendes Spiel öffnet den Live-Screen',
        (tester) async {
      final repo = _FakeTimerRepository();
      await repo.saveTimerState(_state('g1', GamePhase.ersteHalbzeit,
          running: true, start: DateTime.now()));

      await tester.pumpWidget(_listApp(repo, [_game('g1')]));
      await _settle(tester);
      await _tapGame(tester, 'g1');

      expect(find.byType(LiveScreen), findsOneWidget);
      expect(find.byType(ReviewScreen), findsNothing);
      expect(find.byType(GameSetupScreen), findsNothing);
    });

    testWidgets('TC-1094: Tap auf Spiel nach dem Abpfiff öffnet den Live-Screen',
        (tester) async {
      final repo = _FakeTimerRepository();
      await repo.saveTimerState(_state('g1', GamePhase.beendet));

      await tester.pumpWidget(_listApp(repo, [_game('g1')]));
      await _settle(tester);
      await _tapGame(tester, 'g1');

      expect(find.byType(LiveScreen), findsOneWidget);
    });

    testWidgets(
        'TC-1095: Nicht gestartetes Spiel öffnet weiterhin die Nachbereitung',
        (tester) async {
      final repo = _FakeTimerRepository();

      await tester.pumpWidget(_listApp(repo, [_game('g1')]));
      await _settle(tester);
      await _tapGame(tester, 'g1');

      expect(find.byType(ReviewScreen), findsOneWidget);
      expect(find.byType(LiveScreen), findsNothing);
    });

    testWidgets(
        'TC-1096: Abgeschlossenes Spiel öffnet weiterhin die Nachbereitung',
        (tester) async {
      final repo = _FakeTimerRepository();
      await repo.saveTimerState(_state('g1', GamePhase.abgeschlossen));

      await tester.pumpWidget(_listApp(repo, [_game('g1')]));
      await _settle(tester);
      await _tapGame(tester, 'g1');

      expect(find.byType(ReviewScreen), findsOneWidget);
      expect(find.byType(LiveScreen), findsNothing);
    });

    testWidgets('TC-1097: Uhr und Phase bleiben beim Fortsetzen unverändert',
        (tester) async {
      final repo = _FakeTimerRepository();
      final start = DateTime(2026, 10, 22, 16, 30);
      await repo.saveTimerState(_state('g1', GamePhase.zweiteHalbzeit,
          running: true, start: start, minutes: 50));

      await tester.pumpWidget(_listApp(repo, [_game('g1')]));
      await _settle(tester);
      await _tapGame(tester, 'g1');

      final saved = (await repo.getTimerState('g1'))!;
      expect(saved.phase, GamePhase.zweiteHalbzeit);
      expect(saved.isRunning, isTrue);
      expect(saved.startTimestamp, start);
      expect(saved.elapsedMs, 50 * 60 * 1000);
    });

    testWidgets('TC-1098: Zurück vom Live-Screen führt zur Spielliste',
        (tester) async {
      final repo = _FakeTimerRepository();
      await repo.saveTimerState(_state('g1', GamePhase.halbzeit));

      await tester.pumpWidget(_listApp(repo, [_game('g1')]));
      await _settle(tester);
      await _tapGame(tester, 'g1');
      expect(find.byType(LiveScreen), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await _settle(tester);

      expect(find.byType(LiveScreen), findsNothing);
      expect(find.byType(GameListScreen), findsOneWidget);
      expect(find.byKey(const Key('badge_laeuft_g1')), findsOneWidget);
    });
  });
}
