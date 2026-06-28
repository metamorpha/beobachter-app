import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/events_table.dart';
import 'tables/event_players_table.dart';
import 'tables/games_table.dart';
import 'tables/squads_table.dart';
import 'tables/timer_states_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Games, Events, EventPlayers, Squads, TimerStates],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

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
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'beobachter_app');
  }
}
