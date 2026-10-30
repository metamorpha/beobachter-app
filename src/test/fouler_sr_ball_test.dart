import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/team_fouls.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/player_role.dart';
import 'package:beobachter_app/domain/enums/ref_decision.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/live/event_form_panel.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';
import 'package:beobachter_app/presentation/widgets/select_tile.dart';

import 'golden/golden_harness.dart';

/// Testfälle aus docs/28_fouler_sr_ball_tests.md (US-216, US-217).

const _tablet = Size(1280, 800);

Event _event(String id, {RefDecision? decision}) => Event(
  id: id,
  gameId: 'g1',
  elapsedMs: 20 * 60 * 1000,
  gamePhase: GamePhase.ersteHalbzeit,
  type: EventType.footFoul,
  locationX: 0.4,
  locationY: 0.6,
  refDecision: decision,
  createdAt: DateTime(2026, 10, 30),
);

EventPlayer _p(PlayerRole role, TeamSide team, int? number) => EventPlayer(
  id: '',
  eventId: '',
  role: role,
  team: team,
  jerseyNumber: number,
);

/// Wie [pumpGoldenScreen], aber ohne Golden-Schatten (kein snapGolden).
Future<ProviderContainer> _pumpScreen(
  WidgetTester tester,
  Widget home, {
  Size size = _tablet,
  Future<void> Function(ProviderContainer c)? afterSeed,
}) async {
  final c = await pumpGoldenScreen(
    tester,
    home,
    size: size,
    afterSeed: afterSeed,
  );
  debugDisableShadows = true;
  return c;
}

/// Ereignisformular für Spiel g1 (Golden-Testdaten, echte In-Memory-DB) in
/// einem Panel der Breite [width].
Future<ProviderContainer> _pumpForm(
  WidgetTester tester, {
  Event? initialEvent,
  List<EventPlayer> initialPlayers = const [],
  double width = 512,
  Size size = _tablet,
}) => _pumpScreen(
  tester,
  Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        height: size.height,
        child: EventFormPanel(
          gameId: 'g1',
          locationX: 0.5,
          locationY: 0.5,
          onClose: () {},
          onSaved: (_) {},
          initialEvent: initialEvent,
          initialPlayers: initialPlayers,
        ),
      ),
    ),
  ),
  size: size,
);

