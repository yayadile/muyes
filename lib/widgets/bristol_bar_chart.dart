import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Bar chart distribusi Bristol (cuma yang keisi) — dipakai halaman
/// Insights (ringkasan mingguan) dan Statistik.
///
/// Kalau tidak ada yang diisi → kalimat jujur, bukan chart kosong (spec
/// §5.5: jangan anggap kosong = normal). Warna batang: hijau (3-5 normal),
/// kuning (1-2 / 6-7 — perlu diperhatikan).
class BristolBarChart extends StatelessWidget {
  const BristolBarChart({
    super.key,
    required this.distribution,
    this.emptyText,
  });

  /// Skala Bristol (1-7) → jumlah. Kosong = belum ada yang diisi.
  final Map<int, int> distribution;

  /// Teks kalau [distribution] kosong.
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) {
      return Text(
        emptyText ??
            'Bristol belum diisi — distribusi bentuk eek belum bisa dibaca. '
                'Isi Bristol biar analisanya lebih akurat.',
        style: TextStyle(
          fontFamily: kBodyFont,
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: MuyesColors.textDark.withValues(alpha: 0.6),
        ),
      );
    }

    final maxCount = distribution.values.reduce((a, b) => a > b ? a : b);
    final sorted = distribution.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribusi Bristol (cuma yang keisi)',
          style: TextStyle(
            fontFamily: kBodyFont,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: MuyesColors.textDark.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: BarChart(
            BarChartData(
              maxY: (maxCount + 1).toDouble(),
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
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
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'B${value.toInt()}',
                        style: TextStyle(
                          fontFamily: kBodyFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: MuyesColors.textDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              barGroups: [
                for (final entry in sorted)
                  BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        width: 16,
                        color: entry.key >= 6 || entry.key <= 2
                            ? MuyesColors.yellow
                            : MuyesColors.green,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
