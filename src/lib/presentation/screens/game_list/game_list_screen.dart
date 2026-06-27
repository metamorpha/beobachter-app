import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/game.dart';
import '../../providers/providers.dart';
import '../game_setup/game_setup_screen.dart';
import '../review/review_screen.dart';

class GameListScreen extends ConsumerWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beobachter'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: gamesAsync.when(
        data: (games) => games.isEmpty
            ? const Center(child: Text('Noch keine Spiele erfasst.'))
            : ListView.builder(
                itemCount: games.length,
                itemBuilder: (ctx, i) => _GameTile(game: games[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_new_game'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        onPressed: () => _createGame(context, ref),
        icon: const Icon(Icons.add),
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

    return ListTile(
      key: Key('game_tile_${game.id}'),
      leading: const Icon(Icons.sports_soccer, color: Colors.green),
      title: Text(
        _displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('$dateStr$countStr'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _openGame(context),
            child: const Icon(Icons.chevron_right),
          ),
          IconButton(
            key: Key('btn_delete_game_${game.id}'),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      onTap: () => _openGame(context),
    );
  }

  void _openGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReviewScreen(game: game)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
          TextButton(
            key: const Key('dialog_btn_delete_confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
