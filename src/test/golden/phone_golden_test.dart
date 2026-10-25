@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/presentation/platform/device_providers.dart';
import 'package:beobachter_app/presentation/screens/game_list/game_list_screen.dart';
import 'package:beobachter_app/presentation/screens/game_setup/game_setup_screen.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';

import 'golden_harness.dart';

/// Golden-Tests im Smartphone-Layout unter Android (US-701 – US-704):
/// Live-Screen quer, übrige Screens hoch.
///
/// Referenzbilder neu erzeugen: `flutter test --update-goldens --tags golden`
const _portrait = Size(390, 844);
const _landscape = Size(844, 390);

class _NoWakeLock implements ScreenWakeLock {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

Future<void> _pump(WidgetTester tester, Widget home, Size size) =>
    pumpGoldenScreen(
      tester,
      home,
      size: size,
      overrides: [
        isAndroidProvider.overrideWithValue(true),
        screenWakeLockProvider.overrideWithValue(_NoWakeLock()),
      ],
    );

void main() {
  group('Golden Smartphone', skip: goldenSkip, () {
    setUpAll(loadGoldenFonts);

    testWidgets('Spielliste', (tester) async {
      await _pump(tester, const GameListScreen(), _portrait);
      await snapGolden('phone_game_list');
    });

    testWidgets('Spiel-Setup', (tester) async {
      await _pump(tester, GameSetupScreen(game: goldenGame), _portrait);
      await snapGolden('phone_game_setup');
    });

    testWidgets('Live-Screen', (tester) async {
      await _pump(tester, LiveScreen(game: goldenGame), _landscape);
      await snapGolden('phone_live');
    });

    testWidgets('Live-Screen mit Formular', (tester) async {
      await _pump(tester, LiveScreen(game: goldenGame), _landscape);
      await tester.tap(find.byKey(const Key('pitch_canvas')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      await snapGolden('phone_live_form');
    });

    testWidgets('Live-Screen mit Ereignisliste', (tester) async {
      await _pump(tester, LiveScreen(game: goldenGame), _landscape);
      await tester.tap(find.byKey(const Key('btn_ereignisse')));
      await tester.pumpAndSettle();
      await snapGolden('phone_live_recent');
    });

    testWidgets('Nachbereitung — Szenen', (tester) async {
      await _pump(tester, ReviewScreen(game: goldenGame), _portrait);
      await snapGolden('phone_review_scenes');
    });

    testWidgets('Nachbereitung — Statistik', (tester) async {
      await _pump(tester, ReviewScreen(game: goldenGame), _portrait);
      await tester.tap(find.text('Statistik'));
      await tester.pumpAndSettle();
      await snapGolden('phone_review_stats');
    });
  });
}
