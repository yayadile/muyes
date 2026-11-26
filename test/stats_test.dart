import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/ai/ai_types.dart';
import 'package:muyes/models/food_log.dart';
import 'package:muyes/models/mules_log.dart';
import 'package:muyes/models/poop_log.dart';
import 'package:muyes/screens/home_screen.dart';
import 'package:muyes/screens/stats_screen.dart';
import 'package:muyes/utils/stats_calculator.dart';

import 'test_helpers.dart';

void main() {
  // "Sekarang" tetap: Rabu 25 Nov 2026, 20:00.
  final now = DateTime(2026, 11, 25, 20);

  MuyesAiInput inputWith({
    List<FoodLog> food = const [],
    List<PoopLog> poop = const [],
    List<MulesLog> mules = const [],
  }) => MuyesAiInput(food: food, poop: poop, mules: mules, now: now);

  group('buildStats (halaman Statistik)', () {
    test('hitung total, per hari, dan rata-rata (pembagi hari tercatat)', () {
      final stats = buildStats(
        inputWith(
          food: [
            makeFood(id: 'f1', eatenAt: DateTime(2026, 11, 25, 8)),
            makeFood(id: 'f2', eatenAt: DateTime(2026, 11, 25, 12)),
            makeFood(id: 'f3', eatenAt: DateTime(2026, 11, 24, 8)),
          ],
          poop: [
            makePoop(id: 'p1', poopedAt: DateTime(2026, 11, 25, 9), bristol: 4),
            makePoop(id: 'p2', poopedAt: DateTime(2026, 11, 24, 9)),
          ],
          mules: [makeMules(id: 'm1', feltAt: DateTime(2026, 11, 24, 15))],
        ),
        days: 7,
      );

      expect(stats.totalFood, 3);
      expect(stats.totalPoop, 2);
      expect(stats.totalMules, 1);
      expect(stats.totalLogs, 6);
      expect(stats.daysWithData, 2);

      // perDay lengkap 7 hari, urut lama → baru, hari terakhir = hari ini.
      expect(stats.perDay, hasLength(7));
      expect(stats.perDay.last.total, 3); // 2 makan + 1 eek (25 Nov)
      expect(stats.perDay[5].total, 3); // 1 makan + 1 eek + 1 mules (24 Nov)

      // Rata-rata dibagi hari TERCATAT (2), bukan 7.
      expect(stats.avgFoodPerDay, 1.5);
      expect(stats.avgPoopPerDay, 1.0);
      expect(stats.coveredDays, 2);
    });

    test('Bristol cuma yang keisi yang dihitung (null bukan 0)', () {
      final stats = buildStats(
        inputWith(
          poop: [
            makePoop(id: 'p1', poopedAt: DateTime(2026, 11, 25, 9), bristol: 6),
            makePoop(id: 'p2', poopedAt: DateTime(2026, 11, 24, 9)),
            makePoop(id: 'p3', poopedAt: DateTime(2026, 11, 23, 9), bristol: 6),
          ],
        ),
        days: 7,
      );

      expect(stats.bristolDistribution, {6: 2});
      expect(stats.bristolFilled, 2);
      expect(stats.totalPoop, 3);
    });

    test('rentang 30 hari & top makanan maks 5 urut terbanyak', () {
      final food = <FoodLog>[
        for (var i = 0; i < 6; i++)
          makeFood(
            id: 'a$i',
            eatenAt: DateTime(2026, 11, 25 - i, 8),
            foodName: 'Seblak',
          ),
        for (var i = 0; i < 3; i++)
          makeFood(
            id: 'b$i',
            eatenAt: DateTime(2026, 11, 25 - i, 12),
            foodName: 'Nasi ayam',
          ),
        for (var i = 0; i < 2; i++)
          makeFood(
            id: 'c$i',
            eatenAt: DateTime(2026, 11, 25 - i, 18),
            foodName: 'Indomie',
          ),
        for (var i = 0; i < 2; i++)
          makeFood(
            id: 'd$i',
            eatenAt: DateTime(2026, 11, 25 - i, 20),
            foodName: 'Kopi',
          ),
        for (var i = 0; i < 2; i++)
          makeFood(
            id: 'e$i',
            eatenAt: DateTime(2026, 11, 25 - i, 21),
            foodName: 'Tahu',
          ),
        for (var i = 0; i < 2; i++)
          makeFood(
            id: 'f$i',
            eatenAt: DateTime(2026, 11, 25 - i, 22),
            foodName: 'Tempe',
          ),
      ];

      final stats = buildStats(inputWith(food: food), days: 30);
      expect(stats.topFoods, hasLength(5));
      expect(stats.topFoods.first.name, 'Seblak');
      expect(stats.topFoods.first.count, 6);
      expect(stats.topFoods.every((f) => f.name != 'Tempe'), isTrue);
    });

    test('data kosong: aman, nggak ada pembagian nol', () {
      final stats = buildStats(inputWith(), days: 7);
      expect(stats.totalLogs, 0);
      expect(stats.coveredDays, 1);
      expect(stats.avgFoodPerDay, 0);
      expect(stats.bristolDistribution, isEmpty);
      expect(stats.topFoods, isEmpty);
    });
  });

  group('HomeScreen — baris Terakhir (lookback, koreksi 26 Nov 2026)', () {
    testWidgets('lihat hari SEBELUM semua log → baris Terakhir "-" semua', (
      tester,
    ) async {
      useTallWindow(tester);
      final lastEat = DateTime(2026, 11, 20, 8, 30);

      // Lihat 5 Nov: belum ada log sampai 5 Nov → "-" semua.
      await tester.pumpWidget(
        wrapScreenWithData(
          const HomeScreen(),
          food: [makeFood(id: 'f1', eatenAt: lastEat)],
          selectedDay: DateTime(2026, 11, 5),
        ),
      );
      await settle(tester);

      expect(find.text('0'), findsNWidgets(3)); // count hari itu tetap 0
      expect(find.text('-'), findsNWidgets(3));
    });

    testWidgets('pindah ke hari kosong SETELAH log → baris Terakhir nunjuk '
        'catatan terakhir sampai tanggal itu', (tester) async {
      useTallWindow(tester);
      final lastEat = DateTime(2026, 11, 20, 8, 30);

      // Lihat 24 Nov (kosong): baris Terakhir "mundur" ke 20 Nov.
      await tester.pumpWidget(
        wrapScreenWithData(
          const HomeScreen(),
          food: [makeFood(id: 'f1', eatenAt: lastEat)],
          selectedDay: DateTime(2026, 11, 24),
        ),
      );
      await settle(tester);

      expect(find.text('0'), findsNWidgets(3)); // count hari itu tetap 0
      expect(find.textContaining('08:30'), findsOneWidget); // lookback ke 20 Nov
      expect(find.text('-'), findsNWidgets(2)); // eek + mules belum ada
    });

    testWidgets('lihat hari dengan log → waktu log terakhir hari itu', (
      tester,
    ) async {
      useTallWindow(tester);
      final eatenAt = DateTime(2026, 11, 25, 19, 56);

      await tester.pumpWidget(
        wrapScreenWithData(
          const HomeScreen(),
          food: [makeFood(id: 'f1', eatenAt: eatenAt)],
          now: now,
          selectedDay: DateTime(2026, 11, 25),
        ),
      );
      await settle(tester);

      expect(find.text('Terakhir Makan'), findsOneWidget);
      // Baris Terakhir menampilkan waktu log terakhir (19:56) — bentuk
      // "Hari ini/Kemarin/tanggal" tergantung jam device saat test jalan,
      // jadi cek yang relevan: ada baris yang berakhir "19:56".
      expect(find.textContaining(RegExp(r'19:56$')), findsOneWidget);
    });
  });

  group('StatsScreen (spec §8.1)', () {
    testWidgets('rentang 7/30, ringkasan, diagram, dan top makanan', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrapScreenWithData(
          const StatsScreen(),
          now: now,
          food: [
            makeFood(id: 'f1', eatenAt: DateTime(2026, 11, 25, 8)),
            makeFood(id: 'f2', eatenAt: DateTime(2026, 11, 25, 12)),
            makeFood(id: 'f3', eatenAt: DateTime(2026, 11, 24, 8)),
          ],
          poop: [
            makePoop(id: 'p1', poopedAt: DateTime(2026, 11, 25, 9), bristol: 4),
            makePoop(id: 'p2', poopedAt: DateTime(2026, 11, 24, 9), bristol: 6),
          ],
          mules: [makeMules(id: 'm1', feltAt: DateTime(2026, 11, 25, 15))],
        ),
      );
      await settle(tester);

      expect(find.text('Statistik'), findsOneWidget);
      expect(find.text('7 hari'), findsOneWidget);
      expect(find.text('30 hari'), findsOneWidget);
      expect(find.text('Proporsi Catatan'), findsOneWidget);
      expect(find.text('Catatan per Hari'), findsOneWidget);
      expect(find.text('Bentuk Eek (Bristol)'), findsOneWidget);
      expect(find.text('Makanan Paling Sering'), findsOneWidget);

      // Angka ringkasan: 3 makan + 2 eek + 1 mules = 6 catatan.
      expect(find.textContaining('6 catatan'), findsOneWidget);
      expect(find.textContaining('2 dari 7 hari'), findsOneWidget);

      // Label "Makan"/"Eek"/"Mules" muncul 2x: ringkasan + legend donut.
      expect(find.text('Makan'), findsNWidgets(2));
      expect(find.text('Eek'), findsNWidgets(2));
      expect(find.text('Mules'), findsNWidgets(2));
    });

    testWidgets('pindah rentang ke 30 hari → tetap stabil', (tester) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrapScreenWithData(
          const StatsScreen(),
          now: now,
          food: [makeFood(id: 'f1', eatenAt: DateTime(2026, 11, 25, 8))],
        ),
      );
      await settle(tester);

      await tester.tap(find.text('30 hari'));
      await tester.pump();

      expect(find.text('Catatan per Hari'), findsOneWidget);
      expect(find.textContaining('30 hari terakhir'), findsWidgets);
    });

    testWidgets('data kosong → kartu ajakan catat, bukan diagram kosong', (
      tester,
    ) async {
      useTallWindow(tester);
      await tester.pumpWidget(
        wrapScreenWithData(const StatsScreen(), now: now),
      );
      await settle(tester);

      expect(find.text('Belum ada data buat diagram.'), findsOneWidget);
      expect(find.textContaining('Pengaturan'), findsOneWidget);
      expect(find.text('Proporsi Catatan'), findsNothing);
    });
  });
}
