import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ikon custom Muyes — aset SVG asli di `assets/icons/` (spec §8.1).
///
/// Jangan ganti dengan emoji / ikon Material: ikon ini bagian dari
/// identitas visual app (poop coklat bermata, muka meal, lingkaran
/// hijau zigzag muyes).
enum MuyesIcon { meal, poop, muyes }

extension MuyesIconAsset on MuyesIcon {
  String get assetPath => switch (this) {
    MuyesIcon.meal => 'assets/icons/meal.svg',
    MuyesIcon.poop => 'assets/icons/poop.svg',
    MuyesIcon.muyes => 'assets/icons/muyes.svg',
  };

  String get label => switch (this) {
    MuyesIcon.meal => 'Makan',
    MuyesIcon.poop => 'Eek',
    MuyesIcon.muyes => 'Mules',
  };
}

/// Widget ikon SVG dari aset. Ukuran default 48dp (spec §8.1 — ikon
/// tombol Home 48dp).
class MuyesIconView extends StatelessWidget {
  const MuyesIconView(this.icon, {super.key, this.size = 48});

  final MuyesIcon icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.assetPath,
      width: size,
      height: size,
    );
  }
}
