import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/presentation/widgets/heatmap_canvas.dart';

Event _event(double x, double y, {String id = 'e1'}) => Event(
      id: id,
      gameId: 'g1',
      elapsedMs: 0,
      type: EventType.footFoul,
      locationX: x,
      locationY: y,
      createdAt: DateTime(2026, 1, 1),
    );

double _densityAt(HeatmapDensity d, double x, double y) {
  final c = (x * HeatmapDensity.cols)
      .floor()
      .clamp(0, HeatmapDensity.cols - 1);
  final r = (y * HeatmapDensity.rows)
      .floor()
      .clamp(0, HeatmapDensity.rows - 1);
  return d.grid[r][c];
}

void main() {
  group('HeatmapDensity', () {
    test('TC-1401: leere Ereignisliste ergibt Nullgitter', () {
      final d = HeatmapDensity.fromEvents([]);
      for (final row in d.grid) {
        for (final v in row) {
          expect(v, 0.0);
        }
      }
    });

    test('TC-1402: Einzelereignis hat Maximum an Ereignisposition', () {
      final d = HeatmapDensity.fromEvents([_event(0.5, 0.5)]);
      expect(_densityAt(d, 0.5, 0.5), closeTo(1.0, 0.01));
      // Monoton abfallend mit wachsendem Abstand in x-Richtung
      final near = _densityAt(d, 0.55, 0.5);
      final far = _densityAt(d, 0.62, 0.5);
      expect(near, lessThan(1.0));
      expect(far, lessThan(near));
    });

    test('TC-1403: zwei identische Positionen normalisieren auf 1.0', () {
      final single = HeatmapDensity.fromEvents([_event(0.5, 0.5)]);
      final double_ = HeatmapDensity.fromEvents(
          [_event(0.5, 0.5, id: 'a'), _event(0.5, 0.5, id: 'b')]);
      expect(_densityAt(double_, 0.5, 0.5), closeTo(1.0, 0.01));
      // Normalisierte Verteilung ist identisch geformt wie beim Einzelereignis
      expect(_densityAt(double_, 0.55, 0.5),
          closeTo(_densityAt(single, 0.55, 0.5), 0.001));
    });

    test('TC-1404: zwei weit entfernte Einzelereignisse gleich intensiv', () {
      final d = HeatmapDensity.fromEvents(
          [_event(0.2, 0.5, id: 'a'), _event(0.8, 0.5, id: 'b')]);
      expect(_densityAt(d, 0.2, 0.5), closeTo(1.0, 0.01));
      expect(_densityAt(d, 0.8, 0.5), closeTo(1.0, 0.01));
      // Dazwischen fällt die Dichte deutlich ab
      expect(_densityAt(d, 0.5, 0.5), lessThan(0.1));
    });

    test('TC-1405: Ereignisse in Feldecken ohne Fehler', () {
      final d = HeatmapDensity.fromEvents(
          [_event(0.0, 0.0, id: 'a'), _event(1.0, 1.0, id: 'b')]);
      expect(_densityAt(d, 0.0, 0.0), greaterThan(0.9));
      expect(_densityAt(d, 1.0, 1.0), greaterThan(0.9));
    });

    test('TC-1406: Cluster intensiver, Einzelereignis bleibt sichtbar', () {
      final cluster = List.generate(
          5, (i) => _event(0.3 + i * 0.005, 0.5, id: 'c$i'));
      final d = HeatmapDensity.fromEvents([...cluster, _event(0.8, 0.5)]);
      final clusterDensity = _densityAt(d, 0.31, 0.5);
      final singleDensity = _densityAt(d, 0.8, 0.5);
      expect(clusterDensity, closeTo(1.0, 0.05));
      expect(singleDensity, greaterThan(0.1));
      expect(clusterDensity, greaterThan(singleDensity * 2));
    });

    test('TC-1407: Kernel ist radialsymmetrisch (hängt nur vom Abstand ab)',
        () {
      const ex = 0.5, ey = 0.5;
      final d = HeatmapDensity.fromEvents([_event(ex, ey)]);
      final peak = _densityAt(d, ex, ey);
      // Jede Zelle im Kernelbereich muss dem analytischen Gauß-Wert ihres
      // tatsächlichen Abstands zum Ereignis entsprechen — damit ist der
      // Abfall in x- und y-Richtung identisch.
      final twoSigmaSq = 2 * HeatmapDensity.sigma * HeatmapDensity.sigma;
      for (final offset in [
        [0.06, 0.0],
        [-0.06, 0.0],
        [0.0, 0.06],
        [0.0, -0.06],
        [0.04, 0.04],
      ]) {
        final x = ex + offset[0];
        final y = ey + offset[1];
        final c = (x * HeatmapDensity.cols).floor();
        final r = (y * HeatmapDensity.rows).floor();
        final dx = (c + 0.5) / HeatmapDensity.cols - ex;
        final dy = (r + 0.5) / HeatmapDensity.rows - ey;
        final expected = peak * exp(-(dx * dx + dy * dy) / twoSigmaSq);
        expect(d.grid[r][c], closeTo(expected, 0.02),
            reason: 'Offset $offset');
      }
    });
  });

  group('HeatmapCanvas Widget', () {
    testWidgets('TC-1408: rendert ohne Fehler bei 0, 1 und 50 Ereignissen',
        (tester) async {
      final rng = Random(42);
      for (final events in [
        <Event>[],
        [_event(0.5, 0.5)],
        List.generate(
            50, (i) => _event(rng.nextDouble(), rng.nextDouble(), id: 'e$i')),
      ]) {
        await tester.pumpWidget(MaterialApp(
          home: SizedBox(
              width: 400, height: 300, child: HeatmapCanvas(events: events)),
        ));
        expect(tester.takeException(), isNull);
        expect(find.byType(HeatmapCanvas), findsOneWidget);
      }
    });

    test('TC-1409: shouldRepaint bei geänderter Ereignisliste', () {
      final events1 = [_event(0.5, 0.5)];
      final events2 = [_event(0.3, 0.3)];
      final p1 = HeatmapPainter(events: events1);
      expect(p1.shouldRepaint(HeatmapPainter(events: events2)), isTrue);
      expect(p1.shouldRepaint(HeatmapPainter(events: events1)), isFalse);
    });
  });
}
