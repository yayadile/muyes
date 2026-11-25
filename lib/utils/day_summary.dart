import '../models/poop_log.dart';
import '../models/timeline_entry.dart';

/// Status harian untuk dot kalender (spec §5.4).
///
/// PROVISIONAL: aturan ringan per-hari untuk Phase 3.
/// Phase 4 (`lib/ai/abnormal_detector.dart`) bakal jadi sumber utama
/// (termasuk pola lintas-hari seperti "diare 2 hari berturut-turut").
enum DayStatus { normal, waspada, abnormal }

/// Hitung status satu hari dari log hari itu.
/// Return `null` kalau hari itu nggak ada log (nggak ada dot).
DayStatus? computeDayStatus(List<TimelineEntry> entries) {
  if (entries.isEmpty) return null;

  final poopLogs = entries
      .where((e) => e.poop != null)
      .map((e) => e.poop!)
      .toList(growable: false);

  // Merah: darah, warna merah/hitam, atau diare >=3x sehari.
  final bloodOrDangerColor = poopLogs.any(
    (p) =>
        p.hasBlood == true ||
        p.color == PoopColors.merah ||
        p.color == PoopColors.hitam,
  );
  final diarrheaCount = poopLogs
      .where((p) => p.bristol != null && p.bristol! >= 6)
      .length;
  if (bloodOrDangerColor || diarrheaCount >= 3) return DayStatus.abnormal;

  // Kuning: diare 1-2x, mules >=4x, atau eek keras 2x+.
  final hardCount = poopLogs
      .where((p) => p.bristol != null && p.bristol! <= 2)
      .length;
  final mulesCount = entries.where(_isMulesEvent).length;
  if (diarrheaCount >= 1 || hardCount >= 2 || mulesCount >= 4) {
    return DayStatus.waspada;
  }

  return DayStatus.normal;
}

/// Kejadian mules: MulesLog dengan level > 0, atau PoopLog painLevel >= 3.
///
/// CATATAN: ini versi mentah per-hari. Merge + dedup <30 menit (spec §5.2b)
/// dilakukan di analyzer Phase 4.
bool _isMulesEvent(TimelineEntry entry) {
  final mules = entry.mules;
  if (mules != null) return mules.painLevel > 0;
  final poop = entry.poop;
  if (poop != null) {
    final pain = poop.painLevel;
    return pain != null && pain >= 3;
  }
  return false;
}
