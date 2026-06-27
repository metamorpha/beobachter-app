// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, GameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kickoffTimeMeta = const VerificationMeta(
    'kickoffTime',
  );
  @override
  late final GeneratedColumn<DateTime> kickoffTime = GeneratedColumn<DateTime>(
    'kickoff_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homeTeamNameMeta = const VerificationMeta(
    'homeTeamName',
  );
  @override
  late final GeneratedColumn<String> homeTeamName = GeneratedColumn<String>(
    'home_team_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _awayTeamNameMeta = const VerificationMeta(
    'awayTeamName',
  );
  @override
  late final GeneratedColumn<String> awayTeamName = GeneratedColumn<String>(
    'away_team_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ligaMeta = const VerificationMeta('liga');
  @override
  late final GeneratedColumn<String> liga = GeneratedColumn<String>(
    'liga',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spieltagMeta = const VerificationMeta(
    'spieltag',
  );
  @override
  late final GeneratedColumn<String> spieltag = GeneratedColumn<String>(
    'spieltag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    kickoffTime,
    location,
    homeTeamName,
    awayTeamName,
    liga,
    spieltag,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kickoff_time')) {
      context.handle(
        _kickoffTimeMeta,
        kickoffTime.isAcceptableOrUnknown(
          data['kickoff_time']!,
          _kickoffTimeMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('home_team_name')) {
      context.handle(
        _homeTeamNameMeta,
        homeTeamName.isAcceptableOrUnknown(
          data['home_team_name']!,
          _homeTeamNameMeta,
        ),
      );
    }
    if (data.containsKey('away_team_name')) {
      context.handle(
        _awayTeamNameMeta,
        awayTeamName.isAcceptableOrUnknown(
          data['away_team_name']!,
          _awayTeamNameMeta,
        ),
      );
    }
    if (data.containsKey('liga')) {
      context.handle(
        _ligaMeta,
        liga.isAcceptableOrUnknown(data['liga']!, _ligaMeta),
      );
    }
    if (data.containsKey('spieltag')) {
      context.handle(
        _spieltagMeta,
        spieltag.isAcceptableOrUnknown(data['spieltag']!, _spieltagMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      kickoffTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}kickoff_time'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      homeTeamName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_team_name'],
      )!,
      awayTeamName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}away_team_name'],
      )!,
      liga: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liga'],
      ),
      spieltag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spieltag'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class GameRow extends DataClass implements Insertable<GameRow> {
  final String id;
  final DateTime date;
  final DateTime? kickoffTime;
  final String? location;
  final String homeTeamName;
  final String awayTeamName;
  final String? liga;
  final String? spieltag;
  final DateTime createdAt;
  const GameRow({
    required this.id,
    required this.date,
    this.kickoffTime,
    this.location,
    required this.homeTeamName,
    required this.awayTeamName,
    this.liga,
    this.spieltag,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || kickoffTime != null) {
      map['kickoff_time'] = Variable<DateTime>(kickoffTime);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['home_team_name'] = Variable<String>(homeTeamName);
    map['away_team_name'] = Variable<String>(awayTeamName);
    if (!nullToAbsent || liga != null) {
      map['liga'] = Variable<String>(liga);
    }
    if (!nullToAbsent || spieltag != null) {
      map['spieltag'] = Variable<String>(spieltag);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      date: Value(date),
      kickoffTime: kickoffTime == null && nullToAbsent
          ? const Value.absent()
          : Value(kickoffTime),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      homeTeamName: Value(homeTeamName),
      awayTeamName: Value(awayTeamName),
      liga: liga == null && nullToAbsent ? const Value.absent() : Value(liga),
      spieltag: spieltag == null && nullToAbsent
          ? const Value.absent()
          : Value(spieltag),
      createdAt: Value(createdAt),
    );
  }

  factory GameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      kickoffTime: serializer.fromJson<DateTime?>(json['kickoffTime']),
      location: serializer.fromJson<String?>(json['location']),
      homeTeamName: serializer.fromJson<String>(json['homeTeamName']),
      awayTeamName: serializer.fromJson<String>(json['awayTeamName']),
      liga: serializer.fromJson<String?>(json['liga']),
      spieltag: serializer.fromJson<String?>(json['spieltag']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'kickoffTime': serializer.toJson<DateTime?>(kickoffTime),
      'location': serializer.toJson<String?>(location),
      'homeTeamName': serializer.toJson<String>(homeTeamName),
      'awayTeamName': serializer.toJson<String>(awayTeamName),
      'liga': serializer.toJson<String?>(liga),
      'spieltag': serializer.toJson<String?>(spieltag),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GameRow copyWith({
    String? id,
    DateTime? date,
    Value<DateTime?> kickoffTime = const Value.absent(),
    Value<String?> location = const Value.absent(),
    String? homeTeamName,
    String? awayTeamName,
    Value<String?> liga = const Value.absent(),
    Value<String?> spieltag = const Value.absent(),
    DateTime? createdAt,
  }) => GameRow(
    id: id ?? this.id,
    date: date ?? this.date,
    kickoffTime: kickoffTime.present ? kickoffTime.value : this.kickoffTime,
    location: location.present ? location.value : this.location,
    homeTeamName: homeTeamName ?? this.homeTeamName,
    awayTeamName: awayTeamName ?? this.awayTeamName,
    liga: liga.present ? liga.value : this.liga,
    spieltag: spieltag.present ? spieltag.value : this.spieltag,
    createdAt: createdAt ?? this.createdAt,
  );
  GameRow copyWithCompanion(GamesCompanion data) {
    return GameRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      kickoffTime: data.kickoffTime.present
          ? data.kickoffTime.value
          : this.kickoffTime,
      location: data.location.present ? data.location.value : this.location,
      homeTeamName: data.homeTeamName.present
          ? data.homeTeamName.value
          : this.homeTeamName,
      awayTeamName: data.awayTeamName.present
          ? data.awayTeamName.value
          : this.awayTeamName,
      liga: data.liga.present ? data.liga.value : this.liga,
      spieltag: data.spieltag.present ? data.spieltag.value : this.spieltag,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kickoffTime: $kickoffTime, ')
          ..write('location: $location, ')
          ..write('homeTeamName: $homeTeamName, ')
          ..write('awayTeamName: $awayTeamName, ')
          ..write('liga: $liga, ')
          ..write('spieltag: $spieltag, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    kickoffTime,
    location,
    homeTeamName,
    awayTeamName,
    liga,
    spieltag,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.kickoffTime == this.kickoffTime &&
          other.location == this.location &&
          other.homeTeamName == this.homeTeamName &&
          other.awayTeamName == this.awayTeamName &&
          other.liga == this.liga &&
          other.spieltag == this.spieltag &&
          other.createdAt == this.createdAt);
}

class GamesCompanion extends UpdateCompanion<GameRow> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<DateTime?> kickoffTime;
  final Value<String?> location;
  final Value<String> homeTeamName;
  final Value<String> awayTeamName;
  final Value<String?> liga;
  final Value<String?> spieltag;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.kickoffTime = const Value.absent(),
    this.location = const Value.absent(),
    this.homeTeamName = const Value.absent(),
    this.awayTeamName = const Value.absent(),
    this.liga = const Value.absent(),
    this.spieltag = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamesCompanion.insert({
    required String id,
    required DateTime date,
    this.kickoffTime = const Value.absent(),
    this.location = const Value.absent(),
    this.homeTeamName = const Value.absent(),
    this.awayTeamName = const Value.absent(),
    this.liga = const Value.absent(),
    this.spieltag = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<GameRow> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<DateTime>? kickoffTime,
    Expression<String>? location,
    Expression<String>? homeTeamName,
    Expression<String>? awayTeamName,
    Expression<String>? liga,
    Expression<String>? spieltag,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (kickoffTime != null) 'kickoff_time': kickoffTime,
      if (location != null) 'location': location,
      if (homeTeamName != null) 'home_team_name': homeTeamName,
      if (awayTeamName != null) 'away_team_name': awayTeamName,
      if (liga != null) 'liga': liga,
      if (spieltag != null) 'spieltag': spieltag,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<DateTime?>? kickoffTime,
    Value<String?>? location,
    Value<String>? homeTeamName,
    Value<String>? awayTeamName,
    Value<String?>? liga,
    Value<String?>? spieltag,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      kickoffTime: kickoffTime ?? this.kickoffTime,
      location: location ?? this.location,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      liga: liga ?? this.liga,
      spieltag: spieltag ?? this.spieltag,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (kickoffTime.present) {
      map['kickoff_time'] = Variable<DateTime>(kickoffTime.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (homeTeamName.present) {
      map['home_team_name'] = Variable<String>(homeTeamName.value);
    }
    if (awayTeamName.present) {
      map['away_team_name'] = Variable<String>(awayTeamName.value);
    }
    if (liga.present) {
      map['liga'] = Variable<String>(liga.value);
    }
    if (spieltag.present) {
      map['spieltag'] = Variable<String>(spieltag.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('kickoffTime: $kickoffTime, ')
          ..write('location: $location, ')
          ..write('homeTeamName: $homeTeamName, ')
          ..write('awayTeamName: $awayTeamName, ')
          ..write('liga: $liga, ')
          ..write('spieltag: $spieltag, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customTypeLabelMeta = const VerificationMeta(
    'customTypeLabel',
  );
  @override
  late final GeneratedColumn<String> customTypeLabel = GeneratedColumn<String>(
    'custom_type_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationXMeta = const VerificationMeta(
    'locationX',
  );
  @override
  late final GeneratedColumn<double> locationX = GeneratedColumn<double>(
    'location_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationYMeta = const VerificationMeta(
    'locationY',
  );
  @override
  late final GeneratedColumn<double> locationY = GeneratedColumn<double>(
    'location_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refDecisionMeta = const VerificationMeta(
    'refDecision',
  );
  @override
  late final GeneratedColumn<String> refDecision = GeneratedColumn<String>(
    'ref_decision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardMeta = const VerificationMeta('card');
  @override
  late final GeneratedColumn<String> card = GeneratedColumn<String>(
    'card',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assessmentMeta = const VerificationMeta(
    'assessment',
  );
  @override
  late final GeneratedColumn<String> assessment = GeneratedColumn<String>(
    'assessment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sceneNoteMeta = const VerificationMeta(
    'sceneNote',
  );
  @override
  late final GeneratedColumn<String> sceneNote = GeneratedColumn<String>(
    'scene_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coachingFlagMeta = const VerificationMeta(
    'coachingFlag',
  );
  @override
  late final GeneratedColumn<bool> coachingFlag = GeneratedColumn<bool>(
    'coaching_flag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("coaching_flag" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _coachingNoteMeta = const VerificationMeta(
    'coachingNote',
  );
  @override
  late final GeneratedColumn<String> coachingNote = GeneratedColumn<String>(
    'coaching_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    elapsedMs,
    type,
    customTypeLabel,
    locationX,
    locationY,
    refDecision,
    card,
    assessment,
    sceneNote,
    coachingFlag,
    coachingNote,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('custom_type_label')) {
      context.handle(
        _customTypeLabelMeta,
        customTypeLabel.isAcceptableOrUnknown(
          data['custom_type_label']!,
          _customTypeLabelMeta,
        ),
      );
    }
    if (data.containsKey('location_x')) {
      context.handle(
        _locationXMeta,
        locationX.isAcceptableOrUnknown(data['location_x']!, _locationXMeta),
      );
    } else if (isInserting) {
      context.missing(_locationXMeta);
    }
    if (data.containsKey('location_y')) {
      context.handle(
        _locationYMeta,
        locationY.isAcceptableOrUnknown(data['location_y']!, _locationYMeta),
      );
    } else if (isInserting) {
      context.missing(_locationYMeta);
    }
    if (data.containsKey('ref_decision')) {
      context.handle(
        _refDecisionMeta,
        refDecision.isAcceptableOrUnknown(
          data['ref_decision']!,
          _refDecisionMeta,
        ),
      );
    }
    if (data.containsKey('card')) {
      context.handle(
        _cardMeta,
        card.isAcceptableOrUnknown(data['card']!, _cardMeta),
      );
    }
    if (data.containsKey('assessment')) {
      context.handle(
        _assessmentMeta,
        assessment.isAcceptableOrUnknown(data['assessment']!, _assessmentMeta),
      );
    }
    if (data.containsKey('scene_note')) {
      context.handle(
        _sceneNoteMeta,
        sceneNote.isAcceptableOrUnknown(data['scene_note']!, _sceneNoteMeta),
      );
    }
    if (data.containsKey('coaching_flag')) {
      context.handle(
        _coachingFlagMeta,
        coachingFlag.isAcceptableOrUnknown(
          data['coaching_flag']!,
          _coachingFlagMeta,
        ),
      );
    }
    if (data.containsKey('coaching_note')) {
      context.handle(
        _coachingNoteMeta,
        coachingNote.isAcceptableOrUnknown(
          data['coaching_note']!,
          _coachingNoteMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      customTypeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_type_label'],
      ),
      locationX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_x'],
      )!,
      locationY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_y'],
      )!,
      refDecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_decision'],
      ),
      card: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card'],
      ),
      assessment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment'],
      ),
      sceneNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scene_note'],
      ),
      coachingFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}coaching_flag'],
      )!,
      coachingNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coaching_note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final String id;
  final String gameId;
  final int elapsedMs;
  final String type;
  final String? customTypeLabel;
  final double locationX;
  final double locationY;
  final String? refDecision;
  final String? card;
  final String? assessment;
  final String? sceneNote;
  final bool coachingFlag;
  final String? coachingNote;
  final DateTime createdAt;
  const EventRow({
    required this.id,
    required this.gameId,
    required this.elapsedMs,
    required this.type,
    this.customTypeLabel,
    required this.locationX,
    required this.locationY,
    this.refDecision,
    this.card,
    this.assessment,
    this.sceneNote,
    required this.coachingFlag,
    this.coachingNote,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || customTypeLabel != null) {
      map['custom_type_label'] = Variable<String>(customTypeLabel);
    }
    map['location_x'] = Variable<double>(locationX);
    map['location_y'] = Variable<double>(locationY);
    if (!nullToAbsent || refDecision != null) {
      map['ref_decision'] = Variable<String>(refDecision);
    }
    if (!nullToAbsent || card != null) {
      map['card'] = Variable<String>(card);
    }
    if (!nullToAbsent || assessment != null) {
      map['assessment'] = Variable<String>(assessment);
    }
    if (!nullToAbsent || sceneNote != null) {
      map['scene_note'] = Variable<String>(sceneNote);
    }
    map['coaching_flag'] = Variable<bool>(coachingFlag);
    if (!nullToAbsent || coachingNote != null) {
      map['coaching_note'] = Variable<String>(coachingNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      elapsedMs: Value(elapsedMs),
      type: Value(type),
      customTypeLabel: customTypeLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(customTypeLabel),
      locationX: Value(locationX),
      locationY: Value(locationY),
      refDecision: refDecision == null && nullToAbsent
          ? const Value.absent()
          : Value(refDecision),
      card: card == null && nullToAbsent ? const Value.absent() : Value(card),
      assessment: assessment == null && nullToAbsent
          ? const Value.absent()
          : Value(assessment),
      sceneNote: sceneNote == null && nullToAbsent
          ? const Value.absent()
          : Value(sceneNote),
      coachingFlag: Value(coachingFlag),
      coachingNote: coachingNote == null && nullToAbsent
          ? const Value.absent()
          : Value(coachingNote),
      createdAt: Value(createdAt),
    );
  }

  factory EventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      type: serializer.fromJson<String>(json['type']),
      customTypeLabel: serializer.fromJson<String?>(json['customTypeLabel']),
      locationX: serializer.fromJson<double>(json['locationX']),
      locationY: serializer.fromJson<double>(json['locationY']),
      refDecision: serializer.fromJson<String?>(json['refDecision']),
      card: serializer.fromJson<String?>(json['card']),
      assessment: serializer.fromJson<String?>(json['assessment']),
      sceneNote: serializer.fromJson<String?>(json['sceneNote']),
      coachingFlag: serializer.fromJson<bool>(json['coachingFlag']),
      coachingNote: serializer.fromJson<String?>(json['coachingNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'type': serializer.toJson<String>(type),
      'customTypeLabel': serializer.toJson<String?>(customTypeLabel),
      'locationX': serializer.toJson<double>(locationX),
      'locationY': serializer.toJson<double>(locationY),
      'refDecision': serializer.toJson<String?>(refDecision),
      'card': serializer.toJson<String?>(card),
      'assessment': serializer.toJson<String?>(assessment),
      'sceneNote': serializer.toJson<String?>(sceneNote),
      'coachingFlag': serializer.toJson<bool>(coachingFlag),
      'coachingNote': serializer.toJson<String?>(coachingNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EventRow copyWith({
    String? id,
    String? gameId,
    int? elapsedMs,
    String? type,
    Value<String?> customTypeLabel = const Value.absent(),
    double? locationX,
    double? locationY,
    Value<String?> refDecision = const Value.absent(),
    Value<String?> card = const Value.absent(),
    Value<String?> assessment = const Value.absent(),
    Value<String?> sceneNote = const Value.absent(),
    bool? coachingFlag,
    Value<String?> coachingNote = const Value.absent(),
    DateTime? createdAt,
  }) => EventRow(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    type: type ?? this.type,
    customTypeLabel: customTypeLabel.present
        ? customTypeLabel.value
        : this.customTypeLabel,
    locationX: locationX ?? this.locationX,
    locationY: locationY ?? this.locationY,
    refDecision: refDecision.present ? refDecision.value : this.refDecision,
    card: card.present ? card.value : this.card,
    assessment: assessment.present ? assessment.value : this.assessment,
    sceneNote: sceneNote.present ? sceneNote.value : this.sceneNote,
    coachingFlag: coachingFlag ?? this.coachingFlag,
    coachingNote: coachingNote.present ? coachingNote.value : this.coachingNote,
    createdAt: createdAt ?? this.createdAt,
  );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      type: data.type.present ? data.type.value : this.type,
      customTypeLabel: data.customTypeLabel.present
          ? data.customTypeLabel.value
          : this.customTypeLabel,
      locationX: data.locationX.present ? data.locationX.value : this.locationX,
      locationY: data.locationY.present ? data.locationY.value : this.locationY,
      refDecision: data.refDecision.present
          ? data.refDecision.value
          : this.refDecision,
      card: data.card.present ? data.card.value : this.card,
      assessment: data.assessment.present
          ? data.assessment.value
          : this.assessment,
      sceneNote: data.sceneNote.present ? data.sceneNote.value : this.sceneNote,
      coachingFlag: data.coachingFlag.present
          ? data.coachingFlag.value
          : this.coachingFlag,
      coachingNote: data.coachingNote.present
          ? data.coachingNote.value
          : this.coachingNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('type: $type, ')
          ..write('customTypeLabel: $customTypeLabel, ')
          ..write('locationX: $locationX, ')
          ..write('locationY: $locationY, ')
          ..write('refDecision: $refDecision, ')
          ..write('card: $card, ')
          ..write('assessment: $assessment, ')
          ..write('sceneNote: $sceneNote, ')
          ..write('coachingFlag: $coachingFlag, ')
          ..write('coachingNote: $coachingNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    elapsedMs,
    type,
    customTypeLabel,
    locationX,
    locationY,
    refDecision,
    card,
    assessment,
    sceneNote,
    coachingFlag,
    coachingNote,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.elapsedMs == this.elapsedMs &&
          other.type == this.type &&
          other.customTypeLabel == this.customTypeLabel &&
          other.locationX == this.locationX &&
          other.locationY == this.locationY &&
          other.refDecision == this.refDecision &&
          other.card == this.card &&
          other.assessment == this.assessment &&
          other.sceneNote == this.sceneNote &&
          other.coachingFlag == this.coachingFlag &&
          other.coachingNote == this.coachingNote &&
          other.createdAt == this.createdAt);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<int> elapsedMs;
  final Value<String> type;
  final Value<String?> customTypeLabel;
  final Value<double> locationX;
  final Value<double> locationY;
  final Value<String?> refDecision;
  final Value<String?> card;
  final Value<String?> assessment;
  final Value<String?> sceneNote;
  final Value<bool> coachingFlag;
  final Value<String?> coachingNote;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.type = const Value.absent(),
    this.customTypeLabel = const Value.absent(),
    this.locationX = const Value.absent(),
    this.locationY = const Value.absent(),
    this.refDecision = const Value.absent(),
    this.card = const Value.absent(),
    this.assessment = const Value.absent(),
    this.sceneNote = const Value.absent(),
    this.coachingFlag = const Value.absent(),
    this.coachingNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String gameId,
    required int elapsedMs,
    required String type,
    this.customTypeLabel = const Value.absent(),
    required double locationX,
    required double locationY,
    this.refDecision = const Value.absent(),
    this.card = const Value.absent(),
    this.assessment = const Value.absent(),
    this.sceneNote = const Value.absent(),
    this.coachingFlag = const Value.absent(),
    this.coachingNote = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       elapsedMs = Value(elapsedMs),
       type = Value(type),
       locationX = Value(locationX),
       locationY = Value(locationY),
       createdAt = Value(createdAt);
  static Insertable<EventRow> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<int>? elapsedMs,
    Expression<String>? type,
    Expression<String>? customTypeLabel,
    Expression<double>? locationX,
    Expression<double>? locationY,
    Expression<String>? refDecision,
    Expression<String>? card,
    Expression<String>? assessment,
    Expression<String>? sceneNote,
    Expression<bool>? coachingFlag,
    Expression<String>? coachingNote,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (type != null) 'type': type,
      if (customTypeLabel != null) 'custom_type_label': customTypeLabel,
      if (locationX != null) 'location_x': locationX,
      if (locationY != null) 'location_y': locationY,
      if (refDecision != null) 'ref_decision': refDecision,
      if (card != null) 'card': card,
      if (assessment != null) 'assessment': assessment,
      if (sceneNote != null) 'scene_note': sceneNote,
      if (coachingFlag != null) 'coaching_flag': coachingFlag,
      if (coachingNote != null) 'coaching_note': coachingNote,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<int>? elapsedMs,
    Value<String>? type,
    Value<String?>? customTypeLabel,
    Value<double>? locationX,
    Value<double>? locationY,
    Value<String?>? refDecision,
    Value<String?>? card,
    Value<String?>? assessment,
    Value<String?>? sceneNote,
    Value<bool>? coachingFlag,
    Value<String?>? coachingNote,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      type: type ?? this.type,
      customTypeLabel: customTypeLabel ?? this.customTypeLabel,
      locationX: locationX ?? this.locationX,
      locationY: locationY ?? this.locationY,
      refDecision: refDecision ?? this.refDecision,
      card: card ?? this.card,
      assessment: assessment ?? this.assessment,
      sceneNote: sceneNote ?? this.sceneNote,
      coachingFlag: coachingFlag ?? this.coachingFlag,
      coachingNote: coachingNote ?? this.coachingNote,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (customTypeLabel.present) {
      map['custom_type_label'] = Variable<String>(customTypeLabel.value);
    }
    if (locationX.present) {
      map['location_x'] = Variable<double>(locationX.value);
    }
    if (locationY.present) {
      map['location_y'] = Variable<double>(locationY.value);
    }
    if (refDecision.present) {
      map['ref_decision'] = Variable<String>(refDecision.value);
    }
    if (card.present) {
      map['card'] = Variable<String>(card.value);
    }
    if (assessment.present) {
      map['assessment'] = Variable<String>(assessment.value);
    }
    if (sceneNote.present) {
      map['scene_note'] = Variable<String>(sceneNote.value);
    }
    if (coachingFlag.present) {
      map['coaching_flag'] = Variable<bool>(coachingFlag.value);
    }
    if (coachingNote.present) {
      map['coaching_note'] = Variable<String>(coachingNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('type: $type, ')
          ..write('customTypeLabel: $customTypeLabel, ')
          ..write('locationX: $locationX, ')
          ..write('locationY: $locationY, ')
          ..write('refDecision: $refDecision, ')
          ..write('card: $card, ')
          ..write('assessment: $assessment, ')
          ..write('sceneNote: $sceneNote, ')
          ..write('coachingFlag: $coachingFlag, ')
          ..write('coachingNote: $coachingNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventPlayersTable extends EventPlayers
    with TableInfo<$EventPlayersTable, EventPlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventPlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamMeta = const VerificationMeta('team');
  @override
  late final GeneratedColumn<String> team = GeneratedColumn<String>(
    'team',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jerseyNumberMeta = const VerificationMeta(
    'jerseyNumber',
  );
  @override
  late final GeneratedColumn<int> jerseyNumber = GeneratedColumn<int>(
    'jersey_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, eventId, role, team, jerseyNumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventPlayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('team')) {
      context.handle(
        _teamMeta,
        team.isAcceptableOrUnknown(data['team']!, _teamMeta),
      );
    } else if (isInserting) {
      context.missing(_teamMeta);
    }
    if (data.containsKey('jersey_number')) {
      context.handle(
        _jerseyNumberMeta,
        jerseyNumber.isAcceptableOrUnknown(
          data['jersey_number']!,
          _jerseyNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jerseyNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventPlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventPlayerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      team: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team'],
      )!,
      jerseyNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jersey_number'],
      )!,
    );
  }

  @override
  $EventPlayersTable createAlias(String alias) {
    return $EventPlayersTable(attachedDatabase, alias);
  }
}

class EventPlayerRow extends DataClass implements Insertable<EventPlayerRow> {
  final String id;
  final String eventId;
  final String role;
  final String team;
  final int jerseyNumber;
  const EventPlayerRow({
    required this.id,
    required this.eventId,
    required this.role,
    required this.team,
    required this.jerseyNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['role'] = Variable<String>(role);
    map['team'] = Variable<String>(team);
    map['jersey_number'] = Variable<int>(jerseyNumber);
    return map;
  }

  EventPlayersCompanion toCompanion(bool nullToAbsent) {
    return EventPlayersCompanion(
      id: Value(id),
      eventId: Value(eventId),
      role: Value(role),
      team: Value(team),
      jerseyNumber: Value(jerseyNumber),
    );
  }

  factory EventPlayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventPlayerRow(
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      role: serializer.fromJson<String>(json['role']),
      team: serializer.fromJson<String>(json['team']),
      jerseyNumber: serializer.fromJson<int>(json['jerseyNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'role': serializer.toJson<String>(role),
      'team': serializer.toJson<String>(team),
      'jerseyNumber': serializer.toJson<int>(jerseyNumber),
    };
  }

  EventPlayerRow copyWith({
    String? id,
    String? eventId,
    String? role,
    String? team,
    int? jerseyNumber,
  }) => EventPlayerRow(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    role: role ?? this.role,
    team: team ?? this.team,
    jerseyNumber: jerseyNumber ?? this.jerseyNumber,
  );
  EventPlayerRow copyWithCompanion(EventPlayersCompanion data) {
    return EventPlayerRow(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      role: data.role.present ? data.role.value : this.role,
      team: data.team.present ? data.team.value : this.team,
      jerseyNumber: data.jerseyNumber.present
          ? data.jerseyNumber.value
          : this.jerseyNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventPlayerRow(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('role: $role, ')
          ..write('team: $team, ')
          ..write('jerseyNumber: $jerseyNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventId, role, team, jerseyNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventPlayerRow &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.role == this.role &&
          other.team == this.team &&
          other.jerseyNumber == this.jerseyNumber);
}

class EventPlayersCompanion extends UpdateCompanion<EventPlayerRow> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> role;
  final Value<String> team;
  final Value<int> jerseyNumber;
  final Value<int> rowid;
  const EventPlayersCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.role = const Value.absent(),
    this.team = const Value.absent(),
    this.jerseyNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventPlayersCompanion.insert({
    required String id,
    required String eventId,
    required String role,
    required String team,
    required int jerseyNumber,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       role = Value(role),
       team = Value(team),
       jerseyNumber = Value(jerseyNumber);
  static Insertable<EventPlayerRow> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? role,
    Expression<String>? team,
    Expression<int>? jerseyNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (role != null) 'role': role,
      if (team != null) 'team': team,
      if (jerseyNumber != null) 'jersey_number': jerseyNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventPlayersCompanion copyWith({
    Value<String>? id,
    Value<String>? eventId,
    Value<String>? role,
    Value<String>? team,
    Value<int>? jerseyNumber,
    Value<int>? rowid,
  }) {
    return EventPlayersCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      role: role ?? this.role,
      team: team ?? this.team,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (team.present) {
      map['team'] = Variable<String>(team.value);
    }
    if (jerseyNumber.present) {
      map['jersey_number'] = Variable<int>(jerseyNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventPlayersCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('role: $role, ')
          ..write('team: $team, ')
          ..write('jerseyNumber: $jerseyNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SquadsTable extends Squads with TableInfo<$SquadsTable, SquadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SquadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _teamMeta = const VerificationMeta('team');
  @override
  late final GeneratedColumn<String> team = GeneratedColumn<String>(
    'team',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jerseyNumbersMeta = const VerificationMeta(
    'jerseyNumbers',
  );
  @override
  late final GeneratedColumn<String> jerseyNumbers = GeneratedColumn<String>(
    'jersey_numbers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, team, jerseyNumbers];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'squads';
  @override
  VerificationContext validateIntegrity(
    Insertable<SquadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('team')) {
      context.handle(
        _teamMeta,
        team.isAcceptableOrUnknown(data['team']!, _teamMeta),
      );
    } else if (isInserting) {
      context.missing(_teamMeta);
    }
    if (data.containsKey('jersey_numbers')) {
      context.handle(
        _jerseyNumbersMeta,
        jerseyNumbers.isAcceptableOrUnknown(
          data['jersey_numbers']!,
          _jerseyNumbersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jerseyNumbersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, team};
  @override
  SquadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SquadRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      team: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team'],
      )!,
      jerseyNumbers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jersey_numbers'],
      )!,
    );
  }

  @override
  $SquadsTable createAlias(String alias) {
    return $SquadsTable(attachedDatabase, alias);
  }
}

class SquadRow extends DataClass implements Insertable<SquadRow> {
  final String gameId;
  final String team;
  final String jerseyNumbers;
  const SquadRow({
    required this.gameId,
    required this.team,
    required this.jerseyNumbers,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['team'] = Variable<String>(team);
    map['jersey_numbers'] = Variable<String>(jerseyNumbers);
    return map;
  }

  SquadsCompanion toCompanion(bool nullToAbsent) {
    return SquadsCompanion(
      gameId: Value(gameId),
      team: Value(team),
      jerseyNumbers: Value(jerseyNumbers),
    );
  }

  factory SquadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SquadRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      team: serializer.fromJson<String>(json['team']),
      jerseyNumbers: serializer.fromJson<String>(json['jerseyNumbers']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'team': serializer.toJson<String>(team),
      'jerseyNumbers': serializer.toJson<String>(jerseyNumbers),
    };
  }

  SquadRow copyWith({String? gameId, String? team, String? jerseyNumbers}) =>
      SquadRow(
        gameId: gameId ?? this.gameId,
        team: team ?? this.team,
        jerseyNumbers: jerseyNumbers ?? this.jerseyNumbers,
      );
  SquadRow copyWithCompanion(SquadsCompanion data) {
    return SquadRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      team: data.team.present ? data.team.value : this.team,
      jerseyNumbers: data.jerseyNumbers.present
          ? data.jerseyNumbers.value
          : this.jerseyNumbers,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SquadRow(')
          ..write('gameId: $gameId, ')
          ..write('team: $team, ')
          ..write('jerseyNumbers: $jerseyNumbers')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, team, jerseyNumbers);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SquadRow &&
          other.gameId == this.gameId &&
          other.team == this.team &&
          other.jerseyNumbers == this.jerseyNumbers);
}

class SquadsCompanion extends UpdateCompanion<SquadRow> {
  final Value<String> gameId;
  final Value<String> team;
  final Value<String> jerseyNumbers;
  final Value<int> rowid;
  const SquadsCompanion({
    this.gameId = const Value.absent(),
    this.team = const Value.absent(),
    this.jerseyNumbers = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SquadsCompanion.insert({
    required String gameId,
    required String team,
    required String jerseyNumbers,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       team = Value(team),
       jerseyNumbers = Value(jerseyNumbers);
  static Insertable<SquadRow> custom({
    Expression<String>? gameId,
    Expression<String>? team,
    Expression<String>? jerseyNumbers,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (team != null) 'team': team,
      if (jerseyNumbers != null) 'jersey_numbers': jerseyNumbers,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SquadsCompanion copyWith({
    Value<String>? gameId,
    Value<String>? team,
    Value<String>? jerseyNumbers,
    Value<int>? rowid,
  }) {
    return SquadsCompanion(
      gameId: gameId ?? this.gameId,
      team: team ?? this.team,
      jerseyNumbers: jerseyNumbers ?? this.jerseyNumbers,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (team.present) {
      map['team'] = Variable<String>(team.value);
    }
    if (jerseyNumbers.present) {
      map['jersey_numbers'] = Variable<String>(jerseyNumbers.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SquadsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('team: $team, ')
          ..write('jerseyNumbers: $jerseyNumbers, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimerStatesTable extends TimerStates
    with TableInfo<$TimerStatesTable, TimerStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _isRunningMeta = const VerificationMeta(
    'isRunning',
  );
  @override
  late final GeneratedColumn<bool> isRunning = GeneratedColumn<bool>(
    'is_running',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_running" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startTimestampMeta = const VerificationMeta(
    'startTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> startTimestamp =
      GeneratedColumn<DateTime>(
        'start_timestamp',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    isRunning,
    startTimestamp,
    elapsedMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('is_running')) {
      context.handle(
        _isRunningMeta,
        isRunning.isAcceptableOrUnknown(data['is_running']!, _isRunningMeta),
      );
    }
    if (data.containsKey('start_timestamp')) {
      context.handle(
        _startTimestampMeta,
        startTimestamp.isAcceptableOrUnknown(
          data['start_timestamp']!,
          _startTimestampMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  TimerStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerStateRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      isRunning: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_running'],
      )!,
      startTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_timestamp'],
      ),
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
    );
  }

  @override
  $TimerStatesTable createAlias(String alias) {
    return $TimerStatesTable(attachedDatabase, alias);
  }
}

class TimerStateRow extends DataClass implements Insertable<TimerStateRow> {
  final String gameId;
  final bool isRunning;
  final DateTime? startTimestamp;
  final int elapsedMs;
  const TimerStateRow({
    required this.gameId,
    required this.isRunning,
    this.startTimestamp,
    required this.elapsedMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['is_running'] = Variable<bool>(isRunning);
    if (!nullToAbsent || startTimestamp != null) {
      map['start_timestamp'] = Variable<DateTime>(startTimestamp);
    }
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    return map;
  }

  TimerStatesCompanion toCompanion(bool nullToAbsent) {
    return TimerStatesCompanion(
      gameId: Value(gameId),
      isRunning: Value(isRunning),
      startTimestamp: startTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(startTimestamp),
      elapsedMs: Value(elapsedMs),
    );
  }

  factory TimerStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerStateRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      isRunning: serializer.fromJson<bool>(json['isRunning']),
      startTimestamp: serializer.fromJson<DateTime?>(json['startTimestamp']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'isRunning': serializer.toJson<bool>(isRunning),
      'startTimestamp': serializer.toJson<DateTime?>(startTimestamp),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
    };
  }

  TimerStateRow copyWith({
    String? gameId,
    bool? isRunning,
    Value<DateTime?> startTimestamp = const Value.absent(),
    int? elapsedMs,
  }) => TimerStateRow(
    gameId: gameId ?? this.gameId,
    isRunning: isRunning ?? this.isRunning,
    startTimestamp: startTimestamp.present
        ? startTimestamp.value
        : this.startTimestamp,
    elapsedMs: elapsedMs ?? this.elapsedMs,
  );
  TimerStateRow copyWithCompanion(TimerStatesCompanion data) {
    return TimerStateRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      isRunning: data.isRunning.present ? data.isRunning.value : this.isRunning,
      startTimestamp: data.startTimestamp.present
          ? data.startTimestamp.value
          : this.startTimestamp,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerStateRow(')
          ..write('gameId: $gameId, ')
          ..write('isRunning: $isRunning, ')
          ..write('startTimestamp: $startTimestamp, ')
          ..write('elapsedMs: $elapsedMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, isRunning, startTimestamp, elapsedMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerStateRow &&
          other.gameId == this.gameId &&
          other.isRunning == this.isRunning &&
          other.startTimestamp == this.startTimestamp &&
          other.elapsedMs == this.elapsedMs);
}

class TimerStatesCompanion extends UpdateCompanion<TimerStateRow> {
  final Value<String> gameId;
  final Value<bool> isRunning;
  final Value<DateTime?> startTimestamp;
  final Value<int> elapsedMs;
  final Value<int> rowid;
  const TimerStatesCompanion({
    this.gameId = const Value.absent(),
    this.isRunning = const Value.absent(),
    this.startTimestamp = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimerStatesCompanion.insert({
    required String gameId,
    this.isRunning = const Value.absent(),
    this.startTimestamp = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId);
  static Insertable<TimerStateRow> custom({
    Expression<String>? gameId,
    Expression<bool>? isRunning,
    Expression<DateTime>? startTimestamp,
    Expression<int>? elapsedMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (isRunning != null) 'is_running': isRunning,
      if (startTimestamp != null) 'start_timestamp': startTimestamp,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimerStatesCompanion copyWith({
    Value<String>? gameId,
    Value<bool>? isRunning,
    Value<DateTime?>? startTimestamp,
    Value<int>? elapsedMs,
    Value<int>? rowid,
  }) {
    return TimerStatesCompanion(
      gameId: gameId ?? this.gameId,
      isRunning: isRunning ?? this.isRunning,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (isRunning.present) {
      map['is_running'] = Variable<bool>(isRunning.value);
    }
    if (startTimestamp.present) {
      map['start_timestamp'] = Variable<DateTime>(startTimestamp.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerStatesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('isRunning: $isRunning, ')
          ..write('startTimestamp: $startTimestamp, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $EventPlayersTable eventPlayers = $EventPlayersTable(this);
  late final $SquadsTable squads = $SquadsTable(this);
  late final $TimerStatesTable timerStates = $TimerStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    games,
    events,
    eventPlayers,
    squads,
    timerStates,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('event_players', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('squads', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('timer_states', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      required String id,
      required DateTime date,
      Value<DateTime?> kickoffTime,
      Value<String?> location,
      Value<String> homeTeamName,
      Value<String> awayTeamName,
      Value<String?> liga,
      Value<String?> spieltag,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<DateTime?> kickoffTime,
      Value<String?> location,
      Value<String> homeTeamName,
      Value<String> awayTeamName,
      Value<String?> liga,
      Value<String?> spieltag,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, GameRow> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EventsTable, List<EventRow>> _eventsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.events,
    aliasName: $_aliasNameGenerator(db.games.id, db.events.gameId),
  );

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SquadsTable, List<SquadRow>> _squadsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.squads,
    aliasName: $_aliasNameGenerator(db.games.id, db.squads.gameId),
  );

  $$SquadsTableProcessedTableManager get squadsRefs {
    final manager = $$SquadsTableTableManager(
      $_db,
      $_db.squads,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_squadsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TimerStatesTable, List<TimerStateRow>>
  _timerStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timerStates,
    aliasName: $_aliasNameGenerator(db.games.id, db.timerStates.gameId),
  );

  $$TimerStatesTableProcessedTableManager get timerStatesRefs {
    final manager = $$TimerStatesTableTableManager(
      $_db,
      $_db.timerStates,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_timerStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get kickoffTime => $composableBuilder(
    column: $table.kickoffTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeTeamName => $composableBuilder(
    column: $table.homeTeamName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awayTeamName => $composableBuilder(
    column: $table.awayTeamName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liga => $composableBuilder(
    column: $table.liga,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spieltag => $composableBuilder(
    column: $table.spieltag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> eventsRefs(
    Expression<bool> Function($$EventsTableFilterComposer f) f,
  ) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> squadsRefs(
    Expression<bool> Function($$SquadsTableFilterComposer f) f,
  ) {
    final $$SquadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.squads,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SquadsTableFilterComposer(
            $db: $db,
            $table: $db.squads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timerStatesRefs(
    Expression<bool> Function($$TimerStatesTableFilterComposer f) f,
  ) {
    final $$TimerStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timerStates,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerStatesTableFilterComposer(
            $db: $db,
            $table: $db.timerStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get kickoffTime => $composableBuilder(
    column: $table.kickoffTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeTeamName => $composableBuilder(
    column: $table.homeTeamName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awayTeamName => $composableBuilder(
    column: $table.awayTeamName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liga => $composableBuilder(
    column: $table.liga,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spieltag => $composableBuilder(
    column: $table.spieltag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get kickoffTime => $composableBuilder(
    column: $table.kickoffTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get homeTeamName => $composableBuilder(
    column: $table.homeTeamName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get awayTeamName => $composableBuilder(
    column: $table.awayTeamName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get liga =>
      $composableBuilder(column: $table.liga, builder: (column) => column);

  GeneratedColumn<String> get spieltag =>
      $composableBuilder(column: $table.spieltag, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> eventsRefs<T extends Object>(
    Expression<T> Function($$EventsTableAnnotationComposer a) f,
  ) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> squadsRefs<T extends Object>(
    Expression<T> Function($$SquadsTableAnnotationComposer a) f,
  ) {
    final $$SquadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.squads,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SquadsTableAnnotationComposer(
            $db: $db,
            $table: $db.squads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> timerStatesRefs<T extends Object>(
    Expression<T> Function($$TimerStatesTableAnnotationComposer a) f,
  ) {
    final $$TimerStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timerStates,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.timerStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          GameRow,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (GameRow, $$GamesTableReferences),
          GameRow,
          PrefetchHooks Function({
            bool eventsRefs,
            bool squadsRefs,
            bool timerStatesRefs,
          })
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime?> kickoffTime = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> homeTeamName = const Value.absent(),
                Value<String> awayTeamName = const Value.absent(),
                Value<String?> liga = const Value.absent(),
                Value<String?> spieltag = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                date: date,
                kickoffTime: kickoffTime,
                location: location,
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                liga: liga,
                spieltag: spieltag,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                Value<DateTime?> kickoffTime = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> homeTeamName = const Value.absent(),
                Value<String> awayTeamName = const Value.absent(),
                Value<String?> liga = const Value.absent(),
                Value<String?> spieltag = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                date: date,
                kickoffTime: kickoffTime,
                location: location,
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                liga: liga,
                spieltag: spieltag,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GamesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                eventsRefs = false,
                squadsRefs = false,
                timerStatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (eventsRefs) db.events,
                    if (squadsRefs) db.squads,
                    if (timerStatesRefs) db.timerStates,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (eventsRefs)
                        await $_getPrefetchedData<
                          GameRow,
                          $GamesTable,
                          EventRow
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._eventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(db, table, p0).eventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (squadsRefs)
                        await $_getPrefetchedData<
                          GameRow,
                          $GamesTable,
                          SquadRow
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._squadsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(db, table, p0).squadsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (timerStatesRefs)
                        await $_getPrefetchedData<
                          GameRow,
                          $GamesTable,
                          TimerStateRow
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._timerStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).timerStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      GameRow,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (GameRow, $$GamesTableReferences),
      GameRow,
      PrefetchHooks Function({
        bool eventsRefs,
        bool squadsRefs,
        bool timerStatesRefs,
      })
    >;
typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required String id,
      required String gameId,
      required int elapsedMs,
      required String type,
      Value<String?> customTypeLabel,
      required double locationX,
      required double locationY,
      Value<String?> refDecision,
      Value<String?> card,
      Value<String?> assessment,
      Value<String?> sceneNote,
      Value<bool> coachingFlag,
      Value<String?> coachingNote,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<int> elapsedMs,
      Value<String> type,
      Value<String?> customTypeLabel,
      Value<double> locationX,
      Value<double> locationY,
      Value<String?> refDecision,
      Value<String?> card,
      Value<String?> assessment,
      Value<String?> sceneNote,
      Value<bool> coachingFlag,
      Value<String?> coachingNote,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, EventRow> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias($_aliasNameGenerator(db.events.gameId, db.games.id));

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EventPlayersTable, List<EventPlayerRow>>
  _eventPlayersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventPlayers,
    aliasName: $_aliasNameGenerator(db.events.id, db.eventPlayers.eventId),
  );

  $$EventPlayersTableProcessedTableManager get eventPlayersRefs {
    final manager = $$EventPlayersTableTableManager(
      $_db,
      $_db.eventPlayers,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventPlayersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customTypeLabel => $composableBuilder(
    column: $table.customTypeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationX => $composableBuilder(
    column: $table.locationX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationY => $composableBuilder(
    column: $table.locationY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refDecision => $composableBuilder(
    column: $table.refDecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get card => $composableBuilder(
    column: $table.card,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessment => $composableBuilder(
    column: $table.assessment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sceneNote => $composableBuilder(
    column: $table.sceneNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get coachingFlag => $composableBuilder(
    column: $table.coachingFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coachingNote => $composableBuilder(
    column: $table.coachingNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> eventPlayersRefs(
    Expression<bool> Function($$EventPlayersTableFilterComposer f) f,
  ) {
    final $$EventPlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventPlayers,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventPlayersTableFilterComposer(
            $db: $db,
            $table: $db.eventPlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customTypeLabel => $composableBuilder(
    column: $table.customTypeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationX => $composableBuilder(
    column: $table.locationX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationY => $composableBuilder(
    column: $table.locationY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refDecision => $composableBuilder(
    column: $table.refDecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get card => $composableBuilder(
    column: $table.card,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessment => $composableBuilder(
    column: $table.assessment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sceneNote => $composableBuilder(
    column: $table.sceneNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get coachingFlag => $composableBuilder(
    column: $table.coachingFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coachingNote => $composableBuilder(
    column: $table.coachingNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get customTypeLabel => $composableBuilder(
    column: $table.customTypeLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get locationX =>
      $composableBuilder(column: $table.locationX, builder: (column) => column);

  GeneratedColumn<double> get locationY =>
      $composableBuilder(column: $table.locationY, builder: (column) => column);

  GeneratedColumn<String> get refDecision => $composableBuilder(
    column: $table.refDecision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get card =>
      $composableBuilder(column: $table.card, builder: (column) => column);

  GeneratedColumn<String> get assessment => $composableBuilder(
    column: $table.assessment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sceneNote =>
      $composableBuilder(column: $table.sceneNote, builder: (column) => column);

  GeneratedColumn<bool> get coachingFlag => $composableBuilder(
    column: $table.coachingFlag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coachingNote => $composableBuilder(
    column: $table.coachingNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> eventPlayersRefs<T extends Object>(
    Expression<T> Function($$EventPlayersTableAnnotationComposer a) f,
  ) {
    final $$EventPlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventPlayers,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventPlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.eventPlayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          EventRow,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (EventRow, $$EventsTableReferences),
          EventRow,
          PrefetchHooks Function({bool gameId, bool eventPlayersRefs})
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> customTypeLabel = const Value.absent(),
                Value<double> locationX = const Value.absent(),
                Value<double> locationY = const Value.absent(),
                Value<String?> refDecision = const Value.absent(),
                Value<String?> card = const Value.absent(),
                Value<String?> assessment = const Value.absent(),
                Value<String?> sceneNote = const Value.absent(),
                Value<bool> coachingFlag = const Value.absent(),
                Value<String?> coachingNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                gameId: gameId,
                elapsedMs: elapsedMs,
                type: type,
                customTypeLabel: customTypeLabel,
                locationX: locationX,
                locationY: locationY,
                refDecision: refDecision,
                card: card,
                assessment: assessment,
                sceneNote: sceneNote,
                coachingFlag: coachingFlag,
                coachingNote: coachingNote,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required int elapsedMs,
                required String type,
                Value<String?> customTypeLabel = const Value.absent(),
                required double locationX,
                required double locationY,
                Value<String?> refDecision = const Value.absent(),
                Value<String?> card = const Value.absent(),
                Value<String?> assessment = const Value.absent(),
                Value<String?> sceneNote = const Value.absent(),
                Value<bool> coachingFlag = const Value.absent(),
                Value<String?> coachingNote = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                gameId: gameId,
                elapsedMs: elapsedMs,
                type: type,
                customTypeLabel: customTypeLabel,
                locationX: locationX,
                locationY: locationY,
                refDecision: refDecision,
                card: card,
                assessment: assessment,
                sceneNote: sceneNote,
                coachingFlag: coachingFlag,
                coachingNote: coachingNote,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$EventsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, eventPlayersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (eventPlayersRefs) db.eventPlayers],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$EventsTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$EventsTableReferences
                                    ._gameIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eventPlayersRefs)
                    await $_getPrefetchedData<
                      EventRow,
                      $EventsTable,
                      EventPlayerRow
                    >(
                      currentTable: table,
                      referencedTable: $$EventsTableReferences
                          ._eventPlayersRefsTable(db),
                      managerFromTypedResult: (p0) => $$EventsTableReferences(
                        db,
                        table,
                        p0,
                      ).eventPlayersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.eventId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      EventRow,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (EventRow, $$EventsTableReferences),
      EventRow,
      PrefetchHooks Function({bool gameId, bool eventPlayersRefs})
    >;
typedef $$EventPlayersTableCreateCompanionBuilder =
    EventPlayersCompanion Function({
      required String id,
      required String eventId,
      required String role,
      required String team,
      required int jerseyNumber,
      Value<int> rowid,
    });
typedef $$EventPlayersTableUpdateCompanionBuilder =
    EventPlayersCompanion Function({
      Value<String> id,
      Value<String> eventId,
      Value<String> role,
      Value<String> team,
      Value<int> jerseyNumber,
      Value<int> rowid,
    });

final class $$EventPlayersTableReferences
    extends BaseReferences<_$AppDatabase, $EventPlayersTable, EventPlayerRow> {
  $$EventPlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events.createAlias(
    $_aliasNameGenerator(db.eventPlayers.eventId, db.events.id),
  );

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventPlayersTableFilterComposer
    extends Composer<_$AppDatabase, $EventPlayersTable> {
  $$EventPlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get team => $composableBuilder(
    column: $table.team,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => ColumnFilters(column),
  );

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventPlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $EventPlayersTable> {
  $$EventPlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get team => $composableBuilder(
    column: $table.team,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventPlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventPlayersTable> {
  $$EventPlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get team =>
      $composableBuilder(column: $table.team, builder: (column) => column);

  GeneratedColumn<int> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => column,
  );

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventPlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventPlayersTable,
          EventPlayerRow,
          $$EventPlayersTableFilterComposer,
          $$EventPlayersTableOrderingComposer,
          $$EventPlayersTableAnnotationComposer,
          $$EventPlayersTableCreateCompanionBuilder,
          $$EventPlayersTableUpdateCompanionBuilder,
          (EventPlayerRow, $$EventPlayersTableReferences),
          EventPlayerRow,
          PrefetchHooks Function({bool eventId})
        > {
  $$EventPlayersTableTableManager(_$AppDatabase db, $EventPlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventPlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventPlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventPlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> team = const Value.absent(),
                Value<int> jerseyNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventPlayersCompanion(
                id: id,
                eventId: eventId,
                role: role,
                team: team,
                jerseyNumber: jerseyNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventId,
                required String role,
                required String team,
                required int jerseyNumber,
                Value<int> rowid = const Value.absent(),
              }) => EventPlayersCompanion.insert(
                id: id,
                eventId: eventId,
                role: role,
                team: team,
                jerseyNumber: jerseyNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventPlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable: $$EventPlayersTableReferences
                                    ._eventIdTable(db),
                                referencedColumn: $$EventPlayersTableReferences
                                    ._eventIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventPlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventPlayersTable,
      EventPlayerRow,
      $$EventPlayersTableFilterComposer,
      $$EventPlayersTableOrderingComposer,
      $$EventPlayersTableAnnotationComposer,
      $$EventPlayersTableCreateCompanionBuilder,
      $$EventPlayersTableUpdateCompanionBuilder,
      (EventPlayerRow, $$EventPlayersTableReferences),
      EventPlayerRow,
      PrefetchHooks Function({bool eventId})
    >;
typedef $$SquadsTableCreateCompanionBuilder =
    SquadsCompanion Function({
      required String gameId,
      required String team,
      required String jerseyNumbers,
      Value<int> rowid,
    });
typedef $$SquadsTableUpdateCompanionBuilder =
    SquadsCompanion Function({
      Value<String> gameId,
      Value<String> team,
      Value<String> jerseyNumbers,
      Value<int> rowid,
    });

final class $$SquadsTableReferences
    extends BaseReferences<_$AppDatabase, $SquadsTable, SquadRow> {
  $$SquadsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias($_aliasNameGenerator(db.squads.gameId, db.games.id));

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SquadsTableFilterComposer
    extends Composer<_$AppDatabase, $SquadsTable> {
  $$SquadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get team => $composableBuilder(
    column: $table.team,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jerseyNumbers => $composableBuilder(
    column: $table.jerseyNumbers,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SquadsTableOrderingComposer
    extends Composer<_$AppDatabase, $SquadsTable> {
  $$SquadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get team => $composableBuilder(
    column: $table.team,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jerseyNumbers => $composableBuilder(
    column: $table.jerseyNumbers,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SquadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SquadsTable> {
  $$SquadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get team =>
      $composableBuilder(column: $table.team, builder: (column) => column);

  GeneratedColumn<String> get jerseyNumbers => $composableBuilder(
    column: $table.jerseyNumbers,
    builder: (column) => column,
  );

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SquadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SquadsTable,
          SquadRow,
          $$SquadsTableFilterComposer,
          $$SquadsTableOrderingComposer,
          $$SquadsTableAnnotationComposer,
          $$SquadsTableCreateCompanionBuilder,
          $$SquadsTableUpdateCompanionBuilder,
          (SquadRow, $$SquadsTableReferences),
          SquadRow,
          PrefetchHooks Function({bool gameId})
        > {
  $$SquadsTableTableManager(_$AppDatabase db, $SquadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SquadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SquadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SquadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> team = const Value.absent(),
                Value<String> jerseyNumbers = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SquadsCompanion(
                gameId: gameId,
                team: team,
                jerseyNumbers: jerseyNumbers,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gameId,
                required String team,
                required String jerseyNumbers,
                Value<int> rowid = const Value.absent(),
              }) => SquadsCompanion.insert(
                gameId: gameId,
                team: team,
                jerseyNumbers: jerseyNumbers,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SquadsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$SquadsTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$SquadsTableReferences
                                    ._gameIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SquadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SquadsTable,
      SquadRow,
      $$SquadsTableFilterComposer,
      $$SquadsTableOrderingComposer,
      $$SquadsTableAnnotationComposer,
      $$SquadsTableCreateCompanionBuilder,
      $$SquadsTableUpdateCompanionBuilder,
      (SquadRow, $$SquadsTableReferences),
      SquadRow,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$TimerStatesTableCreateCompanionBuilder =
    TimerStatesCompanion Function({
      required String gameId,
      Value<bool> isRunning,
      Value<DateTime?> startTimestamp,
      Value<int> elapsedMs,
      Value<int> rowid,
    });
typedef $$TimerStatesTableUpdateCompanionBuilder =
    TimerStatesCompanion Function({
      Value<String> gameId,
      Value<bool> isRunning,
      Value<DateTime?> startTimestamp,
      Value<int> elapsedMs,
      Value<int> rowid,
    });

final class $$TimerStatesTableReferences
    extends BaseReferences<_$AppDatabase, $TimerStatesTable, TimerStateRow> {
  $$TimerStatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.timerStates.gameId, db.games.id),
  );

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimerStatesTableFilterComposer
    extends Composer<_$AppDatabase, $TimerStatesTable> {
  $$TimerStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isRunning => $composableBuilder(
    column: $table.isRunning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTimestamp => $composableBuilder(
    column: $table.startTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerStatesTable> {
  $$TimerStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isRunning => $composableBuilder(
    column: $table.isRunning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTimestamp => $composableBuilder(
    column: $table.startTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerStatesTable> {
  $$TimerStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isRunning =>
      $composableBuilder(column: $table.isRunning, builder: (column) => column);

  GeneratedColumn<DateTime> get startTimestamp => $composableBuilder(
    column: $table.startTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerStatesTable,
          TimerStateRow,
          $$TimerStatesTableFilterComposer,
          $$TimerStatesTableOrderingComposer,
          $$TimerStatesTableAnnotationComposer,
          $$TimerStatesTableCreateCompanionBuilder,
          $$TimerStatesTableUpdateCompanionBuilder,
          (TimerStateRow, $$TimerStatesTableReferences),
          TimerStateRow,
          PrefetchHooks Function({bool gameId})
        > {
  $$TimerStatesTableTableManager(_$AppDatabase db, $TimerStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<bool> isRunning = const Value.absent(),
                Value<DateTime?> startTimestamp = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerStatesCompanion(
                gameId: gameId,
                isRunning: isRunning,
                startTimestamp: startTimestamp,
                elapsedMs: elapsedMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gameId,
                Value<bool> isRunning = const Value.absent(),
                Value<DateTime?> startTimestamp = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerStatesCompanion.insert(
                gameId: gameId,
                isRunning: isRunning,
                startTimestamp: startTimestamp,
                elapsedMs: elapsedMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimerStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$TimerStatesTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$TimerStatesTableReferences
                                    ._gameIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimerStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerStatesTable,
      TimerStateRow,
      $$TimerStatesTableFilterComposer,
      $$TimerStatesTableOrderingComposer,
      $$TimerStatesTableAnnotationComposer,
      $$TimerStatesTableCreateCompanionBuilder,
      $$TimerStatesTableUpdateCompanionBuilder,
      (TimerStateRow, $$TimerStatesTableReferences),
      TimerStateRow,
      PrefetchHooks Function({bool gameId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$EventPlayersTableTableManager get eventPlayers =>
      $$EventPlayersTableTableManager(_db, _db.eventPlayers);
  $$SquadsTableTableManager get squads =>
      $$SquadsTableTableManager(_db, _db.squads);
  $$TimerStatesTableTableManager get timerStates =>
      $$TimerStatesTableTableManager(_db, _db.timerStates);
}
