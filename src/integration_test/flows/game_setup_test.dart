import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/app_driver.dart';

Future<void> startGame(WidgetTester tester,
    {String home = '', String away = ''}) async {
  await tester.tap(find.byKey(const Key('fab_new_game')));
  await tester.pumpAndSettle();

  if (home.isNotEmpty) {
    await tester.enterText(find.byKey(const Key('tf_home_team')), home);
  }
  if (away.isNotEmpty) {
    await tester.enterText(find.byKey(const Key('tf_away_team')), away);
  }
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byKey(const Key('btn_start_game')));
  await tester.tap(find.byKey(const Key('btn_start_game')));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Spiel anlegen öffnet Live-Screen mit korrekten Teamnamen',
      (tester) async {
    await pumpApp(tester);
    await startGame(tester, home: 'Borussia', away: 'Schalke');

    expect(find.text('Borussia – Schalke'), findsOneWidget);
    expect(find.byKey(const Key('pitch_canvas')), findsOneWidget);
    expect(find.byKey(const Key('btn_start_game')), findsOneWidget);
  });

  testWidgets('Spiel ohne Teamnamen öffnet Live-Screen mit Platzhaltern',
      (tester) async {
    await pumpApp(tester);
    await startGame(tester);

    expect(find.text('Heim – Gast'), findsOneWidget);
    expect(find.byKey(const Key('pitch_canvas')), findsOneWidget);
  });

  testWidgets('Angelegtes Spiel erscheint in der Spielliste', (tester) async {
    await pumpApp(tester);
    await startGame(tester, home: 'Dortmund', away: 'Bayern');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Dortmund – Bayern'), findsOneWidget);
  });
}
