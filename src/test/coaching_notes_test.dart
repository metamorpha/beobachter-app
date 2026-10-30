import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/kit_color.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/domain/repositories/event_repository.dart';
import 'package:beobachter_app/domain/repositories/game_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/review/review_screen.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeEventRepository implements EventRepository {
  final List<Event> _events;

  String? lastCoachingNoteEventId;
  String? lastCoachingNote;
  String? lastCoachingFlagEventId;
  bool? lastCoachingFlag;

  _FakeEventRepository(List<Event> events) : _events = List.of(events);

  @override
  Future<Event> createEvent(Event event, List<EventPlayer> players) async =>
      event;

  @override
  Future<List<Event>> getEvents(String gameId) async =>
      _events.where((e) => e.gameId == gameId).toList();

  @override
  Future<Event?> getEvent(String id) async =>
      _events.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> updateEvent(Event event, List<EventPlayer> players) async {}

  @override
  Future<void> deleteEvent(String id) async {}

  @override
  Future<List<EventPlayer>> getPlayersForGame(String gameId) async => [];

  @override
  Future<void> updateCoachingNote(String eventId, String? note) async {
    lastCoachingNoteEventId = eventId;
    lastCoachingNote = note;
    // Zustand im internen Store aktualisieren
    final idx = _events.indexWhere((e) => e.id == eventId);
    if (idx >= 0) {
      final e = _events[idx];
      _events[idx] = Event(
        id: e.id,
        gameId: e.gameId,
        elapsedMs: e.elapsedMs,
        gamePhase: e.gamePhase,
        type: e.type,
        customTypeLabel: e.customTypeLabel,
        locationX: e.locationX,
        locationY: e.locationY,
        refDecision: e.refDecision,
        card: e.card,
        assessment: e.assessment,
        sceneNote: e.sceneNote,
        coachingFlag: e.coachingFlag,
        coachingNote: note,
        createdAt: e.createdAt,
      );
    }
  }

  @override
  Future<void> updateCoachingFlag(String eventId, bool flag) async {
    lastCoachingFlagEventId = eventId;
    lastCoachingFlag = flag;
    final idx = _events.indexWhere((e) => e.id == eventId);
    if (idx >= 0) {
      _events[idx] = _events[idx].copyWith(coachingFlag: flag);
    }
  }
}

class _FakeGameRepository implements GameRepository {
  String? lastCoachingNoteGameId;
  String? lastCoachingNote;

  @override
  Future<Game> createGame(Game game) async => game;

  @override
  Future<List<Game>> getGames() async => [];

  @override
  Future<Game?> getGame(String id) async => null;

  @override
  Future<void> updateGame(Game game) async {}

  @override
  Future<void> deleteGame(String id) async {}

  @override
  Future<void> updateCoachingNote(String gameId, String? note) async {
    lastCoachingNoteGameId = gameId;
    lastCoachingNote = note;
  }
  @override
  Future<void> updateKitColor(
    String gameId,
    TeamSide team,
    KitColor kit,
  ) async {}
}

// ── Hilfsfunktionen ───────────────────────────────────────────────────────────

const _gameId = 'g-test';

Game _testGame({String? coachingNote}) => Game(
      id: _gameId,
      date: DateTime(2026, 10, 1),
      homeTeamName: 'Heim',
      awayTeamName: 'Gast',
      createdAt: DateTime(2026, 10, 1),
      coachingNote: coachingNote,
    );

Event _testEvent({
  String id = 'e-1',
  bool coachingFlag = true,
  String? sceneNote,
  String? coachingNote,
  int elapsedMs = 15 * 60 * 1000,
}) =>
    Event(
      id: id,
      gameId: _gameId,
      elapsedMs: elapsedMs,
      type: EventType.footFoul,
      locationX: 0.5,
      locationY: 0.5,
      coachingFlag: coachingFlag,
      sceneNote: sceneNote,
      coachingNote: coachingNote,
      createdAt: DateTime(2026, 10, 1, 15),
    );

Widget _buildReviewApp({
  required Game game,
  required _FakeEventRepository eventRepo,
  required _FakeGameRepository gameRepo,
}) =>
    ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(eventRepo),
        gameRepositoryProvider.overrideWithValue(gameRepo),
      ],
      child: MaterialApp(
        home: ReviewScreen(game: game),
      ),
    );

Future<void> _goToCoachingTab(WidgetTester tester) async {
  await tester.tap(find.text('Coaching'));
  await tester.pumpAndSettle();
}

