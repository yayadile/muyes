part of 'database.dart';

/// Akses data MulesLog (spec §5.2b).
class MulesLogDao {
  MulesLogDao(this._db);

  final AppDatabase _db;

  /// Semua kejadian mules, terbaru dulu.
  Future<List<MulesLog>> getAll() async {
    final rows =
        await (_db.select(_db.mulesLogs)
              ..orderBy([(t) => OrderingTerm.desc(t.feltAt)]))
            .get();
    return rows.map((r) => r.toModel()).toList(growable: false);
  }

  /// Rentang [from] (inklusif) sampai [to] (eksklusif), urut waktu naik.
  Future<List<MulesLog>> getBetween(DateTime from, DateTime to) async {
    final rows =
        await (_db.select(_db.mulesLogs)
              ..where((t) => t.feltAt.isBiggerOrEqualValue(from))
              ..where((t) => t.feltAt.isSmallerThanValue(to))
              ..orderBy([(t) => OrderingTerm.asc(t.feltAt)]))
            .get();
    return rows.map((r) => r.toModel()).toList(growable: false);
  }

  /// Satu hari kalender [day], urut waktu.
  Future<List<MulesLog>> getForDay(DateTime day) =>
      getBetween(startOfDay(day), startOfNextDay(day));

  /// Versi live dari [getBetween].
  Stream<List<MulesLog>> watchBetween(DateTime from, DateTime to) {
    return (_db.select(_db.mulesLogs)
          ..where((t) => t.feltAt.isBiggerOrEqualValue(from))
          ..where((t) => t.feltAt.isSmallerThanValue(to))
          ..orderBy([(t) => OrderingTerm.asc(t.feltAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.toModel()).toList(growable: false));
  }

  /// Versi live dari [getForDay].
  Stream<List<MulesLog>> watchForDay(DateTime day) =>
      watchBetween(startOfDay(day), startOfNextDay(day));

  /// Versi live dari [getLastDays] — bahan analisa AI (spec §5.5: 30 hari).
  Stream<List<MulesLog>> watchLastDays(int days, {DateTime? now}) {
    final end = now ?? DateTime.now();
    return watchBetween(
      startOfDay(end).subtract(Duration(days: days - 1)),
      startOfNextDay(end),
    );
  }

  /// Versi live dari [getAll].
  Stream<List<MulesLog>> watchAll() {
    return (_db.select(_db.mulesLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.feltAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.toModel()).toList(growable: false));
  }

  /// [days] hari terakhir sampai sekarang, urut waktu naik.
  Future<List<MulesLog>> getLastDays(int days, {DateTime? now}) {
    final end = now ?? DateTime.now();
    return getBetween(
      startOfDay(end).subtract(Duration(days: days - 1)),
      startOfNextDay(end),
    );
  }

  Future<MulesLog?> getById(String id) async {
    final row = await (_db.select(
      _db.mulesLogs,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toModel();
  }

  Future<void> upsert(MulesLog log) =>
      _db.into(_db.mulesLogs).insertOnConflictUpdate(_mulesLogCompanion(log));

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.mulesLogs)..where((t) => t.id.equals(id))).go();
  }
}
