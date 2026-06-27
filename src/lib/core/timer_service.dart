import 'dart:async';

import '../domain/entities/timer_state.dart';
import '../domain/repositories/timer_repository.dart';

/// Background-safe Spieluhr.
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

  Future<void> start() async {
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

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _controller.add(_state); // State unverändert, currentMs berechnet sich neu
    });
  }

  void dispose() {
    _ticker?.cancel();
    _controller.close();
  }
}
