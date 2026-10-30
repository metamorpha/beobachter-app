import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../data/repositories/squad_repository_impl.dart';
import '../../data/repositories/timer_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_player.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/score.dart';
import '../../domain/entities/team_fouls.dart';
import '../../domain/entities/timer_state.dart';
import '../../domain/enums/assessment.dart';
import '../../domain/enums/event_type.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/enums/player_role.dart';
import '../../domain/enums/team_side.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/repositories/squad_repository.dart';
import '../../domain/repositories/timer_repository.dart';
import '../../core/timer_service.dart';
import '../theme/kit_colors.dart';

// ── Database ──────────────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((_) => AppDatabase());

// ── Repositories ──────────────────────────────────────────────────────────────

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepositoryImpl(ref.watch(databaseProvider)),
);

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => EventRepositoryImpl(ref.watch(databaseProvider)),
);

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepositoryImpl(ref.watch(databaseProvider)),
);

final squadRepositoryProvider = Provider<SquadRepository>(
  (ref) => SquadRepositoryImpl(ref.watch(databaseProvider)),
);

final timerRepositoryProvider = Provider<TimerRepository>(
  (ref) => TimerRepositoryImpl(ref.watch(databaseProvider)),
);

// ── Games ─────────────────────────────────────────────────────────────────────

final gamesProvider = FutureProvider<List<Game>>((ref) {
  return ref.watch(gameRepositoryProvider).getGames();
});

// ── Events ────────────────────────────────────────────────────────────────────

final eventsProvider =
    FutureProvider.family<List<Event>, String>((ref, gameId) {
  return ref.watch(eventRepositoryProvider).getEvents(gameId);
});


final eventCountProvider =
    FutureProvider.family<int, String>((ref, gameId) async {
  final events = await ref.watch(eventsProvider(gameId).future);
  return events.length;
});

// ── Tore (US-215) ─────────────────────────────────────────────────────────────

final goalsProvider = FutureProvider.family<List<Goal>, String>((ref, gameId) {
  return ref.watch(goalRepositoryProvider).getGoals(gameId);
});

/// Aktueller Spielstand — abgeleitet aus den Toren (US-215).
final scoreProvider = Provider.family<Score, String>((ref, gameId) {
  final goals = ref.watch(goalsProvider(gameId)).valueOrNull ?? const [];
  return Score.fromGoals(goals);
});

/// Einzelnes Spiel — Quelle der Trikotfarben; nach Änderungen invalidieren.
final gameProvider = FutureProvider.family<Game?, String>((ref, gameId) {
  return ref.watch(gameRepositoryProvider).getGame(gameId);
});

/// Trikotfarben eines Spiels (US-111); `null` solange noch nicht geladen.
final teamKitsProvider = Provider.family<TeamKits?, String>((ref, gameId) {
  final game = ref.watch(gameProvider(gameId)).valueOrNull;
  return game == null ? null : TeamKits.fromGame(game);
});

// ── Squad ─────────────────────────────────────────────────────────────────────

final homeSquadProvider =
    FutureProvider.family<List<int>, String>((ref, gameId) {
  return ref.watch(squadRepositoryProvider).getSquad(gameId, TeamSide.home);
});

final awaySquadProvider =
    FutureProvider.family<List<int>, String>((ref, gameId) {
  return ref.watch(squadRepositoryProvider).getSquad(gameId, TeamSide.away);
});

// ── Timer ─────────────────────────────────────────────────────────────────────

final timerServiceProvider =
    Provider.family.autoDispose<TimerService, String>((ref, gameId) {
  final service = TimerService(
    ref.watch(timerRepositoryProvider),
    gameId: gameId,
  );
  service.load();
  ref.onDispose(service.dispose);
  return service;
});

final timerStateProvider =
    StreamProvider.family<TimerState, String>((ref, gameId) {
  return ref.watch(timerServiceProvider(gameId)).stream;
});

/// Persistierte Spielphase eines Spiels, reaktiv aus der DB
/// (z. B. für das „Beendet"-Badge in der Spielliste, US-212).
final gamePhaseProvider =
    StreamProvider.family.autoDispose<GamePhase?, String>((ref, gameId) {
  return ref
      .watch(timerRepositoryProvider)
      .watchTimerState(gameId)
      .map((state) => state?.phase);
});

// ── Player Ranking ────────────────────────────────────────────────────────────

/// Gibt eine sortierte Liste von (TeamSide, Rückennummer, Anzahl) zurück.
/// Gezählt werden nur Täter (Fouler), keine gefoulten Spieler, und nur
/// Einträge mit Rückennummer (US-404).
final playerRankingProvider = FutureProvider.family<
    List<({TeamSide team, int number, int count})>, String>(
  (ref, gameId) async {
    final players =
        await ref.watch(eventRepositoryProvider).getPlayersForGame(gameId);
    final freq = <String, ({TeamSide team, int number, int count})>{};
    for (final p in players.where((p) => p.role == PlayerRole.fouler)) {
      final number = p.jerseyNumber;
      if (number == null) continue;
      final key = '${p.team.name}-$number';
      final prev = freq[key];
      freq[key] = (
        team: p.team,
        number: number,
        count: (prev?.count ?? 0) + 1,
      );
    }
    final list = freq.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return list;
  },
);

