import '../models/insight.dart';
import '../models/poop_log.dart';
import '../utils/date_utils.dart';
import 'ai_types.dart';

/// Deteksi abnormal rule-based (spec §5.5B). Prioritas tinggi.
///
/// Semua aturan:
/// | Kondisi | Level |
/// | Diare (Bristol 6-7) >=3x sehari, 2 hari berturut-turut | alert |
/// | Ada darah di eek (sekali pun) | alert |
/// | Eek hitam (bukan obat/besi) | alert |
/// | Tidak eek >=3 hari | warning |
/// | Mules >=4 dalam sehari | warning |
/// | Bristol 1-2 terus 3+ hari | warning |
/// | Pola normal | info |
///
/// Kalau Bristol jarang diisi, aturan yang butuh Bristol di-skip dan
/// dikasih catatan jujur — bukan dianggap 0 / normal.
class AbnormalDetector {
  const AbnormalDetector(this.input);

  final MuyesAiInput input;

  /// Hasilkan insight untuk rentang [days] hari.
  List<Insight> detect({int days = 7}) {
    final insights = <_InsightDraft>[];

    insights.addAll(_checkBlood());
    insights.addAll(_checkBlackStool());
    insights.addAll(_checkRepeatedDiarrhea());
    insights.addAll(_checkNoPoop());
    insights.addAll(_checkManyMules(days));
    insights.addAll(_checkHardStool());
    insights.addAll(_checkNormal(days));
    insights.addAll(_checkBristolCoverage(days));

    final now = input.now;
    return [
      for (final draft in insights)
        Insight(
          id: draft.id,
          type: InsightType.abnormal,
          level: draft.level,
          title: draft.title,
          body: draft.body,
          confidence: draft.confidence,
          evidenceLogIds: draft.evidence,
          periodDays: days,
          createdAt: now,
        ),
    ];
  }

  // ---- Aturan merah ----

  List<_InsightDraft> _checkBlood() {
    final withBlood = input.poop
        .where((p) => p.hasBlood == true)
        .toList(growable: false);
    if (withBlood.isEmpty) return const [];
    final latest = withBlood.last;
    return [
      _InsightDraft(
        id: 'abnormal:darah:${dayKey(latest.poopedAt)}',
        level: InsightLevel.alert,
        title: 'Ada darah di eek',
        body: 'Ada darah di eek kamu'
            '${withBlood.length > 1 ? " (${withBlood.length}x tercatat)" : ""}. '
            'Ini perlu perhatian serius — pertimbangkan konsultasi ke dokter. '
            'Kalau diikuti pusing / lemas, jangan ditunda.',
        confidence: InsightConfidence.tinggi,
        evidence: withBlood.map((p) => p.id).toList(growable: false),
      ),
    ];
  }

  List<_InsightDraft> _checkBlackStool() {
    final black = input.poop
        .where((p) => p.color == PoopColors.hitam)
        .toList(growable: false);
    if (black.isEmpty) return const [];
    return [
      _InsightDraft(
        id: 'abnormal:hitam:${dayKey(black.last.poopedAt)}',
        level: InsightLevel.alert,
        title: 'Eek hitam',
        body: 'Eek hitam bisa jadi tanda perdarahan saluran cerna atas — '
            'kecuali kamu lagi minum obat / suplemen zat besi. '
            'Pertimbangkan ke dokter.',
        confidence: InsightConfidence.sedang,
        evidence: black.map((p) => p.id).toList(growable: false),
      ),
    ];
  }

  // ---- Aturan kuning ----

