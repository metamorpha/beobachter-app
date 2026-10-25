import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/goal.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/assessment.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/presentation/platform/device_providers.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/game_list/game_list_screen.dart';
import 'package:beobachter_app/presentation/screens/game_setup/game_setup_screen.dart';
import 'package:beobachter_app/presentation/screens/live/event_form_panel.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';
import 'package:beobachter_app/presentation/theme/app_theme.dart';

/// Android-Smartphone (US-701 – US-706), Testfälle aus
/// `docs/26_android_smartphone_tests.md`.

// ── Größen ───────────────────────────────────────────────────────────────────

const _phoneLandscape = Size(844, 390);
const _phonePortrait = Size(390, 844);
const _tablet = Size(1280, 800);

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeWakeLock implements ScreenWakeLock {
  final calls = <String>[];

  @override
  Future<void> enable() async => calls.add('enable');

  @override
  Future<void> disable() async => calls.add('disable');
}

// ── Testdaten ────────────────────────────────────────────────────────────────

const _gameId = 'g1';

Game _game({
  String id = _gameId,
  String home = 'SV Westfalia',
  String away = 'FC Ruhrtal',
}) => Game(
  id: id,
  date: DateTime(2026, 10, 18),
  homeTeamName: home,
  awayTeamName: away,
  createdAt: DateTime(2026, 10, 18),
);

Event _event(String id, int minute, EventType type) => Event(
  id: id,
  gameId: _gameId,
  elapsedMs: minute * 60 * 1000,
  gamePhase: GamePhase.ersteHalbzeit,
  type: type,
  locationX: 0.4,
  locationY: 0.5,
  assessment: Assessment.correctExpected,
  createdAt: DateTime(2026, 10, 18),
);

/// Aufbau einer Testumgebung mit In-Memory-Datenbank.
class _Env {
  final WidgetTester tester;
  final ProviderContainer container;
  final _FakeWakeLock wakeLock;
  final List<List<String>> orientations;

  _Env(this.tester, this.container, this.wakeLock, this.orientations);

  T read<T>(ProviderListenable<T> p) => container.read(p);

  Future<List<Event>> events() =>
      read(eventRepositoryProvider).getEvents(_gameId);
}

Future<_Env> _setUp(
  WidgetTester tester, {
  required Size size,
  bool android = true,
  GamePhase phase = GamePhase.zweiteHalbzeit,
  Game? game,
  List<Event> events = const [],
  List<Goal> goals = const [],
  List<Game> extraGames = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final orientations = <List<String>>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'SystemChrome.setPreferredOrientations') {
        final wanted = List<String>.from(call.arguments as List);
        orientations.add(wanted);
        // Gerät dreht sich wie gewünscht — nach dem laufenden Frame
        scheduleMicrotask(() {
          final current = tester.view.physicalSize;
          final landscape = wanted.first.contains('landscape');
          if (landscape != (current.width > current.height)) {
            tester.view.physicalSize = current.flipped;
          }
        });
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );

  final wakeLock = _FakeWakeLock();
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final c = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      isAndroidProvider.overrideWithValue(android),
      screenWakeLockProvider.overrideWithValue(wakeLock),
    ],
  );
  addTearDown(() async {
    c.dispose();
    await db.close();
  });

  await c.read(gameRepositoryProvider).createGame(game ?? _game());
  for (final g in extraGames) {
    await c.read(gameRepositoryProvider).createGame(g);
  }
  await c.read(squadRepositoryProvider).saveSquad(_gameId, TeamSide.home, [
    4,
    7,
    9,
    10,
  ]);
  await c.read(squadRepositoryProvider).saveSquad(_gameId, TeamSide.away, [
    2,
    6,
    11,
  ]);
  for (final e in events) {
    await c.read(eventRepositoryProvider).createEvent(e, const []);
  }
  for (final g in goals) {
    await c.read(goalRepositoryProvider).createGoal(g);
  }
  await c
      .read(timerRepositoryProvider)
      .saveTimerState(
        TimerState(
          gameId: _gameId,
          isRunning: false,
          elapsedMs: 68 * 60 * 1000,
          phase: phase,
        ),
      );
  return _Env(tester, c, wakeLock, orientations);
}

