import 'package:flutter/widgets.dart';

/// Unterscheidet Smartphone- und Tablet-Layout (US-701 – US-704).
///
/// Die Weiche hängt an der Bildschirmgröße, nicht an der Plattform: Android-
/// Tablets und das Windows-Surface (Fenster maximiert, nicht verkleinerbar)
/// bekommen immer das Tablet-Layout.
abstract final class FormFactor {
  /// Kürzere Bildschirmseite, unter der das Smartphone-Layout gilt.
  static const double phoneMaxShortestSide = 600;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide < phoneMaxShortestSide;
}
