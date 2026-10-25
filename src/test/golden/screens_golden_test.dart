@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/presentation/screens/game_list/game_list_screen.dart';
import 'package:beobachter_app/presentation/screens/game_setup/game_setup_screen.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';

import 'golden_harness.dart';

/// Golden-Tests der Hauptscreens im Tablet-Querformat mit echter Schrift
/// (Inter + Material Icons), damit visuelle Regressionen sichtbar werden
/// (US-601 – US-606, TC-6064 Vorbereitung).
///
/// Referenzbilder neu erzeugen: `flutter test --update-goldens --tags golden`
/// Schriftdarstellung ist plattformabhängig — Referenzen stammen von macOS,
/// deshalb laufen die Tests nur dort und werden sonst übersprungen.
const _size = Size(1280, 800);

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget home, {
  GamePhase phase = GamePhase.zweiteHalbzeit,
}) => pumpGoldenScreen(tester, home, size: _size, phase: phase);

Future<void> _snap(String name) => snapGolden(name);

void main() {
  group('Golden', skip: goldenSkip, () {
    setUpAll(loadGoldenFonts);

    testWidgets('Spielliste', (tester) async {
      await _pump(tester, const GameListScreen());
      await _snap('game_list');
    });

    testWidgets('Spiel-Setup', (tester) async {
      await _pump(tester, GameSetupScreen(game: goldenGame));
      await _snap('game_setup');
    });

    testWidgets('Live-Screen', (tester) async {
      await _pump(tester, LiveScreen(game: goldenGame));
      await _snap('live');
    });

    testWidgets('Live-Screen mit Formular', (tester) async {
      await _pump(tester, LiveScreen(game: goldenGame));
      await tester.tapAt(
        tester.getCenter(find.byKey(const Key('pitch_canvas'))),
      );
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
      await _pump(tester, ReviewScreen(game: goldenGame));
      await _snap('review_scenes');
    });

    testWidgets('Nachbereitung — Szene bearbeiten', (tester) async {
      await _pump(tester, ReviewScreen(game: goldenGame));
      await tester.tap(find.byTooltip('Bearbeiten').at(2));
      await tester.pumpAndSettle();
      await _snap('review_edit');
    });

    testWidgets('Nachbereitung — Coaching', (tester) async {
      await _pump(tester, ReviewScreen(game: goldenGame));
      await tester.tap(find.text('Coaching'));
      await tester.pumpAndSettle();
      await _snap('review_coaching');
    });

    testWidgets('Nachbereitung — Statistik', (tester) async {
      await _pump(tester, ReviewScreen(game: goldenGame));
      await tester.tap(find.text('Statistik'));
      await tester.pumpAndSettle();
      await _snap('review_stats');
    });
  });
}
