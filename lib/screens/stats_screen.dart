import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import '../utils/date_utils.dart';
import '../utils/stats_calculator.dart';
import '../widgets/bristol_bar_chart.dart';
import '../widgets/muyes_chip.dart';
import '../widgets/muyes_icons.dart';

/// Statistik (spec §8.1) — halaman diagram.
///
/// Semua angka dari catatan user sendiri: diagram lingkar proporsi
/// makan/eek/mules, diagram batang bertumpuk per hari, distribusi Bristol,
/// dan makanan paling sering. Bukan rekomendasi / ramalan.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(statsRangeProvider);
    final stats = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: MuyesColors.cream,
      appBar: AppBar(title: const Text('Statistik')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                for (final (value, label) in const [
                  (7, '7 hari'),
                  (30, '30 hari'),
                ]) ...[
                  MuyesChip(
                    label: label,
                    selected: range == value,
                    onTap: () => ref
                        .read(statsRangeProvider.notifier)
                        .select(value),
                  ),
                  if (value != 30) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: stats.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Gagal: $error')),
              data: (data) => _StatsBody(stats: data),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final MuyesStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.totalLogs == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MuyesIconView(MuyesIcon.muyes, size: 56),
              const SizedBox(height: 12),
              const Text(
                'Belum ada data buat diagram.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kBodyFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: MuyesColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Catat makan / eek / mules dulu, atau isi data contoh di '
                'Pengaturan → Data Contoh.',
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _SummaryCard(stats: stats),
        const SizedBox(height: 16),
        _DonutCard(stats: stats),
        const SizedBox(height: 16),
        _PerDayCard(stats: stats),
        const SizedBox(height: 16),
        _BristolCard(stats: stats),
        const SizedBox(height: 16),
        _TopFoodsCard(stats: stats),
      ],
    );
  }
}

/// Kartu ringkasan angka: total + rata-rata per hari (pembaginya hari
/// yang ada catatan, biar jujur kalau cuma nyatat sebagian hari).
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats});

  final MuyesStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    value: '${stats.totalFood}',
                    label: 'Makan',
                    icon: MuyesIcon.meal,
                  ),
                ),
                Expanded(
                  child: _StatBox(
                    value: '${stats.totalPoop}',
                    label: 'Eek',
                    icon: MuyesIcon.poop,
                  ),
                ),
                Expanded(
                  child: _StatBox(
                    value: '${stats.totalMules}',
                    label: 'Mules',
                    icon: MuyesIcon.muyes,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: MuyesColors.primary.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 10),
            Text(
              '${stats.days} hari terakhir: ${stats.totalLogs} catatan · '
              'tercatat di ${stats.daysWithData} dari ${stats.days} hari · '
              'rata-rata ${stats.avgFoodPerDay.toStringAsFixed(1)} makan, '
              '${stats.avgPoopPerDay.toStringAsFixed(1)} eek, '
              '${stats.avgMulesPerDay.toStringAsFixed(1)} mules per hari '
              '(dihitung dari hari yang tercatat).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kBodyFont,
                fontSize: 12.5,
                height: 1.45,
                color: MuyesColors.textDark.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final MuyesIcon icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MuyesIconView(icon, size: 40),
        const SizedBox(height: 4),
        Text(
          value,
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
    );
  }
}

/// Warna identitas per jenis log (konsisten di semua diagram halaman ini).
abstract final class StatsColors {
  static const food = MuyesColors.primary; // orange
  static const poop = Color(0xFFB05800); // coklat eek
  static const mules = Color(0xFF7BC67E); // hijau mules
}

/// Diagram lingkar (donut): proporsi Makan / Eek / Mules.
class _DonutCard extends StatelessWidget {
  const _DonutCard({required this.stats});

  final MuyesStats stats;

