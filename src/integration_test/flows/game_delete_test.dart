import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/app_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> createGameAndReturn(WidgetTester tester, String home, String away) async {
    await tester.tap(find.byKey(const Key('fab_new_game')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tf_home_team')), home);
    await tester.enterText(find.byKey(const Key('tf_away_team')), away);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('btn_start_game')));
    await tester.tap(find.byKey(const Key('btn_start_game')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  testWidgets('Spiel löschen nach Bestätigung entfernt Kachel', (tester) async {
    await pumpApp(tester);
    await createGameAndReturn(tester, 'Hamburg', 'Werder');

    expect(find.text('Hamburg – Werder'), findsOneWidget);

    final deleteBtn = find.byWidgetPredicate(
      (w) => w is IconButton && w.key.toString().contains('btn_delete_game'),
    );
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dialog_btn_delete_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Hamburg – Werder'), findsNothing);
    expect(find.text('Noch keine Spiele erfasst.'), findsOneWidget);
  });

  testWidgets('Abbrechen im Lösch-Dialog lässt Spiel bestehen', (tester) async {
    await pumpApp(tester);
    await createGameAndReturn(tester, 'Mainz', 'Köln');

    final deleteBtn = find.byWidgetPredicate(
      (w) => w is IconButton && w.key.toString().contains('btn_delete_game'),
    );
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dialog_btn_cancel')));
    await tester.pumpAndSettle();

    expect(find.text('Mainz – Köln'), findsOneWidget);
  });

  testWidgets('Löschen des letzten Spiels zeigt Leer-Hinweis', (tester) async {
    await pumpApp(tester);
    await createGameAndReturn(tester, 'Freiburg', 'Stuttgart');

    final deleteBtn = find.byWidgetPredicate(
      (w) => w is IconButton && w.key.toString().contains('btn_delete_game'),
    );
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dialog_btn_delete_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Noch keine Spiele erfasst.'), findsOneWidget);
  });
}
