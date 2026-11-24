import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Läuft die App auf Android oder iOS? Nur dort gibt es Display-Sperre und
/// feste Ausrichtung (US-702, US-803, US-804). Eigener Provider, damit Tests
/// die Plattform unabhängig vom Host-Betriebssystem setzen können.
final isMobileProvider =
    Provider<bool>((ref) => Platform.isAndroid || Platform.isIOS);

/// Hält das Display während des Spiels an (US-702, US-803).
abstract interface class ScreenWakeLock {
  Future<void> enable();
  Future<void> disable();
}

/// Setzt `FLAG_KEEP_SCREEN_ON` (Android, `MainActivity`) bzw.
/// `isIdleTimerDisabled` (iOS, `AppDelegate`) — ohne zusätzliches Paket.
class MethodChannelScreenWakeLock implements ScreenWakeLock {
  static const _channel = MethodChannel('de.beobachter/screen');

  const MethodChannelScreenWakeLock();

  @override
  Future<void> enable() => _channel.invokeMethod('setKeepScreenOn', true);

  @override
  Future<void> disable() => _channel.invokeMethod('setKeepScreenOn', false);
}

final screenWakeLockProvider = Provider<ScreenWakeLock>(
  (ref) => const MethodChannelScreenWakeLock(),
);
