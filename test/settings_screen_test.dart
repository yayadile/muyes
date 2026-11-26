import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/data/database.dart';
import 'package:muyes/data/demo_seed.dart';
import 'package:muyes/screens/settings_screen.dart';

import 'test_helpers.dart';

/// Pump beberapa frame buat mastiin animasi + operasi DB kelar.
Future<void> pumpTimes(WidgetTester tester, [int count = 8]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Snackbar pakai Timer 4 detik — expire dulu biar teardown bersih.
Future<void> expireSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  group('SettingsScreen (spec §5.6)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> pumpSettings(
      WidgetTester tester, {
      bool demoSeeded = false,
      bool fastingMode = false,
    }) async {
      tester.view.physicalSize = const Size(900, 3600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        wrapScreenWithData(
          const SettingsScreen(),
          database: db,
          demoSeeded: demoSeeded,
          fastingMode: fastingMode,
        ),
      );
      await pumpTimes(tester);
    }

    testWidgets('semua section tampil + disclaimer medis', (tester) async {
      await pumpSettings(tester);

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Mode Puasa / Intermittent Fasting'), findsOneWidget);
      expect(find.text('Ekspor Data'), findsOneWidget);
      expect(find.text('Impor Data'), findsOneWidget);
      expect(find.text('Data Contoh'), findsOneWidget);
      expect(find.text('Hapus Semua Data'), findsOneWidget);
      expect(find.text('Tentang Muyes'), findsOneWidget);
      expect(find.textContaining('bukan alat medis'), findsOneWidget);
      expect(find.textContaining('100% offline'), findsOneWidget);
    });

    testWidgets('toggle Mode Puasa ON tersimpan ke DB', (tester) async {
      await pumpSettings(tester);

      expect(await db.getBoolSetting(SettingKeys.fastingMode), isFalse);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      await tester.tap(find.byType(Switch));
      await pumpTimes(tester);

      expect(await db.getBoolSetting(SettingKeys.fastingMode), isTrue);
    });

    testWidgets('toggle Mode Puasa OFF tersimpan ke DB', (tester) async {
      await db.setBoolSetting(SettingKeys.fastingMode, true);
      await pumpSettings(tester, fastingMode: true);

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

      await tester.tap(find.byType(Switch));
      await pumpTimes(tester);

      expect(await db.getBoolSetting(SettingKeys.fastingMode), isFalse);
    });

    testWidgets('"Isi data contoh" masuk DB + snackbar konfirmasi', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Isi data contoh'));
      await pumpTimes(tester, 20);

      final counts = await db.tableCounts();
      expect(counts['food'], greaterThan(30));
      expect(counts['poop'], greaterThan(15));
      expect(counts['mules'], greaterThan(3));
      expect(await db.getBoolSetting(SettingKeys.demoSeeded), isTrue);
      expect(
        find.textContaining('Data contoh 14 hari terpasang'),
        findsOneWidget,
      );

      await expireSnackBars(tester);
    });

    testWidgets('flag demoSeeded ON → tampil tombol "Hapus data contoh"', (
      tester,
    ) async {
      await pumpSettings(tester, demoSeeded: true);

      expect(find.text('Data contoh terpasang'), findsOneWidget);
      expect(find.text('Hapus data contoh'), findsOneWidget);
      expect(find.text('Isi data contoh'), findsNothing);
    });

    testWidgets('"Hapus data contoh" mengosongkan lagi', (tester) async {
      await pumpSettings(tester, demoSeeded: true);
      await applyDemoSeed(db, buildDemoSeed());

      await tester.tap(find.text('Hapus data contoh'));
      await pumpTimes(tester, 20);

      final counts = await db.tableCounts();
      expect(counts['food'], 0);
      expect(counts['poop'], 0);
      expect(counts['mules'], 0);
      expect(await db.getBoolSetting(SettingKeys.demoSeeded), isFalse);
      expect(find.textContaining('Data contoh dihapus'), findsOneWidget);

      await expireSnackBars(tester);
    });

    testWidgets('"Hapus semua data" butuh konfirmasi 2x (spec §5.6)', (
      tester,
    ) async {
      await pumpSettings(tester);
      await applyDemoSeed(db, buildDemoSeed());

      // Batal di konfirmasi pertama → data tetap.
      await tester.tap(find.text('Hapus semua data'));
      await pumpTimes(tester);
      expect(find.text('Hapus semua data?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await pumpTimes(tester);
      expect((await db.tableCounts())['food'], greaterThan(0));

      // Konfirmasi 1 → lanjut, batal di konfirmasi 2 → data tetap.
      await tester.tap(find.text('Hapus semua data'));
      await pumpTimes(tester);
      await tester.tap(find.text('Lanjut'));
      await pumpTimes(tester);
      expect(find.text('Yakin banget?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await pumpTimes(tester);
      expect((await db.tableCounts())['food'], greaterThan(0));

      // Dua-duanya dikonfirmasi → data hilang.
      await tester.tap(find.text('Hapus semua data'));
      await pumpTimes(tester);
      await tester.tap(find.text('Lanjut'));
      await pumpTimes(tester);
      await tester.tap(find.text('Ya, hapus semuanya'));
      await pumpTimes(tester, 20);

      final counts = await db.tableCounts();
      expect(counts['food'], 0);
      expect(counts['poop'], 0);
      expect(counts['mules'], 0);
      expect(find.textContaining('Semua data sudah dihapus'), findsOneWidget);

      await expireSnackBars(tester);
    });
  });
}
