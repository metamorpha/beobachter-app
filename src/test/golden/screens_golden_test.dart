@Tags(['golden'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/assessment.dart';
import 'package:beobachter_app/domain/enums/card_type.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/player_role.dart';
import 'package:beobachter_app/domain/enums/ref_decision.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/game_list/game_list_screen.dart';
import 'package:beobachter_app/presentation/screens/game_setup/game_setup_screen.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';
import 'package:beobachter_app/presentation/theme/app_theme.dart';

/// Golden-Tests der Hauptscreens im Tablet-Querformat mit echter Schrift
/// (Inter + Material Icons), damit visuelle Regressionen sichtbar werden
/// (US-601 – US-606, TC-6064 Vorbereitung).
///
/// Referenzbilder neu erzeugen: `flutter test --update-goldens --tags golden`
/// Schriftdarstellung ist plattformabhängig — Referenzen stammen von macOS.
const _size = Size(1280, 800);

Future<void> _loadFonts() async {
  final inter = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    inter.addFont(_bytes('assets/fonts/inter/Inter-$w.ttf'));
  }
  await inter.load();

  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final icons = File(
        '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(
            ByteData.sublistView(icons.readAsBytesSync())));
      await loader.load();
    }
  }
}

Future<ByteData> _bytes(String path) async =>
    ByteData.sublistView(File(path).readAsBytesSync());

final _game = Game(
  id: 'g1',
  date: DateTime(2026, 10, 18),
  location: 'Sportpark Nord',
  homeTeamName: 'SV Westfalia',
  awayTeamName: 'FC Ruhrtal',
  liga: 'Bezirksliga 7',
  spieltag: '9',
  createdAt: DateTime(2026, 10, 18),
);

Event _e(
  String id,
  int minute,
  EventType type,
  double x,
  double y, {
  RefDecision? decision,
  CardType? card,
  Assessment? assessment,
  bool coaching = false,
  String? note,
  GamePhase phase = GamePhase.ersteHalbzeit,
  TeamSide? scorer,
}) =>
    Event(
      id: id,
      gameId: 'g1',
      elapsedMs: minute * 60 * 1000 + 17000,
      gamePhase: phase,
      type: type,
      locationX: x,
      locationY: y,
      refDecision: decision,
      card: card,
      assessment: assessment,
      coachingFlag: coaching,
      sceneNote: note,
      goalScorerTeam: scorer,
      createdAt: DateTime(2026, 10, 18),
    );

