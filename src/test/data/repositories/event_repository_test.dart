import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/data/database/app_database.dart';
import 'package:beobachter_app/data/repositories/event_repository_impl.dart';
import 'package:beobachter_app/data/repositories/game_repository_impl.dart';
import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/enums/assessment.dart';
import 'package:beobachter_app/domain/enums/card_type.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/player_role.dart';
import 'package:beobachter_app/domain/enums/ref_decision.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';

void main() {
  late AppDatabase db;
  late EventRepositoryImpl eventRepo;
  late GameRepositoryImpl gameRepo;
  const gameId = 'g-1';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    gameRepo = GameRepositoryImpl(db);
    eventRepo = EventRepositoryImpl(db);
    await gameRepo.createGame(Game(
      id: gameId,
      date: DateTime(2026, 4, 30),
      homeTeamName: 'Heim',
      awayTeamName: 'Gast',
      createdAt: DateTime(2026, 4, 30),
    ));
  });

  tearDown(() => db.close());

  Event testEvent({String id = 'e-1', int elapsedMs = 60000}) => Event(
        id: id,
        gameId: gameId,
        elapsedMs: elapsedMs,
        type: EventType.footFoul,
        locationX: 0.3,
        locationY: 0.6,
        refDecision: RefDecision.freeKick,
        card: null,
        assessment: Assessment.correctExpected,
        sceneNote: 'Typisches Foul',
        coachingFlag: false,
        createdAt: DateTime(2026, 4, 30, 15, 0),
      );

  group('EventRepository', () {
    test('createEvent speichert Event und gibt es zurück', () async {
      final event = await eventRepo.createEvent(testEvent(), []);
      expect(event.type, EventType.footFoul);
      expect(event.locationX, 0.3);
      expect(event.assessment, Assessment.correctExpected);
    });

    test('createEvent speichert EventPlayer korrekt', () async {
      final player = EventPlayer(
        id: '',
        eventId: '',
        role: PlayerRole.fouler,
        team: TeamSide.home,
        jerseyNumber: 7,
      );
      final event = await eventRepo.createEvent(testEvent(), [player]);
      expect(event.id, isNotEmpty);
    });

    test('getEvents gibt Events chronologisch sortiert zurück', () async {
      await eventRepo.createEvent(testEvent(id: 'e-1', elapsedMs: 120000), []);
      await eventRepo.createEvent(testEvent(id: 'e-2', elapsedMs: 60000), []);
      final events = await eventRepo.getEvents(gameId);
      expect(events.first.elapsedMs, 60000); // früher zuerst
      expect(events.last.elapsedMs, 120000);
    });

    test('getEvent gibt null zurück wenn nicht gefunden', () async {
      final result = await eventRepo.getEvent('nicht-vorhanden');
      expect(result, isNull);
    });

    test('updateEvent aktualisiert coachingFlag', () async {
      final created = await eventRepo.createEvent(testEvent(), []);
      final updated = created.copyWith(coachingFlag: true);
      await eventRepo.updateEvent(updated, []);
      final result = await eventRepo.getEvent(created.id);
      expect(result?.coachingFlag, true);
    });

    test('deleteEvent entfernt das Event', () async {
      final created = await eventRepo.createEvent(testEvent(), []);
      await eventRepo.deleteEvent(created.id);
      final result = await eventRepo.getEvent(created.id);
      expect(result, isNull);
    });

    test('deleteGame löscht Events via Cascade', () async {
      await eventRepo.createEvent(testEvent(), []);
      await gameRepo.deleteGame(gameId);
      final events = await eventRepo.getEvents(gameId);
      expect(events, isEmpty);
    });

    test('Event mit CardType.red wird korrekt persistiert', () async {
      final event = testEvent().copyWith(card: CardType.red);
      final saved = await eventRepo.createEvent(event, []);
      expect(saved.card, CardType.red);
    });

    test('Event ohne Bewertung bleibt null', () async {
      final event = Event(
        id: '',
        gameId: gameId,
        elapsedMs: 30000,
        type: EventType.offside,
        locationX: 0.8,
        locationY: 0.5,
        coachingFlag: false,
        createdAt: DateTime.now(),
      );
      final saved = await eventRepo.createEvent(event, []);
      expect(saved.assessment, isNull);
      expect(saved.refDecision, isNull);
    });
  });
}
