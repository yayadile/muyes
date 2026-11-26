import '../models/food_log.dart';
import '../models/insight.dart';
import '../utils/date_utils.dart';
import 'ai_types.dart';

/// Deteksi pola makan abnormal dari FoodLog saja (spec §5.5D).
///
/// Baseline "normal" (bukan standar medis, cuma patokan pola):
/// - 2-4x makan/hari, jeda 3-6 jam
/// - Jam makan relatif teratur (variasi <2 jam)
/// - Tidak makan berat larut malam
///
/// Aturan:
/// - Jangan hitung kalori. Jangan diagnosis gangguan makan.
/// - Selalu kasih opsi "lupa catat" untuk gap panjang.
/// - Mode Puasa/IF ON → rule skip-makan + gap panjang dimatikan.
/// - Butuh minimal 3 hari data makan; kalau kurang, kasih pesan ajakan.
class EatingPatternDetector {
  const EatingPatternDetector(this.input);

  final MuyesAiInput input;

  /// Jam mulai "jam bangun" buat cek gap makan (spec §5.5D: 06:00-22:00).
  static const awakeStart = 6;
  static const awakeEnd = 22;

  /// Minimal hari data makan biar insight pola makan muncul.
  static const minDays = 3;

  List<Insight> detect({int days = 7}) {
    if (input.daysWithFoodLog(days) < minDays) {
      return [
        Insight(
          id: 'makan:cukup-data:$days',
          type: InsightType.eatingPattern,
          level: InsightLevel.info,
          title: 'Pola makan belum kebaca',
          body: 'Catat makan $minDays hari dulu biar pola makanmu kebaca. '
              'Santai, nggak harus detail — yang penting jamnya.',
          confidence: InsightConfidence.rendah,
          evidenceLogIds: const [],
          periodDays: days,
          createdAt: input.now,
        ),
      ];
    }

    final insights = <_InsightDraft>[];

    // Rule yang bisa dimatikan Mode Puasa (spec §5.5D).
    if (!input.fastingMode) {
      insights.addAll(_checkTooFewMeals(days));
      insights.addAll(_checkLongGap(days));
    }
    insights.addAll(_checkTooManyMeals(days));
    insights.addAll(_checkLateNightHeavy());
    insights.addAll(_checkIrregularTimes(days));
    insights.addAll(_checkBigPortions(days));
    insights.addAll(_checkTooMuchCoffee(days));
    insights.addAll(_checkJunkFood(days));
    insights.addAll(_checkNormalPattern(days));

    return [
      for (final draft in insights)
        Insight(
          id: draft.id,
          type: InsightType.eatingPattern,
          level: draft.level,
          title: draft.title,
          body: draft.body,
          confidence: draft.confidence,
          evidenceLogIds: draft.evidence,
          periodDays: days,
          createdAt: input.now,
        ),
    ];
  }

  // ---- Rule yang dimatikan Mode Puasa ----

  /// Makan cuma 0-1x/hari, 2 hari berturut-turut (skip kalau Mode Puasa ON).
  List<_InsightDraft> _checkTooFewMeals(int days) {
    final byDay = input.foodByDay(days);
    final sortedKeys = byDay.keys.toList()..sort();

    var run = 0;
    var runLogs = <FoodLog>[];
    for (final key in sortedKeys) {
      final logs = byDay[key]!;
      if (logs.length <= 1) {
        run++;
        runLogs = logs;
        if (run >= 2) {
          return [
            _draft(
              id: 'makan:terlalu-sedikit:$key',
              level: InsightLevel.warning,
              title: 'Makan cuma ${runLogs.length}x sehari 2 hari',
              body: 'Kamu cuma makan ${runLogs.length}x kemarin dan hari ini '
                  '(kalau lupa catat, isi dulu ya biar akurat). Pola ini '
                  'kalau berlanjut bisa bikin perut makin sensitif. Coba isi '
                  'makan ringan dulu kalau belum selera makan berat.',
              confidence: InsightConfidence.sedang,
              evidence: runLogs.map((l) => l.id).toList(growable: false),
            ),
          ];
        }
      } else {
        run = 0;
      }
    }
    return const [];
  }

