import '../enums/team_side.dart';
import 'goal.dart';

/// Spielstand — immer aus den Toren abgeleitet, nie gespeichert (US-215).
class Score {
  final int home;
  final int away;

  const Score(this.home, this.away);

  static const zero = Score(0, 0);

  Score plus(TeamSide team) =>
      team == TeamSide.home ? Score(home + 1, away) : Score(home, away + 1);

  /// Endstand über alle Tore.
  factory Score.fromGoals(List<Goal> goals) {
    var score = Score.zero;
    for (final g in goals) {
      score = score.plus(g.team);
    }
    return score;
  }

  /// Spielstand nach jedem Tor, nach Tor-ID.
  /// Sortiert nach Phase, dann Zeit — Nachspielzeit der 1. HZ liegt zeitlich
  /// vor der 2. HZ, obwohl ihr elapsedMs größer ist.
  static Map<String, Score> runningByGoalId(List<Goal> goals) {
    final sorted = [...goals]..sort((a, b) {
        final byPhase = a.gamePhase.index.compareTo(b.gamePhase.index);
        return byPhase != 0 ? byPhase : a.elapsedMs.compareTo(b.elapsedMs);
      });
    final result = <String, Score>{};
    var score = Score.zero;
    for (final g in sorted) {
      score = score.plus(g.team);
      result[g.id] = score;
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
