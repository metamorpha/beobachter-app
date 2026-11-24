import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/speech_input.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Mikrofon im Notizfeld (US-218) — als `suffixIcon` einsetzen. Ein Tap
/// startet das Diktat, ein zweiter beendet es; der erkannte Text wird an den
/// vorhandenen Text von [controller] angehängt. Einbau über [suffix], damit
/// das Feld ohne Spracherkennung auf dem Gerät unverändert bleibt.
class DictationButton extends ConsumerStatefulWidget {
  final TextEditingController controller;

  /// Nach dem Diktat, z. B. zum Speichern von Notizen ohne eigenen Button.
  final VoidCallback? onFinished;

  const DictationButton({super.key, required this.controller, this.onFinished});

  /// Das Mikrofon für `InputDecoration.suffixIcon` — `null`, wenn das Gerät
  /// keine Spracherkennung hat.
  static Widget? suffix(
    WidgetRef ref,
    TextEditingController controller, {
    VoidCallback? onFinished,
  }) =>
      ref.watch(dictationAvailableProvider).valueOrNull == true
          ? DictationButton(controller: controller, onFinished: onFinished)
          : null;

  /// Hängt diktierten Text mit einem Leerzeichen an.
  static String append(String base, String words) {
    if (base.isEmpty || words.isEmpty || RegExp(r'\s$').hasMatch(base)) {
      return base + words;
    }
    return '$base $words';
  }

  @override
  ConsumerState<DictationButton> createState() => _DictationButtonState();
}

class _DictationButtonState extends ConsumerState<DictationButton>
    with SingleTickerProviderStateMixin {
  late final SpeechInput _speech;
  late final AnimationController _pulse;
  bool _listening = false;
  String _base = '';

  @override
  void initState() {
    super.initState();
    _speech = ref.read(speechInputProvider);
    _pulse = AnimationController(vsync: this, duration: AppMotion.slow * 2);
  }

  Future<void> _toggle() async {
    if (_listening) {
      _setListening(false);
      await _speech.stop();
      return;
    }
    _base = widget.controller.text;
    _setListening(true);
    await _speech.listen(onResult: _onResult, onDone: _onDone);
  }

  void _onResult(String words) {
    if (!mounted) return;
    final text = DictationButton.append(_base, words);
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _onDone(DictationError? error) {
    if (!mounted) return;
    _setListening(false);
    if (error != null) {
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_message(error))));
    }
    widget.onFinished?.call();
  }

  static String _message(DictationError error) => switch (error) {
        DictationError.permission => 'Mikrofon nicht freigegeben',
        DictationError.unavailable =>
          'Spracherkennung nicht verfügbar – Internet oder '
              'Offline-Sprachpaket Deutsch erforderlich',
        DictationError.noMatch => 'Nichts erkannt – bitte noch einmal versuchen',
        DictationError.other => 'Spracherkennung fehlgeschlagen',
      };

  void _setListening(bool listening) {
    setState(() => _listening = listening);
    if (listening && !AppMotion.reduced(context)) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('btn_dictation'),
      tooltip: _listening ? 'Aufnahme beenden' : 'Diktieren',
      onPressed: _toggle,
      icon: _listening
          ? FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0.35).animate(_pulse),
              child: Icon(Icons.mic_rounded, color: context.scheme.error),
            )
          : Icon(Icons.mic_none_rounded, color: context.scheme.onSurfaceVariant),
    );
  }

  @override
  void dispose() {
    if (_listening) _speech.stop();
    _pulse.dispose();
    super.dispose();
  }
}
