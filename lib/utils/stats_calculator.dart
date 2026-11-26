import '../ai/ai_types.dart';
import 'date_utils.dart';

/// Agregasi data buat halaman Statistik (spec §8.1 stats).
///
/// Murni hitung-hitungan dari data yang sudah ada (30 hari terakhir) —
/// TIDAK pakai trend/ramalan, cuma angka + diagram dari catatan user.

/// Frekuensi satu nama makanan.
class StatsFoodCount {
  const StatsFoodCount({required this.name, required this.count});

  final String name;
  final int count;
}

/// Jumlah catatan per hari (buat diagram batang bertumpuk).
class StatsDayCounts {
  const StatsDayCounts({
    required this.day,
    required this.food,
    required this.poop,
    required this.mules,
  });

  final DateTime day;
  final int food;
  final int poop;
  final int mules;

  int get total => food + poop + mules;
}

/// Semua angka halaman Statistik untuk rentang [days] hari.
class MuyesStats {
  const MuyesStats({
    required this.days,
    required this.totalFood,
    required this.totalPoop,
    required this.totalMules,
    required this.daysWithData,
    required this.bristolDistribution,
    required this.bristolFilled,
    required this.perDay,
    required this.topFoods,
  });

  /// Rentang yang dihitung: 7 atau 30.
  final int days;

  final int totalFood;
  final int totalPoop;
  final int totalMules;

  /// Hari unik yang punya catatan apapun dalam rentang.
  final int daysWithData;

  /// Distribusi Bristol — HANYA yang keisi (null bukan 0 / normal).
  final Map<int, int> bristolDistribution;

  /// Berapa log eek yang Bristol-nya keisi.
  final int bristolFilled;

  /// Jumlah catatan per hari, urut lama → baru (buat diagram batang).
  final List<StatsDayCounts> perDay;

  /// Makanan paling sering dimakan (maks 5), terbanyak dulu.
  final List<StatsFoodCount> topFoods;

  int get totalLogs => totalFood + totalPoop + totalMules;

  /// Pembagi rata-rata: hari yang ada catatan (biar nggak bohong kalau
  /// cuma nyatat 3 dari 7 hari).
  int get coveredDays => daysWithData == 0 ? 1 : daysWithData;

  double get avgFoodPerDay => totalFood / coveredDays;
  double get avgPoopPerDay => totalPoop / coveredDays;
  double get avgMulesPerDay => totalMules / coveredDays;
}

/// Hitung statistik dari input data (30 hari terakhir), rentang [days].
MuyesStats buildStats(MuyesAiInput input, {int days = 7}) {
  final food = input.foodSince(days);
  final poop = input.poopSince(days);
  final mules = input.mulesSince(days);

  // Jumlah per hari (key dayKey).
  final foodByDay = <String, int>{};
  final poopByDay = <String, int>{};
  final mulesByDay = <String, int>{};
  for (final log in food) {
    final key = dayKey(log.eatenAt);
    foodByDay[key] = (foodByDay[key] ?? 0) + 1;
  }
  for (final log in poop) {
    final key = dayKey(log.poopedAt);
    poopByDay[key] = (poopByDay[key] ?? 0) + 1;
  }
  for (final log in mules) {
    final key = dayKey(log.feltAt);
    mulesByDay[key] = (mulesByDay[key] ?? 0) + 1;
  }

  // Daftar hari lengkap dalam rentang, urut lama → baru.
  final today = startOfDay(input.now);
  final perDay = <StatsDayCounts>[];
  for (var i = days - 1; i >= 0; i--) {
    final d = DateTime(today.year, today.month, today.day - i);
    final key = dayKey(d);
    perDay.add(
      StatsDayCounts(
        day: d,
        food: foodByDay[key] ?? 0,
        poop: poopByDay[key] ?? 0,
        mules: mulesByDay[key] ?? 0,
      ),
    );
  }

  // Distribusi Bristol (cuma yang keisi).
  final bristol = <int, int>{};
  var bristolFilled = 0;
  for (final log in poop) {
    final value = log.bristol;
    if (value != null) {
      bristol[value] = (bristol[value] ?? 0) + 1;
      bristolFilled++;
    }
  }

  // Makanan paling sering.
  final nameCounts = <String, int>{};
  for (final log in food) {
    nameCounts[log.foodName] = (nameCounts[log.foodName] ?? 0) + 1;
  }
  final sortedNames = nameCounts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });

  return MuyesStats(
    days: days,
    totalFood: food.length,
    totalPoop: poop.length,
    totalMules: mules.length,
    daysWithData: input.daysWithAnyLog(days),
    bristolDistribution: bristol,
    bristolFilled: bristolFilled,
    perDay: perDay,
    topFoods: [
      for (final entry in sortedNames.take(5))
        StatsFoodCount(name: entry.key, count: entry.value),
    ],
  );
}
