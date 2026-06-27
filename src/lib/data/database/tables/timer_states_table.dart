import 'package:drift/drift.dart';

import 'games_table.dart';

@DataClassName('TimerStateRow')
class TimerStates extends Table {
  TextColumn get gameId =>
      text().references(Games, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isRunning =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get startTimestamp => dateTime().nullable()();
  IntColumn get elapsedMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {gameId};
}
