import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/ai/abnormal_detector.dart';
import 'package:muyes/ai/ai_types.dart';
import 'package:muyes/ai/analyzer.dart';
import 'package:muyes/ai/correlation.dart';
import 'package:muyes/ai/eating_pattern_detector.dart';
import 'package:muyes/ai/weekly_summary.dart';
import 'package:muyes/models/food_log.dart';
import 'package:muyes/models/insight.dart';
import 'package:muyes/models/mules_log.dart';
import 'package:muyes/models/poop_log.dart';

/// Hari test terakhir: Rabu 25 Nov 2026.
final testNow = DateTime(2026, 11, 25, 20);

FoodLog food(
  DateTime at,
  String name, {
  List<String> categories = const [],
  int spicy = 0,
  String portion = FoodPortion.sedang,
}) {
  return FoodLog(
    id: 'food-${at.millisecondsSinceEpoch}-$name',
    eatenAt: at,
    foodName: name,
    categories: categories,
    spicyLevel: spicy,
    portion: portion,
    createdAt: at,
    updatedAt: at,
  );
}

PoopLog poop(
  DateTime at, {
  int? bristol,
  int? pain,
  bool? blood,
  bool? mucus,
  String? color,
  String? id,
}) {
  return PoopLog(
    id: id ?? 'poop-${at.millisecondsSinceEpoch}-${bristol ?? 'x'}',
    poopedAt: at,
    bristol: bristol,
    painLevel: pain,
    hasBlood: blood,
    hasMucus: mucus,
    color: color,
    createdAt: at,
    updatedAt: at,
  );
}

MulesLog mules(DateTime at, int level, {String? id}) {
  return MulesLog(
    id: id ?? 'mules-${at.millisecondsSinceEpoch}-$level',
    feltAt: at,
    painLevel: level,
    createdAt: at,
    updatedAt: at,
  );
}

MuyesAiInput inputWith({
  List<FoodLog> foodLogs = const [],
  List<PoopLog> poopLogs = const [],
  List<MulesLog> mulesLogs = const [],
  bool fasting = false,
}) {
  return MuyesAiInput(
    food: foodLogs,
    poop: poopLogs,
    mules: mulesLogs,
    now: testNow,
    fastingMode: fasting,
  );
}