  /// Gap makan >10 jam di jam bangun (06:00-22:00), atau tidak ada log
  /// makan >14 jam (skip kalau Mode Puasa ON).
  List<_InsightDraft> _checkLongGap(int days) {
    final food = input.foodSince(days);
    if (food.isEmpty) return const [];

    // Cek gap intra-hari di jam bangun untuk beberapa hari terakhir.
    final byDay = input.foodByDay(days);
    for (final entry in byDay.entries) {
      final logs = entry.value..sort((a, b) => a.eatenAt.compareTo(b.eatenAt));
      for (var i = 1; i < logs.length; i++) {
        final gap = logs[i].eatenAt.difference(logs[i - 1].eatenAt);
        // Cuma hitung gap yang jatuh di jam bangun.
        final gapStart = logs[i - 1].eatenAt;
        final inAwakeWindow =
            gapStart.hour >= awakeStart && gapStart.hour < awakeEnd;
        if (inAwakeWindow && gap.inHours > 10) {
          return [
            _draft(
              id: 'makan:gap-panjang:${dayKey(gapStart)}:${gapStart.hour}',
              level: InsightLevel.warning,
              title: 'Gap makan ${gap.inHours} jam',
              body: 'Ada jeda ${gap.inHours} jam antar makan di '
                  '${dayKey(gapStart)}. Kamu skip makan atau cuma lupa catat? '
                  'Kalau beneran skip, coba isi yang ringan dulu.',
              confidence: InsightConfidence.sedang,
              evidence: [logs[i - 1].id, logs[i].id],
            ),
          ];
        }
      }
    }

    // Gap dari log terakhir sampai sekarang > 14 jam.
    final last = food.last.eatenAt;
    final sinceLast = input.now.difference(last);
    if (sinceLast.inHours > 14) {
      return [
        _draft(
          id: 'makan:belum-makan:${dayKey(last)}',
          level: InsightLevel.warning,
          title: 'Terakhir makan ${sinceLast.inHours} jam lalu',
          body: 'Terakhir makan catatan jam ${formatTimeId(last)} '
              '(${sinceLast.inHours} jam lalu). Kamu skip makan, lupa catat, '
              'atau masih puasa? Kalau bukan puasa, coba isi dulu.',
          confidence: InsightConfidence.rendah,
          evidence: [food.last.id],
        ),
      ];
    }

    return const [];
  }

  // ---- Rule yang selalu jalan ----

  /// Makan >=6x/hari, 2 hari berturut-turut.
  List<_InsightDraft> _checkTooManyMeals(int days) {
    final byDay = input.foodByDay(days);
    final sortedKeys = byDay.keys.toList()..sort();

    var run = 0;
    var runKey = '';
    var runLogs = <FoodLog>[];
    for (final key in sortedKeys) {
      final logs = byDay[key]!;
      if (logs.length >= 6) {
        run++;
        runKey = key;
        runLogs = logs;
        if (run >= 2) {
          return [
            _draft(
              id: 'makan:terlalu-banyak:$runKey',
              level: InsightLevel.warning,
              title: 'Ngemil terus 2 hari',
              body: 'Kamu makan ${runLogs.length}x kemarin dan hari ini — '
                  'ngemil terus. Cek apakah ini lapar beneran atau cuma iseng '
                  '/ stres. Nggak perlu dihentikan mendadak kok.',
              confidence: InsightConfidence.sedang,
              evidence: runLogs.map((l) => l.id).toList(growable: false),
            ),
          ];
        }
      } else {
        run = 0;
      }
    }
    return const [];
  }

  /// Makan berat (porsi Sedang/Besar) jam 23:00-04:00, >=3x dalam 7 hari.
  List<_InsightDraft> _checkLateNightHeavy() {
    final heavy = input.food
        .where(_isLateNightHeavy)
        .toList(growable: false);
    if (heavy.length < 3) return const [];
    return [
      _draft(
        id: 'makan:larut-malam:7',
        level: InsightLevel.warning,
        title: '${heavy.length}x makan berat larut malam',
        body: '${heavy.length}x minggu ini kamu makan berat di atas jam 11 '
            'malam. Makan larut gini sering bikin mules / begah besok '
            'paginya. Coba majukan 1-2 jam kalau bisa.',
        confidence: InsightConfidence.sedang,
        evidence: heavy.map((l) => l.id).toList(growable: false),
      ),
    ];
  }

  /// Jam makan pertama bervariasi >3 jam antar hari dalam 7 hari.
  List<_InsightDraft> _checkIrregularTimes(int days) {
    final byDay = input.foodByDay(days);
    if (byDay.length < 3) return const [];

    final firstMealMinutes = <int>[];
    final evidence = <String>[];
    for (final entry in byDay.entries) {
      final logs = entry.value..sort((a, b) => a.eatenAt.compareTo(b.eatenAt));
      final first = logs.first;
      firstMealMinutes.add(first.eatenAt.hour * 60 + first.eatenAt.minute);
      evidence.add(first.id);
    }

    final min = firstMealMinutes.reduce((a, b) => a < b ? a : b);
    final max = firstMealMinutes.reduce((a, b) => a > b ? a : b);
    final spreadHours = (max - min) / 60.0;

    if (spreadHours > 3) {
      return [
        _draft(
          id: 'makan:jam-tidak-teratur:$days',
          level: InsightLevel.warning,
          title: 'Jam makan lompat-lompat',
          body: 'Jam makan pertama kamu $days hari terakhir bervariasi '
              '${spreadHours.toStringAsFixed(1)} jam (kadang '
              '${formatTimeId(DateTime(2026, 1, 1, min ~/ 60, min % 60))}, '
              'kadang '
              '${formatTimeId(DateTime(2026, 1, 1, max ~/ 60, max % 60))}). '
              'Perut suka pola yang lebih teratur. Nggak harus pas, yang '
              'penting nggak lompat-lompat banget.',
          confidence: InsightConfidence.sedang,
          evidence: evidence,
        ),
      ];
    }
    return const [];
  }

