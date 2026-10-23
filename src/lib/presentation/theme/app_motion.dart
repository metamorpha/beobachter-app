import 'package:flutter/widgets.dart';

/// Dauern und Kurven für Übergänge (US-606). Bei „Bewegung reduzieren"
/// liefert [of] immer [Duration.zero].
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 350);

  static const Curve curve = Curves.easeOutCubic;

  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
          ? Duration.zero
          : duration;

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}
