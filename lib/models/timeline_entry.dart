import 'food_log.dart';
import 'mules_log.dart';
import 'poop_log.dart';

/// Jenis kejadian di timeline.
enum TimelineKind { food, poop, mules }

extension TimelineKindLabel on TimelineKind {
  /// Nama jenis log dalam Bahasa Indonesia — dipakai dialog hapus, dsb.
  String get labelId => switch (this) {
    TimelineKind.food => 'makan',
    TimelineKind.poop => 'eek',
    TimelineKind.mules => 'mules',
  };
}

/// Satu kejadian timeline gabungan: makan / eek / mules (spec §5.3).
class TimelineEntry {
  const TimelineEntry._({
    required this.kind,
    required this.time,
    this.food,
    this.poop,
    this.mules,
  });

  factory TimelineEntry.food(FoodLog log) =>
      TimelineEntry._(kind: TimelineKind.food, time: log.eatenAt, food: log);

  factory TimelineEntry.poop(PoopLog log) =>
      TimelineEntry._(kind: TimelineKind.poop, time: log.poopedAt, poop: log);

  factory TimelineEntry.mules(MulesLog log) =>
      TimelineEntry._(kind: TimelineKind.mules, time: log.feltAt, mules: log);

  final TimelineKind kind;
  final DateTime time;

  /// Terisi kalau [kind] == food.
  final FoodLog? food;

  /// Terisi kalau [kind] == poop.
  final PoopLog? poop;

  /// Terisi kalau [kind] == mules.
  final MulesLog? mules;

  /// Id log asli — buat buka form edit / hapus.
  String get id => food?.id ?? poop?.id ?? mules!.id;
}
