import '../entities/event.dart';
import '../entities/event_player.dart';

abstract class EventRepository {
  Future<Event> createEvent(Event event, List<EventPlayer> players);
  Future<List<Event>> getEvents(String gameId);
  Future<Event?> getEvent(String id);
  Future<void> updateEvent(Event event, List<EventPlayer> players);
  Future<void> deleteEvent(String id);
  Future<List<EventPlayer>> getPlayersForGame(String gameId);
}
