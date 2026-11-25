import 'package:flutter/foundation.dart' show listEquals;

/// Hasil analisa AI lokal (spec §5.5 / §6). Di-generate, bukan diinput user.
class Insight {
  const Insight({
    required this.id,
    required this.type,
    required this.level,
    required this.title,
    required this.body,
    required this.confidence,
    this.evidenceLogIds = const <String>[],
    this.periodDays = 7,
    required this.createdAt,
    this.isRead = false,
  });

  /// Id deterministik (mis. 'abnormal:diare-berulang:7') biar re-generate tidak duplikat.
  final String id;

  /// Isi dari [InsightType].
  final String type;

  /// Isi dari [InsightLevel].
  final String level;

  final String title;

  /// Body insight — selalu Bahasa Indonesia, santai, tanpa diagnosis.
  final String body;

  /// Isi dari [InsightConfidence].
  final String confidence;

  /// Id FoodLog / PoopLog / MulesLog pendukung — untuk "Kenapa AI bilang ini?".
  final List<String> evidenceLogIds;

  /// 7 atau 30.
  final int periodDays;

  final DateTime createdAt;

  final bool isRead;

  Insight copyWith({bool? isRead}) {
    return Insight(
      id: id,
      type: type,
      level: level,
      title: title,
      body: body,
      confidence: confidence,
      evidenceLogIds: evidenceLogIds,
      periodDays: periodDays,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Insight &&
      other.id == id &&
      other.type == type &&
      other.level == level &&
      other.title == title &&
      other.body == body &&
      other.confidence == confidence &&
      listEquals(other.evidenceLogIds, evidenceLogIds) &&
      other.periodDays == periodDays &&
      other.createdAt == createdAt &&
      other.isRead == isRead;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    level,
    title,
    body,
    confidence,
    Object.hashAll(evidenceLogIds),
    periodDays,
    createdAt,
    isRead,
  );

  @override
  String toString() => 'Insight($id, $type/$level, "$title")';
}

/// Jenis insight (spec §6).
abstract final class InsightType {
  static const correlation = 'correlation';
  static const abnormal = 'abnormal';
  static const eatingPattern = 'eating_pattern';
  static const weeklySummary = 'weekly_summary';
}

/// Level insight (spec §6). Hijau/kuning/merah hanya untuk level waspada.
abstract final class InsightLevel {
  static const info = 'info';
  static const warning = 'warning';
  static const alert = 'alert';
}

/// Confidence insight (spec §5.5A) — jujur, berdasarkan jumlah sampel.
abstract final class InsightConfidence {
  static const rendah = 'Rendah';
  static const sedang = 'Sedang';
  static const tinggi = 'Tinggi';
}
