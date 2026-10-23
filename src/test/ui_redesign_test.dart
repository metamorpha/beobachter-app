import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/app.dart';
import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/assessment.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/game_list/game_list_screen.dart';
import 'package:beobachter_app/presentation/screens/game_setup/game_setup_screen.dart';
import 'package:beobachter_app/presentation/screens/live/event_form_panel.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';
import 'package:beobachter_app/presentation/theme/app_colors.dart';
import 'package:beobachter_app/presentation/theme/app_theme.dart';

/// Testfälle UI-Redesign (US-601 – US-606), siehe docs/24_ui_redesign_tests.md.

Game _game(String id, {String home = 'Heim', String away = 'Gast'}) => Game(
  id: id,
  date: DateTime(2026, 10, 18),
  homeTeamName: home,
  awayTeamName: away,
  createdAt: DateTime(2026, 10, 18),
);

Event _event(String id, int minute, {EventType type = EventType.footFoul}) =>
    Event(
      id: id,
      gameId: 'g1',
      elapsedMs: minute * 60 * 1000,
      gamePhase: GamePhase.ersteHalbzeit,
      type: type,
      locationX: 0.4,
      locationY: 0.5,
      refDecision: null,
      assessment: Assessment.correctExpected,
      createdAt: DateTime(2026, 10, 18),
    );

/// Baut [home] mit App-Theme und frischer In-Memory-DB bei 1280 × 800.
Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  List<Game> games = const [],
  List<Event> events = const [],
  Map<TeamSide, List<int>> squads = const {},
  TimerState? timer,
  bool settle = true,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final c = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db), ...overrides],
  );
  addTearDown(() async {
    c.dispose();
    await db.close();
  });
  for (final g in games) {
    await c.read(gameRepositoryProvider).createGame(g);
  }
  for (final e in events) {
    await c.read(eventRepositoryProvider).createEvent(e, const []);
  }
  for (final entry in squads.entries) {
    await c
        .read(squadRepositoryProvider)
        .saveSquad('g1', entry.key, entry.value);
  }
  if (timer != null) {
    await c.read(timerRepositoryProvider).saveTimerState(timer);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(theme: AppTheme.light, home: home),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

TimerState _timer(GamePhase phase, {bool running = false}) => TimerState(
  gameId: 'g1',
  isRunning: running,
  startTimestamp: running ? DateTime.now() : null,
  elapsedMs: 10 * 60 * 1000,
  phase: phase,
);

Future<void> _pumpLive(
  WidgetTester tester, {
  GamePhase phase = GamePhase.halbzeit,
  List<Event> events = const [],
  Map<TeamSide, List<int>> squads = const {},
}) => _pump(
  tester,
  LiveScreen(game: _game('g1')),
  games: [_game('g1')],
  events: events,
  squads: squads,
  timer: _timer(phase),
);

Future<void> _openForm(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('pitch_canvas')));
  await tester.pumpAndSettle();
}

Size _size(WidgetTester tester, String key) =>
    tester.getSize(find.byKey(Key(key)));

const _screen = Size(1280, 800);

