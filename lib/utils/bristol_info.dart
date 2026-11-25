/// Deskripsi skala Bristol 1-7 (spec §5.2 / §7).
///
/// Data-only — visual picker-nya ada di `widgets/bristol_picker.dart`.
class BristolInfo {
  const BristolInfo({
    required this.scale,
    required this.title,
    required this.description,
  });

  /// Skala 1-7.
  final int scale;

  /// Judul singkat, mis. "Sosis halus".
  final String title;

  /// Deskripsi awam, santai, tidak medis.
  final String description;

  /// 1-2 = tanda konstipasi.
  bool get isConstipation => scale <= 2;

  /// 3-5 = rentang normal.
  bool get isNormal => scale >= 3 && scale <= 5;

  /// 6-7 = diare.
  bool get isDiarrhea => scale >= 6;

  static const all = <BristolInfo>[
    BristolInfo(
      scale: 1,
      title: 'Keras, bulat-bulat kecil',
      description: 'Susah keluar, kayak kelereng. Tanda konstipasi berat.',
    ),
    BristolInfo(
      scale: 2,
      title: 'Berbentuk sosis, bergumpal',
      description: 'Bentuknya sosis tapi bergumpal-gumpal.',
    ),
    BristolInfo(
      scale: 3,
      title: 'Sosis, ada retakan',
      description: 'Seperti sosis dengan retakan di permukaan.',
    ),
    BristolInfo(
      scale: 4,
      title: 'Sosis halus, normal',
      description: 'Lembut dan halus. Ini yang paling ideal.',
    ),
    BristolInfo(
      scale: 5,
      title: 'Gumpalan lunak, tepi jelas',
      description: 'Potongan lunak dengan tepi yang jelas.',
    ),
    BristolInfo(
      scale: 6,
      title: 'Lembek, potongan tidak jelas',
      description: 'Hancur, tepinya nggak beraturan. Mendekati diare.',
    ),
    BristolInfo(
      scale: 7,
      title: 'Cair, tanpa bentuk padat',
      description: 'Seperti air, sama sekali nggak berbentuk. Ini diare.',
    ),
  ];

  static BristolInfo of(int scale) =>
      all.firstWhere((e) => e.scale == scale, orElse: () => all[3]);

  /// Label super singkat untuk kartu picker.
  static String shortLabel(int scale) => switch (scale) {
    1 => 'Bulat kecil',
    2 => 'Bergumpal',
    3 => 'Ada retakan',
    4 => 'Halus (ideal)',
    5 => 'Gumpalan lunak',
    6 => 'Lembek',
    7 => 'Cair',
    _ => '-',
  };
}
