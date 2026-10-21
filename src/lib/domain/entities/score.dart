import '../enums/team_side.dart';
import 'event.dart';

/// Spielstand — immer aus den Ereignissen abgeleitet, nie gespeichert (US-214).
class Score {
  final int home;
  final int away;

  const Score(this.home, this.away);

  static const zero = Score(0, 0);

  Score plus(TeamSide team) =>
      team == TeamSide.home ? Score(home + 1, away) : Score(home, away + 1);

  /// Endstand über alle Ereignisse.
  factory Score.fromEvents(List<Event> events) {
    var score = Score.zero;
    for (final e in events) {
      final team = e.goalForTeam;
      if (team != null) score = score.plus(team);
    }
    return score;
  }

  /// Spielstand nach jedem gezählten Tor, nach Event-ID.
  /// Sortiert nach Phase, dann Zeit — Nachspielzeit der 1. HZ liegt zeitlich
  /// vor der 2. HZ, obwohl ihr elapsedMs größer ist.
  static Map<String, Score> runningByEventId(List<Event> events) {
    final sorted = [...events]..sort((a, b) {
        final byPhase = a.gamePhase.index.compareTo(b.gamePhase.index);
        return byPhase != 0 ? byPhase : a.elapsedMs.compareTo(b.elapsedMs);
      });
    final result = <String, Score>{};
    var score = Score.zero;
    for (final e in sorted) {
      final team = e.goalForTeam;
      if (team == null) continue;
      score = score.plus(team);
      result[e.id] = score;
    }
    return result;
  }

  /// Format für die Kopfzeile, z. B. „2 : 1".
  String get label => '$home : $away';

  /// Kompaktformat für Listen, z. B. „2:1".
  String get shortLabel => '$home:$away';

  @override
  bool operator ==(Object other) =>
      other is Score && other.home == home && other.away == away;

  @override
  int get hashCode => Object.hash(home, away);

  @override
  String toString() => 'Score($home:$away)';
}
