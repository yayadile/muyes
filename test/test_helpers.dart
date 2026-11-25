import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyes/ai/ai_types.dart';
import 'package:muyes/ai/analyzer.dart';
import 'package:muyes/ai/weekly_summary.dart';
import 'package:muyes/models/food_log.dart';
import 'package:muyes/models/mules_log.dart';
import 'package:muyes/models/poop_log.dart';
import 'package:muyes/models/timeline_entry.dart';
import 'package:muyes/providers.dart';

/// Helper test widget Muyes.
///
/// Layar Home/History/Kalender baca data lewat Drift `.watch()` stream.
/// Kalau dites pakai DB asli, kombinasi fake-clock `pumpAndSettle()` +
/// stream asli bikin deadlock (spinner muter terus / timer nyangkut).
/// Solusi: override semua provider stream dengan data statis — widget test
/// jadi deterministik, dan DB tetap dites terpisah di test DAO.
Widget wrapScreenWithData(
  Widget screen, {
  List<FoodLog> food = const [],
  List<PoopLog> poop = const [],
  List<MulesLog> mules = const [],
  bool fastingMode = false,
  DateTime? now,
}) {
  final entries = <TimelineEntry>[
    ...food.map(TimelineEntry.food),
    ...poop.map(TimelineEntry.poop),
    ...mules.map(TimelineEntry.mules),
  ]..sort((a, b) => a.time.compareTo(b.time));

  // Input AI statis — biar Home/Insights bisa dites tanpa DB nyata.
  final input = MuyesAiInput(
    food: food,
    poop: poop,
    mules: mules,
    now: now ?? DateTime.now(),
    fastingMode: fastingMode,
  );
  final analysis = MuyesAnalyzer(input).analyze(days: 7, thirtyDays: true);

  return ProviderScope(
    overrides: [
      dayFoodLogsProvider.overrideWith((ref) => Stream.value(food)),
      dayPoopLogsProvider.overrideWith((ref) => Stream.value(poop)),
      dayMulesLogsProvider.overrideWith((ref) => Stream.value(mules)),
      allFoodLogsProvider.overrideWith((ref) => Stream.value(food)),
      allPoopLogsProvider.overrideWith((ref) => Stream.value(poop)),
      allMulesLogsProvider.overrideWith((ref) => Stream.value(mules)),
      // Timeline gabungan — langsung dari data statis juga.
      dayTimelineProvider.overrideWith(
        (ref) => AsyncData<List<TimelineEntry>>(entries),
      ),
      // Provider AI — statis, tanpa DB.
      aiInputProvider.overrideWith((ref) => AsyncData(input)),
      aiAnalysisProvider.overrideWith((ref) => AsyncData(analysis)),
      aiWeeklySummaryProvider.overrideWith(
        (ref) => AsyncData(buildWeeklySummary(input)),
      ),
      stomachStatusProvider.overrideWith(
        (ref) => AsyncData(stomachStatusForToday(input)),
      ),
      eatingStatusProvider.overrideWith(
        (ref) => AsyncData(eatingStatusForToday(input)),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('id'),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: screen,
    ),
  );
}

/// Pump beberapa frame + microtask biar Stream.value kelar dan widget render.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 20));
}

/// Jendela tinggi biar konten muat tanpa scroll.
void useTallWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// FoodLog cepat untuk seed data test.
FoodLog makeFood({
  required String id,
  required DateTime eatenAt,
  String foodName = 'Nasi goreng',
  List<String> categories = const [FoodCategories.nasi],
  int spicyLevel = 0,
  String portion = FoodPortion.sedang,
  String? drink,
  String? note,
}) {
  final created = DateTime(2026, 11, 1, 8);
  return FoodLog(
    id: id,
    eatenAt: eatenAt,
    foodName: foodName,
    categories: categories,
    spicyLevel: spicyLevel,
    portion: portion,
    drink: drink,
    note: note,
    createdAt: created,
    updatedAt: created,
  );
}

/// PoopLog cepat — default cuma waktu (semua detail null).
PoopLog makePoop({
  required String id,
  required DateTime poopedAt,
  int? bristol,
  bool? hasBlood,
  String? color,
  int? painLevel,
}) {
  return PoopLog(
    id: id,
    poopedAt: poopedAt,
    bristol: bristol,
    hasBlood: hasBlood,
    color: color,
    painLevel: painLevel,
    createdAt: poopedAt,
    updatedAt: poopedAt,
  );
}

/// MulesLog cepat.
MulesLog makeMules({
  required String id,
  required DateTime feltAt,
  int painLevel = 3,
}) {
  return MulesLog(
    id: id,
    feltAt: feltAt,
    painLevel: painLevel,
    createdAt: feltAt,
    updatedAt: feltAt,
  );
}
