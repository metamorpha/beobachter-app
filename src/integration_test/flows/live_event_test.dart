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

  testWidgets('Tap auf Spielfeld öffnet Ereignisformular', (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('pitch_canvas')));
    await tester.pumpAndSettle();

    expect(find.text('Ereignis erfassen'), findsOneWidget);
    expect(find.byKey(const Key('btn_save_event')), findsOneWidget);
  });

  testWidgets('Speichern-Button ist deaktiviert ohne Ereignistyp', (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('pitch_canvas')));
    await tester.pumpAndSettle();

    final saveBtn = tester.widget<ElevatedButton>(
      find.byKey(const Key('btn_save_event')),
    );
    expect(saveBtn.onPressed, isNull);
  });

  testWidgets('Kritischer Pfad: Ereignistyp wählen aktiviert Speichern-Button',
      (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('pitch_canvas')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('event_type_footFoul')));
    await tester.pumpAndSettle();

    final saveBtn = tester.widget<ElevatedButton>(
      find.byKey(const Key('btn_save_event')),
    );
    expect(saveBtn.onPressed, isNotNull);
  });

  testWidgets('Kritischer Pfad: Ereignis mit Typ + Entscheidung speichern',
      (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('pitch_canvas')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('event_type_footFoul')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('decision_freeKick')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('btn_save_event')));
    await tester.pumpAndSettle();

    // Formular geschlossen — Spielfeld wieder sichtbar
    expect(find.text('Ereignis erfassen'), findsNothing);
    expect(find.byKey(const Key('pitch_canvas')), findsOneWidget);
  });

  testWidgets('Schließen-Button schließt Formular ohne zu speichern',
      (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('pitch_canvas')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('event_type_offside')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('btn_close_event_form')));
    await tester.pumpAndSettle();

    expect(find.text('Ereignis erfassen'), findsNothing);
    // Kein Ereignis in der Letzte-Ereignisse-Liste
    expect(find.text("Abseits"), findsNothing);
  });

  testWidgets('Bewertung wählen und Ereignis speichern', (tester) async {
    await openLiveScreen(tester);

    await tester.tap(find.byKey(const Key('pitch_canvas')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('event_type_handball')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('assessment_correctExpected')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('btn_save_event')));
    await tester.pumpAndSettle();

    expect(find.text('Ereignis erfassen'), findsNothing);
  });
}
