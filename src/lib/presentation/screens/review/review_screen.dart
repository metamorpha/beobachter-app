import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/entities/score.dart';
import '../../../domain/entities/team_fouls.dart';
import '../../../domain/enums/assessment.dart';
import '../../../domain/enums/event_type.dart';
import '../../../domain/enums/goal_kind.dart';
import '../../../domain/enums/ref_decision.dart';
import '../../../domain/enums/team_side.dart';
import '../../platform/preferred_orientation.dart';
import '../../providers/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/event_type_style.dart';
import '../../theme/form_factor.dart';
import '../../widgets/phone_dialog.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/heatmap_canvas.dart';
import '../game_setup/game_setup_screen.dart';
import '../live/event_form_panel.dart';

class ReviewScreen extends ConsumerWidget {
  final Game game;

  const ReviewScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PreferredOrientation(
      landscape: false,
      child: _buildTabs(context),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${game.homeTeamName.isEmpty ? 'Heim' : game.homeTeamName}'
            ' – '
            '${game.awayTeamName.isEmpty ? 'Gast' : game.awayTeamName}',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Spiel einrichten',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GameSetupScreen(game: game)),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                0,
                AppSpacing.l,
                AppSpacing.m,
              ),
              child: Container(
                height: 52,
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: context.scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.m + 2),
                ),
                child: TabBar(
                  // Smartphone: drei Tabs passen nebeneinander (US-704)
                  labelPadding: FormFactor.isPhone(context)
                      ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs)
                      : null,
                  tabs: const [
                    _TabLabel(icon: Icons.view_list_rounded, text: 'Szenen'),
                    _TabLabel(icon: Icons.forum_outlined, text: 'Coaching'),
                    _TabLabel(icon: Icons.insights_rounded, text: 'Statistik'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _SceneListTab(gameId: game.id),
            _CoachingTab(game: game),
            _StatsTab(gameId: game.id),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TabLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Tab(
    height: 44,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.s),
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
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
                return _EmptyMessage(
                  icon: filter.isActive
                      ? Icons.filter_alt_off_outlined
                      : Icons.sports_soccer,
                  text: filter.isActive
                      ? 'Keine Ereignisse für diesen Filter.'
                      : 'Noch keine Ereignisse erfasst.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                itemCount: filtered.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.s),
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

class _EmptyMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: context.scheme.outline),
          const SizedBox(height: AppSpacing.m),
          Text(
            text,
            style: context.text.bodyLarge?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
    final events = ref.watch(eventsProvider(gameId)).valueOrNull ?? const [];
    int countOf(EventType t) => events.where((e) => e.type == t).length;

    return Container(
      decoration: BoxDecoration(
        color: context.scheme.surface,
        border: Border(
          bottom: BorderSide(color: context.scheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // EventType-Chips (horizontal scrollbar)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              children: [
                _FilterChip(
                  label: 'Alle',
                  selected: filter.eventType == null,
                  onTap: () =>
                      notifier.state = filter.copyWith(clearEventType: true),
                ),
                const SizedBox(width: AppSpacing.s),
                ...EventType.values.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: _FilterChip(
                      label: t.label,
                      icon: t.icon,
                      count: countOf(t),
                      selected: filter.eventType == t,
                      onTap: () => notifier.state = filter.eventType == t
                          ? filter.copyWith(clearEventType: true)
                          : filter.copyWith(eventType: t),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Sekundäre Filter
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              children: [
                _FilterChip(
                  label: 'Korrekt',
                  icon: Icons.check,
                  selected: filter.correct == true,
                  activeColor: context.colors.correct,
                  onTap: () => notifier.state = filter.correct == true
                      ? filter.copyWith(clearCorrect: true)
                      : filter.copyWith(correct: true),
                ),
                const SizedBox(width: AppSpacing.s),
                _FilterChip(
                  label: 'Falsch',
                  icon: Icons.close,
                  selected: filter.correct == false,
                  activeColor: context.colors.wrong,
                  onTap: () => notifier.state = filter.correct == false
                      ? filter.copyWith(clearCorrect: true)
                      : filter.copyWith(correct: false),
                ),
                const SizedBox(width: AppSpacing.s),
                _FilterChip(
                  label: 'Karte',
                  icon: Icons.style_outlined,
                  selected: filter.withCard == true,
                  onTap: () => notifier.state = filter.withCard == true
                      ? filter.copyWith(clearWithCard: true)
                      : filter.copyWith(withCard: true),
                ),
                const SizedBox(width: AppSpacing.s),
                _FilterChip(
                  label: '⭐ Coaching',
                  selected: filter.coachingOnly,
                  onTap: () => notifier.state = filter.copyWith(
                    coachingOnly: !filter.coachingOnly,
                  ),
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
  final IconData? icon;
  final int? count;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor,
    this.icon,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? context.scheme.primary;
    final fg = selected ? AppColors.onColor(color) : context.scheme.onSurface;
    return Center(
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.fast),
        height: 40,
        decoration: BoxDecoration(
          color: selected ? color : context.scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: selected ? color : context.scheme.outlineVariant,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m + 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: selected ? fg : color),
                    const SizedBox(width: AppSpacing.xs + 2),
                  ],
                  Text(
                    label,
                    style: context.text.labelLarge?.copyWith(
                      fontSize: 14,
                      color: fg,
                    ),
                  ),
                  if (count != null && count! > 0) ...[
                    const SizedBox(width: AppSpacing.xs + 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? fg.withValues(alpha: 0.2)
                            : context.scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      child: Text(
                        '$count',
                        style: context.text.labelMedium?.copyWith(color: fg),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kleines Minuten-Badge links in Szenen- und Coaching-Karten.
class _MinuteBadge extends StatelessWidget {
  final Event event;

  const _MinuteBadge({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      alignment: Alignment.center,
      child: Text(
        "${event.minute}'",
        style: context.text.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Bewertung als farbige Pille mit ✓/✗.
class _AssessmentPill extends StatelessWidget {
  final Assessment assessment;

  const _AssessmentPill({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final color = assessment.isCorrect
        ? context.colors.correct
        : context.colors.wrong;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: 0.12),
          context.scheme.surface,
        ),
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            assessment.isCorrect ? Icons.check : Icons.close,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              assessment.label,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(color: color),
            ),
          ),
        ],
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
    return Card(
      child: InkWell(
        onTap: () => _showDetail(context, ref, event),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.s,
            AppSpacing.m,
          ),
          child: Row(
            children: [
              _MinuteBadge(event: event),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: AppSpacing.s),
                          decoration: BoxDecoration(
                            color: event.type.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            event.type.label,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleMedium,
                          ),
                        ),
                        // Smartphone: Entscheidung in eigener Zeile (US-704)
                        if (event.refDecision != null &&
                            !FormFactor.isPhone(context)) ...[
                          Text(
                            '  ·  ',
                            style: context.text.bodyMedium?.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              event.refDecision!.label,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyLarge,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (event.refDecision != null &&
                        FormFactor.isPhone(context))
                      Text(
                        event.refDecision!.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium?.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                    // Smartphone: Bewertung und Notiz untereinander (US-704)
                    if (FormFactor.isPhone(context)) ...[
                      if (event.assessment != null) ...[
                        const SizedBox(height: AppSpacing.xs + 2),
                        Row(
                          children: [
                            Flexible(
                              child: _AssessmentPill(
                                assessment: event.assessment!,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (event.sceneNote != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          event.sceneNote!,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ] else if (event.assessment != null ||
                        event.sceneNote != null) ...[
                      const SizedBox(height: AppSpacing.xs + 2),
                      Row(
                        children: [
                          if (event.assessment != null) ...[
                            _AssessmentPill(assessment: event.assessment!),
                            const SizedBox(width: AppSpacing.s),
                          ],
                          if (event.sceneNote != null)
                            Expanded(
                              child: Text(
                                event.sceneNote!,
                                style: context.text.bodyMedium?.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (event.card != null)
                Container(
                  width: 18,
                  height: 26,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                  decoration: BoxDecoration(
                    color: context.colors.card(event.card!),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 2),
                    ],
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: context.scheme.onSurfaceVariant,
                onPressed: () => _openEdit(context, ref),
                tooltip: 'Bearbeiten',
              ),
              IconButton(
                icon: Icon(
                  event.coachingFlag ? Icons.star : Icons.star_border,
                  color: event.coachingFlag
                      ? context.colors.coaching
                      : context.scheme.onSurfaceVariant,
                ),
                onPressed: () => _toggleCoaching(ref, event),
                tooltip: 'Coaching',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleCoaching(WidgetRef ref, Event event) async {
    await ref
        .read(eventRepositoryProvider)
        .updateCoachingFlag(event.id, !event.coachingFlag);
    ref.invalidate(eventsProvider(gameId));
  }

  Future<void> _openEdit(BuildContext context, WidgetRef ref) async {
    final allPlayers = await ref
        .read(eventRepositoryProvider)
        .getPlayersForGame(gameId);
    final eventPlayers = allPlayers
        .where((p) => p.eventId == event.id)
        .toList();

    if (!context.mounted) return;
    // Smartphone: Formular im Vollbild (US-704)
    if (FormFactor.isPhone(context)) {
      showAppDialog<void>(
        context,
        builder: (ctx) => FullscreenDialog(
          child: EventFormPanel(
            gameId: gameId,
            locationX: event.locationX,
            locationY: event.locationY,
            initialEvent: event,
            initialPlayers: eventPlayers,
            onClose: () => Navigator.of(ctx).pop(),
            onSaved: (updated) {
              ref.invalidate(eventsProvider(gameId));
              Navigator.of(ctx).pop();
            },
          ),
        ),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 540,
          height: 680,
          child: EventFormPanel(
            gameId: gameId,
            locationX: event.locationX,
            locationY: event.locationY,
            initialEvent: event,
            initialPlayers: eventPlayers,
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
    // Smartphone: Sheet darf mit Tastatur wachsen (US-704)
    final phone = FormFactor.isPhone(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: phone,
      useSafeArea: phone,
      builder: (_) => phone
          ? SingleChildScrollView(
              child: _EventDetailSheet(event: event, gameId: gameId),
            )
          : _EventDetailSheet(event: event, gameId: gameId),
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
    _coachingCtrl = TextEditingController(
      text: widget.event.coachingNote ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: 0,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${widget.event.minute}' — ${widget.event.type.label}",
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.s),
          if (widget.event.refDecision != null)
            Text(
              'Entscheidung: ${widget.event.refDecision!.label}',
              style: context.text.bodyLarge,
            ),
          if (widget.event.assessment != null)
            Text(
              'Bewertung: ${widget.event.assessment!.label}',
              style: context.text.bodyLarge,
            ),
          if (widget.event.sceneNote != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Notiz: ${widget.event.sceneNote}',
              style: context.text.bodyLarge?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          Text('Coaching-Notiz:', style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _coachingCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Was möchte ich mit dem Schiedsrichter besprechen?',
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(180, AppSizes.liveTap),
              ),
              onPressed: _saveCoachingNote,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Speichern'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCoachingNote() async {
    final note = _coachingCtrl.text.isEmpty ? null : _coachingCtrl.text;
    final repo = ref.read(eventRepositoryProvider);
    await repo.updateCoachingNote(widget.event.id, note);
    await repo.updateCoachingFlag(widget.event.id, true);
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

class _CoachingTab extends ConsumerStatefulWidget {
  final Game game;

  const _CoachingTab({required this.game});

  @override
  ConsumerState<_CoachingTab> createState() => _CoachingTabState();
}

class _CoachingTabState extends ConsumerState<_CoachingTab> {
  late final TextEditingController _overallCtrl;
  late final FocusNode _overallFocus;

  @override
  void initState() {
    super.initState();
    _overallCtrl = TextEditingController(text: widget.game.coachingNote ?? '');
    _overallFocus = FocusNode()..addListener(_saveOverallNote);
  }

  void _saveOverallNote() {
    if (!_overallFocus.hasFocus) {
      final note = _overallCtrl.text.isEmpty ? null : _overallCtrl.text;
      ref.read(gameRepositoryProvider).updateCoachingNote(widget.game.id, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider(widget.game.id));

    return eventsAsync.when(
      data: (events) {
        final coaching = events.where((e) => e.coachingFlag).toList();
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                _OverallNoteSection(
                  controller: _overallCtrl,
                  focusNode: _overallFocus,
                ),
                const SizedBox(height: AppSpacing.l),
                if (coaching.isEmpty)
                  const _EmptyMessage(
                    icon: Icons.star_outline_rounded,
                    text: 'Noch keine Szenen für das Coaching markiert.',
                  )
                else
                  ...coaching.map(
                    (e) => _CoachingItem(event: e, gameId: widget.game.id),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
    );
  }

  @override
  void dispose() {
    _overallFocus.removeListener(_saveOverallNote);
    _overallCtrl.dispose();
    _overallFocus.dispose();
    super.dispose();
  }
}

class _OverallNoteSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _OverallNoteSection({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.scheme.primaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.m,
          AppSpacing.l,
          AppSpacing.l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 20,
                  color: context.scheme.primary,
                ),
                const SizedBox(width: AppSpacing.s),
                const SectionHeader('Allgemeine Notiz'),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Eröffnungsworte, allgemeines Fazit …',
                fillColor: context.scheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachingItem extends ConsumerStatefulWidget {
  final Event event;
  final String gameId;

  const _CoachingItem({required this.event, required this.gameId});

  @override
  ConsumerState<_CoachingItem> createState() => _CoachingItemState();
}

class _CoachingItemState extends ConsumerState<_CoachingItem> {
  late final TextEditingController _noteCtrl;
  late final FocusNode _noteFocus;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.event.coachingNote ?? '');
    _noteFocus = FocusNode()..addListener(_saveNote);
  }

  void _saveNote() {
    if (!_noteFocus.hasFocus) {
      final note = _noteCtrl.text.isEmpty ? null : _noteCtrl.text;
      ref
          .read(eventRepositoryProvider)
          .updateCoachingNote(widget.event.id, note);
    }
  }

  Future<void> _toggleFlag() async {
    await ref
        .read(eventRepositoryProvider)
        .updateCoachingFlag(widget.event.id, !widget.event.coachingFlag);
    ref.invalidate(eventsProvider(widget.gameId));
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.s,
            AppSpacing.xs,
            AppSpacing.m,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: minute · type · decision · assessment · flag
              Row(
                children: [
                  _MinuteBadge(event: e),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      [
                        e.type.label,
                        if (e.refDecision != null) e.refDecision!.label,
                        if (e.assessment != null) e.assessment!.label,
                      ].join(' · '),
                      style: context.text.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      e.coachingFlag
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: e.coachingFlag
                          ? context.colors.coaching
                          : context.scheme.onSurfaceVariant,
                    ),
                    onPressed: _toggleFlag,
                    tooltip: 'Coaching-Flag',
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 56 + AppSpacing.m,
                  right: AppSpacing.s,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scene note (read-only, from live capture)
                    if (e.sceneNote != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 18,
                            color: context.scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: Text(
                              e.sceneNote!,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Coaching note (inline editable)
                    const SizedBox(height: AppSpacing.s),
                    TextField(
                      controller: _noteCtrl,
                      focusNode: _noteFocus,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Coaching-Notiz …',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteFocus.removeListener(_saveNote);
    _noteCtrl.dispose();
    _noteFocus.dispose();
    super.dispose();
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
      data: (events) {
        final heatmap = StatCard(
          title: 'Heatmap',
          icon: Icons.blur_on_rounded,
          // Echtes Spielfeld-Seitenverhältnis (105 × 68 m), nicht gestreckt
          child: Center(
            child: AspectRatio(
              aspectRatio: 105 / 68,
              child: HeatmapCanvas(events: events),
            ),
          ),
        );
        final timeline = StatCard(
          title: 'Zeitachse',
          icon: Icons.bar_chart_rounded,
          child: _TimelineChart(events: events),
        );
        final ranking = StatCard(
          title: 'Spieler-Ranking',
          icon: Icons.leaderboard_outlined,
          child: _PlayerRanking(gameId: gameId),
        );
        final goals = StatCard(
          title: 'Tore',
          icon: Icons.sports_soccer,
          child: _GoalList(gameId: gameId),
        );
        final fouls = StatCard(
          title: 'Vergehen pro Team',
          icon: Icons.table_chart_outlined,
          child: SingleChildScrollView(child: _TeamFoulsTable(gameId: gameId)),
        );
        const gap = SizedBox.square(dimension: AppSpacing.l);

        return LayoutBuilder(
          builder: (context, constraints) {
            // Schmale Fenster: Karten untereinander, scrollbar
            if (constraints.maxWidth < 900 || constraints.maxHeight < 520) {
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.l),
                children: [
                  for (final c in [heatmap, timeline, ranking, goals, fouls])
                    ...[
                    SizedBox(height: 320, child: c),
                    gap,
                  ],
                ],
              );
            }
            // 2 × 2-Dashboard (US-605)
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  Expanded(
                    flex: 11,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: heatmap),
                        gap,
                        Expanded(flex: 2, child: timeline),
                      ],
                    ),
                  ),
                  gap,
                  Expanded(
                    flex: 9,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 2, child: ranking),
                        gap,
                        Expanded(flex: 2, child: goals),
                        gap,
                        Expanded(flex: 2, child: fouls),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
    );
  }
}

/// Ereignisse pro 15-Minuten-Phase als Balkendiagramm; die Balken wachsen
/// beim Öffnen hoch (US-402, US-605, US-606).
class _TimelineChart extends StatelessWidget {
  final List<Event> events;
  static const _phases = [
    (0, 15),
    (15, 30),
    (30, 45),
    (45, 60),
    (60, 75),
    (75, 90),
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

    return TweenAnimationBuilder<double>(
      key: const Key('timeline_chart'),
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, const Duration(milliseconds: 600)),
      curve: AppMotion.curve,
      builder: (context, grow, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_phases.length, (i) {
          final label = '${_phases[i].$1}–${_phases[i].$2}\'';
          final frac = counts[i] / maxCount;
          // 2. Halbzeit leicht abgesetzt
          final color = i < 3
              ? context.scheme.primary
              : Color.lerp(context.scheme.primary, Colors.black, 0.25)!;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                children: [
                  Text(
                    '${counts[i]}',
                    style: context.text.titleSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.scheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: (frac * grow).clamp(0.0, 1.0),
                        widthFactor: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(AppRadius.s),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: context.text.labelMedium?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
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
          return Text(
            'Keine Spielernummern erfasst.',
            style: context.text.bodyMedium?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          );
        }
        final maxCount = ranking.first.count;
        return ListView.separated(
          itemCount: ranking.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
          itemBuilder: (ctx, i) {
            final entry = ranking[i];
            final isHome = entry.team == TeamSide.home;
            final teamColor = context.colors.team(entry.team);
            final teamLabel = isHome ? 'H' : 'G';
            return Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}.',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: teamColor,
                    borderRadius: BorderRadius.circular(AppRadius.s - 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    teamLabel,
                    style: context.text.labelMedium?.copyWith(
                      color: AppColors.onColor(teamColor),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                SizedBox(
                  width: 52,
                  child: Text(
                    '#${entry.number}',
                    style: context.text.titleMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.s),
                    child: LinearProgressIndicator(
                      value: entry.count / maxCount,
                      minHeight: 10,
                      color: teamColor,
                      backgroundColor: context.scheme.surfaceContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s + 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: Text(
                    '${entry.count}×',
                    style: context.text.labelLarge?.copyWith(fontSize: 14),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(
        'Fehler: $e',
        style: TextStyle(color: context.scheme.error, fontSize: 13),
      ),
    );
  }
}

/// Tore mit Minute, Team, Spielstand danach, Torschütze und Torart (US-215).
class _GoalList extends ConsumerWidget {
  final String gameId;

  const _GoalList({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider(gameId)).valueOrNull ?? [];
    if (goals.isEmpty) {
      return Text(
        'Keine Tore erfasst.',
        style: context.text.bodyMedium?.copyWith(
          color: context.scheme.onSurfaceVariant,
        ),
      );
    }
    final running = Score.runningByGoalId(goals);
    // Chronologisch nach Phase, dann Zeit (wie der laufende Spielstand)
    final sorted = [...goals]..sort((a, b) {
        final byPhase = a.gamePhase.index.compareTo(b.gamePhase.index);
        return byPhase != 0 ? byPhase : a.elapsedMs.compareTo(b.elapsedMs);
      });

    return ListView.separated(
      key: const Key('stats_goal_list'),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
      itemBuilder: (_, i) {
        final g = sorted[i];
        final teamColor = context.colors.team(g.team);
        final scorer = [
          if (g.scorerNumber != null)
            '#${g.scorerNumber}'
                '${g.kind == GoalKind.ownGoal ? ' (${g.scorerTeam.label})' : ''}',
          if (g.kind != GoalKind.regular) g.kind.label,
        ].join(' · ');
        return Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                g.elapsedLabel,
                style: context.text.bodyMedium?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: teamColor,
                borderRadius: BorderRadius.circular(AppRadius.s - 2),
              ),
              alignment: Alignment.center,
              child: Text(
                g.team == TeamSide.home ? 'H' : 'G',
                style: context.text.labelMedium?.copyWith(
                  color: AppColors.onColor(teamColor),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              running[g.id]!.shortLabel,
              style: context.text.titleMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                scorer,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Kompakte Tabelle „Vergehen pro Team" (US-404): Kategorien × Halbzeit/Team.
class _TeamFoulsTable extends ConsumerWidget {
  final String gameId;

  const _TeamFoulsTable({required this.gameId});

  static const _cellWidth = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foulsAsync = ref.watch(teamFoulsProvider(gameId));

    return foulsAsync.when(
      data: (fouls) {
        final periods = fouls.periods;

        Widget row(
          String label,
          int Function(FoulPeriod, TeamSide) value, {
          bool bold = false,
        }) {
          final style = TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: context.scheme.onSurface,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(child: Text(label, style: style)),
                for (final period in periods)
                  for (final team in TeamSide.values)
                    SizedBox(
                      width: _cellWidth,
                      child: Text(
                        '${value(period, team)}',
                        textAlign: TextAlign.right,
                        style: style,
                      ),
                    ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                for (final period in periods)
                  SizedBox(
                    width: _cellWidth * 2,
                    child: Text(
                      period.label,
                      textAlign: TextAlign.right,
                      style: context.text.labelMedium?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                for (final _ in periods)
                  for (final team in TeamSide.values)
                    SizedBox(
                      width: _cellWidth,
                      child: Text(
                        team == TeamSide.home ? 'H' : 'G',
                        textAlign: TextAlign.right,
                        style: context.text.labelMedium?.copyWith(
                          color: context.colors.team(team),
                        ),
                      ),
                    ),
              ],
            ),
            for (final category in FoulCategory.values)
              row(
                category.label,
                (period, team) => fouls.count(period, team, category),
              ),
            const Divider(height: AppSpacing.m),
            row('Summe', fouls.total, bold: true),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text(
        'Fehler: $e',
        style: TextStyle(color: context.scheme.error, fontSize: 13),
      ),
    );
  }
}