void main() {
  group('mergeMulesEpisodes — dedup <30 menit (spec §5.2b)', () {
    test('MulesLog & PoopLog.painLevel <30 menit = 1 kejadian', () {
      final episodes = mergeMulesEpisodes(
        [mules(DateTime(2026, 11, 25, 10), 3)],
        [poop(DateTime(2026, 11, 25, 10, 15), pain: 2)],
      );
      expect(episodes, hasLength(1));
      expect(episodes.single.level, 3); // ambil yang tertinggi
      expect(episodes.single.time, DateTime(2026, 11, 25, 10)); // paling awal
      expect(episodes.single.sourceLogIds, hasLength(2));
    });

    test('jarak >30 menit = 2 kejadian terpisah', () {
      final episodes = mergeMulesEpisodes(
        [mules(DateTime(2026, 11, 25, 10), 3)],
        [poop(DateTime(2026, 11, 25, 10, 31), pain: 2)],
      );
      expect(episodes, hasLength(2));
    });

    test('tepat 30 menit = 2 kejadian (window < 30, bukan <=)', () {
      final episodes = mergeMulesEpisodes(
        [mules(DateTime(2026, 11, 25, 10), 3)],
        [poop(DateTime(2026, 11, 25, 10, 30), pain: 2)],
      );
      expect(episodes, hasLength(2));
    });

    test('MulesLog level 0 ("Nggak mules") bukan kejadian', () {
      expect(
        mergeMulesEpisodes([mules(DateTime(2026, 11, 25, 10), 0)], const []),
        isEmpty,
      );
    });

    test('PoopLog tanpa pain & tanpa Bristol bukan kejadian mules', () {
      expect(
        mergeMulesEpisodes(const [], [poop(DateTime(2026, 11, 25, 10))]),
        isEmpty,
      );
    });

    test('PoopLog Bristol 6 tanpa pain tetap kejadian (diare)', () {
      final episodes = mergeMulesEpisodes(
        const [],
        [poop(DateTime(2026, 11, 25, 10), bristol: 6)],
      );
      expect(episodes, hasLength(1));
      expect(episodes.single.level, 0);
      expect(episodes.single.hasDiarrhea, isTrue);
      expect(episodes.single.isBadEpisode, isTrue);
    });

    test('diare + mules log terdekat digabung dengan flag diare', () {
      final episodes = mergeMulesEpisodes(
        [mules(DateTime(2026, 11, 25, 10, 10), 4)],
        [poop(DateTime(2026, 11, 25, 10), bristol: 7)],
      );
      expect(episodes, hasLength(1));
      expect(episodes.single.level, 4);
      expect(episodes.single.hasDiarrhea, isTrue);
    });
  });

  group('Correlation — makanan → mules/diare (spec §5.5A)', () {
    // Pola spec §10: makan pedas level 4-5, 6-10 jam lagi mules.
    List<FoodLog> spicySchedule() => [
      food(
        DateTime(2026, 11, 20, 12),
        'Seblak pedas level 5',
        categories: const [FoodCategories.pedas],
        spicy: 5,
      ),
      food(
        DateTime(2026, 11, 21, 12),
        'Ayam geprek sambal',
        categories: const [FoodCategories.pedas],
        spicy: 4,
      ),
      food(
        DateTime(2026, 11, 22, 12),
        'Mie pedas level 5',
        categories: const [FoodCategories.pedas],
        spicy: 5,
      ),
      food(
        DateTime(2026, 11, 23, 12),
        'Nasi ayam',
        categories: const [FoodCategories.nasi],
      ),
    ];

    List<PoopLog> mulesAfter() => [
      // 6-8 jam setelah makan pedas → mules + diare.
      poop(DateTime(2026, 11, 20, 19), bristol: 6, pain: 4),
      poop(DateTime(2026, 11, 21, 20), bristol: 4, pain: 3),
      poop(DateTime(2026, 11, 22, 20), bristol: 6, pain: 3),
      // Hari tanpa pedas: normal.
      poop(DateTime(2026, 11, 23, 19), bristol: 4),
    ];

    test('pedas terdeteksi muncul di 3/3 kejadian', () {
      final results = findCorrelations(
        inputWith(foodLogs: spicySchedule(), poopLogs: mulesAfter()),
        days: 7,
      );
      final pedas = results.firstWhere((r) => r.trigger == TriggerKind.pedas);
      expect(pedas.hitCount, 3);
      expect(pedas.totalEpisodes, 3);
      expect(pedas.evidenceLogIds.length, greaterThanOrEqualTo(3));
    });

    test('confidence naik sesuai jumlah sampel', () {
      final results = findCorrelations(
        inputWith(foodLogs: spicySchedule(), poopLogs: mulesAfter()),
        days: 7,
      );
      final pedas = results.firstWhere((r) => r.trigger == TriggerKind.pedas);
      // 3 hits → Rendah (jujur: sampel kecil).
      expect(pedas.confidence, InsightConfidence.rendah);
      expect(pedas.body, contains('3 dari 3'));
      expect(pedas.body, contains('Bukan diagnosis'));
    });

    test('cuma muncul 1x → TIDAK ditampilkan (minimal 2x)', () {
      final results = findCorrelations(
        inputWith(
          foodLogs: [
            food(
              DateTime(2026, 11, 20, 12),
              'Seblak',
              categories: const [FoodCategories.pedas],
              spicy: 5,
            ),
          ],
          poopLogs: [poop(DateTime(2026, 11, 20, 19), bristol: 6, pain: 4)],
        ),
        days: 7,
      );
      expect(results, isEmpty);
    });

    test('makanan di luar jendela 2-12 jam tidak dihitung pemicu', () {
      final results = findCorrelations(
        inputWith(
          foodLogs: [
            // 1 jam sebelum mules (terlalu dekat) → skip.
            food(
              DateTime(2026, 11, 20, 18),
              'Seblak 1',
              categories: const [FoodCategories.pedas],
              spicy: 5,
            ),
            // 20 jam sebelum mules (terlalu jauh) → skip.
            food(
              DateTime(2026, 11, 20, 0),
              'Seblak 2',
              categories: const [FoodCategories.pedas],
              spicy: 5,
            ),
          ],
          poopLogs: [poop(DateTime(2026, 11, 20, 19), bristol: 6, pain: 4)],
        ),
        days: 7,
      );
      expect(results.where((r) => r.trigger == TriggerKind.pedas), isEmpty);
    });

    test('mules level 1-2 ringan BUKAN "kejadian bermasalah"', () {
      final results = findCorrelations(
        inputWith(
          foodLogs: [
            food(
              DateTime(2026, 11, 20, 12),
              'Seblak',
              categories: const [FoodCategories.pedas],
              spicy: 5,
            ),
            food(
              DateTime(2026, 11, 21, 12),
              'Seblak',
              categories: const [FoodCategories.pedas],
              spicy: 5,
            ),
          ],
          // Level 2 doang — nggak masuk korelasi (butuh >=3 atau diare).
          poopLogs: [
            poop(DateTime(2026, 11, 20, 19), pain: 2),
            poop(DateTime(2026, 11, 21, 19), pain: 2),
          ],
        ),
        days: 7,
      );
      expect(results, isEmpty);
    });

    test('pemicu yang sering dimakan tapi rate-nya sama = bukan sinyal', () {
      // Pedas dimakan 8x (2x diikuti mules). Makanan lain juga 8x dengan
      // rate sama — artinya pedas nggak beda dari makanan lain.
      final foodLogs = <FoodLog>[];
      final poopLogs = <PoopLog>[];
      for (var i = 0; i < 2; i++) {
        final day = 20 + i;
        foodLogs.add(
          food(
            DateTime(2026, 11, day, 12),
            'Seblak $i',
            categories: const [FoodCategories.pedas],
            spicy: 5,
          ),
        );
        foodLogs.add(food(DateTime(2026, 11, day, 9), 'Nasi uduk $i'));
        poopLogs.add(
          poop(DateTime(2026, 11, day, 19), bristol: 6, pain: 4),
        );
      }
      for (var i = 0; i < 6; i++) {
        foodLogs.add(
          food(
            DateTime(2026, 11, 23, 8 + i),
            'Seblak $i',
            categories: const [FoodCategories.pedas],
            spicy: 5,
          ),
        );
        foodLogs.add(food(DateTime(2026, 11, 24, 8 + i), 'Roti $i'));
      }
      final results = findCorrelations(
        inputWith(foodLogs: foodLogs, poopLogs: poopLogs),
        days: 7,
      );
      expect(results.where((r) => r.trigger == TriggerKind.pedas), isEmpty);
    });

    test('denominator jujur: eksposur & pembanding muncul di body', () {
      // 4 kejadian, semuanya didahului pedas — tapi pedas cuma 4 dari 12
      // log makan, dan makanan lain 0 dari 8x. Body harus nunjukin itu.
      final foodLogs = <FoodLog>[];
      final poopLogs = <PoopLog>[];
      for (var i = 0; i < 4; i++) {
        foodLogs.add(
          food(
            DateTime(2026, 11, 20 + i, 12),
            'Ayam geprek $i',
            categories: const [FoodCategories.pedas],
            spicy: 4,
          ),
        );
        // Setelah episode → bukan pemicu.
        foodLogs.add(food(DateTime(2026, 11, 20 + i, 22, 30), 'Roti $i'));
        poopLogs.add(
          poop(DateTime(2026, 11, 20 + i, 19), bristol: 6, pain: 4),
        );
      }
      for (var i = 0; i < 4; i++) {
        foodLogs.add(food(DateTime(2026, 11, 24, 6 + i), 'Bubur $i'));
      }

      final results = findCorrelations(
        inputWith(foodLogs: foodLogs, poopLogs: poopLogs),
        days: 7,
      );
      final pedas = results.firstWhere((r) => r.trigger == TriggerKind.pedas);
      expect(pedas.hitCount, 4);
      expect(pedas.totalEpisodes, 4);
      expect(pedas.exposureCount, 4);
      expect(pedas.exposureHits, 4);
      expect(pedas.otherExposureCount, 8);
      expect(pedas.otherExposureHits, 0);
      expect(pedas.body, contains('kamu makan Pedas 4x'));
      expect(pedas.body, contains('makanan lain 0 dari 8x'));
      // 4 dari 4 eksposur, tapi sampel kecil → tetap Rendah (jujur).
      expect(pedas.confidence, InsightConfidence.rendah);
    });

    test('pemicu yang selalu bareng digabung, bukan kartu kembar', () {
      // "Ayam geprek goreng" match Pedas DAN Gorengan di kejadian yang sama.
      final foodLogs = <FoodLog>[
        for (var i = 0; i < 3; i++)
          food(
            DateTime(2026, 11, 20 + i, 12),
            'Ayam geprek goreng $i',
            categories: const [FoodCategories.pedas, FoodCategories.gorengan],
            spicy: 4,
          ),
        for (var i = 0; i < 2; i++)
          food(DateTime(2026, 11, 20 + i, 22, 30), 'Roti $i'),
      ];
      final poopLogs = <PoopLog>[
        for (var i = 0; i < 3; i++)
          poop(DateTime(2026, 11, 20 + i, 19), bristol: 6, pain: 4),
      ];

      final results = findCorrelations(
        inputWith(foodLogs: foodLogs, poopLogs: poopLogs),
        days: 7,
      );
      expect(results, hasLength(1));
      expect(results.single.trigger, TriggerKind.pedas);
      expect(results.single.coTriggers, contains(TriggerKind.gorengan));
      expect(results.single.isConfounded, isTrue);
      expect(results.single.body, contains('sering muncul bareng'));
    });

    test('confidence Tinggi butuh sampel banyak & jelas di atas baseline', () {
      final foodLogs = <FoodLog>[];
      final poopLogs = <PoopLog>[];
      // 8 episode, masing-masing didahului pedas 6 jam sebelumnya.
      for (var i = 0; i < 8; i++) {
        foodLogs.add(
          food(
            DateTime(2026, 11, 10 + i, 14),
            'Seblak $i',
            categories: const [FoodCategories.pedas],
            spicy: 5,
          ),
        );
        // Setelah episode → bukan pemicu buat makanan pembanding.
        foodLogs.add(food(DateTime(2026, 11, 10 + i, 22, 30), 'Roti $i'));
        poopLogs.add(
          poop(DateTime(2026, 11, 10 + i, 20), bristol: 6, pain: 4),
        );
      }
      // Eksposur pedas tambahan tanpa episode → denominator gede.
      for (var i = 0; i < 5; i++) {
        foodLogs.add(
          food(
            DateTime(2026, 11, 18, 6 + i),
            'Seblak extra $i',
            categories: const [FoodCategories.pedas],
            spicy: 5,
          ),
        );
      }
      for (var i = 0; i < 7; i++) {
        foodLogs.add(food(DateTime(2026, 11, 23, 6 + i), 'Bubur $i'));
      }

      final results = findCorrelations(
        inputWith(foodLogs: foodLogs, poopLogs: poopLogs),
        days: 30,
      );
      final pedas = results.firstWhere((r) => r.trigger == TriggerKind.pedas);
      expect(pedas.exposureCount, 13);
      expect(pedas.exposureHits, 8);
      expect(pedas.confidence, InsightConfidence.tinggi);
    });

    test('Wilson lower bound: sampel kecil lebih rendah', () {
      expect(wilsonLowerBound(2, 2), lessThan(wilsonLowerBound(8, 9)));
      expect(wilsonLowerBound(0, 0), 0);
    });
  });

  group('AbnormalDetector (spec §5.5B)', () {
    test('darah → alert merah', () {
      final insights = AbnormalDetector(
        inputWith(
          poopLogs: [poop(DateTime(2026, 11, 25, 8), bristol: 4, blood: true)],
        ),
      ).detect();
      final darah = insights.firstWhere((i) => i.id.startsWith('abnormal:darah'));
      expect(darah.level, InsightLevel.alert);
      expect(darah.body, contains('dokter'));
      expect(darah.confidence, InsightConfidence.tinggi);
      expect(darah.evidenceLogIds, hasLength(1));
    });

    test('eek hitam → alert', () {
      final insights = AbnormalDetector(
        inputWith(
          poopLogs: [
            poop(DateTime(2026, 11, 25, 8), bristol: 4, color: PoopColors.hitam),
          ],
        ),
      ).detect();
      expect(
        insights.any(
          (i) => i.id.startsWith('abnormal:hitam') && i.level == InsightLevel.alert,
        ),
        isTrue,
      );
    });

    test('diare >=3x sehari 2 hari berturut-turut → alert merah', () {
      final poopLogs = [
        for (var h = 20; h <= 21; h++)
          for (var i = 0; i < 3; i++)
            poop(DateTime(2026, 11, h, 8 + i * 4), bristol: 7),
      ];
      final insights = AbnormalDetector(inputWith(poopLogs: poopLogs)).detect();
      final diare = insights.firstWhere(
        (i) => i.id.startsWith('abnormal:diare-berulang'),
      );
      expect(diare.level, InsightLevel.alert);
      expect(diare.body, contains('Perbanyak cairan'));
      expect(diare.evidenceLogIds, hasLength(6));
    });

    test('diare 1 hari doang → TIDAK ada alert diare berulang', () {
      final poopLogs = [
        for (var i = 0; i < 3; i++) poop(DateTime(2026, 11, 24, 8 + i * 4), bristol: 6),
      ];
      final insights = AbnormalDetector(inputWith(poopLogs: poopLogs)).detect();
      expect(
        insights.where((i) => i.id.startsWith('abnormal:diare-berulang')),
        isEmpty,
      );
    });

    test('tidak eek >=3 hari → warning', () {
      final insights = AbnormalDetector(
        inputWith(
          poopLogs: [poop(DateTime(2026, 11, 20, 8), bristol: 4)],
        ),
      ).detect();
      final noPoop = insights.firstWhere(
        (i) => i.id.startsWith('abnormal:nggak-eek'),
      );
      expect(noPoop.level, InsightLevel.warning);
      expect(noPoop.body, contains('belum eek 5 hari'));
    });

    test('mules >=4x sehari → warning', () {
      final mulesLogs = [
        for (var i = 0; i < 4; i++)
          mules(DateTime(2026, 11, 25, 8 + i * 2), 3),
      ];
      final insights = AbnormalDetector(inputWith(mulesLogs: mulesLogs)).detect();
      expect(
        insights.any(
          (i) =>
              i.id.startsWith('abnormal:mules-banyak') &&
              i.level == InsightLevel.warning,
        ),
        isTrue,
      );
    });

    test('mules 3x + 1 di-lock dedup <30 menit → tetap 4, bukan 5', () {
      final mulesLogs = [
        for (var i = 0; i < 3; i++) mules(DateTime(2026, 11, 25, 8 + i * 2), 3),
        mules(DateTime(2026, 11, 25, 14, 50), 3),
      ];
      // Pain di log eek 10 menit setelah mules ke-4 → harus di-merge.
      final poopLogs = [poop(DateTime(2026, 11, 25, 15), pain: 4)];
      final insights = AbnormalDetector(
        inputWith(mulesLogs: mulesLogs, poopLogs: poopLogs),
      ).detect();
      final mulesBanyak = insights.firstWhere(
        (i) => i.id.startsWith('abnormal:mules-banyak'),
      );
      expect(mulesBanyak.title, contains('4x'));
    });

    test('Bristol 1-2 terus 3 hari → warning konstipasi', () {
      final poopLogs = [
        for (var d = 20; d <= 22; d++) poop(DateTime(2026, 11, d, 8), bristol: 2),
      ];
      final insights = AbnormalDetector(inputWith(poopLogs: poopLogs)).detect();
      expect(
        insights.any(
          (i) =>
              i.id.startsWith('abnormal:konstipasi') &&
              i.level == InsightLevel.warning,
        ),
        isTrue,
      );
    });

    test('TANPA Bristol: konstipasi/diare di-skip, frekuensi tetap jalan', () {
      // 3 eek tanpa Bristol dalam 7 hari terakhir + terakhir eek Nov 22.
      final poopLogs = [
        for (var d = 20; d <= 22; d++) poop(DateTime(2026, 11, d, 8)),
      ];
      final insights = AbnormalDetector(inputWith(poopLogs: poopLogs)).detect();
      // Skip aturan Bristol.
      expect(
        insights.where(
          (i) =>
              i.id.startsWith('abnormal:konstipasi') ||
              i.id.startsWith('abnormal:diare-berulang'),
        ),
        isEmpty,
      );
      // Frekuensi (tidak eek >=3 hari) tetap kepakai.
      expect(
        insights.any((i) => i.id.startsWith('abnormal:nggak-eek')),
        isTrue,
      );
      // Dan dia jujur soal Bristol kosong.
      expect(
        insights.any((i) => i.id.startsWith('abnormal:bristol-kosong')),
        isTrue,
      );
    });

    test('pola normal → info hijau', () {
      final poopLogs = [
        for (var d = 23; d <= 25; d++)
          poop(DateTime(2026, 11, d, 8), bristol: 4),
      ];
      final insights = AbnormalDetector(inputWith(poopLogs: poopLogs)).detect();
      expect(
        insights.any(
          (i) =>
              i.id.startsWith('abnormal:normal') &&
              i.level == InsightLevel.info,
        ),
        isTrue,
      );
    });
  });

  group('EatingPatternDetector (spec §5.5D)', () {
    /// Jadwal normal: 3x makan sehari (08:00, 12:30, 19:00).
    List<FoodLog> normalDays(int count, {DateTime? until}) {
      final end = until ?? DateTime(2026, 11, 25);
      final logs = <FoodLog>[];
      for (var i = 0; i < count; i++) {
        final day = DateTime(end.year, end.month, end.day - i);
        logs.add(food(DateTime(day.year, day.month, day.day, 8), 'Sarapan'));
        logs.add(food(DateTime(day.year, day.month, day.day, 12, 30), 'Makan siang'));
        logs.add(food(DateTime(day.year, day.month, day.day, 19), 'Makan malam'));
      }
      return logs;
    }

    test('data makan <3 hari → pesan "catat 3 hari dulu"', () {
      final insights = EatingPatternDetector(
        inputWith(
          foodLogs: [
            food(DateTime(2026, 11, 24, 8), 'A'),
            food(DateTime(2026, 11, 25, 8), 'B'),
          ],
        ),
      ).detect();
      expect(insights, hasLength(1));
      expect(insights.single.body, contains('Catat makan 3 hari dulu'));
    });

    test('makan 1x/hari 2 hari berturut → warning', () {
      final insights = EatingPatternDetector(
        inputWith(
          foodLogs: [
            food(DateTime(2026, 11, 24, 19), 'Nasi telur'),
            food(DateTime(2026, 11, 25, 19), 'Mie rebus'),
            // Hari-hari sebelumnya normal, biar >=3 hari data.
            ...normalDays(3, until: DateTime(2026, 11, 23)),
          ],
        ),
      ).detect();
      final kurang = insights.firstWhere(
        (i) => i.id.startsWith('makan:terlalu-sedikit'),
      );
      expect(kurang.level, InsightLevel.warning);
      expect(kurang.body, contains('lupa catat'));
    });

    test('Mode Puasa ON: warning skip-makan & gap panjang mati', () {
      final logs = [
        food(DateTime(2026, 11, 24, 19), 'Nasi telur'),
        food(DateTime(2026, 11, 25, 19), 'Mie rebus'),
        ...normalDays(3, until: DateTime(2026, 11, 23)),
      ];
      final normal = EatingPatternDetector(
        inputWith(foodLogs: logs),
      ).detect();
      final fasting = EatingPatternDetector(
        inputWith(foodLogs: logs, fasting: true),
      ).detect();

      expect(
        normal.any((i) => i.id.startsWith('makan:terlalu-sedikit')),
        isTrue,
      );
      expect(
        fasting.where(
          (i) =>
              i.id.startsWith('makan:terlalu-sedikit') ||
              i.id.startsWith('makan:gap-panjang') ||
              i.id.startsWith('makan:belum-makan'),
        ),
        isEmpty,
      );
      // Rule lain tetap ada (misal normal pattern atau kopi dll).
      expect(fasting.any((i) => i.id.startsWith('makan:')), isTrue);
    });

    test('kopi 4x sehari → warning', () {
      final insights = EatingPatternDetector(
        inputWith(
          foodLogs: [
            ...normalDays(3),
            for (var i = 0; i < 4; i++)
              food(
                DateTime(2026, 11, 25, 13 + i),
                'Kopi susu $i',
                categories: const [FoodCategories.kopi],
              ),
          ],
        ),
      ).detect();
      expect(
        insights.any((i) => i.id.startsWith('makan:kopi-banyak')),
        isTrue,
      );
    });

    test('makan berat jam 23:30 3x seminggu → warning', () {
      final insights = EatingPatternDetector(
        inputWith(
          foodLogs: [
            ...normalDays(4),
            food(DateTime(2026, 11, 23, 23, 30), 'Nasi goreng besar',
                portion: FoodPortion.besar),
            food(DateTime(2026, 11, 24, 23, 30), 'Mie goreng besar',
                portion: FoodPortion.besar),
            food(DateTime(2026, 11, 22, 23, 45), 'Martabak',
                portion: FoodPortion.besar),
          ],
        ),
      ).detect();
      final larut = insights.firstWhere(
        (i) => i.id.startsWith('makan:larut-malam'),
      );
      expect(larut.level, InsightLevel.warning);
      expect(larut.body, contains('jam 11'));
    });

    test('makan 6x sehari → warning ngemil', () {
      final insights = EatingPatternDetector(
        inputWith(
          foodLogs: [
            ...normalDays(3, until: DateTime(2026, 11, 22)),
            for (var i = 0; i < 6; i++)
              food(DateTime(2026, 11, 23, 8 + i * 2), 'Snack $i',
                  portion: FoodPortion.kecil),
            for (var i = 0; i < 6; i++)
              food(DateTime(2026, 11, 24, 8 + i * 2), 'Snack $i',
                  portion: FoodPortion.kecil),
          ],
        ),
      ).detect();
      expect(
        insights.any((i) => i.id.startsWith('makan:terlalu-banyak')),
        isTrue,
      );
    });

    test('junk food >70% → warning variasi', () {
      final foodLogs = <FoodLog>[
        for (var d = 23; d <= 25; d++) ...[
          for (var i = 0; i < 5; i++)
            food(
              DateTime(2026, 11, d, 10 + i * 2),
              'Gorengan $d-$i',
              categories: const [FoodCategories.gorengan],
              portion: FoodPortion.kecil,
            ),
          food(DateTime(2026, 11, d, 8), 'Nasi uduk $d'),
        ],
      ];
      final insights = EatingPatternDetector(
        inputWith(foodLogs: foodLogs),
      ).detect();
      final junk = insights.firstWhere(
        (i) => i.id.startsWith('makan:junk-food'),
      );
      expect(junk.level, InsightLevel.warning);
      expect(junk.body, contains('83%'));
    });

    test('pola teratur → info hijau "teratur"', () {
      final insights = EatingPatternDetector(
        inputWith(foodLogs: normalDays(5)),
      ).detect();
      expect(
        insights.any(
          (i) =>
              i.id.startsWith('makan:normal') &&
              i.level == InsightLevel.info,
        ),
        isTrue,
      );
    });

    test('tidak ada diagnosis penyakit di semua teks', () {
      final insights = EatingPatternDetector(
        inputWith(
          foodLogs: [
            ...normalDays(5),
            for (var i = 0; i < 6; i++)
              food(DateTime(2026, 11, 25, 8 + i), 'Snack $i',
                  portion: FoodPortion.kecil),
          ],
        ),
      ).detect();
      for (final insight in insights) {
        expect(insight.body.toLowerCase(), isNot(contains('kamu kena')));
        expect(insight.body.toLowerCase(), isNot(contains('diagnosis')));
      }
    });
  });

  group('WeeklySummary (spec §5.5C)', () {
    test('hitung total, rata-rata, distribusi Bristol, top food', () {
      final input = inputWith(
        foodLogs: [
          food(DateTime(2026, 11, 24, 8), 'Bubur'),
          food(DateTime(2026, 11, 24, 19), 'Seblak',
              categories: const [FoodCategories.pedas], spicy: 5),
          food(DateTime(2026, 11, 25, 8), 'Bubur'),
        ],
        poopLogs: [
          poop(DateTime(2026, 11, 24, 9), bristol: 4),
          poop(DateTime(2026, 11, 25, 9), bristol: 6),
        ],
      );
      final summary = buildWeeklySummary(input);
      expect(summary.totalFood, 3);
      expect(summary.totalPoop, 2);
      expect(summary.bristolDistribution, {4: 1, 6: 1});
      expect(summary.topFoods.first.name, 'Bubur');
      expect(summary.topFoods.first.count, 2);
      expect(summary.avgFirstMealTime, '08:00');
    });

    test('Bristol kosong: distribusi kosong + teks jujur', () {
      final input = inputWith(
        foodLogs: [food(DateTime(2026, 11, 25, 8), 'Bubur')],
        poopLogs: [poop(DateTime(2026, 11, 25, 9))],
      );
      final summary = buildWeeklySummary(input);
      expect(summary.bristolDistribution, isEmpty);

      final insight = weeklySummaryInsight(input);
      expect(insight.body, contains('Bristol belum pernah diisi'));
      expect(insight.type, InsightType.weeklySummary);
    });

    test('tanggal konsisten & evidence ngisi semua log periode', () {
      final input = inputWith(
        foodLogs: [food(DateTime(2026, 11, 25, 8), 'Bubur')],
        poopLogs: [poop(DateTime(2026, 11, 25, 9), bristol: 4)],
      );
      final insight = weeklySummaryInsight(input);
      expect(insight.id, 'weekly-summary:7:2026-11-25');
      expect(insight.evidenceLogIds, hasLength(2));
    });
  });

  group('MuyesAnalyzer orchestrator', () {
    test('data kosong tidak crash & kasih catatan jujur', () {
      final analysis = MuyesAnalyzer(
        MuyesAiInput(food: [], poop: [], mules: [], now: testNow),
      ).analyze();
      expect(analysis.dataNote, contains('Data masih sedikit'));
      expect(analysis.insights, isNotEmpty); // weekly summary + ajakan
    });

    test('data lengkap: pola makan & pola eek terpisah', () {
      final input = inputWith(
        foodLogs: [
          for (var d = 19; d <= 25; d++)
            for (var meal = 0; meal < 3; meal++)
              food(
                DateTime(2026, 11, d, 8 + meal * 5),
                'Makan $d-$meal',
                categories: const [FoodCategories.nasi],
              ),
        ],
        poopLogs: [
          for (var d = 20; d <= 25; d++)
            poop(DateTime(2026, 11, d, 19), bristol: 4),
        ],
      );
      final analysis = MuyesAnalyzer(input).analyze();
      expect(analysis.patternInsights, isNotEmpty);
      expect(analysis.poopInsights, isNotEmpty);
      expect(
        analysis.patternInsights.every(
          (i) => i.type == InsightType.eatingPattern,
        ),
        isTrue,
      );
    });

    test('korelasi 30 hari punya sampel >= korelasi 7 hari', () {
      final foodLogs = <FoodLog>[
        for (var d = 1; d <= 25; d += 4)
          food(
            DateTime(2026, 11, 1 + d, 12),
            'Seblak pedas',
            categories: const [FoodCategories.pedas],
            spicy: 5,
          ),
      ];
      final poopLogs = <PoopLog>[
        for (var d = 1; d <= 25; d += 4)
          poop(DateTime(2026, 11, 1 + d, 19), bristol: 6, pain: 4),
      ];
      final input = inputWith(foodLogs: foodLogs, poopLogs: poopLogs);
      final hits7 = findCorrelations(input, days: 7);
      final hits30 = findCorrelations(input, days: 30);
      // 30 hari cakup lebih banyak sampel dari 7 hari.
      expect(
        (hits30.isEmpty ? 0 : hits30.first.hitCount) >=
            (hits7.isEmpty ? 0 : hits7.first.hitCount),
        isTrue,
      );
    });
  });

  group('Status Hari Ini (buat Home, spec §5.3)', () {
    test('hari kosong → perut aman, belum ada catatan makan', () {
      final input = inputWith();
      expect(stomachStatusForToday(input).level, InsightLevel.info);
      expect(stomachStatusForToday(input).title, 'Perut aman');
      expect(eatingStatusForToday(input).title, 'Belum ada catatan makan');
    });

    test('mules 2x → waspada kuning', () {
      final input = inputWith(
        mulesLogs: [
          mules(DateTime(2026, 11, 25, 10), 3),
          mules(DateTime(2026, 11, 25, 15), 4),
        ],
      );
      final status = stomachStatusForToday(input);
      expect(status.level, InsightLevel.warning);
      expect(status.title, contains('2x'));
    });

    test('darah hari ini → alert merah', () {
      final input = inputWith(
        poopLogs: [poop(DateTime(2026, 11, 25, 10), bristol: 4, blood: true)],
      );
      expect(stomachStatusForToday(input).level, InsightLevel.alert);
    });

    test('terakhir makan 10 jam lalu → status kuning "Belum makan"', () {
      final input = inputWith(
        foodLogs: [food(DateTime(2026, 11, 25, 10), 'Sarapan')],
      );
      final status = eatingStatusForToday(input);
      expect(status.level, InsightLevel.warning);
      expect(status.title, contains('Belum makan 10 jam'));
    });

    test('sudah makan 2x → status hijau', () {
      final input = inputWith(
        foodLogs: [
          food(DateTime(2026, 11, 25, 8), 'Sarapan'),
          food(DateTime(2026, 11, 25, 13), 'Makan siang'),
        ],
      );
      final status = eatingStatusForToday(input);
      expect(status.level, InsightLevel.info);
      expect(status.title, 'Baru makan 2x hari ini');
    });
  });
}
