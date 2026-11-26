import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/food_log.dart';
import '../models/insight.dart';
import '../models/mules_log.dart';
import '../models/poop_log.dart';
import '../utils/date_utils.dart';

part 'database.g.dart';
part 'food_log_dao.dart';
part 'insight_dao.dart';
part 'mules_log_dao.dart';
part 'poop_log_dao.dart';

/// Kunci setting yang dipakai app (spec §5.6).
abstract final class SettingKeys {
  /// Toggle "Mode Puasa / Intermittent Fasting" (default OFF).
  static const fastingMode = 'fasting_mode';

  /// Reminder makan siang, default OFF.
  static const reminderLunch = 'reminder_lunch';

  /// Reminder review harian, default OFF.
  static const reminderDailyReview = 'reminder_daily_review';

  /// Sudah pernah lihat penjelasan Bristol saat pertama kali log eek.
  static const seenBristolIntro = 'seen_bristol_intro';

  /// Data contoh (seed §10) sedang terpasang — buat tombol
  /// "Hapus data contoh" di Settings.
  static const demoSeeded = 'demo_seeded';
}

/// Converter `List<String>` ↔ JSON array text.
class JsonStringListConverter extends TypeConverter<List<String>, String> {
  const JsonStringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is! List) return const [];
    return decoded.whereType<String>().toList(growable: false);
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// Tabel FoodLog (spec §6).
@DataClassName('FoodLogRow')
class FoodLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get eatenAt => dateTime()();
  TextColumn get foodName => text()();
  TextColumn get categories => text().map(const JsonStringListConverter())();
  IntColumn get spicyLevel => integer().withDefault(const Constant(0))();
  TextColumn get portion =>
      text().withDefault(const Constant(FoodPortion.sedang))();
  TextColumn get drink => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel PoopLog (spec §6). Hanya `poopedAt` yang wajib, sisanya nullable.
@DataClassName('PoopLogRow')
class PoopLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get poopedAt => dateTime()();
  IntColumn get bristol => integer().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get urgency => integer().nullable()();
  IntColumn get painLevel => integer().nullable()();
  BoolColumn get hasBlood => boolean().nullable()();
  BoolColumn get hasMucus => boolean().nullable()();
  TextColumn get duration => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel MulesLog — mules tanpa eek (spec §5.2b / §6).
@DataClassName('MulesLogRow')
class MulesLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get feltAt => dateTime()();
  IntColumn get painLevel => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabel Insight — hasil analisa AI lokal (spec §6), di-generate bukan diinput.
@DataClassName('InsightRow')
class Insights extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get level => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get confidence => text()();
  TextColumn get evidenceLogIds =>
      text().map(const JsonStringListConverter())();
  IntColumn get periodDays => integer().withDefault(const Constant(7))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Key-value sederhana buat setting app (Mode Puasa, reminder, dll).
@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Database lokal Muyes. Semua data di HP user, tanpa backend.
@DriftDatabase(
  tables: [FoodLogs, PoopLogs, MulesLogs, Insights, AppSettings],
  daos: [FoodLogDao, PoopLogDao, MulesLogDao, InsightDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openDefault());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openDefault() => driftDatabase(name: 'muyes');

  // ---- Settings (key-value) ----

  Future<String?> getSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSetting(key: key, value: value),
    );
  }

  Future<bool> getBoolSetting(String key, {bool defaultValue = false}) async {
    final value = await getSetting(key);
    if (value == null) return defaultValue;
    return value == 'true';
  }

  Future<void> setBoolSetting(String key, bool value) =>
      setSetting(key, value.toString());

  /// Versi live [getBoolSetting] — dipakai toggle yang mengalir ke AI,
  /// mis. Mode Puasa (spec §5.5D).
  Stream<bool> watchBoolSetting(String key, {bool defaultValue = false}) {
    return (select(appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row == null ? defaultValue : row.value == 'true');
  }

  Future<void> deleteSetting(String key) async {
    await (delete(appSettings)..where((t) => t.key.equals(key))).go();
  }

  // ---- Bulk operations ----

  /// Hapus semua log + insight yang di-generate, tapi setting tetap. Dipakai
  /// tombol "Hapus semua data" (spec §5.6).
  Future<void> deleteAllLogs() => transaction(() async {
    await delete(insights).go();
    await delete(foodLogs).go();
    await delete(poopLogs).go();
    await delete(mulesLogs).go();
  });

  /// Jumlah baris per tabel — buat cek cepat dari layar (placeholder Phase 1)
  /// dan kepakai juga buat validasi export.
  Future<Map<String, int>> tableCounts() async {
    Future<int> countOf(TableInfo table) async {
      final expr = table.$columns.first.count();
      final query = selectOnly(table)..addColumns([expr]);
      final row = await query.getSingle();
      return row.read(expr) ?? 0;
    }

    return {
      'food': await countOf(foodLogs),
      'poop': await countOf(poopLogs),
      'mules': await countOf(mulesLogs),
      'insight': await countOf(insights),
    };
  }
}

// ---- Mapping row <-> model ----

extension FoodLogRowMapper on FoodLogRow {
  FoodLog toModel() => FoodLog(
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
  );
}

FoodLogsCompanion _foodLogCompanion(FoodLog log) => FoodLogsCompanion(
  id: Value(log.id),
  eatenAt: Value(log.eatenAt),
  foodName: Value(log.foodName),
  categories: Value(log.categories),
  spicyLevel: Value(log.spicyLevel),
  portion: Value(log.portion),
  drink: Value(log.drink),
  note: Value(log.note),
  createdAt: Value(log.createdAt),
  updatedAt: Value(log.updatedAt),
);

extension PoopLogRowMapper on PoopLogRow {
  PoopLog toModel() => PoopLog(
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
  );
}

PoopLogsCompanion _poopLogCompanion(PoopLog log) => PoopLogsCompanion(
  id: Value(log.id),
  poopedAt: Value(log.poopedAt),
  bristol: Value(log.bristol),
  color: Value(log.color),
  urgency: Value(log.urgency),
  painLevel: Value(log.painLevel),
  hasBlood: Value(log.hasBlood),
  hasMucus: Value(log.hasMucus),
  duration: Value(log.duration),
  note: Value(log.note),
  createdAt: Value(log.createdAt),
  updatedAt: Value(log.updatedAt),
);

extension MulesLogRowMapper on MulesLogRow {
  MulesLog toModel() => MulesLog(
    id: id,
    feltAt: feltAt,
    painLevel: painLevel,
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

MulesLogsCompanion _mulesLogCompanion(MulesLog log) => MulesLogsCompanion(
  id: Value(log.id),
  feltAt: Value(log.feltAt),
  painLevel: Value(log.painLevel),
  note: Value(log.note),
  createdAt: Value(log.createdAt),
  updatedAt: Value(log.updatedAt),
);

extension InsightRowMapper on InsightRow {
  Insight toModel() => Insight(
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
  );
}

InsightsCompanion _insightCompanion(Insight insight) => InsightsCompanion(
  id: Value(insight.id),
  type: Value(insight.type),
  level: Value(insight.level),
  title: Value(insight.title),
  body: Value(insight.body),
  confidence: Value(insight.confidence),
  evidenceLogIds: Value(insight.evidenceLogIds),
  periodDays: Value(insight.periodDays),
  createdAt: Value(insight.createdAt),
  // `isRead` sengaja absent: insert baru pakai default false, tapi upsert
  // ulang (re-generate tiap ada log baru) TIDAK me-reset yang sudah dibaca.
  isRead: const Value.absent(),
);
