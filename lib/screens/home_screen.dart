import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timeline_entry.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils/date_utils.dart';
import '../widgets/duo_button.dart';
import '../widgets/log_timeline.dart';
import '../widgets/muyes_icons.dart';
import '../widgets/time_field.dart';
import 'log_food_screen.dart';
import 'log_mules_screen.dart';
import 'log_poop_screen.dart';

/// Home / Hari Ini (spec §5.3 + mock §8.1).
///
/// Header orange "Hari Ini" + tanggal → kartu stats (count + terakhir) →
/// kartu aksi (+ Eek / + Makan / + Mules) → timeline hari ini.
/// Kartu "Status perut / Status makan (dari AI)" nyusul di Phase 5.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final isToday = isSameDay(day, DateTime.now());
    final timeline = ref.watch(dayTimelineProvider);

    return Scaffold(
      backgroundColor: MuyesColors.cream,
      body: Column(
        children: [
          _HomeHeader(day: day, isToday: isToday),
          Expanded(
            child: timeline.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Gagal: $error')),
              data: (entries) => _HomeBody(entries: entries),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header orange: "Hari Ini" + tanggal lengkap putih bold (spec §8.1).
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.day, required this.isToday});

  final DateTime day;
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: MuyesColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Hari Ini' : formatDateId(day),
                      style: headerHeadingStyle(size: 30),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatFullDateId(day),
                      style: const TextStyle(
                        fontFamily: kBodyFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isToday)
                IconButton(
                  tooltip: 'Balik ke hari ini',
                  icon: const Icon(Icons.today, color: Colors.white),
                  onPressed: () =>
                      ref.read(selectedDayProvider.notifier).goToToday(),
                ),
              IconButton(
                tooltip: 'Ganti hari',
                icon: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                ),
                onPressed: () => _pickDay(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDay(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      ref.read(selectedDayProvider.notifier).select(picked);
    }
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodCount = entries.where((e) => e.food != null).length;
    final poopCount = entries.where((e) => e.poop != null).length;
    final mulesCount = entries.where((e) => e.mules != null).length;

    final lastFood = _lastTime(entries, (e) => e.food != null);
    final lastPoop = _lastTime(entries, (e) => e.poop != null);
    final lastMules = _lastTime(entries, (e) => e.mules != null);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        _StatsCard(
          foodCount: foodCount,
          poopCount: poopCount,
          mulesCount: mulesCount,
          lastFood: lastFood,
          lastPoop: lastPoop,
          lastMules: lastMules,
        ),
        const SizedBox(height: 16),
        const _ActionCard(),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Timeline Hari Ini',
            style: TextStyle(
              fontFamily: kHeadingFont,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: MuyesColors.textDark,
            ),
          ),
        ),
        LogTimeline(
          entries: entries,
          onTapEntry: (entry) => _openEdit(context, ref, entry),
          onDeleteEntry: (entry) => _deleteEntry(context, ref, entry),
        ),
      ],
    );
  }

  static DateTime? _lastTime(
    List<TimelineEntry> entries,
    bool Function(TimelineEntry) test,
  ) {
    DateTime? last;
    for (final entry in entries) {
      if (test(entry) && (last == null || entry.time.isAfter(last))) {
        last = entry.time;
      }
    }
    return last;
  }

  Future<void> _openEdit(
    BuildContext context,
    WidgetRef ref,
    TimelineEntry entry,
  ) async {
    final food = entry.food;
    if (food != null) {
      await Navigator.of(
        context,
      ).push(LogFoodScreen.route(existing: food));
      return;
    }
    final poop = entry.poop;
    if (poop != null) {
      await Navigator.of(
        context,
      ).push(LogPoopScreen.route(existing: poop));
      return;
    }
    await Navigator.of(
      context,
    ).push(LogMulesScreen.route(existing: entry.mules!));
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    TimelineEntry entry,
  ) async {
    final confirmed = await confirmDeleteLog(context, entry.kind.labelId);
    if (!confirmed) return;

    final food = entry.food;
    if (food != null) {
      await ref.read(foodLogDaoProvider).deleteById(food.id);
      return;
    }
    final poop = entry.poop;
    if (poop != null) {
      await ref.read(poopLogDaoProvider).deleteById(poop.id);
      return;
    }
    await ref.read(mulesLogDaoProvider).deleteById(entry.mules!.id);
  }
}

/// Kartu stats (spec §8.1): 3 ikon + count hari ini dari DB,
/// lalu baris Terakhir Makan / Terakhir Eek / Terakhir Mules — waktu
/// asli atau "-".
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.foodCount,
    required this.poopCount,
    required this.mulesCount,
    required this.lastFood,
    required this.lastPoop,
    required this.lastMules,
  });

  final int foodCount;
  final int poopCount;
  final int mulesCount;
  final DateTime? lastFood;
  final DateTime? lastPoop;
  final DateTime? lastMules;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _StatCount(
                  icon: MuyesIcon.poop,
                  label: 'Eek',
                  count: poopCount,
                ),
                _StatCount(
                  icon: MuyesIcon.meal,
                  label: 'Makan',
                  count: foodCount,
                ),
                _StatCount(
                  icon: MuyesIcon.muyes,
                  label: 'Mules',
                  count: mulesCount,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: MuyesColors.primary.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            _LastRow(label: 'Terakhir Makan', time: lastFood),
            const SizedBox(height: 8),
            _LastRow(label: 'Terakhir Eek', time: lastPoop),
            const SizedBox(height: 8),
            _LastRow(label: 'Terakhir Mules', time: lastMules),
          ],
        ),
      ),
    );
  }
}

class _StatCount extends StatelessWidget {
  const _StatCount({
    required this.icon,
    required this.label,
    required this.count,
  });

  final MuyesIcon icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          MuyesIconView(icon, size: 44),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(
              fontFamily: kHeadingFont,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: MuyesColors.textDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: kBodyFont,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MuyesColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris "Terakhir Makan | Hari ini, 19:56" — pakai kata Hari ini/Kemarin
/// untuk rentang hari ini/kemarin, tanggal lengkap kalau lebih lama
/// (koreksi user 25 Nov 2026). "-" kalau belum ada log — bukan data palsu.
class _LastRow extends StatelessWidget {
  const _LastRow({required this.label, required this.time});

  final String label;
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: kBodyFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MuyesColors.textDark,
            ),
          ),
        ),
        Text(
          time == null ? '-' : formatLastTimeId(time!),
          style: const TextStyle(
            fontFamily: kBodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: MuyesColors.textDark,
          ),
        ),
      ],
    );
  }
}

/// Kartu aksi (spec §8.1): judul + divider orange tipis +
/// 3 tombol + Eek / + Makan / + Mules (ikon SVG di atas, label di bawah).
class _ActionCard extends StatelessWidget {
  const _ActionCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          children: [
            const Text(
              'Catat makan, eek, dan mules!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kHeadingFont,
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: MuyesColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: MuyesColors.primary.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _QuickButton(
                    icon: MuyesIcon.poop,
                    label: '+ Eek',
                    onTap: () => Navigator.of(context)
                        .push(LogPoopScreen.route()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickButton(
                    icon: MuyesIcon.meal,
                    label: '+ Makan',
                    onTap: () => Navigator.of(context)
                        .push(LogFoodScreen.route()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickButton(
                    icon: MuyesIcon.muyes,
                    label: '+ Mules',
                    onTap: () => Navigator.of(context)
                        .push(LogMulesScreen.route()),
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

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final MuyesIcon icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DuoButton.secondary(
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MuyesIconView(icon, size: 48),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: kHeadingFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MuyesColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
