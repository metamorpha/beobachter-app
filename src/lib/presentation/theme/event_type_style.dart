import 'package:flutter/material.dart';

import '../../domain/enums/event_type.dart';

/// Icon und Markerfarbe je Ereignistyp — Formular-Kacheln, Spielfeld-Marker,
/// Ereignislisten (US-602, US-603).
extension EventTypeStyle on EventType {
  IconData get icon => switch (this) {
        EventType.footFoul => Icons.do_not_step,
        EventType.bodyFoul => Icons.accessibility_new,
        EventType.handball => Icons.back_hand_outlined,
        EventType.unsporting => Icons.sentiment_very_dissatisfied_outlined,
        EventType.violent => Icons.flash_on,
        EventType.offside => Icons.flag_outlined,
        EventType.advantage => Icons.fast_forward_rounded,
        EventType.custom => Icons.edit_note,
      };

  Color get color => switch (this) {
        EventType.footFoul => const Color(0xFFEA580C),
        EventType.bodyFoul => const Color(0xFFD97706),
        EventType.handball => const Color(0xFF7C3AED),
        EventType.unsporting => const Color(0xFFDB2777),
        EventType.violent => const Color(0xFFB91C1C),
        EventType.offside => const Color(0xFF0E7490),
        EventType.advantage => const Color(0xFF2563EB),
        EventType.custom => const Color(0xFF475569),
      };
}
