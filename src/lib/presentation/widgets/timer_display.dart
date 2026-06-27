import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/timer_state.dart';
import '../providers/providers.dart';

class TimerDisplay extends ConsumerWidget {
  final String gameId;

  const TimerDisplay({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerAsync = ref.watch(timerStateProvider(gameId));
    final service = ref.read(timerServiceProvider(gameId));

    return timerAsync.when(
      data: (state) => _buildTimer(context, state, service),
      loading: () => _buildTimer(context, TimerState.initial(gameId), service),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTimer(
      BuildContext context, TimerState state, dynamic service) {
    final ms = state.currentMs;
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    final label =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                state.isRunning ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 48),
          ),
          onPressed: state.isRunning ? service.stop : service.start,
          icon: Icon(state.isRunning ? Icons.stop : Icons.play_arrow),
          label: Text(state.isRunning ? 'STOP' : 'START'),
        ),
      ],
    );
  }
}