Future<void> _tap(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Spieler des zuletzt angelegten bzw. des angegebenen Ereignisses.
Future<List<EventPlayer>> _playersOf(ProviderContainer c, String eventId) async {
  final all = await c.read(eventRepositoryProvider).getPlayersForGame('g1');
  return all.where((p) => p.eventId == eventId).toList();
}

Future<Event> _newest(ProviderContainer c) async {
  final events = await c.read(eventRepositoryProvider).getEvents('g1');
  return events.firstWhere(
    (e) => !const {'a', 'b', 'c', 'e', 'f', 'g', 'x'}.contains(e.id),
  );
}

/// Öffnet das Formular im Edit-Modus für ein Altereignis mit Gefoultem.
Future<(ProviderContainer, Event)> _pumpLegacyEdit(WidgetTester tester) async {
  late Event event;
  late List<EventPlayer> players;
  final c = await _pumpScreen(
    tester,
    const SizedBox(),
    size: _tablet,
    afterSeed: (c) async => (event, players) = await _seedLegacy(c),
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 512,
            child: EventFormPanel(
              gameId: 'g1',
              locationX: 0.5,
              locationY: 0.5,
              onClose: () {},
              onSaved: (_) {},
              initialEvent: event,
              initialPlayers: players,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (c, event);
}

/// Legt Ereignis x mit Fouler Heim #4 und Gefoultem Gast #10 an (Altdaten).
Future<(Event, List<EventPlayer>)> _seedLegacy(ProviderContainer c) async {
  final repo = c.read(eventRepositoryProvider);
  await repo.createEvent(_event('x'), [
    _p(PlayerRole.fouler, TeamSide.home, 4),
    _p(PlayerRole.fouled, TeamSide.away, 10),
  ]);
  final event = (await repo.getEvents('g1')).firstWhere(
    (e) => e.elapsedMs == 20 * 60 * 1000,
  );
  return (event, await _playersOf(c, event.id));
}

void main() {
  setUpAll(loadGoldenFonts);

  group('US-216 — Nur den Fouler erfassen', () {
    testWidgets('TC-216-01: Formular zeigt nur die Fouler-Zeile',
        (tester) async {
      await _pumpForm(tester);
      await _tap(tester, 'event_type_footFoul');

      expect(find.text('Fouler'), findsOneWidget);
      expect(find.byKey(const Key('fouler_team_home')), findsOneWidget);
      expect(find.text('Gefoulter'), findsNothing);
      expect(find.byKey(const Key('fouled_team_home')), findsNothing);
      expect(find.byKey(const Key('fouled_number')), findsNothing);
    });

    testWidgets('TC-216-02: Fouler wird wie bisher gespeichert',
        (tester) async {
      final c = await _pumpForm(tester);
      await _tap(tester, 'event_type_footFoul');
      await _tap(tester, 'fouler_team_home');
      await _tap(tester, 'fouler_chip_7');
      await _tap(tester, 'decision_freeKick');
      await _tap(tester, 'btn_save_event');

      final players = await _playersOf(c, (await _newest(c)).id);
      expect(players, hasLength(1));
      expect(players.single.role, PlayerRole.fouler);
      expect(players.single.team, TeamSide.home);
      expect(players.single.jerseyNumber, 7);
    });

    testWidgets('TC-216-03: Fouler nur mit Team, ohne Nummer', (tester) async {
      final c = await _pumpForm(tester);
      await _tap(tester, 'event_type_footFoul');
      await _tap(tester, 'fouler_team_away');
      await _tap(tester, 'btn_save_event');

      final players = await _playersOf(c, (await _newest(c)).id);
      expect(players.single.role, PlayerRole.fouler);
      expect(players.single.team, TeamSide.away);
      expect(players.single.jerseyNumber, isNull);
    });

    testWidgets('TC-216-04: Ereignis ohne Spielerangabe', (tester) async {
      final c = await _pumpForm(tester);
      await _tap(tester, 'event_type_footFoul');
      await _tap(tester, 'decision_freeKick');
      await _tap(tester, 'btn_save_event');

      final event = await _newest(c);
      expect(event.refDecision, RefDecision.freeKick);
      expect(await _playersOf(c, event.id), isEmpty);
    });

    testWidgets(
        'TC-216-05/06: Altereignis — nur Fouler sichtbar, Gefoulter bleibt '
        'beim Speichern erhalten', (tester) async {
      final (c, event) = await _pumpLegacyEdit(tester);

      // TC-216-05: Fouler vorausgefüllt, keine Gefoulten-Zeile
      expect(find.text('Gefoulter'), findsNothing);
      expect(find.byKey(const Key('fouled_team_away')), findsNothing);
      final chip4 = find.byKey(const Key('fouler_chip_4'));
      expect(chip4, findsOneWidget);

      // TC-216-06: Fouler ändern, Gefoulter bleibt
      await _tap(tester, 'fouler_chip_6');
      await _tap(tester, 'btn_save_event');

      final saved = await _playersOf(c, event.id);
      final fouler = saved.singleWhere((p) => p.role == PlayerRole.fouler);
      final fouled = saved.singleWhere((p) => p.role == PlayerRole.fouled);
      expect((fouler.team, fouler.jerseyNumber), (TeamSide.home, 6));
      expect((fouled.team, fouled.jerseyNumber), (TeamSide.away, 10));
    });

    testWidgets('TC-216-07: Fouler entfernen bei Altereignis', (tester) async {
      final (c, event) = await _pumpLegacyEdit(tester);

      // Erneuter Tap auf das gewählte Team hebt die Auswahl auf
      await _tap(tester, 'fouler_team_home');
      await _tap(tester, 'btn_save_event');

      final saved = await _playersOf(c, event.id);
      expect(saved.where((p) => p.role == PlayerRole.fouler), isEmpty);
      final fouled = saved.single;
      expect(fouled.role, PlayerRole.fouled);
      expect((fouled.team, fouled.jerseyNumber), (TeamSide.away, 10));
    });

    test('TC-216-08: Vergehen pro Team zählt nur Fouler', () {
      final events = [_event('e1'), _event('e2')];
      final players = [
        EventPlayer(
          id: 'p1',
          eventId: 'e1',
          role: PlayerRole.fouler,
          team: TeamSide.home,
          jerseyNumber: 4,
        ),
        EventPlayer(
          id: 'p2',
          eventId: 'e1',
          role: PlayerRole.fouled,
          team: TeamSide.away,
          jerseyNumber: 10,
        ),
        EventPlayer(
          id: 'p3',
          eventId: 'e2',
          role: PlayerRole.fouled,
          team: TeamSide.away,
          jerseyNumber: 10,
        ),
      ];
      final fouls = TeamFouls.fromEvents(events, players);
      expect(fouls.total(FoulPeriod.first, TeamSide.home), 1);
      expect(fouls.total(FoulPeriod.first, TeamSide.away), 0);
    });
  });

  group('US-217 — SR-Ball', () {
    test('TC-217-01: Enum und Bezeichnung', () {
      expect(RefDecision.droppedBall.label, 'SR-Ball');
      final values = RefDecision.values;
      expect(values.indexOf(RefDecision.droppedBall),
          values.indexOf(RefDecision.throwIn) + 1);
      expect(values.indexOf(RefDecision.goal),
          values.indexOf(RefDecision.droppedBall) + 1);
    });

    testWidgets('TC-217-02/03: Kachel nach Einwurf, auswählen und abwählen',
        (tester) async {
      final c = await _pumpForm(tester);
      await _tap(tester, 'event_type_footFoul');

      final tiles = tester
          .widgetList<Widget>(find.byWidgetPredicate((w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('decision_')))
          .map((w) => (w.key! as ValueKey<String>).value)
          .toList();
      expect(tiles, hasLength(12));
      expect(tiles.indexOf('decision_droppedBall'),
          tiles.indexOf('decision_throwIn') + 1);
      expect(tiles, isNot(contains('decision_goal')));
      expect(find.text('SR-Ball'), findsOneWidget);

      // Auswahl ersetzt eine andere Entscheidung …
      await _tap(tester, 'decision_freeKick');
      await _tap(tester, 'decision_droppedBall');
      await _tap(tester, 'btn_save_event');
      expect((await _newest(c)).refDecision, RefDecision.droppedBall);
    });

    testWidgets('TC-217-03: Erneuter Tap hebt SR-Ball auf', (tester) async {
      final c = await _pumpForm(tester);
      await _tap(tester, 'event_type_footFoul');
      await _tap(tester, 'decision_droppedBall');
      await _tap(tester, 'decision_droppedBall');
      await _tap(tester, 'btn_save_event');
      expect((await _newest(c)).refDecision, isNull);
    });

    test('TC-217-04/08: Speichern und Laden ohne Schemawechsel', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      expect(db.schemaVersion, 8);
      final c = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(c.dispose);
      await c.read(gameRepositoryProvider).createGame(Game(
        id: 'g1',
        date: DateTime(2026, 10, 30),
        homeTeamName: 'Heim',
        awayTeamName: 'Gast',
        createdAt: DateTime(2026, 10, 30),
      ));
      final repo = c.read(eventRepositoryProvider);
      final saved = await repo.createEvent(
        _event('', decision: RefDecision.droppedBall),
        const [],
      );

      final loaded = await repo.getEvent(saved.id);
      expect(loaded?.refDecision, RefDecision.droppedBall);
      final row = await (db.select(db.events)
            ..where((t) => t.id.equals(saved.id)))
          .getSingle();
      expect(row.refDecision, 'droppedBall');
    });

    testWidgets('TC-217-05: Vorauswahl beim Bearbeiten', (tester) async {
      await _pumpForm(
        tester,
        initialEvent: _event('x', decision: RefDecision.droppedBall),
      );
      SelectTile tile(String key) => tester.widget<SelectTile>(
        find.byKey(Key(key)),
      );
      expect(tile('decision_droppedBall').selected, isTrue);
      expect(tile('decision_throwIn').selected, isFalse);
    });

    testWidgets('TC-217-06: Anzeige in der Szenenliste', (tester) async {
      await _pumpScreen(
        tester,
        ReviewScreen(game: goldenGame),
        size: _tablet,
        afterSeed: (c) => c.read(eventRepositoryProvider).createEvent(
          _event('', decision: RefDecision.droppedBall),
          const [],
        ),
      );
      // Seit US-308 mit Präfix „Fortsetzung:"
      expect(find.text('Fortsetzung: SR-Ball'), findsOneWidget);
    });

    for (final (name, width, size) in [
      ('Tablet-Panel', 512.0, _tablet),
      ('schmales Panel', 300.0, _tablet),
      ('Smartphone quer', 844.0, const Size(844, 390)),
    ]) {
      testWidgets('TC-217-07: Grid ohne Überlauf — $name', (tester) async {
        await _pumpForm(tester, width: width, size: size);
        await _tap(tester, 'event_type_footFoul');
        await tester.ensureVisible(
          find.byKey(const Key('decision_droppedBall')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final throwIn =
            tester.getRect(find.byKey(const Key('decision_throwIn')));
        final dropped =
            tester.getRect(find.byKey(const Key('decision_droppedBall')));
        // Direkt danach: gleiche Zeile rechts daneben oder Anfang der nächsten
        expect(
          dropped.left > throwIn.left && dropped.top == throwIn.top ||
              dropped.top > throwIn.top,
          isTrue,
        );
        expect(dropped.right, lessThanOrEqualTo(width + 0.5));
      });
    }
  });
}
