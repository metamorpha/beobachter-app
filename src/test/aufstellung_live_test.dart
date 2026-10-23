import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/player_role.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/domain/repositories/event_repository.dart';
import 'package:beobachter_app/domain/repositories/squad_repository.dart';
import 'package:beobachter_app/domain/repositories/timer_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/live/event_form_panel.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';
import 'package:beobachter_app/presentation/widgets/pitch_canvas.dart';
import 'package:beobachter_app/presentation/widgets/squad_edit_dialog.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

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

class _FakeSquadRepository implements SquadRepository {
  final Map<TeamSide, List<int>> squads;

  _FakeSquadRepository({List<int> home = const [], List<int> away = const []})
      : squads = {TeamSide.home: [...home], TeamSide.away: [...away]};

  @override
  Future<List<int>> getSquad(String gameId, TeamSide team) async =>
      [...squads[team]!];

  @override
  Future<void> saveSquad(String gameId, TeamSide team, List<int> numbers) async =>
      squads[team] = [...numbers];
}

class _FakeEventRepository implements EventRepository {
  final List<Event> events;
  final List<EventPlayer> players;
  int updateCalls = 0;
  int deleteCalls = 0;

  _FakeEventRepository([this.events = const [], this.players = const []]);

  @override
  Future<List<Event>> getEvents(String gameId) async => events;

  @override
  Future<List<EventPlayer>> getPlayersForGame(String gameId) async => players;

  @override
  Future<void> updateEvent(Event event, List<EventPlayer> players) async =>
      updateCalls++;

  @override
  Future<void> deleteEvent(String id) async => deleteCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// ── Hilfsfunktionen ──────────────────────────────────────────────────────────

const _gameId = 'g1';

final _game = Game(
  id: _gameId,
  date: DateTime(2026, 10, 22),
  homeTeamName: 'Heim',
  awayTeamName: 'Gast',
  createdAt: DateTime(2026, 10, 22),
);

Future<_FakeTimerRepository> _timerIn(GamePhase phase,
    {bool running = false, DateTime? start}) async {
  final repo = _FakeTimerRepository();
  await repo.saveTimerState(TimerState(
    gameId: _gameId,
    isRunning: running,
    startTimestamp: start,
    elapsedMs: 50 * 60 * 1000,
    phase: phase,
  ));
  return repo;
}

Future<void> _pumpLive(
  WidgetTester tester, {
  required _FakeTimerRepository timerRepo,
  required _FakeSquadRepository squadRepo,
  _FakeEventRepository? eventRepo,
}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      timerRepositoryProvider.overrideWithValue(timerRepo),
      squadRepositoryProvider.overrideWithValue(squadRepo),
      eventRepositoryProvider
          .overrideWithValue(eventRepo ?? _FakeEventRepository()),
    ],
    child: MaterialApp(home: LiveScreen(game: _game)),
  ));
  await _settle(tester);
}

/// Kurz pumpen statt pumpAndSettle — eine laufende Uhr tickt endlos.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _openDialog(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('btn_aufstellung')));
  await _settle(tester);
}

Future<void> _addViaButton(
    WidgetTester tester, TeamSide team, String text) async {
  await tester.enterText(find.byKey(Key('squad_${team.name}_field')), text);
  await tester.tap(find.byKey(Key('squad_${team.name}_add')));
  await _settle(tester);
}

