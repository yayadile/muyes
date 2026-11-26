import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai/ai_types.dart';
import 'ai/analyzer.dart';
import 'ai/weekly_summary.dart';
import 'data/database.dart';
import 'models/food_log.dart';
import 'models/mules_log.dart';
import 'models/poop_log.dart';
import 'models/timeline_entry.dart';
import 'utils/stats_calculator.dart';

/// Database lokal — satu instance untuk seluruh app.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final foodLogDaoProvider = Provider<FoodLogDao>(
  (ref) => FoodLogDao(ref.watch(appDatabaseProvider)),
);

final poopLogDaoProvider = Provider<PoopLogDao>(
  (ref) => PoopLogDao(ref.watch(appDatabaseProvider)),
);

final mulesLogDaoProvider = Provider<MulesLogDao>(
  (ref) => MulesLogDao(ref.watch(appDatabaseProvider)),
);

final insightDaoProvider = Provider<InsightDao>(
  (ref) => InsightDao(ref.watch(appDatabaseProvider)),
);

/// Hari yang sedang dilihat di Home (spec §5.3 "Hari Ini").
class SelectedDay extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime day) => state = day;

  void goToToday() => state = DateTime.now();
}

final selectedDayProvider = NotifierProvider<SelectedDay, DateTime>(
  SelectedDay.new,
);

/// Stream log makan satu hari, urut waktu naik.
final dayFoodLogsProvider = StreamProvider.autoDispose<List<FoodLog>>((ref) {
  final day = ref.watch(selectedDayProvider);
  return ref.watch(foodLogDaoProvider).watchForDay(day);
});

/// Stream log eek satu hari.
final dayPoopLogsProvider = StreamProvider.autoDispose<List<PoopLog>>((ref) {
  final day = ref.watch(selectedDayProvider);
  return ref.watch(poopLogDaoProvider).watchForDay(day);
});

/// Stream log mules satu hari.
final dayMulesLogsProvider = StreamProvider.autoDispose<List<MulesLog>>((ref) {
  final day = ref.watch(selectedDayProvider);
  return ref.watch(mulesLogDaoProvider).watchForDay(day);
});

/// Timeline gabungan satu hari, urut waktu (spec §5.3).
final dayTimelineProvider = Provider.autoDispose<AsyncValue<List<TimelineEntry>>>(
  (ref) {
    final food = ref.watch(dayFoodLogsProvider);
    final poop = ref.watch(dayPoopLogsProvider);
    final mules = ref.watch(dayMulesLogsProvider);

    // Kalau salah satu masih loading / error, teruskan state-nya.
    for (final async in [food, poop, mules]) {
      if (async.hasError) {
        return AsyncError(async.error!, async.stackTrace ?? StackTrace.current);
      }
    }
    if (!food.hasValue || !poop.hasValue || !mules.hasValue) {
      return const AsyncLoading();
    }

    final entries = <TimelineEntry>[
      ...food.value!.map(TimelineEntry.food),
      ...poop.value!.map(TimelineEntry.poop),
      ...mules.value!.map(TimelineEntry.mules),
    ]..sort((a, b) => a.time.compareTo(b.time));
    return AsyncData(entries);
  },
);

/// Semua log (semua hari), untuk History & Kalender.
final allFoodLogsProvider = StreamProvider.autoDispose<List<FoodLog>>(
  (ref) => ref.watch(foodLogDaoProvider).watchAll(),
);

final allPoopLogsProvider = StreamProvider.autoDispose<List<PoopLog>>(
  (ref) => ref.watch(poopLogDaoProvider).watchAll(),
);

final allMulesLogsProvider = StreamProvider.autoDispose<List<MulesLog>>(
  (ref) => ref.watch(mulesLogDaoProvider).watchAll(),
);

/// Bulan yang sedang dilihat di Kalender (spec §5.4).
class CalendarMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void select(DateTime month) => state = DateTime(month.year, month.month);

  void next() => state = DateTime(state.year, state.month + 1);

  void previous() => state = DateTime(state.year, state.month - 1);
}

final calendarMonthProvider = NotifierProvider<CalendarMonth, DateTime>(
  CalendarMonth.new,
);

// ---- AI lokal (spec §5.5) ----

/// Rentang data yang dibaca AI: 30 hari terakhir (spec: analisa 7 & 30 hari).
const aiWindowDays = 30;

