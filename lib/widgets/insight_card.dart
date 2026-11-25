import 'package:flutter/material.dart';

import '../models/insight.dart';
import '../theme.dart';
import 'log_timeline.dart' show statusColor;

/// Label kata untuk level insight (spec §5.5B): merah/kuning/hijau.
String insightLevelLabel(String level) => switch (level) {
  InsightLevel.alert => 'Perlu perhatian',
  InsightLevel.warning => 'Waspada',
  _ => 'Info',
};

/// Kartu satu hasil analisa AI lokal (spec §5.5).
///
/// Termasuk: judul + body Bahasa Indonesia, badge keyakinan (jujur dari
/// jumlah sampel), dan tombol "Kenapa AI bilang ini?" yang dibuka oleh
/// pemanggil lewat [onWhyPressed] (nunjukin data mentahnya).
class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight, this.onWhyPressed});

  final Insight insight;
  final VoidCallback? onWhyPressed;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(context, insight.level);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4, right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    insight.title,
                    style: const TextStyle(
                      fontFamily: kHeadingFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MuyesColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              insight.body,
              style: TextStyle(
                fontFamily: kBodyFont,
                fontSize: 14,
                height: 1.45,
                color: MuyesColors.textDark.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Badge(label: insightLevelLabel(insight.level)),
                _Badge(label: 'Keyakinan: ${insight.confidence}'),
                if (insight.periodDays != 7)
                  _Badge(label: '${insight.periodDays} hari terakhir'),
                if (onWhyPressed != null)
                  TextButton(
                    onPressed: onWhyPressed,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: MuyesColors.primaryDark,
                      textStyle: const TextStyle(
                        fontFamily: kBodyFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Kenapa AI bilang ini?'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill kecil buat badge level/keyakinan.
class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: MuyesColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MuyesColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: kBodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: MuyesColors.textDark.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