Future<void> _pumpApp(_Env env, Widget home) async {
  await env.tester.pumpWidget(
    UncontrolledProviderScope(
      container: env.container,
      child: MaterialApp(theme: AppTheme.light, home: home),
    ),
  );
  await env.tester.pumpAndSettle();
}

/// Spielliste als Startseite, Live-Screen darüber — wie in der App.
Future<void> _pumpLiveOverList(_Env env, Game game) async {
  await _pumpApp(env, const GameListScreen());
  final nav = env.tester.state<NavigatorState>(find.byType(Navigator));
  nav.push(MaterialPageRoute(builder: (_) => LiveScreen(game: game)));
  await env.tester.pumpAndSettle();
}

/// Android-Zurück-Taste / -Geste.
Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

const _landscape = [
  'DeviceOrientation.landscapeLeft',
  'DeviceOrientation.landscapeRight',
];
const _portrait = ['DeviceOrientation.portraitUp'];

void main() {
  // ── Regression ─────────────────────────────────────────────────────────────

  group('Regression', () {
    testWidgets('TC-7004a: Smartphone-Layout bei 844 × 390 (Android)', (
      tester,
    ) async {
      final env = await _setUp(tester, size: _phoneLandscape);
      await _pumpApp(env, LiveScreen(game: _game()));
      expect(find.byKey(const Key('btn_ereignisse')), findsOneWidget);
      expect(find.text('Letzte Ereignisse'), findsNothing);
    });

    testWidgets('TC-7004b: Tablet-Layout bei 1280 × 800 (Android)', (
      tester,
    ) async {
      final env = await _setUp(tester, size: _tablet);
      await _pumpApp(env, LiveScreen(game: _game()));
      expect(find.text('Letzte Ereignisse'), findsOneWidget);
      expect(find.byKey(const Key('btn_ereignisse')), findsNothing);
    });

    testWidgets('TC-7004c: Tablet-Layout unter Windows', (tester) async {
      final env = await _setUp(tester, size: _tablet, android: false);
      await _pumpApp(env, LiveScreen(game: _game()));
      expect(find.text('Letzte Ereignisse'), findsOneWidget);
      expect(find.byKey(const Key('btn_ereignisse')), findsNothing);
    });

    group('TC-7005: Kein Overflow in Smartphone-Größe', () {
      final longGame = _game(
        home: 'Sportvereinigung Westfalia 1911',
        away: 'Fußballclub Ruhrtal-Hohenlimburg',
      );

      for (final phase in [
        GamePhase.bereit,
        GamePhase.ersteHalbzeit,
        GamePhase.beendet,
        GamePhase.abgeschlossen,
      ]) {
        testWidgets('Live-Screen in Phase ${phase.name}', (tester) async {
          final env = await _setUp(
            tester,
            size: _phoneLandscape,
            phase: phase,
            game: longGame,
          );
          await _pumpApp(env, LiveScreen(game: longGame));
          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('Spielliste leer und mit 3 Spielen', (tester) async {
        final env = await _setUp(
          tester,
          size: _phonePortrait,
          game: longGame,
          extraGames: [
            _game(id: 'g2'),
            _game(id: 'g3'),
          ],
        );
        await _pumpApp(env, const GameListScreen());
        expect(find.byType(Card), findsNWidgets(3));
        expect(tester.takeException(), isNull);
      });

      testWidgets('Spiel-Setup', (tester) async {
        final env = await _setUp(tester, size: _phonePortrait, game: longGame);
        await _pumpApp(env, GameSetupScreen(game: longGame));
        expect(tester.takeException(), isNull);
      });

      testWidgets('Erfassungsformular, Tor-Dialog und Aufstellung', (
        tester,
      ) async {
        final env = await _setUp(tester, size: _phoneLandscape, game: longGame);
        await _pumpApp(env, LiveScreen(game: longGame));

        await tester.tap(find.byKey(const Key('pitch_canvas')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('event_type_footFoul')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_close_event_form')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('btn_goal_home')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_cancel_goal')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('btn_aufstellung')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Nachbereitung — alle Tabs', (tester) async {
        final env = await _setUp(
          tester,
          size: _phonePortrait,
          game: longGame,
          events: [
            _event('a', 5, EventType.footFoul),
            _event('b', 20, EventType.offside),
          ],
        );
        await _pumpApp(env, ReviewScreen(game: longGame));
        for (final tab in ['Coaching', 'Statistik']) {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    });
  });

  // ── US-701 · Live-Erfassung ────────────────────────────────────────────────

  group('US-701 · Live-Erfassung auf dem Smartphone', () {
    testWidgets('TC-7011: Querformat beim Öffnen, Hochformat beim Verlassen', (
      tester,
    ) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.abgeschlossen,
      );
      await _pumpLiveOverList(env, _game());
      expect(env.orientations.last, _landscape);

      await _systemBack(tester);
      expect(find.byType(GameListScreen), findsOneWidget);
      expect(env.orientations.last, _portrait);
    });

    testWidgets('TC-7012: Keine Ausrichtungs-Vorgabe auf Tablet/Windows', (
      tester,
    ) async {
      for (final android in [true, false]) {
        final env = await _setUp(tester, size: _tablet, android: android);
        await _pumpLiveOverList(env, _game());
        await _systemBack(tester);
        expect(env.orientations, isEmpty);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('TC-7013: Kompakte Kopfzeile', (tester) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.ersteHalbzeit,
        goals: [
          for (final t in [TeamSide.home, TeamSide.home, TeamSide.away])
            Goal(
              id: '',
              gameId: _gameId,
              elapsedMs: 60000,
              team: t,
              createdAt: DateTime(2026, 10, 18),
            ),
        ],
      );
      await _pumpApp(env, LiveScreen(game: _game()));

      expect(tester.getSize(find.byType(AppBar)).height, lessThanOrEqualTo(56));
      expect(find.text('SV Westfalia'), findsOneWidget);
      expect(find.text('FC Ruhrtal'), findsOneWidget);
      expect(find.text('2 : 1'), findsOneWidget);
      expect(find.byKey(const Key('timer_phase_label')), findsOneWidget);
      expect(find.byKey(const Key('timer_label')), findsOneWidget);
      for (final team in ['home', 'away']) {
        final btn = find.byKey(Key('btn_goal_$team'));
        expect(btn, findsOneWidget);
        expect(tester.getSize(btn).height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('TC-7014: Aktionsleisten in Daumenreichweite', (tester) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.ersteHalbzeit,
      );
      await _pumpApp(env, LiveScreen(game: _game()));

      final pitch = tester.getRect(find.byKey(const Key('pitch_canvas')));
      final phaseBtn = tester.getRect(find.byKey(const Key('btn_halbzeit')));
      expect(phaseBtn.right, lessThanOrEqualTo(pitch.left));
      expect(phaseBtn.width, greaterThanOrEqualTo(144));
      expect(phaseBtn.height, greaterThanOrEqualTo(56));

      final keys = [
        'btn_ereignisse',
        'btn_aufstellung',
        'btn_szenen',
        'btn_display',
      ];
      var lastY = -1.0;
      for (final k in keys) {
        final rect = tester.getRect(
          find.descendant(
            of: find.byKey(Key(k)),
            matching: find.byType(IconButton),
          ),
        );
        expect(rect.left, greaterThanOrEqualTo(pitch.right), reason: k);
        expect(rect.width, greaterThanOrEqualTo(56), reason: k);
        expect(rect.height, greaterThanOrEqualTo(56), reason: k);
        expect(rect.top, greaterThan(lastY), reason: 'Reihenfolge $k');
        lastY = rect.top;
      }
      for (final t in ['Ereignisse', 'Aufstellung', 'Szenen']) {
        expect(find.byTooltip(t), findsOneWidget);
      }
    });

    testWidgets('TC-7015: Zwei Phasen-Buttons nach Abpfiff untereinander', (
      tester,
    ) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.beendet,
      );
      await _pumpApp(env, LiveScreen(game: _game()));

      final a = tester.getRect(find.byKey(const Key('btn_verlaengerung')));
      final b = tester.getRect(find.byKey(const Key('btn_spiel_beenden')));
      expect(b.top, greaterThanOrEqualTo(a.bottom));
      expect(a.left, b.left);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-7016: Ereignis im Vollbild-Formular erfassen', (
      tester,
    ) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.ersteHalbzeit,
      );
      await _pumpApp(env, LiveScreen(game: _game()));

      var taps = 0;
      Future<void> tap(Finder f) async {
        taps++;
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      await tap(find.byKey(const Key('pitch_canvas')));
      expect(
        tester.getSize(find.byType(EventFormPanel)),
        _phoneLandscape,
        reason: 'Formular füllt den Bildschirm',
      );
      final save = find.byKey(const Key('btn_save_event'));
      expect(tester.getRect(save).bottom, lessThanOrEqualTo(390));

      await tap(find.byKey(const Key('event_type_footFoul')));
      await tester.ensureVisible(find.byKey(const Key('decision_freeKick')));
      await tap(find.byKey(const Key('decision_freeKick')));
      await tester.ensureVisible(
        find.byKey(const Key('assessment_correctExpected')),
      );
      await tap(find.byKey(const Key('assessment_correctExpected')));
      await tap(save);

      expect(taps, lessThanOrEqualTo(5));
      expect(find.byType(EventFormPanel), findsNothing);
      final saved = await env.events();
      expect(saved, hasLength(1));
      expect(saved.single.type, EventType.footFoul);
      expect(find.text('Ereignis gespeichert'), findsOneWidget);
    });

    testWidgets('TC-7017: Formular abbrechen', (tester) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.ersteHalbzeit,
      );
      await _pumpApp(env, LiveScreen(game: _game()));

      await tester.tap(find.byKey(const Key('pitch_canvas')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_close_event_form')));
      await tester.pumpAndSettle();

      expect(find.byType(EventFormPanel), findsNothing);
      expect(await env.events(), isEmpty);
    });

    Future<_Env> withEntries(WidgetTester tester) => _setUp(
      tester,
      size: _phoneLandscape,
      phase: GamePhase.ersteHalbzeit,
      events: [
        _event('e1', 5, EventType.footFoul),
        _event('e2', 20, EventType.offside),
      ],
      goals: [
        Goal(
          id: 'goal1',
          gameId: _gameId,
          elapsedMs: 12 * 60 * 1000,
          team: TeamSide.home,
          scorerNumber: 9,
          createdAt: DateTime(2026, 10, 18),
        ),
      ],
    );

    testWidgets('TC-7018: „Letzte Ereignisse" als Seitenleiste', (
      tester,
    ) async {
      final env = await withEntries(tester);
      await _pumpApp(env, LiveScreen(game: _game()));

      await tester.tap(find.byKey(const Key('btn_ereignisse')));
      await tester.pumpAndSettle();

      final sheet = tester.getRect(find.byKey(const Key('recent_sheet')));
      expect(sheet.width, lessThanOrEqualTo(844 / 2));
      expect(sheet.right, 844);

      final rows = [
        find.byKey(const Key('recent_event_e2')),
        find.byKey(const Key('recent_goal_goal1')),
        find.byKey(const Key('recent_event_e1')),
      ];
      var lastY = -1.0;
      for (final r in rows) {
        final rect = tester.getRect(r);
        expect(rect.top, greaterThan(lastY));
        expect(rect.height, greaterThanOrEqualTo(56));
        lastY = rect.top;
      }
    });

    testWidgets('TC-7019: Löschen und Tor bearbeiten aus der Seitenleiste', (
      tester,
    ) async {
      final env = await withEntries(tester);
      await _pumpApp(env, LiveScreen(game: _game()));
      await tester.tap(find.byKey(const Key('btn_ereignisse')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('recent_event_e2')),
          matching: find.byTooltip('Löschen'),
        ),
      );
      await tester.pumpAndSettle();
      expect((await env.events()).map((e) => e.id), ['e1']);
      expect(find.byKey(const Key('recent_event_e2')), findsNothing);

      await tester.tap(find.byKey(const Key('recent_goal_goal1')));
      await tester.pumpAndSettle();
      expect(find.text('Tor bearbeiten'), findsOneWidget);
      expect(find.textContaining('#9'), findsWidgets);
    });

    testWidgets('TC-7020: Tor-Dialog und Aufstellung im Vollbild', (
      tester,
    ) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.ersteHalbzeit,
      );
      await _pumpApp(env, LiveScreen(game: _game()));

      await tester.tap(find.byKey(const Key('btn_goal_home')));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Dialog)), _phoneLandscape);
      await tester.tap(find.byKey(const Key('btn_save_goal')));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('1 : 0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_aufstellung')));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Dialog)), _phoneLandscape);
      await tester.enterText(find.byKey(const Key('squad_away_field')), '23');
      await tester.tap(find.byKey(const Key('squad_away_add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_squad_done')));
      await tester.pumpAndSettle();

      expect(
        await env
            .read(squadRepositoryProvider)
            .getSquad(_gameId, TeamSide.away),
        contains(23),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-7021: Zurück schließt zuerst das oberste Element', (
      tester,
    ) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.ersteHalbzeit,
      );
      await _pumpLiveOverList(env, _game());

      await tester.tap(find.byKey(const Key('pitch_canvas')));
      await tester.pumpAndSettle();
      await _systemBack(tester);
      expect(find.byType(EventFormPanel), findsNothing);
      expect(find.byType(LiveScreen), findsOneWidget);
      expect(find.text('Live-Erfassung verlassen?'), findsNothing);

      await tester.tap(find.byKey(const Key('btn_ereignisse')));
      await tester.pumpAndSettle();
      await _systemBack(tester);
      expect(find.byKey(const Key('recent_sheet')), findsNothing);
      expect(find.byType(LiveScreen), findsOneWidget);
      expect(find.text('Live-Erfassung verlassen?'), findsNothing);
    });

    testWidgets('TC-7022: Zurück im Live-Screen fragt nach', (tester) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.ersteHalbzeit,
      );
      await _pumpLiveOverList(env, _game());

      await _systemBack(tester);
      expect(find.text('Live-Erfassung verlassen?'), findsOneWidget);
      expect(find.textContaining('Die Uhr läuft weiter'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dialog_btn_leave_cancel')));
      await tester.pumpAndSettle();
      expect(find.byType(LiveScreen), findsOneWidget);

      await _systemBack(tester);
      await tester.tap(find.byKey(const Key('dialog_btn_leave_confirm')));
      await tester.pumpAndSettle();
      expect(find.byType(LiveScreen), findsNothing);
      expect(find.byKey(const Key('badge_laeuft_$_gameId')), findsOneWidget);
    });

    testWidgets('TC-7023: Keine Nachfrage bei abgeschlossenem Spiel', (
      tester,
    ) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.abgeschlossen,
      );
      await _pumpLiveOverList(env, _game());

      await _systemBack(tester);
      expect(find.text('Live-Erfassung verlassen?'), findsNothing);
      expect(find.byType(LiveScreen), findsNothing);
    });

    testWidgets('TC-7024: Tablet-Verhalten der Zurück-Taste unverändert', (
      tester,
    ) async {
      final env = await _setUp(
        tester,
        size: _tablet,
        android: false,
        phase: GamePhase.ersteHalbzeit,
      );
      await _pumpLiveOverList(env, _game());

      await _systemBack(tester);
      expect(find.text('Live-Erfassung verlassen?'), findsNothing);
      expect(find.byType(LiveScreen), findsNothing);
    });
  });

  // ── US-702 · Display bleibt an ─────────────────────────────────────────────

  group('US-702 · Display bleibt während des Spiels an', () {
    Finder displayIcon(IconData icon) => find.descendant(
      of: find.byKey(const Key('btn_display')),
      matching: find.byIcon(icon),
    );

    testWidgets('TC-7031: Display-Sperre beim Öffnen aktiv', (tester) async {
      final env = await _setUp(tester, size: _phoneLandscape);
      await _pumpApp(env, LiveScreen(game: _game()));

      expect(env.wakeLock.calls, ['enable']);
      expect(displayIcon(Icons.light_mode), findsOneWidget);
      expect(
        find.byTooltip('Display bleibt an — zum Ausschalten tippen'),
        findsOneWidget,
      );
    });

    testWidgets('TC-7032: Schalter aus und wieder an', (tester) async {
      final env = await _setUp(tester, size: _phoneLandscape);
      await _pumpApp(env, LiveScreen(game: _game()));

      await tester.tap(find.byKey(const Key('btn_display')));
      await tester.pumpAndSettle();
      expect(env.wakeLock.calls, ['enable', 'disable']);
      expect(displayIcon(Icons.light_mode_outlined), findsOneWidget);
      expect(
        find.byTooltip('Display geht automatisch aus — zum Einschalten tippen'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('btn_display')));
      await tester.pumpAndSettle();
      expect(env.wakeLock.calls, ['enable', 'disable', 'enable']);
      expect(displayIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('TC-7033/7034: Verlassen hebt auf, erneutes Öffnen aktiviert', (
      tester,
    ) async {
      final env = await _setUp(
        tester,
        size: _phoneLandscape,
        phase: GamePhase.abgeschlossen,
      );
      await _pumpLiveOverList(env, _game());
      await tester.tap(find.byKey(const Key('btn_display')));
      await tester.pumpAndSettle();
      await _systemBack(tester);
      expect(env.wakeLock.calls, ['enable', 'disable', 'disable']);

      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(MaterialPageRoute(builder: (_) => LiveScreen(game: _game())));
      await tester.pumpAndSettle();
      expect(env.wakeLock.calls.last, 'enable');
      expect(displayIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('TC-7035: Schalter auf Android-Tablet in der Aktionsleiste', (
      tester,
    ) async {
      final env = await _setUp(tester, size: _tablet);
      await _pumpApp(env, LiveScreen(game: _game()));

      final display = tester.getRect(find.byKey(const Key('btn_display')));
      final szenen = tester.getRect(find.byKey(const Key('btn_szenen')));
      expect(display.left, greaterThan(szenen.left));
      expect(display.center.dy, closeTo(szenen.center.dy, 1));
      await tester.tap(find.byKey(const Key('btn_display')));
      await tester.pumpAndSettle();
      expect(env.wakeLock.calls, ['enable', 'disable']);
    });

    testWidgets('TC-7036: Kein Schalter, keine Wirkung unter Windows', (
      tester,
    ) async {
      final env = await _setUp(tester, size: _tablet, android: false);
      await _pumpLiveOverList(env, _game());
      expect(find.byKey(const Key('btn_display')), findsNothing);
      await _systemBack(tester);
      expect(env.wakeLock.calls, isEmpty);
    });
  });

  // ── US-703 · Spielliste, Setup, Aufstellung ────────────────────────────────

  group('US-703 · Spielliste, Spiel-Setup und Aufstellung', () {
    testWidgets('TC-7041: Hochformat außerhalb des Live-Screens', (
      tester,
    ) async {
      final env = await _setUp(tester, size: _phonePortrait);
      await _pumpApp(env, const GameListScreen());
      expect(env.orientations, [_portrait]);
    });

    testWidgets('TC-7041b: Keine Vorgabe auf Tablet-Größe', (tester) async {
      final env = await _setUp(tester, size: _tablet);
      await _pumpApp(env, const GameListScreen());
      expect(env.orientations, isEmpty);
    });

    testWidgets('TC-7042: Spielliste einspaltig, Fortsetzen', (tester) async {
      final env = await _setUp(
        tester,
        size: _phonePortrait,
        phase: GamePhase.ersteHalbzeit,
        extraGames: [
          _game(id: 'g2'),
          _game(id: 'g3'),
        ],
      );
      await _pumpApp(env, const GameListScreen());

      final lefts = {
        for (final id in [_gameId, 'g2', 'g3'])
          tester.getRect(find.byKey(Key('game_tile_$id'))).left,
      };
      expect(lefts, hasLength(1), reason: 'eine Spalte');
      expect(find.byKey(const Key('badge_laeuft_$_gameId')), findsOneWidget);

      await tester.tap(find.byKey(const Key('game_tile_$_gameId')));
      await tester.pumpAndSettle();
      expect(find.byType(LiveScreen), findsOneWidget);
    });

    testWidgets('TC-7043: Spiel-Setup untereinander, „Spiel starten" fix', (
      tester,
    ) async {
      final env = await _setUp(tester, size: _phonePortrait);
      await _pumpApp(env, GameSetupScreen(game: _game()));

      expect(
        tester.getRect(find.text('Aufstellungen')).top,
        greaterThan(tester.getRect(find.text('Spieldaten')).bottom),
      );
      final start = tester.getRect(find.byKey(const Key('btn_start_game')));
      expect(start.bottom, lessThanOrEqualTo(844));
      expect(start.height, greaterThanOrEqualTo(56));
    });

    testWidgets('TC-7044: Tastatur verdeckt kein Eingabefeld', (tester) async {
      final env = await _setUp(tester, size: _phonePortrait);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await _pumpApp(env, GameSetupScreen(game: _game()));

      final field = find.byType(TextField).last; // Aufstellung Gast
      await tester.showKeyboard(field);
      await tester.pumpAndSettle();
      expect(tester.getRect(field).bottom, lessThanOrEqualTo(844 - 300));
    });

    testWidgets('TC-7045: Dialoge passen sich der Breite an', (tester) async {
      final env = await _setUp(tester, size: _phonePortrait);
      await _pumpApp(env, const GameListScreen());

      await tester.tap(find.byKey(const Key('btn_delete_game_$_gameId')));
      await tester.pumpAndSettle();
      final dialog = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(Material),
      );
      expect(tester.getSize(dialog.first).width, lessThanOrEqualTo(390 - 32));
      expect(tester.takeException(), isNull);
    });
  });

  // ── US-704 · Nachbereitung ─────────────────────────────────────────────────

  group('US-704 · Nachbereitung und Statistik', () {
    Future<_Env> review(WidgetTester tester) async {
      final env = await _setUp(
        tester,
        size: _phonePortrait,
        events: [
          _event('a', 5, EventType.footFoul),
          _event('b', 20, EventType.offside),
          _event('c', 30, EventType.handball),
        ],
      );
      await _pumpApp(env, ReviewScreen(game: _game()));
      return env;
    }

    testWidgets('TC-7051: Tabs vorhanden', (tester) async {
      await review(tester);
      for (final t in ['Szenen', 'Coaching', 'Statistik']) {
        expect(find.text(t), findsOneWidget);
      }
    });

    testWidgets('TC-7052: Filterleiste horizontal scrollbar', (tester) async {
      await review(tester);
      final filterRow = find.byType(ListView).first;
      final chip = find.descendant(
        of: filterRow,
        matching: find.text('Abseits'),
      );
      await tester.dragUntilVisible(chip, filterRow, const Offset(-120, 0));
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Bearbeiten'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-7053: Szene bearbeiten im Vollbild', (tester) async {
      final env = await review(tester);
      await tester.tap(find.byTooltip('Bearbeiten').first);
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(EventFormPanel)), _phonePortrait);
      await tester.ensureVisible(
        find.byKey(const Key('assessment_wrongComplex')),
      );
      await tester.tap(find.byKey(const Key('assessment_wrongComplex')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pumpAndSettle();

      expect(find.byType(EventFormPanel), findsNothing);
      final events = await env.events();
      expect(
        events.where((e) => e.assessment == Assessment.wrongComplex),
        hasLength(1),
      );
    });

    testWidgets('TC-7054: Statistik-Karten untereinander', (tester) async {
      await review(tester);
      await tester.tap(find.text('Statistik'));
      await tester.pumpAndSettle();

      final scrollable = find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first;
      final lefts = <double>{};
      for (final title in [
        'Heatmap',
        'Zeitachse',
        'Spieler-Ranking',
        'Tore',
        'Vergehen pro Team',
      ]) {
        final f = find.text(title);
        await tester.scrollUntilVisible(f, 200, scrollable: scrollable);
        await tester.pumpAndSettle();
        expect(f, findsOneWidget, reason: title);
        lefts.add(tester.getRect(f).left);
      }
      expect(lefts, hasLength(1), reason: 'eine Spalte');
      expect(tester.takeException(), isNull);
    });
  });
}
