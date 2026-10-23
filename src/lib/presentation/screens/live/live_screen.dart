import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/entities/goal.dart';
import '../../../domain/entities/score.dart';
import '../../../domain/enums/event_type.dart';
import '../../../domain/enums/game_phase.dart';
import '../../../domain/enums/goal_kind.dart';
import '../../../domain/enums/team_side.dart';
import '../../providers/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/event_type_style.dart';
import '../../widgets/pitch_canvas.dart';
import '../../widgets/squad_edit_dialog.dart';
import '../../widgets/timer_display.dart';
import '../review/review_screen.dart';
import 'event_form_panel.dart';
import 'goal_dialog.dart';

class LiveScreen extends ConsumerStatefulWidget {
  final Game game;

  const LiveScreen({super.key, required this.game});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  double? _tapX;
  double? _tapY;
  bool _formVisible = false;

  /// Zählt Speichervorgänge; jeder neue Wert startet die Bestätigung (US-603).
  int _savedCount = 0;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider(widget.game.id));
    final events = eventsAsync.valueOrNull ?? [];
    final abgeschlossen =
        ref
            .watch(timerStateProvider(widget.game.id))
            .valueOrNull
            ?.phase
            .istAbgeschlossen ??
        false;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = _formVisible
        ? screenWidth * 0.40
        : (screenWidth * 0.26).clamp(240.0, 340.0);
    final duration = AppMotion.of(context, AppMotion.medium);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
        titleSpacing: AppSpacing.s,
        title: _Scoreboard(game: widget.game),
      ),
      body: Row(
        children: [
          // ── Spielfeld + Aktionsleiste (linker Daumen) ───────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.s,
                AppSpacing.m,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PitchCanvas(
                          events: events,
                          dimmed: _formVisible,
                          onTap: (x, y) {
                            // Abgeschlossenes Spiel: keine neue Erfassung (US-212)
                            if (_formVisible || abgeschlossen) return;
                            setState(() {
                              _tapX = x;
                              _tapY = y;
                              _formVisible = true;
                            });
                          },
                        ),
                        if (_savedCount > 0 && !AppMotion.reduced(context))
                          Positioned(
                            top: AppSpacing.l,
                            left: 0,
                            right: 0,
                            child: _SavedToast(key: ValueKey(_savedCount)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _ActionBar(game: widget.game),
                ],
              ),
            ),
          ),

          // ── Seitenpanel (rechter Daumen) ─────────────────────────────────
          AnimatedContainer(
            duration: duration,
            curve: AppMotion.curve,
            width: panelWidth,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s,
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.m,
            ),
            child: Card(
              elevation: _formVisible ? 3 : 0,
              shadowColor: Colors.black26,
              child: AnimatedSwitcher(
                duration: duration,
                switchInCurve: AppMotion.curve,
                switchOutCurve: AppMotion.curve.flipped,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.12, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _formVisible
                    ? EventFormPanel(
                        key: const ValueKey('form'),
                        gameId: widget.game.id,
                        locationX: _tapX!,
                        locationY: _tapY!,
                        onClose: () => setState(() => _formVisible = false),
                        onSaved: (event) {
                          setState(() {
                            _formVisible = false;
                            _savedCount++;
                          });
                          ref.invalidate(eventsProvider(widget.game.id));
                        },
                      )
                    : _RecentEvents(
                        key: const ValueKey('recent'),
                        game: widget.game,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kurze Bestätigung nach dem Speichern: blendet ein, steht kurz, blendet aus.
class _SavedToast extends StatelessWidget {
  const _SavedToast({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1400),
        builder: (context, t, child) {
          // 0–15 %: einblenden, bis 75 %: stehen, danach ausblenden
          final opacity = t < 0.15
              ? t / 0.15
              : t < 0.75
              ? 1.0
              : (1 - t) / 0.25;
          final dy = t < 0.15 ? (1 - t / 0.15) * -8 : 0.0;
          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.translate(offset: Offset(0, dy), child: child),
          );
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.s + 2,
            ),
            decoration: BoxDecoration(
              color: context.scheme.inverseSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 12),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: context.colors.correct,
                ),
                const SizedBox(width: AppSpacing.s),
                Text(
                  'Ereignis gespeichert',
                  style: context.text.labelLarge?.copyWith(
                    color: context.scheme.onInverseSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kopfleiste: Tor-Buttons, Teams, Spielstand, Phase und Uhr (US-602, US-215).
class _Scoreboard extends ConsumerWidget {
  final Game game;

  const _Scoreboard({required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = game.homeTeamName.isEmpty ? 'Heim' : game.homeTeamName;
    final away = game.awayTeamName.isEmpty ? 'Gast' : game.awayTeamName;
    final abgeschlossen =
        ref
            .watch(timerStateProvider(game.id))
            .valueOrNull
            ?.phase
            .istAbgeschlossen ??
        false;

    return Row(
      key: const Key('live_scoreboard'),
      children: [
        _GoalButton(
          game: game,
          team: TeamSide.home,
          enabled: !abgeschlossen,
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TeamDot(color: context.colors.home),
                  const SizedBox(width: AppSpacing.s),
                  Flexible(
                    child: Text(
                      '$home – $away',
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  _TeamDot(color: context.colors.away),
                ],
              ),
              const SizedBox(height: 2),
              _ScoreDisplay(score: ref.watch(scoreProvider(game.id))),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        _GoalButton(
          game: game,
          team: TeamSide.away,
          enabled: !abgeschlossen,
        ),
        const SizedBox(width: AppSpacing.l),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.s),
          child: TimerClock(gameId: game.id),
        ),
      ],
    );
  }
}

/// „+ Tor" in Teamfarbe — friert Spielzeit und Phase beim Tap ein (US-215).
class _GoalButton extends ConsumerWidget {
  final Game game;
  final TeamSide team;
  final bool enabled;

  const _GoalButton({
    required this.game,
    required this.team,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = context.colors.team(team);
    final name = team == TeamSide.home ? game.homeTeamName : game.awayTeamName;
    return Tooltip(
      message: 'Tor ${team.label}',
      child: FilledButton.icon(
        key: Key('btn_goal_${team.name}'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSizes.liveTap),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          backgroundColor: color,
          foregroundColor: AppColors.onColor(color),
        ),
        onPressed: enabled
            ? () {
                final timer = ref.read(timerServiceProvider(game.id));
                GoalDialog.show(
                  context,
                  gameId: game.id,
                  team: team,
                  elapsedMs: timer.currentMs,
                  gamePhase: timer.current.phase,
                  teamName: name,
                );
              }
            : null,
        icon: const Icon(Icons.sports_soccer, size: 22),
        label: const Text('+ Tor'),
      ),
    );
  }
}

class _TeamDot extends StatelessWidget {
  final Color color;

  const _TeamDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Aktionsleiste unten links: Phasen-Button, Aufstellung, Szenen (US-602).
class _ActionBar extends StatelessWidget {
  final Game game;

  const _ActionBar({required this.game});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Auf schmalen Flächen (Formular offen, kleine Tablets) nur Icons
        final compact = constraints.maxWidth < 620;
        return Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PhaseActions(gameId: game.id),
              _NavButton(
                key: const Key('btn_aufstellung'),
                icon: Icons.groups_rounded,
                label: 'Aufstellung',
                compact: compact,
                onPressed: () => SquadEditDialog.show(context, game.id),
              ),
              _NavButton(
                key: const Key('btn_szenen'),
                icon: Icons.view_list_rounded,
                label: 'Szenen',
                compact: compact,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReviewScreen(game: game)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;
  final VoidCallback onPressed;

  const _NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.compact,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size(AppSizes.liveTap + 8, AppSizes.primaryAction),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.m : AppSpacing.l + 4,
      ),
      backgroundColor: context.scheme.surface,
      foregroundColor: context.scheme.onSurface,
      side: BorderSide(color: context.scheme.outlineVariant),
    );
    return Tooltip(
      message: label,
      child: compact
          ? FilledButton(
              style: style,
              onPressed: onPressed,
              child: Icon(icon, size: 26),
            )
          : FilledButton.icon(
              style: style,
              onPressed: onPressed,
              icon: Icon(icon, size: 24),
              label: Text(label),
            ),
    );
  }
}

/// Eintrag in „Letzte Ereignisse": Ereignis oder Tor (US-215).
typedef _Entry = ({Event? event, Goal? goal});

class _RecentEvents extends ConsumerWidget {
  final Game game;

  const _RecentEvents({super.key, required this.game});

  static GamePhase _phase(_Entry e) => e.event?.gamePhase ?? e.goal!.gamePhase;
  static int _ms(_Entry e) => e.event?.elapsedMs ?? e.goal!.elapsedMs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameId = game.id;
    final events = ref.watch(eventsProvider(gameId)).valueOrNull ?? [];
    final goals = ref.watch(goalsProvider(gameId)).valueOrNull ?? [];
    final goalScores = Score.runningByGoalId(goals);

    // Ereignisse und Tore chronologisch (Phase, dann Zeit), neuestes zuerst;
    // Liste füllt die Panelhöhe und scrollt (US-213)
    final recent = <_Entry>[
      for (final e in events) (event: e, goal: null),
      for (final g in goals) (event: null, goal: g),
    ]..sort((a, b) {
        final byPhase = _phase(b).index.compareTo(_phase(a).index);
        return byPhase != 0 ? byPhase : _ms(b).compareTo(_ms(a));
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 20,
                color: context.scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.s),
              Flexible(
                child: Text(
                  'Letzte Ereignisse',
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: recent.isEmpty
              ? _EmptyEvents(
                  child: ListView(
                    key: const Key('recent_events_list'),
                    children: const [],
                  ),
                )
              : ListView.separated(
                  key: const Key('recent_events_list'),
                  padding: EdgeInsets.zero,
                  itemCount: recent.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: AppSpacing.l),
                  itemBuilder: (_, i) {
                    final entry = recent[i];
                    final e = entry.event;
                    if (e != null) {
                      return _RecentRow(
                        key: Key('recent_event_${e.id}'),
                        time: e.elapsedLabel,
                        dotColor: e.type.color,
                        label: e.type.label,
                        onDelete: () async {
                          await ref
                              .read(eventRepositoryProvider)
                              .deleteEvent(e.id);
                          ref.invalidate(eventsProvider(gameId));
                        },
                      );
                    }
                    final g = entry.goal!;
                    final name = g.team == TeamSide.home
                        ? game.homeTeamName
                        : game.awayTeamName;
                    return _RecentRow(
                      key: Key('recent_goal_${g.id}'),
                      time: g.elapsedLabel,
                      dotColor: context.colors.team(g.team),
                      label: _goalLabel(g, goalScores[g.id]),
                      bold: true,
                      onTap: () => GoalDialog.edit(context, g, teamName: name),
                      onDelete: () async {
                        await ref.read(goalRepositoryProvider).deleteGoal(g.id);
                        ref.invalidate(goalsProvider(gameId));
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// z. B. „⚽ 2:1 · #9 · 11m" — Spielstand nach diesem Tor.
  static String _goalLabel(Goal g, Score? after) => [
    '⚽ ${after?.shortLabel ?? 'Tor'}',
    if (g.scorerNumber != null) '#${g.scorerNumber}',
    ?g.kind.shortLabel,
  ].join(' · ');
}

/// Zeile in „Letzte Ereignisse" — Mindesthöhe 56 dp gegen Fehltipps
/// (US-213, US-602).
class _RecentRow extends StatelessWidget {
  final String time;
  final Color dotColor;
  final String label;
  final bool bold;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _RecentRow({
    super.key,
    required this.time,
    required this.dotColor,
    required this.label,
    required this.onDelete,
    this.bold = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.liveTap),
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.l),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  time,
                  style: TextStyle(
                    color: context.scheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: AppSpacing.s + 2),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.scheme.onSurface,
                    fontSize: 14,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: context.scheme.onSurfaceVariant,
                  size: 22,
                ),
                constraints: const BoxConstraints(
                  minWidth: AppSizes.tap,
                  minHeight: AppSizes.tap,
                ),
                tooltip: 'Löschen',
                onPressed: onDelete,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  final Widget child;

  const _EmptyEvents({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Aufs Spielfeld tippen,\num ein Ereignis zu erfassen.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Spielstand unter den Mannschaftsnamen; leuchtet bei Änderung kurz auf (US-214, US-215).
class _ScoreDisplay extends StatefulWidget {
  final Score score;

  const _ScoreDisplay({required this.score});

  @override
  State<_ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<_ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _highlight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: 1,
  );

  @override
  void didUpdateWidget(_ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) _highlight.forward(from: 0);
  }

  @override
  void dispose() {
    _highlight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = context.colors.yellowCard;
    return AnimatedBuilder(
      animation: _highlight,
      builder: (_, _) {
        final t = Curves.easeOut.transform(_highlight.value);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          decoration: BoxDecoration(
            color: glow.withValues(alpha: 0.6 * (1 - t)),
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          child: Text(
            widget.score.label,
            key: const Key('live_score'),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: context.scheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }
}
