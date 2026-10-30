import 'package:flutter/material.dart';

import '../../domain/entities/game.dart';
import '../../domain/enums/kit_color.dart';
import '../../domain/enums/team_side.dart';
import 'app_colors.dart';

/// Darstellungswerte der Trikotfarben (US-111). Orange, Gelb und Grün weichen
/// bewusst von den Karten- und Bewertungsfarben ab.
extension KitColorStyle on KitColor {
  Color get color => switch (this) {
    KitColor.white => const Color(0xFFFFFFFF),
    KitColor.black => const Color(0xFF1A1A1A),
    KitColor.grey => const Color(0xFF6B7280),
    KitColor.red => const Color(0xFFC2261D),
    KitColor.burgundy => const Color(0xFF7F1D1D),
    KitColor.orange => const Color(0xFFF97316),
    KitColor.yellow => const Color(0xFFFDE047),
    KitColor.green => const Color(0xFF16A34A),
    KitColor.lightBlue => const Color(0xFF7DD3FC),
    KitColor.blue => const Color(0xFF1D4ED8),
    KitColor.purple => const Color(0xFF7C3AED),
  };
}

/// Trikotfarben beider Teams eines Spiels; ohne Auswahl gelten
/// [AppColors.home] / [AppColors.away].
@immutable
class TeamKits {
  final KitColor? home;
  final KitColor? away;

  const TeamKits({this.home, this.away});

  static const none = TeamKits();

  factory TeamKits.fromGame(Game game) =>
      TeamKits(home: game.homeKitColor, away: game.awayKitColor);

  KitColor? of(TeamSide side) => side == TeamSide.home ? home : away;

  Color color(BuildContext context, TeamSide side) =>
      of(side)?.color ?? context.colors.team(side);

  /// Beide Teams haben ausdrücklich dieselbe Farbe gewählt.
  bool get clash => home != null && home == away;
}

/// Rand für helle Teamfarben (Weiß, Gelb, Hellblau), damit sie auf hellem
/// Hintergrund sichtbar bleiben.
BorderSide? teamColorOutline(BuildContext context, Color color) =>
    AppColors.needsOutline(color)
    ? BorderSide(color: context.scheme.outline, width: 1.5)
    : null;
