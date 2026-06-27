import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/app_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('Timer-Button zeigt START beim Start', (tester) async {
    await openLiveScreen(tester);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('Timer läuft nach START-Tap und Button wechselt zu STOP',
      (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('btn_timer_toggle')));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('STOP'), findsOneWidget);
    expect(find.text('00:00'), findsNothing);
  });

  testWidgets('Timer pausiert nach STOP-Tap', (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('btn_timer_toggle')));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('btn_timer_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('Timer setzt nach erneutem START fort ohne Reset', (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('btn_timer_toggle')));
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('btn_timer_toggle')));
    await tester.pumpAndSettle();

    final pausedLabel = (tester.widget(find.byKey(const Key('timer_label')))
            as Text)
        .data!;

    await tester.tap(find.byKey(const Key('btn_timer_toggle')));
    await tester.pump(const Duration(milliseconds: 500));

    final runningLabel = (tester.widget(find.byKey(const Key('timer_label')))
            as Text)
        .data!;

    expect(pausedLabel, isNot(equals('00:00')));
    expect(runningLabel, isNot(equals('00:00')));
  });
}
