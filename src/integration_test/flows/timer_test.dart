import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/app_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Navigiert zum Live-Screen (über Game-Setup btn_start_game)
  Future<void> openLiveScreen(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('fab_new_game')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('btn_start_game')));
    await tester.tap(find.byKey(const Key('btn_start_game')));
    await tester.pumpAndSettle();
  }

  testWidgets('Timer zeigt 00:00 beim Start', (tester) async {
    await openLiveScreen(tester);
    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets('Timer-Button zeigt "Start" im Bereit-Zustand', (tester) async {
    await openLiveScreen(tester);
    // Nach openLiveScreen ist der LiveScreen sichtbar; btn_start_game
    // gehört jetzt zum Timer (bereit-Phase), nicht mehr zum Game-Setup.
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets(
      'Timer läuft nach Start-Tap; Button wechselt zu "Halbzeit"',
      (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('btn_start_game')));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byKey(const Key('btn_halbzeit')), findsOneWidget);
    expect(find.text('00:00'), findsNothing);
  });

  testWidgets(
      'Halbzeit-Tap stoppt Timer; Button wechselt zu "2. HZ starten"',
      (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('btn_start_game')));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('btn_halbzeit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('btn_start_zweite_halbzeit')), findsOneWidget);
  });

  testWidgets('Timer setzt nach 2. HZ-Start ohne Reset fort', (tester) async {
    await openLiveScreen(tester);

    // Start → 1. HZ
    await tester.tap(find.byKey(const Key('btn_start_game')));
    await tester.pump(const Duration(seconds: 2));

    // Halbzeit
    await tester.tap(find.byKey(const Key('btn_halbzeit')));
    await tester.pumpAndSettle();

    final pausedLabel =
        (tester.widget(find.byKey(const Key('timer_label'))) as Text).data!;

    // 2. HZ starten
    await tester.tap(find.byKey(const Key('btn_start_zweite_halbzeit')));
    await tester.pump(const Duration(milliseconds: 500));

    final runningLabel =
        (tester.widget(find.byKey(const Key('timer_label'))) as Text).data!;

    expect(pausedLabel, isNot(equals('00:00')));
    expect(runningLabel, isNot(equals('00:00')));
  });

  testWidgets('Phase-Label zeigt "1. Halbzeit" nach Start', (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('btn_start_game')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('timer_phase_label')), findsOneWidget);
    final label =
        (tester.widget(find.byKey(const Key('timer_phase_label'))) as Text)
            .data!;
    expect(label, '1. Halbzeit');
  });
}
