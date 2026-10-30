import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/data/repositories/game_repository_impl.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/enums/kit_color.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/presentation/platform/device_providers.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/game_setup/game_setup_screen.dart';
import 'package:beobachter_app/presentation/screens/live/goal_dialog.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';
import 'package:beobachter_app/presentation/theme/app_colors.dart';
import 'package:beobachter_app/presentation/theme/app_theme.dart';
import 'package:beobachter_app/presentation/theme/kit_colors.dart';
import 'package:beobachter_app/presentation/widgets/kit_color_picker.dart';
import 'package:beobachter_app/presentation/widgets/select_tile.dart';
import 'package:beobachter_app/presentation/widgets/squad_edit_dialog.dart';
import 'package:beobachter_app/presentation/widgets/team_dot.dart';

import 'golden/golden_harness.dart';

/// Testfälle aus docs/27_trikotfarben_tests.md (US-111).

const _tablet = Size(1280, 800);

Game _base({KitColor? home, KitColor? away}) => Game(
  id: 'k1',
  date: DateTime(2026, 10, 30),
  homeTeamName: 'Heim',
  awayTeamName: 'Gast',
  createdAt: DateTime(2026, 10, 30),
  homeKitColor: home,
  awayKitColor: away,
);

/// Testdaten der Goldens (Spiel g1 mit Kader, Szenen, Toren) plus optionale
/// Trikotfarben; echte In-Memory-Datenbank.
Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget Function(Game game) home, {
  KitColor? homeKit,
  KitColor? awayKit,
  Size size = _tablet,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
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
  await seedGoldenData(c);
  final games = c.read(gameRepositoryProvider);
  if (homeKit != null) {
    await games.updateKitColor('g1', TeamSide.home, homeKit);
  }
  if (awayKit != null) {
    await games.updateKitColor('g1', TeamSide.away, awayKit);
  }
  final game = (await games.getGame('g1'))!;

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(theme: AppTheme.light, home: home(game)),
    ),
  );
  await tester.pumpAndSettle();
  return c;
}

Future<Game> _stored(ProviderContainer c) async =>
    (await c.read(gameRepositoryProvider).getGame('g1'))!;

Color _goalButtonColor(WidgetTester tester, TeamSide team) {
  final button = tester.widget<ButtonStyleButton>(
    find.byKey(Key('btn_goal_${team.name}')),
  );
  return button.style!.backgroundColor!.resolve({})!;
}

BorderSide? _goalButtonSide(WidgetTester tester, TeamSide team) {
  final button = tester.widget<ButtonStyleButton>(
    find.byKey(Key('btn_goal_${team.name}')),
  );
  return button.style!.side?.resolve({});
}

List<Color> _dotColors(WidgetTester tester, Finder within) => tester
    .widgetList<TeamDot>(
      find.descendant(of: within, matching: find.byType(TeamDot)),
    )
    .map((d) => d.color)
    .toList();

