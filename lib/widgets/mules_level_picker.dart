import 'package:flutter/material.dart';

import '../models/mules_log.dart';
import 'streamline_icons.dart';

/// Pilih level mules dengan 4 chip cepat (spec §5.2b).
///
/// UI menampilkan kata (Ringan / Sedang / Parah / Nggak mules),
/// bukan angka 0-5. Ikon muka dari Streamline (bukan emoji — koreksi
/// user, 26 Nov 2026): 🙂 smile → 😖 sad → 😫 sick.
class MulesLevelPicker extends StatelessWidget {
  const MulesLevelPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Nilai 0-5, atau null kalau belum dipilih.
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final level in MulesLevel.chips)
              ChoiceChip(
                label: Text(MulesLevel.labelFor(level)),
                selected: value == level,
                onSelected: (_) => onChanged(level),
                avatar: level == 0
                    ? const Icon(Icons.check_circle_outline, size: 18)
                    : SlIconView(
                        _face(level),
                        size: 18,
                        color: _faceColor(level),
                      ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value == null
              ? 'Pilih seberapa mules perutmu. Kalau udah baikan, pilih "Nggak mules".'
              : _hint(value!),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  static SlIcon _face(int level) => switch (level) {
    <= 2 => SlIcon.smile,
    3 => SlIcon.sad,
    _ => SlIcon.sick,
  };

  static Color _faceColor(int level) => switch (level) {
    <= 2 => const Color(0xFF2E7D32), // hijau — mules ringan
    3 => const Color(0xFFB8860B), // kuning — sedang
    _ => const Color(0xFFC0392B), // merah — parah
  };

  static String _hint(int level) => switch (level) {
    0 => 'Oke, dicatat kalau perutmu udah nggak mules.',
    <= 2 => 'Mules ringan — masih bisa lanjut aktivitas.',
    3 => 'Mules sedang — lumayan ganggu.',
    _ => 'Mules parah — kalau makin sering, cek pemicunya di Insight ya.',
  };
}
