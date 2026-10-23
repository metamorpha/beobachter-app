import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/event_player.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/enums/player_role.dart';
import 'package:beobachter_app/domain/enums/team_side.dart';
import 'package:beobachter_app/domain/repositories/event_repository.dart';
import 'package:beobachter_app/domain/repositories/timer_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/live/event_form_panel.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeTimerRepository implements TimerRepository {
  final Map<String, TimerState> _states = {};
  final _controller = StreamController<void>.broadcast();

  @override
  Future<TimerState?> getTimerState(String gameId) async => _states[gameId];

  @override
  Future<void> saveTimerState(TimerState state) async {
    _states[state.gameId] = state;
    _controller.add(null);
  }

  @override
  Stream<TimerState?> watchTimerState(String gameId) async* {
    yield _states[gameId];
    await for (final _ in _controller.stream) {
      yield _states[gameId];
    }
  }
}

class _FakeEventRepository implements EventRepository {
  final List<Event> _events = [];
  Event? lastCreated;
  Event? lastUpdated;
  List<EventPlayer> lastPlayers = [];

  @override
  Future<Event> createEvent(Event event, List<EventPlayer> players) async {
    final saved = Event(
      id: 'e-${_events.length + 1}',
      gameId: event.gameId,
      elapsedMs: event.elapsedMs,
      gamePhase: event.gamePhase,
      type: event.type,
      customTypeLabel: event.customTypeLabel,
      locationX: event.locationX,
      locationY: event.locationY,
      refDecision: event.refDecision,
      card: event.card,
      assessment: event.assessment,
      sceneNote: event.sceneNote,
      coachingFlag: event.coachingFlag,
      coachingNote: event.coachingNote,
      createdAt: event.createdAt,
    );
    _events.add(saved);
    lastCreated = saved;
    lastPlayers = players;
    return saved;
  }

  @override
  Future<List<Event>> getEvents(String gameId) async =>
      _events.where((e) => e.gameId == gameId).toList();

  @override
  Future<Event?> getEvent(String id) async =>
      _events.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> updateEvent(Event event, List<EventPlayer> players) async {
    lastUpdated = event;
    lastPlayers = players;
  }

  @override
  Future<void> deleteEvent(String id) async {}

  @override
  Future<List<EventPlayer>> getPlayersForGame(String gameId) async => [];

  @override
  Future<void> updateCoachingNote(String eventId, String? note) async {}

  @override
  Future<void> updateCoachingFlag(String eventId, bool flag) async {}
}

// ── Hilfsfunktionen ───────────────────────────────────────────────────────────

const _gameId = 'g-test';

Widget _buildPanelApp({
  required _FakeTimerRepository timerRepo,
  required _FakeEventRepository eventRepo,
  Event? initialEvent,
  List<EventPlayer> initialPlayers = const [],
  void Function(Event)? onSaved,
}) =>
    ProviderScope(
      overrides: [
        timerRepositoryProvider.overrideWithValue(timerRepo),
        eventRepositoryProvider.overrideWithValue(eventRepo),
        homeSquadProvider(_gameId).overrideWith((_) async => []),
        awaySquadProvider(_gameId).overrideWith((_) async => []),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: EventFormPanel(
            gameId: _gameId,
            locationX: 0.5,
            locationY: 0.5,
            onClose: () {},
            onSaved: onSaved ?? (_) {},
            initialEvent: initialEvent,
            initialPlayers: initialPlayers,
          ),
        ),
      ),
    );

