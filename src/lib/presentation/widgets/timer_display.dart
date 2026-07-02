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
        _PhaseButtons(state: state, service: service),
      ],
    );
  }
}

class _PhaseButtons extends StatelessWidget {
  final TimerState state;
  final dynamic service;

  const _PhaseButtons({required this.state, required this.service});

  @override
  Widget build(BuildContext context) {
    final configs = _buttonConfigs(state.phase);
    if (configs.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final cfg in configs) ...[
          if (cfg != configs.first) const SizedBox(width: 8),
          ElevatedButton.icon(
            key: Key(cfg.key),
            style: ElevatedButton.styleFrom(
              backgroundColor: cfg.color,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            onPressed: () => cfg.action(context, service),
            icon: Icon(cfg.icon, size: 18),
            label: Text(cfg.label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }

  /// Bestätigungsdialog vor dem irreversiblen Spielende (US-212).
  static Future<void> _confirmSpielBeenden(
      BuildContext context, dynamic service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Spiel endgültig beenden?'),
        content: const Text(
          'Das Spiel kann danach nicht erneut gestartet werden. '
          'Szenen, Notizen und Statistik bleiben weiterhin verfügbar.',
        ),
        actions: [
          TextButton(
            key: const Key('dialog_btn_beenden_cancel'),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            key: const Key('dialog_btn_beenden_confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Beenden'),
          ),
        ],
      ),
    );
    if (confirmed == true) await service.spielBeenden();
  }

  static final _spielBeendenCfg = _BtnCfg(
    key: 'btn_spiel_beenden',
    label: 'Spiel beenden',
    icon: Icons.sports_score,
    color: Colors.blueGrey.shade700,
    action: _confirmSpielBeenden,
  );

  List<_BtnCfg> _buttonConfigs(GamePhase phase) {
    switch (phase) {
      case GamePhase.bereit:
        return [
          _BtnCfg(
            key: 'btn_start_game',
            label: 'Start',
            icon: Icons.play_arrow,
            color: Colors.green.shade600,
            action: (_, s) => s.startGame(),
          ),
        ];
      case GamePhase.ersteHalbzeit:
      case GamePhase.ersteHalbzeitNachspielzeit:
        return [
          _BtnCfg(
            key: 'btn_halbzeit',
            label: 'Halbzeit',
            icon: Icons.pause,
            color: Colors.orange.shade700,
            action: (_, s) => s.setHalbzeit(),
          ),
        ];
      case GamePhase.halbzeit:
        return [
          _BtnCfg(
            key: 'btn_start_zweite_halbzeit',
            label: '2. HZ starten',
            icon: Icons.play_arrow,
            color: Colors.green.shade600,
            action: (_, s) => s.startZweiteHalbzeit(),
          ),
        ];
      case GamePhase.zweiteHalbzeit:
      case GamePhase.zweiteHalbzeitNachspielzeit:
        return [
          _BtnCfg(
            key: 'btn_abpfiff',
            label: 'Abpfiff',
            icon: Icons.stop,
            color: Colors.red.shade700,
            action: (_, s) => s.setAbpfiff(),
          ),
        ];
      case GamePhase.beendet:
        return [
          _BtnCfg(
            key: 'btn_verlaengerung',
            label: 'Verlängerung',
            icon: Icons.play_arrow,
            color: Colors.green.shade700,
            action: (_, s) => s.startVerlaengerung(),
          ),
          _spielBeendenCfg,
        ];
      case GamePhase.verlaengerungErsteHalbzeit:
      case GamePhase.verlaengerungErsteHalbzeitNachspielzeit:
        return [
          _BtnCfg(
            key: 'btn_halbzeit_verlaengerung',
            label: 'HZ (Verl.)',
            icon: Icons.pause,
            color: Colors.orange.shade700,
            action: (_, s) => s.setHalbzeitVerlaengerung(),
          ),
        ];
      case GamePhase.verlaengerungHalbzeit:
        return [
          _BtnCfg(
            key: 'btn_start_zweite_verlaengerung',
            label: '2. Verl. starten',
            icon: Icons.play_arrow,
            color: Colors.green.shade600,
            action: (_, s) => s.startZweiteVerlaengerung(),
          ),
        ];
      case GamePhase.verlaengerungZweiteHalbzeit:
      case GamePhase.verlaengerungZweiteHalbzeitNachspielzeit:
        return [
          _BtnCfg(
            key: 'btn_abpfiff_verlaengerung',
            label: 'Abpfiff (Verl.)',
            icon: Icons.stop,
            color: Colors.red.shade700,
            action: (_, s) => s.setAbpfiffVerlaengerung(),
          ),
        ];
      case GamePhase.beendetVerlaengerung:
        return [_spielBeendenCfg];
      case GamePhase.abgeschlossen:
        return [];
    }
  }
}

class _BtnCfg {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final Future<void> Function(BuildContext, dynamic) action;

  const _BtnCfg({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.action,
  });
}
