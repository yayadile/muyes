import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'models/food_log.dart';
import 'models/mules_log.dart';
import 'models/poop_log.dart';
import 'models/timeline_entry.dart';

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
