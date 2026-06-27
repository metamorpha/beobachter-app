import 'package:flutter/material.dart';

import '../../domain/entities/event.dart';

/// Interaktiver Spielfeld-Sketch als CustomPainter.
/// Tap-Koordinaten werden als normalisierte Werte (0.0–1.0) zurückgegeben.
class PitchCanvas extends StatelessWidget {
  final List<Event> events;
  final void Function(double x, double y) onTap;
  final bool dimmed;

  const PitchCanvas({
    super.key,
    required this.events,
    required this.onTap,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('pitch_canvas'),
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.globalPosition);
        final x = (local.dx / box.size.width).clamp(0.0, 1.0);
        final y = (local.dy / box.size.height).clamp(0.0, 1.0);
        onTap(x, y);
      },
      child: ClipRect(
        child: CustomPaint(
          painter: _PitchPainter(events: events, dimmed: dimmed),
          child: dimmed
              ? Container(color: Colors.black.withOpacity(0.3))
              : const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  final List<Event> events;
  final bool dimmed;

  _PitchPainter({required this.events, required this.dimmed});

  @override
  void paint(Canvas canvas, Size size) {
    final grassPaint = Paint()..color = const Color(0xFF2E7D32);
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final markerPaint = Paint()..color = Colors.red;

    // Rasen
    canvas.drawRect(Offset.zero & size, grassPaint);

    final w = size.width;
    final h = size.height;

    // Mittellinie
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), linePaint);

    // Mittelkreis
    canvas.drawCircle(Offset(w / 2, h / 2), h * 0.18, linePaint);

    // Außenlinien
    canvas.drawRect(
        Rect.fromLTWH(4, 4, w - 8, h - 8), linePaint);

    // Strafräume (links & rechts)
    final boxW = w * 0.16;
    final boxH = h * 0.44;
    canvas.drawRect(
        Rect.fromLTWH(4, h / 2 - boxH / 2, boxW, boxH), linePaint);
    canvas.drawRect(
        Rect.fromLTWH(w - 4 - boxW, h / 2 - boxH / 2, boxW, boxH), linePaint);

    // Toräume (links & rechts)
    final goalBoxW = w * 0.06;
    final goalBoxH = h * 0.22;
    canvas.drawRect(
        Rect.fromLTWH(4, h / 2 - goalBoxH / 2, goalBoxW, goalBoxH), linePaint);
    canvas.drawRect(
        Rect.fromLTWH(w - 4 - goalBoxW, h / 2 - goalBoxH / 2, goalBoxW, goalBoxH),
        linePaint);

    // Mittelpunkt
    canvas.drawCircle(Offset(w / 2, h / 2), 4, Paint()..color = Colors.white);

    // Ereignis-Marker
    for (final e in events) {
      final pos = Offset(e.locationX * w, e.locationY * h);
      canvas.drawCircle(pos, 6, markerPaint);
      canvas.drawCircle(
          pos, 6, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_PitchPainter old) =>
      old.events != events || old.dimmed != dimmed;
}
