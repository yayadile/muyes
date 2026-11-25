part of 'database.dart';

/// Akses data PoopLog (spec §5.2). Hanya [poopedAt] yang wajib.
class PoopLogDao {
  PoopLogDao(this._db);

  final AppDatabase _db;

  /// Semua log eek, terbaru dulu.
  Future<List<PoopLog>> getAll() async {
    final rows =
        await (_db.select(_db.poopLogs)
              ..orderBy([(t) => OrderingTerm.desc(t.poopedAt)]))
            .get();
    return rows.map((r) => r.toModel()).toList(growable: false);
  }

  /// Rentang [from] (inklusif) sampai [to] (eksklusif), urut waktu naik.
  Future<List<PoopLog>> getBetween(DateTime from, DateTime to) async {
    final rows =
        await (_db.select(_db.poopLogs)
              ..where((t) => t.poopedAt.isBiggerOrEqualValue(from))
              ..where((t) => t.poopedAt.isSmallerThanValue(to))
              ..orderBy([(t) => OrderingTerm.asc(t.poopedAt)]))
            .get();
    return rows.map((r) => r.toModel()).toList(growable: false);
  }

  /// Satu hari kalender [day], urut waktu.
  Future<List<PoopLog>> getForDay(DateTime day) =>
      getBetween(startOfDay(day), startOfNextDay(day));

  /// Versi live dari [getBetween].
  Stream<List<PoopLog>> watchBetween(DateTime from, DateTime to) {
    return (_db.select(_db.poopLogs)
          ..where((t) => t.poopedAt.isBiggerOrEqualValue(from))
          ..where((t) => t.poopedAt.isSmallerThanValue(to))
          ..orderBy([(t) => OrderingTerm.asc(t.poopedAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.toModel()).toList(growable: false));
  }

  /// Versi live dari [getForDay].
  Stream<List<PoopLog>> watchForDay(DateTime day) =>
      watchBetween(startOfDay(day), startOfNextDay(day));

  /// Versi live dari [getAll].
  Stream<List<PoopLog>> watchAll() {
    return (_db.select(_db.poopLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.poopedAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.toModel()).toList(growable: false));
  }

  /// [days] hari terakhir sampai sekarang, urut waktu naik.
  Future<List<PoopLog>> getLastDays(int days, {DateTime? now}) {
    final end = now ?? DateTime.now();
    return getBetween(
      startOfDay(end).subtract(Duration(days: days - 1)),
      startOfNextDay(end),
    );
  }

  Future<PoopLog?> getById(String id) async {
    final row = await (_db.select(
      _db.poopLogs,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toModel();
  }

  Future<void> upsert(PoopLog log) =>
      _db.into(_db.poopLogs).insertOnConflictUpdate(_poopLogCompanion(log));

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.poopLogs)..where((t) => t.id.equals(id))).go();
  }

  /// Berapa banyak log eek yang Bristol-nya kosong (0..7 scale) — dipakai AI
  /// untuk pesan jujur "insight terbatas karena Bristol jarang diisi" (spec §5.5).
  Future<int> countWithoutBristol() async {
    final expr = _db.poopLogs.id.count();
    final query = _db.selectOnly(_db.poopLogs)
      ..addColumns([expr])
      ..where(_db.poopLogs.bristol.isNull());
    final row = await query.getSingle();
    return row.read(expr) ?? 0;
  }

  /// Log terakhir sebelum [before] (untuk cek "belum eek X hari").
  Future<PoopLog?> getLastBefore(DateTime before) async {
    final row =
        await (_db.select(_db.poopLogs)
              ..where((t) => t.poopedAt.isSmallerThanValue(before))
              ..orderBy([(t) => OrderingTerm.desc(t.poopedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.toModel();
  }
}
