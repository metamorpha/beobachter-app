import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/game.dart';
import '../../../domain/entities/score.dart';
import '../../../domain/enums/event_type.dart';
import '../../../domain/enums/game_phase.dart';
import '../../providers/providers.dart';
import '../../widgets/pitch_canvas.dart';
import '../../widgets/squad_edit_dialog.dart';
import '../../widgets/timer_display.dart';
import '../review/review_screen.dart';
import 'event_form_panel.dart';

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

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider(widget.game.id));
    final events = eventsAsync.valueOrNull ?? [];
    final abgeschlossen = ref
            .watch(timerStateProvider(widget.game.id))
            .valueOrNull
            ?.phase
            .istAbgeschlossen ??
        false;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        toolbarHeight: 76,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.game.homeTeamName.isEmpty ? 'Heim' : widget.game.homeTeamName}'
              ' – '
              '${widget.game.awayTeamName.isEmpty ? 'Gast' : widget.game.awayTeamName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            _ScoreDisplay(score: ref.watch(scoreProvider(widget.game.id))),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('btn_aufstellung'),
            icon: const Icon(Icons.groups),
            tooltip: 'Aufstellung',
            onPressed: () => SquadEditDialog.show(context, widget.game.id),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Szenen',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ReviewScreen(game: widget.game)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TimerDisplay(gameId: widget.game.id),
          ),
        ),
      ),
      body: Row(
        children: [
          // ── Spielfeld (60%) ──────────────────────────────────────────────
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: PitchCanvas(
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
            ),
          ),

          // ── Seitenpanel (40%) ────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _formVisible
                ? MediaQuery.of(context).size.width * 0.40
                : 200,
            child: _formVisible
                ? EventFormPanel(
                    gameId: widget.game.id,
                    locationX: _tapX!,
                    locationY: _tapY!,
                    onClose: () => setState(() => _formVisible = false),
                    onSaved: (event) {
                      setState(() => _formVisible = false);
                      ref.invalidate(eventsProvider(widget.game.id));
                    },
                  )
                : _RecentEvents(gameId: widget.game.id),
          ),
        ],
      ),
    );
  }
}

class _RecentEvents extends ConsumerWidget {
  final String gameId;

  const _RecentEvents({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider(gameId)).valueOrNull ?? [];
    // Neuestes zuerst; Liste füllt die Panelhöhe und scrollt (US-213)
    final recent = events.reversed.toList();
    final goalScores = Score.runningByEventId(events);

    return Container(
      color: const Color(0xFF212121),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Letzte Ereignisse',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: ListView.separated(
              key: const Key('recent_events_list'),
              padding: EdgeInsets.zero,
              itemCount: recent.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Colors.white10),
              itemBuilder: (_, i) {
                final e = recent[i];
                final goalScore = goalScores[e.id];
                return ConstrainedBox(
                  key: Key('recent_event_${e.id}'),
                  // Mindesthöhe 44 dp gegen Fehltipps (US-213)
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(
                          e.elapsedLabel,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          // Gezähltes Tor mit Spielstand danach (US-214)
                          goalScore != null
                              ? '⚽ Tor ${goalScore.shortLabel}'
                              : e.type.label,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.white38, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 44, minHeight: 44),
                        tooltip: 'Löschen',
                        onPressed: () async {
                          await ref
                              .read(eventRepositoryProvider)
                              .deleteEvent(e.id);
                          ref.invalidate(eventsProvider(gameId));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Spielstand unter den Mannschaftsnamen; leuchtet bei Änderung kurz auf (US-214).
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
    return AnimatedBuilder(
      animation: _highlight,
      builder: (_, _) {
        final t = Curves.easeOut.transform(_highlight.value);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.5 * (1 - t)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.score.label,
            key: const Key('live_score'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.1,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }
}
