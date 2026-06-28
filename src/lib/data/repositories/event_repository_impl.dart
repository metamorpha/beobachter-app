import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_player.dart';
import '../../domain/enums/assessment.dart';
import '../../domain/enums/card_type.dart';
import '../../domain/enums/event_type.dart';
import '../../domain/enums/game_phase.dart';
import '../../domain/enums/player_role.dart';
import '../../domain/enums/ref_decision.dart';
import '../../domain/enums/team_side.dart';
import '../../domain/repositories/event_repository.dart';
import '../database/app_database.dart';

class EventRepositoryImpl implements EventRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  EventRepositoryImpl(this._db);

  @override
  Future<Event> createEvent(Event event, List<EventPlayer> players) async {
    return _db.transaction(() async {
      final eventId = event.id.isEmpty ? _uuid.v4() : event.id;
      await _db.into(_db.events).insert(_toCompanion(event, eventId));
      for (final p in players) {
        await _db.into(_db.eventPlayers).insert(
              EventPlayersCompanion(
                id: Value(_uuid.v4()),
                eventId: Value(eventId),
                role: Value(p.role.name),
                team: Value(p.team.name),
                jerseyNumber: Value(p.jerseyNumber),
              ),
            );
      }
      return _toEntity(
        await (_db.select(_db.events)
              ..where((t) => t.id.equals(eventId)))
            .getSingle(),
        players,
      );
    });
  }

  @override
  Future<List<Event>> getEvents(String gameId) async {
    final rows = await (_db.select(_db.events)
          ..where((t) => t.gameId.equals(gameId))
          ..orderBy([(t) => OrderingTerm.asc(t.elapsedMs)]))
        .get();
    final result = <Event>[];
    for (final row in rows) {
      final players = await _playersFor(row.id);
      result.add(_toEntity(row, players));
    }
    return result;
  }

  @override
  Future<Event?> getEvent(String id) async {
    final rows = await (_db.select(_db.events)
          ..where((t) => t.id.equals(id)))
        .get();
    if (rows.isEmpty) return null;
    final players = await _playersFor(id);
    return _toEntity(rows.first, players);
  }

  @override
  Future<void> updateEvent(Event event, List<EventPlayer> players) async {
    await _db.transaction(() async {
      await (_db.update(_db.events)..where((t) => t.id.equals(event.id)))
          .write(_toCompanion(event, event.id));
      await (_db.delete(_db.eventPlayers)
            ..where((t) => t.eventId.equals(event.id)))
          .go();
      for (final p in players) {
        await _db.into(_db.eventPlayers).insert(
              EventPlayersCompanion(
                id: Value(_uuid.v4()),
                eventId: Value(event.id),
                role: Value(p.role.name),
                team: Value(p.team.name),
                jerseyNumber: Value(p.jerseyNumber),
              ),
            );
      }
    });
  }

  @override
  Future<void> deleteEvent(String id) async {
    await (_db.delete(_db.events)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<EventPlayer>> getPlayersForGame(String gameId) async {
    final eventRows = await (_db.select(_db.events)
          ..where((t) => t.gameId.equals(gameId)))
        .get();
    final eventIds = eventRows.map((e) => e.id).toList();
    if (eventIds.isEmpty) return [];
    final rows = await (_db.select(_db.eventPlayers)
          ..where((t) => t.eventId.isIn(eventIds)))
        .get();
    return rows
        .map((r) => EventPlayer(
              id: r.id,
              eventId: r.eventId,
              role: PlayerRole.values.byName(r.role),
              team: TeamSide.values.byName(r.team),
              jerseyNumber: r.jerseyNumber,
            ))
        .toList();
  }

  Future<List<EventPlayer>> _playersFor(String eventId) async {
    final rows = await (_db.select(_db.eventPlayers)
          ..where((t) => t.eventId.equals(eventId)))
        .get();
    return rows
        .map((r) => EventPlayer(
              id: r.id,
              eventId: r.eventId,
              role: PlayerRole.values.byName(r.role),
              team: TeamSide.values.byName(r.team),
              jerseyNumber: r.jerseyNumber,
            ))
        .toList();
  }

  EventsCompanion _toCompanion(Event e, String id) => EventsCompanion(
        id: Value(id),
        gameId: Value(e.gameId),
        elapsedMs: Value(e.elapsedMs),
        gamePhase: Value(e.gamePhase.name),
        type: Value(e.type.name),
        customTypeLabel: Value(e.customTypeLabel),
        locationX: Value(e.locationX),
        locationY: Value(e.locationY),
        refDecision: Value(e.refDecision?.name),
        card: Value(e.card?.name),
        assessment: Value(e.assessment?.name),
        sceneNote: Value(e.sceneNote),
        coachingFlag: Value(e.coachingFlag),
        coachingNote: Value(e.coachingNote),
        createdAt: Value(e.createdAt),
      );

  Event _toEntity(EventRow row, List<EventPlayer> players) => Event(
        id: row.id,
        gameId: row.gameId,
        elapsedMs: row.elapsedMs,
        gamePhase: _parsePhase(row.gamePhase),
        type: EventType.values.byName(row.type),
        customTypeLabel: row.customTypeLabel,
        locationX: row.locationX,
        locationY: row.locationY,
        refDecision: row.refDecision != null
            ? RefDecision.values.byName(row.refDecision!)
            : null,
        card: row.card != null ? CardType.values.byName(row.card!) : null,
        assessment: row.assessment != null
            ? Assessment.values.byName(row.assessment!)
            : null,
        sceneNote: row.sceneNote,
        coachingFlag: row.coachingFlag,
        coachingNote: row.coachingNote,
        createdAt: row.createdAt,
      );

  static GamePhase _parsePhase(String name) {
    try {
      return GamePhase.values.byName(name);
    } catch (_) {
      return GamePhase.ersteHalbzeit;
    }
  }
}