  @override
  Widget build(BuildContext context) {
    final sections = <(String, int, Color)>[
      ('Makan', stats.totalFood, StatsColors.food),
      ('Eek', stats.totalPoop, StatsColors.poop),
      ('Mules', stats.totalMules, StatsColors.mules),
    ];

    return _StatsChartCard(
      title: 'Proporsi Catatan',
      subtitle: 'Perbandingan jumlah catatan makan / eek / mules '
          '${stats.days} hari terakhir.',
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 34,
                sectionsSpace: 3,
                startDegreeOffset: -90,
                sections: [
                  for (final (label, count, color) in sections)
                    if (count > 0)
                      PieChartSectionData(
                        value: count.toDouble(),
                        color: color,
                        radius: 24,
                        showTitle: false,
                        title: '$label: $count',
                        titleStyle: const TextStyle(
                          fontFamily: kBodyFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (label, count, color) in sections) ...[
                  _LegendRow(
                    color: color,
                    label: label,
                    value: '$count',
                    percent: stats.totalLogs == 0
                        ? '0%'
                        : '${(count * 100 / stats.totalLogs).round()}%',
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });

  final Color color;
  final String label;
  final String value;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: MuyesColors.textDark.withValues(alpha: 0.15),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: kBodyFont,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: MuyesColors.textDark,
            ),
          ),
        ),
        Text(
          '$value · $percent',
          style: TextStyle(
            fontFamily: kBodyFont,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: MuyesColors.textDark.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Diagram batang bertumpuk: jumlah catatan per hari.
class _PerDayCard extends StatelessWidget {
  const _PerDayCard({required this.stats});

  final MuyesStats stats;

  @override
  Widget build(BuildContext context) {
    final perDay = stats.perDay;
    final maxTotal = perDay.fold<int>(0, (a, d) => d.total > a ? d.total : a);

    return _StatsChartCard(
      title: 'Catatan per Hari',
      subtitle: 'Batang bertumpuk: orange makan, coklat eek, hijau mules.',
      child: SizedBox(
        height: 170,
        child: BarChart(
          BarChartData(
            maxY: (maxTotal + 1).toDouble(),
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => MuyesColors.textDark,
                maxContentWidth: 120,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final day = perDay[group.x];
                  return BarTooltipItem(
                    '${formatDateId(day.day)}\n'
                    'makan ${day.food} · eek ${day.poop} · mules ${day.mules}',
                    const TextStyle(
                      fontFamily: kBodyFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value != value.roundToDouble()) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        fontFamily: kBodyFont,
                        fontSize: 10,
                        color: MuyesColors.textDark.withValues(alpha: 0.55),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= perDay.length) {
                      return const SizedBox.shrink();
                    }
                    final day = perDay[index].day;
                    // 30 hari: label tiap 5 hari biar nggak berdesakan.
                    final showEvery = stats.days > 14 ? 5 : 1;
                    final fromEnd = perDay.length - 1 - index;
                    if (showEvery != 1 && fromEnd % showEvery != 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        weekdayShortId(day),
                        style: TextStyle(
                          fontFamily: kBodyFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: MuyesColors.textDark.withValues(alpha: 0.7),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < perDay.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: perDay[i].total.toDouble(),
                      width: stats.days > 14 ? 6 : 14,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                      rodStackItems: _stackItems(perDay[i]),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Item tumpukan: makan (bawah) → eek → mules (atas).
  static List<BarChartRodStackItem> _stackItems(StatsDayCounts day) {
    final items = <BarChartRodStackItem>[];
    var from = 0.0;
    void add(int count, Color color) {
      if (count <= 0) return;
      final to = from + count;
      items.add(BarChartRodStackItem(from, to, color));
      from = to;
    }

    add(day.food, StatsColors.food);
    add(day.poop, StatsColors.poop);
    add(day.mules, StatsColors.mules);
    return items;
  }
}

/// Distribusi Bristol — pakai chart bersama [BristolBarChart].
class _BristolCard extends StatelessWidget {
  const _BristolCard({required this.stats});

  final MuyesStats stats;

  @override
  Widget build(BuildContext context) {
    return _StatsChartCard(
      title: 'Bentuk Eek (Bristol)',
      subtitle: stats.bristolFilled == 0
          ? null
          : '${stats.bristolFilled} dari ${stats.totalPoop} log eek '
                'Bristol-nya keisi. B3-B5 = rentang normal, B1-B2 keras, '
                'B6-B7 cenderung cair.',
      child: BristolBarChart(
        distribution: stats.bristolDistribution,
        emptyText: stats.totalPoop == 0
            ? 'Belum ada data eek di rentang ini.'
            : 'Bristol belum diisi di rentang ini — distribusi bentuk eek '
                  'belum bisa dibaca. Isi Bristol biar diagramnya muncul.',
      ),
    );
  }
}

/// Top 5 makanan paling sering.
class _TopFoodsCard extends StatelessWidget {
  const _TopFoodsCard({required this.stats});

  final MuyesStats stats;

  @override
  Widget build(BuildContext context) {
    final top = stats.topFoods;
    if (top.isEmpty) return const SizedBox.shrink();

    final maxCount = top.first.count;
    return _StatsChartCard(
      title: 'Makanan Paling Sering',
      subtitle: 'Top ${top.length} dari ${stats.totalFood} catatan makan.',
      child: Column(
        children: [
          for (var i = 0; i < top.length; i++) ...[
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    top[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: kBodyFont,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: MuyesColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: top[i].count / maxCount,
                      minHeight: 10,
                      backgroundColor: MuyesColors.primary.withValues(
                        alpha: 0.15,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        MuyesColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${top[i].count}x',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: kBodyFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: MuyesColors.textDark.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
            if (i != top.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Kartu dasar diagram: judul + subjudul + isi.
class _StatsChartCard extends StatelessWidget {
  const _StatsChartCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: kHeadingFont,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: MuyesColors.textDark,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: kBodyFont,
                  fontSize: 12.5,
                  height: 1.4,
                  color: MuyesColors.textDark.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
