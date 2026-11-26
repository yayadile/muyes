part of 'database.dart';

/// Akses data Insight (spec §5.5 / §6). Di-generate AI, bukan diinput user.
class InsightDao {
  InsightDao(this._db);

  final AppDatabase _db;

  /// Semua insight, terbaru dulu.
  Future<List<Insight>> getAll() async {
    final rows =
        await (_db.select(_db.insights)
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map((r) => r.toModel()).toList(growable: false);
  }

  /// Insight yang belum dibaca.
  Future<List<Insight>> getUnread() async {
    final rows =
        await (_db.select(_db.insights)
              ..where((t) => t.isRead.equals(false))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map((r) => r.toModel()).toList(growable: false);
  }

  Future<int> countUnread() async {
    final expr = _db.insights.id.count();
    final query = _db.selectOnly(_db.insights)
      ..addColumns([expr])
      ..where(_db.insights.isRead.equals(false));
    final row = await query.getSingle();
    return row.read(expr) ?? 0;
  }

  Future<Insight?> getById(String id) async {
    final row = await (_db.select(
      _db.insights,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toModel();
  }

  Future<void> upsert(Insight insight) =>
      _db.into(_db.insights).insertOnConflictUpdate(_insightCompanion(insight));

  /// Simpan batch hasil generate. Id deterministik bikin re-generate tidak duplikat.
  Future<void> upsertAll(List<Insight> items) => _db.transaction(() async {
    for (final insight in items) {
      await upsert(insight);
    }
  });

  Future<void> markRead(String id) async {
    await (_db.update(_db.insights)..where((t) => t.id.equals(id))).write(
      const InsightsCompanion(isRead: Value(true)),
    );
  }

  Future<void> markAllRead() async {
    await _db.update(_db.insights).write(
      const InsightsCompanion(isRead: Value(true)),
    );
  }

  /// Hapus semua insight — dipakai reset data contoh biar hasil analisa
  /// lama (dari data yang sudah dihapus) nggak nyangkut di DB.
  Future<void> deleteAll() async {
    await _db.delete(_db.insights).go();
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.insights)..where((t) => t.id.equals(id))).go();
  }
}
