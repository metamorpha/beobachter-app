import 'package:drift/drift.dart';

@DataClassName('GameRow')
class Games extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get kickoffTime => dateTime().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get homeTeamName => text().withDefault(const Constant(''))();
  TextColumn get awayTeamName => text().withDefault(const Constant(''))();
  TextColumn get liga => text().nullable()();
  TextColumn get spieltag => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
