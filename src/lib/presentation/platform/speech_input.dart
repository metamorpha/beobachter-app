import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Warum ein Diktat nicht geklappt hat (US-218).
enum DictationError {
  /// Mikrofon oder Spracherkennung nicht freigegeben.
  permission,

  /// Kein Internet und kein Offline-Sprachpaket, Dienst nicht erreichbar.
  unavailable,

  /// Nichts verstanden.
  noMatch,
  other,
}

/// Spracheingabe über die Erkennung des Betriebssystems (US-218).
abstract interface class SpeechInput {
  /// Ob das Mikrofon angezeigt wird — ohne Freigabe-Dialog auszulösen.
  Future<bool> isAvailable();

  /// Startet ein Diktat auf Deutsch. [onResult] liefert den bisher erkannten
  /// Text dieser Aufnahme (Zwischenstände), [onDone] kommt genau einmal: nach
  /// [stop], nach einer Sprechpause, bei einem Fehler oder wenn ein anderes
  /// Feld ein neues Diktat startet.
  Future<void> listen({
    required void Function(String words) onResult,
    required void Function(DictationError? error) onDone,
  });

  /// Beendet die Aufnahme; das letzte Ergebnis wird noch geliefert.
  Future<void> stop();
}

/// Umsetzung mit dem Paket `speech_to_text` — iOS, Android, Windows.
class SpeechToTextInput implements SpeechInput {
  static const _pause = Duration(seconds: 3);
  static const _maxDuration = Duration(minutes: 1);

  final _stt = SpeechToText();
  Future<bool>? _init;
  String? _localeId;

  void Function(String)? _onResult;
  void Function(DictationError?)? _onDone;

  /// Bis der Status `listening` kommt, kann ein `done` noch von der vorigen
  /// (abgebrochenen) Aufnahme stammen.
  bool _starting = false;

  static bool get _platformSupported =>
      Platform.isAndroid || Platform.isIOS || Platform.isWindows;

  Future<bool> _initialize() => _init ??= _stt
      .initialize(onError: _handleError, onStatus: _handleStatus)
      .catchError((Object _) => false);

  @override
  Future<bool> isAvailable() async {
    if (!_platformSupported) return false;
    // Unter Windows fragt initialize() nicht nach — direkt prüfen. Auf dem
    // Handy würde es den Freigabe-Dialog öffnen, das passiert erst beim Tap.
    if (Platform.isWindows) return _initialize();
    return true;
  }

  @override
  Future<void> listen({
    required void Function(String words) onResult,
    required void Function(DictationError? error) onDone,
  }) async {
    if (_onDone != null) {
      _finish(null);
      await _stt.cancel();
    }
    _onResult = onResult;
    _onDone = onDone;
    _starting = true;

    if (!await _initialize()) {
      _finish(await _stt.hasPermission
          ? DictationError.unavailable
          : DictationError.permission);
      return;
    }
    try {
      await _stt.listen(
        onResult: (r) => _onResult?.call(r.recognizedWords),
        listenOptions: SpeechListenOptions(
          localeId: await _germanLocale(),
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
          pauseFor: _pause,
          listenFor: _maxDuration,
        ),
      );
    } on Exception {
      _finish(DictationError.other);
    }
  }

  @override
  Future<void> stop() async {
    if (_onDone == null) return;
    await _stt.stop();
  }

  Future<String?> _germanLocale() async {
    if (_localeId != null) return _localeId;
    final locales = await _stt.locales();
    String norm(String id) => id.replaceAll('-', '_').toLowerCase();
    final de = locales.where((l) => norm(l.localeId) == 'de_de').firstOrNull ??
        locales.where((l) => norm(l.localeId).startsWith('de')).firstOrNull;
    return _localeId = de?.localeId ?? 'de_DE';
  }

  void _handleStatus(String status) {
    if (status == SpeechToText.listeningStatus) {
      _starting = false;
    } else if (status == SpeechToText.doneStatus && !_starting) {
      _finish(null);
    }
  }

  void _handleError(SpeechRecognitionError error) {
    if (_onDone == null) return;
    _finish(errorFor(error.errorMsg));
    _stt.cancel();
  }

  void _finish(DictationError? error) {
    final done = _onDone;
    _onDone = null;
    _onResult = null;
    _starting = false;
    done?.call(error);
  }

  /// Fehlercodes von Android (`SpeechRecognizer`) und iOS (`SFSpeech…`).
  static DictationError errorFor(String code) => switch (code) {
        'error_permission' ||
        'error_speech_recognizer_request_not_authorized' =>
          DictationError.permission,
        'error_network' ||
        'error_network_timeout' ||
        'error_server' ||
        'error_server_disconnected' ||
        'error_language_unavailable' ||
        'error_language_not_supported' ||
        'error_assets_not_installed' ||
        'error_speech_recognizer_disabled' =>
          DictationError.unavailable,
        'error_no_match' || 'error_speech_timeout' => DictationError.noMatch,
        _ => DictationError.other,
      };
}

final speechInputProvider = Provider<SpeechInput>((ref) => SpeechToTextInput());

/// Ob die Notizfelder ein Mikrofon zeigen (einmal pro App-Start geprüft).
final dictationAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(speechInputProvider).isAvailable(),
);