Future<AppDatabase> _seed(ProviderContainer c,
    {GamePhase phase = GamePhase.zweiteHalbzeit}) async {
  final games = c.read(gameRepositoryProvider);
  await games.createGame(_game);
  await games.createGame(Game(
    id: 'g2',
    date: DateTime(2026, 10, 11),
    homeTeamName: 'TuS Hohenlimburg',
    awayTeamName: 'SC Berchum',
    liga: 'Kreisliga A',
    spieltag: '8',
    createdAt: DateTime(2026, 10, 11),
  ));
  final squads = c.read(squadRepositoryProvider);
  await squads.saveSquad('g1', TeamSide.home, [1, 3, 4, 6, 7, 8, 9, 10, 11, 14, 17]);
  await squads.saveSquad('g1', TeamSide.away, [1, 2, 5, 6, 7, 9, 10, 13, 16, 19, 23]);

  final events = c.read(eventRepositoryProvider);
  EventPlayer p(PlayerRole r, TeamSide t, int n) =>
      EventPlayer(id: '', eventId: '', role: r, team: t, jerseyNumber: n);
  final seed = <(Event, List<EventPlayer>)>[
    (_e('a', 6, EventType.footFoul, 0.32, 0.41,
        decision: RefDecision.freeKick, assessment: Assessment.correctExpected),
      [p(PlayerRole.fouler, TeamSide.away, 6), p(PlayerRole.fouled, TeamSide.home, 9)]),
    (_e('b', 14, EventType.offside, 0.81, 0.30,
        decision: RefDecision.indirectFreeKick, assessment: Assessment.correctComplex),
      []),
    (_e('c', 23, EventType.bodyFoul, 0.55, 0.62,
        decision: RefDecision.yellowCard, card: CardType.yellow,
        assessment: Assessment.wrongExpected, coaching: true,
        note: 'Zu spät, Ellbogen im Spiel'),
      [p(PlayerRole.fouler, TeamSide.home, 4), p(PlayerRole.fouled, TeamSide.away, 10)]),
    (_e('d', 31, EventType.goalDecision, 0.93, 0.50,
        decision: RefDecision.goal, scorer: TeamSide.home),
      []),
    (_e('e', 38, EventType.handball, 0.18, 0.55,
        decision: RefDecision.penalty, assessment: Assessment.wrongComplex,
        coaching: true, note: 'Arm angelegt?'),
      [p(PlayerRole.fouler, TeamSide.home, 3)]),
    (_e('f', 52, EventType.advantage, 0.45, 0.22,
        decision: RefDecision.advantage, assessment: Assessment.correctExpected,
        phase: GamePhase.zweiteHalbzeit),
      []),
    (_e('g', 61, EventType.footFoul, 0.61, 0.78,
        decision: RefDecision.freeKick, assessment: Assessment.correctExpected,
        phase: GamePhase.zweiteHalbzeit),
      [p(PlayerRole.fouler, TeamSide.away, 6)]),
    (_e('h', 67, EventType.goalDecision, 0.07, 0.47,
        decision: RefDecision.goal, scorer: TeamSide.away,
        phase: GamePhase.zweiteHalbzeit),
      []),
  ];
  for (final (e, players) in seed) {
    await events.createEvent(e, players);
  }
  await c.read(timerRepositoryProvider).saveTimerState(TimerState(
        gameId: 'g1',
        isRunning: false,
        elapsedMs: 68 * 60 * 1000 + 12000,
        phase: phase,
      ));
  return c.read(databaseProvider);
}

Future<ProviderContainer> _pump(WidgetTester tester, Widget home,
    {GamePhase phase = GamePhase.zweiteHalbzeit}) async {
  tester.view.physicalSize = _size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  // Echte Schatten statt der schwarzen Test-Konturen; _snap setzt zurück
  debugDisableShadows = false;

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
  addTearDown(() async {
    c.dispose();
    await db.close();
  });
  await _seed(c, phase: phase);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: home,
    ),
  ));
  await tester.pumpAndSettle();
  return c;
}

Future<void> _snap(String name) async {
  try {
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
  } finally {
    debugDisableShadows = true;
  }
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('Spielliste', (tester) async {
    await _pump(tester, const GameListScreen());
    await _snap('game_list');
  });

  testWidgets('Spiel-Setup', (tester) async {
    await _pump(tester, GameSetupScreen(game: _game));
    await _snap('game_setup');
  });

  testWidgets('Live-Screen', (tester) async {
    await _pump(tester, LiveScreen(game: _game));
    await _snap('live');
  });

  testWidgets('Live-Screen mit Formular', (tester) async {
    await _pump(tester, LiveScreen(game: _game));
    await tester.tapAt(tester.getCenter(find.byKey(const Key('pitch_canvas'))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('event_type_footFoul')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('fouler_team_away')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('decision_freeKick')));
    await tester.tap(find.byKey(const Key('assessment_correctExpected')));
    await tester.pumpAndSettle();
    await _snap('live_form');
  });

  testWidgets('Nachbereitung — Szenen', (tester) async {
    await _pump(tester, ReviewScreen(game: _game));
    await _snap('review_scenes');
  });

  testWidgets('Nachbereitung — Coaching', (tester) async {
    await _pump(tester, ReviewScreen(game: _game));
    await tester.tap(find.text('Coaching'));
    await tester.pumpAndSettle();
    await _snap('review_coaching');
  });

  testWidgets('Nachbereitung — Statistik', (tester) async {
    await _pump(tester, ReviewScreen(game: _game));
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();
    await _snap('review_stats');
  });
}
