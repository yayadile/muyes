import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/data/database.dart';
import 'package:muyes/models/food_log.dart';
import 'package:muyes/models/insight.dart';
import 'package:muyes/models/mules_log.dart';
import 'package:muyes/models/poop_log.dart';
import 'package:muyes/utils/date_utils.dart';

/// Helper: DB in-memory untuk test.
AppDatabase openTestDb() => AppDatabase(NativeDatabase.memory());

/// Buat FoodLog cepat dengan waktu relatif.
FoodLog makeFood({
  required String id,
  required DateTime eatenAt,
  String foodName = 'Nasi goreng',
  List<String> categories = const [FoodCategories.nasi],
  int spicyLevel = 0,
  String portion = FoodPortion.sedang,
  String? drink,
  String? note,
}) {
  final created = DateTime(2026, 11, 1, 8);
  return FoodLog(
    id: id,
    eatenAt: eatenAt,
    foodName: foodName,
    categories: categories,
    spicyLevel: spicyLevel,
    portion: portion,
    drink: drink,
    note: note,
    createdAt: created,
    updatedAt: created,
  );
}

void main() {
  group('date utils', () {
    test('startOfDay / startOfNextDay / dayKey', () {
      final dt = DateTime(2026, 11, 25, 13, 45, 12);
      expect(startOfDay(dt), DateTime(2026, 11, 25));
      expect(startOfNextDay(dt), DateTime(2026, 11, 26));
      expect(dayKey(dt), '2026-11-25');
      expect(dayKey(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('startOfNextDay works across month & year boundary', () {
      expect(startOfNextDay(DateTime(2026, 11, 30, 23)), DateTime(2026, 12, 1));
      expect(startOfNextDay(DateTime(2026, 12, 31, 10)), DateTime(2027, 1, 1));
    });

    test('isSameDay', () {
      expect(
        isSameDay(DateTime(2026, 11, 25, 0, 1), DateTime(2026, 11, 25, 23, 59)),
        isTrue,
      );
      expect(
        isSameDay(DateTime(2026, 11, 25), DateTime(2026, 11, 26)),
        isFalse,
      );
    });
  });

  group('FoodLog', () {
    test('defaults: kategori kosong, pedas 0, porsi Sedang', () {
      final log = FoodLog(
        id: 'f1',
        eatenAt: DateTime(2026, 11, 25, 12),
        foodName: 'Mie ayam',
        createdAt: DateTime(2026, 11, 25, 12),
        updatedAt: DateTime(2026, 11, 25, 12),
      );
      expect(log.categories, isEmpty);
      expect(log.spicyLevel, 0);
      expect(log.portion, FoodPortion.sedang);
      expect(log.drink, isNull);
      expect(log.note, isNull);
    });

    test('categories: 15 kategori sesuai spec §5.1', () {
      expect(FoodCategories.all, hasLength(15));
      expect(FoodCategories.all.first, FoodCategories.nasi);
      expect(FoodCategories.all.last, FoodCategories.lainnya);
    });

    test('equality termasuk isi list categories', () {
      final a = makeFood(id: 'x', eatenAt: DateTime(2026, 11, 25));
      final b = makeFood(id: 'x', eatenAt: DateTime(2026, 11, 25));
      final c = makeFood(
        id: 'x',
        eatenAt: DateTime(2026, 11, 25),
        categories: const [FoodCategories.mie],
      );
      expect(a, b);
      expect(a == c, isFalse);
    });

    test('copyWith mengganti field yang diberikan', () {
      final a = makeFood(id: 'x', eatenAt: DateTime(2026, 11, 25));
      final b = a.copyWith(foodName: 'Seblak', spicyLevel: 4);
      expect(b.foodName, 'Seblak');
      expect(b.spicyLevel, 4);
      expect(b.id, a.id);
      expect(b.eatenAt, a.eatenAt);
    });
  });

  group('AppDatabase + DAO', () {
    late AppDatabase db;

    setUp(() => db = openTestDb());
    tearDown(() => db.close());

    test('upsert & getAll food log, urut terbaru dulu', () async {
      final dao = FoodLogDao(db);
      await dao.upsert(
        makeFood(id: 'a', eatenAt: DateTime(2026, 11, 25, 8), foodName: 'Bubur'),
      );
      await dao.upsert(
        makeFood(
          id: 'b',
          eatenAt: DateTime(2026, 11, 25, 12),
          foodName: 'Nasi padang',
          spicyLevel: 3,
          categories: const [FoodCategories.nasi, FoodCategories.pedas],
        ),
      );

      final all = await dao.getAll();
      expect(all.map((e) => e.id), ['b', 'a']);
      expect(all.first.categories, [FoodCategories.nasi, FoodCategories.pedas]);
      expect(all.first.spicyLevel, 3);
    });

    test('upsert dengan id sama = update, bukan duplikat', () async {
      final dao = FoodLogDao(db);
      final log = makeFood(id: 'a', eatenAt: DateTime(2026, 11, 25, 8));
      await dao.upsert(log);
      await dao.upsert(log.copyWith(foodName: 'Diubah'));

      final all = await dao.getAll();
      expect(all, hasLength(1));
      expect(all.first.foodName, 'Diubah');
    });

    test('getForDay hanya 1 hari kalender', () async {
      final dao = FoodLogDao(db);
      await dao.upsert(makeFood(id: 'a', eatenAt: DateTime(2026, 11, 24, 23)));
      await dao.upsert(makeFood(id: 'b', eatenAt: DateTime(2026, 11, 25, 0)));
      await dao.upsert(
        makeFood(id: 'c', eatenAt: DateTime(2026, 11, 25, 23, 59, 59)),
      );
      await dao.upsert(makeFood(id: 'd', eatenAt: DateTime(2026, 11, 26, 0)));

      final day = await dao.getForDay(DateTime(2026, 11, 25, 15));
      expect(day.map((e) => e.id), ['b', 'c']);
    });

    test('getLastDays mengambil rentang inklusif', () async {
      final now = DateTime(2026, 11, 25, 15);
      final dao = FoodLogDao(db);
      await dao.upsert(
        makeFood(id: 'old', eatenAt: DateTime(2026, 11, 18, 12)),
      );
      await dao.upsert(
        makeFood(id: 'edge', eatenAt: DateTime(2026, 11, 19, 0, 30)),
      );
      await dao.upsert(makeFood(id: 'new', eatenAt: DateTime(2026, 11, 25, 9)));

      final last7 = await dao.getLastDays(7, now: now);
      expect(last7.map((e) => e.id), ['edge', 'new']);
    });

    test('topFoodNames menghitung & mengurutkan frekuensi', () async {
      final dao = FoodLogDao(db);
      for (var i = 0; i < 3; i++) {
        await dao.upsert(
          makeFood(
            id: 'nasi$i',
            eatenAt: DateTime(2026, 11, 20 + i),
            foodName: 'Nasi uduk',
          ),
        );
      }
      await dao.upsert(
        makeFood(id: 'mie', eatenAt: DateTime(2026, 11, 23), foodName: 'Mie'),
      );

      final top = await dao.topFoodNames();
      expect(top.first.name, 'Nasi uduk');
      expect(top.first.count, 3);
      expect(top[1].name, 'Mie');
    });

    test('search nama makanan, catatan, dan minuman', () async {
      final dao = FoodLogDao(db);
      await dao.upsert(
        makeFood(
          id: 'a',
          eatenAt: DateTime(2026, 11, 20),
          foodName: 'Ayam geprek sambal',
        ),
      );
      await dao.upsert(
        makeFood(
          id: 'b',
          eatenAt: DateTime(2026, 11, 21),
          foodName: 'Bakso',
          note: 'pakai sambal banyak',
        ),
      );
      await dao.upsert(
        makeFood(
          id: 'c',
          eatenAt: DateTime(2026, 11, 22),
          foodName: 'Sate',
          drink: 'Es sambal? nggak, es teh',
        ),
      );
      await dao.upsert(
        makeFood(id: 'd', eatenAt: DateTime(2026, 11, 23), foodName: 'Soto'),
      );

      final hasil = await dao.search('sambal');
      expect(hasil.map((e) => e.id).toSet(), {'a', 'b', 'c'});
    });

    test('PoopLog: simpan dengan HANYA waktu (semua field opsional)', () async {
      final dao = PoopLogDao(db);
      final t = DateTime(2026, 11, 25, 7, 30);
      await dao.upsert(
        PoopLog(
          id: 'p1',
          poopedAt: t,
          createdAt: t,
          updatedAt: t,
        ),
      );

      final all = await dao.getAll();
      expect(all, hasLength(1));
      final log = all.single;
      expect(log.poopedAt, t);
      expect(log.bristol, isNull);
      expect(log.color, isNull);
      expect(log.urgency, isNull);
      expect(log.painLevel, isNull);
      expect(log.hasBlood, isNull);
      expect(log.hasMucus, isNull);
      expect(log.duration, isNull);
      expect(log.note, isNull);
      expect(log.hasBristol, isFalse);
    });

    test('PoopLog: nullable tetap null setelah round-trip DB', () async {
      final dao = PoopLogDao(db);
      final t = DateTime(2026, 11, 24, 9);
      await dao.upsert(
        PoopLog(
          id: 'p2',
          poopedAt: t,
          bristol: 6,
          hasBlood: true,
          hasMucus: false, // diisi "tidak", bukan null
          createdAt: t,
          updatedAt: t,
        ),
      );

      final log = (await dao.getById('p2'))!;
      expect(log.bristol, 6);
      expect(log.hasBlood, isTrue);
      expect(log.hasMucus, isFalse);
      expect(log.color, isNull); // tidak diisi tetap null, bukan default
      expect(log.hasBristol, isTrue);
    });

    test('PoopLog: countWithoutBristol menghitung log tanpa Bristol', () async {
      final dao = PoopLogDao(db);
      for (var i = 0; i < 3; i++) {
        await dao.upsert(
          PoopLog(
            id: 'p$i',
            poopedAt: DateTime(2026, 11, 20 + i),
            bristol: i == 0 ? 4 : null,
            createdAt: DateTime(2026, 11, 20 + i),
            updatedAt: DateTime(2026, 11, 20 + i),
          ),
        );
      }
      expect(await dao.countWithoutBristol(), 2);
    });

    test('PoopLog: getLastBefore untuk cek "belum eek X hari"', () async {
      final dao = PoopLogDao(db);
      await dao.upsert(
        PoopLog(
          id: 'p1',
          poopedAt: DateTime(2026, 11, 20, 8),
          createdAt: DateTime(2026, 11, 20, 8),
          updatedAt: DateTime(2026, 11, 20, 8),
        ),
      );

      final last = await dao.getLastBefore(DateTime(2026, 11, 25));
      expect(last?.id, 'p1');
      expect(await dao.getLastBefore(DateTime(2026, 11, 19)), isNull);
    });

    test('MulesLog: level 0-5 round-trip, label UI benar', () async {
      final dao = MulesLogDao(db);
      final levels = [0, 1, 2, 3, 4, 5];
      for (var i = 0; i < levels.length; i++) {
        await dao.upsert(
          MulesLog(
            id: 'm$i',
            feltAt: DateTime(2026, 11, 25, 10 + i),
            painLevel: levels[i],
            createdAt: DateTime(2026, 11, 25, 10 + i),
            updatedAt: DateTime(2026, 11, 25, 10 + i),
          ),
        );
      }

      final all = await dao.getAll();
      expect(all, hasLength(6));
      expect(MulesLevel.labelFor(0), 'Nggak mules');
      expect(MulesLevel.labelFor(1), 'Ringan');
      expect(MulesLevel.labelFor(2), 'Ringan');
      expect(MulesLevel.labelFor(3), 'Sedang');
      expect(MulesLevel.labelFor(4), 'Parah');
      expect(MulesLevel.labelFor(5), 'Parah');
      expect(MulesLevel.chips, [1, 3, 5, 0]);
    });

    test('Insight: round-trip evidenceLogIds JSON + markRead', () async {
      final dao = InsightDao(db);
      final insight = Insight(
        id: 'abnormal:darah:7',
        type: InsightType.abnormal,
        level: InsightLevel.alert,
        title: 'Ada darah di eek',
        body: 'Perlu perhatian serius...',
        confidence: InsightConfidence.tinggi,
        evidenceLogIds: const ['p2', 'p9'],
        periodDays: 7,
        createdAt: DateTime(2026, 11, 25, 12),
      );
      await dao.upsert(insight);

      final loaded = (await dao.getById('abnormal:darah:7'))!;
      expect(loaded.evidenceLogIds, ['p2', 'p9']);
      expect(loaded.isRead, isFalse);
      expect(await dao.countUnread(), 1);

      await dao.markRead('abnormal:darah:7');
      expect(await dao.countUnread(), 0);
    });

    test('Setting key-value: fasting mode default OFF', () async {
      expect(
        await db.getBoolSetting(SettingKeys.fastingMode),
        isFalse,
      );
      await db.setBoolSetting(SettingKeys.fastingMode, true);
      expect(await db.getBoolSetting(SettingKeys.fastingMode), isTrue);
      await db.deleteSetting(SettingKeys.fastingMode);
      expect(await db.getBoolSetting(SettingKeys.fastingMode), isFalse);
    });

    test('deleteAllLogs menghapus log tapi setting tetap', () async {
      final foodDao = FoodLogDao(db);
      final poopDao = PoopLogDao(db);
      final mulesDao = MulesLogDao(db);
      final insightDao = InsightDao(db);

      await foodDao.upsert(
        makeFood(id: 'a', eatenAt: DateTime(2026, 11, 25, 8)),
      );
      await poopDao.upsert(
        PoopLog(
          id: 'p1',
          poopedAt: DateTime(2026, 11, 25, 8),
          createdAt: DateTime(2026, 11, 25, 8),
          updatedAt: DateTime(2026, 11, 25, 8),
        ),
      );
      await mulesDao.upsert(
        MulesLog(
          id: 'm1',
          feltAt: DateTime(2026, 11, 25, 9),
          painLevel: 3,
          createdAt: DateTime(2026, 11, 25, 9),
          updatedAt: DateTime(2026, 11, 25, 9),
        ),
      );
      await insightDao.upsert(
        Insight(
          id: 'i1',
          type: InsightType.eatingPattern,
          level: InsightLevel.warning,
          title: 'T',
          body: 'B',
          confidence: InsightConfidence.sedang,
          createdAt: DateTime(2026, 11, 25, 9),
        ),
      );
      await db.setBoolSetting(SettingKeys.fastingMode, true);

      await db.deleteAllLogs();

      expect(await foodDao.getAll(), isEmpty);
      expect(await poopDao.getAll(), isEmpty);
      expect(await mulesDao.getAll(), isEmpty);
      expect(await insightDao.getAll(), isEmpty);
      expect(await db.getBoolSetting(SettingKeys.fastingMode), isTrue);
    });

    test('tableCounts menghitung semua tabel', () async {
      final foodDao = FoodLogDao(db);
      await foodDao.upsert(
        makeFood(id: 'a', eatenAt: DateTime(2026, 11, 25, 8)),
      );
      await foodDao.upsert(
        makeFood(id: 'b', eatenAt: DateTime(2026, 11, 25, 12)),
      );

      final counts = await db.tableCounts();
      expect(counts['food'], 2);
      expect(counts['poop'], 0);
      expect(counts['mules'], 0);
      expect(counts['insight'], 0);
    });
  });
}
