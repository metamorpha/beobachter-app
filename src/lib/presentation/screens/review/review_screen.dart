import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/enums/assessment.dart';
import '../../../domain/enums/card_type.dart';
import '../../../domain/enums/event_type.dart';
import '../../../domain/enums/ref_decision.dart';
import '../../../domain/enums/team_side.dart';
import '../../providers/providers.dart';
import '../../widgets/heatmap_canvas.dart';
import '../live/event_form_panel.dart';

class ReviewScreen extends ConsumerWidget {
  final Game game;

  const ReviewScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade900,
          foregroundColor: Colors.white,
          title: Text(
            '${game.homeTeamName.isEmpty ? 'Heim' : game.homeTeamName}'
            ' – '
            '${game.awayTeamName.isEmpty ? 'Gast' : game.awayTeamName}',
            style: const TextStyle(fontSize: 15),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Szenen'),
              Tab(text: 'Coaching'),
              Tab(text: 'Statistik'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SceneListTab(gameId: game.id),
            _CoachingTab(gameId: game.id),
            _StatsTab(gameId: game.id),
          ],
        ),
      ),
    );
  }
}

// ── Szenenliste ──────────────────────────────────────────────────────────────

class _SceneListTab extends ConsumerWidget {
  final String gameId;

  const _SceneListTab({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider(gameId));
    final filter = ref.watch(sceneFilterProvider(gameId));

    return Column(
      children: [
        _FilterBar(gameId: gameId),
        Expanded(
          child: eventsAsync.when(
            data: (events) {
              final filtered = filter.apply(events);
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    filter.isActive
                        ? 'Keine Ereignisse für diesen Filter.'
                        : 'Noch keine Ereignisse erfasst.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16),
                itemBuilder: (ctx, i) =>
                    _SceneTile(event: filtered[i], gameId: gameId),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Fehler: $e')),
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final String gameId;

  const _FilterBar({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(sceneFilterProvider(gameId));
    final notifier = ref.read(sceneFilterProvider(gameId).notifier);

    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // EventType-Chips (horizontal scrollbar)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                _FilterChip(
                  label: 'Alle',
                  selected: filter.eventType == null,
                  onTap: () => notifier.state =
                      filter.copyWith(clearEventType: true),
                ),
                const SizedBox(width: 4),
                ...EventType.values.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _FilterChip(
                        label: t.label,
                        selected: filter.eventType == t,
                        onTap: () => notifier.state = filter.eventType == t
                            ? filter.copyWith(clearEventType: true)
                            : filter.copyWith(eventType: t),
                      ),
                    )),
              ],
            ),
          ),
          // Sekundäre Filter
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                _FilterChip(
                  label: 'Korrekt',
                  selected: filter.correct == true,
                  activeColor: Colors.green.shade600,
                  onTap: () => notifier.state = filter.correct == true
                      ? filter.copyWith(clearCorrect: true)
                      : filter.copyWith(correct: true),
                ),
                const SizedBox(width: 4),
                _FilterChip(
                  label: 'Falsch',
                  selected: filter.correct == false,
                  activeColor: Colors.red.shade600,
                  onTap: () => notifier.state = filter.correct == false
                      ? filter.copyWith(clearCorrect: true)
                      : filter.copyWith(correct: false),
                ),
                const SizedBox(width: 4),
                _FilterChip(
                  label: 'Karte',
                  selected: filter.withCard == true,
                  onTap: () => notifier.state = filter.withCard == true
                      ? filter.copyWith(clearWithCard: true)
                      : filter.copyWith(withCard: true),
                ),
                const SizedBox(width: 4),
                _FilterChip(
                  label: '⭐ Coaching',
                  selected: filter.coachingOnly,
                  onTap: () => notifier.state =
                      filter.copyWith(coachingOnly: !filter.coachingOnly),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? Colors.green.shade700;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SceneTile extends ConsumerWidget {
  final Event event;
  final String gameId;

  const _SceneTile({required this.event, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Text(
        "${event.minute}'",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      title: Text(event.type.label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.refDecision != null)
            Text(event.refDecision!.label,
                style: const TextStyle(fontSize: 12)),
          if (event.assessment != null)
            Text(event.assessment!.label,
                style: TextStyle(
                  fontSize: 11,
                  color: event.assessment!.isCorrect
                      ? Colors.green
                      : Colors.red,
                )),
          if (event.sceneNote != null)
            Text(event.sceneNote!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.card != null)
            Container(
              width: 16,
              height: 22,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: event.card == CardType.yellow
                    ? Colors.yellow
                    : event.card == CardType.yellowRed
                        ? Colors.orange
                        : Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: Colors.grey,
            onPressed: () => _openEdit(context, ref),
            tooltip: 'Bearbeiten',
          ),
          IconButton(
            icon: Icon(
              event.coachingFlag ? Icons.star : Icons.star_border,
              color: event.coachingFlag ? Colors.amber : Colors.grey,
            ),
            onPressed: () => _toggleCoaching(ref, event),
            tooltip: 'Coaching',
          ),
        ],
      ),
      onTap: () => _showDetail(context, ref, event),
    );
  }

  Future<void> _toggleCoaching(WidgetRef ref, Event event) async {
    final updated = event.copyWith(coachingFlag: !event.coachingFlag);
    await ref.read(eventRepositoryProvider).updateEvent(updated, []);
    ref.invalidate(eventsProvider(gameId));
  }

  void _openEdit(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: SizedBox(
          width: 480,
          height: 600,
          child: EventFormPanel(
            gameId: gameId,
            locationX: event.locationX,
            locationY: event.locationY,
            initialEvent: event,
            onClose: () => Navigator.of(ctx).pop(),
            onSaved: (updated) {
              ref.invalidate(eventsProvider(gameId));
              Navigator.of(ctx).pop();
            },
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, Event event) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _EventDetailSheet(event: event, gameId: gameId),
    );
  }
}

class _EventDetailSheet extends ConsumerStatefulWidget {
  final Event event;
  final String gameId;

  const _EventDetailSheet({required this.event, required this.gameId});

  @override
  ConsumerState<_EventDetailSheet> createState() => _EventDetailSheetState();
}

class _EventDetailSheetState extends ConsumerState<_EventDetailSheet> {
  late final TextEditingController _coachingCtrl;

  @override
  void initState() {
    super.initState();
    _coachingCtrl =
        TextEditingController(text: widget.event.coachingNote ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${widget.event.minute}' — ${widget.event.type.label}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          if (widget.event.refDecision != null)
            Text('Entscheidung: ${widget.event.refDecision!.label}'),
          if (widget.event.assessment != null)
            Text('Bewertung: ${widget.event.assessment!.label}'),
          if (widget.event.sceneNote != null) ...[
            const SizedBox(height: 8),
            Text('Notiz: ${widget.event.sceneNote}',
                style: const TextStyle(color: Colors.grey)),
          ],
          const SizedBox(height: 16),
          const Text('Coaching-Notiz:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextField(
            controller: _coachingCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Was möchte ich mit dem Schiedsrichter besprechen?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveCoachingNote,
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCoachingNote() async {
    final updated = widget.event.copyWith(
      coachingNote: _coachingCtrl.text.isEmpty ? null : _coachingCtrl.text,
      coachingFlag: true,
    );
    await ref.read(eventRepositoryProvider).updateEvent(updated, []);
    ref.invalidate(eventsProvider(widget.gameId));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _coachingCtrl.dispose();
    super.dispose();
  }
}

// ── Coaching-Ansicht ─────────────────────────────────────────────────────────

class _CoachingTab extends ConsumerWidget {
  final String gameId;

  const _CoachingTab({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider(gameId));

    return eventsAsync.when(
      data: (events) {
        final coaching = events.where((e) => e.coachingFlag).toList();
        if (coaching.isEmpty) {
          return const Center(
              child: Text('Noch keine Szenen für das Coaching markiert.'));
        }
        return ListView.builder(
          itemCount: coaching.length,
          itemBuilder: (ctx, i) {
            final e = coaching[i];
            return ListTile(
              leading: Text("${e.minute}'",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              title: Text(e.type.label),
              subtitle: e.coachingNote != null
                  ? Text(e.coachingNote!,
                      style: const TextStyle(fontSize: 12))
                  : null,
              trailing: e.assessment != null
                  ? Icon(
                      e.assessment!.isCorrect
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: e.assessment!.isCorrect
                          ? Colors.green
                          : Colors.red,
                    )
                  : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
    );
  }
}

// ── Statistik ─────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerWidget {
  final String gameId;

  const _StatsTab({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider(gameId));

    return eventsAsync.when(
      data: (events) => Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Heatmap',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(child: HeatmapCanvas(events: events)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Zeitachse',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _TimelineChart(events: events),
                  const SizedBox(height: 16),
                  const Text('Spieler-Ranking',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(child: _PlayerRanking(gameId: gameId)),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
    );
  }
}

class _TimelineChart extends StatelessWidget {
  final List<Event> events;
  static const _phases = [
    (0, 15), (15, 30), (30, 45), (45, 60), (60, 75), (75, 90)
  ];

  const _TimelineChart({required this.events});

  @override
  Widget build(BuildContext context) {
    final counts = _phases.map((p) {
      return events.where((e) {
        final min = e.elapsedMs ~/ 60000;
        return min >= p.$1 && min < p.$2;
      }).length;
    }).toList();
    final maxCount = counts.fold(1, (a, b) => a > b ? a : b);

    return Column(
      children: List.generate(_phases.length, (i) {
        final label = '${_phases[i].$1}–${_phases[i].$2}\'';
        final frac = counts[i] / maxCount;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                  width: 46,
                  child: Text(label,
                      style: const TextStyle(fontSize: 11))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: frac,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.green.shade700,
                    minHeight: 18,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text('${counts[i]}',
                  style: const TextStyle(fontSize: 11)),
            ],
          ),
        );
      }),
    );
  }
}

class _PlayerRanking extends ConsumerWidget {
  final String gameId;

  const _PlayerRanking({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(playerRankingProvider(gameId));

    return rankingAsync.when(
      data: (ranking) {
        if (ranking.isEmpty) {
          return const Text(
            'Keine Spielernummern erfasst.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          );
        }
        return ListView.builder(
          itemCount: ranking.length,
          itemBuilder: (ctx, i) {
            final entry = ranking[i];
            final isHome = entry.team == TeamSide.home;
            final teamColor = isHome ? Colors.blue : Colors.red;
            final teamLabel = isHome ? 'H' : 'G';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Text('${i + 1}.',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                  const SizedBox(width: 6),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: teamColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.center,
                    child: Text(teamLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  Text('#${entry.number}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${entry.count}×',
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Fehler: $e',
          style: const TextStyle(color: Colors.red, fontSize: 12)),
    );
  }
}
