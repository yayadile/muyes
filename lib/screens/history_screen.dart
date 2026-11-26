import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/food_log.dart';
import '../models/mules_log.dart';
import '../models/poop_log.dart';
import '../models/timeline_entry.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils/date_utils.dart';
import '../widgets/log_timeline.dart';
import '../widgets/muyes_chip.dart';
import '../widgets/time_field.dart';
import 'calendar_screen.dart';
import 'log_food_screen.dart';
import 'log_mules_screen.dart';
import 'log_poop_screen.dart';
import 'stats_screen.dart';

/// Filter daftar riwayat (spec §5.4).
enum HistoryFilter { semua, makan, eek, mules }

/// Riwayat: list semua log + filter + search makanan (spec §5.4).
///
/// Gaya sama dengan Home (spec §8.1): header orange, kartu putih 24dp.
/// Kalender dibuka dari tombol di header.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  var _filter = HistoryFilter.semua;
  var _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = ref.watch(allFoodLogsProvider);
    final poop = ref.watch(allPoopLogsProvider);
    final mules = ref.watch(allMulesLogsProvider);

    final loading = food.isLoading || poop.isLoading || mules.isLoading;
    final error = food.error ?? poop.error ?? mules.error;

    return Scaffold(
      backgroundColor: MuyesColors.cream,
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            tooltip: 'Statistik',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          IconButton(
            tooltip: 'Kalender',
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CalendarScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari makanan / catatan (mis. "sambal")',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                      ),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _search = value.trim()),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final (value, label) in const [
                  (HistoryFilter.semua, 'Semua'),
                  (HistoryFilter.makan, 'Makan'),
                  (HistoryFilter.eek, 'Eek'),
                  (HistoryFilter.mules, 'Mules'),
                ]) ...[
                  MuyesChip(
                    label: label,
                    selected: _filter == value,
                    onTap: () => setState(() => _filter = value),
                  ),
                  if (value != HistoryFilter.mules) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(child: Text('Gagal: $error'))
                : _buildList(
                    food.value ?? const [],
                    poop.value ?? const [],
                    mules.value ?? const [],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    List<FoodLog> food,
    List<PoopLog> poop,
    List<MulesLog> mules,
  ) {
    var entries = <TimelineEntry>[
      if (_filter == HistoryFilter.semua || _filter == HistoryFilter.makan)
        ...food.map(TimelineEntry.food),
      if (_filter == HistoryFilter.semua || _filter == HistoryFilter.eek)
        ...poop.map(TimelineEntry.poop),
      if (_filter == HistoryFilter.semua || _filter == HistoryFilter.mules)
        ...mules.map(TimelineEntry.mules),
    ];

    // Search makanan (spec §5.4) — cari di nama, kategori, minuman, catatan.
    if (_search.isNotEmpty) {
      final needle = _search.toLowerCase();
      entries = entries.where((entry) {
        final log = entry.food;
        if (log == null) return false;
        return log.foodName.toLowerCase().contains(needle) ||
            log.categories.any((c) => c.toLowerCase().contains(needle)) ||
            (log.drink?.toLowerCase().contains(needle) ?? false) ||
            (log.note?.toLowerCase().contains(needle) ?? false);
      }).toList(growable: false);
    }

    entries.sort((a, b) => b.time.compareTo(a.time));

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _search.isNotEmpty
                ? 'Nggak ada log yang cocok dengan "$_search".'
                : 'Belum ada log. Mulai catat dari Beranda ya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kBodyFont,
              fontSize: 15,
              color: MuyesColors.textDark.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    // Group per hari (terbaru dulu).
    final groups = <String, List<TimelineEntry>>{};
    for (final entry in entries) {
      groups.putIfAbsent(dayKey(entry.time), () => []).add(entry);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
      children: [
        for (final group in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
            child: Text(
              formatDateId(group.value.first.time),
              style: const TextStyle(
                fontFamily: kHeadingFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MuyesColors.textDark,
              ),
            ),
          ),
          LogTimeline(
            entries: group.value.reversed.toList(growable: false),
            onTapEntry: _openEdit,
            onDeleteEntry: _deleteEntry,
          ),
        ],
      ],
    );
  }

  Future<void> _openEdit(TimelineEntry entry) async {
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

  Future<void> _deleteEntry(TimelineEntry entry) async {
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

/// Chip filter gaya Duolingo — pakai [MuyesChip] (widget bersama di
/// `widgets/muyes_chip.dart`).
