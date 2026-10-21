import '../entities/event.dart';
import '../entities/event_player.dart';

abstract class EventRepository {
  Future<Event> createEvent(Event event, List<EventPlayer> players);
  Future<List<Event>> getEvents(String gameId);
  Future<Event?> getEvent(String id);
  Future<void> updateEvent(Event event, List<EventPlayer> players);
  Future<void> deleteEvent(String id);
  Future<List<EventPlayer>> getPlayersForGame(String gameId);

  /// Aktualisiert nur die Coaching-Notiz — lässt Spieler-Zuordnungen unberührt.
  Future<void> updateCoachingNote(String eventId, String? note);

  /// Aktualisiert nur das Coaching-Flag — lässt Spieler-Zuordnungen unberührt.
  Future<void> updateCoachingFlag(String eventId, bool flag);
}