  /// Diare >=3x sehari, 2 hari berturut-turut.
  List<_InsightDraft> _checkRepeatedDiarrhea() {
    final byDay = input.poopByDay(14);
    final diarrheaDays = <String>[];
    final evidence = <String>[];
    for (final entry in byDay.entries) {
      final count = entry.value.where(_isDiarrhea).length;
      if (count >= 3) {
        diarrheaDays.add(entry.key);
        evidence.addAll(
          entry.value.where(_isDiarrhea).map((p) => p.id),
        );
      }
    }
    diarrheaDays.sort();

    // Cari 2 hari berturut-turut.
    for (var i = 0; i + 1 < diarrheaDays.length; i++) {
      final first = DateTime.parse(diarrheaDays[i]);
      final second = DateTime.parse(diarrheaDays[i + 1]);
      if (second.difference(first).inDays == 1) {
        return [
          _InsightDraft(
            id: 'abnormal:diare-berulang:${diarrheaDays[i]}',
            level: InsightLevel.alert,
            title: 'Diare berulang 2 hari',
            body: 'Diare (Bristol 6-7) 3x+ sehari selama 2 hari berturut-turut '
                '(${diarrheaDays[i]} & ${diarrheaDays[i + 1]}). '
                'Perbanyak cairan, hindari pemicu. Kalau berlanjut / ada '
                'darah / demam, pertimbangkan ke dokter.',
            confidence: InsightConfidence.tinggi,
            evidence: evidence,
          ),
        ];
      }
    }
    return const [];
  }

  /// Mules >=4 dalam sehari (gabungan MulesLog + PoopLog, dedup <30 menit).
  List<_InsightDraft> _checkManyMules(int days) {
    final episodes = mergeMulesEpisodes(
      input.mulesSince(days),
      input.poopSince(days),
    ).where((e) => e.isMulesEvent).toList(growable: false);

    final byDay = <String, List<AiMulesEpisode>>{};
    for (final episode in episodes) {
      byDay.putIfAbsent(dayKey(episode.time), () => []).add(episode);
    }

    for (final entry in byDay.entries) {
      if (entry.value.length >= 4) {
        return [
          _InsightDraft(
            id: 'abnormal:mules-banyak:${entry.key}',
            level: InsightLevel.warning,
            title: 'Mules ${entry.value.length}x dalam sehari',
            body: 'Perut kamu mules ${entry.value.length}x di '
                '${entry.key}. Coba cek makanan 12 jam terakhir — '
                'kelihatan pemicunya nggak?',
            confidence: InsightConfidence.sedang,
            evidence: [
              for (final episode in entry.value) ...episode.sourceLogIds,
            ],
          ),
        ];
      }
    }
    return const [];
  }

  /// Bristol 1-2 terus 3+ hari berturut-turut.
  List<_InsightDraft> _checkHardStool() {
    final byDay = input.poopByDay(14);
    final hardDays = <String>[];
    final evidence = <String>[];
    for (final entry in byDay.entries) {
      final hasHard = entry.value.any(
        (p) => p.bristol != null && p.bristol! <= 2,
      );
      if (hasHard) {
        hardDays.add(entry.key);
        evidence.addAll(
          entry.value
              .where((p) => p.bristol != null && p.bristol! <= 2)
              .map((p) => p.id),
        );
      }
    }
    hardDays.sort();

    var run = 0;
    for (var i = 0; i < hardDays.length; i++) {
      if (i > 0 &&
          DateTime.parse(hardDays[i])
                  .difference(DateTime.parse(hardDays[i - 1]))
                  .inDays ==
              1) {
        run++;
      } else {
        run = 1;
      }
      if (run >= 3) {
        return [
          _InsightDraft(
            id: 'abnormal:konstipasi:${hardDays[i]}',
            level: InsightLevel.warning,
            title: 'Eek keras terus 3 hari',
            body: 'Bristol 1-2 (keras) terus 3 hari — kemungkinan konstipasi. '
                'Coba perbanyak air + serat, gerak. Kalau >5 hari / sakit '
                'parah, ke dokter.',
            confidence: InsightConfidence.tinggi,
            evidence: evidence,
          ),
        ];
      }
    }
    return const [];
  }

