import '../models/food_log.dart';
import '../models/insight.dart';
import 'ai_types.dart';

/// Pemicu yang dilacak (spec §5.5A).
abstract final class TriggerKind {
  static const pedas = 'Pedas';
  static const santan = 'Santan';
  static const susu = 'Susu';
  static const kopi = 'Kopi/Kafein';
  static const gorengan = 'Gorengan';
  static const mieInstan = 'Mie Instan';
  static const manis = 'Manis Berlebih';
  static const junkFood = 'Junk Food';

  static const all = <String>[
    pedas,
    santan,
    susu,
    kopi,
    gorengan,
    mieInstan,
    manis,
    junkFood,
  ];
}

/// Deteksi korelasi pemicu → mules / diare (spec §5.5A).
///
/// Logika:
/// - Untuk tiap kejadian mules (`level >= 3` atau diare Bristol >= 6),
///   cari FoodLog dalam 2-12 jam sebelumnya.
/// - Pemicu dihitung muncul kalau FoodLog-nya match (kategori/pedas/nama).
/// - Tampilkan cuma kalau muncul >= 2x di kejadian DAN proporsinya jelas.
/// - Confidence berdasarkan jumlah kejadian yang ada pemicunya
///   (sample kecil = jangan sok yakin).
class CorrelationResult {
  const CorrelationResult({
    required this.trigger,
    required this.hitCount,
    required this.totalEpisodes,
    required this.evidenceLogIds,
    required this.periodDays,
  });

  final String trigger;

  /// Berapa kejadian bermasalah yang punya pemicu ini di 2-12 jam sebelumnya.
  final int hitCount;

  /// Total kejadian bermasalah di periode ini.
  final int totalEpisodes;

  /// Id FoodLog + log kejadian pendukung (spec: "Kenapa AI bilang ini?").
  final List<String> evidenceLogIds;

  final int periodDays;

  String get confidence {
    if (hitCount >= 6) return InsightConfidence.tinggi;
    if (hitCount >= 4) return InsightConfidence.sedang;
    return InsightConfidence.rendah;
  }

  /// Kalimat jujur dengan angka pendukung, tanpa nuduh.
  String get body {
    final pemicuText = switch (trigger) {
      TriggerKind.pedas => 'Makanan pedas muncul',
      TriggerKind.mieInstan => 'Mie instan muncul',
      _ => '$trigger muncul',
    };
    return '$pemicuText di $hitCount dari $totalEpisodes kejadian mules/diare '
        'kamu $periodDays hari terakhir. Kemungkinan $trigger salah satu '
        'pemicunya. Bukan diagnosis ya — cuma pola dari catatanmu sendiri.';
  }
}

/// Cari korelasi kuat untuk rentang [days] hari.
///
/// Hasil dikembalikan urut dari yang paling kuat (hit count terbanyak).
/// Cuma mengembalikan korelasi yang lolos syarat >= 2x muncul.
List<CorrelationResult> findCorrelations(
  MuyesAiInput input, {
  int days = 7,
}) {
  final episodes = mergeMulesEpisodes(
    input.mulesSince(days),
    input.poopSince(days),
  ).where((e) => e.isBadEpisode).toList(growable: false);

  if (episodes.length < 2) return const [];

  final results = <CorrelationResult>[];
  for (final trigger in TriggerKind.all) {
    final evidence = <String>{};
    var hits = 0;
    for (final episode in episodes) {
      final match = _findTriggerFood(input.food, episode.time, trigger);
      if (match != null) {
        hits++;
        evidence.add(match.id);
        evidence.addAll(episode.sourceLogIds);
      }
    }
    // Spec §5.5A: tampilkan hanya kalau muncul minimal 2x dan polanya jelas.
    if (hits >= 2) {
      results.add(
        CorrelationResult(
          trigger: trigger,
          hitCount: hits,
          totalEpisodes: episodes.length,
          evidenceLogIds: evidence.toList(growable: false),
          periodDays: days,
        ),
      );
    }
  }

  results.sort((a, b) => b.hitCount.compareTo(a.hitCount));
  return results;
}

/// Cari FoodLog pemicu dalam jendela 2-12 jam sebelum [episodeTime].
///
/// Jendela mulai 2 jam (biar nggak salah tuduh makanan yang baru dimakan)
/// sampai 12 jam (batas wajar makanan masih berdampak).
FoodLog? _findTriggerFood(
  List<FoodLog> food,
  DateTime episodeTime,
  String trigger,
) {
  final windowStart = episodeTime.subtract(const Duration(hours: 12));
  final windowEnd = episodeTime.subtract(const Duration(hours: 2));

  FoodLog? best;
  for (final log in food) {
    if (log.eatenAt.isBefore(windowStart)) continue;
    if (log.eatenAt.isAfter(windowEnd)) continue;
    if (!matchesTrigger(log, trigger)) continue;
    // Ambil yang paling dekat dengan kejadian.
    if (best == null || log.eatenAt.isAfter(best.eatenAt)) best = log;
  }
  return best;
}

/// Apakah [log] match [trigger] — lihat kategori, level pedas, dan nama.
bool matchesTrigger(FoodLog log, String trigger) {
  final name = log.foodName.toLowerCase();
  final categories = log.categories;
  return switch (trigger) {
    TriggerKind.pedas =>
      log.spicyLevel >= 2 ||
          categories.contains(FoodCategories.pedas) ||
          name.contains('pedas') ||
          name.contains('pedes') ||
          name.contains('sambal') ||
          name.contains('seblak') ||
          name.contains('geprek'),
    TriggerKind.santan =>
      categories.contains(FoodCategories.santan) ||
          name.contains('santan') ||
          name.contains('kari') ||
          name.contains('rendang') ||
          name.contains('soto') ||
          name.contains('opor'),
    TriggerKind.susu =>
      categories.contains(FoodCategories.susu) ||
          name.contains('susu') ||
          name.contains('keju') ||
          name.contains('cheese') ||
          name.contains('yogurt'),
    TriggerKind.kopi =>
      categories.contains(FoodCategories.kopi) ||
          name.contains('kopi') ||
          name.contains('coffee') ||
          name.contains('espresso') ||
          name.contains('latte'),
    TriggerKind.gorengan =>
      categories.contains(FoodCategories.gorengan) ||
          name.contains('goreng') ||
          name.contains('gorengan') ||
          name.contains('cireng') ||
          name.contains('pisang goreng'),
    TriggerKind.mieInstan =>
      name.contains('mie instan') ||
          name.contains('indomie') ||
          name.contains('mi instan') ||
          name.contains('ramen instan') ||
          (categories.contains(FoodCategories.mie) &&
              name.contains('instan')),
    TriggerKind.manis =>
      categories.contains(FoodCategories.manis) ||
          name.contains('manis') ||
          name.contains('kue') ||
          name.contains('cake') ||
          name.contains('boba') ||
          name.contains('es krim'),
    TriggerKind.junkFood =>
      categories.contains(FoodCategories.junkFood) ||
          name.contains('junk') ||
          name.contains('burger') ||
          name.contains('pizza') ||
          name.contains('kentang'),
    _ => false,
  };
}
