import 'package:drift/drift.dart';

import '../models/food_log.dart';
import '../models/mules_log.dart';
import '../models/poop_log.dart';
import '../utils/date_utils.dart';
import 'database.dart';

/// Seed data contoh untuk testing manual (spec §10).
///
/// Semua id berprefix [DemoSeed.idPrefix] — tombol "Hapus data contoh"
/// menghapus HANYA baris ini, data asli user nggak kesentuh.
///
/// Hari 0 = 13 hari lalu, hari 13 = hari ini. Semua log di masa depan
/// (kalau seed dijalankan pagi) di-skip otomatis.
///
/// Kalibrasi pola biar semua acceptance §9 kepicu:
/// - Korelasi (spec §5.5A): 6 hari pedas level 4-5 jam 12:30 → mules 3-4 +
///   Bristol 6 jam 19:00-19:25 (6-8 jam kemudian, masuk jendela 2-12 jam).
///   Dalam 7 hari terakhir: "Pedas muncul di 3 dari 4 kejadian" — persis
///   pola contoh spec. Dalam 30 hari: 6 dari 15.
/// - Alert merah: diare 4x Bristol 7 dua hari berturut (hari 4-5) +
///   1 log hasBlood (hari 9).
/// - Warning kuning: "belum eek 3 hari" (poop terakhir hari 10),
///   "makan 1x sehari 2 hari" (hari 9-10), "ngemil terus 2 hari"
///   (hari 11-12, 7 & 6 log), "3x makan berat jam 23:30" (hari 7, 11, 12),
///   "kopi 4x" (hari 11), "jam makan lompat-lompat" (variasi jam pertama).
/// - Dedup mules (spec §5.2b): mules + eek <30 menit = 1 kejadian
///   (hari 1, 3, 6, 8, 10).
/// - Null semantics: 2 log eek cuma diisi waktu (Bristol null) — analisa
///   Bristol tetap jalan tanpa nganggap null = normal.
abstract final class DemoSeed {
  /// Prefix id semua baris hasil seed — penanda "ini data contoh".
  static const idPrefix = 'demo-';

  static bool isDemoId(String id) => id.startsWith(idPrefix);
}

/// Isi seed yang sudah di-generate (belum masuk DB).
class DemoSeedBundle {
  const DemoSeedBundle({
    required this.food,
    required this.poop,
    required this.mules,
  });

  final List<FoodLog> food;
  final List<PoopLog> poop;
  final List<MulesLog> mules;

  int get total => food.length + poop.length + mules.length;

  String get summary =>
      '${food.length}x makan, ${poop.length}x eek, ${mules.length}x mules';
}