  /// Tidak eek >=3 hari (dihitung dari log terakhir).
  List<_InsightDraft> _checkNoPoop() {
    if (input.poop.isEmpty) return const [];
    final last = input.poop.last.poopedAt;
    final daysSince = startOfDay(input.now).difference(startOfDay(last)).inDays;
    if (daysSince < 3) return const [];
    return [
      _InsightDraft(
        id: 'abnormal:nggak-eek:${dayKey(last)}',
        level: InsightLevel.warning,
        title: 'Belum eek $daysSince hari',
        body: 'Kamu belum eek $daysSince hari (terakhir catatan '
            '${dayKey(last)}). Coba perbanyak air + serat, gerak. '
            'Kalau >5 hari / sakit parah, ke dokter.',
        confidence: InsightConfidence.sedang,
        evidence: [input.poop.last.id],
      ),
    ];
  }

  // ---- Info hijau ----

  /// Pola normal: frekuensi 1-2x/hari, mules 0-1, Bristol 3-5 kalau ada.
  List<_InsightDraft> _checkNormal(int days) {
    if (input.poop.isEmpty) return const [];
    final poopLogs = input.poopSince(days);
    if (poopLogs.isEmpty) return const [];

    final episodes = mergeMulesEpisodes(
      input.mulesSince(days),
      input.poopSince(days),
    ).where((e) => e.isMulesEvent).toList(growable: false);

    final daysCovered = input.daysWithAnyLog(days);
    if (daysCovered < 3) return const [];

    final poopPerDay = poopLogs.length / daysCovered;
    final abnormal = input.poop.any(
      (p) => p.hasBlood == true || p.color == PoopColors.hitam,
    );
    final bristolAll = poopLogs
        .where((p) => p.bristol != null)
        .map((p) => p.bristol!)
        .toList(growable: false);
    final bristolOk = bristolAll.every((b) => b >= 3 && b <= 5);

    if (poopPerDay <= 2.5 &&
        episodes.length <= 1 &&
        !abnormal &&
        bristolOk) {
      return [
        _InsightDraft(
          id: 'abnormal:normal:$days',
          level: InsightLevel.info,
          title: 'Pola eek normal',
          body: 'Pola eek kamu $days hari terakhir kelihatan normal — '
              '${poopLogs.length}x eek, mules ${episodes.length}x. '
              'Pertahankan! 🎉',
          confidence: bristolAll.length >= poopLogs.length / 2
              ? InsightConfidence.tinggi
              : InsightConfidence.sedang,
          evidence: poopLogs.map((p) => p.id).toList(growable: false),
        ),
      ];
    }
    return const [];
  }

  static bool _isDiarrhea(PoopLog log) => (log.bristol ?? 0) >= 6;

  /// Catatan jujur kalau Bristol jarang diisi (spec §5.5 "Aturan AI").
  /// Bukan insight medis — cuma ngasih tau analisa jadi terbatas.
  List<_InsightDraft> _checkBristolCoverage(int days) {
    final poopLogs = input.poopSince(days);
    if (poopLogs.isEmpty) return const [];
    final filled = poopLogs.where((p) => p.bristol != null).length;
    // Bilang sesuatu cuma kalau ada eek tapi Bristol kebanyakan kosong.
    if (filled == 0 && poopLogs.length >= 3) {
      return [
        _InsightDraft(
          id: 'abnormal:bristol-kosong:$days',
          level: InsightLevel.info,
          title: 'Insight terbatas: Bristol jarang diisi',
          body: 'Kamu udah catat ${poopLogs.length}x eek $days hari terakhir, '
              'tapi Bristol (bentuk eek) belum pernah diisi. Analisa sejauh '
              'ini cuma bisa pakai frekuensi & jeda waktu. Isi Bristol biar '
              'analisanya lebih akurat — cukup tap 1x pas logging.',
          confidence: InsightConfidence.tinggi,
          evidence: poopLogs.map((p) => p.id).toList(growable: false),
        ),
      ];
    }
    return const [];
  }
}

class _InsightDraft {
  const _InsightDraft({
    required this.id,
    required this.level,
    required this.title,
    required this.body,
    required this.confidence,
    required this.evidence,
  });

  final String id;
  final String level;
  final String title;
  final String body;
  final String confidence;
  final List<String> evidence;
}
