import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Smoke test: verifies the test harness itself is wired correctly.
// Full app integration tests require a mocked database provider and
// are covered by the repository tests in test/data/repositories/.
void main() {
  testWidgets('Flutter test harness works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('ok'))));
    expect(find.text('ok'), findsOneWidget);
  });
}
