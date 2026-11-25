import '../models/food_log.dart';
import '../models/mules_log.dart';
import '../models/poop_log.dart';
import '../utils/date_utils.dart';

/// Input untuk semua analisa AI lokal (spec §5.5).
///
/// Semua data yang masuk HARUS dari log user sendiri — nggak ada dataset
/// eksternal, nggak ada network.
class MuyesAiInput {
  const MuyesAiInput({
    required this.food,
    required this.poop,
    required this.mules,
    required this.now,
    this.fastingMode = false,
  });

  /// Log makan (disarankan >= 30 hari terakhir, urut waktu naik).
  final List<FoodLog> food;

  /// Log eek (disarankan >= 30 hari terakhir, urut waktu naik).
  final List<PoopLog> poop;

  /// Log mules terpisah (disarankan >= 30 hari terakhir, urut waktu naik).
  final List<MulesLog> mules;

  /// Waktu "sekarang" — di-inject biar bisa dites.
  final DateTime now;

  /// Toggle "Mode Puasa / IF" (spec §5.5D). Kalau true, rule skip-makan +
  /// gap panjang dimatikan, rule lain tetap jalan.
  final bool fastingMode;

  /// Log dalam [days] hari terakhir (inklusif hari ini).
  List<FoodLog> foodSince(int days) =>
      _since(food, days, (log) => log.eatenAt);
  List<PoopLog> poopSince(int days) =>
      _since(poop, days, (log) => log.poopedAt);
  List<MulesLog> mulesSince(int days) =>
      _since(mules, days, (log) => log.feltAt);

  List<T> _since<T>(
    List<T> logs,
    int days,
    DateTime Function(T) timeOf,
  ) {
    final cutoff = startOfDay(now).subtract(Duration(days: days - 1));
    return logs
        .where((log) => !timeOf(log).isBefore(cutoff))
        .toList(growable: false);
  }

  /// Banyak hari unik yang punya catatan apapun dalam [days] hari terakhir.
  int daysWithAnyLog(int days) {
    final cutoff = startOfDay(now).subtract(Duration(days: days - 1));
    final keys = <String>{
      for (final log in food)
        if (!log.eatenAt.isBefore(cutoff)) dayKey(log.eatenAt),
      for (final log in poop)
        if (!log.poopedAt.isBefore(cutoff)) dayKey(log.poopedAt),
      for (final log in mules)
        if (!log.feltAt.isBefore(cutoff)) dayKey(log.feltAt),
    };
    return keys.length;
  }

  /// Banyak hari unik yang punya catatan MAKAN dalam [days] hari terakhir.
  int daysWithFoodLog(int days) {
    final cutoff = startOfDay(now).subtract(Duration(days: days - 1));
    final keys = <String>{
      for (final log in food)
        if (!log.eatenAt.isBefore(cutoff)) dayKey(log.eatenAt),
    };
    return keys.length;
  }

  /// Kelompokkan log per hari (key `YYYY-MM-DD`) untuk rentang [days] hari.
  Map<String, List<FoodLog>> foodByDay(int days) =>
      _groupByDay(food, days, (log) => log.eatenAt);

  Map<String, List<PoopLog>> poopByDay(int days) =>
      _groupByDay(poop, days, (log) => log.poopedAt);

  Map<String, List<MulesLog>> mulesByDay(int days) =>
      _groupByDay(mules, days, (log) => log.feltAt);

  Map<String, List<T>> _groupByDay<T>(
    List<T> logs,
    int days,
    DateTime Function(T) timeOf,
  ) {
    final cutoff = startOfDay(now).subtract(Duration(days: days - 1));
    final result = <String, List<T>>{};
    for (final log in logs) {
      final time = timeOf(log);
      if (time.isBefore(cutoff)) continue;
      result.putIfAbsent(dayKey(time), () => []).add(log);
    }
    return result;
  }
}

/// Satu kejadian mules GABUNGAN — hasil merge MulesLog + PoopLog.painLevel
/// dengan deduplikasi <30 menit (spec §5.2b).
///
/// Kalau user nyatet mules di log eek DAN di log mules dalam <30 menit,
/// itu dihitung SATU kejadian, bukan dua.
class AiMulesEpisode {
  const AiMulesEpisode({
    required this.time,
    required this.level,
    required this.hasDiarrhea,
    required this.sourceLogIds,
  });

  /// Waktu kejadian (waktu paling awal dari log yang di-merge).
  final DateTime time;

  /// Level mules tertinggi di antara log yang di-merge (1-5).
  /// 0 artinya nggak ada nyeri, misal episode cuma diare.
  final int level;

  /// Ada eek Bristol 6-7 di episode ini?
  final bool hasDiarrhea;

  /// Id log asli yang jadi bukti (PoopLog / MulesLog).
  final List<String> sourceLogIds;

  /// Buat filter "kejadian mules" (level nyeri >= 1).
  bool get isMulesEvent => level >= 1;

  /// Buat filter "kejadian bermasalah" untuk korelasi (spec §5.5A):
  /// mules level >= 3 ATAU diare.
  bool get isBadEpisode => level >= 3 || hasDiarrhea;
}

/// Jendela deduplikasi mules (spec §5.2b: <30 menit = 1 kejadian).
const muyesMulesMergeWindow = Duration(minutes: 30);

/// Merge MulesLog + PoopLog jadi daftar kejadian mules ter-dedup.
///
/// - MulesLog `painLevel == 0` ("Nggak mules") = koreksi, BUKAN kejadian.
/// - PoopLog dianggap kejadian kalau `painLevel >= 1` ATAU `bristol >= 6`.
/// - Dua kejadian yang jaraknya < 30 menit digabung jadi 1.
List<AiMulesEpisode> mergeMulesEpisodes(
  List<MulesLog> mules,
  List<PoopLog> poop,
) {
  final raw = <_RawEvent>[
    for (final log in mules)
      if (log.painLevel >= 1)
        _RawEvent(
          time: log.feltAt,
          level: log.painLevel,
          diarrhea: false,
          id: log.id,
        ),
    for (final log in poop)
      if ((log.painLevel ?? 0) >= 1 || (log.bristol ?? 0) >= 6)
        _RawEvent(
          time: log.poopedAt,
          level: log.painLevel ?? 0,
          diarrhea: (log.bristol ?? 0) >= 6,
          id: log.id,
        ),
  ]..sort((a, b) => a.time.compareTo(b.time));

  final episodes = <AiMulesEpisode>[];
  for (final event in raw) {
    if (episodes.isEmpty) {
      episodes.add(event.toEpisode());
      continue;
    }
    final last = episodes.last;
    final gap = event.time.difference(last.time);
    if (gap < muyesMulesMergeWindow) {
      // Gabung: level tertinggi, waktu paling awal, tanda diare digabung.
      episodes[episodes.length - 1] = AiMulesEpisode(
        time: last.time,
        level: event.level > last.level ? event.level : last.level,
        hasDiarrhea: last.hasDiarrhea || event.diarrhea,
        sourceLogIds: [...last.sourceLogIds, event.id],
      );
    } else {
      episodes.add(event.toEpisode());
    }
  }
  return episodes;
}

class _RawEvent {
  const _RawEvent({
    required this.time,
    required this.level,
    required this.diarrhea,
    required this.id,
  });

  final DateTime time;
  final int level;
  final bool diarrhea;
  final String id;

  AiMulesEpisode toEpisode() => AiMulesEpisode(
    time: time,
    level: level,
    hasDiarrhea: diarrhea,
    sourceLogIds: [id],
  );
}
