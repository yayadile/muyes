import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/ai_types.dart';
import '../ai/analyzer.dart';
import '../ai/weekly_summary.dart';
import '../models/insight.dart';
import '../models/timeline_entry.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/insight_card.dart';
import '../widgets/log_timeline.dart';
import 'log_food_screen.dart';
import 'log_mules_screen.dart';
import 'log_poop_screen.dart';

/// Halaman Insights (spec §5.5) — semua analisa AI lokal.
///
/// Struktur: Ringkasan Mingguan (otomatis) di atas, lalu 2 section
/// TERPISAH sesuai spec: "Pola Makan" (dari FoodLog) dan "Pola Eek"
/// (abnormal + korelasi). Tiap kartu bisa dibuka "Kenapa AI bilang ini?"
/// untuk lihat data mentahnya.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(aiInputProvider);
    final analysis = ref.watch(aiAnalysisProvider);

    return Scaffold(
      backgroundColor: MuyesColors.cream,
      appBar: AppBar(title: const Text('Insights')),
      body: input.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal: $error')),
        data: (data) => analysis.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Gagal: $error')),
          data: (ai) => _InsightsBody(input: data, analysis: ai),
        ),
      ),
    );
  }
}

class _InsightsBody extends ConsumerWidget {
  const _InsightsBody({required this.input, required this.analysis});

  final MuyesAiInput input;
  final AiAnalysis analysis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(aiWeeklySummaryProvider).value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (analysis.dataNote != null) ...[
          _DataNoteCard(note: analysis.dataNote!),
          const SizedBox(height: 16),
        ],
        if (summary != null) ...[
          _WeeklySummaryCard(input: input, summary: summary),
          const SizedBox(height: 20),
        ],
        _SectionHeader(
          title: 'Pola Makan',
          subtitle: 'Dari catatan makan kamu — nggak butuh data eek.',
        ),
        const SizedBox(height: 8),
        ..._insightCards(
          context,
          input,
          analysis.patternInsights,
          emptyText: 'Belum ada pola makan yang bisa dibaca.',
        ),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Pola Eek',
          subtitle: 'Deteksi abnormal + kemungkinan pemicu dari catatanmu.',
        ),
        const SizedBox(height: 8),
        ..._insightCards(
          context,
          input,
          _dedupeCorrelations(analysis.poopInsights),
          emptyText: 'Belum ada pola eek yang bisa dibaca. Catat eek dulu ya.',
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Semua analisa jalan lokal di HP-mu. Nggak ada data yang dikirim '
            'ke internet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kBodyFont,
              fontSize: 12,
              color: MuyesColors.textDark.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
  }

  /// Korelasi 7 & 30 hari buat pemicu yang sama = kartu kembar di UI.
  /// Tampilkan versi 7 hari (paling relevan); versi 30 hari cuma dipakai
  /// kalau versi 7-harinya nggak lolos syarat minimum (spec §5.5A).
  static List<Insight> _dedupeCorrelations(List<Insight> insights) {
    final sevenDayTitles = insights
        .where((i) => i.type == InsightType.correlation && i.periodDays == 7)
        .map((i) => i.title)
        .toSet();
    return [
      for (final insight in insights)
        if (insight.type != InsightType.correlation ||
            insight.periodDays == 7 ||
            !sevenDayTitles.contains(insight.title))
          insight,
    ];
  }

  List<Widget> _insightCards(
    BuildContext context,
    MuyesAiInput input,
    List<Insight> insights, {
    required String emptyText,
  }) {
    if (insights.isEmpty) {
      return [_EmptySectionCard(text: emptyText)];
    }

    // Urutkan: alert dulu, lalu warning, lalu info — yang penting di atas.
    final order = {
      InsightLevel.alert: 0,
      InsightLevel.warning: 1,
      InsightLevel.info: 2,
    };
    final sorted = [...insights]
      ..sort(
        (a, b) => (order[a.level] ?? 3).compareTo(order[b.level] ?? 3),
      );

    return [
      for (final insight in sorted) ...[
        InsightCard(
          insight: insight,
          onWhyPressed: () => _openWhy(context, insight),
        ),
        const SizedBox(height: 10),
      ],
    ];
  }

  /// "Kenapa AI bilang ini?" — buka data mentah yang jadi bukti (spec §5.5).
  void _openWhy(BuildContext context, Insight insight) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WhySheet(input: input, insight: insight),
    );
  }
}

