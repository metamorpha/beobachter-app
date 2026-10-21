import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/entities/game.dart';
import 'package:beobachter_app/domain/entities/timer_state.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';
import 'package:beobachter_app/domain/repositories/event_repository.dart';
import 'package:beobachter_app/domain/repositories/timer_repository.dart';
import 'package:beobachter_app/presentation/providers/providers.dart';
import 'package:beobachter_app/presentation/screens/live/live_screen.dart';

/// In-Memory-Repository für Widget-Tests: persistiert und streamt TimerStates.
class FakeTimerRepository implements TimerRepository {
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

/// In-Memory-EventRepository: nur getEvents/deleteEvent werden benötigt.
class FakeEventRepository implements EventRepository {
  final List<Event> events;
  final List<String> deletedIds = [];

  FakeEventRepository(this.events);

  @override
  Future<List<Event>> getEvents(String gameId) async =>
      events.where((e) => e.gameId == gameId).toList();

  @override
  Future<void> deleteEvent(String id) async {
    deletedIds.add(id);
    events.removeWhere((e) => e.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Game _game(String id) => Game(
      id: id,
      date: DateTime(2026, 7, 1),
      homeTeamName: 'Heim',
      awayTeamName: 'Gast',
      createdAt: DateTime(2026, 7, 1),
    );

Event _event(int i,
        {EventType type = EventType.footFoul,
        int? minute,
        GamePhase phase = GamePhase.ersteHalbzeit}) =>
    Event(
      id: 'e$i',
      gameId: 'g1',
      elapsedMs: (minute ?? i) * 60 * 1000,
      gamePhase: phase,
      type: type,
      locationX: 0.5,
      locationY: 0.5,
      createdAt: DateTime(2026, 7, 1),
    );

List<Event> _events(int n) => [for (var i = 0; i < n; i++) _event(i)];

Future<FakeEventRepository> _pumpLive(
  WidgetTester tester,
  List<Event> events, {
  Size size = const Size(1280, 1000),
  GamePhase phase = GamePhase.halbzeit,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final timerRepo = FakeTimerRepository();
  await timerRepo.saveTimerState(TimerState(
    gameId: 'g1',
    isRunning: false,
    elapsedMs: 45 * 60 * 1000,
    phase: phase,
  ));
  final eventRepo = FakeEventRepository(events);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      timerRepositoryProvider.overrideWithValue(timerRepo),
      eventRepositoryProvider.overrideWithValue(eventRepo),
    ],
    child: MaterialApp(home: LiveScreen(game: _game('g1'))),
  ));
  await tester.pumpAndSettle();
  return eventRepo;
}

/// Anzahl der Zeilen, die vollständig im sichtbaren Bereich der Liste liegen.
int _visibleRows(WidgetTester tester, int total) {
  final listRect =
      tester.getRect(find.byKey(const Key('recent_events_list')));
  var count = 0;
  for (var i = 0; i < total; i++) {
    final row = find.byKey(Key('recent_event_e$i'));
    if (row.evaluate().isEmpty) continue;
    final r = tester.getRect(row);
    if (r.top >= listRect.top && r.bottom <= listRect.bottom) count++;
  }
  return count;
}

void main() {
  group('Länge der Liste (US-213)', () {
    testWidgets('TC-2131: Mehr als 5 Ereignisse auf hohem Bildschirm sichtbar',
        (tester) async {
      await _pumpLive(tester, _events(20));

      expect(_visibleRows(tester, 20), greaterThan(5));
    });

    testWidgets('TC-2132: Anzahl sichtbarer Zeilen wächst mit Bildschirmhöhe',
        (tester) async {
      await _pumpLive(tester, _events(30), size: const Size(1280, 600));
      final small = _visibleRows(tester, 30);

      await _pumpLive(tester, _events(30), size: const Size(1280, 1200));
      final large = _visibleRows(tester, 30);

      expect(large, greaterThan(small));
    });

    testWidgets('TC-2133: Liste scrollbar, Überschrift bleibt fix',
        (tester) async {
      await _pumpLive(tester, _events(30), size: const Size(1280, 600));

      // Ältestes Ereignis (e0) steht ganz unten → anfangs nicht gebaut
      expect(find.byKey(const Key('recent_event_e0')), findsNothing);

      await tester.scrollUntilVisible(
        find.byKey(const Key('recent_event_e0')),
        200,
        scrollable: find.descendant(
          of: find.byKey(const Key('recent_events_list')),
          matching: find.byType(Scrollable),
        ),
      );

      expect(find.byKey(const Key('recent_event_e0')), findsOneWidget);
      expect(find.text('Letzte Ereignisse'), findsOneWidget);
    });

    testWidgets('TC-2134: Neuestes Ereignis steht oben', (tester) async {
      await _pumpLive(tester, [
        _event(0, type: EventType.offside, minute: 5),
        _event(1, type: EventType.handball, minute: 10),
        _event(2, type: EventType.footFoul, minute: 15),
      ]);

      final y0 = tester.getTopLeft(find.text('Fußvergehen')).dy;
      final y1 = tester.getTopLeft(find.text('Handspiel')).dy;
      final y2 = tester.getTopLeft(find.text('Abseits')).dy;
      expect(y0, lessThan(y1));
      expect(y1, lessThan(y2));
    });

    testWidgets('TC-2135: Leere Liste ohne Layout-Fehler', (tester) async {
      await _pumpLive(tester, []);

      expect(find.text('Letzte Ereignisse'), findsOneWidget);
      expect(find.byKey(const Key('recent_events_list')), findsOneWidget);
      expect(find.byTooltip('Löschen'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Zeilengröße / Fehltipp-Schutz (US-213)', () {
    testWidgets('TC-2136: Zeilen min. 44 dp hoch, Schrift 14, Trennlinie',
        (tester) async {
      await _pumpLive(tester, _events(3));

      for (var i = 0; i < 3; i++) {
        expect(
            tester.getSize(find.byKey(Key('recent_event_e$i'))).height,
            greaterThanOrEqualTo(44));
      }
      final label = tester.widget<Text>(find.text('Fußvergehen').first);
      expect(label.style?.fontSize, 14);

      final separators = find.descendant(
        of: find.byKey(const Key('recent_events_list')),
        matching: find.byType(Divider),
      );
      expect(separators, findsNWidgets(2));
    });

    testWidgets('TC-2137: Lösch-Button Tippfläche ≥ 44 × 44 dp, Icon 22 dp',
        (tester) async {
      await _pumpLive(tester, _events(1));

      final button = find.byTooltip('Löschen');
      final size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));

      final icon = tester.widget<Icon>(find.byIcon(Icons.delete_outline));
      expect(icon.size, 22);
    });

    testWidgets('TC-2138: Langes Label wird ohne Overflow gekürzt',
        (tester) async {
      await _pumpLive(tester, [
        Event(
          id: 'e0',
          gameId: 'g1',
          elapsedMs: 47 * 60 * 1000,
          gamePhase: GamePhase.ersteHalbzeitNachspielzeit,
          type: EventType.bodyFoul,
          locationX: 0.5,
          locationY: 0.5,
          createdAt: DateTime(2026, 7, 1),
        ),
      ]);

      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Löschen'), findsOneWidget);
    });
  });

  group('Bestehendes Verhalten (US-213)', () {
    testWidgets('TC-2139: Löschen entfernt Zeile sofort', (tester) async {
      final repo = await _pumpLive(tester, _events(3));

      await tester.tap(find.byTooltip('Löschen').first);
      await tester.pumpAndSettle();

      expect(repo.deletedIds, ['e2']);
      expect(find.byTooltip('Löschen'), findsNWidgets(2));
      expect(find.byKey(const Key('recent_event_e2')), findsNothing);
    });

    testWidgets('TC-2140: Liste im abgeschlossenen Spiel sichtbar',
        (tester) async {
      await _pumpLive(tester, _events(8), phase: GamePhase.abgeschlossen);

      expect(find.text('Letzte Ereignisse'), findsOneWidget);
      expect(_visibleRows(tester, 8), 8);
    });
  });
}
