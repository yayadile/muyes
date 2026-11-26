import 'dart:convert';

import '../models/food_log.dart';
import '../models/mules_log.dart';
import '../models/poop_log.dart';
import '../utils/date_utils.dart';
import 'database.dart';

/// Backup JSON punya penanda app + versi format (spec §5.6).
/// Import cuma nerima file yang dikenali — bukan file sembarangan.
const backupAppId = 'muyes';
const backupVersion = 1;

/// Isi satu file backup: semua log dari 3 tabel.
class BackupBundle {
  const BackupBundle({
    required this.food,
    required this.poop,
    required this.mules,
  });

  final List<FoodLog> food;
  final List<PoopLog> poop;
  final List<MulesLog> mules;

  bool get isEmpty => food.isEmpty && poop.isEmpty && mules.isEmpty;

  int get total => food.length + poop.length + mules.length;

  /// Ringkasan buat pesan hasil impor.
  String get summary =>
      '${food.length}x makan, ${poop.length}x eek, ${mules.length}x mules';
}

/// Ekspor semua log ke JSON (backup penuh — null tetap null, bukan 0).
String exportBackupJson({
  required List<FoodLog> food,
  required List<PoopLog> poop,
  required List<MulesLog> mules,
  DateTime? now,
}) {
  final data = <String, dynamic>{
    'app': backupAppId,
    'version': backupVersion,
    'exportedAt': (now ?? DateTime.now()).toIso8601String(),
    'foodLogs': [for (final log in food) _foodToJson(log)],
    'poopLogs': [for (final log in poop) _poopToJson(log)],
    'mulesLogs': [for (final log in mules) _mulesToJson(log)],
  };
  return const JsonEncoder.withIndent('  ').convert(data);
}

/// Parse file backup JSON. Lempar [FormatException] dengan pesan ramah
/// kalau file-nya bukan backup Muyes yang dikenal.
BackupBundle parseBackupJson(String source) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    throw const FormatException('File-nya bukan JSON yang valid.');
  }
  if (decoded is! Map) {
    throw const FormatException('Format backup nggak dikenal.');
  }
  final map = Map<String, dynamic>.from(decoded);
  if (map['app'] != backupAppId) {
    throw const FormatException('Ini bukan file backup Muyes.');
  }
  if (map['version'] != backupVersion) {
    throw FormatException(
      'Versi backup (${map['version']}) belum didukung app ini.',
    );
  }

  return BackupBundle(
    food: _parseList(map['foodLogs'], _foodFromJson),
    poop: _parseList(map['poopLogs'], _poopFromJson),
    mules: _parseList(map['mulesLogs'], _mulesFromJson),
  );
}

List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) item) {
  if (raw == null) return const [];
  if (raw is! List) {
    throw const FormatException('Isi file backup rusak.');
  }
  return [
    for (final entry in raw)
      if (entry is Map) item(Map<String, dynamic>.from(entry)),
  ];
}

// ---- JSON per model ----

Map<String, dynamic> _foodToJson(FoodLog log) => {
  'id': log.id,
  'eatenAt': log.eatenAt.toIso8601String(),
  'foodName': log.foodName,
  'categories': log.categories,
  'spicyLevel': log.spicyLevel,
  'portion': log.portion,
  'drink': log.drink,
  'note': log.note,
  'createdAt': log.createdAt.toIso8601String(),
  'updatedAt': log.updatedAt.toIso8601String(),
};

Map<String, dynamic> _poopToJson(PoopLog log) => {
  'id': log.id,
  'poopedAt': log.poopedAt.toIso8601String(),
  'bristol': log.bristol,
  'color': log.color,
  'urgency': log.urgency,
  'painLevel': log.painLevel,
  'hasBlood': log.hasBlood,
  'hasMucus': log.hasMucus,
  'duration': log.duration,
  'note': log.note,
  'createdAt': log.createdAt.toIso8601String(),
  'updatedAt': log.updatedAt.toIso8601String(),
};

Map<String, dynamic> _mulesToJson(MulesLog log) => {
  'id': log.id,
  'feltAt': log.feltAt.toIso8601String(),
  'painLevel': log.painLevel,
  'note': log.note,
  'createdAt': log.createdAt.toIso8601String(),
  'updatedAt': log.updatedAt.toIso8601String(),
};

String _reqString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('Field "$key" hilang / rusak di file backup.');
  }
  return value;
}

String? _optString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Field "$key" harus teks.');
  }
  return value;
}

int _reqInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('Field "$key" hilang / rusak di file backup.');
  }
  return value;
}

int? _optInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! int) {
    throw FormatException('Field "$key" harus angka.');
  }
  return value;
}

bool? _optBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! bool) {
    throw FormatException('Field "$key" harus Ya/Tidak.');
  }
  return value;
}

DateTime _reqTime(Map<String, dynamic> json, String key) {
  final raw = _reqString(json, key);
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    throw FormatException('Waktu "$key" nggak bisa dibaca: $raw');
  }
  return parsed;
}

