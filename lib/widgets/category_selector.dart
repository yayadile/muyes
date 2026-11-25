import 'package:flutter/material.dart';

import '../models/food_log.dart';

/// Chip multi-pilih untuk kategori makanan (spec §5.1).
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in FoodCategories.all)
          FilterChip(
            label: Text(category),
            selected: selected.contains(category),
            onSelected: (isSelected) {
              final next = Set<String>.of(selected);
              if (isSelected) {
                next.add(category);
              } else {
                next.remove(category);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}
