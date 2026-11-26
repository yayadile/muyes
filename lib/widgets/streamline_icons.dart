import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';

/// Ikon UI Muyes dari Streamline, pengganti semua emoji (koreksi user,
/// 26 Nov 2026).
///
/// Aset SVG di `assets/streamline/` diunduh dari Streamline lewat MCP —
/// keluarga Phosphor (open-source, rounded, gratis penuh) set `phosphor-fill`.
/// Satu keluarga untuk semua ikon biar gaya konsisten di seluruh app.
///
/// Pemetaan lama → baru:
///  - 🤖 robot (kartu "Kata AI Hari Ini")
///  - 🟢 perut aman → jempol hijau [thumbsUp]
///  - 🟡 waspada → [warning]; 🔴 bahaya → [danger]
///  - 🌶️ pedas → [chili]; 🙂😖😫 mules → [smile]/[sad]/[sick]
///  - 🌱 mulai nyatat → [sprout]; 📋 ringkasan → [clipboard]
///  - 🕐 jam → [clock]; 🍽️ makanan → [plate]; ⚡ pemicu → [bolt]
///  - ℹ️ info → [info]; 🎉 apresiasi → [celebrate]
enum SlIcon {
  robot,
  thumbsUp,
  warning,
  danger,
  chili,
  smile,
  sad,
  sick,
  sprout,
  clipboard,
  clock,
  plate,
  bolt,
  info,
  celebrate,
}

extension SlIconAsset on SlIcon {
  String get assetPath => switch (this) {
    SlIcon.robot => 'assets/streamline/robot.svg',
    SlIcon.thumbsUp => 'assets/streamline/thumbs-up.svg',
    SlIcon.warning => 'assets/streamline/warning.svg',
    SlIcon.danger => 'assets/streamline/danger.svg',
    SlIcon.chili => 'assets/streamline/chili.svg',
    SlIcon.smile => 'assets/streamline/smile.svg',
    SlIcon.sad => 'assets/streamline/sad.svg',
    SlIcon.sick => 'assets/streamline/sick.svg',
    SlIcon.sprout => 'assets/streamline/sprout.svg',
    SlIcon.clipboard => 'assets/streamline/clipboard.svg',
    SlIcon.clock => 'assets/streamline/clock.svg',
    SlIcon.plate => 'assets/streamline/plate.svg',
    SlIcon.bolt => 'assets/streamline/bolt.svg',
    SlIcon.info => 'assets/streamline/info.svg',
    SlIcon.celebrate => 'assets/streamline/celebrate.svg',
  };
}

/// Ikon Streamline ukuran tetap, opsional diwarnai (mis. status hijau /
/// kuning / merah). Tanpa [color] → warna asli aset (hitam).
class SlIconView extends StatelessWidget {
  const SlIconView(this.icon, {super.key, this.size = 24, this.color});

  final SlIcon icon;
  final double size;

  /// Kalau diisi, seluruh ikon diwarnai [color] (tint srcIn).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color;
    return SvgPicture.asset(
      icon.assetPath,
      width: size,
      height: size,
      colorFilter: c == null
          ? null
          : ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}

/// Ikon + warna untuk level status AI / insight:
/// `info` → jempol hijau (aman), `warning` → warning kuning,
/// `alert` → danger merah.
(SlIcon, Color) slStatusIcon(BuildContext context, String level) =>
    switch (level) {
      'alert' => (SlIcon.danger, MuyesColors.red),
      'warning' => (SlIcon.warning, MuyesColors.yellow),
      'info' => (SlIcon.thumbsUp, MuyesColors.green),
      _ => (SlIcon.info, Theme.of(context).colorScheme.outline),
    };
