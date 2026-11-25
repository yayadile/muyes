import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/models/poop_log.dart';
import 'package:muyes/models/timeline_entry.dart';
import 'package:muyes/screens/calendar_screen.dart';
import 'package:muyes/screens/history_screen.dart';
import 'package:muyes/screens/home_screen.dart';
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
      expect(find.text('🟢 Pola hari ini kelihatan normal'), findsOneWidget);
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
