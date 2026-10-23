import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Große Auswahlfläche mit animiertem Auswahlzustand (US-603).
/// Beim Drücken skaliert die Kachel kurz auf 96 %, die Farbe wechselt weich.
/// Der Tap wird sofort ausgelöst — keine Animation verzögert die Eingabe.
class SelectTile extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  /// Akzentfarbe im ausgewählten Zustand (Standard: `primary`).
  final Color? color;

  /// Hintergrund im nicht ausgewählten Zustand (Standard: Fläche mit Rand).
  final Color? unselectedColor;

  final double minHeight;
  final double? width;
  final bool dense;

  const SelectTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
    this.unselectedColor,
    this.minHeight = AppSizes.liveTap,
    this.width,
    this.dense = false,
  });

  @override
  State<SelectTile> createState() => _SelectTileState();
}

class _SelectTileState extends State<SelectTile> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final accent = widget.color ?? scheme.primary;
    final bg = widget.selected
        ? accent
        : (widget.unselectedColor ?? scheme.surface);
    final fg = widget.selected
        ? AppColors.onColor(accent)
        : (widget.unselectedColor != null
            ? AppColors.onColor(widget.unselectedColor!)
            : scheme.onSurface);
    final border = widget.selected
        ? accent
        : (widget.unselectedColor != null
            ? Colors.transparent
            : scheme.outlineVariant);
    final duration = AppMotion.of(context, AppMotion.fast);
    final iconColor =
        widget.selected || widget.unselectedColor != null ? fg : accent;

    final labelText = Text(
      widget.label,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.text.labelLarge?.copyWith(
        fontSize: widget.dense ? 14 : 15,
        color: fg,
        fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w600,
        height: 1.15,
      ),
    );

    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: duration,
      curve: AppMotion.curve,
      child: AnimatedContainer(
        duration: duration,
        curve: AppMotion.curve,
        width: widget.width,
        constraints: BoxConstraints(minHeight: widget.minHeight),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(color: border, width: 1.5),
          boxShadow: widget.selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.m),
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.dense ? AppSpacing.s : AppSpacing.m,
                  vertical: AppSpacing.xs + 2,
                ),
                child: Center(
                  widthFactor: 1,
                  child: widget.icon == null
                      ? labelText
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(widget.icon, size: 22, color: iconColor),
                            const SizedBox(height: 2),
                            labelText,
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
