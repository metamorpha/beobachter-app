import '../enums/event_type.dart';
import '../enums/game_phase.dart';
import '../enums/player_role.dart';
import '../enums/team_side.dart';
import 'event.dart';
import 'event_player.dart';

/// Zeilen der Tabelle „Vergehen pro Team" (US-404).
enum FoulCategory { foot, body, other }

/// Spaltengruppen: 1. HZ, 2. HZ, Verlängerung — Nachspielzeit inklusive.
enum FoulPeriod { first, second, extraTime }

extension FoulCategoryX on FoulCategory {
  String get label => switch (this) {
        FoulCategory.foot => 'Fußvergehen',
        FoulCategory.body => 'Oberkörperv.',
        FoulCategory.other => 'Andere',
      };

  /// Kategorie eines Ereignistyps — null für Abseits und Vorteil.
  static FoulCategory? of(EventType type) => switch (type) {
        EventType.footFoul => FoulCategory.foot,
        EventType.bodyFoul => FoulCategory.body,
        EventType.handball ||
        EventType.unsporting ||
        EventType.violent ||
        EventType.custom =>
          FoulCategory.other,
        EventType.offside ||
        EventType.advantage => null,
      };
}

extension FoulPeriodX on FoulPeriod {
  String get label => switch (this) {
        FoulPeriod.first => '1. HZ',
        FoulPeriod.second => '2. HZ',
        FoulPeriod.extraTime => 'Verl.',
      };

  static FoulPeriod of(GamePhase phase) => switch (phase) {
        GamePhase.bereit ||
        GamePhase.ersteHalbzeit ||
        GamePhase.ersteHalbzeitNachspielzeit ||
        GamePhase.halbzeit =>
          FoulPeriod.first,
        GamePhase.zweiteHalbzeit ||
        GamePhase.zweiteHalbzeitNachspielzeit ||
        GamePhase.beendet ||
        GamePhase.abgeschlossen =>
          FoulPeriod.second,
        GamePhase.verlaengerungErsteHalbzeit ||
        GamePhase.verlaengerungErsteHalbzeitNachspielzeit ||
        GamePhase.verlaengerungHalbzeit ||
        GamePhase.verlaengerungZweiteHalbzeit ||
        GamePhase.verlaengerungZweiteHalbzeitNachspielzeit ||
        GamePhase.beendetVerlaengerung =>
          FoulPeriod.extraTime,
      };
}

/// Vergehen pro Team und Halbzeit — immer aus Ereignissen abgeleitet.
/// Zugeordnet wird über das Team des Täters (Fouler); Ereignisse ohne
/// Täter-Team zählen nicht.
class TeamFouls {
  final Map<(FoulPeriod, TeamSide, FoulCategory), int> _counts;

  /// true, sobald irgendein Ereignis in der Verlängerung erfasst wurde.
  final bool hasExtraTime;

  const TeamFouls._(this._counts, this.hasExtraTime);

  factory TeamFouls.fromEvents(List<Event> events, List<EventPlayer> players) {
    final foulerTeam = <String, TeamSide>{
      for (final p in players)
        if (p.role == PlayerRole.fouler) p.eventId: p.team,
    };
    final counts = <(FoulPeriod, TeamSide, FoulCategory), int>{};
    var hasExtraTime = false;
    for (final e in events) {
      final period = FoulPeriodX.of(e.gamePhase);
      if (period == FoulPeriod.extraTime) hasExtraTime = true;
      final category = FoulCategoryX.of(e.type);
      final team = foulerTeam[e.id];
      if (category == null || team == null) continue;
      final key = (period, team, category);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return TeamFouls._(counts, hasExtraTime);
  }

  int count(FoulPeriod period, TeamSide team, FoulCategory category) =>
      _counts[(period, team, category)] ?? 0;

  int total(FoulPeriod period, TeamSide team) => FoulCategory.values
      .fold(0, (sum, c) => sum + count(period, team, c));

  /// Anzuzeigende Spaltengruppen — „Verl." nur bei Verlängerung.
  List<FoulPeriod> get periods => [
        FoulPeriod.first,
        FoulPeriod.second,
        if (hasExtraTime) FoulPeriod.extraTime,
      ];
}
