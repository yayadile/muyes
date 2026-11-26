import 'dart:math' as math;

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

/// Hasil satu korelasi pemicu → mules/diare dengan statistik 2x2 (spec §5.5A).
///
/// Di-versi 2x2 dua sisi dihitung, biar nggak cuma "berapa kejadian yang ada
/// pemicunya" — angka itu menyesatkan kalau pemicunya sering dimakan:
///  - Sisi kejadian: [hitCount] dari [totalEpisodes] kejadian mules/diare
///    punya pemicu ini di jendela 2-12 jam sebelumnya.
///  - Sisi pemakaian: dari [exposureCount]x user makan pemicu ini,
///    [exposureHits]x di antaranya diikuti kejadian — dibanding makanan lain
///    ([otherExposureHits]/[otherExposureCount]).
///
/// Rate dihaluskan Laplace smoothing (+1/+2) biar sampel kecil nggak bikin
/// angka ekstrem, dan confidence dihitung dari batas bawah interval Wilson —
/// bukan threshold mentah (spec: jujur, jangan sok yakin).
class CorrelationResult {
  const CorrelationResult({
    required this.trigger,
    required this.hitCount,
    required this.totalEpisodes,
    required this.exposureCount,
    required this.exposureHits,
    required this.otherExposureCount,
    required this.otherExposureHits,
    required this.evidenceLogIds,
    required this.periodDays,
    this.coTriggers = const <String>[],
  });

  final String trigger;

  /// Berapa kejadian bermasalah yang punya pemicu ini di 2-12 jam sebelumnya.
  final int hitCount;

  /// Total kejadian bermasalah di periode ini.
  final int totalEpisodes;

  /// Berapa kali user makan pemicu ini di periode yang sama.
  final int exposureCount;

  /// Dari [exposureCount]x itu, berapa yang diikuti kejadian bermasalah.
  final int exposureHits;

  /// Berapa kali user makan makanan LAIN (pembanding) di periode yang sama.
  final int otherExposureCount;

  /// Dari makanan lain itu, berapa yang diikuti kejadian bermasalah.
  final int otherExposureHits;

  /// Id FoodLog + log kejadian pendukung (spec: "Kenapa AI bilang ini?").
  final List<String> evidenceLogIds;

  final int periodDays;

  /// Pemicu lain yang datanya kembar (hampir selalu muncul bareng) — belum
  /// bisa dipisah dari data, jadi jangan tampil sebagai kartu terpisah.
  final List<String> coTriggers;

  bool get isConfounded => coTriggers.isNotEmpty;

  /// Rate pemicu → kejadian, dihaluskan Laplace (a+1)/(n+2).
  double get smoothedRate => (exposureHits + 1) / (exposureCount + 2);

  /// Rate makanan lain → kejadian, dihaluskan Laplace juga.
  double get baselineRate => (otherExposureHits + 1) / (otherExposureCount + 2);

  /// Berapa kali lebih sering kejadian muncul setelah pemicu ini vs makanan
  /// lain (relative risk versi halus). > 1 = pemicu ini beda dari kebanyakan.
  double get lift => smoothedRate / baselineRate;

  String get confidence {
    final lower = wilsonLowerBound(exposureHits, exposureCount);
    final clearlyAboveBaseline = lower > baselineRate;
    if (exposureCount >= 12 &&
        hitCount >= 4 &&
        lift >= 1.5 &&
        clearlyAboveBaseline) {
      return InsightConfidence.tinggi;
    }
    if (exposureCount >= 6 &&
        hitCount >= 2 &&
        lift >= 1.2 &&
        clearlyAboveBaseline) {
      return InsightConfidence.sedang;
    }
    return InsightConfidence.rendah;
  }

