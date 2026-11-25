import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/date_utils.dart';

/// Baris waktu yang bisa di-tap untuk ubah tanggal/jam.
///
/// Dipakai di semua form log. Default-nya "sekarang", tapi selalu bisa diedit
/// (spec §5.1 / §5.2 / §5.2b).
class TimeField extends StatelessWidget {
  const TimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: MuyesColors.primary.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.schedule, color: MuyesColors.primary),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: kBodyFont,
            fontWeight: FontWeight.w600,
            color: MuyesColors.textDark,
          ),
        ),
        subtitle: Text(
          formatDateTimeId(value),
          style: const TextStyle(
            fontFamily: kBodyFont,
            color: MuyesColors.textDark,
          ),
        ),
        trailing: const Icon(
          Icons.edit_outlined,
          size: 18,
          color: MuyesColors.primary,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Bottom sheet pilihan waktu: ubah jam, ubah tanggal, atau balik "sekarang".
/// Mengembalikan DateTime baru, atau null kalau user batal.
Future<DateTime?> showTimePickerSheet(
  BuildContext context,
  DateTime current,
) {
  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final now = DateTime.now();
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                formatDateTimeId(current),
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Ubah jam'),
              onTap: () async {
                final picked = await showTimePicker(
                  context: sheetContext,
                  initialTime: TimeOfDay.fromDateTime(current),
                );
                if (picked == null) return;
                if (!sheetContext.mounted) return;
                Navigator.of(sheetContext).pop(
                  DateTime(
                    current.year,
                    current.month,
                    current.day,
                    picked.hour,
                    picked.minute,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Ubah tanggal'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: sheetContext,
                  initialDate: current,
                  firstDate: DateTime(now.year - 5),
                  lastDate: now.add(const Duration(days: 1)),
                );
                if (picked == null) return;
                if (!sheetContext.mounted) return;
                Navigator.of(sheetContext).pop(
                  DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    current.hour,
                    current.minute,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Pakai waktu sekarang'),
              onTap: () => Navigator.of(sheetContext).pop(DateTime.now()),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

/// Dialog konfirmasi hapus log (dipakai mode edit).
Future<bool> confirmDeleteLog(BuildContext context, String what) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Hapus $what?'),
      content: const Text('Log ini bakal dihapus permanen. Yakin?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return result ?? false;
}
