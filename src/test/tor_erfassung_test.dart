import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/data/repositories/event_repository_impl.dart';
import 'package:beobachter_app/data/repositories/game_repository_impl.dart';
import 'package:beobachter_app/data/repositories/goal_repository_impl.dart';
import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/goal.dart';
import 'package:beobachter_app/domain/entities/score.dart';
import 'package:beobachter_app/domain/entities/team_fouls.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/goal_kind.dart';
import 'package:beobachter_app/domain/enums/player_role.dart';
import 'package:beobachter_app/domain/enums/ref_decision.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/domain/repositories/event_repository.dart';
import 'package:beobachter_app/domain/repositories/goal_repository.dart';
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

class FakeEventRepository implements EventRepository {
  final List<Event> events;

  FakeEventRepository([List<Event>? events]) : events = events ?? [];

  @override
  Future<List<Event>> getEvents(String gameId) async =>
      events.where((e) => e.gameId == gameId).toList();

  @override
  Future<void> deleteEvent(String id) async =>
      events.removeWhere((e) => e.id == id);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// In-Memory-GoalRepository: vergibt IDs wie die echte Implementierung.
class FakeGoalRepository implements GoalRepository {
  final List<Goal> goals;
  Goal? lastCreated;
  Goal? lastUpdated;
  int _next = 0;

  FakeGoalRepository([List<Goal>? goals]) : goals = goals ?? [];

  @override
  Future<Goal> createGoal(Goal goal) async {
    final saved = Goal(
      id: goal.id.isEmpty ? 'new${_next++}' : goal.id,
      gameId: goal.gameId,
      elapsedMs: goal.elapsedMs,
      gamePhase: goal.gamePhase,
      team: goal.team,
      scorerNumber: goal.scorerNumber,
      kind: goal.kind,
      createdAt: goal.createdAt,
    );
    lastCreated = saved;
    goals.add(saved);
    return saved;
  }

  @override
  Future<List<Goal>> getGoals(String gameId) async =>
      goals.where((g) => g.gameId == gameId).toList();

  @override
  Future<void> updateGoal(Goal goal) async {
    lastUpdated = goal;
    final i = goals.indexWhere((g) => g.id == goal.id);
    if (i >= 0) goals[i] = goal;
  }

  @override
  Future<void> deleteGoal(String id) async =>
      goals.removeWhere((g) => g.id == id);
}

// ── Hilfsfunktionen ──────────────────────────────────────────────────────────

const _gameId = 'g1';

Goal _goal(
  String id, {
  TeamSide team = TeamSide.home,
  int? number,
  GoalKind kind = GoalKind.regular,
  int minute = 10,
  GamePhase phase = GamePhase.ersteHalbzeit,
}) =>
    Goal(
      id: id,
      gameId: _gameId,
      elapsedMs: minute * 60 * 1000,
      gamePhase: phase,
      team: team,
      scorerNumber: number,
      kind: kind,
      createdAt: DateTime(2026, 7, 1),
    );

Event _event(String id, {int minute = 10, EventType type = EventType.footFoul}) =>
    Event(
      id: id,
      gameId: _gameId,
      elapsedMs: minute * 60 * 1000,
      type: type,
      locationX: 0.5,
      locationY: 0.5,
      createdAt: DateTime(2026, 7, 1),
    );

Game _game() => Game(
      id: _gameId,
      date: DateTime(2026, 7, 1),
      homeTeamName: 'FC Heim',
      awayTeamName: 'SV Gast',
      createdAt: DateTime(2026, 7, 1),
    );

Future<void> _pumpLive(
  WidgetTester tester, {
  FakeGoalRepository? goals,
  FakeEventRepository? events,
  GamePhase phase = GamePhase.halbzeit,
}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final timerRepo = FakeTimerRepository();
  await timerRepo.saveTimerState(TimerState(
    gameId: _gameId,
    isRunning: false,
    elapsedMs: 30 * 60 * 1000,
    phase: phase,
  ));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      timerRepositoryProvider.overrideWithValue(timerRepo),
      eventRepositoryProvider.overrideWithValue(events ?? FakeEventRepository()),
      goalRepositoryProvider.overrideWithValue(goals ?? FakeGoalRepository()),
      homeSquadProvider(_gameId).overrideWith((_) async => [7, 9, 11]),
      awaySquadProvider(_gameId).overrideWith((_) async => [4, 10]),
    ],
    child: MaterialApp(home: LiveScreen(game: _game())),
  ));
  await tester.pumpAndSettle();
}

String _preview(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('goal_preview'))).data!;

String _score(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('live_score'))).data!;

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