  /// Kalimat jujur dengan angka pendukung, tanpa nuduh.
  String get body {
    final pemicuText = switch (trigger) {
      TriggerKind.pedas => 'Makanan pedas muncul',
      TriggerKind.mieInstan => 'Mie instan muncul',
      _ => '$trigger muncul',
    };
    final lines = <String>[
      '$pemicuText di $hitCount dari $totalEpisodes kejadian mules/diare '
          'kamu $periodDays hari terakhir. '
          'Di periode yang sama kamu makan $trigger ${exposureCount}x — '
          '${exposureHits}x di antaranya diikuti mules/diare dalam 2-12 jam '
          'berikutnya.',
      if (otherExposureCount > 0)
        'Sebagai pembanding: makanan lain $otherExposureHits dari '
            '${otherExposureCount}x.',
      'Perkiraan risikonya ≈${lift.toStringAsFixed(1)}x dibanding makanan '
          'lain${lift >= 2 ? ' — kelihatannya cukup beda' : ' — masih tipis, bisa kebetulan'}.',
      if (isConfounded)
        'Catatan: ${coTriggers.join(', ')} sering muncul bareng $trigger, '
            'jadi belum bisa dipisah mana yang paling berpengaruh.',
      'Kemungkinan $trigger salah satu pemicunya. Bukan diagnosis ya — '
          'cuma pola dari catatanmu sendiri.',
    ];
    return lines.join(' ');
  }

  CorrelationResult withCoTriggers(List<String> others) {
    return CorrelationResult(
      trigger: trigger,
      hitCount: hitCount,
      totalEpisodes: totalEpisodes,
      exposureCount: exposureCount,
      exposureHits: exposureHits,
      otherExposureCount: otherExposureCount,
      otherExposureHits: otherExposureHits,
      evidenceLogIds: evidenceLogIds,
      periodDays: periodDays,
      coTriggers: others,
    );
  }
}

/// Batas bawah interval kepercayaan Wilson (default 95%) buat proporsi
/// `successes / total`. Dipakai buat confidence: sampel kecil otomatis
/// dapet batas bawah rendah, jadi nggak gampang bilang "sok yakin".
double wilsonLowerBound(int successes, int total, {double z = 1.96}) {
  if (total <= 0) return 0;
  final n = total.toDouble();
  final p = successes / n;
  final z2 = z * z;
  final denom = 1 + z2 / n;
  final center = p + z2 / (2 * n);
  final margin = z * math.sqrt((p * (1 - p) / n) + z2 / (4 * n * n));
  return ((center - margin) / denom).clamp(0.0, 1.0);
}