// ── Vergehen pro Team (US-404) ────────────────────────────────────────────────

/// Vergehen pro Team und Halbzeit. Hängt an [eventsProvider], damit die
/// Tabelle nach Bearbeiten oder Löschen einer Szene neu berechnet wird.
final teamFoulsProvider =
    FutureProvider.family<TeamFouls, String>((ref, gameId) async {
  final events = await ref.watch(eventsProvider(gameId).future);
  final players =
      await ref.watch(eventRepositoryProvider).getPlayersForGame(gameId);
  return TeamFouls.fromEvents(events, players);
});

// ── Scene Filter ──────────────────────────────────────────────────────────────

class SceneFilter {
  final EventType? eventType;
  final bool? correct;   // null = alle, true = korrekt, false = falsch
  final bool? withCard;  // null = alle, true = mit Karte
  final bool coachingOnly;

  const SceneFilter({
    this.eventType,
    this.correct,
    this.withCard,
    this.coachingOnly = false,
  });

  bool get isActive =>
      eventType != null || correct != null || withCard != null || coachingOnly;

  List<Event> apply(List<Event> events) {
    return events.where((e) {
      if (eventType != null && e.type != eventType) return false;
      if (correct != null) {
        if (e.assessment == null) return false;
        if (e.assessment!.isCorrect != correct) return false;
      }
      if (withCard == true && e.card == null) return false;
      if (coachingOnly && !e.coachingFlag) return false;
      return true;
    }).toList();
  }

  SceneFilter copyWith({
    EventType? eventType,
    bool? correct,
    bool? withCard,
    bool? coachingOnly,
    bool clearEventType = false,
    bool clearCorrect = false,
    bool clearWithCard = false,
  }) =>
      SceneFilter(
        eventType: clearEventType ? null : (eventType ?? this.eventType),
        correct: clearCorrect ? null : (correct ?? this.correct),
        withCard: clearWithCard ? null : (withCard ?? this.withCard),
        coachingOnly: coachingOnly ?? this.coachingOnly,
      );
}

final sceneFilterProvider =
    StateProvider.family<SceneFilter, String>((ref, gameId) {
  return const SceneFilter();
});

// ── Event Form State ──────────────────────────────────────────────────────────

class EventFormNotifier extends StateNotifier<EventFormState> {
  final EventRepository _eventRepo;
  final Ref _ref;
  final String gameId;

  EventFormNotifier(this._eventRepo, this._ref, this.gameId)
      : super(EventFormState.empty());

  void updateField(EventFormState Function(EventFormState) updater) {
    state = updater(state);
  }

  Future<Event?> save({
    required double locationX,
    required double locationY,
    required int elapsedMs,
  }) async {
    if (state.type == null) return null;
    final event = Event(
      id: '',
      gameId: gameId,
      elapsedMs: elapsedMs,
      type: state.type!,
      customTypeLabel: state.customTypeLabel,
      locationX: locationX,
      locationY: locationY,
      refDecision: state.refDecision,
      card: state.card,
      assessment: state.assessment,
      sceneNote: state.sceneNote,
      coachingFlag: false,
      createdAt: DateTime.now(),
    );
    final saved = await _eventRepo.createEvent(event, state.players);
    state = EventFormState.empty();
    _ref.invalidate(eventsProvider(gameId));
    return saved;
  }

  void reset() => state = EventFormState.empty();
}

class EventFormState {
  final dynamic type;       // EventType?
  final String? customTypeLabel;
  final dynamic refDecision; // RefDecision?
  final dynamic card;        // CardType?
  final dynamic assessment;  // Assessment?
  final String? sceneNote;
  final List<EventPlayer> players;

  const EventFormState({
    this.type,
    this.customTypeLabel,
    this.refDecision,
    this.card,
    this.assessment,
    this.sceneNote,
    this.players = const [],
  });

  factory EventFormState.empty() => const EventFormState();

  EventFormState copyWith({
    dynamic type,
    String? customTypeLabel,
    dynamic refDecision,
    dynamic card,
    dynamic assessment,
    String? sceneNote,
    List<EventPlayer>? players,
  }) =>
      EventFormState(
        type: type ?? this.type,
        customTypeLabel: customTypeLabel ?? this.customTypeLabel,
        refDecision: refDecision ?? this.refDecision,
        card: card ?? this.card,
        assessment: assessment ?? this.assessment,
        sceneNote: sceneNote ?? this.sceneNote,
        players: players ?? this.players,
      );
}

final eventFormProvider = StateNotifierProvider.family
    .autoDispose<EventFormNotifier, EventFormState, String>(
  (ref, gameId) => EventFormNotifier(
    ref.watch(eventRepositoryProvider),
    ref,
    gameId,
  ),
);