FoodLog _foodFromJson(Map<String, dynamic> json) => FoodLog(
  id: _reqString(json, 'id'),
  eatenAt: _reqTime(json, 'eatenAt'),
  foodName: _reqString(json, 'foodName'),
  categories: [
    for (final c in json['categories'] ?? const <dynamic>[])
      if (c is String) c,
  ],
  spicyLevel: _reqInt(json, 'spicyLevel'),
  portion: _reqString(json, 'portion'),
  drink: _optString(json, 'drink'),
  note: _optString(json, 'note'),
  createdAt: _reqTime(json, 'createdAt'),
  updatedAt: _reqTime(json, 'updatedAt'),
);

PoopLog _poopFromJson(Map<String, dynamic> json) => PoopLog(
  id: _reqString(json, 'id'),
  poopedAt: _reqTime(json, 'poopedAt'),
  bristol: _optInt(json, 'bristol'),
  color: _optString(json, 'color'),
  urgency: _optInt(json, 'urgency'),
  painLevel: _optInt(json, 'painLevel'),
  hasBlood: _optBool(json, 'hasBlood'),
  hasMucus: _optBool(json, 'hasMucus'),
  duration: _optString(json, 'duration'),
  note: _optString(json, 'note'),
  createdAt: _reqTime(json, 'createdAt'),
  updatedAt: _reqTime(json, 'updatedAt'),
);

MulesLog _mulesFromJson(Map<String, dynamic> json) => MulesLog(
  id: _reqString(json, 'id'),
  feltAt: _reqTime(json, 'feltAt'),
  painLevel: _reqInt(json, 'painLevel'),
  note: _optString(json, 'note'),
  createdAt: _reqTime(json, 'createdAt'),
  updatedAt: _reqTime(json, 'updatedAt'),
);

// ---- CSV (buat dibuka di Excel / Google Sheets) ----

/// Ekspor log makan ke CSV. "" berarti nggak diisi (bukan "tidak").
String exportFoodCsv(List<FoodLog> logs) {
  final rows = <List<String>>[
    [
      'id',
      'waktu',
      'nama',
      'kategori',
      'pedas (0-5)',
      'porsi',
      'minuman',
      'catatan',
      'dibuat',
    ],
    for (final log in logs)
      [
        log.id,
        _csvDateTime(log.eatenAt),
        log.foodName,
        log.categories.join(' | '),
        '${log.spicyLevel}',
        log.portion,
        log.drink ?? '',
        log.note ?? '',
        _csvDateTime(log.createdAt),
      ],
  ];
  return _csv(rows);
}

/// Ekspor log eek ke CSV. Kolom kosong = nggak diisi (jangan dianggap 0).
String exportPoopCsv(List<PoopLog> logs) {
  final rows = <List<String>>[
    [
      'id',
      'waktu',
      'bristol (1-7)',
      'warna',
      'urgensi (0-3)',
      'mules (0-5)',
      'darah',
      'lendir',
      'durasi',
      'catatan',
      'dibuat',
    ],
    for (final log in logs)
      [
        log.id,
        _csvDateTime(log.poopedAt),
        log.bristol?.toString() ?? '',
        log.color ?? '',
        log.urgency?.toString() ?? '',
        log.painLevel?.toString() ?? '',
        _csvBool(log.hasBlood),
        _csvBool(log.hasMucus),
        log.duration ?? '',
        log.note ?? '',
        _csvDateTime(log.createdAt),
      ],
  ];
  return _csv(rows);
}

/// Ekspor log mules ke CSV.
String exportMulesCsv(List<MulesLog> logs) {
  final rows = <List<String>>[
    ['id', 'waktu', 'level (1-5)', 'catatan', 'dibuat'],
    for (final log in logs)
      [
        log.id,
        _csvDateTime(log.feltAt),
        '${log.painLevel}',
        log.note ?? '',
        _csvDateTime(log.createdAt),
      ],
  ];
  return _csv(rows);
}

String _csvBool(bool? value) => switch (value) {
  true => 'ya',
  false => 'tidak',
  null => '',
};

String _csvDateTime(DateTime dt) =>
    '${dayKey(dt)} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';

/// Gabung baris CSV + escaping standar (koma, kutip, baris baru).
String _csv(List<List<String>> rows) {
  return rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
}

String _csvCell(String value) {
  if (value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

// ---- Import: merge bundle ke DB ----

/// Hasil impor: berapa baris yang masuk, buat pesan di Settings.
class ImportResult {
  const ImportResult({
    required this.food,
    required this.poop,
    required this.mules,
  });

  final int food;
  final int poop;
  final int mules;

  int get total => food + poop + mules;

  String get summary =>
      '${food}x makan, ${poop}x eek, ${mules}x mules ditambahkan / di-update.';
}

/// Merge [bundle] ke DB: log dengan id yang sudah ada di-update, id baru
/// ditambah — data yang sudah ada nggak dihapus (impor = tambah, bukan
/// replace).
Future<ImportResult> importBundle(AppDatabase db, BackupBundle bundle) async {
  final foodDao = FoodLogDao(db);
  final poopDao = PoopLogDao(db);
  final mulesDao = MulesLogDao(db);

  await db.transaction(() async {
    for (final log in bundle.food) {
      await foodDao.upsert(log);
    }
    for (final log in bundle.poop) {
      await poopDao.upsert(log);
    }
    for (final log in bundle.mules) {
      await mulesDao.upsert(log);
    }
  });

  return ImportResult(
    food: bundle.food.length,
    poop: bundle.poop.length,
    mules: bundle.mules.length,
  );
}
