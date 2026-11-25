import 'package:flutter/material.dart';

import '../models/mules_log.dart';

/// Pilih level mules dengan 4 chip cepat (spec §5.2b).
///
/// UI menampilkan kata (Ringan / Sedang / Parah / Nggak mules),
/// bukan angka 0-5.
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
                    : Text(_emoji(level)),
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

  static String _emoji(int level) => switch (level) {
    <= 2 => '🙂',
    3 => '😖',
    _ => '😫',
  };

  static String _hint(int level) => switch (level) {
    0 => 'Oke, dicatat kalau perutmu udah nggak mules.',
    <= 2 => 'Mules ringan — masih bisa lanjut aktivitas.',
    3 => 'Mules sedang — lumayan ganggu.',
    _ => 'Mules parah — kalau makin sering, cek pemicunya di Insight ya.',
  };
}
