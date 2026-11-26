import 'package:flutter/material.dart';

import '../theme.dart';

/// Chip filter gaya Duolingo — putih, border orange saat tidak aktif,
/// orange penuh saat dipilih (spec §8.1). Dipakai Riwayat + Statistik.
class MuyesChip extends StatelessWidget {
  const MuyesChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? MuyesColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MuyesColors.primary, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kHeadingFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : MuyesColors.textDark,
          ),
        ),
      ),
    );
  }
}
