import 'package:flutter/material.dart';

import '../models/food_log.dart';
import '../models/mules_log.dart';
import '../models/timeline_entry.dart';
import '../theme.dart';
import '../utils/date_utils.dart';
import 'muyes_icons.dart';
import 'streamline_icons.dart';

/// Timeline — gabungan makan + eek + mules, urut waktu (spec §5.3).
///
/// Ikon pakai aset SVG Muyes: meal.svg / poop.svg / muyes.svg (spec §8.1).
/// MulesLog tetap beda ikon dari eek (spec §5.2b).
class LogTimeline extends StatelessWidget {
  const LogTimeline({
    super.key,
    required this.entries,
    this.onTapEntry,
    this.onDeleteEntry,
  });

  final List<TimelineEntry> entries;
  final ValueChanged<TimelineEntry>? onTapEntry;
  final ValueChanged<TimelineEntry>? onDeleteEntry;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _EmptyTimeline();
    }
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            _TimelineTile(
              entry: entries[i],
              onTap: onTapEntry,
              onDelete: onDeleteEntry,
            ),
            if (i != entries.length - 1)
              const Divider(height: 1, indent: 64, endIndent: 12),
          ],
        ],
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SlIconView(SlIcon.sprout, size: 36),
            const SizedBox(height: 8),
            const Text(
              'Belum ada catatan hari ini.',
              style: TextStyle(
                fontFamily: kBodyFont,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: MuyesColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mulai dari "+ Eek", "+ Makan", atau "+ Mules" di atas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kBodyFont,
                fontSize: 13,
                color: MuyesColors.textDark.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.entry, this.onTap, this.onDelete});

  final TimelineEntry entry;
  final ValueChanged<TimelineEntry>? onTap;
  final ValueChanged<TimelineEntry>? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: onTap == null ? null : () => onTap!(entry),
      onLongPress: onDelete == null ? null : () => onDelete!(entry),
      leading: _LeadingIcon(entry: entry),
      title: Text(
        _title(entry),
        style: const TextStyle(
          fontFamily: kBodyFont,
          fontWeight: FontWeight.w700,
          color: MuyesColors.textDark,
        ),
      ),
      subtitle: Text(
        '${formatTimeId(entry.time)} · ${_subtitle(entry)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: kBodyFont,
          color: MuyesColors.textDark.withValues(alpha: 0.6),
        ),
      ),
      trailing: onDelete == null
          ? null
          : IconButton(
              tooltip: 'Hapus',
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: MuyesColors.textDark.withValues(alpha: 0.35),
              ),
              onPressed: () => onDelete!(entry),
            ),
    );
  }

  static String _title(TimelineEntry entry) {
    final food = entry.food;
    if (food != null) return food.foodName;
    final poop = entry.poop;
    if (poop != null) {
      final bristol = poop.bristol;
      return bristol == null ? 'Eek' : 'Eek · Bristol $bristol';
    }
    final mules = entry.mules!;
    return 'Mules ${MulesLevel.labelFor(mules.painLevel)}';
  }

  static String _subtitle(TimelineEntry entry) {
    final food = entry.food;
    if (food != null) {
      final parts = <String>[
        if (food.categories.isNotEmpty) food.categories.join(', '),
        if (food.spicyLevel > 0) 'pedas ${food.spicyLevel}/5',
        food.portion,
        if (food.drink?.isNotEmpty ?? false) food.drink!,
      ];
      return parts.join(' · ');
    }
    final poop = entry.poop;
    if (poop != null) {
      final parts = <String>[
        if (poop.color != null) poop.color!,
        if (poop.hasBlood == true) 'ada darah',
        if (poop.painLevel != null && poop.painLevel! > 0)
          'mules ${MulesLevel.labelFor(poop.painLevel!).toLowerCase()}',
        if (poop.note?.isNotEmpty ?? false) poop.note!,
      ];
      return parts.isEmpty ? 'Detail nggak diisi' : parts.join(' · ');
    }
    final mules = entry.mules!;
    final note = mules.note;
    return (note == null || note.isEmpty) ? 'Kejadian mules' : note;
  }
}

/// Ikon per jenis log dari aset SVG Muyes (spec §8.1) — tanpa emoji.
class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final icon = switch (entry.kind) {
      TimelineKind.food => MuyesIcon.meal,
      TimelineKind.poop => MuyesIcon.poop,
      TimelineKind.mules => MuyesIcon.muyes,
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: MuyesColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(6),
      child: MuyesIconView(icon, size: 32),
    );
  }
}

/// Chip warna kecil sesuai status perut hari ini (dipakai Home).
Color statusColor(BuildContext context, String level) => switch (level) {
  'alert' => MuyesColors.red,
  'warning' => MuyesColors.yellow,
  'info' => MuyesColors.green,
  _ => Theme.of(context).colorScheme.outline,
};

/// Format "terakhir makan jam X" — kosong kalau belum ada.
String? lastTimeLabel(DateTime? time) =>
    time == null ? null : 'jam ${formatTimeId(time)}';

/// Ambil [FoodLog] terbaru dari daftar (sudah urut naik).
FoodLog? latestFood(List<FoodLog> logs) => logs.isEmpty ? null : logs.last;
