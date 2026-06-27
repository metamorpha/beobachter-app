import 'package:flutter_test/flutter_test.dart';

import 'package:beobachter_app/domain/entities/event.dart';
import 'package:beobachter_app/domain/enums/event_type.dart';

void main() {
  group('Event', () {
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

    test('elapsedLabel formatiert korrekt', () {
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
  });
}