/// Cari korelasi kuat untuk rentang [days] hari.
///
/// Gate tampil (lebih ketat dari versi lama):
///  - minimal 2 kejadian mules/diare kena pemicu ini (spec §5.5A), dan
///  - rate pemicu (Laplace) harus lebih tinggi dari rate makanan lain
///    (lift > 1) — pemicu yang sering dimakan tanpa efek nggak dilaporin.
///
/// Pemicu yang datanya kembar (mengarah ke kejadian yang sama persis)
/// digabung jadi satu hasil: yang paling kuat jadi primary, sisanya masuk
/// [CorrelationResult.coTriggers] biar nggak tampil sebagai kartu terpisah.
List<CorrelationResult> findCorrelations(
  MuyesAiInput input, {
  int days = 7,
}) {
  final food = input.foodSince(days);
  final episodes = mergeMulesEpisodes(
    input.mulesSince(days),
    input.poopSince(days),
  ).where((e) => e.isBadEpisode).toList(growable: false);

  if (episodes.length < 2 || food.isEmpty) return const [];

  // Untuk tiap FoodLog: index kejadian yang jatuh di jendela 2-12 jam
  // setelahnya. Dipakai dua arah (sisi kejadian + sisi pemakaian).
  final covered = <List<int>>[
    for (final log in food) _episodesAfter(log.eatenAt, episodes),
  ];

  final candidates = <_TriggerCandidate>[];
  for (final trigger in TriggerKind.all) {
    var exposures = 0;
    var exposureHits = 0;
    var otherExposures = 0;
    var otherHits = 0;
    final hitEpisodes = <int>{};
    final evidence = <String>{};

    for (var i = 0; i < food.length; i++) {
      final coveredEpisodes = covered[i];
      if (matchesTrigger(food[i], trigger)) {
        exposures++;
        if (coveredEpisodes.isNotEmpty) {
          exposureHits++;
          hitEpisodes.addAll(coveredEpisodes);
          evidence.add(food[i].id);
          for (final e in coveredEpisodes) {
            evidence.addAll(episodes[e].sourceLogIds);
          }
        }
      } else {
        otherExposures++;
        if (coveredEpisodes.isNotEmpty) otherHits++;
      }
    }

    if (hitEpisodes.length < 2 || exposures < 2) continue;

    final result = CorrelationResult(
      trigger: trigger,
      hitCount: hitEpisodes.length,
      totalEpisodes: episodes.length,
      exposureCount: exposures,
      exposureHits: exposureHits,
      otherExposureCount: otherExposures,
      otherExposureHits: otherHits,
      evidenceLogIds: evidence.toList(growable: false),
      periodDays: days,
    );
    // Pemicu yang rate-nya nggak beda dari makanan lain = bukan sinyal.
    if (result.lift <= 1.0) continue;
    candidates.add(_TriggerCandidate(result, hitEpisodes));
  }

  // Gabung pemicu kembar: yang nunjuk ke kejadian yang (hampir) sama.
  final results = <CorrelationResult>[];
  final used = List<bool>.filled(candidates.length, false);
  for (var i = 0; i < candidates.length; i++) {
    if (used[i]) continue;
    used[i] = true;
    final group = <_TriggerCandidate>[candidates[i]];
    for (var j = i + 1; j < candidates.length; j++) {
      if (used[j]) continue;
      if (_looksIdentical(candidates[i].episodes, candidates[j].episodes)) {
        used[j] = true;
        group.add(candidates[j]);
      }
    }
    group.sort(_compareStrength);
    results.add(
      group.first.result.withCoTriggers([
        for (final c in group.skip(1)) c.result.trigger,
      ]),
    );
  }

  // Paling kuat dulu (lift), tie-break sampel kejadian lebih banyak.
  results.sort((a, b) {
    final byLift = b.lift.compareTo(a.lift);
    return byLift != 0 ? byLift : b.hitCount.compareTo(a.hitCount);
  });
  return results;
}

/// Kejadian yang jatuh 2-12 jam setelah [eaten] (spec §5.5A).
List<int> _episodesAfter(DateTime eaten, List<AiMulesEpisode> episodes) {
  const minGap = Duration(hours: 2);
  const maxGap = Duration(hours: 12);
  final result = <int>[];
  for (var i = 0; i < episodes.length; i++) {
    final gap = episodes[i].time.difference(eaten);
    if (gap >= minGap && gap <= maxGap) result.add(i);
  }
  return result;
}

/// Dua pemicu dianggap kembar kalau set kejadiannya (hampir) sama:
/// minimal 2 kejadian bareng dan overlap >= 75% dari yang lebih kecil.
bool _looksIdentical(Set<int> a, Set<int> b) {
  final overlap = a.intersection(b).length;
  if (overlap < 2) return false;
  return overlap / math.min(a.length, b.length) >= 0.75;
}

/// Urutan kekuatan pemicu: lift > jumlah kejadian > jumlah eksposur.
/// Tie-break terakhir pakai urutan [TriggerKind.all] biar deterministik.
int _compareStrength(_TriggerCandidate a, _TriggerCandidate b) {
  final byLift = b.result.lift.compareTo(a.result.lift);
  if (byLift != 0) return byLift;
  final byHits = b.result.hitCount.compareTo(a.result.hitCount);
  if (byHits != 0) return byHits;
  final byExposure = b.result.exposureCount.compareTo(a.result.exposureCount);
  if (byExposure != 0) return byExposure;
  return TriggerKind.all
      .indexOf(a.result.trigger)
      .compareTo(TriggerKind.all.indexOf(b.result.trigger));
}

class _TriggerCandidate {
  const _TriggerCandidate(this.result, this.episodes);

  final CorrelationResult result;

  /// Index kejadian yang kena pemicu ini — buat deteksi pemicu kembar.
  final Set<int> episodes;
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
