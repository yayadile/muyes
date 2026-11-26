import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/data/backup_service.dart';
import 'package:muyes/data/database.dart';
import 'package:muyes/models/food_log.dart';
import 'package:muyes/models/mules_log.dart';
import 'package:muyes/models/poop_log.dart';

/// Waktu tetap biar hasil ekspor deterministik.
final exportNow = DateTime(2026, 11, 25, 20);

FoodLog demoFood(String id, {String name = 'Seblak pedas level 5'}) => FoodLog(
  id: id,
  eatenAt: DateTime(2026, 11, 24, 12, 30),
  foodName: name,
  categories: const [FoodCategories.pedas, FoodCategories.mie],
  spicyLevel: 5,
  portion: FoodPortion.besar,
  drink: 'Es teh manis',
  note: 'enak, "pedas" banget, mantap',
  createdAt: DateTime(2026, 11, 24, 12, 31),
  updatedAt: DateTime(2026, 11, 24, 12, 31),
);

PoopLog demoPoop(String id) => PoopLog(
  id: id,
  poopedAt: DateTime(2026, 11, 24, 19, 25),
  bristol: 6,
  painLevel: 4,
  hasBlood: false,
  note: 'eek lembek',
  createdAt: DateTime(2026, 11, 24, 19, 26),
  updatedAt: DateTime(2026, 11, 24, 19, 26),
);

MulesLog demoMules(String id) => MulesLog(
  id: id,
  feltAt: DateTime(2026, 11, 24, 19),
  painLevel: 3,
  createdAt: DateTime(2026, 11, 24, 19, 1),
  updatedAt: DateTime(2026, 11, 24, 19, 1),
);

AppDatabase openTestDb() => AppDatabase(NativeDatabase.memory());

void main() {
  group('exportBackupJson / parseBackupJson (spec §5.6)', () {
    test('round-trip: semua field + null tetap null (bukan 0)', () {
      final json = exportBackupJson(
        food: [demoFood('f1')],
        poop: [
          demoPoop('p1'),
          // Log minimalis — cuma waktu, semua detail null.
          PoopLog(
            id: 'p2',
            poopedAt: DateTime(2026, 11, 23, 8),
            createdAt: DateTime(2026, 11, 23, 8),
            updatedAt: DateTime(2026, 11, 23, 8),
          ),
        ],
        mules: [demoMules('m1')],
        now: exportNow,
      );

      final bundle = parseBackupJson(json);

      expect(bundle.food.single, demoFood('f1'));
      expect(bundle.poop.first, demoPoop('p1'));
      expect(bundle.poop.last.bristol, isNull);
      expect(bundle.poop.last.painLevel, isNull);
      expect(bundle.poop.last.hasBlood, isNull);
      expect(bundle.poop.last.note, isNull);
      expect(bundle.mules.single, demoMules('m1'));
      expect(bundle.total, 4);
      expect(json, contains('"app": "muyes"'));
      expect(json, contains('"exportedAt"'));
    });

    test('bukan JSON → FormatException ramah', () {
      expect(
        () => parseBackupJson('bukan json sama sekali'),
        throwsFormatException,
      );
    });

    test('JSON valid tapi bukan backup Muyes → ditolak', () {
      expect(
        () => parseBackupJson('{"app": "aplikasi-lain", "version": 1}'),
        throwsFormatException,
      );
    });

    test('versi backup yang nggak dikenal → ditolak', () {
      expect(
        () => parseBackupJson('{"app": "muyes", "version": 99}'),
        throwsFormatException,
      );
    });

    test('field wajib hilang di salah satu log → ditolak (bukan diam-diam)', () {
      final json = exportBackupJson(
        food: [demoFood('f1')],
        poop: const [],
        mules: const [],
        now: exportNow,
      );
      // Rusak: hapus foodName dari log pertama.
      final broken = json.replaceFirst('"foodName": "Seblak pedas level 5",', '');
      expect(() => parseBackupJson(broken), throwsFormatException);
    });
  });

  group('export CSV (spec §9: bisa dibuka di Excel)', () {
    test('food CSV: header + baris, escaping koma/kutip', () {
      final csv = exportFoodCsv([demoFood('f1')]);
      final lines = csv.split('\r\n');
      expect(lines, hasLength(2));
      expect(lines.first, startsWith('id,waktu,nama,kategori'));
      // Nama tidak perlu di-quote; note berisi koma + kutip → di-escape.
      expect(lines[1], contains('"enak, ""pedas"" banget, mantap"'));
      expect(lines[1], contains('2026-11-24 12:30'));
      expect(lines[1], contains('Pedas | Mie'));
    });

    test('poop CSV: null jadi kolom kosong (bukan 0 / "tidak")', () {
      final csv = exportPoopCsv([
        PoopLog(
          id: 'p1',
          poopedAt: DateTime(2026, 11, 23, 8),
          createdAt: DateTime(2026, 11, 23, 8),
          updatedAt: DateTime(2026, 11, 23, 8),
        ),
      ]);
      final row = csv.split('\r\n')[1];
      // id,waktu,bristol,color,urgency,mules,darah,lendir,durasi,catatan,dibuat
      expect(row, 'p1,2026-11-23 08:00,,,,,,,,,2026-11-23 08:00');
    });

    test('mules CSV: level + catatan', () {
      final csv = exportMulesCsv([demoMules('m1')]);
      final row = csv.split('\r\n')[1];
      expect(row, startsWith('m1,2026-11-24 19:00,3,'));
    });
  });

  group('importBundle (merge, bukan replace)', () {
    test('impor 2x: update by id, tambah yang baru, nggak hapus', () async {
      final db = openTestDb();
      addTearDown(db.close);

      final first = await importBundle(
        db,
        BackupBundle(food: [demoFood('f1')], poop: const [], mules: const []),
      );
      expect(first.total, 1);
      expect((await db.tableCounts())['food'], 1);

      // Impor ulang: id sama tapi nama beda → update, bukan duplikat.
      await importBundle(
        db,
        BackupBundle(
          food: [demoFood('f1', name: 'Nama baru')],
          poop: const [],
          mules: const [],
        ),
      );
      final counts = await db.tableCounts();
      expect(counts['food'], 1);
      expect((await FoodLogDao(db).getById('f1'))?.foodName, 'Nama baru');

      // Id baru → ditambah.
      await importBundle(
        db,
        BackupBundle(food: [demoFood('f2')], poop: const [], mules: const []),
      );
      expect((await db.tableCounts())['food'], 2);
    });
  });
}
