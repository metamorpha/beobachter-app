import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../domain/entities/event.dart';

/// Kontinuierliche Dichte-Heatmap (KDE): Jedes Ereignis trägt eine weiche
/// Gauß-Glocke bei, Überlagerungen addieren sich. Hotspots erscheinen
/// punktgenau und intensiv, ohne sichtbare Rasterkanten.
class HeatmapCanvas extends StatelessWidget {
  final List<Event> events;

  const HeatmapCanvas({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HeatmapPainter(events: events),
      child: const SizedBox.expand(),
    );
  }
}

/// Reine Dichteberechnung auf einem festen logischen Gitter.
/// Getrennt vom Rendering, damit sie ohne Canvas unit-testbar ist.
class HeatmapDensity {
  static const int cols = 96;
  static const int rows = 64;

  /// Gauß-Bandbreite in normierten Feldkoordinaten (0.0–1.0).
  static const double sigma = 0.04;

  /// Normalisiertes Dichtegitter [rows][cols], Maximum = 1.0
  /// (bzw. Nullgitter bei leerer Ereignisliste).
  final List<List<double>> grid;

  HeatmapDensity._(this.grid);

  factory HeatmapDensity.fromEvents(List<Event> events) {
    final grid = List.generate(rows, (_) => List.filled(cols, 0.0));
    if (events.isEmpty) return HeatmapDensity._(grid);

    // Kernel bei 3σ abschneiden; Zellabstände in normierten Einheiten.
    final radiusX = (3 * sigma * cols).ceil();
    final radiusY = (3 * sigma * rows).ceil();
    final twoSigmaSq = 2 * sigma * sigma;

    double maxDensity = 0;
    for (final e in events) {
      final cx = (e.locationX * cols).clamp(0.0, cols - 1.0);
      final cy = (e.locationY * rows).clamp(0.0, rows - 1.0);
      final c0 = max(0, cx.floor() - radiusX);
      final c1 = min(cols - 1, cx.floor() + radiusX);
      final r0 = max(0, cy.floor() - radiusY);
      final r1 = min(rows - 1, cy.floor() + radiusY);

      for (int r = r0; r <= r1; r++) {
        for (int c = c0; c <= c1; c++) {
          final dx = (c + 0.5) / cols - e.locationX;
          final dy = (r + 0.5) / rows - e.locationY;
          final distSq = dx * dx + dy * dy;
          grid[r][c] += exp(-distSq / twoSigmaSq);
          maxDensity = max(maxDensity, grid[r][c]);
        }
      }
    }

    if (maxDensity > 0) {
      for (final row in grid) {
        for (int c = 0; c < cols; c++) {
          row[c] /= maxDensity;
        }
      }
    }
    return HeatmapDensity._(grid);
  }
}

class HeatmapPainter extends CustomPainter {
  final List<Event> events;
  late final HeatmapDensity _density = HeatmapDensity.fromEvents(events);

  // Ab dieser normierten Dichte wird eine Zelle gezeichnet.
  static const double _threshold = 0.05;

  HeatmapPainter({required this.events});

  /// Farbrampe: gelb (niedrig) → orange → rot (Maximum),
  /// Alpha von 0.15 (Einzelereignis sichtbar) bis 0.85 (Linien durchscheinend).
  static Color colorFor(double intensity) {
    final t = intensity.clamp(0.0, 1.0);
    final color = t < 0.5
        ? Color.lerp(Colors.yellow, Colors.orange, t * 2)!
        : Color.lerp(Colors.orange, Colors.red, (t - 0.5) * 2)!;
    return color.withValues(alpha: 0.15 + 0.70 * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cellW = w / HeatmapDensity.cols;
    final cellH = h / HeatmapDensity.rows;

    // Rasen
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF2E7D32));

    // Dichte-Overlay: alle Zellen in eine Ebene zeichnen und diese einmal
    // weichzeichnen — glättet die Gitterkanten des 96×64-Rasters in einem Pass.
    canvas.saveLayer(
      Offset.zero & size,
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
            sigmaX: cellW, sigmaY: cellH, tileMode: TileMode.decal),
    );
    final cellPaint = Paint();
    for (int r = 0; r < HeatmapDensity.rows; r++) {
      for (int c = 0; c < HeatmapDensity.cols; c++) {
        final intensity = _density.grid[r][c];
        if (intensity < _threshold) continue;
        cellPaint.color = colorFor(intensity);
        canvas.drawRect(
          Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH),
          cellPaint,
        );
      }
    }
    canvas.restore();

    // Feldlinien (vereinfacht)
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(2, 2, w - 4, h - 4), linePaint);
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), linePaint);
  }

  @override
  bool shouldRepaint(HeatmapPainter old) => old.events != events;
}
