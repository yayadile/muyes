import 'package:flutter/material.dart';

/// Pilih level pedas 0-5 (spec §5.1). 0 = tidak pedas.
class SpicyPicker extends StatelessWidget {
  const SpicyPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

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
                    ? Text('🌶️', style: theme.textTheme.bodySmall)
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value == 0
              ? '0 = nggak pedas'
              : '${'🌶️' * value} level $value — ${_spicyDescription(value)}',
          style: theme.textTheme.bodySmall,
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
