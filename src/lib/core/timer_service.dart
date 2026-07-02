import 'dart:async';

import '../domain/entities/timer_state.dart';
import '../domain/enums/game_phase.dart';
import '../domain/repositories/timer_repository.dart';

/// Background-safe Spieluhr mit Phasensteuerung.
///
/// Speichert Start-Timestamp in der DB. currentMs berechnet sich
/// immer als elapsedMs + (now - startTimestamp), sodass die Zeit
/// nach App-Neustart oder Hintergrundwechsel korrekt weiterläuft.
class TimerService {
  final TimerRepository _repository;

  TimerState _state;
  Timer? _ticker;
  final _controller = StreamController<TimerState>.broadcast();

  TimerService(this._repository, {required String gameId})
      : _state = TimerState.initial(gameId);

  Stream<TimerState> get stream => _controller.stream;
  TimerState get current => _state;

  Future<void> load() async {
    final saved = await _repository.getTimerState(_state.gameId);
    if (saved != null) {
      _state = saved;
      if (_state.isRunning) _startTicker();
    }
    _controller.add(_state);
  }

  // ── Phasen-Übergänge ──────────────────────────────────────────────────────

  Future<void> startGame() =>
      _advancePhase(GamePhase.ersteHalbzeit, startTimer: true);

  Future<void> setHalbzeit() =>
      _advancePhase(GamePhase.halbzeit, startTimer: false);

  Future<void> startZweiteHalbzeit() =>
      _advancePhase(GamePhase.zweiteHalbzeit, startTimer: true);

  Future<void> setAbpfiff() =>
      _advancePhase(GamePhase.beendet, startTimer: false);

  Future<void> startVerlaengerung() =>
      _advancePhase(GamePhase.verlaengerungErsteHalbzeit, startTimer: true);

  Future<void> setHalbzeitVerlaengerung() =>
      _advancePhase(GamePhase.verlaengerungHalbzeit, startTimer: false);

  Future<void> startZweiteVerlaengerung() =>
      _advancePhase(GamePhase.verlaengerungZweiteHalbzeit, startTimer: true);

  Future<void> setAbpfiffVerlaengerung() =>
      _advancePhase(GamePhase.beendetVerlaengerung, startTimer: false);

  Future<void> spielBeenden() =>
      _advancePhase(GamePhase.abgeschlossen, startTimer: false);

  // ── Interner Start/Stop (für Tests und Load) ──────────────────────────────

  Future<void> start() async {
    if (_state.phase.istAbgeschlossen) return;
    if (_state.isRunning) return;
    _state = _state.start();
    await _repository.saveTimerState(_state);
    _startTicker();
    _controller.add(_state);
  }

  Future<void> stop() async {
    if (!_state.isRunning) return;
    _ticker?.cancel();
    _state = _state.stop();
    await _repository.saveTimerState(_state);
    _controller.add(_state);
  }

  /// Gibt die aktuelle Zeit in ms zurück (für Event-Zeitstempel).
  int get currentMs => _state.currentMs;

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _advancePhase(GamePhase phase, {required bool startTimer}) async {
    // Ein abgeschlossenes Spiel kann nicht erneut gestartet werden (US-212).
    if (_state.phase.istAbgeschlossen) return;
    if (startTimer) {
      _state = _state.withPhase(phase).start();
      _startTicker();
    } else {
      _ticker?.cancel();
      _state = _state.stop().withPhase(phase);
    }
    await _repository.saveTimerState(_state);
    _controller.add(_state);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final ms = _state.currentMs;
    final schwelle = _state.phase.nachspielzeitSchwelle;
    final nsPhase = _state.phase.nachspielzeitPhase;

    if (schwelle != null && nsPhase != null && ms >= schwelle) {
      _state = _state.withPhase(nsPhase);
      _repository.saveTimerState(_state); // fire-and-forget
    }

    _controller.add(_state);
  }

  void dispose() {
    _ticker?.cancel();
    _controller.close();
  }
}
