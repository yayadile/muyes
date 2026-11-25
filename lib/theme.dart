import 'package:flutter/material.dart';

/// Palet + tema Muyes gaya Duolingo (spec §8.1).
///
/// Satu warna utama dominan (orange Muyes). Hijau/kuning/merah HANYA
/// untuk level waspada, bukan warna utama.
abstract final class MuyesColors {
  /// Orange utama — header, bottom nav, border tombol (spec §8.1).
  static const primary = Color(0xFFFFA63D);

  /// Orange lebih gelap — bottom shadow 3D tombol (spec §8.1).
  static const primaryDark = Color(0xFFE08A1E);

  /// Orange terang — aksen lembut.
  static const primaryLight = Color(0xFFFFC46B);

  /// Cream — background bawah / body (spec §8.1).
  static const cream = Color(0xFFFFF6E8);

  /// Kartu putih.
  static const card = Color(0xFFFFFFFF);

  /// Teks gelap.
  static const textDark = Color(0xFF222222);

  /// Level waspada (dipakai HANYA untuk status).
  static const green = Color(0xFF2E7D32);
  static const yellow = Color(0xFFB8860B);
  static const red = Color(0xFFC0392B);
}

/// Font rounded playful untuk judul (spec §8.1).
const kHeadingFont = 'Fredoka';

/// Font body rounded untuk isi (spec §8.1).
const kBodyFont = 'Nunito';

/// Tema global app — semua screen pakai ini.
ThemeData buildMuyesTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: MuyesColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: MuyesColors.primary,
    onPrimary: Colors.white,
    surface: MuyesColors.cream,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MuyesColors.cream,
    fontFamily: kBodyFont,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: kBodyFont,
      bodyColor: MuyesColors.textDark,
      displayColor: MuyesColors.textDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: MuyesColors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: kHeadingFont,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: const CardThemeData(
      color: MuyesColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MuyesColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: kHeadingFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MuyesColors.textDark,
        side: const BorderSide(color: MuyesColors.primary, width: 2),
        textStyle: const TextStyle(
          fontFamily: kHeadingFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MuyesColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: MuyesColors.primary.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: MuyesColors.primary.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MuyesColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(fontFamily: kBodyFont),
      hintStyle: TextStyle(
        fontFamily: kBodyFont,
        color: MuyesColors.textDark.withValues(alpha: 0.4),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: MuyesColors.card,
      selectedColor: MuyesColors.primary.withValues(alpha: 0.18),
      side: BorderSide(color: MuyesColors.primary.withValues(alpha: 0.35)),
      labelStyle: const TextStyle(
        fontFamily: kBodyFont,
        fontWeight: FontWeight.w600,
        color: MuyesColors.textDark,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: MuyesColors.textDark,
      contentTextStyle: TextStyle(fontFamily: kBodyFont, color: Colors.white),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MuyesColors.cream,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: MuyesColors.cream,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      titleTextStyle: TextStyle(
        fontFamily: kHeadingFont,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: MuyesColors.textDark,
      ),
    ),
  );
}

/// Style judul header — putih bold untuk di atas orange (spec §8.1).
TextStyle headerHeadingStyle({double size = 32}) => TextStyle(
  fontFamily: kHeadingFont,
  fontSize: size,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

/// Style judul section di atas cream (judul kartu, dsb).
TextStyle sectionHeadingStyle(BuildContext context, {double size = 18}) =>
    TextStyle(
      fontFamily: kHeadingFont,
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: MuyesColors.textDark,
    );