void main() {
  // ── US-601 ───────────────────────────────────────────────────────────────
  group('US-601 · Einheitliches helles Design', () {
    testWidgets('TC-6011: Helles Theme mit Inter, kein Dark Theme', (
      tester,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const BeobachterApp(),
        ),
      );
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.darkTheme, isNull);
      final theme = Theme.of(tester.element(find.byType(GameListScreen)));
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
    });

    testWidgets('TC-6012: Live-Screen ist hell', (tester) async {
      await _pumpLive(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      final bg =
          scaffold.backgroundColor ??
          Theme.of(
            tester.element(find.byType(LiveScreen)),
          ).scaffoldBackgroundColor;
      expect(bg.computeLuminance(), greaterThan(0.8));
    });

    test('TC-6013: Semantische Farben über ThemeExtension', () {
      final c = AppTheme.light.extension<AppColors>()!;
      expect({c.home, c.away, c.correct, c.coaching, c.yellowCard}.length, 5);
      expect(c.wrong, isNot(c.correct));
      expect(c.redCard, isNot(c.yellowCard));
      expect(c.team(TeamSide.home), c.home);
      expect(c.team(TeamSide.away), c.away);
    });

    test('TC-6014: Keine hartkodierten Material-Farben in Screens/Widgets', () {
      final pattern = RegExp(
        r'Colors\.(red|green|blue|grey|amber|orange|yellow|blueGrey|deepOrange)\b',
      );
      final offenders = <String>[];
      for (final dir in [
        'lib/presentation/screens',
        'lib/presentation/widgets',
      ]) {
        for (final f
            in Directory(dir)
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart'))) {
          final lines = f.readAsLinesSync();
          for (var i = 0; i < lines.length; i++) {
            if (pattern.hasMatch(lines[i])) offenders.add('${f.path}:${i + 1}');
          }
        }
      }
      expect(offenders, isEmpty);
    });

    testWidgets('TC-6015: Textkontrast Spielliste', (tester) async {
      await _pump(tester, const GameListScreen(), games: [_game('g1')]);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('TC-6015: Textkontrast Live-Screen mit Formular', (
      tester,
    ) async {
      await _pumpLive(tester, events: [_event('a', 5)]);
      await _openForm(tester);
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('TC-6015: Textkontrast Statistik', (tester) async {
      await _pump(
        tester,
        ReviewScreen(game: _game('g1')),
        games: [_game('g1')],
        events: [_event('a', 5)],
      );
      await tester.tap(find.text('Statistik'));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });
  });

  // ── US-602 ───────────────────────────────────────────────────────────────
  group('US-602 · Live-Screen in Daumenreichweite', () {
    testWidgets('TC-6021: Phasen-Button unten links', (tester) async {
      await _pumpLive(tester, phase: GamePhase.bereit);
      final c = tester.getCenter(find.byKey(const Key('btn_start_game')));
      expect(c.dx, lessThan(_screen.width / 2));
      expect(c.dy, greaterThan(_screen.height / 2));
    });

    testWidgets('TC-6022: Phasen-Button ≥ 160 × 64 dp', (tester) async {
      await _pumpLive(tester, phase: GamePhase.ersteHalbzeit);
      final s = _size(tester, 'btn_halbzeit');
      expect(s.width, greaterThanOrEqualTo(160));
      expect(s.height, greaterThanOrEqualTo(64));
    });

    testWidgets('TC-6023: Aufstellung und Szenen beschriftet unten links', (
      tester,
    ) async {
      await _pumpLive(tester);
      expect(find.text('Aufstellung'), findsOneWidget);
      expect(find.text('Szenen'), findsOneWidget);
      for (final key in ['btn_aufstellung', 'btn_szenen']) {
        final r = tester.getRect(find.byKey(Key(key)));
        expect(r.height, greaterThanOrEqualTo(56), reason: key);
        expect(r.center.dx, lessThan(_screen.width / 2), reason: key);
        expect(r.center.dy, greaterThan(_screen.height / 2), reason: key);
      }
    });

    testWidgets('TC-6024: Kopfleiste ohne Aktions-Buttons', (tester) async {
      await _pumpLive(tester, phase: GamePhase.ersteHalbzeit);
      final board = find.byKey(const Key('live_scoreboard'));
      expect(
        find.descendant(of: board, matching: find.byType(ButtonStyleButton)),
        findsNothing,
      );
      expect(
        find.descendant(of: board, matching: find.byType(IconButton)),
        findsNothing,
      );
      for (final key in ['live_score', 'timer_label', 'timer_phase_label']) {
        expect(
          find.descendant(of: board, matching: find.byKey(Key(key))),
          findsOneWidget,
          reason: key,
        );
      }
    });

    testWidgets('TC-6025: Punkt nur bei laufender Uhr', (tester) async {
      // Fester Zustandsstrom statt echtem Ticker (kein Timer nach Testende)
      await _pump(
        tester,
        LiveScreen(game: _game('g1')),
        games: [_game('g1')],
        overrides: [
          timerStateProvider('g1').overrideWith(
            (_) => Stream.value(_timer(GamePhase.ersteHalbzeit, running: true)),
          ),
        ],
      );
      expect(find.byKey(const Key('timer_running_dot')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());

      await _pumpLive(tester, phase: GamePhase.halbzeit);
      expect(find.byKey(const Key('timer_running_dot')), findsNothing);
    });

    testWidgets('TC-6026: Ereigniszeilen ≥ 56 dp, Löschen ≥ 48 × 48 dp', (
      tester,
    ) async {
      await _pumpLive(
        tester,
        events: [_event('a', 1), _event('b', 2), _event('c', 3)],
      );
      for (final id in ['a', 'b', 'c']) {
        expect(
          _size(tester, 'recent_event_$id').height,
          greaterThanOrEqualTo(56),
        );
      }
      final del = tester.getSize(find.byTooltip('Löschen').first);
      expect(del.width, greaterThanOrEqualTo(48));
      expect(del.height, greaterThanOrEqualTo(48));
    });

    testWidgets('TC-6027: Tippflächen-Guideline Live-Screen mit Formular', (
      tester,
    ) async {
      await _pumpLive(
        tester,
        events: [_event('a', 5)],
        squads: {
          TeamSide.home: [7, 9],
        },
      );
      await _openForm(tester);
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });
  });

  // ── US-603 ───────────────────────────────────────────────────────────────
  group('US-603 · Erfassungsformular', () {
    testWidgets('TC-6031: Ereignistyp-Kacheln ≥ 56 dp', (tester) async {
      await _pumpLive(tester);
      await _openForm(tester);
      for (final t in EventType.values) {
        expect(
          _size(tester, 'event_type_${t.name}').height,
          greaterThanOrEqualTo(56),
          reason: t.name,
        );
      }
    });

    testWidgets('TC-6032: Entscheidungen ≥ 56 dp', (tester) async {
      await _pumpLive(tester);
      await _openForm(tester);
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      for (final key in ['decision_freeKick', 'decision_penalty']) {
        expect(
          _size(tester, key).height,
          greaterThanOrEqualTo(56),
          reason: key,
        );
      }
    });

    testWidgets('TC-6033: Team-Umschalter ≥ 56 dp, Nummern ≥ 48 × 48 dp', (
      tester,
    ) async {
      await _pumpLive(
        tester,
        squads: {
          TeamSide.home: [7, 9],
        },
      );
      await _openForm(tester);
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('fouler_team_home')));
      await tester.pumpAndSettle();

      expect(
        _size(tester, 'fouler_team_home').height,
        greaterThanOrEqualTo(56),
      );
      final chip = _size(tester, 'fouler_chip_7');
      expect(chip.width, greaterThanOrEqualTo(48));
      expect(chip.height, greaterThanOrEqualTo(48));
    });

    testWidgets('TC-6034: Bewertung ≥ 64 dp mit ✓/✗', (tester) async {
      await _pumpLive(tester);
      await _openForm(tester);
      await tester.tap(find.byKey(const Key('event_type_offside')));
      await tester.pumpAndSettle();
      for (final a in Assessment.values) {
        final cell = find.byKey(Key('assessment_${a.name}'));
        await tester.ensureVisible(cell);
        expect(tester.getSize(cell).height, greaterThanOrEqualTo(64));
        expect(
          find.descendant(
            of: cell,
            matching: find.byIcon(a.isCorrect ? Icons.check : Icons.close),
          ),
          findsOneWidget,
          reason: a.name,
        );
      }
    });

    testWidgets('TC-6037: Kein Überlauf bei schmaler Breite (Einblenden)',
        (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 300,
              child: EventFormPanel(
                gameId: 'g1',
                locationX: 0.5,
                locationY: 0.5,
                onClose: () {},
                onSaved: (_) {},
              ),
            ),
          ),
        ),
        games: [_game('g1')],
        squads: {TeamSide.home: [7, 9, 11]},
        timer: _timer(GamePhase.ersteHalbzeit),
      );
      for (final type in ['footFoul', 'goalDecision']) {
        await tester.tap(find.byKey(Key('event_type_$type')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: type);
      }
      await tester.ensureVisible(find.byKey(const Key('card_red')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-6035: Speichern fix unten rechts, ≥ 64 dp', (tester) async {
      await _pumpLive(tester);
      await _openForm(tester);
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();

      final save = find.byKey(const Key('btn_save_event'));
      final before = tester.getRect(save);
      expect(before.height, greaterThanOrEqualTo(64));
      expect(before.center.dx, greaterThan(_screen.width / 2));
      expect(before.bottom, greaterThan(_screen.height - 40));

      // Formularinhalt scrollen — Speichern bleibt stehen
      await tester.drag(
        find.byKey(const Key('decision_freeKick')),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(save), before);
    });
  });

  // ── US-604 ───────────────────────────────────────────────────────────────
  group('US-604 · Spielliste und Setup', () {
    testWidgets('TC-6041: Spiele als Karten in zwei Spalten', (tester) async {
      await _pump(
        tester,
        const GameListScreen(),
        games: [_game('g1'), _game('g2'), _game('g3')],
      );
      final rects =
          ['g1', 'g2', 'g3']
              .map((id) => tester.getRect(find.byKey(Key('game_tile_$id'))))
              .toList()
            ..sort(
              (a, b) => a.top == b.top
                  ? a.left.compareTo(b.left)
                  : a.top.compareTo(b.top),
            );
      expect(rects[0].top, rects[1].top);
      expect(rects[0].left, lessThan(rects[1].left));
      expect(rects[2].top, greaterThan(rects[0].bottom));
    });

    testWidgets('TC-6042: Leer-Zustand mit Hinweis', (tester) async {
      await _pump(tester, const GameListScreen());
      expect(find.text('Noch keine Spiele erfasst.'), findsOneWidget);
      expect(find.textContaining('Neues Spiel'), findsNWidgets(2));
    });

    testWidgets('TC-6043: Lösch-Button sichtbar, ≥ 48 × 48 dp', (tester) async {
      await _pump(tester, const GameListScreen(), games: [_game('g1')]);
      final s = _size(tester, 'btn_delete_game_g1');
      expect(s.width, greaterThanOrEqualTo(48));
      expect(s.height, greaterThanOrEqualTo(48));
    });

    testWidgets('TC-6044: Setup zweispaltig', (tester) async {
      await _pump(
        tester,
        GameSetupScreen(game: _game('g1')),
        games: [_game('g1')],
      );
      final home = tester.getRect(find.byKey(const Key('tf_home_team')));
      final squad = tester.getRect(find.text('Aufstellung Heim'));
      expect(home.right, lessThan(squad.left));
    });

    testWidgets('TC-6045: „Spiel starten" ohne Scrollen sichtbar', (
      tester,
    ) async {
      await _pump(
        tester,
        GameSetupScreen(game: _game('g1')),
        games: [_game('g1')],
        squads: {
          TeamSide.home: [for (var i = 1; i <= 22; i++) i],
          TeamSide.away: [for (var i = 1; i <= 22; i++) i],
        },
      );
      final r = tester.getRect(find.byKey(const Key('btn_start_game')));
      expect(r.bottom, lessThanOrEqualTo(_screen.height));
      expect(r.top, greaterThan(_screen.height / 2));
      expect(r.center.dx, greaterThan(_screen.width / 2));
    });
  });

  // ── US-605 ───────────────────────────────────────────────────────────────
  group('US-605 · Nachbereitung und Statistik', () {
    testWidgets('TC-6051: Szenen-Aktionen ≥ 48 × 48 dp', (tester) async {
      await _pump(
        tester,
        ReviewScreen(game: _game('g1')),
        games: [_game('g1')],
        events: [_event('a', 5)],
      );
      for (final tip in ['Bearbeiten', 'Coaching']) {
        final s = tester.getSize(find.byTooltip(tip));
        expect(s.width, greaterThanOrEqualTo(48), reason: tip);
        expect(s.height, greaterThanOrEqualTo(48), reason: tip);
      }
    });

    testWidgets('TC-6052: Statistik als 2 × 2-Dashboard', (tester) async {
      await _pump(
        tester,
        ReviewScreen(game: _game('g1')),
        games: [_game('g1')],
        events: [_event('a', 5)],
      );
      await tester.tap(find.text('Statistik'));
      await tester.pumpAndSettle();

      Rect r(String t) => tester.getRect(find.text(t));
      final heat = r('Heatmap');
      final time = r('Zeitachse');
      final rank = r('Spieler-Ranking');
      final fouls = r('Vergehen pro Team');
      expect(heat.top, time.top);
      expect(rank.top, fouls.top);
      expect(rank.top, greaterThan(heat.bottom));
      expect(heat.left, lessThan(time.left));
      expect(rank.left, lessThan(fouls.left));
    });

    testWidgets('TC-6053: Zeitachse als Balkendiagramm, Werte unverändert', (
      tester,
    ) async {
      await _pump(
        tester,
        ReviewScreen(game: _game('g1')),
        games: [_game('g1')],
        events: [_event('a', 3), _event('b', 9), _event('c', 62)],
      );
      await tester.tap(find.text('Statistik'));
      await tester.pumpAndSettle();

      final chart = find.byKey(const Key('timeline_chart'));
      expect(chart, findsOneWidget);
      Finder inChart(String t) =>
          find.descendant(of: chart, matching: find.text(t));
      expect(inChart('2'), findsOneWidget);
      expect(inChart('1'), findsOneWidget);
      for (final label in [
        "0–15'",
        "15–30'",
        "30–45'",
        "45–60'",
        "60–75'",
        "75–90'",
      ]) {
        expect(inChart(label), findsOneWidget, reason: label);
      }
    });
  });

  // ── US-606 ───────────────────────────────────────────────────────────────
  group('US-606 · Flüssige Übergänge', () {
    testWidgets('TC-6061: Formular gleitet ein', (tester) async {
      await _pumpLive(tester);
      await tester.tap(find.byKey(const Key('pitch_canvas')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final during = tester.getTopLeft(find.byType(EventFormPanel)).dx;
      await tester.pumpAndSettle();
      final end = tester.getTopLeft(find.byType(EventFormPanel)).dx;
      expect(during, greaterThan(end));
    });

    testWidgets('TC-6062: „Bewegung reduzieren" — sofort an Endposition', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      await _pumpLive(tester);
      await tester.tap(find.byKey(const Key('pitch_canvas')));
      await tester.pump();
      await tester.pump();
      final immediate = tester.getTopLeft(find.byType(EventFormPanel));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(EventFormPanel)), immediate);
    });

    testWidgets('TC-6063: Tap während laufender Animation wird angenommen', (
      tester,
    ) async {
      await _pumpLive(tester);
      await tester.tap(find.byKey(const Key('pitch_canvas')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();

      final save = tester.widget<FilledButton>(
        find.byKey(const Key('btn_save_event')),
      );
      expect(save.onPressed, isNotNull);
    });
  });
}