Finder _coachingNoteField() => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Coaching-Notiz …',
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Coaching-Notizen — Allgemeine Notiz (US-307)', () {
    testWidgets(
        'TC-3071: Allgemeine-Notiz-Sektion immer sichtbar, '
        'auch ohne Coaching-Szenen', (tester) async {
      // Kein Event mit coachingFlag=true
      final eventRepo = _FakeEventRepository([_testEvent(coachingFlag: false)]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      // Abschnitts-Label sichtbar
      expect(find.text('ALLGEMEINE NOTIZ'), findsOneWidget);

      // Leertext sichtbar
      expect(
        find.text('Noch keine Szenen für das Coaching markiert.'),
        findsOneWidget,
      );

      // Allgemeines Notiz-TextField vorhanden
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == 'Eröffnungsworte, allgemeines Fazit …',
        ),
        findsOneWidget,
      );
    });

    testWidgets('TC-3072: FocusLoss speichert allgemeine Notiz', (tester) async {
      final eventRepo = _FakeEventRepository([]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      final overallField = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == 'Eröffnungsworte, allgemeines Fazit …',
      );

      await tester.tap(overallField);
      await tester.pump();
      await tester.enterText(overallField, 'Guter Schiedsrichter');
      await tester.pump();

      // Fokus entfernen → Autosave auslösen
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      expect(gameRepo.lastCoachingNoteGameId, _gameId);
      expect(gameRepo.lastCoachingNote, 'Guter Schiedsrichter');
    });

    testWidgets('TC-3073: Leeres Feld + FocusLoss speichert null', (tester) async {
      final eventRepo = _FakeEventRepository([]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      final overallField = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == 'Eröffnungsworte, allgemeines Fazit …',
      );

      await tester.tap(overallField);
      await tester.pump();
      // Leeres Textfeld lassen
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      expect(gameRepo.lastCoachingNote, isNull);
    });

    testWidgets('TC-3074: Allgemeine Notiz aus Game vorausgefüllt', (tester) async {
      const savedNote = 'Vorhandene Notiz';
      final eventRepo = _FakeEventRepository([]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(coachingNote: savedNote), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      // Gespeicherte Notiz ist im TextField sichtbar
      expect(find.text(savedNote), findsOneWidget);
    });
  });

  group('Coaching-Notizen — Szenen-Coaching-Notizen (US-306)', () {
    testWidgets(
        'TC-3061: Szenennotiz mit Klemmbrett-Icon read-only angezeigt',
        (tester) async {
      final event = _testEvent(
        coachingFlag: true,
        sceneNote: 'Klare Fehlentscheidung',
      );
      final eventRepo = _FakeEventRepository([event]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      expect(find.text('Klare Fehlentscheidung'), findsOneWidget);
      expect(find.byIcon(Icons.sticky_note_2_outlined), findsOneWidget);
    });

    testWidgets(
        'TC-3062: Kein sceneNote → kein Klemmbrett-Icon', (tester) async {
      final event = _testEvent(coachingFlag: true, sceneNote: null);
      final eventRepo = _FakeEventRepository([event]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      expect(find.byIcon(Icons.sticky_note_2_outlined), findsNothing);
    });

    testWidgets(
        'TC-3063: FocusLoss auf Coaching-Notiz-Feld speichert Note',
        (tester) async {
      final event = _testEvent(coachingFlag: true);
      final eventRepo = _FakeEventRepository([event]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      await tester.tap(_coachingNoteField());
      await tester.pump();
      await tester.enterText(_coachingNoteField(), 'Super Leistung');
      await tester.pump();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      expect(eventRepo.lastCoachingNoteEventId, event.id);
      expect(eventRepo.lastCoachingNote, 'Super Leistung');
    });

    testWidgets(
        'TC-3064: Coaching-Notiz-Feld aus event.coachingNote vorausgefüllt',
        (tester) async {
      final event = _testEvent(
        coachingFlag: true,
        coachingNote: 'Gute Reaktion',
      );
      final eventRepo = _FakeEventRepository([event]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      // Vorhandene Coaching-Notiz im Textfeld sichtbar
      expect(find.text('Gute Reaktion'), findsOneWidget);
    });

    testWidgets(
        'TC-3065: Leeres Coaching-Notiz-Feld + FocusLoss → null gespeichert',
        (tester) async {
      final event = _testEvent(coachingFlag: true);
      final eventRepo = _FakeEventRepository([event]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      await tester.tap(_coachingNoteField());
      await tester.pump();
      // Feld bleibt leer
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      expect(eventRepo.lastCoachingNote, isNull);
    });

    testWidgets(
        'TC-3066: Stern-Tap entfernt Event aus Coaching-Ansicht',
        (tester) async {
      final event = _testEvent(coachingFlag: true);
      final eventRepo = _FakeEventRepository([event]);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      // Coaching-Item sichtbar (gefüllter Stern)
      expect(find.byIcon(Icons.star_rounded), findsWidgets);

      // Stern antippen → Flag entfernen
      await tester.tap(find.byIcon(Icons.star_rounded).first);
      await tester.pumpAndSettle();

      // Event aus Coaching-Liste entfernt
      expect(
        find.text('Noch keine Szenen für das Coaching markiert.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'TC-3068: Mehrere Coaching-Szenen chronologisch mit je einem '
        'Coaching-Notiz-Feld', (tester) async {
      final events = [
        _testEvent(id: 'e-1', elapsedMs: 10 * 60 * 1000, coachingFlag: true,
            sceneNote: 'Erster Foul'),
        _testEvent(id: 'e-2', elapsedMs: 25 * 60 * 1000, coachingFlag: true),
        _testEvent(id: 'e-3', elapsedMs: 40 * 60 * 1000, coachingFlag: true,
            sceneNote: 'Dritter Foul'),
      ];
      final eventRepo = _FakeEventRepository(events);
      final gameRepo = _FakeGameRepository();

      await tester.pumpWidget(
          _buildReviewApp(game: _testGame(), eventRepo: eventRepo, gameRepo: gameRepo));
      await tester.pumpAndSettle();
      await _goToCoachingTab(tester);

      // Alle drei Events erscheinen (an ihren Minuten erkennbar)
      expect(find.text("10'"), findsOneWidget);
      expect(find.text("25'"), findsOneWidget);
      expect(find.text("40'"), findsOneWidget);

      // Jedes Event hat ein Coaching-Notiz-Feld
      expect(_coachingNoteField(), findsNWidgets(3));

      // Events mit Szenennotiz zeigen Klemmbrett-Icon
      expect(find.byIcon(Icons.sticky_note_2_outlined), findsNWidgets(2));
    });
  });
}
