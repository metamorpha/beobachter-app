import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/data/repositories/event_repository_impl.dart';
import 'package:beobachter_app/data/repositories/game_repository_impl.dart';
import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/score.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/ref_decision.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/domain/repositories/event_repository.dart';
import 'package:beobachter_app/domain/repositories/timer_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/live/event_form_panel.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

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

/// In-Memory-EventRepository: speichert Events, merkt sich letzte Aufrufe.
class FakeEventRepository implements EventRepository {
  final List<Event> events;
  Event? lastCreated;
  Event? lastUpdated;
  List<EventPlayer>? lastPlayers;

  FakeEventRepository([List<Event>? events]) : events = events ?? [];

  @override
  Future<List<Event>> getEvents(String gameId) async =>
      events.where((e) => e.gameId == gameId).toList();

  @override
  Future<Event> createEvent(Event event, List<EventPlayer> players) async {
    lastCreated = event;
    lastPlayers = players;
    events.add(event);
    return event;
  }

  @override
  Future<void> updateEvent(Event event, List<EventPlayer> players) async {
    lastUpdated = event;
    lastPlayers = players;
  }

  @override
  Future<void> deleteEvent(String id) async =>
      events.removeWhere((e) => e.id == id);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// ── Hilfsfunktionen ──────────────────────────────────────────────────────────

const _gameId = 'g1';

Event _goal(
  String id, {
  TeamSide? team = TeamSide.home,
  int? number,
  bool ownGoal = false,
  RefDecision? decision = RefDecision.goal,
  EventType type = EventType.goalDecision,
  int minute = 10,
  GamePhase phase = GamePhase.ersteHalbzeit,
}) =>
    Event(
      id: id,
      gameId: _gameId,
      elapsedMs: minute * 60 * 1000,
      gamePhase: phase,
      type: type,
      locationX: 0.5,
      locationY: 0.1,
      refDecision: decision,
      goalScorerTeam: team,
      goalScorerNumber: number,
      ownGoal: ownGoal,
      createdAt: DateTime(2026, 7, 1),
    );

Game _game() => Game(
      id: _gameId,
      date: DateTime(2026, 7, 1),
      homeTeamName: 'Heim',
      awayTeamName: 'Gast',
      createdAt: DateTime(2026, 7, 1),
    );

Future<FakeTimerRepository> _timerRepo() async {
  final repo = FakeTimerRepository();
  await repo.saveTimerState(TimerState(
    gameId: _gameId,
    isRunning: false,
    elapsedMs: 30 * 60 * 1000,
    phase: GamePhase.halbzeit,
  ));
  return repo;
}

Future<void> _pumpForm(
  WidgetTester tester,
  FakeEventRepository eventRepo, {
  Event? initialEvent,
}) async {
  final timerRepo = await _timerRepo();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      timerRepositoryProvider.overrideWithValue(timerRepo),
      eventRepositoryProvider.overrideWithValue(eventRepo),
      homeSquadProvider(_gameId).overrideWith((_) async => [7, 9, 11]),
      awaySquadProvider(_gameId).overrideWith((_) async => [4, 10]),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: EventFormPanel(
          gameId: _gameId,
          locationX: 0.5,
          locationY: 0.1,
          onClose: () {},
          onSaved: (_) {},
          initialEvent: initialEvent,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _pumpLive(WidgetTester tester, FakeEventRepository repo) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final timerRepo = await _timerRepo();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      timerRepositoryProvider.overrideWithValue(timerRepo),
      eventRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(home: LiveScreen(game: _game())),
  ));
  await tester.pumpAndSettle();
}

String _preview(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('goal_preview'))).data!;

