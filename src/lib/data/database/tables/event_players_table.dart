import 'package:drift/drift.dart';

import 'events_table.dart';

@DataClassName('EventPlayerRow')
class EventPlayers extends Table {
  TextColumn get id => text()();
  TextColumn get eventId =>
      text().references(Events, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();   // PlayerRole.name
  TextColumn get team => text()();   // TeamSide.name
  IntColumn get jerseyNumber => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
