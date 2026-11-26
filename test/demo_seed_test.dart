import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/ai/ai_types.dart';
import 'package:muyes/ai/analyzer.dart';
import 'package:muyes/ai/weekly_summary.dart';
import 'package:muyes/data/database.dart';
import 'package:muyes/data/demo_seed.dart';
import 'package:muyes/models/food_log.dart';
import 'package:muyes/models/insight.dart';

/// Waktu tetap buat seed — "hari ini" = Rabu 25 Nov 2026, 20:00.
final seedNow = DateTime(2026, 11, 25, 20);

void main() {
  group('buildDemoSeed (spec §10)', () {
    final bundle = buildDemoSeed(now: seedNow);

    test('jumlah log & prefix demo- & urut waktu & tanpa log masa depan', () {
      expect(bundle.food, hasLength(41));
      expect(bundle.poop, hasLength(22));
      expect(bundle.mules, hasLength(6));

      for (final log in bundle.food) {
        expect(DemoSeed.isDemoId(log.id), isTrue);
        expect(log.eatenAt.isAfter(seedNow), isFalse);
      }
      for (final log in bundle.poop) {
        expect(DemoSeed.isDemoId(log.id), isTrue);
        expect(log.poopedAt.isAfter(seedNow), isFalse);
      }
      for (final log in bundle.mules) {
        expect(DemoSeed.isDemoId(log.id), isTrue);
        expect(log.feltAt.isAfter(seedNow), isFalse);
      }

      // Urut waktu naik — kontrak MuyesAiInput.
      for (var i = 1; i < bundle.food.length; i++) {
        expect(
          bundle.food[i].eatenAt.isBefore(bundle.food[i - 1].eatenAt),
          isFalse,
        );
      }
      for (var i = 1; i < bundle.poop.length; i++) {
        expect(
          bundle.poop[i].poopedAt.isBefore(bundle.poop[i - 1].poopedAt),
          isFalse,
        );
      }
    });

    MuyesAiInput inputOf(DemoSeedBundle b) => MuyesAiInput(
      food: b.food,
      poop: b.poop,
      mules: b.mules,
      now: seedNow,
    );

    test('korelasi pedas benar: "3 dari 4" dalam 7 hari (spec §9)', () {
      final analysis = MuyesAnalyzer(
        inputOf(bundle),
      ).analyze(days: 7, thirtyDays: true);

      final pedas = analysis.poopInsights.firstWhere(
        (i) => i.title == 'Kemungkinan pemicu: Pedas' && i.periodDays == 7,
      );
      expect(pedas.body, contains('3 dari 4'));
      expect(pedas.level, InsightLevel.warning);
      expect(pedas.evidenceLogIds, isNotEmpty);

      // Versi 30 hari juga ada (6 dari 15) — bukti 30-day analysis jalan.
      final pedas30 = analysis.poopInsights.firstWhere(
        (i) => i.title == 'Kemungkinan pemicu: Pedas' && i.periodDays == 30,
      );
      expect(pedas30.body, contains('6 dari 15'));
    });

    test('alert merah: darah + diare berulang (spec §9)', () {
      final analysis = MuyesAnalyzer(
        inputOf(bundle),
      ).analyze(days: 7, thirtyDays: true);

      final darah = analysis.poopInsights.firstWhere(
        (i) => i.title == 'Ada darah di eek',
      );
      expect(darah.level, InsightLevel.alert);
      expect(darah.body, contains('konsultasi ke dokter'));

      final diare = analysis.poopInsights.firstWhere(
        (i) => i.title == 'Diare berulang 2 hari',
      );
      expect(diare.level, InsightLevel.alert);
    });

    test('warning kuning dari eating pattern detector (spec §9)', () {
      final analysis = MuyesAnalyzer(
        inputOf(bundle),
      ).analyze(days: 7, thirtyDays: true);

      final titles = analysis.patternInsights.map((i) => i.title).toSet();
      expect(titles, contains('Makan cuma 1x sehari 2 hari'));
      expect(titles, contains('Ngemil terus 2 hari'));
      expect(titles, contains('3x makan berat larut malam'));
      expect(titles, contains('Kopi 4x hari ini'));
      expect(titles, contains('Jam makan lompat-lompat'));

      expect(
        analysis.patternInsights.every((i) => i.level != InsightLevel.alert),
        isTrue,
      );
      expect(analysis.dataNote, isNull);
    });

    test('warning konstipasi: belum eek 3 hari (spec §9/§10)', () {
      final analysis = MuyesAnalyzer(
        inputOf(bundle),
      ).analyze(days: 7, thirtyDays: true);

      final none = analysis.poopInsights.firstWhere(
        (i) => i.title == 'Belum eek 3 hari',
      );
      expect(none.level, InsightLevel.warning);
    });

    test('dedup mules <30 menit: mules + eek jadi 1 kejadian, bukan 2', () {
      // 6 mules + 14 kejadian eek = 20 raw event; 5 pasang (mules 19:00 +
      // eek 19:25, hari 1/3/6/8/10) di-merge → 15 episode.
      final episodes = mergeMulesEpisodes(bundle.mules, bundle.poop);
      expect(episodes, hasLength(15));

      final day1 = episodes.firstWhere(
        (e) => e.time == DateTime(2026, 11, 13, 19),
      );
      expect(day1.level, 4);
      expect(day1.hasDiarrhea, isTrue);
      expect(day1.sourceLogIds, hasLength(2));
    });

    test('Mode Puasa mematikan warning skip-makan, warning lain tetap', () {
      final fastingInput = MuyesAiInput(
        food: bundle.food,
        poop: bundle.poop,
        mules: bundle.mules,
        now: seedNow,
        fastingMode: true,
      );
      final analysis = MuyesAnalyzer(
        fastingInput,
      ).analyze(days: 7, thirtyDays: true);

      final titles = analysis.patternInsights.map((i) => i.title).toSet();
      expect(titles, isNot(contains('Makan cuma 1x sehari 2 hari')));
      expect(titles, contains('Ngemil terus 2 hari'));
      expect(titles, contains('3x makan berat larut malam'));
      expect(titles, contains('Kopi 4x hari ini'));
    });

    test('ringkasan mingguan: 1 kalimat utama + distribusi Bristol terisi',
        () {
      final input = inputOf(bundle);
      final summary = buildWeeklySummary(input);
      expect(summary.totalFood, greaterThan(20));
      expect(summary.totalPoop, greaterThan(3));
      expect(summary.bristolDistribution, isNotEmpty);

      final line = mainInsightLine(input, summary, days: 7);
      expect(line, isNotNull);
      expect(line, contains('ada darah'));
    });
  });

  group('applyDemoSeed / removeDemoData', () {
    test('pasang → baris masuk DB + setting demoSeeded nyala', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await applyDemoSeed(db, buildDemoSeed(now: seedNow));

      final counts = await db.tableCounts();
      expect(counts['food'], 41);
      expect(counts['poop'], 22);
      expect(counts['mules'], 6);
      expect(await db.getBoolSetting(SettingKeys.demoSeeded), isTrue);
    });

    test('pasang 2x tidak menumpuk (id deterministik)', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await applyDemoSeed(db, buildDemoSeed(now: seedNow));
      await applyDemoSeed(db, buildDemoSeed(now: seedNow));

      final counts = await db.tableCounts();
      expect(counts['food'], 41);
      expect(counts['poop'], 22);
      expect(counts['mules'], 6);
    });

    test('hapus cuma menyentuh baris demo-, data asli aman', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      // 1 log asli user (tanpa prefix demo-).
      final real = FoodLog(
        id: 'asli-1',
        eatenAt: DateTime(2026, 11, 24, 12),
        foodName: 'Nasi padang',
        categories: const [FoodCategories.nasi],
        spicyLevel: 0,
        portion: FoodPortion.sedang,
        createdAt: DateTime(2026, 11, 24, 12),
        updatedAt: DateTime(2026, 11, 24, 12),
      );
      await FoodLogDao(db).upsert(real);

      await applyDemoSeed(db, buildDemoSeed(now: seedNow));
      await removeDemoData(db);

      final counts = await db.tableCounts();
      expect(counts['food'], 1);
      expect(counts['poop'], 0);
      expect(counts['mules'], 0);
      expect(await db.getBoolSetting(SettingKeys.demoSeeded), isFalse);
      expect((await FoodLogDao(db).getById('asli-1'))?.foodName, 'Nasi padang');
    });
  });
}
