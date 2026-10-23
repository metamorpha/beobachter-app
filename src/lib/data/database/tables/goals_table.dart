import 'package:drift/drift.dart';

import 'games_table.dart';

@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get gameId =>
      text().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get elapsedMs => integer()();
  TextColumn get gamePhase =>
      text().withDefault(const Constant('ersteHalbzeit'))();
  TextColumn get team => text()();
  IntColumn get scorerNumber => integer().nullable()();
  TextColumn get kind => text().withDefault(const Constant('regular'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
