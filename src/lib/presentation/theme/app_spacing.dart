/// Abstandsraster, Radien und Mindestgrößen für Tippflächen (US-601).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppRadius {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}

abstract final class AppSizes {
  /// Allgemeine Mindest-Tippfläche.
  static const double tap = 48;

  /// Tippflächen im Live-Screen (US-602, US-603).
  static const double liveTap = 56;

  /// Primäraktionen: Speichern, Phasenwechsel.
  static const double primaryAction = 64;

  /// Mindestbreite des Phasen-Buttons (US-602).
  static const double phaseButtonWidth = 160;
}
