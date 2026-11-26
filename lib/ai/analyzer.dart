import '../models/insight.dart';
import '../models/poop_log.dart';
import '../utils/date_utils.dart';
import 'abnormal_detector.dart';
import 'ai_types.dart';
import 'correlation.dart';
import 'eating_pattern_detector.dart';
import 'weekly_summary.dart';

/// Hasil lengkap satu kali analisa.
class AiAnalysis {
  const AiAnalysis({
    required this.insights,
    required this.patternInsights,
    required this.poopInsights,
    required this.dataNote,
  });

  /// Semua insight (pola makan + pola eek + ringkasan mingguan + korelasi).
  final List<Insight> insights;

  /// Insight pola makan (section `Pola Makan`, spec §5.5D).
  final List<Insight> patternInsights;

  /// Insight eek: abnormal + korelasi (section `Pola Eek`).
  final List<Insight> poopInsights;

  /// Catatan kalau data masih sedikit (spec §5.5 "Kalau data kurang").
  final String? dataNote;
}

/// Orchestrator semua rule AI lokal (spec §7).
///
/// Local-first: rule-based + statistik sederhana dari log user sendiri.
/// Nggak ada ML, nggak ada LLM, nggak ada internet.
class MuyesAnalyzer {
  const MuyesAnalyzer(this.input);

  final MuyesAiInput input;

  /// Minimal hari data biar insight penuh muncul (spec: 3-5 hari).
  static const minDays = 3;

  /// Minimal log eek biar insight eek muncul (spec: <5 log eek → pesan).
  static const minPoopLogs = 5;

  /// Jalankan semua rule untuk [days] hari (default 7). [thirtyDays] = true
  /// juga menghitung versi 30 hari untuk korelasi yang lebih stabil.
  AiAnalysis analyze({int days = 7, bool thirtyDays = false}) {
    final foodInsights = EatingPatternDetector(input).detect(days: days);
    final poopInsights = <Insight>[
      ...AbnormalDetector(input).detect(days: days),
      ...findCorrelations(input, days: days).map(_correlationToInsight),
      if (thirtyDays)
        ...findCorrelations(input, days: 30).map(_correlationToInsight),
    ];
    final weekly = weeklySummaryInsight(input, days: days);

    // Dedup: korelasi 7 & 30 hari bisa punya id beda (periodDays beda),
    // jadi dua-duanya oke ditampilkan — tapi id sama persis cuma 1.
    final byId = <String, Insight>{};
    for (final insight in [
      ...foodInsights,
      ...poopInsights,
      weekly,
    ]) {
      byId[insight.id] = insight;
    }

    return AiAnalysis(
      insights: byId.values.toList(growable: false),
      patternInsights: foodInsights,
      poopInsights: poopInsights,
      dataNote: _dataNote(days),
    );
  }

  /// Insight + catatan data buat layar Insights (spec §5.5): kalau data
  /// kurang dari 3 hari / <5 log eek, bilang jujur.
  String? _dataNote(int days) {
    final daysCount = input.daysWithAnyLog(days);
    final poopTotal = input.poop.length;

    if (daysCount < minDays) {
      return 'Data masih sedikit, insight akan muncul setelah 3-5 hari '
          'pencatatan. Santai, nggak harus langsung lengkap.';
    }
    if (poopTotal < minPoopLogs) {
      return 'Data eek masih sedikit ($poopTotal log), insight eek bakal '
          'makin tajam setelah $minPoopLogs+ log.';
    }
    return null;
  }

  static Insight _correlationToInsight(CorrelationResult result) => Insight(
    id: 'correlation:${result.trigger}:${result.periodDays}',
    type: InsightType.correlation,
    level: InsightLevel.warning,
    title: 'Kemungkinan pemicu: ${result.trigger}',
    body: result.body,
    confidence: result.confidence,
    evidenceLogIds: result.evidenceLogIds,
    periodDays: result.periodDays,
    createdAt: DateTime.now(),
  );
}

// ---- Status Home hari ini (spec §5.3: "dari AI") ----

/// Status perut hari ini — dari AI lokal.
class StomachStatus {
  const StomachStatus({
    required this.level,
    required this.title,
    required this.detail,
  });

  /// `info` / `warning` / `alert` — pakai warna yang sama dengan insight.
  /// UI memetakan level ini ke ikon Streamline (jempol hijau / warning /
  /// danger) lewat `slStatusIcon` — bukan emoji lagi (koreksi user,
  /// 26 Nov 2026).
  final String level;
  final String title;
  final String detail;
}

