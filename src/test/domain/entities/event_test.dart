import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';
import 'package:beobachter_app/domain/enums/game_phase.dart';

void main() {
  group('Event — Basisfunktionen', () {
    late Event event;

    setUp(() {
      event = Event(
        id: 'e-1',
        gameId: 'g-1',
        elapsedMs: 2723000, // 45 Min 23 Sek
        type: EventType.footFoul,
        locationX: 0.5,
        locationY: 0.5,
        createdAt: DateTime(2026, 4, 30),
      );
    });

    test('elapsedLabel formatiert reguläre Zeit korrekt', () {
      expect(event.elapsedLabel, '45:23');
    });

    test('elapsedLabel padded korrekt bei einstelligen Werten', () {
      final e = event.copyWith(elapsedMs: 65000); // 1:05
      expect(e.elapsedLabel, '01:05');
    });

    test('minute gibt korrekte Spielminute zurück', () {
      expect(event.minute, 45);
    });

    test('copyWith ändert nur angegebene Felder', () {
      final updated = event.copyWith(elapsedMs: 3000);
      expect(updated.id, 'e-1');
      expect(updated.gameId, 'g-1');
      expect(updated.elapsedMs, 3000);
      expect(updated.type, EventType.footFoul);
    });

    test('coachingFlag ist standardmäßig false', () {
      expect(event.coachingFlag, false);
    });

    test('gamePhase ist standardmäßig ersteHalbzeit', () {
      expect(event.gamePhase, GamePhase.ersteHalbzeit);
    });
  });

  group('Event — phasenbewusste elapsedLabel', () {
    test('1. HZ Nachspielzeit: 45+XX Format', () {
      final e = Event(
        id: 'e-2',
        gameId: 'g-1',
        elapsedMs: 46 * 60000, // 46 Min = 45+02
        gamePhase: GamePhase.ersteHalbzeitNachspielzeit,
        type: EventType.footFoul,
        locationX: 0.5,
        locationY: 0.5,
        createdAt: DateTime(2026, 4, 30),
      );
      expect(e.elapsedLabel, '45+02');
    });

    test('2. HZ Nachspielzeit: 90+XX Format', () {
      final e = Event(
        id: 'e-3',
        gameId: 'g-1',
        elapsedMs: 91 * 60000, // 91 Min = 90+02
        gamePhase: GamePhase.zweiteHalbzeitNachspielzeit,
        type: EventType.footFoul,
        locationX: 0.5,
        locationY: 0.5,
        createdAt: DateTime(2026, 4, 30),
      );
      expect(e.elapsedLabel, '90+02');
    });

    test('VL 1. HZ Nachspielzeit: 105+XX Format', () {
      final e = Event(
        id: 'e-4',
        gameId: 'g-1',
        elapsedMs: 107 * 60000, // 107 Min = 105+03
        gamePhase: GamePhase.verlaengerungErsteHalbzeitNachspielzeit,
        type: EventType.footFoul,
        locationX: 0.5,
        locationY: 0.5,
        createdAt: DateTime(2026, 4, 30),
      );
      expect(e.elapsedLabel, '105+03');
    });

    test('VL 2. HZ Nachspielzeit: 120+XX Format', () {
      final e = Event(
        id: 'e-5',
        gameId: 'g-1',
        elapsedMs: 121 * 60000, // 121 Min = 120+02
        gamePhase: GamePhase.verlaengerungZweiteHalbzeitNachspielzeit,
        type: EventType.footFoul,
        locationX: 0.5,
        locationY: 0.5,
        createdAt: DateTime(2026, 4, 30),
      );
      expect(e.elapsedLabel, '120+02');
    });

    test('exakt 45:00 Nachspielzeit ergibt 45+01', () {
      final e = Event(
        id: 'e-6',
        gameId: 'g-1',
        elapsedMs: 45 * 60000,
        gamePhase: GamePhase.ersteHalbzeitNachspielzeit,
        type: EventType.footFoul,
        locationX: 0.5,
        locationY: 0.5,
        createdAt: DateTime(2026, 4, 30),
      );
      expect(e.elapsedLabel, '45+01');
    });

    test('2. HZ reguläre Zeit zeigt MM:SS', () {
      final e = Event(
        id: 'e-7',
        gameId: 'g-1',
        elapsedMs: 67 * 60000 + 12 * 1000, // 67:12
        gamePhase: GamePhase.zweiteHalbzeit,
        type: EventType.footFoul,
        locationX: 0.5,
        locationY: 0.5,
        createdAt: DateTime(2026, 4, 30),
      );
      expect(e.elapsedLabel, '67:12');
    });

    test('copyWith überträgt gamePhase', () {
      final e = Event(
        id: 'e-8',
        gameId: 'g-1',
        elapsedMs: 46 * 60000,
        gamePhase: GamePhase.ersteHalbzeitNachspielzeit,
        type: EventType.footFoul,
        locationX: 0.5,
        locationY: 0.5,
        createdAt: DateTime(2026, 4, 30),
      );
      final updated = e.copyWith(type: EventType.handball);
      expect(updated.gamePhase, GamePhase.ersteHalbzeitNachspielzeit);
    });
  });
}
