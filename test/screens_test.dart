import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/models/food_log.dart';
import 'package:muyes/models/poop_log.dart';
import 'package:muyes/models/timeline_entry.dart';
import 'package:muyes/screens/calendar_screen.dart';
import 'package:muyes/screens/history_screen.dart';
import 'package:muyes/screens/home_screen.dart';
import 'package:muyes/screens/insights_screen.dart';
import 'package:muyes/utils/date_utils.dart';
import 'package:muyes/utils/day_summary.dart';

import 'test_helpers.dart';

void main() {
  group('computeDayStatus (dot kalender)', () {
    test('hari kosong = null (nggak ada dot)', () {
      expect(computeDayStatus(const []), isNull);
    });

    test('normal: Bristol 4 + mules 1x', () {
      final t = DateTime(2026, 11, 25);
      final entries = [
        TimelineEntry.poop(makePoop(id: 'p', poopedAt: t, bristol: 4)),
        TimelineEntry.mules(makeMules(id: 'm', feltAt: t, painLevel: 1)),
      ];
      expect(computeDayStatus(entries), DayStatus.normal);
    });

    test('abnormal: ada darah', () {
      final t = DateTime(2026, 11, 25);
      expect(
        computeDayStatus([
          TimelineEntry.poop(
            makePoop(id: 'p', poopedAt: t, bristol: 4, hasBlood: true),
          ),
        ]),
        DayStatus.abnormal,
      );
    });

    test('abnormal: warna hitam / merah', () {
      final t = DateTime(2026, 11, 25);
      expect(
        computeDayStatus([
          TimelineEntry.poop(
            makePoop(id: 'p', poopedAt: t, color: PoopColors.hitam),
          ),
        ]),
        DayStatus.abnormal,
      );
      expect(
        computeDayStatus([
          TimelineEntry.poop(
            makePoop(id: 'p', poopedAt: t, color: PoopColors.merah),
          ),
        ]),
        DayStatus.abnormal,
      );
    });

    test('abnormal: diare >=3x sehari', () {
      final t = DateTime(2026, 11, 25);
      expect(
        computeDayStatus([
          for (var i = 0; i < 3; i++)
            TimelineEntry.poop(
              makePoop(
                id: 'p$i',
                poopedAt: t.add(Duration(hours: i)),
                bristol: 7,
              ),
            ),
        ]),
        DayStatus.abnormal,
      );
    });

    test('waspada: diare 1x', () {
      final t = DateTime(2026, 11, 25);
      expect(
        computeDayStatus([
          TimelineEntry.poop(makePoop(id: 'p', poopedAt: t, bristol: 6)),
        ]),
        DayStatus.waspada,
      );
    });

    test('waspada: mules >=4x', () {
      final t = DateTime(2026, 11, 25);
      expect(
        computeDayStatus([
          for (var i = 0; i < 4; i++)
            TimelineEntry.mules(
              makeMules(id: 'm$i', feltAt: t.add(Duration(hours: i))),
            ),
        ]),
        DayStatus.waspada,
      );
    });

    test('Bristol kosong tidak dikarang jadi medis', () {
      final t = DateTime(2026, 11, 25);
      expect(
        computeDayStatus([
          TimelineEntry.poop(makePoop(id: 'p', poopedAt: t)),
        ]),
        DayStatus.normal,
      );
    });
  });

  group('HomeScreen', () {
    testWidgets('ringkasan: jumlah, 3 tombol, timeline gabungan', (
      tester,
    ) async {
      useTallWindow(tester);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await tester.pumpWidget(
        wrapScreenWithData(
          const HomeScreen(),
          food: [
            makeFood(id: 'f1', eatenAt: today.add(const Duration(hours: 8))),
            makeFood(id: 'f2', eatenAt: today.add(const Duration(hours: 12))),
          ],
          poop: [
            makePoop(
              id: 'p1',
              poopedAt: today.add(const Duration(hours: 9)),
              bristol: 4,
            ),
          ],
          mules: [
            makeMules(id: 'm1', feltAt: today.add(const Duration(hours: 13))),
          ],
        ),
      );
      await settle(tester);

      // Header ala mock §8.1 (versi Indonesia): "Hari Ini" + tanggal lengkap.
      expect(find.text('Hari Ini'), findsOneWidget);

      // 3 tombol besar (urutan: Eek, Makan, Mules).
      expect(find.text('+ Eek'), findsOneWidget);
      expect(find.text('+ Makan'), findsOneWidget);
      expect(find.text('+ Mules'), findsOneWidget);

      // Kartu stats: 3 ikon + count hari ini dari data.
      expect(find.text('Eek'), findsOneWidget);
      expect(find.text('Makan'), findsOneWidget);
      expect(find.text('Mules'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // 2x makan hari ini

      // Baris terakhir — waktu asli (bukan "Bla bla").
      expect(find.text('Terakhir Makan'), findsOneWidget);
      expect(find.text('Terakhir Eek'), findsOneWidget);
      expect(find.text('Terakhir Mules'), findsOneWidget);
      expect(find.text('Bla bla'), findsNothing);

      // Timeline berisi ketiga jenis log.
      expect(find.text('Mules Sedang'), findsOneWidget);
      expect(find.text('Eek · Bristol 4'), findsOneWidget);
      expect(find.text('Nasi goreng'), findsNWidgets(2));
    });

    testWidgets('hari kosong: count 0 dan Terakhir semua "-" (bukan data palsu)', (
      tester,
    ) async {
      useTallWindow(tester);
      await tester.pumpWidget(wrapScreenWithData(const HomeScreen()));
      await settle(tester);

      // Count semua 0.
      expect(find.text('0'), findsNWidgets(3));

      // Semua baris Terakhir menampilkan "-" (spec §8.1 — bukan "Bla bla").
      expect(find.text('-'), findsNWidgets(3));

      // Empty state timeline.
      expect(find.text('Belum ada catatan hari ini.'), findsOneWidget);
      expect(find.textContaining('Mulai dari'), findsOneWidget);
    });

    testWidgets('Terakhir Makan menampilkan waktu asli log terakhir', (
      tester,
    ) async {
      useTallWindow(tester);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eatenAt = today.add(const Duration(hours: 8, minutes: 5));

      await tester.pumpWidget(
        wrapScreenWithData(
          const HomeScreen(),
          food: [makeFood(id: 'f1', eatenAt: eatenAt)],
        ),
      );
      await settle(tester);

      // Hari ini → "Hari ini, HH:mm" (koreksi user: kata Hari ini/Kemarin).
      expect(find.text(formatLastTimeId(eatenAt)), findsOneWidget);
      expect(find.text('Hari ini, 08:05'), findsOneWidget);
    });
  });

  group('formatLastTimeId (baris Terakhir di Home)', () {
    final now = DateTime(2026, 11, 25, 20);

    test('hari ini → "Hari ini, HH:mm"', () {
      expect(
        formatLastTimeId(DateTime(2026, 11, 25, 19, 56), now: now),
        'Hari ini, 19:56',
      );
    });

    test('kemarin → "Kemarin, HH:mm"', () {
      expect(
        formatLastTimeId(DateTime(2026, 11, 24, 19, 56), now: now),
        'Kemarin, 19:56',
      );
    });

    test('lebih lama dari kemarin → tanggal lengkap', () {
      expect(
        formatLastTimeId(DateTime(2026, 11, 23, 19, 56), now: now),
        '23 Nov 2026, 19:56',
      );
      expect(
        formatLastTimeId(DateTime(2026, 11, 10, 8), now: now),
        '10 Nov 2026, 08:00',
      );
    });

    test('lewat tengah malam tetap benar (23:59 kemarin)', () {
      final justBeforeMidnight = DateTime(2026, 11, 24, 23, 59);
      expect(
        formatLastTimeId(justBeforeMidnight, now: DateTime(2026, 11, 25, 0, 5)),
        'Kemarin, 23:59',
      );
    });
  });

  group('HistoryScreen', () {
    List<TimelineEntry> historyFood() => [
      TimelineEntry.food(
        makeFood(
          id: 'f1',
          eatenAt: DateTime(2026, 11, 24, 12),
          foodName: 'Ayam geprek sambal',
        ),
      ),
      TimelineEntry.food(
        makeFood(
          id: 'f2',
          eatenAt: DateTime(2026, 11, 25, 8),
          foodName: 'Bubur ayam',
        ),
      ),
    ];

    testWidgets('menampilkan semua log', (tester) async {
      useTallWindow(tester);
      await tester.pumpWidget(
        wrapScreenWithData(
          const HistoryScreen(),
          food: [for (final e in historyFood()) e.food!],
          poop: [
            makePoop(id: 'p1', poopedAt: DateTime(2026, 11, 25, 9), bristol: 4),
          ],
        ),
      );
      await settle(tester);

      expect(find.text('Ayam geprek sambal'), findsOneWidget);
      expect(find.text('Bubur ayam'), findsOneWidget);
      expect(find.text('Eek · Bristol 4'), findsOneWidget);
    });

    testWidgets('filter Eek menyembunyikan makanan', (tester) async {
      useTallWindow(tester);
      await tester.pumpWidget(
        wrapScreenWithData(
          const HistoryScreen(),
          food: [makeFood(id: 'f1', eatenAt: DateTime(2026, 11, 25, 8))],
          poop: [
            makePoop(id: 'p1', poopedAt: DateTime(2026, 11, 25, 9), bristol: 4),
          ],
        ),
      );
      await settle(tester);

      await tester.tap(find.text('Eek'));
      await tester.pump();

      expect(find.text('Nasi goreng'), findsNothing);
      expect(find.text('Eek · Bristol 4'), findsOneWidget);
    });

    testWidgets('search "sambal" menyaring log', (tester) async {
      useTallWindow(tester);
      await tester.pumpWidget(
        wrapScreenWithData(
          const HistoryScreen(),
          food: [
            makeFood(
              id: 'f1',
              eatenAt: DateTime(2026, 11, 24, 12),
              foodName: 'Ayam geprek sambal',
            ),
            makeFood(
              id: 'f2',
              eatenAt: DateTime(2026, 11, 25, 8),
              foodName: 'Bubur ayam',
            ),
          ],
        ),
      );
      await settle(tester);

      await tester.enterText(find.byType(TextField).first, 'sambal');
      await tester.pump();

      expect(find.text('Ayam geprek sambal'), findsOneWidget);
      expect(find.text('Bubur ayam'), findsNothing);
    });

    testWidgets('search tanpa hasil menampilkan pesan kosong', (tester) async {
      useTallWindow(tester);
      await tester.pumpWidget(
        wrapScreenWithData(
          const HistoryScreen(),
          food: [
            makeFood(
              id: 'f1',
              eatenAt: DateTime(2026, 11, 24, 12),
              foodName: 'Ayam geprek',
            ),
          ],
        ),
      );
      await settle(tester);

      await tester.enterText(find.byType(TextField).first, 'martabak');
      await tester.pump();

      expect(
        find.text('Nggak ada log yang cocok dengan "martabak".'),
        findsOneWidget,
      );
    });
  });

  group('CalendarScreen', () {
    testWidgets('grid bulan ini + dot + legend', (tester) async {
      useTallWindow(tester);
      final now = DateTime.now();
      await tester.pumpWidget(
        wrapScreenWithData(
          const CalendarScreen(),
          poop: [
            makePoop(
              id: 'p1',
              poopedAt: DateTime(now.year, now.month, 10, 8),
              bristol: 4,
            ),
            makePoop(
              id: 'p2',
              poopedAt: DateTime(now.year, now.month, 11, 8),
              hasBlood: true,
            ),
          ],
        ),
      );
      await settle(tester);

      expect(
        find.text('${_monthName(now.month)} ${now.year}'),
        findsOneWidget,
      );
      expect(find.text('10'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Waspada'), findsOneWidget);
      expect(find.text('Abnormal'), findsOneWidget);
    });

    testWidgets('tap tanggal → detail hari', (tester) async {
      useTallWindow(tester);
      final now = DateTime.now();
      await tester.pumpWidget(
        wrapScreenWithData(
          const CalendarScreen(),
          food: [
            makeFood(
              id: 'f1',
              eatenAt: DateTime(now.year, now.month, 10, 12),
              foodName: 'Sate ayam',
            ),
          ],
        ),
      );
      await settle(tester);

      await tester.tap(find.text('10'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Sate ayam'), findsOneWidget);
      expect(find.text('Pola hari ini kelihatan normal'), findsOneWidget);
    });

    testWidgets('navigasi bulan sebelumnya / berikutnya', (tester) async {
      useTallWindow(tester);
      await tester.pumpWidget(wrapScreenWithData(const CalendarScreen()));
      await settle(tester);

      final now = DateTime.now();
      final thisMonth = '${_monthName(now.month)} ${now.year}';
      expect(find.text(thisMonth), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      final prev = DateTime(now.year, now.month - 1);
      expect(
        find.text('${_monthName(prev.month)} ${prev.year}'),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(find.text(thisMonth), findsOneWidget);
    });
  });

  group('InsightsScreen (spec §5.5)', () {
    /// Jendela ekstra tinggi — semua kartu Insights harus ke-render
    /// (ListView lazy, jadi viewport harus cukup besar).
    void useHugeWindow(WidgetTester tester) {
      tester.view.physicalSize = const Size(900, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    /// Pola spec §10: makan pedas 4-5, 6-8 jam kemudian mules + diare.
    final now = DateTime(2026, 11, 25, 20);

    List<FoodLog> spicySchedule() => [
      makeFood(
        id: 'f1',
        eatenAt: DateTime(2026, 11, 20, 12),
        foodName: 'Seblak pedas level 5',
        categories: const [FoodCategories.pedas],
        spicyLevel: 5,
      ),
      makeFood(
        id: 'f2',
        eatenAt: DateTime(2026, 11, 21, 12),
        foodName: 'Ayam geprek sambal',
        categories: const [FoodCategories.pedas],
        spicyLevel: 4,
      ),
      makeFood(
        id: 'f3',
        eatenAt: DateTime(2026, 11, 22, 12),
        foodName: 'Mie pedas level 5',
        categories: const [FoodCategories.pedas],
        spicyLevel: 5,
      ),
    ];

    List<PoopLog> diarrheaAfter() => [
      makePoop(id: 'p1', poopedAt: DateTime(2026, 11, 20, 19), bristol: 6, painLevel: 4),
      makePoop(id: 'p2', poopedAt: DateTime(2026, 11, 21, 20), bristol: 4, painLevel: 3),
      makePoop(id: 'p3', poopedAt: DateTime(2026, 11, 22, 20), bristol: 6, painLevel: 3),
    ];

    testWidgets('2 section terpisah + korelasi "Pedas" dari data dummy', (
      tester,
    ) async {
      useHugeWindow(tester);
      await tester.pumpWidget(
        wrapScreenWithData(
          const InsightsScreen(),
          food: spicySchedule(),
          poop: diarrheaAfter(),
          now: now,
        ),
      );
      await settle(tester);

      // 2 section terpisah (spec §5.5D: pola makan vs pola eek).
      expect(find.text('Pola Makan'), findsOneWidget);
      expect(find.text('Pola Eek'), findsOneWidget);
      expect(find.text('Ringkasan 7 Hari Terakhir'), findsOneWidget);

      // Korelasi pedas (spec §9: minimal 1 korelasi benar dari data dummy).
      expect(find.text('Kemungkinan pemicu: Pedas'), findsOneWidget);
      expect(find.textContaining('3 dari 3'), findsWidgets);
      expect(find.textContaining('Keyakinan:'), findsWidgets);

      // Tombol bukti ada di kartu.
      expect(find.text('Kenapa AI bilang ini?'), findsWidgets);
    });

    testWidgets('"Kenapa AI bilang ini?" menampilkan log mentah', (tester) async {
      useHugeWindow(tester);
      await tester.pumpWidget(
        wrapScreenWithData(
          const InsightsScreen(),
          food: spicySchedule(),
          poop: diarrheaAfter(),
          now: now,
        ),
      );
      await settle(tester);

      await tester.tap(find.text('Kenapa AI bilang ini?').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      // Sheet bukti: judul + log mentah dari catatan user (LogTimeline).
      expect(
        find.text(
          'Ini data mentah dari catatanmu yang dipakai AI — '
          'bukan data dari luar.',
        ),
        findsOneWidget,
      );
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('darah → kartu alert merah di Pola Eek (spec §9)', (tester) async {
      useHugeWindow(tester);
      await tester.pumpWidget(
        wrapScreenWithData(
          const InsightsScreen(),
          poop: [
            makePoop(id: 'p1', poopedAt: DateTime(2026, 11, 24, 9), bristol: 4),
            makePoop(
              id: 'p2',
              poopedAt: DateTime(2026, 11, 25, 9),
              hasBlood: true,
            ),
          ],
          now: now,
        ),
      );
      await settle(tester);

      expect(find.text('Ada darah di eek'), findsOneWidget);
      expect(find.text('Perlu perhatian'), findsWidgets);
      expect(find.textContaining('pertimbangkan konsultasi ke dokter'), findsWidgets);
    });

    testWidgets('data kosong → catatan jujur, bukan insight ngarang', (
      tester,
    ) async {
      useHugeWindow(tester);
      await tester.pumpWidget(wrapScreenWithData(const InsightsScreen()));
      await settle(tester);

      expect(find.textContaining('Data masih sedikit'), findsOneWidget);
      expect(find.text('Pola makan belum kebaca'), findsOneWidget);
      expect(
        find.textContaining('Catat makan 3 hari dulu'),
        findsOneWidget,
      );
    });

    testWidgets('pola makan abnormal dari FoodLog doang → warning kuning', (
      tester,
    ) async {
      useHugeWindow(tester);
      // 4 hari data makan, tiap hari cuma 1x → warning skip-makan (spec §5.5D).
      await tester.pumpWidget(
        wrapScreenWithData(
          const InsightsScreen(),
          food: [
            makeFood(id: 'f1', eatenAt: DateTime(2026, 11, 22, 12)),
            makeFood(id: 'f2', eatenAt: DateTime(2026, 11, 23, 12)),
            makeFood(id: 'f3', eatenAt: DateTime(2026, 11, 24, 12)),
            makeFood(id: 'f4', eatenAt: DateTime(2026, 11, 25, 12)),
          ],
          now: now,
        ),
      );
      await settle(tester);

      expect(find.text('Makan cuma 1x sehari 2 hari'), findsOneWidget);
    });
  });

  group('HomeScreen — kartu AI (spec §5.3)', () {
    testWidgets('"Kata AI Hari Ini" tampil + tap membuka Insights', (
      tester,
    ) async {
      useTallWindow(tester);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await tester.pumpWidget(
        wrapScreenWithData(
          const HomeScreen(),
          poop: [
            makePoop(
              id: 'p1',
              poopedAt: today.add(const Duration(hours: 9)),
              hasBlood: true,
            ),
          ],
        ),
      );
      await settle(tester);

      // Status perut merah dari AI tampil di Home.
      expect(find.text('Kata AI Hari Ini'), findsOneWidget);
      expect(find.textContaining('ada darah'), findsWidgets);

      // Tap kartu → halaman Insights.
      await tester.tap(find.text('Kata AI Hari Ini'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Pola Eek'), findsOneWidget);
    });
  });
}

String _monthName(int month) {
  const names = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return names[month - 1];
}
