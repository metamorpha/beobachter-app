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
import 'package:beobachter_app/domain/entities/team_fouls.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/player_role.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/domain/repositories/event_repository.dart';
import 'package:beobachter_app/domain/repositories/game_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeEventRepository implements EventRepository {
  final List<Event> events;
  final List<EventPlayer> players;

  _FakeEventRepository(this.events, [this.players = const []]);

  @override
  Future<List<Event>> getEvents(String gameId) async =>
      events.where((e) => e.gameId == gameId).toList();

  @override
  Future<List<EventPlayer>> getPlayersForGame(String gameId) async => players;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeGameRepository implements GameRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// ── Hilfsfunktionen ──────────────────────────────────────────────────────────

const _gameId = 'g1';

Event _event(
  String id,
  EventType type, {
  GamePhase phase = GamePhase.ersteHalbzeit,
}) =>
    Event(
      id: id,
      gameId: _gameId,
      elapsedMs: 10 * 60 * 1000,
      gamePhase: phase,
      type: type,
      locationX: 0.5,
      locationY: 0.5,
      createdAt: DateTime(2026, 10, 22),
    );

EventPlayer _player(String eventId, PlayerRole role, TeamSide team,
        [int? number]) =>
    EventPlayer(
      id: '$eventId-${role.name}',
      eventId: eventId,
      role: role,
      team: team,
      jerseyNumber: number,
    );

EventPlayer _fouler(String eventId, TeamSide team, [int? number]) =>
    _player(eventId, PlayerRole.fouler, team, number);

/// Summe aller Zellen — 0 heißt: nichts gezählt.
int _sumAll(TeamFouls fouls) => [
      for (final period in FoulPeriod.values)
        for (final team in TeamSide.values) fouls.total(period, team)
    ].fold(0, (a, b) => a + b);

Game _game() => Game(
      id: _gameId,
      date: DateTime(2026, 10, 22),
      homeTeamName: 'Heim',
      awayTeamName: 'Gast',
      createdAt: DateTime(2026, 10, 22),
    );

Future<void> _openStatsTab(
    WidgetTester tester, _FakeEventRepository eventRepo) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      eventRepositoryProvider.overrideWithValue(eventRepo),
      gameRepositoryProvider.overrideWithValue(_FakeGameRepository()),
    ],
    child: MaterialApp(home: ReviewScreen(game: _game())),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Statistik'));
  await tester.pumpAndSettle();
}