void main() {
  // ── Domain & Datenhaltung ──────────────────────────────────────────────────

  test('TC-111-01: Palette vollständig, Rand nur bei hellen Farben', () {
    expect(KitColor.values.map((k) => k.label), [
      'Weiß',
      'Schwarz',
      'Grau',
      'Rot',
      'Bordeaux',
      'Orange',
      'Gelb',
      'Grün',
      'Hellblau',
      'Blau',
      'Lila',
    ]);
    expect(KitColor.values.map((k) => k.color).toSet(), hasLength(11));
    expect(KitColor.values.where((k) => AppColors.needsOutline(k.color)), [
      KitColor.white,
      KitColor.yellow,
      KitColor.lightBlue,
    ]);
    // Standardfarben bleiben ohne Rand
    expect(AppColors.needsOutline(AppColors.light.home), isFalse);
    expect(AppColors.needsOutline(AppColors.light.away), isFalse);
  });

  group('GameRepository (US-111)', () {
    late AppDatabase db;
    late GameRepositoryImpl repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = GameRepositoryImpl(db);
    });
    tearDown(() => db.close());

    test('TC-111-02: Trikotfarben werden gespeichert und geladen', () async {
      await repo.createGame(_base(home: KitColor.white, away: KitColor.black));
      final game = (await repo.getGame('k1'))!;
      expect(game.homeKitColor, KitColor.white);
      expect(game.awayKitColor, KitColor.black);

      await repo.updateKitColor('k1', TeamSide.away, KitColor.green);
      final updated = (await repo.getGame('k1'))!;
      expect(updated.homeKitColor, KitColor.white);
      expect(updated.awayKitColor, KitColor.green);

      await repo.updateGame(updated.copyWith(homeTeamName: 'Neu'));
      expect((await repo.getGame('k1'))!.awayKitColor, KitColor.green);
    });

    test('TC-111-03: Spiel ohne Trikotfarben nutzt Standardfarben', () async {
      await repo.createGame(_base());
      final game = (await repo.getGame('k1'))!;
      expect(game.homeKitColor, isNull);
      expect(game.awayKitColor, isNull);
      final kits = TeamKits.fromGame(game);
      expect(kits.of(TeamSide.home), isNull);
      expect(kits.clash, isFalse);
    });

    test('TC-111-05: Unbekannter Farbwert in der DB ergibt null', () async {
      await repo.createGame(_base(home: KitColor.red));
      await db.customStatement(
        "UPDATE games SET home_kit_color = 'magenta' WHERE id = 'k1'",
      );
      expect((await repo.getGame('k1'))!.homeKitColor, isNull);
    });
  });

  test('TC-111-04: Migration v7 → v8 erhält Altdaten', () async {
    final db = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('''
            CREATE TABLE games (
              id TEXT NOT NULL PRIMARY KEY,
              date INTEGER NOT NULL,
              kickoff_time INTEGER,
              location TEXT,
              home_team_name TEXT NOT NULL DEFAULT '',
              away_team_name TEXT NOT NULL DEFAULT '',
              liga TEXT,
              spieltag TEXT,
              coaching_note TEXT,
              created_at INTEGER NOT NULL
            );
          ''');
          raw.execute('''
            INSERT INTO games (id, date, home_team_name, away_team_name,
              liga, coaching_note, created_at)
            VALUES ('alt', 1761782400, 'FC Alt', 'SV Alt', 'Kreisliga A',
              'Gute Leistung', 1761782400);
          ''');
          raw.execute('PRAGMA user_version = 7;');
        },
      ),
    );
    addTearDown(db.close);

    expect(db.schemaVersion, 8);
    final game = (await GameRepositoryImpl(db).getGame('alt'))!;
    expect(game.homeTeamName, 'FC Alt');
    expect(game.awayTeamName, 'SV Alt');
    expect(game.liga, 'Kreisliga A');
    expect(game.coachingNote, 'Gute Leistung');
    expect(game.homeKitColor, isNull);
    expect(game.awayKitColor, isNull);
  });

  // ── Spiel-Setup ────────────────────────────────────────────────────────────

  group('Spiel-Setup (US-111)', () {
    testWidgets('TC-111-07: Farbauswahl je Team, nichts markiert', (
      tester,
    ) async {
      await _pump(tester, (g) => GameSetupScreen(game: g));

      expect(find.byType(KitColorPicker), findsNWidgets(2));
      for (final team in TeamSide.values) {
        for (final kit in KitColor.values) {
          expect(
            find.byKey(Key('kit_${team.name}_${kit.name}')),
            findsOneWidget,
          );
        }
      }
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('TC-111-08: Gewählte Farbe wirkt sofort', (tester) async {
      await _pump(tester, (g) => GameSetupScreen(game: g));

      await tester.tap(find.byKey(const Key('kit_home_white')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('kit_home_white')),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
      // Heim-Kader-Chip #7 jetzt weiß mit Rand und dunkler Schrift
      final chip = tester.widget<Chip>(
        find.ancestor(of: find.text('#7'), matching: find.byType(Chip)).first,
      );
      expect(chip.backgroundColor, KitColor.white.color);
      expect(chip.side, isNot(BorderSide.none));
      expect(AppColors.onColor(chip.backgroundColor!), isNot(Colors.white));
    });

    testWidgets('TC-111-09: Farbe wird mit dem Spiel gespeichert', (
      tester,
    ) async {
      final c = await _pump(tester, (g) => GameSetupScreen(game: g));

      await tester.tap(find.byKey(const Key('kit_home_yellow')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('kit_away_black')));
      await tester.tap(find.byKey(const Key('kit_away_black')));
      await tester.pumpAndSettle();

      // Sofort gespeichert, auch ohne „Spiel starten"
      var game = await _stored(c);
      expect(game.homeKitColor, KitColor.yellow);
      expect(game.awayKitColor, KitColor.black);

      await tester.tap(find.text('Spiel starten'));
      await tester.pumpAndSettle();
      game = await _stored(c);
      expect(game.homeKitColor, KitColor.yellow);
      expect(game.awayKitColor, KitColor.black);
    });

    testWidgets('TC-111-10: Bestehendes Spiel zeigt gespeicherte Farbe', (
      tester,
    ) async {
      await _pump(
        tester,
        (g) => GameSetupScreen(game: g),
        homeKit: KitColor.green,
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('kit_home_green')),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('TC-111-11: Hinweis bei gleicher Farbe, nicht blockierend', (
      tester,
    ) async {
      await _pump(
        tester,
        (g) => GameSetupScreen(game: g),
        homeKit: KitColor.red,
      );
      expect(find.byKey(const Key('kit_clash_hint')), findsNothing);

      await tester.ensureVisible(find.byKey(const Key('kit_away_red')));
      await tester.tap(find.byKey(const Key('kit_away_red')));
      await tester.pumpAndSettle();
      expect(
        find.text('Beide Teams haben dieselbe Trikotfarbe'),
        findsOneWidget,
      );
      final start = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Spiel starten'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(start.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('kit_away_blue')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('kit_clash_hint')), findsNothing);
    });
  });

  // ── Live-Screen ────────────────────────────────────────────────────────────

  group('Live-Screen (US-111)', () {
    testWidgets('TC-111-12: Kopfzeile in Trikotfarben', (tester) async {
      await _pump(
        tester,
        (g) => LiveScreen(game: g),
        homeKit: KitColor.white,
        awayKit: KitColor.black,
      );

      expect(_goalButtonColor(tester, TeamSide.home), KitColor.white.color);
      expect(_goalButtonSide(tester, TeamSide.home), isNotNull);
      expect(_goalButtonColor(tester, TeamSide.away), KitColor.black.color);
      expect(_goalButtonSide(tester, TeamSide.away), isNull);
      expect(_dotColors(tester, find.byKey(const Key('live_scoreboard'))), [
        KitColor.white.color,
        KitColor.black.color,
      ]);
    });

    testWidgets('TC-111-12b: Ohne Auswahl Standardfarben', (tester) async {
      await _pump(tester, (g) => LiveScreen(game: g));

      expect(_goalButtonColor(tester, TeamSide.home), AppColors.light.home);
      expect(_goalButtonColor(tester, TeamSide.away), AppColors.light.away);
    });

    testWidgets('TC-111-13: Tor-Dialog und Ereignisformular', (tester) async {
      await _pump(
        tester,
        (g) => LiveScreen(game: g),
        homeKit: KitColor.white,
        awayKit: KitColor.black,
      );

      await tester.tap(find.byKey(const Key('btn_goal_home')));
      await tester.pumpAndSettle();
      expect(
        _dotColors(tester, find.byType(GoalDialog)),
        contains(KitColor.white.color),
      );
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      await tester.tapAt(
        tester.getCenter(find.byKey(const Key('pitch_canvas'))),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      final toggle = tester.widget<SelectTile>(
        find.byKey(const Key('fouler_team_home')),
      );
      expect(toggle.color, KitColor.white.color);
      await tester.tap(find.byKey(const Key('fouler_team_home')));
      await tester.pumpAndSettle();
      final chip = tester.widget<SelectTile>(
        find.byKey(const Key('fouler_chip_9')),
      );
      expect(chip.color, KitColor.white.color);
    });

    testWidgets('TC-111-14: Farbe im Dialog „Aufstellung" ändern', (
      tester,
    ) async {
      final c = await _pump(tester, (g) => LiveScreen(game: g));

      await tester.tap(find.byKey(const Key('btn_aufstellung')));
      await tester.pumpAndSettle();
      expect(find.byType(KitColorPicker), findsNWidgets(2));

      await tester.tap(find.byKey(const Key('kit_home_purple')));
      await tester.pumpAndSettle();
      expect((await _stored(c)).homeKitColor, KitColor.purple);

      await tester.tap(find.byKey(const Key('btn_squad_done')));
      await tester.pumpAndSettle();
      expect(find.byType(SquadEditDialog), findsNothing);
      expect(_goalButtonColor(tester, TeamSide.home), KitColor.purple.color);
    });

    testWidgets('TC-111-15: Hinweis im Dialog „Aufstellung"', (tester) async {
      await _pump(tester, (g) => LiveScreen(game: g), homeKit: KitColor.green);
      await tester.tap(find.byKey(const Key('btn_aufstellung')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('kit_away_green')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('kit_clash_hint')), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_squad_done')));
      await tester.pumpAndSettle();
      expect(find.byType(SquadEditDialog), findsNothing);
    });

    testWidgets('TC-111-16: „Letzte Ereignisse" zeigt Tor in Trikotfarbe', (
      tester,
    ) async {
      await _pump(tester, (g) => LiveScreen(game: g), awayKit: KitColor.green);
      // Tor „h" ist ein Gast-Tor
      expect(_dotColors(tester, find.byKey(const Key('recent_goal_h'))), [
        KitColor.green.color,
      ]);
    });
  });

  test('TC-111-17: Fachfarben bleiben unabhängig von Trikotfarben', () {
    final c = AppColors.light;
    expect(c.yellowCard, const Color(0xFFFACC15));
    expect(KitColor.yellow.color, isNot(c.yellowCard));
    expect(KitColor.green.color, isNot(c.correct));
    expect(KitColor.orange.color, isNot(c.yellowRedCard));
  });

  // ── Nachbereitung ──────────────────────────────────────────────────────────

  testWidgets('TC-111-18: Ranking, Torliste und Vergehen in Trikotfarben', (
    tester,
  ) async {
    await _pump(
      tester,
      (g) => ReviewScreen(game: g),
      homeKit: KitColor.white,
      awayKit: KitColor.burgundy,
    );
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();

    final badges = tester.widgetList<TeamBadge>(find.byType(TeamBadge));
    expect(badges, isNotEmpty);
    for (final b in badges) {
      expect(
        b.color,
        b.label == 'H' ? KitColor.white.color : KitColor.burgundy.color,
      );
    }
    // „H" in der Vergehen-Tabelle bleibt auf Weiß lesbar
    final scheme = Theme.of(
      tester.element(find.byType(ReviewScreen)),
    ).colorScheme;
    final headers = tester
        .widgetList<Text>(find.text('H'))
        .where((t) => t.style?.color != null)
        .map((t) => t.style!.color);
    expect(headers, isNot(contains(KitColor.white.color)));
    expect(headers, contains(scheme.onSurface));
  });

  // ── Smartphone ─────────────────────────────────────────────────────────────

  testWidgets('TC-111-19a: Farbauswahl im Smartphone-Setup ohne Overflow', (
    tester,
  ) async {
    await _pump(
      tester,
      (g) => GameSetupScreen(game: g),
      size: const Size(390, 844),
      overrides: [isAndroidProvider.overrideWithValue(true)],
    );
    expect(tester.takeException(), isNull);
    for (final kit in KitColor.values) {
      final finder = find.byKey(Key('kit_home_${kit.name}'));
      final size = tester.getSize(finder);
      expect(size.width, greaterThanOrEqualTo(40));
      final rect = tester.getRect(finder);
      expect(rect.right, lessThanOrEqualTo(390));
    }
  });

  testWidgets('TC-111-19b: Dialog „Aufstellung" auf dem Smartphone', (
    tester,
  ) async {
    await _pump(
      tester,
      (g) => LiveScreen(game: g),
      size: const Size(844, 390),
      overrides: [isAndroidProvider.overrideWithValue(true)],
    );
    await tester.tap(find.byKey(const Key('btn_aufstellung')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (final kit in KitColor.values) {
      final rect = tester.getRect(find.byKey(Key('kit_away_${kit.name}')));
      expect(rect.right, lessThanOrEqualTo(844));
    }
  });
}
