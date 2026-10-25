import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/form_factor.dart';
import 'device_providers.dart';

/// Legt auf Android-Smartphones die Ausrichtung des umschlossenen Screens fest:
/// Live-Screen quer, alle anderen hoch (US-701, US-703). Tablets und Windows
/// bleiben unberührt.
///
/// Geschachtelte Screens bilden einen Stapel: Wird der oberste Screen
/// geschlossen, gilt wieder die Ausrichtung des darunterliegenden.
class PreferredOrientation extends ConsumerStatefulWidget {
  final bool landscape;
  final Widget child;

  const PreferredOrientation({
    super.key,
    required this.landscape,
    required this.child,
  });

  static const _landscape = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
  static const _portrait = [DeviceOrientation.portraitUp];

  static final List<_PreferredOrientationState> _stack = [];

  @override
  ConsumerState<PreferredOrientation> createState() =>
      _PreferredOrientationState();
}

class _PreferredOrientationState extends ConsumerState<PreferredOrientation> {
  bool? _active;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nur einmal entscheiden — beim Drehen ändert sich die kürzere Seite nicht
    if (_active != null) return;
    _active = ref.read(isAndroidProvider) && FormFactor.isPhone(context);
    if (_active!) {
      PreferredOrientation._stack.add(this);
      _apply(widget.landscape);
    }
  }

  @override
  void dispose() {
    if (_active ?? false) {
      final stack = PreferredOrientation._stack..remove(this);
      _apply(stack.lastOrNull?.widget.landscape ?? false);
    }
    super.dispose();
  }

  static void _apply(bool landscape) => SystemChrome.setPreferredOrientations(
    landscape
        ? PreferredOrientation._landscape
        : PreferredOrientation._portrait,
  );

  @override
  Widget build(BuildContext context) => widget.child;
}
