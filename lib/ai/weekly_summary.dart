import '../models/insight.dart';
import '../utils/date_utils.dart';
import 'abnormal_detector.dart';
import 'ai_types.dart';
import 'correlation.dart';
import 'eating_pattern_detector.dart';

/// Frekuensi sebuah nama makanan (hasil agregasi lokal).
class FoodFrequency {
  const FoodFrequency({required this.name, required this.count});

  final String name;
  final int count;
}

/// Ringkasan mingguan otomatis (spec §5.5C).
///
/// Isi: total + rata-rata makan/eek, jam makan rata-rata + keteraturan,
/// distribusi Bristol, makanan paling sering + pemicu, dan 1 insight utama.
class WeeklySummary {
  const WeeklySummary({
    required this.totalFood,
    required this.totalPoop,
    required this.avgFoodPerDay,
    required this.avgPoopPerDay,
    required this.avgFirstMealTime,
    required this.avgLastMealTime,
    required this.firstMealSpreadHours,
    required this.bristolDistribution,
    required this.topFoods,
    required this.topTrigger,
    required this.daysWithData,
    required this.bristolEntriesFilled,
  });

  final int totalFood;
  final int totalPoop;
  final double avgFoodPerDay;
  final double avgPoopPerDay;

  /// Rata-rata jam makan pertama (format "08:30"), null kalau nggak ada data.
  final String? avgFirstMealTime;

  /// Rata-rata jam makan terakhir, null kalau nggak ada data.
  final String? avgLastMealTime;

  /// Variasi jam makan pertama antar hari (jam). Makin kecil makin teratur.
  final double firstMealSpreadHours;

  /// Distribusi Bristol: skala 1-7 → jumlah. Kosong = nggak ada yang diisi.
  final Map<int, int> bristolDistribution;

  /// Makanan paling sering (terbanyak dulu), maks 5.
  final List<FoodFrequency> topFoods;

  /// Pemicu yang paling sering muncul bareng mules (spec §5.5C).
  final CorrelationResult? topTrigger;

  final int daysWithData;

  /// Berapa log eek yang Bristol-nya keisi — buat kalimat jujur.
  final int bristolEntriesFilled;
}

/// Hitung ringkasan mingguan dari data [days] hari terakhir.
WeeklySummary buildWeeklySummary(MuyesAiInput input, {int days = 7}) {
  final food = input.foodSince(days);
  final poop = input.poopSince(days);

  // Hari dengan catatan apapun (kecuali semua kosong → pakai `days`).
  var coveredDays = input.daysWithAnyLog(days);
  if (coveredDays == 0) coveredDays = 1;

  // Rata-rata jam makan pertama & terakhir + spread.
  final firstMinutes = <int>[];
  final lastMinutes = <int>[];
  final byDay = input.foodByDay(days);
  for (final logs in byDay.values) {
    final sorted = logs..sort((a, b) => a.eatenAt.compareTo(b.eatenAt));
    final first = sorted.first.eatenAt;
    final last = sorted.last.eatenAt;
    firstMinutes.add(first.hour * 60 + first.minute);
    lastMinutes.add(last.hour * 60 + last.minute);
  }

  String? fmtAvg(List<int> minutes) {
    if (minutes.isEmpty) return null;
    final avg = minutes.reduce((a, b) => a + b) ~/ minutes.length;
    return formatTimeId(DateTime(2026, 1, 1, avg ~/ 60, avg % 60));
  }

  var spread = 0.0;
  if (firstMinutes.length >= 2) {
    final min = firstMinutes.reduce((a, b) => a < b ? a : b);
    final max = firstMinutes.reduce((a, b) => a > b ? a : b);
    spread = (max - min) / 60.0;
  }

  // Distribusi Bristol — cuma yang keisi (spec: jangan anggap kosong = 0).
  final bristolDistribution = <int, int>{};
  for (final log in poop) {
    final bristol = log.bristol;
    if (bristol != null) {
      bristolDistribution[bristol] = (bristolDistribution[bristol] ?? 0) + 1;
    }
  }

  // Makanan paling sering.
  final foodCounts = <String, int>{};
  for (final log in food) {
    foodCounts[log.foodName] = (foodCounts[log.foodName] ?? 0) + 1;
  }
  final topFoods = foodCounts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });
  final topFoodsList = [
    for (final entry in topFoods.take(5))
      FoodFrequency(name: entry.key, count: entry.value),
  ];

  // Pemicu top dari korelasi.
  final correlations = findCorrelations(input, days: days);
  final topTrigger = correlations.isEmpty ? null : correlations.first;

  return WeeklySummary(
    totalFood: food.length,
    totalPoop: poop.length,
    avgFoodPerDay: food.length / coveredDays,
    avgPoopPerDay: poop.length / coveredDays,
    avgFirstMealTime: fmtAvg(firstMinutes),
    avgLastMealTime: fmtAvg(lastMinutes),
    firstMealSpreadHours: spread,
    bristolDistribution: bristolDistribution,
    topFoods: topFoodsList,
    topTrigger: topTrigger,
    daysWithData: input.daysWithAnyLog(days),
    bristolEntriesFilled:
        poop.where((p) => p.bristol != null).length,
  );
}