/// Toggle "Mode Puasa / IF" dari Settings (spec §5.5D), default OFF.
final fastingModeProvider = StreamProvider<bool>(
  (ref) =>
      ref.watch(appDatabaseProvider).watchBoolSetting(SettingKeys.fastingMode),
);

/// Data contoh (spec §10) sedang terpasang? Buat tombol Isi/Hapus di
/// Settings.
final demoSeededProvider = StreamProvider<bool>(
  (ref) =>
      ref.watch(appDatabaseProvider).watchBoolSetting(SettingKeys.demoSeeded),
);

/// Log makan 30 hari terakhir — bahan analisa AI.
final aiFoodLogsProvider = StreamProvider<List<FoodLog>>(
  (ref) => ref.watch(foodLogDaoProvider).watchLastDays(aiWindowDays),
);

/// Log eek 30 hari terakhir — bahan analisa AI.
final aiPoopLogsProvider = StreamProvider<List<PoopLog>>(
  (ref) => ref.watch(poopLogDaoProvider).watchLastDays(aiWindowDays),
);

/// Log mules 30 hari terakhir — bahan analisa AI.
final aiMulesLogsProvider = StreamProvider<List<MulesLog>>(
  (ref) => ref.watch(mulesLogDaoProvider).watchLastDays(aiWindowDays),
);

/// Input gabungan buat semua rule AI (spec §5.5).
final aiInputProvider = Provider.autoDispose<AsyncValue<MuyesAiInput>>((ref) {
  final food = ref.watch(aiFoodLogsProvider);
  final poop = ref.watch(aiPoopLogsProvider);
  final mules = ref.watch(aiMulesLogsProvider);
  final fasting = ref.watch(fastingModeProvider);

  for (final async in [food, poop, mules, fasting]) {
    if (async.hasError) {
      return AsyncError(async.error!, async.stackTrace ?? StackTrace.current);
    }
  }
  if (!food.hasValue ||
      !poop.hasValue ||
      !mules.hasValue ||
      !fasting.hasValue) {
    return const AsyncLoading();
  }

  return AsyncData(
    MuyesAiInput(
      food: food.value!,
      poop: poop.value!,
      mules: mules.value!,
      now: DateTime.now(),
      fastingMode: fasting.value!,
    ),
  );
});

/// Hasil analisa lengkap 7 hari + korelasi 30 hari (halaman Insights).
///
/// Hasilnya langsung disimpan ke tabel `insights` (spec §6) — id insight
/// deterministik, jadi re-generate tiap ada log baru tidak menumpuk duplikat.
final aiAnalysisProvider = Provider.autoDispose<AsyncValue<AiAnalysis>>((ref) {
  final dao = ref.read(insightDaoProvider);
  return ref.watch(aiInputProvider).whenData((input) {
    final analysis = MuyesAnalyzer(input).analyze(days: 7, thirtyDays: true);
    Future.microtask(() => dao.upsertAll(analysis.insights));
    return analysis;
  });
});

/// Ringkasan mingguan terstruktur buat kartu di Insights (spec §5.5C).
final aiWeeklySummaryProvider = Provider.autoDispose<AsyncValue<WeeklySummary>>(
  (ref) => ref.watch(aiInputProvider).whenData((input) => buildWeeklySummary(input)),
);

/// Status perut hari ini, dari AI (Home, spec §5.3).
final stomachStatusProvider = Provider.autoDispose<AsyncValue<StomachStatus>>(
  (ref) => ref.watch(aiInputProvider).whenData(stomachStatusForToday),
);

/// Status makan hari ini, dari AI (Home, spec §5.3).
final eatingStatusProvider = Provider.autoDispose<AsyncValue<StomachStatus>>(
  (ref) => ref.watch(aiInputProvider).whenData(eatingStatusForToday),
);

// ---- Statistik (halaman diagram, spec §8.1) ----

/// Rentang halaman Statistik: 7 atau 30 hari.
class StatsRange extends Notifier<int> {
  @override
  int build() => 7;

  void select(int days) => state = days;
}

final statsRangeProvider = NotifierProvider<StatsRange, int>(StatsRange.new);

/// Semua angka + diagram halaman Statistik, dari data 30 hari terakhir.
final statsProvider = Provider.autoDispose<AsyncValue<MuyesStats>>((ref) {
  final days = ref.watch(statsRangeProvider);
  return ref.watch(aiInputProvider).whenData(
    (input) => buildStats(input, days: days),
  );
});
