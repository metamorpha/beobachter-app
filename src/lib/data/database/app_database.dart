import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/events_table.dart';
import 'tables/event_players_table.dart';
import 'tables/games_table.dart';
import 'tables/goals_table.dart';
import 'tables/squads_table.dart';
import 'tables/timer_states_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Games, Events, EventPlayers, Squads, TimerStates, Goals],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(games, games.liga);
            await m.addColumn(games, games.spieltag);
          }
          if (from < 3) {
            await m.addColumn(timerStates, timerStates.phase);
            await m.addColumn(events, events.gamePhase);
          }
          if (from < 4) {
            await m.addColumn(games, games.coachingNote);
          }
          if (from < 5) {
            await m.addColumn(events, events.goalScorerTeam);
            await m.addColumn(events, events.goalScorerNumber);
            await m.addColumn(events, events.ownGoal);
          }
          if (from < 6) {
            // jersey_number wird nullable — SQLite erfordert Neuaufbau der Tabelle
            // ignore: experimental_member_use
            await m.alterTable(TableMigration(eventPlayers));
          }
          if (from < 7) {
            await m.createTable(goals);
            await _migrateGoalDecisions();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// US-215: Gezählte Torentscheidungen werden zu Toren; alle Torentscheidungen
  /// bleiben als Szene „Sonstiges / Torentscheidung" erhalten.
  Future<void> _migrateGoalDecisions() async {
    // Team = begünstigtes Team: beim Eigentor der Gegner des Torschützen
    await customStatement('''
      INSERT INTO goals (id, game_id, elapsed_ms, game_phase, team,
        scorer_number, kind, created_at)
      SELECT id, game_id, elapsed_ms, game_phase,
        CASE WHEN own_goal = 1
          THEN CASE goal_scorer_team WHEN 'home' THEN 'away' ELSE 'home' END
          ELSE goal_scorer_team END,
        goal_scorer_number,
        CASE WHEN own_goal = 1 THEN 'ownGoal' ELSE 'regular' END,
        created_at
      FROM events
      WHERE type = 'goalDecision' AND ref_decision = 'goal'
        AND goal_scorer_team IS NOT NULL
    ''');
    await customStatement('''
      UPDATE events
      SET type = 'custom', custom_type_label = 'Torentscheidung',
        goal_scorer_team = NULL, goal_scorer_number = NULL, own_goal = 0
      WHERE type = 'goalDecision'
    ''');
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'beobachter_app');
  }
}
