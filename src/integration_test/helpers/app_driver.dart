import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beobachter_app/app.dart';
import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';

/// Startet die App mit einer leeren In-Memory-Datenbank.
/// Jeder Test erhält eine frische DB — kein Zustand zwischen Tests.
/// View-Größe wird auf Tablet-Querformat (1280×800) gesetzt,
/// da das Layout für diese Größe ausgelegt ist.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const BeobachterApp(),
    ),
  );
  await tester.pumpAndSettle();
}