void main() {
  // ── Zählregel ──────────────────────────────────────────────────────────────

  group('Zählregel (US-214)', () {
    test('TC-2141: Tor für Heim', () {
      expect(Score.fromEvents([_goal('a')]), const Score(1, 0));
    });

    test('TC-2142: Tor für Gast', () {
      expect(Score.fromEvents([_goal('a', team: TeamSide.away)]),
          const Score(0, 1));
    });

    test('TC-2143: Eigentor wird dem Gegner gutgeschrieben', () {
      expect(Score.fromEvents([_goal('a', ownGoal: true)]), const Score(0, 1));
    });

    test('TC-2144: Aberkanntes Tor zählt nicht', () {
      expect(
          Score.fromEvents([
            _goal('a', decision: RefDecision.indirectFreeKick),
            _goal('b', decision: null),
          ]),
          Score.zero);
    });

    test('TC-2145: Tor ohne Team zählt nicht', () {
      expect(Score.fromEvents([_goal('a', team: null)]), Score.zero);
    });

    test('TC-2146: Nur Torentscheidungen zählen', () {
      expect(Score.fromEvents([_goal('a', type: EventType.footFoul)]),
          Score.zero);
    });

    test('TC-2147: Gemischter Spielverlauf', () {
      final score = Score.fromEvents([
        _goal('a'),
        _goal('b', team: TeamSide.away),
        _goal('c', team: TeamSide.away, ownGoal: true),
        _goal('d', decision: RefDecision.indirectFreeKick),
      ]);
      expect(score, const Score(2, 1));
      expect(score.label, '2 : 1');
    });

    test('Laufender Spielstand: Nachspielzeit 1. HZ vor 2. HZ', () {
      final running = Score.runningByEventId([
        _goal('zweite', minute: 46, phase: GamePhase.zweiteHalbzeit),
        _goal('nachspiel',
            team: TeamSide.away,
            minute: 47,
            phase: GamePhase.ersteHalbzeitNachspielzeit),
      ]);
      expect(running['nachspiel'], const Score(0, 1));
      expect(running['zweite'], const Score(1, 1));
    });
  });

  // ── Ereignisformular ───────────────────────────────────────────────────────

  group('Ereignisformular (US-214)', () {
    testWidgets('TC-2148: Abschnitt „Tor" und vorausgewählte Entscheidung',
        (tester) async {
      await _pumpForm(tester, FakeEventRepository());
      await tester.tap(find.byKey(const Key('event_type_goalDecision')));
      await tester.pumpAndSettle();

      expect(find.text('TOR'), findsOneWidget);
      expect(find.text('Torschütze'), findsOneWidget);
      expect(find.byKey(const Key('toggle_own_goal')), findsOneWidget);
      expect(find.text('Fouler'), findsNothing);

      // Entscheidung „Tor" ausgewählt → Vorschau fordert nur noch Team
      expect(_preview(tester), 'Team wählen, damit das Tor zählt');
    });

    testWidgets('TC-2149: Vorschau-Zeile — alle Zustände', (tester) async {
      final repo = FakeEventRepository([
        _goal('h'),
        _goal('a', team: TeamSide.away),
      ]);
      await _pumpForm(tester, repo);
      await tester.tap(find.byKey(const Key('event_type_goalDecision')));
      await tester.pumpAndSettle();
      expect(_preview(tester), 'Team wählen, damit das Tor zählt');

      await tester.tap(find.byKey(const Key('scorer_team_home')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('#9'));
      await tester.pumpAndSettle();
      expect(_preview(tester), 'Tor für HEIM · #9 → 2 : 1');

      await tester.tap(find.byKey(const Key('toggle_own_goal')));
      await tester.pumpAndSettle();
      expect(_preview(tester), 'Eigentor #9 (Heim) → Tor für GAST · 1 : 2');

      await tester.ensureVisible(find.byKey(const Key('decision_goal')));
      await tester.tap(find.byKey(const Key('decision_goal')));
      await tester.pumpAndSettle();
      expect(_preview(tester), 'Tor aberkannt – Spielstand bleibt 1 : 1');
    });

    testWidgets('TC-2150: Speichern mit Torschütze', (tester) async {
      final repo = FakeEventRepository();
      await _pumpForm(tester, repo);
      await tester.tap(find.byKey(const Key('event_type_goalDecision')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('scorer_team_home')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('#9'));
      await tester.tap(find.byKey(const Key('toggle_own_goal')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pumpAndSettle();

      final e = repo.lastCreated!;
      expect(e.goalScorerTeam, TeamSide.home);
      expect(e.goalScorerNumber, 9);
      expect(e.ownGoal, isTrue);
      expect(e.refDecision, RefDecision.goal);
      expect(repo.lastPlayers, isEmpty);
    });

    testWidgets('TC-2151: Speichern ohne Team möglich', (tester) async {
      final repo = FakeEventRepository();
      await _pumpForm(tester, repo);
      await tester.tap(find.byKey(const Key('event_type_goalDecision')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pumpAndSettle();

      expect(repo.lastCreated, isNotNull);
      expect(repo.lastCreated!.goalScorerTeam, isNull);
    });

    testWidgets('TC-2152: Typwechsel verwirft Torschütze', (tester) async {
      final repo = FakeEventRepository();
      await _pumpForm(tester, repo);
      await tester.tap(find.byKey(const Key('event_type_goalDecision')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('scorer_team_home')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('#9'));
      await tester.tap(find.byKey(const Key('toggle_own_goal')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pumpAndSettle();

      final e = repo.lastCreated!;
      expect(e.type, EventType.footFoul);
      expect(e.goalScorerTeam, isNull);
      expect(e.goalScorerNumber, isNull);
      expect(e.ownGoal, isFalse);
    });

    testWidgets('TC-2153: Bearbeiten — Vorausfüllung', (tester) async {
      final initial =
          _goal('e1', team: TeamSide.away, number: 4, ownGoal: true);
      final repo = FakeEventRepository([initial]);
      await _pumpForm(tester, repo, initialEvent: initial);

      final field =
          tester.widget<TextField>(find.byKey(const Key('scorer_number')));
      expect(field.controller!.text, '4');
      // Eigener Beitrag wird herausgerechnet → 0:0 + Tor für Heim
      expect(_preview(tester), 'Eigentor #4 (Gast) → Tor für HEIM · 1 : 0');

      // Eigentor aus → Gutschrift wechselt, gespeicherte Werte stimmen
      await tester.tap(find.byKey(const Key('toggle_own_goal')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pumpAndSettle();
      expect(repo.lastUpdated!.ownGoal, isFalse);
      expect(repo.lastUpdated!.goalScorerTeam, TeamSide.away);
      expect(repo.lastUpdated!.goalScorerNumber, 4);
    });
  });

  // ── Live-Screen ────────────────────────────────────────────────────────────

  group('Live-Screen (US-214)', () {
    testWidgets('TC-2154: Spielstand in der Kopfzeile', (tester) async {
      await _pumpLive(tester, FakeEventRepository());
      expect(find.text('0 : 0'), findsOneWidget);

      await _pumpLive(
          tester,
          FakeEventRepository([
            _goal('a', minute: 5),
            _goal('b', minute: 10),
            _goal('c', team: TeamSide.away, minute: 20),
          ]));
      expect(
          tester.widget<Text>(find.byKey(const Key('live_score'))).data,
          '2 : 1');
    });

    testWidgets('TC-2155: Spielstand aktualisiert sich nach Löschen',
        (tester) async {
      await _pumpLive(tester, FakeEventRepository([_goal('a')]));
      expect(find.text('1 : 0'), findsOneWidget);

      await tester.tap(find.byTooltip('Löschen'));
      await tester.pumpAndSettle();
      expect(find.text('0 : 0'), findsOneWidget);
    });

    testWidgets('TC-2155b: Spielstand leuchtet bei Änderung kurz auf',
        (tester) async {
      await _pumpLive(tester, FakeEventRepository([_goal('a')]));

      Color highlight() {
        final box = tester.widget<Container>(find
            .ancestor(
                of: find.byKey(const Key('live_score')),
                matching: find.byType(Container))
            .first);
        return (box.decoration as BoxDecoration).color!;
      }

      expect(highlight().a, 0);

      await tester.tap(find.byTooltip('Löschen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(highlight().a, greaterThan(0));

      await tester.pumpAndSettle();
      expect(highlight().a, 0);
    });

    testWidgets('TC-2156: Seitenpanel zeigt Spielstand nach dem Tor',
        (tester) async {
      await _pumpLive(
          tester,
          FakeEventRepository([
            _goal('a', minute: 5),
            _goal('b', team: TeamSide.away, minute: 10),
            _goal('c', decision: RefDecision.indirectFreeKick, minute: 15),
          ]));

      expect(find.text('⚽ Tor 1:0'), findsOneWidget);
      expect(find.text('⚽ Tor 1:1'), findsOneWidget);
      expect(find.text('Torentsch.'), findsOneWidget);
    });
  });

  // ── Persistenz ─────────────────────────────────────────────────────────────

  group('Persistenz (US-214)', () {
    late AppDatabase db;
    late EventRepositoryImpl repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = EventRepositoryImpl(db);
      await GameRepositoryImpl(db).createGame(_game());
    });

    tearDown(() => db.close());

    test('TC-2157: Torschützen-Felder überleben Speichern/Laden', () async {
      await repo.createEvent(
          _goal('e1', team: TeamSide.away, number: 10, ownGoal: true), []);
      var loaded = (await repo.getEvent('e1'))!;
      expect(loaded.goalScorerTeam, TeamSide.away);
      expect(loaded.goalScorerNumber, 10);
      expect(loaded.ownGoal, isTrue);

      await repo.updateEvent(_goal('e1', team: TeamSide.home), []);
      loaded = (await repo.getEvent('e1'))!;
      expect(loaded.goalScorerTeam, TeamSide.home);
      expect(loaded.goalScorerNumber, isNull);
      expect(loaded.ownGoal, isFalse);
    });

    test('TC-2159: Torschütze nicht im Spieler-Ranking', () async {
      await repo.createEvent(_goal('e1', number: 9), []);
      final container = ProviderContainer(
          overrides: [eventRepositoryProvider.overrideWithValue(repo)]);
      addTearDown(container.dispose);

      final ranking =
          await container.read(playerRankingProvider(_gameId).future);
      expect(ranking, isEmpty);
    });
  });

  test('TC-2158: Migration v4 → v5 erhält Ereignisse', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      // Minimales v4-Schema der events-Tabelle mit einem Bestandsereignis
      raw.execute('''
        CREATE TABLE events (
          id TEXT NOT NULL PRIMARY KEY,
          game_id TEXT NOT NULL,
          elapsed_ms INTEGER NOT NULL,
          game_phase TEXT NOT NULL DEFAULT 'ersteHalbzeit',
          type TEXT NOT NULL,
          custom_type_label TEXT,
          location_x REAL NOT NULL,
          location_y REAL NOT NULL,
          ref_decision TEXT,
          card TEXT,
          assessment TEXT,
          scene_note TEXT,
          coaching_flag INTEGER NOT NULL DEFAULT 0,
          coaching_note TEXT,
          created_at INTEGER NOT NULL
        );
      ''');
      raw.execute('''
        INSERT INTO events (id, game_id, elapsed_ms, type, location_x,
          location_y, ref_decision, created_at)
        VALUES ('alt', 'g1', 600000, 'goalDecision', 0.5, 0.1, 'goal',
          1751328000);
      ''');
      raw.execute('PRAGMA user_version = 4;');
    }));
    addTearDown(db.close);

    expect(db.schemaVersion, 5);
    final rows = await db.select(db.events).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'alt');
    expect(rows.single.goalScorerTeam, isNull);
    expect(rows.single.goalScorerNumber, isNull);
    expect(rows.single.ownGoal, isFalse);

    final columns = await db
        .customSelect("SELECT name FROM pragma_table_info('events')")
        .map((r) => r.read<String>('name'))
        .get();
    expect(columns,
        containsAll(['goal_scorer_team', 'goal_scorer_number', 'own_goal']));
  });
}
