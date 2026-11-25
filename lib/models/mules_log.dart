/// Satu kejadian mules (spec §5.2b / §6).
///
/// Mules sering terjadi TANPA eek, jadi lognya terpisah dari [PoopLog].
class MulesLog {
  const MulesLog({
    required this.id,
    required this.feltAt,
    required this.painLevel,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// UUID log.
  final String id;

  /// Waktu mules. WAJIB.
  final DateTime feltAt;

  /// Level mules 0-5: 0 = Nggak mules (koreksi), 1-2 Ringan, 3 Sedang, 4-5 Parah.
  final int painLevel;

  /// Catatan bebas (opsional), contoh: "habis makan seblak".
  final String? note;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Field opsional yang di-set `null` akan tetap memakai nilai lama.
  MulesLog copyWith({
    String? id,
    DateTime? feltAt,
    int? painLevel,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MulesLog(
      id: id ?? this.id,
      feltAt: feltAt ?? this.feltAt,
      painLevel: painLevel ?? this.painLevel,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MulesLog &&
      other.id == id &&
      other.feltAt == feltAt &&
      other.painLevel == painLevel &&
      other.note == note &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(id, feltAt, painLevel, note, createdAt, updatedAt);

  @override
  String toString() =>
      'MulesLog($id, feltAt: $feltAt, level: ${MulesLevel.labelFor(painLevel)})';
}

/// Mapping chip level mules di UI (spec §5.2b).
///
/// Simpan angka di DB, tampilkan kata di UI. Jangan tampilkan angka 0-5 ke user.
abstract final class MulesLevel {
  /// Chip "Nggak mules" — untuk koreksi / nandain udah baikan.
  static const none = 0;

  /// Chip "Ringan" (= 1-2).
  static const ringan = 1;

  /// Chip "Sedang" (= 3).
  static const sedang = 3;

  /// Chip "Parah" (= 4-5).
  static const parah = 5;

  /// Urutan chip di form: Ringan, Sedang, Parah, lalu Nggak mules.
  static const chips = <int>[ringan, sedang, parah, none];

  /// Label kata untuk sebuah level angka.
  static String labelFor(int level) {
    if (level <= 0) return 'Nggak mules';
    if (level <= 2) return 'Ringan';
    if (level == 3) return 'Sedang';
    return 'Parah';
  }
}
