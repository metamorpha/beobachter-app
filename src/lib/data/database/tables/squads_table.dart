import 'package:drift/drift.dart';

import 'games_table.dart';

@DataClassName('SquadRow')
class Squads extends Table {
  TextColumn get gameId =>
      text().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get team => text()(); // TeamSide.name
  TextColumn get jerseyNumbers => text()(); // JSON: "[1,7,9,...]"

  @override
  Set<Column> get primaryKey => {gameId, team};
}
