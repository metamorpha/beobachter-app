import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/timer_state.dart';
import '../../domain/enums/game_phase.dart';
import '../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Uhr und Phasen-Buttons nebeneinander. Der Live-Screen nutzt die beiden
/// Teile getrennt: [TimerClock] in der Kopfleiste, [PhaseActions] unten links
/// in der Aktionsleiste (US-602).
class TimerDisplay extends StatelessWidget {
  final String gameId;

  const TimerDisplay({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.m,
      runSpacing: AppSpacing.s,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TimerClock(gameId: gameId),
        PhaseActions(gameId: gameId),
      ],
    );
  }
}

TimerState _stateOf(WidgetRef ref, String gameId) =>
    ref.watch(timerStateProvider(gameId)).valueOrNull ??
    TimerState.initial(gameId);

/// Reine Anzeige: Spielzeit und Phase; ein pulsierender Punkt zeigt die
/// laufende Uhr (US-602).
class TimerClock extends ConsumerWidget {
  final String gameId;

  /// Kleinere Uhr für die Smartphone-Kopfzeile (US-701).
  final bool compact;

  const TimerClock({super.key, required this.gameId, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(timerStateProvider(gameId)).hasError) {
      return const SizedBox.shrink();
    }
    final state = _stateOf(ref, gameId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.phaseLabel.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m, vertical: AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: state.isRunning
                  ? context.scheme.primaryContainer
                  : context.scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isRunning) ...[
                  _RunningDot(
                      key: const Key('timer_running_dot'),
                      second: state.currentMs ~/ 1000),
                  const SizedBox(width: AppSpacing.s),
                ],
                Text(
                  key: const Key('timer_phase_label'),
                  state.phaseLabel,
                  style: context.text.labelMedium?.copyWith(
                    color: state.isRunning
                        ? context.scheme.onPrimaryContainer
                        : context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(width: compact ? AppSpacing.s : AppSpacing.m),
        Text(
          key: const Key('timer_label'),
          state.formattedTime,
          style: TextStyle(
            fontSize: compact ? 24 : 34,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.5,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: context.scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Pulsiert im Sekundentakt der Uhr: jeder Tick blendet weich zwischen
/// zwei Helligkeiten (keine Endlos-Animation).
class _RunningDot extends StatelessWidget {
  final int second;

  const _RunningDot({super.key, required this.second});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: second.isEven ? 1.0 : 0.35,
      duration: AppMotion.of(context, const Duration(milliseconds: 700)),
      curve: Curves.easeInOut,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: context.colors.phaseStart, shape: BoxShape.circle),
      ),
    );
  }
}

/// Phasen-Buttons (Start, Halbzeit, Abpfiff, Verlängerung, Spiel beenden …).
/// Mindestens 160 × 64 dp, Farbe nach Art der Aktion (US-602).
class PhaseActions extends ConsumerWidget {
  final String gameId;

  /// Smartphone: feste Breite für die linke Leiste, Höhe 56 dp; mehrere
  /// Buttons stehen untereinander (US-701).
  final bool compact;

  const PhaseActions({super.key, required this.gameId, this.compact = false});

  /// Breite eines Phasen-Buttons in der kompakten Variante.
  static const compactWidth = 160.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(timerStateProvider(gameId)).hasError) {
      return const SizedBox.shrink();
    }
    final state = _stateOf(ref, gameId);
    final service = ref.read(timerServiceProvider(gameId));
    final configs = _buttonConfigs(state.phase, context.colors);

    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.medium),
      switchInCurve: AppMotion.curve,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(anim), child: child),
      ),
      child: configs.isEmpty
          ? const SizedBox.shrink(key: ValueKey('none'))
          : Wrap(
              key: ValueKey(state.phase),
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final cfg in configs)
                  FilledButton.icon(
                    key: Key(cfg.key),
                    style: compact
                        ? FilledButton.styleFrom(
                            backgroundColor: cfg.color,
                            foregroundColor: Colors.white,
                            minimumSize:
                                const Size(compactWidth, AppSizes.liveTap),
                            fixedSize: const Size.fromWidth(compactWidth),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.m),
                            textStyle: context.text.labelLarge?.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          )
                        : FilledButton.styleFrom(
                            backgroundColor: cfg.color,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(AppSizes.phaseButtonWidth,
                                AppSizes.primaryAction),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.l + 4),
                            textStyle: context.text.labelLarge?.copyWith(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                    onPressed: () => cfg.action(context, service),
                    icon: Icon(cfg.icon, size: 24),
                    label: Text(cfg.label),
                  ),
              ],
            ),
    );
  }

  /// Bestätigungsdialog vor dem irreversiblen Spielende (US-212).
  static Future<void> _confirmSpielBeenden(
      BuildContext context, dynamic service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.sports_score, color: ctx.colors.phaseFinish),
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
          FilledButton(
            key: const Key('dialog_btn_beenden_confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: ctx.scheme.error,
                foregroundColor: ctx.scheme.onError),
            child: const Text('Beenden'),
          ),
        ],
      ),
    );
    if (confirmed == true) await service.spielBeenden();
  }

  List<_BtnCfg> _buttonConfigs(GamePhase phase, AppColors c) {
    final spielBeenden = _BtnCfg(
      key: 'btn_spiel_beenden',
      label: 'Spiel beenden',
      icon: Icons.sports_score,
      color: c.phaseFinish,
      action: _confirmSpielBeenden,
    );

    switch (phase) {
      case GamePhase.bereit:
        return [
          _BtnCfg(
            key: 'btn_start_game',
            label: 'Start',
            icon: Icons.play_arrow_rounded,
            color: c.phaseStart,
            action: (_, s) => s.startGame(),
          ),
        ];
      case GamePhase.ersteHalbzeit:
      case GamePhase.ersteHalbzeitNachspielzeit:
        return [
          _BtnCfg(
            key: 'btn_halbzeit',
            label: 'Halbzeit',
            icon: Icons.pause_rounded,
            color: c.phasePause,
            action: (_, s) => s.setHalbzeit(),
          ),
        ];
      case GamePhase.halbzeit:
        return [
          _BtnCfg(
            key: 'btn_start_zweite_halbzeit',
            label: '2. HZ starten',
            icon: Icons.play_arrow_rounded,
            color: c.phaseStart,
            action: (_, s) => s.startZweiteHalbzeit(),
          ),
        ];
      case GamePhase.zweiteHalbzeit:
      case GamePhase.zweiteHalbzeitNachspielzeit:
        return [
          _BtnCfg(
            key: 'btn_abpfiff',
            label: 'Abpfiff',
            icon: Icons.stop_rounded,
            color: c.phaseStop,
            action: (_, s) => s.setAbpfiff(),
          ),
        ];
      case GamePhase.beendet:
        return [
          _BtnCfg(
            key: 'btn_verlaengerung',
            label: 'Verlängerung',
            icon: Icons.play_arrow_rounded,
            color: c.phaseStart,
            action: (_, s) => s.startVerlaengerung(),
          ),
          spielBeenden,
        ];
      case GamePhase.verlaengerungErsteHalbzeit:
      case GamePhase.verlaengerungErsteHalbzeitNachspielzeit:
        return [
          _BtnCfg(
            key: 'btn_halbzeit_verlaengerung',
            label: 'HZ (Verl.)',
            icon: Icons.pause_rounded,
            color: c.phasePause,
            action: (_, s) => s.setHalbzeitVerlaengerung(),
          ),
        ];
      case GamePhase.verlaengerungHalbzeit:
        return [
          _BtnCfg(
            key: 'btn_start_zweite_verlaengerung',
            label: '2. Verl. starten',
            icon: Icons.play_arrow_rounded,
            color: c.phaseStart,
            action: (_, s) => s.startZweiteVerlaengerung(),
          ),
        ];
      case GamePhase.verlaengerungZweiteHalbzeit:
      case GamePhase.verlaengerungZweiteHalbzeitNachspielzeit:
        return [
          _BtnCfg(
            key: 'btn_abpfiff_verlaengerung',
            label: 'Abpfiff (Verl.)',
            icon: Icons.stop_rounded,
            color: c.phaseStop,
            action: (_, s) => s.setAbpfiffVerlaengerung(),
          ),
        ];
      case GamePhase.beendetVerlaengerung:
        return [spielBeenden];
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
