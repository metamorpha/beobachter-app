import '../enums/game_phase.dart';
import '../enums/goal_kind.dart';
import '../enums/team_side.dart';

/// Tor — eigenständig erfasst, ohne Ort und Bewertung (US-215).
class Goal {
  final String id;
  final String gameId;
  final int elapsedMs;
  final GamePhase gamePhase;

  /// Team, dem das Tor gutgeschrieben wird — auch beim Eigentor.
  final TeamSide team;

  /// Rückennummer des Torschützen — optional. Beim Eigentor ein Spieler
  /// der verteidigenden Mannschaft ([scorerTeam]).
  final int? scorerNumber;

  final GoalKind kind;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.gameId,
    required this.elapsedMs,
    this.gamePhase = GamePhase.ersteHalbzeit,
    required this.team,
    this.scorerNumber,
    this.kind = GoalKind.regular,
    required this.createdAt,
  });

  /// Team des Torschützen: beim Eigentor die verteidigende Mannschaft.
  TeamSide get scorerTeam => kind == GoalKind.ownGoal ? team.opponent : team;

  /// Phasenbewusster Zeitstempel-String, z. B. "23:45", "45+02".
  String get elapsedLabel => GamePhaseX.formatMs(elapsedMs, gamePhase);
}