/// Kartu jujur kalau data masih sedikit (spec §5.5 "Aturan AI").
class _DataNoteCard extends StatelessWidget {
  const _DataNoteCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MuyesColors.primaryLight.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                note,
                style: const TextStyle(
                  fontFamily: kBodyFont,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: MuyesColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: kHeadingFont,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: MuyesColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: kBodyFont,
            fontSize: 13,
            color: MuyesColors.textDark.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: kBodyFont,
            fontSize: 14,
            color: MuyesColors.textDark.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

/// Kartu ringkasan mingguan terstruktur (spec §5.5C): angka + jam makan,
/// bar chart Bristol, makanan sering, 1 insight utama.
class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.input, required this.summary});

  final MuyesAiInput input;
  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    final mainLine = mainInsightLine(input, summary, days: 7);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  'Ringkasan 7 Hari Terakhir',
                  style: const TextStyle(
                    fontFamily: kHeadingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: MuyesColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _SummaryStat(value: '${summary.totalFood}x', label: 'Makan'),
                _SummaryStat(value: '${summary.totalPoop}x', label: 'Eek'),
                _SummaryStat(
                  value: summary.avgFoodPerDay.toStringAsFixed(1),
                  label: 'Makan/hari',
                ),
                _SummaryStat(
                  value: summary.avgPoopPerDay.toStringAsFixed(1),
                  label: 'Eek/hari',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (summary.avgFirstMealTime != null &&
                summary.avgLastMealTime != null)
              _SummaryLine(
                icon: '🕐',
                text:
                    'Jam makan rata-rata: mulai ~${summary.avgFirstMealTime}, '
                    'terakhir ~${summary.avgLastMealTime} — '
                    '${_spreadText(summary.firstMealSpreadHours)}.',
              ),
            if (summary.topFoods.isNotEmpty)
              _SummaryLine(
                icon: '🍽️',
                text:
                    'Paling sering: '
                    '${summary.topFoods.take(3).map((f) => '${f.name}${f.count > 1 ? " (${f.count}x)" : ""}').join(", ")}.',
              ),
            if (summary.topTrigger != null)
              _SummaryLine(
                icon: '⚡',
                text:
                    'Pemicu mules paling sering: ${summary.topTrigger!.trigger} '
                    '(${summary.topTrigger!.hitCount} dari '
                    '${summary.topTrigger!.totalEpisodes} kejadian).',
              ),
            const SizedBox(height: 8),
            _BristolChart(summary: summary),
            if (mainLine != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MuyesColors.primaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  mainLine,
                  style: const TextStyle(
                    fontFamily: kBodyFont,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                    color: MuyesColors.textDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _spreadText(double spread) {
    if (spread <= 2) return 'teratur 👍';
    if (spread <= 3) return 'lumayan';
    return 'lumayan lompat-lompat';
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: kHeadingFont,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: MuyesColors.textDark,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: kBodyFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MuyesColors.textDark.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: kBodyFont,
                fontSize: 13.5,
                height: 1.4,
                color: MuyesColors.textDark.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bar chart sederhana distribusi Bristol minggu ini (spec §5.5C).
/// Kalau Bristol jarang diisi → kalimat jujur, bukan chart kosong.
class _BristolChart extends StatelessWidget {
  const _BristolChart({required this.summary});

  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    final distribution = summary.bristolDistribution;
    if (distribution.isEmpty) {
      final text = summary.totalPoop == 0
          ? 'Belum ada data eek minggu ini.'
          : 'Bristol belum diisi minggu ini — distribusi bentuk eek belum '
                'bisa dibaca. Isi Bristol biar analisanya lebih akurat.';
      return Text(
        text,
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

/// Bottom sheet "Kenapa AI bilang ini?" — data mentah yang jadi bukti
/// (spec §5.5 "Aturan AI"). Log bisa di-tap buat lihat detailnya.
class _WhySheet extends StatelessWidget {
  const _WhySheet({required this.input, required this.insight});

  final MuyesAiInput input;
  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final entries = _evidenceEntries();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: MuyesColors.textDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kenapa AI bilang ini?',
              style: TextStyle(
                fontFamily: kHeadingFont,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MuyesColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ini data mentah dari catatanmu yang dipakai AI — '
              'bukan data dari luar.',
              style: TextStyle(
                fontFamily: kBodyFont,
                fontSize: 13,
                color: MuyesColors.textDark.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Insight ini nggak nunjuk log spesifik — kesimpulannya '
                  'dari ringkasan pola ${insight.periodDays} hari terakhir.',
                  style: TextStyle(
                    fontFamily: kBodyFont,
                    fontSize: 14,
                    color: MuyesColors.textDark.withValues(alpha: 0.75),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: SingleChildScrollView(
                  child: LogTimeline(
                    entries: entries,
                    onTapEntry: (entry) => _openEntry(context, entry),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Tap log bukti → tutup sheet, buka form edit log itu.
  void _openEntry(BuildContext context, TimelineEntry entry) {
    final navigator = Navigator.of(context);
    navigator.pop();
    final food = entry.food;
    if (food != null) {
      navigator.push(LogFoodScreen.route(existing: food));
      return;
    }
    final poop = entry.poop;
    if (poop != null) {
      navigator.push(LogPoopScreen.route(existing: poop));
      return;
    }
    navigator.push(LogMulesScreen.route(existing: entry.mules!));
  }

  /// Ambil log mentah yang jadi bukti, urut waktu.
  List<TimelineEntry> _evidenceEntries() {
    final ids = insight.evidenceLogIds.toSet();
    final entries = <TimelineEntry>[
      for (final log in input.food)
        if (ids.contains(log.id)) TimelineEntry.food(log),
      for (final log in input.poop)
        if (ids.contains(log.id)) TimelineEntry.poop(log),
      for (final log in input.mules)
        if (ids.contains(log.id)) TimelineEntry.mules(log),
    ]..sort((a, b) => a.time.compareTo(b.time));
    return entries;
  }
}
