/// Satu catatan eek (spec §5.2 / §6).
///
/// Hanya [poopedAt] yang wajib — Bristol dan semua detail lain boleh kosong.
/// `null` berarti "tidak diisi", BUKAN 0 / normal / "tidak ada".
class PoopLog {
  const PoopLog({
    required this.id,
    required this.poopedAt,
    this.bristol,
    this.color,
    this.urgency,
    this.painLevel,
    this.hasBlood,
    this.hasMucus,
    this.duration,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// UUID log.
  final String id;

  /// Waktu eek. WAJIB — satu-satunya field wajib.
  final DateTime poopedAt;

  /// Skala Bristol 1-7 (spec §5.2). null = tidak diisi.
  final int? bristol;

  /// Warna, isi dari [PoopColors.all]. null = tidak diisi.
  final String? color;

  /// Urgensi 0-3: Santai / Lumayan kebelet / Harus buru-buru / Hampir nggak ketahan.
  final int? urgency;

  /// Mules / nyeri perut 0-5 (0 = tidak mules). null = tidak diisi.
  final int? painLevel;

  /// Ada darah? null = tidak diisi (bukan berarti tidak ada).
  final bool? hasBlood;

  /// Ada lendir? null = tidak diisi.
  final bool? hasMucus;

  /// Durasi, isi dari [PoopDurations.all]. null = tidak diisi.
  final String? duration;

  /// Catatan bebas (opsional).
  final String? note;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Bristol terisi? Dipakai AI untuk menentukan analisa Bristol bisa jalan atau tidak.
  bool get hasBristol => bristol != null;

  /// Field opsional yang di-set `null` akan tetap memakai nilai lama.
  PoopLog copyWith({
    String? id,
    DateTime? poopedAt,
    int? bristol,
    String? color,
    int? urgency,
    int? painLevel,
    bool? hasBlood,
    bool? hasMucus,
    String? duration,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PoopLog(
      id: id ?? this.id,
      poopedAt: poopedAt ?? this.poopedAt,
      bristol: bristol ?? this.bristol,
      color: color ?? this.color,
      urgency: urgency ?? this.urgency,
      painLevel: painLevel ?? this.painLevel,
      hasBlood: hasBlood ?? this.hasBlood,
      hasMucus: hasMucus ?? this.hasMucus,
      duration: duration ?? this.duration,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PoopLog &&
      other.id == id &&
      other.poopedAt == poopedAt &&
      other.bristol == bristol &&
      other.color == color &&
      other.urgency == urgency &&
      other.painLevel == painLevel &&
      other.hasBlood == hasBlood &&
      other.hasMucus == hasMucus &&
      other.duration == duration &&
      other.note == note &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    poopedAt,
    bristol,
    color,
    urgency,
    painLevel,
    hasBlood,
    hasMucus,
    duration,
    note,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'PoopLog($id, poopedAt: $poopedAt, bristol: ${bristol ?? '-'})';
}

/// Warna eek (spec §5.2).
abstract final class PoopColors {
  static const coklat = 'Coklat';
  static const kuning = 'Kuning';
  static const hijau = 'Hijau';
  static const hitam = 'Hitam';
  static const merah = 'Merah';
  static const pucat = 'Pucat';

  static const all = <String>[coklat, kuning, hijau, hitam, merah, pucat];
}

/// Durasi eek (spec §5.2).
abstract final class PoopDurations {
  static const kurang5 = '<5 mnt';
  static const lima15 = '5-15 mnt';
  static const lebih15 = '>15 mnt';

  static const all = <String>[kurang5, lima15, lebih15];
}