/// Zahlenzellen einer Tabellenzeile, von links nach rechts.
List<String> _rowValues(WidgetTester tester, String label) {
  final row = find
      .ancestor(of: find.text(label), matching: find.byType(Row))
      .first;
  return tester
      .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
      .map((t) => t.data!)
      .where((s) => s != label)
      .toList();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Zählregel (US-404)', () {
    test('TC-4041: Kategorien werden korrekt zugeordnet', () {
      final types = [
        EventType.footFoul,
        EventType.bodyFoul,
        EventType.handball,
        EventType.unsporting,
        EventType.violent,
        EventType.custom,
      ];
      final events = [
        for (final t in types) _event(t.name, t),
      ];
      final players = [
        for (final t in types) _fouler(t.name, TeamSide.home),
      ];

      final fouls = TeamFouls.fromEvents(events, players);
      const h = TeamSide.home;
      const first = FoulPeriod.first;
      expect(fouls.count(first, h, FoulCategory.foot), 1);
      expect(fouls.count(first, h, FoulCategory.body), 1);
      expect(fouls.count(first, h, FoulCategory.other), 4);
      expect(fouls.total(first, h), 6);
      for (final period in FoulPeriod.values) {
        expect(fouls.total(period, TeamSide.away), 0);
      }
    });

    test('TC-4042: Abseits und Vorteil zählen nicht', () {
      final types = [
        EventType.offside,
        EventType.advantage,
      ];
      final fouls = TeamFouls.fromEvents(
        [for (final t in types) _event(t.name, t)],
        [for (final t in types) _fouler(t.name, TeamSide.home)],
      );
      expect(_sumAll(fouls), 0);
    });

    test('TC-4043: Team-Zuordnung über den Täter', () {
      final fouls = TeamFouls.fromEvents(
        [_event('e1', EventType.footFoul)],
        [
          _fouler('e1', TeamSide.away),
          _player('e1', PlayerRole.fouled, TeamSide.home),
        ],
      );
      expect(fouls.count(FoulPeriod.first, TeamSide.away, FoulCategory.foot), 1);
      expect(fouls.count(FoulPeriod.first, TeamSide.home, FoulCategory.foot), 0);
    });

    test('TC-4044: Ereignis ohne Täter-Team zählt nicht', () {
      final fouls = TeamFouls.fromEvents(
        [_event('e1', EventType.footFoul)],
        [_player('e1', PlayerRole.fouled, TeamSide.home)],
      );
      expect(_sumAll(fouls), 0);
    });

    test('TC-4045: Nachspielzeit zählt zur jeweiligen Halbzeit', () {
      final fouls = TeamFouls.fromEvents(
        [
          _event('e1', EventType.footFoul,
              phase: GamePhase.ersteHalbzeitNachspielzeit),
          _event('e2', EventType.bodyFoul,
              phase: GamePhase.zweiteHalbzeitNachspielzeit),
        ],
        [_fouler('e1', TeamSide.home), _fouler('e2', TeamSide.away)],
      );
      expect(fouls.count(FoulPeriod.first, TeamSide.home, FoulCategory.foot), 1);
      expect(
          fouls.count(FoulPeriod.second, TeamSide.away, FoulCategory.body), 1);
      expect(fouls.hasExtraTime, isFalse);
    });

    test('TC-4046: Verlängerung wird separat gezählt', () {
      final fouls = TeamFouls.fromEvents(
        [
          _event('e1', EventType.footFoul,
              phase: GamePhase.verlaengerungErsteHalbzeit),
          _event('e2', EventType.footFoul,
              phase: GamePhase.verlaengerungZweiteHalbzeitNachspielzeit),
        ],
        [_fouler('e1', TeamSide.home), _fouler('e2', TeamSide.away)],
      );
      const extra = FoulPeriod.extraTime;
      expect(fouls.count(extra, TeamSide.home, FoulCategory.foot), 1);
      expect(fouls.count(extra, TeamSide.away, FoulCategory.foot), 1);
      for (final team in TeamSide.values) {
        expect(fouls.total(FoulPeriod.first, team), 0);
        expect(fouls.total(FoulPeriod.second, team), 0);
      }
      expect(fouls.hasExtraTime, isTrue);
      expect(fouls.periods, contains(FoulPeriod.extraTime));
    });
  });

  group('Statistik-Tab (US-404)', () {
    testWidgets('TC-4047: Tabelle ohne Verlängerung', (tester) async {
      await _openStatsTab(
        tester,
        _FakeEventRepository(
          [
            _event('e1', EventType.footFoul),
            _event('e2', EventType.footFoul),
            _event('e3', EventType.handball),
            _event('e4', EventType.bodyFoul, phase: GamePhase.zweiteHalbzeit),
          ],
          [
            _fouler('e1', TeamSide.home),
            _fouler('e2', TeamSide.away),
            _fouler('e3', TeamSide.home),
            _fouler('e4', TeamSide.away),
          ],
        ),
      );

      expect(find.text('Vergehen pro Team'), findsOneWidget);
      expect(find.text('1. HZ'), findsOneWidget);
      expect(find.text('2. HZ'), findsOneWidget);
      expect(find.text('Verl.'), findsNothing);
      // Spalten: 1. HZ H | G · 2. HZ H | G
      expect(_rowValues(tester, 'Fußvergehen'), ['1', '1', '0', '0']);
      expect(_rowValues(tester, 'Oberkörperv.'), ['0', '0', '0', '1']);
      expect(_rowValues(tester, 'Andere'), ['1', '0', '0', '0']);
      expect(_rowValues(tester, 'Summe'), ['2', '1', '0', '1']);
    });

    testWidgets('TC-4048: Spalte „Verl." bei Ereignissen in der Verlängerung',
        (tester) async {
      await _openStatsTab(
        tester,
        _FakeEventRepository([
          _event('e1', EventType.offside,
              phase: GamePhase.verlaengerungErsteHalbzeit),
        ]),
      );

      expect(find.text('Verl.'), findsOneWidget);
      expect(_rowValues(tester, 'Summe'), hasLength(6));
    });

    testWidgets('TC-4049: Leeres Spiel zeigt Nullen', (tester) async {
      await _openStatsTab(tester, _FakeEventRepository([]));

      expect(find.text('Vergehen pro Team'), findsOneWidget);
      for (final label in ['Fußvergehen', 'Oberkörperv.', 'Andere', 'Summe']) {
        expect(_rowValues(tester, label), ['0', '0', '0', '0']);
      }
    });
  });

  group('Persistenz (US-404)', () {
    late AppDatabase db;
    late EventRepositoryImpl repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = EventRepositoryImpl(db);
      await GameRepositoryImpl(db).createGame(_game());
    });

    tearDown(() => db.close());

    test('TC-4051: Spielereintrag ohne Nummer überlebt Speichern/Laden',
        () async {
      await repo.createEvent(_event('e1', EventType.footFoul),
          [_fouler('e1', TeamSide.away)]);

      final players = await repo.getPlayersForGame(_gameId);
      expect(players, hasLength(1));
      expect(players.single.team, TeamSide.away);
      expect(players.single.role, PlayerRole.fouler);
      expect(players.single.jerseyNumber, isNull);
    });

    test('TC-4053: Spieler-Ranking ignoriert Einträge ohne Nummer', () async {
      await repo.createEvent(_event('e1', EventType.footFoul),
          [_fouler('e1', TeamSide.home)]);
      await repo.createEvent(_event('e2', EventType.footFoul),
          [_fouler('e2', TeamSide.home, 4)]);
      final container = ProviderContainer(
          overrides: [eventRepositoryProvider.overrideWithValue(repo)]);
      addTearDown(container.dispose);

      final ranking =
          await container.read(playerRankingProvider(_gameId).future);
      expect(ranking, hasLength(1));
      expect(ranking.single.number, 4);
      expect(ranking.single.count, 1);
    });
  });

  test('TC-4052: Migration v5 → v6 macht jersey_number nullable', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      // Minimales v5-Schema der event_players-Tabelle mit einem Bestandseintrag
      raw.execute('''
        CREATE TABLE event_players (
          id TEXT NOT NULL PRIMARY KEY,
          event_id TEXT NOT NULL,
          role TEXT NOT NULL,
          team TEXT NOT NULL,
          jersey_number INTEGER NOT NULL
        );
      ''');
      raw.execute('''
        INSERT INTO event_players (id, event_id, role, team, jersey_number)
        VALUES ('p1', 'e1', 'fouler', 'home', 7);
      ''');
      // v7-Migration liest Torentscheidungen aus events (US-215)
      raw.execute('''
        CREATE TABLE events (
          id TEXT NOT NULL PRIMARY KEY,
          game_id TEXT NOT NULL,
          elapsed_ms INTEGER NOT NULL,
          game_phase TEXT NOT NULL DEFAULT 'ersteHalbzeit',
          type TEXT NOT NULL,
          custom_type_label TEXT,
          ref_decision TEXT,
          goal_scorer_team TEXT,
          goal_scorer_number INTEGER,
          own_goal INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL
        );
      ''');
      raw.execute('PRAGMA user_version = 5;');
    }));
    addTearDown(db.close);

    expect(db.schemaVersion, 7);
    final rows = await db.select(db.eventPlayers).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'p1');
    expect(rows.single.jerseyNumber, 7);

    final notNull = await db
        .customSelect("SELECT \"notnull\" AS nn FROM pragma_table_info("
            "'event_players') WHERE name = 'jersey_number'")
        .map((r) => r.read<int>('nn'))
        .getSingle();
    expect(notNull, 0);
  });
}