/// Variante mit Prewarmer: TimerState ist geladen, bevor EventFormPanel sein
/// initState ausführt — notwendig für Zeitstempel-Tests (TC-EFR-02).
Widget _buildPanelWithPreloadedTimer({
  required _FakeTimerRepository timerRepo,
  required _FakeEventRepository eventRepo,
  void Function(Event)? onSaved,
}) =>
    ProviderScope(
      overrides: [
        timerRepositoryProvider.overrideWithValue(timerRepo),
        eventRepositoryProvider.overrideWithValue(eventRepo),
        homeSquadProvider(_gameId).overrideWith((_) async => []),
        awaySquadProvider(_gameId).overrideWith((_) async => []),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              final timerAsync = ref.watch(timerStateProvider(_gameId));
              return timerAsync.when(
                data: (_) => EventFormPanel(
                  gameId: _gameId,
                  locationX: 0.5,
                  locationY: 0.5,
                  onClose: () {},
                  onSaved: onSaved ?? (_) {},
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Text('Fehler: $e'),
              );
            },
          ),
        ),
      ),
    );

Event _existingEvent({
  EventType type = EventType.footFoul,
  bool coachingFlag = false,
}) =>
    Event(
      id: 'e-existing',
      gameId: _gameId,
      elapsedMs: 5 * 60 * 1000,
      type: type,
      locationX: 0.5,
      locationY: 0.5,
      coachingFlag: coachingFlag,
      createdAt: DateTime(2026, 10, 1),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('EventFormPanel — Progressive Disclosure (US-EFR)', () {
    testWidgets(
        'TC-EFR-01: Vor Typ-Auswahl nur Typ-Grid sichtbar, Save inaktiv',
        (tester) async {
      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: _FakeEventRepository(),
      ));
      await tester.pump();

      // Alle 9 Typ-Chips sind vorhanden
      for (final t in EventType.values) {
        expect(find.byKey(Key('event_type_${t.name}')), findsOneWidget,
            reason: 'Typ-Chip $t fehlt');
      }

      // Platzhaltertext sichtbar
      expect(find.text('Typ auswählen, dann speichern'), findsOneWidget);

      // Entscheidungs- und Karten-Chips NICHT sichtbar
      expect(find.byKey(const Key('decision_freeKick')), findsNothing);
      expect(find.byKey(const Key('card_yellow')), findsNothing);

      // Spieler-Sektion NICHT sichtbar
      expect(find.text('SPIELER'), findsNothing);

      // Speichern-Button inaktiv (onPressed == null)
      final btn = tester
          .widget<FilledButton>(find.byKey(const Key('btn_save_event')));
      expect(btn.onPressed, isNull);
    });

    testWidgets('TC-EFR-02: Zeitstempel wird beim Öffnen eingefroren',
        (tester) async {
      final timerRepo = _FakeTimerRepository();
      const elapsedMs = 47 * 60 * 1000 + 23 * 1000; // 47:23
      await timerRepo.saveTimerState(TimerState(
        gameId: _gameId,
        isRunning: false,
        elapsedMs: elapsedMs,
        phase: GamePhase.ersteHalbzeit,
      ));

      Event? savedEvent;
      await tester.pumpWidget(_buildPanelWithPreloadedTimer(
        timerRepo: timerRepo,
        eventRepo: _FakeEventRepository(),
        onSaved: (e) => savedEvent = e,
      ));

      // Prewarmer zeigt SizedBox bis Timer geladen → eine Runde pumpen
      await tester.pump();

      // Header zeigt den eingefrorenen Zeitpunkt
      expect(find.text('47:23'), findsOneWidget);

      // Typ auswählen und speichern
      await tester.tap(find.byKey(const Key('event_type_offside')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pump();

      // Gespeichertes Event hat den eingefrorenen Zeitstempel
      expect(savedEvent?.elapsedMs, elapsedMs);
    });

    testWidgets(
        'TC-EFR-03: Nach Typ-Auswahl erscheinen Felder, Spieler-Sektion '
        'bei Abseits nicht', (tester) async {
      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: _FakeEventRepository(),
      ));
      await tester.pump();

      await tester.tap(find.byKey(const Key('event_type_offside')));
      await tester.pumpAndSettle();

      // Entscheidungs-Chips erscheinen
      expect(find.byKey(const Key('decision_freeKick')), findsOneWidget);

      // Karten-Chips erscheinen
      expect(find.byKey(const Key('card_yellow')), findsOneWidget);

      // Spieler-Sektion erscheint NICHT (Abseits ist kein Foul-Typ)
      expect(find.text('SPIELER'), findsNothing);

      // Platzhaltertext weg
      expect(find.text('Typ auswählen, dann speichern'), findsNothing);

      // Speichern-Button aktiv
      final btn = tester
          .widget<FilledButton>(find.byKey(const Key('btn_save_event')));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('TC-EFR-04: Spieler-Sektion nur bei Foul-Typen', (tester) async {
      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: _FakeEventRepository(),
      ));
      await tester.pump();

      const foulTypes = [
        EventType.footFoul,
        EventType.bodyFoul,
        EventType.handball,
        EventType.unsporting,
        EventType.violent,
      ];

      for (final foulType in foulTypes) {
        await tester.tap(find.byKey(Key('event_type_${foulType.name}')));
        await tester.pumpAndSettle();
        expect(find.text('SPIELER'), findsOneWidget,
            reason: '$foulType sollte Spieler-Sektion zeigen');

        // Typ abwählen für nächste Iteration
        await tester.tap(find.byKey(Key('event_type_${foulType.name}')));
        await tester.pumpAndSettle();
      }

      // Nicht-Foul-Typ: kein Spieler-Bereich
      await tester.tap(find.byKey(const Key('event_type_offside')));
      await tester.pumpAndSettle();
      expect(find.text('SPIELER'), findsNothing);
    });

    testWidgets('TC-EFR-05: Coaching-Stern togglet hollow ↔ amber',
        (tester) async {
      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: _FakeEventRepository(),
      ));
      await tester.pump();

      // Typ auswählen, damit _buildFields() gerendert wird
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();

      // Anfangs hohl
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);

      // Tap → gefüllt (seit US-603 größere Felder: Stern ggf. erst scrollen)
      await tester.ensureVisible(find.byIcon(Icons.star_outline_rounded));
      await tester.tap(find.byIcon(Icons.star_outline_rounded));
      await tester.pump();
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsNothing);

      // Nochmal tap → hohl
      await tester.tap(find.byIcon(Icons.star_rounded));
      await tester.pump();
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    });

    testWidgets('TC-EFR-06: Gespeichertes Event hat coachingFlag == true',
        (tester) async {
      final eventRepo = _FakeEventRepository();
      Event? savedEvent;

      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: eventRepo,
        onSaved: (e) => savedEvent = e,
      ));
      await tester.pump();

      await tester.tap(find.byKey(const Key('event_type_offside')));
      await tester.pumpAndSettle();

      // Coaching-Stern aktivieren
      await tester.tap(find.byIcon(Icons.star_outline_rounded));
      await tester.pump();

      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pump();

      expect(savedEvent?.coachingFlag, isTrue);
    });

    testWidgets('TC-EFR-07: Edit-Modus: Coaching-Stern aus initialEvent vorbelegt',
        (tester) async {
      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: _FakeEventRepository(),
        initialEvent: _existingEvent(coachingFlag: true),
      ));
      await tester.pump();

      // Stern ist bereits gefüllt (coachingFlag == true)
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    });

    testWidgets(
        'TC-EFR-08: Edit-Modus: Spieler aus initialPlayers in State vorbelegt',
        (tester) async {
      final eventRepo = _FakeEventRepository();

      final fouler = EventPlayer(
        id: 'ep-1',
        eventId: 'e-existing',
        role: PlayerRole.fouler,
        team: TeamSide.home,
        jerseyNumber: 7,
      );

      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: eventRepo,
        initialEvent: _existingEvent(),
        initialPlayers: [fouler],
      ));
      await tester.pump();

      // Im Edit-Modus ist footFoul bereits ausgewählt → Save aktiv
      final btn = tester
          .widget<FilledButton>(find.byKey(const Key('btn_save_event')));
      expect(btn.onPressed, isNotNull);

      // Speichern: Spieler müssen aus initialPlayers übernommen worden sein
      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pump();

      expect(
        eventRepo.lastPlayers.any(
          (p) =>
              p.role == PlayerRole.fouler &&
              p.jerseyNumber == 7 &&
              p.team == TeamSide.home,
        ),
        isTrue,
        reason: 'Fouler aus initialPlayers muss beim Speichern erhalten bleiben',
      );
    });

    testWidgets(
        'TC-EFR-12: Typ-Wechsel setzt Entscheidung und Karte zurück',
        (tester) async {
      final eventRepo = _FakeEventRepository();
      Event? savedEvent;

      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: eventRepo,
        onSaved: (e) => savedEvent = e,
      ));
      await tester.pump();

      // footFoul auswählen, Entscheidung setzen
      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('decision_freeKick')));
      await tester.pump();

      // Auf Abseits wechseln → Entscheidung und Karte werden zurückgesetzt
      await tester.tap(find.byKey(const Key('event_type_offside')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pump();

      expect(savedEvent?.refDecision, isNull,
          reason: 'Entscheidung muss nach Typ-Wechsel null sein');
      expect(savedEvent?.card, isNull,
          reason: 'Karte muss nach Typ-Wechsel null sein');
    });

    testWidgets(
        'TC-EFR-13: Minimal-Pfad (Typ → Speichern) erstellt Event mit Defaults',
        (tester) async {
      final eventRepo = _FakeEventRepository();
      Event? savedEvent;

      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: eventRepo,
        onSaved: (e) => savedEvent = e,
      ));
      await tester.pump();

      // Nur Typ auswählen, sonst nichts
      await tester.tap(find.byKey(const Key('event_type_advantage')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pump();

      expect(savedEvent, isNotNull);
      expect(savedEvent?.type, EventType.advantage);
      expect(savedEvent?.refDecision, isNull);
      expect(savedEvent?.card, isNull);
      expect(savedEvent?.assessment, isNull);
      expect(savedEvent?.sceneNote, isNull);
      expect(savedEvent?.coachingFlag, isFalse);
    });
  });

  group('US-404: Team ohne Rückennummer', () {
    testWidgets('TC-4050: Täter-Team ohne Rückennummer wird gespeichert',
        (tester) async {
      final eventRepo = _FakeEventRepository();

      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: eventRepo,
      ));
      await tester.pump();

      await tester.tap(find.byKey(const Key('event_type_footFoul')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('fouler_team_away')));
      await tester.tap(find.byKey(const Key('fouler_team_away')));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('btn_save_event')));
      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pump();

      final fouler = eventRepo.lastPlayers
          .where((p) => p.role == PlayerRole.fouler)
          .single;
      expect(fouler.team, TeamSide.away);
      expect(fouler.jerseyNumber, isNull);
    });

    testWidgets('TC-4050: Team ohne Nummer ist beim erneuten Öffnen gewählt',
        (tester) async {
      final eventRepo = _FakeEventRepository();

      await tester.pumpWidget(_buildPanelApp(
        timerRepo: _FakeTimerRepository(),
        eventRepo: eventRepo,
        initialEvent: _existingEvent(),
        initialPlayers: const [
          EventPlayer(
            id: 'ep-1',
            eventId: 'e-existing',
            role: PlayerRole.fouler,
            team: TeamSide.away,
          ),
        ],
      ));
      await tester.pump();

      await tester.tap(find.byKey(const Key('btn_save_event')));
      await tester.pump();

      final fouler = eventRepo.lastPlayers
          .where((p) => p.role == PlayerRole.fouler)
          .single;
      expect(fouler.team, TeamSide.away);
      expect(fouler.jerseyNumber, isNull);
    });
  });
}