void main() {
  // ── Spielstand ─────────────────────────────────────────────────────────────

  group('Spielstand (US-215)', () {
    test('TC-215-01: Tor zählt für das gewählte Team', () {
      expect(Score.fromGoals([_goal('a')]), const Score(1, 0));
      expect(Score.fromGoals([_goal('a', team: TeamSide.away)]),
          const Score(0, 1));
    });

    test('TC-215-02: Eigentor zählt für das begünstigte Team', () {
      final g = _goal('a', kind: GoalKind.ownGoal);
      expect(Score.fromGoals([g]), const Score(1, 0));
      expect(g.scorerTeam, TeamSide.away);
    });

    test('TC-215-03: Laufender Spielstand nach Phase und Zeit', () {
      final running = Score.runningByGoalId([
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

  // ── Kopfzeile & Dialog ─────────────────────────────────────────────────────

  group('Kopfzeile & Dialog (US-215)', () {
    testWidgets('TC-215-04: Tor-Buttons links Heim, rechts Gast',
        (tester) async {
      await _pumpLive(tester);
      final home = find.byKey(const Key('btn_goal_home'));
      final away = find.byKey(const Key('btn_goal_away'));
      expect(home, findsOneWidget);
      expect(away, findsOneWidget);
      expect(tester.getCenter(home).dx,
          lessThan(tester.getCenter(find.byKey(const Key('live_score'))).dx));
      expect(tester.getCenter(away).dx,
          greaterThan(tester.getCenter(find.byKey(const Key('live_score'))).dx));
      expect(tester.widget<ButtonStyleButton>(home).enabled, isTrue);
    });

    testWidgets('TC-215-05: Buttons bei abgeschlossenem Spiel deaktiviert',
        (tester) async {
      await _pumpLive(tester, phase: GamePhase.abgeschlossen);
      for (final key in ['btn_goal_home', 'btn_goal_away']) {
        final button = tester.widget<ButtonStyleButton>(find.byKey(Key(key)));
        expect(button.enabled, isFalse, reason: key);
      }
      await tester.tap(find.byKey(const Key('btn_goal_home')),
          warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('goal_dialog_title')), findsNothing);
    });

    testWidgets('TC-215-06/07: Schnellster Weg — 2 Taps, Zeit vom Button-Tap',
        (tester) async {
      final goals = FakeGoalRepository();
      await _pumpLive(tester, goals: goals);
      await _tap(tester, 'btn_goal_home');
      expect(find.text('Tor für HEIM'), findsOneWidget);
      expect(find.text('FC Heim'), findsWidgets);
      await _tap(tester, 'btn_save_goal');

      final g = goals.lastCreated!;
      expect(g.team, TeamSide.home);
      expect(g.kind, GoalKind.regular);
      expect(g.scorerNumber, isNull);
      expect(g.elapsedMs, 30 * 60 * 1000);
      expect(g.gamePhase, GamePhase.halbzeit);
      expect(find.byKey(const Key('goal_dialog_title')), findsNothing);
      expect(_score(tester), '1 : 0');
    });

    testWidgets('TC-215-08: Strafstoßtor mit Torschütze aus eigenem Kader',
        (tester) async {
      final goals = FakeGoalRepository();
      await _pumpLive(tester, goals: goals);
      await _tap(tester, 'btn_goal_home');
      await _tap(tester, 'goal_kind_penalty');

      // Heim-Kader, kein Gast-Kader
      expect(find.byKey(const Key('goal_scorer_chip_9')), findsOneWidget);
      expect(find.byKey(const Key('goal_scorer_chip_4')), findsNothing);

      await _tap(tester, 'goal_scorer_chip_9');
      expect(_preview(tester), 'Tor für HEIM · #9 (Strafstoß) → 1 : 0');
      await _tap(tester, 'btn_save_goal');

      expect(goals.lastCreated!.kind, GoalKind.penalty);
      expect(goals.lastCreated!.scorerNumber, 9);
    });

    testWidgets('TC-215-09: Eigentor — nur Kader der verteidigenden Mannschaft',
        (tester) async {
      final goals = FakeGoalRepository();
      await _pumpLive(tester, goals: goals);
      await _tap(tester, 'btn_goal_home');
      await _tap(tester, 'goal_scorer_chip_9');
      await _tap(tester, 'goal_kind_ownGoal');

      // #9 verworfen, nur Gast-Kader sichtbar
      expect(find.byKey(const Key('goal_scorer_chip_9')), findsNothing);
      expect(find.byKey(const Key('goal_scorer_chip_7')), findsNothing);
      expect(find.byKey(const Key('goal_scorer_chip_4')), findsOneWidget);
      expect(find.text('TORSCHÜTZE (GAST · EIGENTOR)'), findsOneWidget);
      expect(_preview(tester), 'Eigentor (Gast) → Tor für HEIM · 1 : 0');

      await _tap(tester, 'goal_scorer_chip_4');
      expect(_preview(tester), 'Eigentor #4 (Gast) → Tor für HEIM · 1 : 0');
      await _tap(tester, 'btn_save_goal');

      final g = goals.lastCreated!;
      expect(g.team, TeamSide.home);
      expect(g.kind, GoalKind.ownGoal);
      expect(g.scorerNumber, 4);
      expect(_score(tester), '1 : 0');
    });

    testWidgets('TC-215-10: Abbrechen verwirft das Tor', (tester) async {
      final goals = FakeGoalRepository();
      await _pumpLive(tester, goals: goals);
      await _tap(tester, 'btn_goal_away');
      await _tap(tester, 'btn_cancel_goal');

      expect(goals.goals, isEmpty);
      expect(_score(tester), '0 : 0');
    });

    testWidgets('TC-215-11: Vorschau berücksichtigt bestehende Tore',
        (tester) async {
      await _pumpLive(tester,
          goals: FakeGoalRepository([
            _goal('a'),
            _goal('b', team: TeamSide.away, minute: 20),
          ]));
      await _tap(tester, 'btn_goal_away');
      expect(_preview(tester), 'Tor für GAST → 1 : 2');
    });
  });

  // ── „Letzte Ereignisse" ────────────────────────────────────────────────────

  group('Letzte Ereignisse (US-215)', () {
    testWidgets('TC-215-12: Tore chronologisch zwischen Ereignissen',
        (tester) async {
      await _pumpLive(
        tester,
        events: FakeEventRepository([
          _event('e10', minute: 10),
          _event('e30', minute: 30),
        ]),
        goals: FakeGoalRepository([
          _goal('g20', minute: 20, number: 9, kind: GoalKind.penalty),
          _goal('g40',
              minute: 40, team: TeamSide.away, kind: GoalKind.ownGoal),
        ]),
      );

      double y(String key) => tester.getTopLeft(find.byKey(Key(key))).dy;
      expect(y('recent_goal_g40'), lessThan(y('recent_event_e30')));
      expect(y('recent_event_e30'), lessThan(y('recent_goal_g20')));
      expect(y('recent_goal_g20'), lessThan(y('recent_event_e10')));
      expect(find.text('⚽ 1:1 · ET'), findsOneWidget);
      expect(find.text('⚽ 1:0 · #9 · 11m'), findsOneWidget);
    });

    testWidgets('TC-215-13: Tor löschen senkt den Spielstand', (tester) async {
      final goals = FakeGoalRepository([_goal('a')]);
      await _pumpLive(tester, goals: goals);
      expect(_score(tester), '1 : 0');

      await tester.tap(find.descendant(
          of: find.byKey(const Key('recent_goal_a')),
          matching: find.byTooltip('Löschen')));
      await tester.pumpAndSettle();
      expect(goals.goals, isEmpty);
      expect(_score(tester), '0 : 0');
    });

    testWidgets('TC-215-14: Tor bearbeiten', (tester) async {
      final goals = FakeGoalRepository([_goal('a', minute: 12)]);
      await _pumpLive(tester, goals: goals);

      await _tap(tester, 'recent_goal_a');
      expect(find.text('Tor bearbeiten'), findsOneWidget);
      // Eigener Beitrag herausgerechnet
      expect(_preview(tester), 'Tor für HEIM → 1 : 0');

      await _tap(tester, 'goal_kind_ownGoal');
      await _tap(tester, 'goal_scorer_chip_10');
      await _tap(tester, 'btn_save_goal');

      final g = goals.lastUpdated!;
      expect(g.id, 'a');
      expect(g.kind, GoalKind.ownGoal);
      expect(g.scorerNumber, 10);
      expect(g.elapsedMs, 12 * 60 * 1000);
      expect(find.text('⚽ 1:0 · #10 · ET'), findsOneWidget);
    });
  });

  // ── Abgrenzung ─────────────────────────────────────────────────────────────

  group('Abgrenzung (US-215)', () {
    testWidgets('TC-215-16: Kein Typ Torentscheidung, keine Entscheidung Tor',
        (tester) async {
      final timerRepo = FakeTimerRepository();
      await timerRepo.saveTimerState(const TimerState(
        gameId: _gameId,
        isRunning: false,
        elapsedMs: 0,
        phase: GamePhase.ersteHalbzeit,
      ));
      await tester.pumpWidget(ProviderScope(
        overrides: [
          timerRepositoryProvider.overrideWithValue(timerRepo),
          eventRepositoryProvider.overrideWithValue(FakeEventRepository()),
          homeSquadProvider(_gameId).overrideWith((_) async => []),
          awaySquadProvider(_gameId).overrideWith((_) async => []),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: EventFormPanel(
              gameId: _gameId,
              locationX: 0.5,
              locationY: 0.5,
              onClose: () {},
              onSaved: (_) {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Torentsch.'), findsNothing);
      await _tap(tester, 'event_type_offside');
      expect(find.byKey(const Key('decision_goal')), findsNothing);
      expect(find.byKey(const Key('decision_freeKick')), findsOneWidget);
      expect(find.text('Torschütze'), findsNothing);
    });

    test('TC-215-15: Tore nicht im Spieler-Ranking und nicht als Ereignis',
        () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await GameRepositoryImpl(db).createGame(_game());
      await GoalRepositoryImpl(db).createGoal(_goal('a', number: 9));

      final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);

      expect(await container.read(playerRankingProvider(_gameId).future),
          isEmpty);
      expect(await container.read(eventsProvider(_gameId).future), isEmpty);
      final fouls = await container.read(teamFoulsProvider(_gameId).future);
      for (final period in FoulPeriod.values) {
        for (final team in TeamSide.values) {
          expect(fouls.total(period, team), 0);
        }
      }
    });
  });

  // ── Persistenz & Migration ─────────────────────────────────────────────────

  group('Persistenz (US-215)', () {
    late AppDatabase db;
    late GoalRepositoryImpl repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = GoalRepositoryImpl(db);
      await GameRepositoryImpl(db).createGame(_game());
    });

    tearDown(() => db.close());

    test('TC-215-18: Tor überlebt Speichern/Laden/Bearbeiten/Löschen',
        () async {
      final created = await repo.createGoal(Goal(
        id: '',
        gameId: _gameId,
        elapsedMs: 47 * 60 * 1000,
        gamePhase: GamePhase.ersteHalbzeitNachspielzeit,
        team: TeamSide.away,
        scorerNumber: 4,
        kind: GoalKind.ownGoal,
        createdAt: DateTime(2026, 7, 1),
      ));
      expect(created.id, isNotEmpty);

      var loaded = (await repo.getGoals(_gameId)).single;
      expect(loaded.team, TeamSide.away);
      expect(loaded.scorerNumber, 4);
      expect(loaded.kind, GoalKind.ownGoal);
      expect(loaded.gamePhase, GamePhase.ersteHalbzeitNachspielzeit);
      expect(loaded.elapsedMs, 47 * 60 * 1000);

      await repo.updateGoal(Goal(
        id: created.id,
        gameId: _gameId,
        elapsedMs: loaded.elapsedMs,
        gamePhase: loaded.gamePhase,
        team: TeamSide.away,
        kind: GoalKind.penalty,
        createdAt: loaded.createdAt,
      ));
      loaded = (await repo.getGoals(_gameId)).single;
      expect(loaded.scorerNumber, isNull);
      expect(loaded.kind, GoalKind.penalty);

      await repo.deleteGoal(created.id);
      expect(await repo.getGoals(_gameId), isEmpty);
    });

    test('TC-215-19: Spiel löschen löscht seine Tore', () async {
      await repo.createGoal(_goal('a'));
      await GameRepositoryImpl(db).deleteGame(_gameId);
      expect(await repo.getGoals(_gameId), isEmpty);
    });

    test('US-403: Spieler-Ranking zählt nur Täter, nicht Gefoulte', () async {
      final events = EventRepositoryImpl(db);
      EventPlayer player(String id, String eventId, PlayerRole role,
              TeamSide team, int number) =>
          EventPlayer(
              id: id,
              eventId: eventId,
              role: role,
              team: team,
              jerseyNumber: number);

      await events.createEvent(_event('e1'), [
        player('p1', 'e1', PlayerRole.fouler, TeamSide.home, 4),
        player('p2', 'e1', PlayerRole.fouled, TeamSide.away, 10),
      ]);
      await events.createEvent(_event('e2'), [
        player('p3', 'e2', PlayerRole.fouler, TeamSide.home, 4),
        player('p4', 'e2', PlayerRole.fouled, TeamSide.away, 10),
      ]);
      final container = ProviderContainer(
          overrides: [eventRepositoryProvider.overrideWithValue(events)]);
      addTearDown(container.dispose);

      final ranking =
          await container.read(playerRankingProvider(_gameId).future);
      expect(ranking, hasLength(1));
      expect(ranking.single.team, TeamSide.home);
      expect(ranking.single.number, 4);
      expect(ranking.single.count, 2);
    });
  });

  test('TC-215-20: Migration v6 → v7 übernimmt gezählte Tore', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
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
          goal_scorer_team TEXT,
          goal_scorer_number INTEGER,
          own_goal INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL
        );
      ''');
      raw.execute('''
        INSERT INTO events (id, game_id, elapsed_ms, game_phase, type,
          location_x, location_y, ref_decision, assessment, scene_note,
          goal_scorer_team, goal_scorer_number, own_goal, created_at)
        VALUES
          ('tor', 'g1', 600000, 'ersteHalbzeit', 'goalDecision', 0.9, 0.5,
            'goal', NULL, NULL, 'home', 9, 0, 1751328000),
          ('eigentor', 'g1', 3000000, 'zweiteHalbzeit', 'goalDecision', 0.1,
            0.5, 'goal', NULL, NULL, 'home', 4, 1, 1751328000),
          ('aberkannt', 'g1', 1200000, 'ersteHalbzeit', 'goalDecision', 0.9,
            0.4, 'indirectFreeKick', 'correctComplex', 'Abseits', 'away', 10,
            0, 1751328000),
          ('ohneTeam', 'g1', 1800000, 'ersteHalbzeit', 'goalDecision', 0.9,
            0.6, 'goal', NULL, NULL, NULL, NULL, 0, 1751328000),
          ('foul', 'g1', 900000, 'ersteHalbzeit', 'footFoul', 0.5, 0.5,
            'freeKick', NULL, NULL, NULL, NULL, 0, 1751328000);
      ''');
      raw.execute('''
        CREATE TABLE event_players (
          id TEXT NOT NULL PRIMARY KEY,
          event_id TEXT NOT NULL,
          role TEXT NOT NULL,
          team TEXT NOT NULL,
          jersey_number INTEGER
        );
      ''');
      raw.execute('PRAGMA user_version = 6;');
    }));
    addTearDown(db.close);

    expect(db.schemaVersion, 7);
    final goals = await GoalRepositoryImpl(db).getGoals('g1');
    expect(goals, hasLength(2));
    final tor = goals.firstWhere((g) => g.id == 'tor');
    expect(tor.team, TeamSide.home);
    expect(tor.scorerNumber, 9);
    expect(tor.kind, GoalKind.regular);
    expect(tor.elapsedMs, 600000);
    final eigentor = goals.firstWhere((g) => g.id == 'eigentor');
    expect(eigentor.team, TeamSide.away);
    expect(eigentor.scorerTeam, TeamSide.home);
    expect(eigentor.scorerNumber, 4);
    expect(eigentor.kind, GoalKind.ownGoal);
    expect(eigentor.gamePhase, GamePhase.zweiteHalbzeit);
    expect(Score.fromGoals(goals), const Score(1, 1));

    final events = await EventRepositoryImpl(db).getEvents('g1');
    expect(events, hasLength(5));
    for (final id in ['tor', 'eigentor', 'aberkannt', 'ohneTeam']) {
      final e = events.firstWhere((e) => e.id == id);
      expect(e.type, EventType.custom, reason: id);
      expect(e.customTypeLabel, 'Torentscheidung', reason: id);
    }
    final aberkannt = events.firstWhere((e) => e.id == 'aberkannt');
    expect(aberkannt.refDecision, RefDecision.indirectFreeKick);
    expect(aberkannt.sceneNote, 'Abseits');
    expect(aberkannt.locationY, 0.4);
    expect(events.firstWhere((e) => e.id == 'foul').type, EventType.footFoul);
  });

  test('Migration v4 → v7 erhält Ereignisse ohne Torschützen', () async {
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
      // v6-Migration baut event_players neu auf (US-404)
      raw.execute('''
        CREATE TABLE event_players (
          id TEXT NOT NULL PRIMARY KEY,
          event_id TEXT NOT NULL,
          role TEXT NOT NULL,
          team TEXT NOT NULL,
          jersey_number INTEGER NOT NULL
        );
      ''');
      raw.execute('PRAGMA user_version = 4;');
    }));
    addTearDown(db.close);

    final events = await EventRepositoryImpl(db).getEvents('g1');
    expect(events.single.id, 'alt');
    expect(events.single.type, EventType.custom);
    expect(await GoalRepositoryImpl(db).getGoals('g1'), isEmpty);
  });
}
