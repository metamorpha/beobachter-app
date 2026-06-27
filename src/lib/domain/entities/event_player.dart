import '../enums/player_role.dart';
import '../enums/team_side.dart';

class EventPlayer {
  final String id;
  final String eventId;
  final PlayerRole role;
  final TeamSide team;
  final int jerseyNumber;

  const EventPlayer({
    required this.id,
    required this.eventId,
    required this.role,
    required this.team,
    required this.jerseyNumber,
  });
}
