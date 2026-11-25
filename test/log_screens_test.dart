import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/data/database.dart';
import 'package:muyes/models/food_log.dart';
import 'package:muyes/providers.dart';
import 'package:muyes/screens/log_food_screen.dart';
import 'package:muyes/screens/log_mules_screen.dart';
import 'package:muyes/screens/log_poop_screen.dart';

/// Bungkus screen dengan ProviderScope yang pakai DB in-memory.
Widget wrapScreen(Widget screen, AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      locale: const Locale('id'),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: screen,
    ),
  );
}

/// Paksa ukuran jendela tinggi supaya form yang panjang muat tanpa scroll —
/// bikin test stabil (tidak kena bottom bar / tepi viewport).
void useTallWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('LogPoopScreen (spec §5.2 — waktu doang harus bisa)', () {
    testWidgets('Simpan langsung aktif & tersimpan dengan hanya waktu', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const LogPoopScreen(), db));

      // Tombol Simpan harus aktif tanpa isi apapun.
      final saveButton = find.widgetWithText(FilledButton, 'Simpan');
      expect(saveButton, findsOneWidget);
      expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final logs = await PoopLogDao(db).getAll();
      expect(logs, hasLength(1));
      expect(logs.single.bristol, isNull);
      expect(logs.single.color, isNull);
      expect(logs.single.painLevel, isNull);
      expect(logs.single.hasBlood, isNull);
      expect(logs.single.note, isNull);
      // Waktu terisi otomatis ("sekarang"), bukan null.
      expect(
        logs.single.poopedAt.difference(DateTime.now()).abs(),
        lessThan(const Duration(minutes: 1)),
      );
    });

    testWidgets('Bristol picker visual tampil 7 opsi, tetap opsional', (
      tester,
    ) async {
      useTallWindow(tester);
      await tester.pumpWidget(wrapScreen(const LogPoopScreen(), db));

      for (final label in [
        '1. Keras, bulat-bulat kecil',
        '4. Sosis halus, normal',
        '7. Cair, tanpa bentuk padat',
      ]) {
        expect(find.text(label), findsOneWidget);
      }

      // Pilih Bristol 6 lalu simpan.
      await tester.tap(find.text('6. Lembek, potongan tidak jelas'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pumpAndSettle();

      final logs = await PoopLogDao(db).getAll();
      expect(logs.single.bristol, 6);
    });

    testWidgets('detail disembunyikan di balik "Tambah detail"', (
      tester,
    ) async {
      useTallWindow(tester);
      await tester.pumpWidget(wrapScreen(const LogPoopScreen(), db));

      // Detail awalnya tidak tampil.
      expect(find.text('Warna'), findsNothing);
      expect(find.text('Urgensi'), findsNothing);

      await tester.tap(find.text('Tambah detail (opsional)'));
      await tester.pumpAndSettle();

      expect(find.text('Warna'), findsOneWidget);
      expect(find.text('Urgensi'), findsOneWidget);
    });
  });

  group('LogMulesScreen (spec §5.2b — 2 tap)', () {
    testWidgets('pilih Parah → Simpan = 2 tap, level 5 tersimpan', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const LogMulesScreen(), db));

      // Sebelum pilih level, Simpan nonaktif (level wajib di form ini).
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Simpan'))
            .onPressed,
        isNull,
      );

      // Tap 1: pilih level.
      await tester.tap(find.text('Parah'));
      await tester.pumpAndSettle();
      // Tap 2: simpan.
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pumpAndSettle();

      final logs = await MulesLogDao(db).getAll();
      expect(logs, hasLength(1));
      expect(logs.single.painLevel, 5);
    });

    testWidgets('chip pakai kata, bukan angka 0-5', (tester) async {
      await tester.pumpWidget(wrapScreen(const LogMulesScreen(), db));

      for (final label in ['Ringan', 'Sedang', 'Parah', 'Nggak mules']) {
        expect(find.text(label), findsOneWidget);
      }
      // Tidak ada chip berisi angka mentah.
      for (final bad in ['0', '1', '2', '3', '4', '5']) {
        expect(find.text(bad), findsNothing);
      }
    });

    testWidgets('Ringan tersimpan sebagai range 1-2 (nilai 1)', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const LogMulesScreen(), db));

      await tester.tap(find.text('Ringan'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pumpAndSettle();

      final logs = await MulesLogDao(db).getAll();
      expect(logs.single.painLevel, 1);
    });
  });

  group('LogFoodScreen (spec §5.1)', () {
    testWidgets('Simpan nonaktif tanpa nama, aktif setelah isi nama', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const LogFoodScreen(), db));

      final saveFinder = find.widgetWithText(FilledButton, 'Simpan');
      expect(tester.widget<FilledButton>(saveFinder).onPressed, isNull);

      await tester.enterText(
        find.widgetWithText(TextField, 'Makan apa?'),
        'Mie ayam level 3',
      );
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(saveFinder).onPressed, isNotNull);
    });

    testWidgets('isi nama + pedas + kategori → tersimpan lengkap', (
      tester,
    ) async {
      useTallWindow(tester);
      await tester.pumpWidget(wrapScreen(const LogFoodScreen(), db));

      await tester.enterText(
        find.widgetWithText(TextField, 'Makan apa?'),
        'Seblak',
      );
      await tester.pumpAndSettle();

      // Pilih 15 chip kategori ada semua.
      expect(find.text('Nasi'), findsOneWidget);
      expect(find.text('Santan'), findsOneWidget);
      expect(find.text('Junk Food'), findsOneWidget);

      await tester.tap(find.text('Pedas').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(ChoiceChip, '4').first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '4').first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pumpAndSettle();

      final logs = await FoodLogDao(db).getAll();
      expect(logs, hasLength(1));
      final log = logs.single;
      expect(log.foodName, 'Seblak');
      expect(log.spicyLevel, 4);
      expect(log.categories, ['Pedas']);
      expect(log.portion, 'Sedang');
      expect(log.drink, isNull);
    });

    testWidgets('porsi bisa diganti ke Besar', (tester) async {
      useTallWindow(tester);
      await tester.pumpWidget(wrapScreen(const LogFoodScreen(), db));

      await tester.enterText(
        find.widgetWithText(TextField, 'Makan apa?'),
        'Nasi padang',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Besar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pumpAndSettle();

      final logs = await FoodLogDao(db).getAll();
      expect(logs.single.portion, 'Besar');
      expect(logs.single.spicyLevel, 0);
    });

    testWidgets('chip "Makan lagi" muncul dari log lama & bisa diklik', (
      tester,
    ) async {
      useTallWindow(tester);
      // Isi riwayat dulu: "Seblak" 3x, "Bakso" 1x.
      final dao = FoodLogDao(db);
      for (var i = 0; i < 3; i++) {
        await dao.upsert(
          FoodLog(
            id: 'f$i',
            eatenAt: DateTime(2026, 11, 20 + i, 12),
            foodName: 'Seblak',
            createdAt: DateTime(2026, 11, 20 + i, 12),
            updatedAt: DateTime(2026, 11, 20 + i, 12),
          ),
        );
      }
      await dao.upsert(
        FoodLog(
          id: 'f9',
          eatenAt: DateTime(2026, 11, 23, 12),
          foodName: 'Bakso',
          createdAt: DateTime(2026, 11, 23, 12),
          updatedAt: DateTime(2026, 11, 23, 12),
        ),
      );

      await tester.pumpWidget(wrapScreen(const LogFoodScreen(), db));
      await tester.pumpAndSettle();

      expect(find.text('Makan lagi'), findsOneWidget);
      expect(find.text('Seblak (3x)'), findsOneWidget);

      // Tap chip → nama makanan langsung keisi.
      await tester.tap(find.text('Seblak (3x)'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, 'Makan apa?'),
        findsOneWidget,
      );
      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Makan apa?'),
      );
      expect(field.controller!.text, 'Seblak');

      // Simpan → tersimpan sebagai log baru.
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await tester.pumpAndSettle();
      expect(await dao.getAll(), hasLength(5));
    });
  });
}
