import 'dart:math';
import 'package:flutter/material.dart';

import '../../domain/entities/event.dart';

/// Vereinfachte Heatmap: Spielfeld in 6×4-Zonen unterteilt.
/// Ereignishäufigkeit pro Zone bestimmt die Farbintensität.
class HeatmapCanvas extends StatelessWidget {
  final List<Event> events;
  static const _cols = 6;
  static const _rows = 4;

  const HeatmapCanvas({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeatmapPainter(events: events),
      child: const SizedBox.expand(),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<Event> events;

  _HeatmapPainter({required this.events});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cellW = w / HeatmapCanvas._cols;
    final cellH = h / HeatmapCanvas._rows;

    // Zähle Ereignisse pro Zone
    final counts = List.generate(
        HeatmapCanvas._rows,
        (_) => List.filled(HeatmapCanvas._cols, 0));
    int maxCount = 1;

    for (final e in events) {
      final col = (e.locationX * HeatmapCanvas._cols).floor().clamp(0, HeatmapCanvas._cols - 1);
      final row = (e.locationY * HeatmapCanvas._rows).floor().clamp(0, HeatmapCanvas._rows - 1);
      counts[row][col]++;
      maxCount = max(maxCount, counts[row][col]);
    }

    // Rasen
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF2E7D32));

    // Heatmap-Zellen
    for (int r = 0; r < HeatmapCanvas._rows; r++) {
      for (int c = 0; c < HeatmapCanvas._cols; c++) {
        final intensity = counts[r][c] / maxCount;
        if (intensity == 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH),
          Paint()
            ..color =
                Colors.orange.withOpacity(intensity.clamp(0.15, 0.85)),
        );
      }
    }

    // Feldlinien (vereinfacht)
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(2, 2, w - 4, h - 4), linePaint);
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), linePaint);
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) => old.events != events;
}
