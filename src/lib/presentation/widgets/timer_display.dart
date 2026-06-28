import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/timer_state.dart';
import '../../domain/enums/game_phase.dart';
import '../providers/providers.dart';

class TimerDisplay extends ConsumerWidget {
  final String gameId;

  const TimerDisplay({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerAsync = ref.watch(timerStateProvider(gameId));
    final service = ref.read(timerServiceProvider(gameId));

    return timerAsync.when(
      data: (state) => _buildTimer(state, service),
      loading: () => _buildTimer(TimerState.initial(gameId), service),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildTimer(TimerState state, dynamic service) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              key: const Key('timer_label'),
              state.formattedTime,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
                color: Colors.white,
              ),
            ),
            if (state.phaseLabel.isNotEmpty)
              Text(
                key: const Key('timer_phase_label'),
                state.phaseLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        _PhaseButton(state: state, service: service),
      ],
    );
  }
}

class _PhaseButton extends StatelessWidget {
  final TimerState state;
  final dynamic service;

  const _PhaseButton({required this.state, required this.service});

  @override
  Widget build(BuildContext context) {
    final cfg = _buttonConfig(state.phase);
    if (cfg == null) return const SizedBox.shrink();

    return ElevatedButton.icon(
      key: Key(cfg.key),
      style: ElevatedButton.styleFrom(
        backgroundColor: cfg.color,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      onPressed: () => cfg.action(service),
      icon: Icon(cfg.icon, size: 18),
      label: Text(cfg.label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  _BtnCfg? _buttonConfig(GamePhase phase) {
    switch (phase) {
      case GamePhase.bereit:
        return _BtnCfg(
          key: 'btn_start_game',
          label: 'Start',
          icon: Icons.play_arrow,
          color: Colors.green.shade600,
          action: (s) => s.startGame(),
        );
      case GamePhase.ersteHalbzeit:
      case GamePhase.ersteHalbzeitNachspielzeit:
        return _BtnCfg(
          key: 'btn_halbzeit',
          label: 'Halbzeit',
          icon: Icons.pause,
          color: Colors.orange.shade700,
          action: (s) => s.setHalbzeit(),
        );
      case GamePhase.halbzeit:
        return _BtnCfg(
          key: 'btn_start_zweite_halbzeit',
          label: '2. HZ starten',
          icon: Icons.play_arrow,
          color: Colors.green.shade600,
          action: (s) => s.startZweiteHalbzeit(),
        );
      case GamePhase.zweiteHalbzeit:
      case GamePhase.zweiteHalbzeitNachspielzeit:
        return _BtnCfg(
          key: 'btn_abpfiff',
          label: 'Abpfiff',
          icon: Icons.stop,
          color: Colors.red.shade700,
          action: (s) => s.setAbpfiff(),
        );
      case GamePhase.beendet:
        return _BtnCfg(
          key: 'btn_verlaengerung',
          label: 'Verlängerung',
          icon: Icons.play_arrow,
          color: Colors.green.shade700,
          action: (s) => s.startVerlaengerung(),
        );
      case GamePhase.verlaengerungErsteHalbzeit:
      case GamePhase.verlaengerungErsteHalbzeitNachspielzeit:
        return _BtnCfg(
          key: 'btn_halbzeit_verlaengerung',
          label: 'HZ (Verl.)',
          icon: Icons.pause,
          color: Colors.orange.shade700,
          action: (s) => s.setHalbzeitVerlaengerung(),
        );
      case GamePhase.verlaengerungHalbzeit:
        return _BtnCfg(
          key: 'btn_start_zweite_verlaengerung',
          label: '2. Verl. starten',
          icon: Icons.play_arrow,
          color: Colors.green.shade600,
          action: (s) => s.startZweiteVerlaengerung(),
        );
      case GamePhase.verlaengerungZweiteHalbzeit:
      case GamePhase.verlaengerungZweiteHalbzeitNachspielzeit:
        return _BtnCfg(
          key: 'btn_abpfiff_verlaengerung',
          label: 'Abpfiff (Verl.)',
          icon: Icons.stop,
          color: Colors.red.shade700,
          action: (s) => s.setAbpfiffVerlaengerung(),
        );
      case GamePhase.beendetVerlaengerung:
        return null;
    }
  }
}

class _BtnCfg {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final void Function(dynamic) action;

  const _BtnCfg({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.action,
  });
}
