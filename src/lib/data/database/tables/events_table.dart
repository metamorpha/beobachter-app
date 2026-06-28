import 'package:drift/drift.dart';

import 'games_table.dart';

@DataClassName('EventRow')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get gameId =>
      text().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get elapsedMs => integer()();
  TextColumn get gamePhase =>
      text().withDefault(const Constant('ersteHalbzeit'))();
  TextColumn get type => text()();
  TextColumn get customTypeLabel => text().nullable()();
  RealColumn get locationX => real()();
  RealColumn get locationY => real()();
  TextColumn get refDecision => text().nullable()();
  TextColumn get card => text().nullable()();
  TextColumn get assessment => text().nullable()();
  TextColumn get sceneNote => text().nullable()();
  BoolColumn get coachingFlag =>
      boolean().withDefault(const Constant(false))();
  TextColumn get coachingNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