Finder _chip(TeamSide team, int n) => find.byKey(Key('squad_${team.name}_chip_$n'));

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Aufstellung im Live-Screen (US-110)', () {
    testWidgets('TC-1101: Button öffnet den Dialog', (tester) async {
      await _pumpLive(tester,
          timerRepo: await _timerIn(GamePhase.ersteHalbzeit),
          squadRepo: _FakeSquadRepository(home: [4, 7], away: [10]));

      await _openDialog(tester);

      expect(find.byType(SquadEditDialog), findsOneWidget);
      // Titel im Dialog (der Live-Screen-Button trägt seit US-602 dieselbe Beschriftung)
      expect(
          find.descendant(
              of: find.byType(SquadEditDialog),
              matching: find.text('Aufstellung')),
          findsOneWidget);
      expect(find.text('Heim'), findsWidgets);
      expect(find.text('Gast'), findsWidgets);
      expect(_chip(TeamSide.home, 4), findsOneWidget);
      expect(_chip(TeamSide.home, 7), findsOneWidget);
      expect(_chip(TeamSide.away, 10), findsOneWidget);
    });

    testWidgets('TC-1102: Nummer per „+" hinzufügen', (tester) async {
      final squads = _FakeSquadRepository(home: [4, 7]);
      await _pumpLive(tester,
          timerRepo: await _timerIn(GamePhase.ersteHalbzeit),
          squadRepo: squads);
      await _openDialog(tester);

      await _addViaButton(tester, TeamSide.home, '9');

      expect(_chip(TeamSide.home, 9), findsOneWidget);
      expect(squads.squads[TeamSide.home], [4, 7, 9]);
      final field = tester
          .widget<TextField>(find.byKey(const Key('squad_home_field')));
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('TC-1103: Nummer per Enter hinzufügen, sortiert',
        (tester) async {
      final squads = _FakeSquadRepository(away: [10]);
      await _pumpLive(tester,
          timerRepo: await _timerIn(GamePhase.ersteHalbzeit),
          squadRepo: squads);
      await _openDialog(tester);

      await tester.enterText(find.byKey(const Key('squad_away_field')), '3');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);

      expect(squads.squads[TeamSide.away], [3, 10]);
      final x3 = tester.getTopLeft(_chip(TeamSide.away, 3)).dx;
      final x10 = tester.getTopLeft(_chip(TeamSide.away, 10)).dx;
      expect(x3, lessThan(x10));
    });

    testWidgets('TC-1104: Ungültige Eingaben und Duplikate werden ignoriert',
        (tester) async {
      final squads = _FakeSquadRepository(home: [4]);
      await _pumpLive(tester,
          timerRepo: await _timerIn(GamePhase.ersteHalbzeit),
          squadRepo: squads);
      await _openDialog(tester);

      for (final input in ['0', '100', 'abc', '4']) {
        await _addViaButton(tester, TeamSide.home, input);
      }

      expect(squads.squads[TeamSide.home], [4]);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('TC-1105: Nummer entfernen', (tester) async {
      final squads = _FakeSquadRepository(home: [4, 7]);
      await _pumpLive(tester,
          timerRepo: await _timerIn(GamePhase.ersteHalbzeit),
          squadRepo: squads);
      await _openDialog(tester);

      await tester.tap(find.descendant(
          of: _chip(TeamSide.home, 7), matching: find.byIcon(Icons.cancel)));
      await _settle(tester);

      expect(_chip(TeamSide.home, 7), findsNothing);
      expect(squads.squads[TeamSide.home], [4]);
    });

    testWidgets('TC-1106: „Fertig" schließt den Dialog, Änderungen bleiben',
        (tester) async {
      final squads = _FakeSquadRepository();
      await _pumpLive(tester,
          timerRepo: await _timerIn(GamePhase.ersteHalbzeit),
          squadRepo: squads);
      await _openDialog(tester);
      await _addViaButton(tester, TeamSide.home, '9');

      await tester.tap(find.byKey(const Key('btn_squad_done')));
      await _settle(tester);

      expect(find.byType(SquadEditDialog), findsNothing);
      expect(find.byType(LiveScreen), findsOneWidget);
      expect(squads.squads[TeamSide.home], contains(9));
    });

    testWidgets('TC-1107: Ereignisformular zeigt neue Nummern',
        (tester) async {
      await _pumpLive(tester,
          timerRepo: await _timerIn(GamePhase.ersteHalbzeit),
          squadRepo: _FakeSquadRepository(home: [4]));
      await _openDialog(tester);
      await _addViaButton(tester, TeamSide.home, '9');
      await tester.tap(find.byKey(const Key('btn_squad_done')));
      await _settle(tester);

      await tester.tap(find.byType(PitchCanvas));
      await _settle(tester);
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await _settle(tester);
      await tester.ensureVisible(find.byKey(const Key('fouler_team_home')));
      await tester.tap(find.byKey(const Key('fouler_team_home')));
      await _settle(tester);

      expect(
          find.descendant(
              of: find.byType(EventFormPanel), matching: find.text('#9')),
          findsWidgets);
    });

    testWidgets('TC-1108: Uhr und Szenen bleiben unberührt', (tester) async {
      // Start „jetzt" — sonst greift der automatische Nachspielzeit-Wechsel
      final start = DateTime.now();
      final timerRepo = await _timerIn(GamePhase.zweiteHalbzeit,
          running: true, start: start);
      final squads = _FakeSquadRepository(home: [4, 7]);
      final events = _FakeEventRepository(
        [
          Event(
            id: 'e1',
            gameId: _gameId,
            elapsedMs: 48 * 60 * 1000,
            gamePhase: GamePhase.zweiteHalbzeit,
            type: EventType.footFoul,
            locationX: 0.5,
            locationY: 0.5,
            createdAt: DateTime(2026, 10, 22),
          ),
        ],
        const [
          EventPlayer(
            id: 'p1',
            eventId: 'e1',
            role: PlayerRole.fouler,
            team: TeamSide.home,
            jerseyNumber: 7,
          ),
        ],
      );
      await _pumpLive(tester,
          timerRepo: timerRepo, squadRepo: squads, eventRepo: events);

      await _openDialog(tester);
      await tester.tap(find.descendant(
          of: _chip(TeamSide.home, 7), matching: find.byIcon(Icons.cancel)));
      await _settle(tester);
      await tester.tap(find.byKey(const Key('btn_squad_done')));
      await _settle(tester);

      final saved = (await timerRepo.getTimerState(_gameId))!;
      expect(saved.phase, GamePhase.zweiteHalbzeit);
      expect(saved.isRunning, isTrue);
      expect(saved.startTimestamp, start);
      expect(saved.elapsedMs, 50 * 60 * 1000);
      expect(events.updateCalls, 0);
      expect(events.deleteCalls, 0);
    });

    testWidgets('TC-1109: Button im abgeschlossenen Spiel verfügbar',
        (tester) async {
      await _pumpLive(tester,
          timerRepo: await _timerIn(GamePhase.abgeschlossen),
          squadRepo: _FakeSquadRepository(home: [4]));

      expect(find.byKey(const Key('btn_aufstellung')), findsOneWidget);
      await _openDialog(tester);
      expect(find.byType(SquadEditDialog), findsOneWidget);
    });
  });
}
