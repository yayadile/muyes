import 'package:flutter/material.dart';

import 'streamline_icons.dart';

/// Pilih level pedas 0-5 (spec §5.1). 0 = tidak pedas.
///
/// Ikon cabe dari Streamline (bukan emoji 🌶️ lagi — koreksi user,
/// 26 Nov 2026), diwarnai merah biar kebaca sebagai "pedas".
class SpicyPicker extends StatelessWidget {
  const SpicyPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _chiliColor = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var level = 0; level <= 5; level++)
              ChoiceChip(
                label: Text('$level'),
                selected: value == level,
                onSelected: (_) => onChanged(level),
                avatar: level > 0
                    ? const SlIconView(
                        SlIcon.chili,
                        size: 16,
                        color: _chiliColor,
                      )
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (value > 0) ...[
              for (var i = 0; i < value; i++)
                const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: SlIconView(
                    SlIcon.chili,
                    size: 16,
                    color: _chiliColor,
                  ),
                ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                value == 0
                    ? '0 = nggak pedas'
                    : 'level $value — ${_spicyDescription(value)}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _spicyDescription(int level) => switch (level) {
    1 => 'sedikit nendang',
    2 => 'lumayan pedas',
    3 => 'pedas',
    4 => 'pedas banget',
    5 => 'gila pedesnya',
    _ => '-',
  };
}
