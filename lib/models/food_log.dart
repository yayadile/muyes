import 'package:flutter/foundation.dart' show listEquals;

/// Satu catatan makan (spec §5.1 / §6).
class FoodLog {
  const FoodLog({
    required this.id,
    required this.eatenAt,
    required this.foodName,
    this.categories = const <String>[],
    this.spicyLevel = 0,
    this.portion = FoodPortion.sedang,
    this.drink,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// UUID log.
  final String id;

  /// Waktu makan (default: sekarang, bisa diedit).
  final DateTime eatenAt;

  /// Nama makanan bebas, contoh: "Mie ayam level 3".
  final String foodName;

  /// Kategori multi-pilih, isi dari [FoodCategories.all].
  final List<String> categories;

  /// Level pedas 0-5. 0 = tidak pedas.
  final int spicyLevel;

  /// Porsi, isi dari [FoodPortion.all].
  final String portion;

  /// Minuman (opsional), contoh: "Es teh manis".
  final String? drink;

  /// Catatan bebas (opsional).
  final String? note;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Field opsional yang di-set `null` akan tetap memakai nilai lama.
  FoodLog copyWith({
    String? id,
    DateTime? eatenAt,
    String? foodName,
    List<String>? categories,
    int? spicyLevel,
    String? portion,
    String? drink,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodLog(
      id: id ?? this.id,
      eatenAt: eatenAt ?? this.eatenAt,
      foodName: foodName ?? this.foodName,
      categories: categories ?? this.categories,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      portion: portion ?? this.portion,
      drink: drink ?? this.drink,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FoodLog &&
      other.id == id &&
      other.eatenAt == eatenAt &&
      other.foodName == foodName &&
      listEquals(other.categories, categories) &&
      other.spicyLevel == spicyLevel &&
      other.portion == portion &&
      other.drink == drink &&
      other.note == note &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    eatenAt,
    foodName,
    Object.hashAll(categories),
    spicyLevel,
    portion,
    drink,
    note,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'FoodLog($id, $foodName, eatenAt: $eatenAt, pedas: $spicyLevel)';
}

/// Kategori makanan (spec §5.1).
abstract final class FoodCategories {
  static const nasi = 'Nasi';
  static const mie = 'Mie';
  static const pedas = 'Pedas';
  static const gorengan = 'Gorengan';
  static const santan = 'Santan';
  static const susu = 'Susu/Olahan Susu';
  static const kopi = 'Kopi/Kafein';
  static const teh = 'Teh';
  static const manis = 'Manis';
  static const buah = 'Buah';
  static const sayur = 'Sayur';
  static const daging = 'Daging';
  static const seafood = 'Seafood';
  static const junkFood = 'Junk Food';
  static const lainnya = 'Lainnya';

  /// Semua kategori untuk chip picker, urut sesuai spec.
  static const all = <String>[
    nasi,
    mie,
    pedas,
    gorengan,
    santan,
    susu,
    kopi,
    teh,
    manis,
    buah,
    sayur,
    daging,
    seafood,
    junkFood,
    lainnya,
  ];
}

/// Porsi makan (spec §5.1).
abstract final class FoodPortion {
  static const kecil = 'Kecil';
  static const sedang = 'Sedang';
  static const besar = 'Besar';

  static const all = <String>[kecil, sedang, besar];
}
