import 'package:flutter/material.dart';

import '../../domain/enums/card_type.dart';
import '../../domain/enums/team_side.dart';

/// Farben mit fester fachlicher Bedeutung (US-601). Überall gleich verwendet:
/// Heim/Gast, Bewertung, Karten, Coaching, Phasen-Aktionen, Spielfeld.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color home;
  final Color away;
  final Color correct;
  final Color wrong;
  final Color yellowCard;
  final Color yellowRedCard;
  final Color redCard;
  final Color coaching;
  final Color phaseStart;
  final Color phasePause;
  final Color phaseStop;
  final Color phaseFinish;
  final Color pitch;
  final Color pitchStripe;
  final Color pitchLine;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  const AppColors({
    required this.home,
    required this.away,
    required this.correct,
    required this.wrong,
    required this.yellowCard,
    required this.yellowRedCard,
    required this.redCard,
    required this.coaching,
    required this.phaseStart,
    required this.phasePause,
    required this.phaseStop,
    required this.phaseFinish,
    required this.pitch,
    required this.pitchStripe,
    required this.pitchLine,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  static const light = AppColors(
    home: Color(0xFF1D4ED8),
    away: Color(0xFFC2261D),
    correct: Color(0xFF15803D),
    wrong: Color(0xFFB91C1C),
    yellowCard: Color(0xFFFACC15),
    yellowRedCard: Color(0xFFEA580C),
    redCard: Color(0xFFB91C1C),
    coaching: Color(0xFFF59E0B),
    phaseStart: Color(0xFF15803D),
    phasePause: Color(0xFFC2410C),
    phaseStop: Color(0xFFB91C1C),
    phaseFinish: Color(0xFF334155),
    pitch: Color(0xFF2F7D3B),
    pitchStripe: Color(0xFF2A7235),
    pitchLine: Color(0xF2FFFFFF),
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFEF3C7),
    onWarningContainer: Color(0xFF78350F),
  );

  Color team(TeamSide side) => side == TeamSide.home ? home : away;

  Color card(CardType type) => switch (type) {
        CardType.yellow => yellowCard,
        CardType.yellowRed => yellowRedCard,
        CardType.red => redCard,
      };

  /// Lesbare Schriftfarbe auf einer der obigen Flächen.
  static Color onColor(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
          ? Colors.white
          : const Color(0xFF1A1A1A);

  /// Helle Flächen (z. B. weiße Trikotfarbe) brauchen einen Rand (US-111).
  static bool needsOutline(Color background) =>
      background.computeLuminance() > 0.5;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => other ?? this;
}

extension AppColorsContext on BuildContext {
  /// Fallback auf [AppColors.light], falls ein Widget außerhalb des App-Themes
  /// gebaut wird (z. B. in Widget-Tests mit nacktem `MaterialApp`).
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
