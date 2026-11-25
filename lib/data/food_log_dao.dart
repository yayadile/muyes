part of 'database.dart';

/// Akses data FoodLog (spec §5.1).
class FoodLogDao {
  FoodLogDao(this._db);

  final AppDatabase _db;

  /// Semua log makan, terbaru dulu.
  Future<List<FoodLog>> getAll() async {
    final rows =
        await (_db.select(_db.foodLogs)
              ..orderBy([(t) => OrderingTerm.desc(t.eatenAt)]))
            .get();
    return rows.map((r) => r.toModel()).toList(growable: false);
  }

  /// Rentang [from] (inklusif) sampai [to] (eksklusif).
  Future<List<FoodLog>> getBetween(DateTime from, DateTime to) async {
    final rows =
        await (_db.select(_db.foodLogs)
              ..where((t) => t.eatenAt.isBiggerOrEqualValue(from))
              ..where((t) => t.eatenAt.isSmallerThanValue(to))
              ..orderBy([(t) => OrderingTerm.asc(t.eatenAt)]))
            .get();
    return rows.map((r) => r.toModel()).toList(growable: false);
  }

  /// Satu hari kalender [day] (00:00 s/d 24:00), urut waktu.
  Future<List<FoodLog>> getForDay(DateTime day) =>
      getBetween(startOfDay(day), startOfNextDay(day));

  /// Versi live dari [getBetween] — update otomatis saat DB berubah.
  Stream<List<FoodLog>> watchBetween(DateTime from, DateTime to) {
    return (_db.select(_db.foodLogs)
          ..where((t) => t.eatenAt.isBiggerOrEqualValue(from))
          ..where((t) => t.eatenAt.isSmallerThanValue(to))
          ..orderBy([(t) => OrderingTerm.asc(t.eatenAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.toModel()).toList(growable: false));
  }

  /// Versi live dari [getForDay].
  Stream<List<FoodLog>> watchForDay(DateTime day) =>
      watchBetween(startOfDay(day), startOfNextDay(day));

  /// Versi live dari [getLastDays] — bahan analisa AI (spec §5.5: 30 hari).
  Stream<List<FoodLog>> watchLastDays(int days, {DateTime? now}) {
    final end = now ?? DateTime.now();
    return watchBetween(
      startOfDay(end).subtract(Duration(days: days - 1)),
      startOfNextDay(end),
    );
  }

  /// Versi live dari [getAll].
  Stream<List<FoodLog>> watchAll() {
    return (_db.select(_db.foodLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.eatenAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.toModel()).toList(growable: false));
  }

  /// [days] hari terakhir sampai sekarang, urut waktu naik.
  Future<List<FoodLog>> getLastDays(int days, {DateTime? now}) {
    final end = now ?? DateTime.now();
    return getBetween(
      startOfDay(end).subtract(Duration(days: days - 1)),
      startOfNextDay(end),
    );
  }

  Future<FoodLog?> getById(String id) async {
    final row = await (_db.select(
      _db.foodLogs,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toModel();
  }

  Future<void> upsert(FoodLog log) =>
      _db.into(_db.foodLogs).insertOnConflictUpdate(_foodLogCompanion(log));

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.foodLogs)..where((t) => t.id.equals(id))).go();
  }

  /// Nama makanan unik + jumlah kemunculan, terbanyak dulu.
  /// Dipakai chip "Makan lagi" di form (spec §5.1).
  Future<List<FoodNameCount>> topFoodNames({int limit = 10}) async {
    final name = _db.foodLogs.foodName;
    final count = name.count();
    final query = _db.selectOnly(_db.foodLogs)
      ..addColumns([name, count])
      ..groupBy([name])
      ..orderBy([OrderingTerm.desc(count), OrderingTerm.asc(name)])
      ..limit(limit);
    final rows = await query.get();
    return rows
        .map(
          (r) => FoodNameCount(
            name: r.read(name)!,
            count: r.read(count) ?? 0,
          ),
        )
        .toList(growable: false);
  }

  /// Cari berdasarkan kata kunci di nama makanan / catatan / minuman (spec §5.4).
  Future<List<FoodLog>> search(String keyword) async {
    final pattern = '%${keyword.trim()}%';
    final rows =
        await (_db.select(_db.foodLogs)
              ..where(
                (t) =>
                    t.foodName.like(pattern) |
                    t.note.like(pattern) |
                    t.drink.like(pattern),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.eatenAt)]))
            .get();
    return rows.map((r) => r.toModel()).toList(growable: false);
  }
}

/// Hasil agregasi nama makanan + jumlah kemunculan.
class FoodNameCount {
  const FoodNameCount({required this.name, required this.count});

  final String name;
  final int count;
}
