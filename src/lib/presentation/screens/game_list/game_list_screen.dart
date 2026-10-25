import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/game.dart';
import '../../../domain/enums/game_phase.dart';
import '../../platform/preferred_orientation.dart';
import '../../providers/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../game_setup/game_setup_screen.dart';
import '../live/live_screen.dart';
import '../review/review_screen.dart';

class GameListScreen extends ConsumerWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);

    // Smartphone: Spielliste im Hochformat (US-703)
    return PreferredOrientation(
      landscape: false,
      child: _buildScaffold(context, ref, gamesAsync),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Game>> gamesAsync,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.scheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              child: Icon(
                Icons.sports_soccer,
                color: context.scheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            const Text('Beobachter'),
          ],
        ),
      ),
      body: gamesAsync.when(
        data: (games) => games.isEmpty
            ? const _EmptyState()
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Querformat: zwei (große Displays drei) Spalten (US-604)
                  final cols = constraints.maxWidth >= 1500
                      ? 3
                      : constraints.maxWidth >= 720
                      ? 2
                      : 1;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      112,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: AppSpacing.l,
                      crossAxisSpacing: AppSpacing.l,
                      mainAxisExtent: 172,
                    ),
                    itemCount: games.length,
                    itemBuilder: (ctx, i) => _GameTile(game: games[i]),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_new_game'),
        onPressed: () => _createGame(context, ref),
        icon: const Icon(Icons.add_rounded, size: 26),
        label: const Text('Neues Spiel'),
      ),
    );
  }

  Future<void> _createGame(BuildContext context, WidgetRef ref) async {
    final game = Game(
      id: const Uuid().v4(),
      date: DateTime.now(),
      homeTeamName: '',
      awayTeamName: '',
      createdAt: DateTime.now(),
    );
    final saved = await ref.read(gameRepositoryProvider).createGame(game);
    ref.invalidate(gamesProvider);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameSetupScreen(game: saved)),
      );
    }
  }
}

class _GameTile extends ConsumerWidget {
  final Game game;

  const _GameTile({required this.game});

  String get _displayName {
    if (game.homeTeamName.isEmpty && game.awayTeamName.isEmpty) {
      return 'Unbenanntes Spiel';
    }
    return '${game.homeTeamName} – ${game.awayTeamName}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr =
        '${game.date.day.toString().padLeft(2, '0')}.${game.date.month.toString().padLeft(2, '0')}.${game.date.year}';
    final countAsync = ref.watch(eventCountProvider(game.id));
    final countStr = countAsync.valueOrNull != null
        ? ' · ${countAsync.value} Ereignisse'
        : '';
    final meta = [
      if (game.liga != null) game.liga!,
      if (game.spieltag != null) '${game.spieltag}. Spieltag',
    ].join(' · ');

    final phase = ref.watch(gamePhaseProvider(game.id)).valueOrNull;
    final abgeschlossen = phase == GamePhase.abgeschlossen;
    final laeuft = phase?.istLaufend ?? false;
    final score = ref.watch(scoreProvider(game.id));

    return Card(
      key: Key('game_tile_${game.id}'),
      child: InkWell(
        onTap: () => _openGame(context, laeuft: laeuft),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l + 4,
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        meta.isEmpty ? dateStr : meta,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelMedium?.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (abgeschlossen)
                      _badge(
                        context,
                        key: Key('badge_beendet_${game.id}'),
                        label: 'Beendet',
                        background: context.scheme.surfaceContainerHigh,
                        foreground: context.scheme.onSurfaceVariant,
                      ),
                    if (laeuft)
                      _badge(
                        context,
                        key: Key('badge_laeuft_${game.id}'),
                        label: 'Läuft',
                        background: context.scheme.primaryContainer,
                        foreground: context.scheme.onPrimaryContainer,
                        live: true,
                      ),
                    const SizedBox(width: AppSpacing.s),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleLarge?.copyWith(height: 1.25),
                      ),
                    ),
                    if (score.home + score.away > 0 || laeuft || abgeschlossen)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.m,
                          right: AppSpacing.s,
                        ),
                        child: Text(
                          score.label,
                          style: context.text.headlineSmall?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 16,
                    color: context.scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Expanded(
                    child: Text(
                      '$dateStr$countStr',
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    key: Key('btn_delete_game_${game.id}'),
                    tooltip: 'Spiel löschen',
                    icon: Icon(
                      Icons.delete_outline,
                      color: context.scheme.error,
                    ),
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(
    BuildContext context, {
    required Key key,
    required String label,
    required Color background,
    required Color foreground,
    bool live = false,
  }) => Container(
    key: key,
    margin: const EdgeInsets.only(left: AppSpacing.s),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.s + 2,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (live) ...[
          const _LiveDot(),
          const SizedBox(width: AppSpacing.xs + 2),
        ],
        Text(
          label,
          style: context.text.labelMedium?.copyWith(color: foreground),
        ),
      ],
    ),
  );

  /// Laufende Spiele direkt in die Live-Erfassung (US-109), sonst Nachbereitung.
  void _openGame(BuildContext context, {required bool laeuft}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            laeuft ? LiveScreen(game: game) : ReviewScreen(game: game),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.delete_outline, color: ctx.scheme.error),
        title: const Text('Spiel löschen?'),
        content: Text(
          'Das Spiel „$_displayName" wird unwiderruflich gelöscht – '
          'einschließlich aller Ereignisse, Aufstellungen und Timer-Daten.',
        ),
        actions: [
          TextButton(
            key: const Key('dialog_btn_cancel'),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            key: const Key('dialog_btn_delete_confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: ctx.scheme.error,
              foregroundColor: ctx.scheme.onError,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(gameRepositoryProvider).deleteGame(game.id);
      ref.invalidate(gamesProvider);
    }
  }
}

/// Pulsiert nach dem Erscheinen dreimal dezent und leuchtet dann ruhig
/// (US-604) — bewusst endlich, damit die Liste zur Ruhe kommt.
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> {
  static const _halfCycles = 6;
  bool _bright = true;
  int _done = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !AppMotion.reduced(context)) {
        setState(() => _bright = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _bright ? 1 : 0.3,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      onEnd: () {
        if (!mounted) return;
        _done++;
        if (_done < _halfCycles) {
          setState(() => _bright = !_bright);
        } else if (!_bright) {
          setState(() => _bright = true);
        }
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: context.colors.phaseStart,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_soccer,
                size: 48,
                color: context.scheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Noch keine Spiele erfasst.', style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Mit „Neues Spiel" unten rechts legst du dein erstes Spiel an.',
              textAlign: TextAlign.center,
              style: context.text.bodyLarge?.copyWith(
                color: context.scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
