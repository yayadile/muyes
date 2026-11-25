// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FoodLogsTable extends FoodLogs
    with TableInfo<$FoodLogsTable, FoodLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eatenAtMeta = const VerificationMeta(
    'eatenAt',
  );
  @override
  late final GeneratedColumn<DateTime> eatenAt = GeneratedColumn<DateTime>(
    'eaten_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> categories =
      GeneratedColumn<String>(
        'categories',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($FoodLogsTable.$convertercategories);
  static const VerificationMeta _spicyLevelMeta = const VerificationMeta(
    'spicyLevel',
  );
  @override
  late final GeneratedColumn<int> spicyLevel = GeneratedColumn<int>(
    'spicy_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _portionMeta = const VerificationMeta(
    'portion',
  );
  @override
  late final GeneratedColumn<String> portion = GeneratedColumn<String>(
    'portion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(FoodPortion.sedang),
  );
  static const VerificationMeta _drinkMeta = const VerificationMeta('drink');
  @override
  late final GeneratedColumn<String> drink = GeneratedColumn<String>(
    'drink',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eatenAt,
    foodName,
    categories,
    spicyLevel,
    portion,
    drink,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('eaten_at')) {
      context.handle(
        _eatenAtMeta,
        eatenAt.isAcceptableOrUnknown(data['eaten_at']!, _eatenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_eatenAtMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('spicy_level')) {
      context.handle(
        _spicyLevelMeta,
        spicyLevel.isAcceptableOrUnknown(data['spicy_level']!, _spicyLevelMeta),
      );
    }
    if (data.containsKey('portion')) {
      context.handle(
        _portionMeta,
        portion.isAcceptableOrUnknown(data['portion']!, _portionMeta),
      );
    }
    if (data.containsKey('drink')) {
      context.handle(
        _drinkMeta,
        drink.isAcceptableOrUnknown(data['drink']!, _drinkMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eatenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eaten_at'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      categories: $FoodLogsTable.$convertercategories.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}categories'],
        )!,
      ),
      spicyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spicy_level'],
      )!,
      portion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portion'],
      )!,
      drink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drink'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoodLogsTable createAlias(String alias) {
    return $FoodLogsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertercategories =
      const JsonStringListConverter();
}

class FoodLogRow extends DataClass implements Insertable<FoodLogRow> {
  final String id;
  final DateTime eatenAt;
  final String foodName;
  final List<String> categories;
  final int spicyLevel;
  final String portion;
  final String? drink;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FoodLogRow({
    required this.id,
    required this.eatenAt,
    required this.foodName,
    required this.categories,
    required this.spicyLevel,
    required this.portion,
    this.drink,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['eaten_at'] = Variable<DateTime>(eatenAt);
    map['food_name'] = Variable<String>(foodName);
    {
      map['categories'] = Variable<String>(
        $FoodLogsTable.$convertercategories.toSql(categories),
      );
    }
    map['spicy_level'] = Variable<int>(spicyLevel);
    map['portion'] = Variable<String>(portion);
    if (!nullToAbsent || drink != null) {
      map['drink'] = Variable<String>(drink);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoodLogsCompanion toCompanion(bool nullToAbsent) {
    return FoodLogsCompanion(
      id: Value(id),
      eatenAt: Value(eatenAt),
      foodName: Value(foodName),
      categories: Value(categories),
      spicyLevel: Value(spicyLevel),
      portion: Value(portion),
      drink: drink == null && nullToAbsent
          ? const Value.absent()
          : Value(drink),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FoodLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLogRow(
      id: serializer.fromJson<String>(json['id']),
      eatenAt: serializer.fromJson<DateTime>(json['eatenAt']),
      foodName: serializer.fromJson<String>(json['foodName']),
      categories: serializer.fromJson<List<String>>(json['categories']),
      spicyLevel: serializer.fromJson<int>(json['spicyLevel']),
      portion: serializer.fromJson<String>(json['portion']),
      drink: serializer.fromJson<String?>(json['drink']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eatenAt': serializer.toJson<DateTime>(eatenAt),
      'foodName': serializer.toJson<String>(foodName),
      'categories': serializer.toJson<List<String>>(categories),
      'spicyLevel': serializer.toJson<int>(spicyLevel),
      'portion': serializer.toJson<String>(portion),
      'drink': serializer.toJson<String?>(drink),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FoodLogRow copyWith({
    String? id,
    DateTime? eatenAt,
    String? foodName,
    List<String>? categories,
    int? spicyLevel,
    String? portion,
    Value<String?> drink = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FoodLogRow(
    id: id ?? this.id,
    eatenAt: eatenAt ?? this.eatenAt,
    foodName: foodName ?? this.foodName,
    categories: categories ?? this.categories,
    spicyLevel: spicyLevel ?? this.spicyLevel,
    portion: portion ?? this.portion,
    drink: drink.present ? drink.value : this.drink,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FoodLogRow copyWithCompanion(FoodLogsCompanion data) {
    return FoodLogRow(
      id: data.id.present ? data.id.value : this.id,
      eatenAt: data.eatenAt.present ? data.eatenAt.value : this.eatenAt,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      categories: data.categories.present
          ? data.categories.value
          : this.categories,
      spicyLevel: data.spicyLevel.present
          ? data.spicyLevel.value
          : this.spicyLevel,
      portion: data.portion.present ? data.portion.value : this.portion,
      drink: data.drink.present ? data.drink.value : this.drink,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogRow(')
          ..write('id: $id, ')
          ..write('eatenAt: $eatenAt, ')
          ..write('foodName: $foodName, ')
          ..write('categories: $categories, ')
          ..write('spicyLevel: $spicyLevel, ')
          ..write('portion: $portion, ')
          ..write('drink: $drink, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eatenAt,
    foodName,
    categories,
    spicyLevel,
    portion,
    drink,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLogRow &&
          other.id == this.id &&
          other.eatenAt == this.eatenAt &&
          other.foodName == this.foodName &&
          other.categories == this.categories &&
          other.spicyLevel == this.spicyLevel &&
          other.portion == this.portion &&
          other.drink == this.drink &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoodLogsCompanion extends UpdateCompanion<FoodLogRow> {
  final Value<String> id;
  final Value<DateTime> eatenAt;
  final Value<String> foodName;
  final Value<List<String>> categories;
  final Value<int> spicyLevel;
  final Value<String> portion;
  final Value<String?> drink;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FoodLogsCompanion({
    this.id = const Value.absent(),
    this.eatenAt = const Value.absent(),
    this.foodName = const Value.absent(),
    this.categories = const Value.absent(),
    this.spicyLevel = const Value.absent(),
    this.portion = const Value.absent(),
    this.drink = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodLogsCompanion.insert({
    required String id,
    required DateTime eatenAt,
    required String foodName,
    required List<String> categories,
    this.spicyLevel = const Value.absent(),
    this.portion = const Value.absent(),
    this.drink = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eatenAt = Value(eatenAt),
       foodName = Value(foodName),
       categories = Value(categories),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FoodLogRow> custom({
    Expression<String>? id,
    Expression<DateTime>? eatenAt,
    Expression<String>? foodName,
    Expression<String>? categories,
    Expression<int>? spicyLevel,
    Expression<String>? portion,
    Expression<String>? drink,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eatenAt != null) 'eaten_at': eatenAt,
      if (foodName != null) 'food_name': foodName,
      if (categories != null) 'categories': categories,
      if (spicyLevel != null) 'spicy_level': spicyLevel,
      if (portion != null) 'portion': portion,
      if (drink != null) 'drink': drink,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? eatenAt,
    Value<String>? foodName,
    Value<List<String>>? categories,
    Value<int>? spicyLevel,
    Value<String>? portion,
    Value<String?>? drink,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FoodLogsCompanion(
      id: id ?? this.id,
      eatenAt: eatenAt ?? this.eatenAt,
      foodName: foodName ?? this.foodName,
      categories: categories ?? this.categories,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      portion: portion ?? this.portion,
      drink: drink ?? this.drink,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eatenAt.present) {
      map['eaten_at'] = Variable<DateTime>(eatenAt.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (categories.present) {
      map['categories'] = Variable<String>(
        $FoodLogsTable.$convertercategories.toSql(categories.value),
      );
    }
    if (spicyLevel.present) {
      map['spicy_level'] = Variable<int>(spicyLevel.value);
    }
    if (portion.present) {
      map['portion'] = Variable<String>(portion.value);
    }
    if (drink.present) {
      map['drink'] = Variable<String>(drink.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogsCompanion(')
          ..write('id: $id, ')
          ..write('eatenAt: $eatenAt, ')
          ..write('foodName: $foodName, ')
          ..write('categories: $categories, ')
          ..write('spicyLevel: $spicyLevel, ')
          ..write('portion: $portion, ')
          ..write('drink: $drink, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PoopLogsTable extends PoopLogs
    with TableInfo<$PoopLogsTable, PoopLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoopLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poopedAtMeta = const VerificationMeta(
    'poopedAt',
  );
  @override
  late final GeneratedColumn<DateTime> poopedAt = GeneratedColumn<DateTime>(
    'pooped_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bristolMeta = const VerificationMeta(
    'bristol',
  );
  @override
  late final GeneratedColumn<int> bristol = GeneratedColumn<int>(
    'bristol',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urgencyMeta = const VerificationMeta(
    'urgency',
  );
  @override
  late final GeneratedColumn<int> urgency = GeneratedColumn<int>(
    'urgency',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _painLevelMeta = const VerificationMeta(
    'painLevel',
  );
  @override
  late final GeneratedColumn<int> painLevel = GeneratedColumn<int>(
    'pain_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasBloodMeta = const VerificationMeta(
    'hasBlood',
  );
  @override
  late final GeneratedColumn<bool> hasBlood = GeneratedColumn<bool>(
    'has_blood',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_blood" IN (0, 1))',
    ),
  );
  static const VerificationMeta _hasMucusMeta = const VerificationMeta(
    'hasMucus',
  );
  @override
  late final GeneratedColumn<bool> hasMucus = GeneratedColumn<bool>(
    'has_mucus',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_mucus" IN (0, 1))',
    ),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    poopedAt,
    bristol,
    color,
    urgency,
    painLevel,
    hasBlood,
    hasMucus,
    duration,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'poop_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PoopLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pooped_at')) {
      context.handle(
        _poopedAtMeta,
        poopedAt.isAcceptableOrUnknown(data['pooped_at']!, _poopedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_poopedAtMeta);
    }
    if (data.containsKey('bristol')) {
      context.handle(
        _bristolMeta,
        bristol.isAcceptableOrUnknown(data['bristol']!, _bristolMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('urgency')) {
      context.handle(
        _urgencyMeta,
        urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta),
      );
    }
    if (data.containsKey('pain_level')) {
      context.handle(
        _painLevelMeta,
        painLevel.isAcceptableOrUnknown(data['pain_level']!, _painLevelMeta),
      );
    }
    if (data.containsKey('has_blood')) {
      context.handle(
        _hasBloodMeta,
        hasBlood.isAcceptableOrUnknown(data['has_blood']!, _hasBloodMeta),
      );
    }
    if (data.containsKey('has_mucus')) {
      context.handle(
        _hasMucusMeta,
        hasMucus.isAcceptableOrUnknown(data['has_mucus']!, _hasMucusMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoopLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoopLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      poopedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pooped_at'],
      )!,
      bristol: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bristol'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      urgency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}urgency'],
      ),
      painLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pain_level'],
      ),
      hasBlood: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_blood'],
      ),
      hasMucus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_mucus'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PoopLogsTable createAlias(String alias) {
    return $PoopLogsTable(attachedDatabase, alias);
  }
}

class PoopLogRow extends DataClass implements Insertable<PoopLogRow> {
  final String id;
  final DateTime poopedAt;
  final int? bristol;
  final String? color;
  final int? urgency;
  final int? painLevel;
  final bool? hasBlood;
  final bool? hasMucus;
  final String? duration;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PoopLogRow({
    required this.id,
    required this.poopedAt,
    this.bristol,
    this.color,
    this.urgency,
    this.painLevel,
    this.hasBlood,
    this.hasMucus,
    this.duration,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pooped_at'] = Variable<DateTime>(poopedAt);
    if (!nullToAbsent || bristol != null) {
      map['bristol'] = Variable<int>(bristol);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || urgency != null) {
      map['urgency'] = Variable<int>(urgency);
    }
    if (!nullToAbsent || painLevel != null) {
      map['pain_level'] = Variable<int>(painLevel);
    }
    if (!nullToAbsent || hasBlood != null) {
      map['has_blood'] = Variable<bool>(hasBlood);
    }
    if (!nullToAbsent || hasMucus != null) {
      map['has_mucus'] = Variable<bool>(hasMucus);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<String>(duration);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PoopLogsCompanion toCompanion(bool nullToAbsent) {
    return PoopLogsCompanion(
      id: Value(id),
      poopedAt: Value(poopedAt),
      bristol: bristol == null && nullToAbsent
          ? const Value.absent()
          : Value(bristol),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      urgency: urgency == null && nullToAbsent
          ? const Value.absent()
          : Value(urgency),
      painLevel: painLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(painLevel),
      hasBlood: hasBlood == null && nullToAbsent
          ? const Value.absent()
          : Value(hasBlood),
      hasMucus: hasMucus == null && nullToAbsent
          ? const Value.absent()
          : Value(hasMucus),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PoopLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoopLogRow(
      id: serializer.fromJson<String>(json['id']),
      poopedAt: serializer.fromJson<DateTime>(json['poopedAt']),
      bristol: serializer.fromJson<int?>(json['bristol']),
      color: serializer.fromJson<String?>(json['color']),
      urgency: serializer.fromJson<int?>(json['urgency']),
      painLevel: serializer.fromJson<int?>(json['painLevel']),
      hasBlood: serializer.fromJson<bool?>(json['hasBlood']),
      hasMucus: serializer.fromJson<bool?>(json['hasMucus']),
      duration: serializer.fromJson<String?>(json['duration']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poopedAt': serializer.toJson<DateTime>(poopedAt),
      'bristol': serializer.toJson<int?>(bristol),
      'color': serializer.toJson<String?>(color),
      'urgency': serializer.toJson<int?>(urgency),
      'painLevel': serializer.toJson<int?>(painLevel),
      'hasBlood': serializer.toJson<bool?>(hasBlood),
      'hasMucus': serializer.toJson<bool?>(hasMucus),
      'duration': serializer.toJson<String?>(duration),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PoopLogRow copyWith({
    String? id,
    DateTime? poopedAt,
    Value<int?> bristol = const Value.absent(),
    Value<String?> color = const Value.absent(),
    Value<int?> urgency = const Value.absent(),
    Value<int?> painLevel = const Value.absent(),
    Value<bool?> hasBlood = const Value.absent(),
    Value<bool?> hasMucus = const Value.absent(),
    Value<String?> duration = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PoopLogRow(
    id: id ?? this.id,
    poopedAt: poopedAt ?? this.poopedAt,
    bristol: bristol.present ? bristol.value : this.bristol,
    color: color.present ? color.value : this.color,
    urgency: urgency.present ? urgency.value : this.urgency,
    painLevel: painLevel.present ? painLevel.value : this.painLevel,
    hasBlood: hasBlood.present ? hasBlood.value : this.hasBlood,
    hasMucus: hasMucus.present ? hasMucus.value : this.hasMucus,
    duration: duration.present ? duration.value : this.duration,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PoopLogRow copyWithCompanion(PoopLogsCompanion data) {
    return PoopLogRow(
      id: data.id.present ? data.id.value : this.id,
      poopedAt: data.poopedAt.present ? data.poopedAt.value : this.poopedAt,
      bristol: data.bristol.present ? data.bristol.value : this.bristol,
      color: data.color.present ? data.color.value : this.color,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      painLevel: data.painLevel.present ? data.painLevel.value : this.painLevel,
      hasBlood: data.hasBlood.present ? data.hasBlood.value : this.hasBlood,
      hasMucus: data.hasMucus.present ? data.hasMucus.value : this.hasMucus,
      duration: data.duration.present ? data.duration.value : this.duration,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoopLogRow(')
          ..write('id: $id, ')
          ..write('poopedAt: $poopedAt, ')
          ..write('bristol: $bristol, ')
          ..write('color: $color, ')
          ..write('urgency: $urgency, ')
          ..write('painLevel: $painLevel, ')
          ..write('hasBlood: $hasBlood, ')
          ..write('hasMucus: $hasMucus, ')
          ..write('duration: $duration, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    poopedAt,
    bristol,
    color,
    urgency,
    painLevel,
    hasBlood,
    hasMucus,
    duration,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoopLogRow &&
          other.id == this.id &&
          other.poopedAt == this.poopedAt &&
          other.bristol == this.bristol &&
          other.color == this.color &&
          other.urgency == this.urgency &&
          other.painLevel == this.painLevel &&
          other.hasBlood == this.hasBlood &&
          other.hasMucus == this.hasMucus &&
          other.duration == this.duration &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PoopLogsCompanion extends UpdateCompanion<PoopLogRow> {
  final Value<String> id;
  final Value<DateTime> poopedAt;
  final Value<int?> bristol;
  final Value<String?> color;
  final Value<int?> urgency;
  final Value<int?> painLevel;
  final Value<bool?> hasBlood;
  final Value<bool?> hasMucus;
  final Value<String?> duration;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PoopLogsCompanion({
    this.id = const Value.absent(),
    this.poopedAt = const Value.absent(),
    this.bristol = const Value.absent(),
    this.color = const Value.absent(),
    this.urgency = const Value.absent(),
    this.painLevel = const Value.absent(),
    this.hasBlood = const Value.absent(),
    this.hasMucus = const Value.absent(),
    this.duration = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PoopLogsCompanion.insert({
    required String id,
    required DateTime poopedAt,
    this.bristol = const Value.absent(),
    this.color = const Value.absent(),
    this.urgency = const Value.absent(),
    this.painLevel = const Value.absent(),
    this.hasBlood = const Value.absent(),
    this.hasMucus = const Value.absent(),
    this.duration = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       poopedAt = Value(poopedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PoopLogRow> custom({
    Expression<String>? id,
    Expression<DateTime>? poopedAt,
    Expression<int>? bristol,
    Expression<String>? color,
    Expression<int>? urgency,
    Expression<int>? painLevel,
    Expression<bool>? hasBlood,
    Expression<bool>? hasMucus,
    Expression<String>? duration,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poopedAt != null) 'pooped_at': poopedAt,
      if (bristol != null) 'bristol': bristol,
      if (color != null) 'color': color,
      if (urgency != null) 'urgency': urgency,
      if (painLevel != null) 'pain_level': painLevel,
      if (hasBlood != null) 'has_blood': hasBlood,
      if (hasMucus != null) 'has_mucus': hasMucus,
      if (duration != null) 'duration': duration,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PoopLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? poopedAt,
    Value<int?>? bristol,
    Value<String?>? color,
    Value<int?>? urgency,
    Value<int?>? painLevel,
    Value<bool?>? hasBlood,
    Value<bool?>? hasMucus,
    Value<String?>? duration,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PoopLogsCompanion(
      id: id ?? this.id,
      poopedAt: poopedAt ?? this.poopedAt,
      bristol: bristol ?? this.bristol,
      color: color ?? this.color,
      urgency: urgency ?? this.urgency,
      painLevel: painLevel ?? this.painLevel,
      hasBlood: hasBlood ?? this.hasBlood,
      hasMucus: hasMucus ?? this.hasMucus,
      duration: duration ?? this.duration,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poopedAt.present) {
      map['pooped_at'] = Variable<DateTime>(poopedAt.value);
    }
    if (bristol.present) {
      map['bristol'] = Variable<int>(bristol.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (urgency.present) {
      map['urgency'] = Variable<int>(urgency.value);
    }
    if (painLevel.present) {
      map['pain_level'] = Variable<int>(painLevel.value);
    }
    if (hasBlood.present) {
      map['has_blood'] = Variable<bool>(hasBlood.value);
    }
    if (hasMucus.present) {
      map['has_mucus'] = Variable<bool>(hasMucus.value);
    }
    if (duration.present) {
      map['duration'] = Variable<String>(duration.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoopLogsCompanion(')
          ..write('id: $id, ')
          ..write('poopedAt: $poopedAt, ')
          ..write('bristol: $bristol, ')
          ..write('color: $color, ')
          ..write('urgency: $urgency, ')
          ..write('painLevel: $painLevel, ')
          ..write('hasBlood: $hasBlood, ')
          ..write('hasMucus: $hasMucus, ')
          ..write('duration: $duration, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MulesLogsTable extends MulesLogs
    with TableInfo<$MulesLogsTable, MulesLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MulesLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feltAtMeta = const VerificationMeta('feltAt');
  @override
  late final GeneratedColumn<DateTime> feltAt = GeneratedColumn<DateTime>(
    'felt_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _painLevelMeta = const VerificationMeta(
    'painLevel',
  );
  @override
  late final GeneratedColumn<int> painLevel = GeneratedColumn<int>(
    'pain_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feltAt,
    painLevel,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mules_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MulesLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('felt_at')) {
      context.handle(
        _feltAtMeta,
        feltAt.isAcceptableOrUnknown(data['felt_at']!, _feltAtMeta),
      );
    } else if (isInserting) {
      context.missing(_feltAtMeta);
    }
    if (data.containsKey('pain_level')) {
      context.handle(
        _painLevelMeta,
        painLevel.isAcceptableOrUnknown(data['pain_level']!, _painLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_painLevelMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MulesLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MulesLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      feltAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}felt_at'],
      )!,
      painLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pain_level'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MulesLogsTable createAlias(String alias) {
    return $MulesLogsTable(attachedDatabase, alias);
  }
}

class MulesLogRow extends DataClass implements Insertable<MulesLogRow> {
  final String id;
  final DateTime feltAt;
  final int painLevel;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MulesLogRow({
    required this.id,
    required this.feltAt,
    required this.painLevel,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['felt_at'] = Variable<DateTime>(feltAt);
    map['pain_level'] = Variable<int>(painLevel);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MulesLogsCompanion toCompanion(bool nullToAbsent) {
    return MulesLogsCompanion(
      id: Value(id),
      feltAt: Value(feltAt),
      painLevel: Value(painLevel),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MulesLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MulesLogRow(
      id: serializer.fromJson<String>(json['id']),
      feltAt: serializer.fromJson<DateTime>(json['feltAt']),
      painLevel: serializer.fromJson<int>(json['painLevel']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'feltAt': serializer.toJson<DateTime>(feltAt),
      'painLevel': serializer.toJson<int>(painLevel),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MulesLogRow copyWith({
    String? id,
    DateTime? feltAt,
    int? painLevel,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MulesLogRow(
    id: id ?? this.id,
    feltAt: feltAt ?? this.feltAt,
    painLevel: painLevel ?? this.painLevel,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MulesLogRow copyWithCompanion(MulesLogsCompanion data) {
    return MulesLogRow(
      id: data.id.present ? data.id.value : this.id,
      feltAt: data.feltAt.present ? data.feltAt.value : this.feltAt,
      painLevel: data.painLevel.present ? data.painLevel.value : this.painLevel,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MulesLogRow(')
          ..write('id: $id, ')
          ..write('feltAt: $feltAt, ')
          ..write('painLevel: $painLevel, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, feltAt, painLevel, note, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MulesLogRow &&
          other.id == this.id &&
          other.feltAt == this.feltAt &&
          other.painLevel == this.painLevel &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MulesLogsCompanion extends UpdateCompanion<MulesLogRow> {
  final Value<String> id;
  final Value<DateTime> feltAt;
  final Value<int> painLevel;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MulesLogsCompanion({
    this.id = const Value.absent(),
    this.feltAt = const Value.absent(),
    this.painLevel = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MulesLogsCompanion.insert({
    required String id,
    required DateTime feltAt,
    required int painLevel,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       feltAt = Value(feltAt),
       painLevel = Value(painLevel),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MulesLogRow> custom({
    Expression<String>? id,
    Expression<DateTime>? feltAt,
    Expression<int>? painLevel,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feltAt != null) 'felt_at': feltAt,
      if (painLevel != null) 'pain_level': painLevel,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MulesLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? feltAt,
    Value<int>? painLevel,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MulesLogsCompanion(
      id: id ?? this.id,
      feltAt: feltAt ?? this.feltAt,
      painLevel: painLevel ?? this.painLevel,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (feltAt.present) {
      map['felt_at'] = Variable<DateTime>(feltAt.value);
    }
    if (painLevel.present) {
      map['pain_level'] = Variable<int>(painLevel.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MulesLogsCompanion(')
          ..write('id: $id, ')
          ..write('feltAt: $feltAt, ')
          ..write('painLevel: $painLevel, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InsightsTable extends Insights
    with TableInfo<$InsightsTable, InsightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  evidenceLogIds = GeneratedColumn<String>(
    'evidence_log_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($InsightsTable.$converterevidenceLogIds);
  static const VerificationMeta _periodDaysMeta = const VerificationMeta(
    'periodDays',
  );
  @override
  late final GeneratedColumn<int> periodDays = GeneratedColumn<int>(
    'period_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
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
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    level,
    title,
    body,
    confidence,
    evidenceLogIds,
    periodDays,
    createdAt,
    isRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insights';
  @override
  VerificationContext validateIntegrity(
    Insertable<InsightRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('period_days')) {
      context.handle(
        _periodDaysMeta,
        periodDays.isAcceptableOrUnknown(data['period_days']!, _periodDaysMeta),
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
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InsightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsightRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
      evidenceLogIds: $InsightsTable.$converterevidenceLogIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}evidence_log_ids'],
        )!,
      ),
      periodDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_days'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
    );
  }

  @override
  $InsightsTable createAlias(String alias) {
    return $InsightsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterevidenceLogIds =
      const JsonStringListConverter();
}

class InsightRow extends DataClass implements Insertable<InsightRow> {
  final String id;
  final String type;
  final String level;
  final String title;
  final String body;
  final String confidence;
  final List<String> evidenceLogIds;
  final int periodDays;
  final DateTime createdAt;
  final bool isRead;
  const InsightRow({
    required this.id,
    required this.type,
    required this.level,
    required this.title,
    required this.body,
    required this.confidence,
    required this.evidenceLogIds,
    required this.periodDays,
    required this.createdAt,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['level'] = Variable<String>(level);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['confidence'] = Variable<String>(confidence);
    {
      map['evidence_log_ids'] = Variable<String>(
        $InsightsTable.$converterevidenceLogIds.toSql(evidenceLogIds),
      );
    }
    map['period_days'] = Variable<int>(periodDays);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  InsightsCompanion toCompanion(bool nullToAbsent) {
    return InsightsCompanion(
      id: Value(id),
      type: Value(type),
      level: Value(level),
      title: Value(title),
      body: Value(body),
      confidence: Value(confidence),
      evidenceLogIds: Value(evidenceLogIds),
      periodDays: Value(periodDays),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
    );
  }

  factory InsightRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsightRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      level: serializer.fromJson<String>(json['level']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      confidence: serializer.fromJson<String>(json['confidence']),
      evidenceLogIds: serializer.fromJson<List<String>>(json['evidenceLogIds']),
      periodDays: serializer.fromJson<int>(json['periodDays']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'level': serializer.toJson<String>(level),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'confidence': serializer.toJson<String>(confidence),
      'evidenceLogIds': serializer.toJson<List<String>>(evidenceLogIds),
      'periodDays': serializer.toJson<int>(periodDays),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  InsightRow copyWith({
    String? id,
    String? type,
    String? level,
    String? title,
    String? body,
    String? confidence,
    List<String>? evidenceLogIds,
    int? periodDays,
    DateTime? createdAt,
    bool? isRead,
  }) => InsightRow(
    id: id ?? this.id,
    type: type ?? this.type,
    level: level ?? this.level,
    title: title ?? this.title,
    body: body ?? this.body,
    confidence: confidence ?? this.confidence,
    evidenceLogIds: evidenceLogIds ?? this.evidenceLogIds,
    periodDays: periodDays ?? this.periodDays,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
  );
  InsightRow copyWithCompanion(InsightsCompanion data) {
    return InsightRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      level: data.level.present ? data.level.value : this.level,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      evidenceLogIds: data.evidenceLogIds.present
          ? data.evidenceLogIds.value
          : this.evidenceLogIds,
      periodDays: data.periodDays.present
          ? data.periodDays.value
          : this.periodDays,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsightRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('confidence: $confidence, ')
          ..write('evidenceLogIds: $evidenceLogIds, ')
          ..write('periodDays: $periodDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    level,
    title,
    body,
    confidence,
    evidenceLogIds,
    periodDays,
    createdAt,
    isRead,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsightRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.level == this.level &&
          other.title == this.title &&
          other.body == this.body &&
          other.confidence == this.confidence &&
          other.evidenceLogIds == this.evidenceLogIds &&
          other.periodDays == this.periodDays &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead);
}

class InsightsCompanion extends UpdateCompanion<InsightRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> level;
  final Value<String> title;
  final Value<String> body;
  final Value<String> confidence;
  final Value<List<String>> evidenceLogIds;
  final Value<int> periodDays;
  final Value<DateTime> createdAt;
  final Value<bool> isRead;
  final Value<int> rowid;
  const InsightsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.level = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.confidence = const Value.absent(),
    this.evidenceLogIds = const Value.absent(),
    this.periodDays = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsightsCompanion.insert({
    required String id,
    required String type,
    required String level,
    required String title,
    required String body,
    required String confidence,
    required List<String> evidenceLogIds,
    this.periodDays = const Value.absent(),
    required DateTime createdAt,
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       level = Value(level),
       title = Value(title),
       body = Value(body),
       confidence = Value(confidence),
       evidenceLogIds = Value(evidenceLogIds),
       createdAt = Value(createdAt);
  static Insertable<InsightRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? level,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? confidence,
    Expression<String>? evidenceLogIds,
    Expression<int>? periodDays,
    Expression<DateTime>? createdAt,
    Expression<bool>? isRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (level != null) 'level': level,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (confidence != null) 'confidence': confidence,
      if (evidenceLogIds != null) 'evidence_log_ids': evidenceLogIds,
      if (periodDays != null) 'period_days': periodDays,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsightsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? level,
    Value<String>? title,
    Value<String>? body,
    Value<String>? confidence,
    Value<List<String>>? evidenceLogIds,
    Value<int>? periodDays,
    Value<DateTime>? createdAt,
    Value<bool>? isRead,
    Value<int>? rowid,
  }) {
    return InsightsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      level: level ?? this.level,
      title: title ?? this.title,
      body: body ?? this.body,
      confidence: confidence ?? this.confidence,
      evidenceLogIds: evidenceLogIds ?? this.evidenceLogIds,
      periodDays: periodDays ?? this.periodDays,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (evidenceLogIds.present) {
      map['evidence_log_ids'] = Variable<String>(
        $InsightsTable.$converterevidenceLogIds.toSql(evidenceLogIds.value),
      );
    }
    if (periodDays.present) {
      map['period_days'] = Variable<int>(periodDays.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsightsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('confidence: $confidence, ')
          ..write('evidenceLogIds: $evidenceLogIds, ')
          ..write('periodDays: $periodDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodLogsTable foodLogs = $FoodLogsTable(this);
  late final $PoopLogsTable poopLogs = $PoopLogsTable(this);
  late final $MulesLogsTable mulesLogs = $MulesLogsTable(this);
  late final $InsightsTable insights = $InsightsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    foodLogs,
    poopLogs,
    mulesLogs,
    insights,
    appSettings,
  ];
}

typedef $$FoodLogsTableCreateCompanionBuilder = FoodLogsCompanion Function({
  required String id,
  required DateTime eatenAt,
  required String foodName,
  required List<String> categories,
  Value<int> spicyLevel,
  Value<String> portion,
  Value<String?> drink,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FoodLogsTableUpdateCompanionBuilder = FoodLogsCompanion Function({
  Value<String> id,
  Value<DateTime> eatenAt,
  Value<String> foodName,
  Value<List<String>> categories,
  Value<int> spicyLevel,
  Value<String> portion,
  Value<String?> drink,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FoodLogsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get eatenAt => $composableBuilder(
    column: $table.eatenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get spicyLevel => $composableBuilder(
    column: $table.spicyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get portion => $composableBuilder(
    column: $table.portion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drink => $composableBuilder(
    column: $table.drink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get eatenAt => $composableBuilder(
    column: $table.eatenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spicyLevel => $composableBuilder(
    column: $table.spicyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portion => $composableBuilder(
    column: $table.portion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drink => $composableBuilder(
    column: $table.drink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get eatenAt =>
      $composableBuilder(column: $table.eatenAt, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get categories =>
      $composableBuilder(
        column: $table.categories,
        builder: (column) => column,
      );

  GeneratedColumn<int> get spicyLevel => $composableBuilder(
    column: $table.spicyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get portion =>
      $composableBuilder(column: $table.portion, builder: (column) => column);

  GeneratedColumn<String> get drink =>
      $composableBuilder(column: $table.drink, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FoodLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodLogsTable,
          FoodLogRow,
          $$FoodLogsTableFilterComposer,
          $$FoodLogsTableOrderingComposer,
          $$FoodLogsTableAnnotationComposer,
          $$FoodLogsTableCreateCompanionBuilder,
          $$FoodLogsTableUpdateCompanionBuilder,
          (
            FoodLogRow,
            BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLogRow>,
          ),
          FoodLogRow,
          PrefetchHooks Function()
        > {
  $$FoodLogsTableTableManager(_$AppDatabase db, $FoodLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> eatenAt = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<List<String>> categories = const Value.absent(),
                Value<int> spicyLevel = const Value.absent(),
                Value<String> portion = const Value.absent(),
                Value<String?> drink = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodLogsCompanion(
                id: id,
                eatenAt: eatenAt,
                foodName: foodName,
                categories: categories,
                spicyLevel: spicyLevel,
                portion: portion,
                drink: drink,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime eatenAt,
                required String foodName,
                required List<String> categories,
                Value<int> spicyLevel = const Value.absent(),
                Value<String> portion = const Value.absent(),
                Value<String?> drink = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FoodLogsCompanion.insert(
                id: id,
                eatenAt: eatenAt,
                foodName: foodName,
                categories: categories,
                spicyLevel: spicyLevel,
                portion: portion,
                drink: drink,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodLogsTable, FoodLogRow>(table),
                  BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodLogsTable,
      FoodLogRow,
      $$FoodLogsTableFilterComposer,
      $$FoodLogsTableOrderingComposer,
      $$FoodLogsTableAnnotationComposer,
      $$FoodLogsTableCreateCompanionBuilder,
      $$FoodLogsTableUpdateCompanionBuilder,
      (FoodLogRow, BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLogRow>),
      FoodLogRow,
      PrefetchHooks Function()
    >;
typedef $$PoopLogsTableCreateCompanionBuilder = PoopLogsCompanion Function({
  required String id,
  required DateTime poopedAt,
  Value<int?> bristol,
  Value<String?> color,
  Value<int?> urgency,
  Value<int?> painLevel,
  Value<bool?> hasBlood,
  Value<bool?> hasMucus,
  Value<String?> duration,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PoopLogsTableUpdateCompanionBuilder = PoopLogsCompanion Function({
  Value<String> id,
  Value<DateTime> poopedAt,
  Value<int?> bristol,
  Value<String?> color,
  Value<int?> urgency,
  Value<int?> painLevel,
  Value<bool?> hasBlood,
  Value<bool?> hasMucus,
  Value<String?> duration,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PoopLogsTableFilterComposer
    extends Composer<_$AppDatabase, $PoopLogsTable> {
  $$PoopLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get poopedAt => $composableBuilder(
    column: $table.poopedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bristol => $composableBuilder(
    column: $table.bristol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get painLevel => $composableBuilder(
    column: $table.painLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasBlood => $composableBuilder(
    column: $table.hasBlood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasMucus => $composableBuilder(
    column: $table.hasMucus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PoopLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $PoopLogsTable> {
  $$PoopLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get poopedAt => $composableBuilder(
    column: $table.poopedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bristol => $composableBuilder(
    column: $table.bristol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get painLevel => $composableBuilder(
    column: $table.painLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasBlood => $composableBuilder(
    column: $table.hasBlood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasMucus => $composableBuilder(
    column: $table.hasMucus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PoopLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoopLogsTable> {
  $$PoopLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get poopedAt =>
      $composableBuilder(column: $table.poopedAt, builder: (column) => column);

  GeneratedColumn<int> get bristol =>
      $composableBuilder(column: $table.bristol, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<int> get painLevel =>
      $composableBuilder(column: $table.painLevel, builder: (column) => column);

  GeneratedColumn<bool> get hasBlood =>
      $composableBuilder(column: $table.hasBlood, builder: (column) => column);

  GeneratedColumn<bool> get hasMucus =>
      $composableBuilder(column: $table.hasMucus, builder: (column) => column);

  GeneratedColumn<String> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PoopLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PoopLogsTable,
          PoopLogRow,
          $$PoopLogsTableFilterComposer,
          $$PoopLogsTableOrderingComposer,
          $$PoopLogsTableAnnotationComposer,
          $$PoopLogsTableCreateCompanionBuilder,
          $$PoopLogsTableUpdateCompanionBuilder,
          (
            PoopLogRow,
            BaseReferences<_$AppDatabase, $PoopLogsTable, PoopLogRow>,
          ),
          PoopLogRow,
          PrefetchHooks Function()
        > {
  $$PoopLogsTableTableManager(_$AppDatabase db, $PoopLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoopLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoopLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoopLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> poopedAt = const Value.absent(),
                Value<int?> bristol = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int?> urgency = const Value.absent(),
                Value<int?> painLevel = const Value.absent(),
                Value<bool?> hasBlood = const Value.absent(),
                Value<bool?> hasMucus = const Value.absent(),
                Value<String?> duration = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PoopLogsCompanion(
                id: id,
                poopedAt: poopedAt,
                bristol: bristol,
                color: color,
                urgency: urgency,
                painLevel: painLevel,
                hasBlood: hasBlood,
                hasMucus: hasMucus,
                duration: duration,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime poopedAt,
                Value<int?> bristol = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int?> urgency = const Value.absent(),
                Value<int?> painLevel = const Value.absent(),
                Value<bool?> hasBlood = const Value.absent(),
                Value<bool?> hasMucus = const Value.absent(),
                Value<String?> duration = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PoopLogsCompanion.insert(
                id: id,
                poopedAt: poopedAt,
                bristol: bristol,
                color: color,
                urgency: urgency,
                painLevel: painLevel,
                hasBlood: hasBlood,
                hasMucus: hasMucus,
                duration: duration,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PoopLogsTable, PoopLogRow>(table),
                  BaseReferences<_$AppDatabase, $PoopLogsTable, PoopLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PoopLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PoopLogsTable,
      PoopLogRow,
      $$PoopLogsTableFilterComposer,
      $$PoopLogsTableOrderingComposer,
      $$PoopLogsTableAnnotationComposer,
      $$PoopLogsTableCreateCompanionBuilder,
      $$PoopLogsTableUpdateCompanionBuilder,
      (PoopLogRow, BaseReferences<_$AppDatabase, $PoopLogsTable, PoopLogRow>),
      PoopLogRow,
      PrefetchHooks Function()
    >;
typedef $$MulesLogsTableCreateCompanionBuilder = MulesLogsCompanion Function({
  required String id,
  required DateTime feltAt,
  required int painLevel,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MulesLogsTableUpdateCompanionBuilder = MulesLogsCompanion Function({
  Value<String> id,
  Value<DateTime> feltAt,
  Value<int> painLevel,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MulesLogsTableFilterComposer
    extends Composer<_$AppDatabase, $MulesLogsTable> {
  $$MulesLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get feltAt => $composableBuilder(
    column: $table.feltAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get painLevel => $composableBuilder(
    column: $table.painLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MulesLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $MulesLogsTable> {
  $$MulesLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get feltAt => $composableBuilder(
    column: $table.feltAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get painLevel => $composableBuilder(
    column: $table.painLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MulesLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MulesLogsTable> {
  $$MulesLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get feltAt =>
      $composableBuilder(column: $table.feltAt, builder: (column) => column);

  GeneratedColumn<int> get painLevel =>
      $composableBuilder(column: $table.painLevel, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MulesLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MulesLogsTable,
          MulesLogRow,
          $$MulesLogsTableFilterComposer,
          $$MulesLogsTableOrderingComposer,
          $$MulesLogsTableAnnotationComposer,
          $$MulesLogsTableCreateCompanionBuilder,
          $$MulesLogsTableUpdateCompanionBuilder,
          (
            MulesLogRow,
            BaseReferences<_$AppDatabase, $MulesLogsTable, MulesLogRow>,
          ),
          MulesLogRow,
          PrefetchHooks Function()
        > {
  $$MulesLogsTableTableManager(_$AppDatabase db, $MulesLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MulesLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MulesLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MulesLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> feltAt = const Value.absent(),
                Value<int> painLevel = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MulesLogsCompanion(
                id: id,
                feltAt: feltAt,
                painLevel: painLevel,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime feltAt,
                required int painLevel,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MulesLogsCompanion.insert(
                id: id,
                feltAt: feltAt,
                painLevel: painLevel,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MulesLogsTable, MulesLogRow>(table),
                  BaseReferences<_$AppDatabase, $MulesLogsTable, MulesLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MulesLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MulesLogsTable,
      MulesLogRow,
      $$MulesLogsTableFilterComposer,
      $$MulesLogsTableOrderingComposer,
      $$MulesLogsTableAnnotationComposer,
      $$MulesLogsTableCreateCompanionBuilder,
      $$MulesLogsTableUpdateCompanionBuilder,
      (
        MulesLogRow,
        BaseReferences<_$AppDatabase, $MulesLogsTable, MulesLogRow>,
      ),
      MulesLogRow,
      PrefetchHooks Function()
    >;
typedef $$InsightsTableCreateCompanionBuilder = InsightsCompanion Function({
  required String id,
  required String type,
  required String level,
  required String title,
  required String body,
  required String confidence,
  required List<String> evidenceLogIds,
  Value<int> periodDays,
  required DateTime createdAt,
  Value<bool> isRead,
  Value<int> rowid,
});
typedef $$InsightsTableUpdateCompanionBuilder = InsightsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> level,
  Value<String> title,
  Value<String> body,
  Value<String> confidence,
  Value<List<String>> evidenceLogIds,
  Value<int> periodDays,
  Value<DateTime> createdAt,
  Value<bool> isRead,
  Value<int> rowid,
});

class $$InsightsTableFilterComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get evidenceLogIds => $composableBuilder(
    column: $table.evidenceLogIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get periodDays => $composableBuilder(
    column: $table.periodDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InsightsTableOrderingComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceLogIds => $composableBuilder(
    column: $table.evidenceLogIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodDays => $composableBuilder(
    column: $table.periodDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InsightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get evidenceLogIds =>
      $composableBuilder(
        column: $table.evidenceLogIds,
        builder: (column) => column,
      );

  GeneratedColumn<int> get periodDays => $composableBuilder(
    column: $table.periodDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$InsightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsightsTable,
          InsightRow,
          $$InsightsTableFilterComposer,
          $$InsightsTableOrderingComposer,
          $$InsightsTableAnnotationComposer,
          $$InsightsTableCreateCompanionBuilder,
          $$InsightsTableUpdateCompanionBuilder,
          (
            InsightRow,
            BaseReferences<_$AppDatabase, $InsightsTable, InsightRow>,
          ),
          InsightRow,
          PrefetchHooks Function()
        > {
  $$InsightsTableTableManager(_$AppDatabase db, $InsightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<List<String>> evidenceLogIds = const Value.absent(),
                Value<int> periodDays = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsightsCompanion(
                id: id,
                type: type,
                level: level,
                title: title,
                body: body,
                confidence: confidence,
                evidenceLogIds: evidenceLogIds,
                periodDays: periodDays,
                createdAt: createdAt,
                isRead: isRead,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String level,
                required String title,
                required String body,
                required String confidence,
                required List<String> evidenceLogIds,
                Value<int> periodDays = const Value.absent(),
                required DateTime createdAt,
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsightsCompanion.insert(
                id: id,
                type: type,
                level: level,
                title: title,
                body: body,
                confidence: confidence,
                evidenceLogIds: evidenceLogIds,
                periodDays: periodDays,
                createdAt: createdAt,
                isRead: isRead,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InsightsTable, InsightRow>(table),
                  BaseReferences<_$AppDatabase, $InsightsTable, InsightRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InsightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsightsTable,
      InsightRow,
      $$InsightsTableFilterComposer,
      $$InsightsTableOrderingComposer,
      $$InsightsTableAnnotationComposer,
      $$InsightsTableCreateCompanionBuilder,
      $$InsightsTableUpdateCompanionBuilder,
      (InsightRow, BaseReferences<_$AppDatabase, $InsightsTable, InsightRow>),
      InsightRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodLogsTableTableManager get foodLogs =>
      $$FoodLogsTableTableManager(_db, _db.foodLogs);
  $$PoopLogsTableTableManager get poopLogs =>
      $$PoopLogsTableTableManager(_db, _db.poopLogs);
  $$MulesLogsTableTableManager get mulesLogs =>
      $$MulesLogsTableTableManager(_db, _db.mulesLogs);
  $$InsightsTableTableManager get insights =>
      $$InsightsTableTableManager(_db, _db.insights);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