/// Ubah ringkasan mingguan jadi Insight (type: weekly_summary).
Insight weeklySummaryInsight(MuyesAiInput input, {int days = 7}) {
  final summary = buildWeeklySummary(input, days: days);
  final lines = <String>[];

  lines.add(
    'Total $days hari terakhir: ${summary.totalFood}x makan, '
    '${summary.totalPoop}x eek '
    '(rata-rata ${summary.avgFoodPerDay.toStringAsFixed(1)} makan/hari, '
    '${summary.avgPoopPerDay.toStringAsFixed(1)} eek/hari).',
  );

  if (summary.avgFirstMealTime != null && summary.avgLastMealTime != null) {
    final keteraturan = summary.firstMealSpreadHours <= 2
        ? 'teratur 👍'
        : summary.firstMealSpreadHours <= 3
        ? 'lumayan'
        : 'lumayan lompat-lompat';
    lines.add(
      'Jam makan rata-rata: pertama ~${summary.avgFirstMealTime}, '
      'terakhir ~${summary.avgLastMealTime} — $keteraturan.',
    );
  }

  if (summary.bristolDistribution.isNotEmpty) {
    final distribution = (summary.bristolDistribution.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)))
        .map((e) => 'Bristol ${e.key}: ${e.value}x')
        .join(', ');
    lines.add('Distribusi Bristol: $distribution.');
  } else if (summary.totalPoop > 0) {
    lines.add(
      'Bristol belum pernah diisi minggu ini, jadi distribusi bentuk eek '
      'belum bisa dibaca.',
    );
  }

  if (summary.topFoods.isNotEmpty) {
    final top = summary.topFoods.take(3).map((f) {
      return '${f.name}${f.count > 1 ? " (${f.count}x)" : ""}';
    }).join(', ');
    lines.add('Paling sering dimakan: $top.');
  }

  if (summary.topTrigger != null) {
    lines.add(
      'Pemicu yang paling sering muncul bareng mules: '
      '${summary.topTrigger!.trigger} '
      '(${summary.topTrigger!.hitCount} dari '
      '${summary.topTrigger!.totalEpisodes} kejadian).',
    );
  }

  // 1 insight utama minggu ini.
  final mainInsight = mainInsightLine(input, summary, days: days);
  if (mainInsight != null) lines.add(mainInsight);

  return Insight(
    id: 'weekly-summary:$days:${dayKey(input.now)}',
    type: InsightType.weeklySummary,
    level: _level(summary, days),
    title: 'Ringkasan $days hari terakhir',
    body: lines.join('\n\n'),
    confidence: summary.daysWithData >= 5
        ? InsightConfidence.tinggi
        : summary.daysWithData >= 3
        ? InsightConfidence.sedang
        : InsightConfidence.rendah,
    evidenceLogIds: [
      ...summary.topFoods.isEmpty ? const <String>[] : const <String>[],
      for (final log in input.foodSince(days)) log.id,
      for (final log in input.poopSince(days)) log.id,
    ],
    periodDays: days,
    createdAt: input.now,
  );
}

String _level(WeeklySummary summary, int days) {
  final bristol = summary.bristolDistribution;
  final diarrhea = (bristol[6] ?? 0) + (bristol[7] ?? 0);
  return diarrhea >= 3 ? InsightLevel.warning : InsightLevel.info;
}

/// Satu kalimat paling penting minggu ini (spec §5.5C) — dipakai halaman
/// Insights di kartu Ringkasan Mingguan.
String? mainInsightLine(
  MuyesAiInput input,
  WeeklySummary summary, {
  required int days,
}) {
  // Prioritas: alert merah dari abnormal detector.
  final abnormal = AbnormalDetector(input).detect(days: days);
  final red = abnormal.where((i) => i.level == InsightLevel.alert).toList();
  if (red.isNotEmpty) {
    return 'Paling penting: ${red.first.title.toLowerCase()} — '
        'buka bagian Pola Eek buat detailnya.';
  }

  // Pemicu mules paling kuat.
  if (summary.topTrigger != null && summary.topTrigger!.hitCount >= 2) {
    return 'Paling penting: coba kurangi '
        '${summary.topTrigger!.trigger} dulu — '
        '${summary.topTrigger!.hitCount} dari '
        '${summary.topTrigger!.totalEpisodes} kejadian mulesmu '
        'kebetulan habis itu.';
  }

  // Pola makan bermasalah.
  final eating = EatingPatternDetector(input).detect(days: days);
  final eatingWarning = eating.where((i) => i.level == InsightLevel.warning);
  if (eatingWarning.isNotEmpty) {
    return 'Paling penting: ${eatingWarning.first.title.toLowerCase()} — '
        'buka bagian Pola Makan buat detailnya.';
  }

  if (summary.daysWithData < 3) {
    return 'Catat 3-5 hari lagi biar ringkasannya makin berguna.';
  }

  return null;
}
