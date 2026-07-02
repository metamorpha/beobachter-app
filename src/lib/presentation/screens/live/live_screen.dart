import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/game.dart';
import '../../../domain/enums/event_type.dart';
import '../../../domain/enums/game_phase.dart';
import '../../providers/providers.dart';
import '../../widgets/pitch_canvas.dart';
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
        title: Text(
          '${widget.game.homeTeamName.isEmpty ? 'Heim' : widget.game.homeTeamName}'
          ' – '
          '${widget.game.awayTeamName.isEmpty ? 'Gast' : widget.game.awayTeamName}',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        actions: [
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
    final recent = events.reversed.take(5).toList();

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
          ...recent.map((e) => Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      e.elapsedLabel,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      e.type.label,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.white38, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Löschen',
                    onPressed: () async {
                      await ref
                          .read(eventRepositoryProvider)
                          .deleteEvent(e.id);
                      ref.invalidate(eventsProvider(gameId));
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