/// Generate seed dengan [now] sebagai "hari ini" (biar bisa dites).
DemoSeedBundle buildDemoSeed({DateTime? now}) {
  final refNow = now ?? DateTime.now();
  final today = startOfDay(refNow);
  final food = <FoodLog>[];
  final poop = <PoopLog>[];
  final mules = <MulesLog>[];

  var seq = 0;
  String nextId() => '${DemoSeed.idPrefix}${(++seq).toString().padLeft(3, '0')}';

  /// Waktu di hari ke-[day] (0 = 13 hari lalu, 13 = hari ini).
  DateTime at(int day, int hour, [int minute = 0]) {
    final d = today.subtract(Duration(days: 13 - day));
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  /// Log di masa depan (mis. sarapan "hari ini" padahal seed dijalankan
  /// pagi) di-skip biar data nggak bohong.
  bool isPast(DateTime time) => !time.isAfter(refNow);

  void meal(
    int day,
    int hour,
    int minute,
    String name, {
    List<String> categories = const <String>[],
    int spicy = 0,
    String portion = FoodPortion.sedang,
    String? drink,
    String? note,
  }) {
    final time = at(day, hour, minute);
    if (!isPast(time)) return;
    food.add(
      FoodLog(
        id: nextId(),
        eatenAt: time,
        foodName: name,
        categories: categories,
        spicyLevel: spicy,
        portion: portion,
        drink: drink,
        note: note,
        createdAt: time,
        updatedAt: time,
      ),
    );
  }

  void eek(
    int day,
    int hour,
    int minute, {
    int? bristol,
    int? pain,
    bool? blood,
    String? note,
  }) {
    final time = at(day, hour, minute);
    if (!isPast(time)) return;
    poop.add(
      PoopLog(
        id: nextId(),
        poopedAt: time,
        bristol: bristol,
        painLevel: pain,
        hasBlood: blood,
        note: note,
        createdAt: time,
        updatedAt: time,
      ),
    );
  }

  void mulesAt(int day, int hour, int minute, int level, {String? note}) {
    final time = at(day, hour, minute);
    if (!isPast(time)) return;
    mules.add(
      MulesLog(
        id: nextId(),
        feltAt: time,
        painLevel: level,
        note: note,
        createdAt: time,
        updatedAt: time,
      ),
    );
  }

  void sarapan(int day, String name, {int hour = 7, int minute = 0}) =>
      meal(day, hour, minute, name);

  void siang(
    int day,
    String name, {
    int hour = 12,
    int minute = 30,
    List<String> categories = const <String>[],
    int spicy = 0,
    String? drink,
    String? note,
  }) => meal(
    day,
    hour,
    minute,
    name,
    categories: categories,
    spicy: spicy,
    drink: drink,
    note: note,
  );

  void malam(
    int day,
    String name, {
    int hour = 18,
    int minute = 45,
    List<String> categories = const <String>[],
    int spicy = 0,
    String? drink,
    String? note,
  }) => meal(
    day,
    hour,
    minute,
    name,
    categories: categories,
    spicy: spicy,
    drink: drink,
    note: note,
  );

  /// Hari pedas (spec §10): siang pedas level 4-5, 6-7 jam kemudian mules
  /// + eek Bristol 6 (dedup <30 menit = 1 kejadian).
  void hariPedas(int day, String makananPedas, int levelPedas, int levelMules) {
    siang(
      day,
      makananPedas,
      spicy: levelPedas,
      categories: const [FoodCategories.pedas],
    );
    mulesAt(day, 19, 0, levelMules, note: 'habis makan pedas');
    eek(day, 19, 25, bristol: 6, pain: levelMules, note: 'eek lembek');
  }

  // ---- Hari 0: normal, eek cuma diisi waktu (Bristol null) ----
  sarapan(0, 'Oatmeal pisang');
  siang(0, 'Nasi ayam sayur', categories: const [FoodCategories.nasi]);
  malam(0, 'Sup ayam sayur', categories: const [FoodCategories.sayur]);
  eek(0, 8, 15, note: 'cuma catat jam');

  // ---- Hari 1: pedas → mules 4 + Bristol 6 (satu kejadian) ----
  sarapan(1, 'Bubur ayam');
  hariPedas(1, 'Seblak pedas level 5', 5, 4);
  malam(1, 'Ikan bakar + nasi');
  eek(1, 8, 20, bristol: 4);

  // ---- Hari 2: normal, eek kedua tanpa Bristol ----
  sarapan(2, 'Roti isi telur', hour: 7, minute: 10);
  siang(2, 'Nasi uduk', hour: 12, minute: 40);
  malam(2, 'Tumis kangkung + nasi', hour: 18, minute: 40);
  eek(2, 8, 30, note: 'cuma catat jam');

  // ---- Hari 3: pedas → mules 3 ----
  sarapan(3, 'Nasi uduk');
  hariPedas(3, 'Ayam geprek sambal', 4, 3);
  malam(3, 'Capcay + nasi');
  eek(3, 8, 20, bristol: 4);

  // ---- Hari 4: diare 4x Bristol 7 + cuma makan 1x (lagi sakit) ----
  meal(4, 12, 0, 'Bubur ayam', note: 'makan dikit, perut nggak enak');
  eek(4, 6, 0, bristol: 7, pain: 2, note: 'diare');
  eek(4, 9, 30, bristol: 7, pain: 2, note: 'diare lagi');
  eek(4, 13, 0, bristol: 7, pain: 2);
  eek(4, 16, 30, bristol: 7, pain: 2, note: 'diare terus');

  // ---- Hari 5: diare 4x lagi → alert merah "diare berulang 2 hari" ----
  meal(5, 11, 30, 'Bubur ayam', note: 'masih lemes');
  eek(5, 5, 30, bristol: 7, pain: 2, note: 'diare');
  eek(5, 9, 0, bristol: 7, pain: 2);
  eek(5, 13, 30, bristol: 7, pain: 2);
  eek(5, 18, 0, bristol: 7, pain: 2, note: 'makin sering');

  // ---- Hari 6: pedas → mules 4 ----
  sarapan(6, 'Nasi telur dadar');
  hariPedas(6, 'Mie pedas level 4', 4, 4);
  malam(6, 'Ikan bakar + nasi');
  eek(6, 8, 15, bristol: 4);

  // ---- Hari 7: episode Bristol 6 TANPA pedas + makan berat 23:30 ----
  sarapan(7, 'Oatmeal pisang');
  siang(7, 'Nasi ayam sayur', categories: const [FoodCategories.nasi]);
  malam(7, 'Indomie goreng', hour: 18, minute: 30, note: 'laper banget');
  meal(7, 23, 30, 'Nasi telur', note: 'makan berat larut malam');
  eek(7, 8, 20, bristol: 4);
  eek(7, 21, 0, bristol: 6, pain: 3, note: 'mules + eek lembek');

  // ---- Hari 8: pedas → mules 3 + Bristol 6 ----
  sarapan(8, 'Bubur ayam', hour: 7, minute: 15);
  hariPedas(8, 'Nasi ayam sambal matah', 4, 3);
  malam(8, 'Sup ayam sayur');
  eek(8, 8, 20, bristol: 4);

  // ---- Hari 9: ADA DARAH + cuma makan 1x ----
  sarapan(9, 'Oatmeal pisang');
  eek(9, 8, 30, bristol: 4, blood: true, note: 'ada bercak darah');

  // ---- Hari 10: pedas (makan 1x) + eek terakhir sebelum puasa eek ----
  meal(
    10,
    12,
    30,
    'Bakso aci pedas level 5',
    spicy: 5,
    categories: const [FoodCategories.pedas],
  );
  mulesAt(10, 19, 0, 4, note: 'habis makan pedas');
  eek(10, 19, 25, bristol: 6, pain: 4, note: 'eek lembek');

  // ---- Hari 11: 7 log (ngemil) + kopi 4x + makan berat 23:30, TANPA eek ----
  meal(11, 6, 30, 'Kopi tubruk', categories: const [FoodCategories.kopi]);
  sarapan(11, 'Roti isi telur', hour: 7, minute: 30);
  meal(11, 10, 0, 'Kopi susu', categories: const [FoodCategories.kopi]);
  siang(11, 'Nasi ayam sayur', categories: const [FoodCategories.nasi]);
  meal(11, 15, 0, 'Kopi susu', categories: const [FoodCategories.kopi]);
  meal(11, 21, 0, 'Kopi hitam', categories: const [FoodCategories.kopi], note: 'lembur');
  meal(11, 23, 30, 'Nasi telur', note: 'makan berat larut malam');

  // ---- Hari 12: 6 log + pedas + makan berat 23:30, TANPA eek ----
  sarapan(12, 'Bubur ayam', hour: 7, minute: 30);
  meal(12, 10, 0, 'Roti bakar', drink: 'Teh manis');
  siang(
    12,
    'Mie ayam pedas level 4',
    spicy: 4,
    categories: const [FoodCategories.pedas, FoodCategories.mie],
  );
  meal(12, 15, 30, 'Buah potong');
  malam(12, 'Nasi ayam sayur', hour: 19, minute: 0, categories: const [FoodCategories.nasi]);
  meal(12, 23, 30, 'Nasi telur', note: 'makan berat larut malam');
  mulesAt(12, 19, 10, 3, note: 'mules lagi, belum eek');

  // ---- Hari 13 (hari ini): pagi + siang, belum ada eek ----
  sarapan(13, 'Oatmeal pisang', hour: 7, minute: 30);
  siang(13, 'Nasi ayam sayur', categories: const [FoodCategories.nasi]);

  // Urut waktu naik — kontrak MuyesAiInput (biar bisa dianalisa langsung).
  food.sort((a, b) => a.eatenAt.compareTo(b.eatenAt));
  poop.sort((a, b) => a.poopedAt.compareTo(b.poopedAt));
  mules.sort((a, b) => a.feltAt.compareTo(b.feltAt));

  return DemoSeedBundle(food: food, poop: poop, mules: mules);
}

// ---- Aksi DB: pasang / hapus data contoh ----

/// Pasang [bundle] ke DB: sapu data contoh lama (kalau ada), insert semua,
/// lalu tandai setting [SettingKeys.demoSeeded].
Future<void> applyDemoSeed(AppDatabase db, DemoSeedBundle bundle) =>
    db.transaction(() async {
      await _deleteDemoRows(db);
      final foodDao = FoodLogDao(db);
      final poopDao = PoopLogDao(db);
      final mulesDao = MulesLogDao(db);
      for (final log in bundle.food) {
        await foodDao.upsert(log);
      }
      for (final log in bundle.poop) {
        await poopDao.upsert(log);
      }
      for (final log in bundle.mules) {
        await mulesDao.upsert(log);
      }
      await db.setBoolSetting(SettingKeys.demoSeeded, true);
    });

/// Hapus semua baris berprefix `demo-` + insight lama (insight di-generate
/// ulang otomatis dari data yang tersisa).
Future<void> removeDemoData(AppDatabase db) => db.transaction(() async {
  await _deleteDemoRows(db);
  await InsightDao(db).deleteAll();
  await db.setBoolSetting(SettingKeys.demoSeeded, false);
});

Future<void> _deleteDemoRows(AppDatabase db) async {
  final pattern = '${DemoSeed.idPrefix}%';
  await (db.delete(db.foodLogs)..where((t) => t.id.like(pattern))).go();
  await (db.delete(db.poopLogs)..where((t) => t.id.like(pattern))).go();
  await (db.delete(db.mulesLogs)..where((t) => t.id.like(pattern))).go();
}
