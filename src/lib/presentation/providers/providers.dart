import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../data/repositories/squad_repository_impl.dart';
import '../../data/repositories/timer_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_player.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/timer_state.dart';
import '../../domain/enums/assessment.dart';
import '../../domain/enums/event_type.dart';
import '../../domain/enums/team_side.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/squad_repository.dart';
import '../../domain/repositories/timer_repository.dart';
import '../../core/timer_service.dart';

// ── Database ──────────────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((_) => AppDatabase());

// ── Repositories ──────────────────────────────────────────────────────────────

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepositoryImpl(ref.watch(databaseProvider)),
);

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => EventRepositoryImpl(ref.watch(databaseProvider)),
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
  final events = await ref.read(eventRepositoryProvider).getEvents(gameId);
  return events.length;
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

// ── Player Ranking ────────────────────────────────────────────────────────────

/// Gibt eine sortierte Liste von (TeamSide, Rückennummer, Anzahl) zurück.
final playerRankingProvider = FutureProvider.family<
    List<({TeamSide team, int number, int count})>, String>(
  (ref, gameId) async {
    final players =
        await ref.watch(eventRepositoryProvider).getPlayersForGame(gameId);
    final freq = <String, ({TeamSide team, int number, int count})>{};
    for (final p in players) {
      final key = '${p.team.name}-${p.jerseyNumber}';
      final prev = freq[key];
      freq[key] = (
        team: p.team,
        number: p.jerseyNumber,
        count: (prev?.count ?? 0) + 1,
      );
    }
    final list = freq.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return list;
  },
);

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
