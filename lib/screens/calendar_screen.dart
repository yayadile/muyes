import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timeline_entry.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils/date_utils.dart';
import '../utils/day_summary.dart';
import '../widgets/log_timeline.dart';
import '../widgets/streamline_icons.dart';
import '../widgets/time_field.dart';
import 'log_food_screen.dart';
import 'log_mules_screen.dart';
import 'log_poop_screen.dart';

/// Kalender bulanan: dot per tanggal (hijau/kuning/merah) + detail hari
/// kalau di-tap (spec §5.4). Gaya sama dengan Home (spec §8.1).
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final food = ref.watch(allFoodLogsProvider);
    final poop = ref.watch(allPoopLogsProvider);
    final mules = ref.watch(allMulesLogsProvider);

    final loading = food.isLoading || poop.isLoading || mules.isLoading;
    final error = food.error ?? poop.error ?? mules.error;

    return Scaffold(
      backgroundColor: MuyesColors.cream,
      appBar: AppBar(title: const Text('Kalender')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Gagal: $error'))
          : _CalendarBody(
              month: month,
              entries: <TimelineEntry>[
                ...(food.value ?? const []).map(TimelineEntry.food),
                ...(poop.value ?? const []).map(TimelineEntry.poop),
                ...(mules.value ?? const []).map(TimelineEntry.mules),
              ]..sort((a, b) => a.time.compareTo(b.time)),
            ),
    );
  }
}

class _CalendarBody extends ConsumerWidget {
  const _CalendarBody({required this.month, required this.entries});

  final DateTime month;
  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group entri per hari (key: yyyy-mm-dd).
    final byDay = <String, List<TimelineEntry>>{};
    for (final entry in entries) {
      byDay.putIfAbsent(dayKey(entry.time), () => []).add(entry);
    }

    final firstOfMonth = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Grid mulai dari Senin — weekday 1 (Sen) .. 7 (Min).
    final leadingBlanks = firstOfMonth.weekday - 1;
    final today = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: MuyesColors.primary,
                      ),
                      onPressed: () =>
                          ref.read(calendarMonthProvider.notifier).previous(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${monthNameId(month.month)} ${month.year}',
                          style: const TextStyle(
                            fontFamily: kHeadingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: MuyesColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: MuyesColors.primary,
                      ),
                      onPressed: () =>
                          ref.read(calendarMonthProvider.notifier).next(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (final dayLabel in [
                      'Sen',
                      'Sel',
                      'Rab',
                      'Kam',
                      'Jum',
                      'Sab',
                      'Min',
                    ])
                      Expanded(
                        child: Center(
                          child: Text(
                            dayLabel,
                            style: TextStyle(
                              fontFamily: kBodyFont,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: MuyesColors.textDark.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: leadingBlanks + daysInMonth,
                  itemBuilder: (context, index) {
                    if (index < leadingBlanks) return const SizedBox.shrink();
                    final dayNumber = index - leadingBlanks + 1;
                    final date = DateTime(month.year, month.month, dayNumber);
                    final dayEntries =
                        byDay[dayKey(date)] ?? const <TimelineEntry>[];
                    final status = computeDayStatus(dayEntries);
                    final isToday = isSameDay(date, today);

                    return _DayCell(
                      dayNumber: dayNumber,
                      status: status,
                      isToday: isToday,
                      onTap: () =>
                          _showDayDetail(context, date, dayEntries, ref),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Keterangan',
            style: TextStyle(
              fontFamily: kHeadingFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MuyesColors.textDark,
            ),
          ),
        ),
        const _Legend(),
      ],
    );
  }

  Future<void> _showDayDetail(
    BuildContext context,
    DateTime date,
    List<TimelineEntry> dayEntries,
    WidgetRef ref,
  ) async {
    // Pilih hari itu di Home biar bisa dilihat lengkap.
    ref.read(selectedDayProvider.notifier).select(date);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              formatDateId(date),
              style: const TextStyle(
                fontFamily: kHeadingFont,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: MuyesColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Builder(
              builder: (context) {
                final status = computeDayStatus(dayEntries);
                final (icon, color) = status == null
                    ? (SlIcon.info, MuyesColors.textDark)
                    : switch (status) {
                        DayStatus.normal => (
                          SlIcon.thumbsUp,
                          MuyesColors.green,
                        ),
                        DayStatus.waspada => (
                          SlIcon.warning,
                          MuyesColors.yellow,
                        ),
                        DayStatus.abnormal => (
                          SlIcon.danger,
                          MuyesColors.red,
                        ),
                      };
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SlIconView(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontFamily: kBodyFont,
                          fontSize: 14,
                          color: MuyesColors.textDark.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            if (dayEntries.isEmpty)
              const Text('Nggak ada log di hari ini.')
            else
              LogTimeline(
                entries: dayEntries,
                onTapEntry: (entry) async {
                  Navigator.of(context).pop();
                  await _openEdit(context, entry);
                },
                onDeleteEntry: (entry) async {
                  final confirmed = await confirmDeleteLog(
                    context,
                    entry.kind.labelId,
                  );
                  if (!confirmed) return;
                  final food = entry.food;
                  if (food != null) {
                    await ref.read(foodLogDaoProvider).deleteById(food.id);
                  } else if (entry.poop != null) {
                    await ref
                        .read(poopLogDaoProvider)
                        .deleteById(entry.poop!.id);
                  } else {
                    await ref
                        .read(mulesLogDaoProvider)
                        .deleteById(entry.mules!.id);
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, TimelineEntry entry) async {
    final food = entry.food;
    if (food != null) {
      await Navigator.of(context).push(LogFoodScreen.route(existing: food));
      return;
    }
    final poop = entry.poop;
    if (poop != null) {
      await Navigator.of(context).push(LogPoopScreen.route(existing: poop));
      return;
    }
    await Navigator.of(
      context,
    ).push(LogMulesScreen.route(existing: entry.mules!));
  }

  static String _statusLabel(DayStatus? status) => switch (status) {
    DayStatus.normal => 'Pola hari ini kelihatan normal',
    DayStatus.waspada => 'Ada yang perlu diperhatikan',
    DayStatus.abnormal => 'Ada tanda yang perlu diwaspadai',
    null => 'Belum ada catatan',
  };
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayNumber,
    required this.status,
    required this.isToday,
    required this.onTap,
  });

  final int dayNumber;
  final DayStatus? status;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (status) {
      DayStatus.normal => MuyesColors.green,
      DayStatus.waspada => MuyesColors.yellow,
      DayStatus.abnormal => MuyesColors.red,
      null => null,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(color: MuyesColors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: TextStyle(
                fontFamily: kBodyFont,
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: MuyesColors.textDark,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor ?? Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            for (final item in const [
              (MuyesColors.green, 'Normal'),
              (MuyesColors.yellow, 'Waspada'),
              (MuyesColors.red, 'Abnormal'),
            ])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.$1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontFamily: kBodyFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MuyesColors.textDark,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