/// Hitung status perut hari ini dari log hari itu (spec §5.3).
StomachStatus stomachStatusForToday(MuyesAiInput input) {
  final today = startOfDay(input.now);
  final tomorrow = startOfNextDay(input.now);

  final poopToday = input.poop
      .where((p) => !p.poopedAt.isBefore(today) && p.poopedAt.isBefore(tomorrow))
      .toList(growable: false);
  final mulesToday = mergeMulesEpisodes(
    input.mules
        .where((m) => !m.feltAt.isBefore(today) && m.feltAt.isBefore(tomorrow))
        .toList(growable: false),
    poopToday,
  ).where((e) => e.isMulesEvent).toList(growable: false);

  // Merah: darah / hitam / diare banyak.
  final blood = poopToday.where((p) => p.hasBlood == true).length;
  final black = poopToday.where((p) => p.color == PoopColors.hitam).length;
  final diarrhea = poopToday.where((p) => (p.bristol ?? 0) >= 6).length;

  if (blood > 0) {
    return StomachStatus(
      level: InsightLevel.alert,
      title: 'Perlu perhatian: ada darah',
      detail: 'Ada darah di eek hari ini. Buka Insight buat detail + '
          'saran. Kalau berlanjut, pertimbangkan ke dokter.',
    );
  }
  if (black > 0) {
    return StomachStatus(
      level: InsightLevel.alert,
      title: 'Perlu perhatian: eek hitam',
      detail: 'Eek hitam bisa jadi tanda perdarahan saluran cerna '
          '(kecuali lagi minum zat besi). Pertimbangkan ke dokter.',
    );
  }
  if (diarrhea >= 3) {
    return StomachStatus(
      level: InsightLevel.alert,
      title: 'Waspada: diare $diarrhea kali hari ini',
      detail: 'Perbanyak cairan, hindari pemicu. Kalau berlanjut / ada '
          'darah / demam, pertimbangkan ke dokter.',
    );
  }
  if (mulesToday.length >= 4) {
    return StomachStatus(
      level: InsightLevel.warning,
      title: 'Waspada: mules ${mulesToday.length}x hari ini',
      detail: 'Cek makanan 12 jam terakhir di atas — ada pemicu yang '
          'kelihatan?',
    );
  }
  if (mulesToday.isNotEmpty || diarrhea > 0) {
    return StomachStatus(
      level: InsightLevel.warning,
      title: mulesToday.isNotEmpty
          ? 'Mules ${mulesToday.length}x hari ini'
          : 'Diare $diarrhea kali hari ini',
      detail: 'Pantau terus — buka Riwayat buat lihat makanannya.',
    );
  }
  if (poopToday.isEmpty) {
    return const StomachStatus(
      level: InsightLevel.info,
      title: 'Perut aman',
      detail: 'Belum ada keluhan tercatat hari ini.',
    );
  }
  return const StomachStatus(
    level: InsightLevel.info,
    title: 'Perut aman',
    detail: 'Eek hari ini nggak ada keluhan tercatat.',
  );
}

/// Status makan hari ini — dari AI lokal (spec §5.3).
StomachStatus eatingStatusForToday(MuyesAiInput input) {
  final today = startOfDay(input.now);
  final tomorrow = startOfNextDay(input.now);
  final foodToday = input.food
      .where((f) => !f.eatenAt.isBefore(today) && f.eatenAt.isBefore(tomorrow))
      .toList(growable: false);

  if (input.food.isEmpty) {
    return const StomachStatus(
      level: InsightLevel.info,
      title: 'Belum ada catatan makan',
      detail: 'Catat makan pertamamu hari ini biar kebaca polanya.',
    );
  }

  final lastMeal = input.food.last.eatenAt;
  final gap = input.now.difference(lastMeal);

  // Makan malam kemarin + sekarang masih pagi = gap normal (istirahat malam).
  final overnightRest = lastMeal.hour >= 20 && input.now.hour <= 10;

  if (gap.inHours >= 14) {
    return StomachStatus(
      level: InsightLevel.warning,
      title: 'Terakhir makan ${gap.inHours} jam lalu',
      detail: 'Terakhir makan jam ${formatTimeId(lastMeal)}. Lupa catat '
          'atau memang belum makan? Kalau belum, coba isi yang ringan dulu.',
    );
  }

  if (gap.inHours >= 8 && !overnightRest) {
    return StomachStatus(
      level: InsightLevel.warning,
      title: 'Belum makan ${gap.inHours} jam',
      detail: 'Terakhir makan jam ${formatTimeId(lastMeal)}. Kalau memang '
          'belum makan, coba isi dulu. Kalau udah tapi lupa catat, isi ya.',
    );
  }

  if (foodToday.isEmpty) {
    return const StomachStatus(
      level: InsightLevel.info,
      title: 'Belum ada catatan makan hari ini',
      detail: 'Catat makan pertamamu hari ini biar kebaca polanya.',
    );
  }

  return StomachStatus(
    level: InsightLevel.info,
    title: 'Baru makan ${foodToday.length}x hari ini',
    detail: 'Terakhir jam '
        '${formatTimeId(foodToday.last.eatenAt)}. '
        '${foodToday.length >= 2 ? "Jaga polanya ya." : "Nanti jangan skip lagi."}',
  );
}