  /// Porsi Besar >=2x/hari, 3 hari berturut-turut.
  List<_InsightDraft> _checkBigPortions(int days) {
    final byDay = input.foodByDay(days);
    final sortedKeys = byDay.keys.toList()..sort();

    var run = 0;
    var runKey = '';
    var runLogs = <FoodLog>[];
    for (final key in sortedKeys) {
      final big = byDay[key]!
          .where((l) => l.portion == FoodPortion.besar)
          .toList(growable: false);
      if (big.length >= 2) {
        run++;
        runKey = key;
        runLogs = big;
        if (run >= 3) {
          return [
            _draft(
              id: 'makan:porsi-besar:$runKey',
              level: InsightLevel.warning,
              title: 'Porsi besar 3 hari berturut-turut',
              body: '3 hari terakhir porsi kamu besar terus (terakhir '
                  '$runKey: ${runLogs.length}x). Kalau habis itu sering '
                  'begah / mules, coba turunin ke Sedang dulu.',
              confidence: InsightConfidence.sedang,
              evidence: runLogs.map((l) => l.id).toList(growable: false),
            ),
          ];
        }
      } else {
        run = 0;
      }
    }
    return const [];
  }

  /// Kopi/Kafein >=4x dalam sehari.
  List<_InsightDraft> _checkTooMuchCoffee(int days) {
    final byDay = input.foodByDay(days);
    for (final entry in byDay.entries) {
      final coffees = entry.value
          .where(
            (l) =>
                l.categories.contains(FoodCategories.kopi) ||
                l.foodName.toLowerCase().contains('kopi'),
          )
          .toList(growable: false);
      if (coffees.length >= 4) {
        return [
          _draft(
            id: 'makan:kopi-banyak:${entry.key}',
            level: InsightLevel.warning,
            title: 'Kopi ${coffees.length}x hari ini',
            body: 'Kopi ${coffees.length}x hari ini. Kafein berlebih bisa '
                'bikin perut perih + eek jadi lembek. Coba ganti 1-2 gelas '
                'ke air putih / teh herbal dulu.',
            confidence: InsightConfidence.sedang,
            evidence: coffees.map((l) => l.id).toList(growable: false),
          ),
        ];
      }
    }
    return const [];
  }

  /// Junk Food / Gorengan >70% dari total makan seminggu.
  List<_InsightDraft> _checkJunkFood(int days) {
    final food = input.foodSince(days);
    if (food.length < 6) return const [];

    final junk = food
        .where(
          (l) =>
              l.categories.contains(FoodCategories.junkFood) ||
              l.categories.contains(FoodCategories.gorengan),
        )
        .toList(growable: false);

    final ratio = junk.length / food.length;
    if (ratio > 0.7) {
      final percent = (ratio * 100).round();
      return [
        _draft(
          id: 'makan:junk-food:$days',
          level: InsightLevel.warning,
          title: '$percent% makanan junk food',
          body: '$percent%+ makanan kamu $days hari terakhir junk food / '
              'gorengan (${junk.length} dari ${food.length} makan). Bukan '
              'dilarang, tapi variasinya kurang — coba selipin 1 makanan '
              'yang lebih ringan per hari.',
          confidence: InsightConfidence.sedang,
          evidence: junk.map((l) => l.id).toList(growable: false),
        ),
      ];
    }
    return const [];
  }

  /// Pola makan normal (2-4x/hari, teratur, tidak larut malam).
  List<_InsightDraft> _checkNormalPattern(int days) {
    final food = input.foodSince(days);
    final byDay = input.foodByDay(days);
    if (byDay.length < minDays || food.isEmpty) return const [];

    final avg = food.length / byDay.length;
    if (avg < 2 || avg > 4) return const [];

    final lateNight = input.food.where(_isLateNightHeavy).length;
    if (lateNight > 0) return const [];

    return [
      _draft(
        id: 'makan:normal:$days',
        level: InsightLevel.info,
        title: 'Pola makan teratur',
        body: 'Pola makan kamu $days hari terakhir teratur — rata-rata '
            '${avg.toStringAsFixed(1)}x makan/hari, nggak ada makan berat '
            'larut malam. Mantap!',
        confidence: InsightConfidence.sedang,
        evidence: food.map((l) => l.id).toList(growable: false),
      ),
    ];
  }

  static bool _isLateNightHeavy(FoodLog log) {
    final hour = log.eatenAt.hour;
    final isLate = hour >= 23 || hour < 4;
    return isLate && log.portion != FoodPortion.kecil;
  }

  _InsightDraft _draft({
    required String id,
    required String level,
    required String title,
    required String body,
    required String confidence,
    required List<String> evidence,
  }) => _InsightDraft(
    id: id,
    level: level,
    title: title,
    body: body,
    confidence: confidence,
    evidence: evidence,
  );
}

class _InsightDraft {
  const _InsightDraft({
    required this.id,
    required this.level,
    required this.title,
    required this.body,
    required this.confidence,
    required this.evidence,
  });

  final String id;
  final String level;
  final String title;
  final String body;
  final String confidence;
  final List<String> evidence;
}
