/// Helper tanggal/waktu. Semua waktu lokal device user.
library;

/// Awal hari [dt] (00:00:00.000).
DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Awal hari berikutnya dari [dt] — dipakai sebagai batas atas eksklusif
/// untuk rentang satu hari.
DateTime startOfNextDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day + 1);

/// Hari yang sama? (berdasarkan tanggal lokal)
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Kunci tanggal lokal format `YYYY-MM-DD`, untuk grouping per hari.
String dayKey(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

// ---- Format tampilan (Indonesia, tanpa perlu init locale intl) ----

const _dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sept',
  'Okt',
  'Nov',
  'Des',
];

/// Angka 2 digit, mis. 7 -> "07".
String twoDigits(int n) => n.toString().padLeft(2, '0');

/// Jam-menit, mis. "14:32".
String formatTimeId(DateTime dt) =>
    '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';

/// Tanggal pendek Bahasa Indonesia, mis. "Sen, 25 Nov".
String formatDateId(DateTime dt) =>
    '${_dayNames[dt.weekday - 1]}, ${dt.day} ${_monthNames[dt.month - 1]}';

/// Tanggal lengkap Bahasa Indonesia, mis. "25 Nov 2026" (spec §8.1).
String formatFullDateId(DateTime dt) =>
    '${dt.day} ${_monthNames[dt.month - 1]} ${dt.year}';

/// Tanggal lengkap + jam, mis. "25 Nov 2026, 19:56" (spec §8.1 stats).
String formatFullDateTimeId(DateTime dt) =>
    '${formatFullDateId(dt)}, ${formatTimeId(dt)}';

/// Format relatif untuk baris "Terakhir ..." di Home (koreksi user, 25 Nov 2026):
/// hari ini → "Hari ini, 19:56"; kemarin → "Kemarin, 19:56";
/// lebih lama dari kemarin → tanggal lengkap "23 Nov 2026, 19:56".
String formatLastTimeId(DateTime dt, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final day = startOfDay(dt);
  final today = startOfDay(ref);
  if (isSameDay(day, today)) {
    return 'Hari ini, ${formatTimeId(dt)}';
  }
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  if (isSameDay(day, yesterday)) {
    return 'Kemarin, ${formatTimeId(dt)}';
  }
  return formatFullDateTimeId(dt);
}

/// Tanggal + jam, mis. "Sen, 25 Nov · 14:32".
String formatDateTimeId(DateTime dt) => '${formatDateId(dt)} · ${formatTimeId(dt)}';

/// Nama bulan penuh Bahasa Indonesia, mis. "November".
String monthNameId(int month) {
  const full = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return full[month - 1];
}

