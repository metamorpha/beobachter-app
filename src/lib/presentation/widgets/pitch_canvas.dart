import 'package:flutter/material.dart';

import '../../domain/entities/event.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/event_type_style.dart';

/// Interaktiver Spielfeld-Sketch als CustomPainter.
/// Tap-Koordinaten werden als normalisierte Werte (0.0–1.0) zurückgegeben.
/// Ein Tap zeigt sofort einen Ring an der Tap-Stelle, neue Marker blenden
/// kurz ein (US-602, US-606).
class PitchCanvas extends StatefulWidget {
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
  State<PitchCanvas> createState() => _PitchCanvasState();
}

class _PitchCanvasState extends State<PitchCanvas>
    with TickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final AnimationController _markerIn = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: 1,
  );
  Offset? _rippleAt;
  Set<String> _newIds = const {};

  @override
  void didUpdateWidget(PitchCanvas old) {
    super.didUpdateWidget(old);
    final before = old.events.map((e) => e.id).toSet();
    final added = widget.events
        .map((e) => e.id)
        .where((id) => !before.contains(id))
        .toSet();
    if (added.isNotEmpty && !AppMotion.reduced(context)) {
      _newIds = added;
      _markerIn.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ripple.dispose();
    _markerIn.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(details.globalPosition);
    final x = (local.dx / box.size.width).clamp(0.0, 1.0);
    final y = (local.dy / box.size.height).clamp(0.0, 1.0);
    if (!AppMotion.reduced(context)) {
      _rippleAt = Offset(x, y);
      _ripple.forward(from: 0);
    }
    widget.onTap(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      key: const Key('pitch_canvas'),
      onTapDown: _handleTapDown,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.l),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _PitchPainter(
                events: widget.events,
                colors: colors,
                newIds: _newIds,
                markerIn: _markerIn,
                ripple: _ripple,
                rippleAt: _rippleAt,
              ),
              child: const SizedBox.expand(),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: widget.dimmed ? 1 : 0,
                duration: AppMotion.of(context, AppMotion.medium),
                curve: AppMotion.curve,
                child: const ColoredBox(color: Color(0x47000000)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  final List<Event> events;
  final AppColors colors;
  final Set<String> newIds;
  final Animation<double> markerIn;
  final Animation<double> ripple;
  final Offset? rippleAt;

  _PitchPainter({
    required this.events,
    required this.colors,
    required this.newIds,
    required this.markerIn,
    required this.ripple,
    required this.rippleAt,
  }) : super(repaint: Listenable.merge([markerIn, ripple]));

  static const _stripes = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Rasen mit Mähstreifen
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.pitch);
    final stripePaint = Paint()..color = colors.pitchStripe;
    final stripeW = w / _stripes;
    for (var i = 0; i < _stripes; i += 2) {
      canvas.drawRect(Rect.fromLTWH(i * stripeW, 0, stripeW, h), stripePaint);
    }

    final line = Paint()
      ..color = colors.pitchLine
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const m = 10.0;
    final field = Rect.fromLTWH(m, m, w - 2 * m, h - 2 * m);

    // Außenlinien, Mittellinie, Mittelkreis, Mittelpunkt
    canvas.drawRRect(
        RRect.fromRectAndRadius(field, const Radius.circular(2)), line);
    canvas.drawLine(Offset(w / 2, m), Offset(w / 2, h - m), line);
    canvas.drawCircle(Offset(w / 2, h / 2), h * 0.16, line);
    canvas.drawCircle(
        Offset(w / 2, h / 2), 4, Paint()..color = colors.pitchLine);

    // Strafräume, Torräume, Strafstoßpunkte, Teilkreise
    final boxW = field.width * 0.16;
    final boxH = field.height * 0.44;
    final goalBoxW = field.width * 0.06;
    final goalBoxH = field.height * 0.22;
    for (final left in [true, false]) {
      final x0 = left ? field.left : field.right - boxW;
      canvas.drawRect(Rect.fromLTWH(x0, h / 2 - boxH / 2, boxW, boxH), line);
      final gx0 = left ? field.left : field.right - goalBoxW;
      canvas.drawRect(
          Rect.fromLTWH(gx0, h / 2 - goalBoxH / 2, goalBoxW, goalBoxH), line);
      final spot = Offset(
          left ? field.left + boxW * 0.7 : field.right - boxW * 0.7, h / 2);
      canvas.drawCircle(spot, 3, Paint()..color = colors.pitchLine);
      final arcR = h * 0.12;
      canvas.drawArc(
        Rect.fromCircle(center: spot, radius: arcR),
        left ? -0.93 : 3.14159 - 0.93,
        1.86,
        false,
        line,
      );
    }

    // Ereignis-Marker in Typ-Farbe; neue Marker „ploppen" ein
    final shadow = Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final popIn = Curves.easeOutBack.transform(markerIn.value);
    for (final e in events) {
      final pos = Offset(e.locationX * w, e.locationY * h);
      final r = 8.0 * (newIds.contains(e.id) ? popIn : 1.0);
      if (r <= 0) continue;
      canvas.drawCircle(pos.translate(0, 1.5), r, shadow);
      canvas.drawCircle(pos, r, Paint()..color = e.type.color);
      canvas.drawCircle(pos, r, ring);
    }

    // Tap-Rückmeldung: Ring wächst und blendet aus
    final at = rippleAt;
    if (at != null && ripple.isAnimating) {
      final t = Curves.easeOut.transform(ripple.value);
      canvas.drawCircle(
        Offset(at.dx * w, at.dy * h),
        10 + 26 * t,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85 * (1 - t))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(_PitchPainter old) =>
      old.events != events ||
      old.newIds != newIds ||
      old.rippleAt != rippleAt ||
      old.colors != colors;
}
