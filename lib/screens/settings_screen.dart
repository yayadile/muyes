import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/backup_service.dart';
import '../data/database.dart';
import '../data/demo_seed.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils/date_utils.dart';
import '../widgets/duo_button.dart';

/// Pengaturan (spec §5.6).
///
/// - Ekspor data: JSON (backup lengkap, bisa diimpor balik) + CSV (3 file
///   buat Excel/Sheets).
/// - Impor data dari backup JSON (merge — nggak menghapus data lama).
/// - Mode Puasa / Intermittent Fasting (mengalir ke AI, spec §5.5D).
/// - Isi / Hapus data contoh (spec §10).
/// - Hapus semua data: konfirmasi 2x (spec §5.6).
/// - Tentang + disclaimer medis.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fasting = ref.watch(fastingModeProvider).value ?? false;
    final demoSeeded = ref.watch(demoSeededProvider).value ?? false;

    return Scaffold(
      backgroundColor: MuyesColors.cream,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          _FastingCard(
            value: fasting,
            onChanged: (value) => ref
                .read(appDatabaseProvider)
                .setBoolSetting(SettingKeys.fastingMode, value),
          ),
          const SizedBox(height: 16),
          const _ExportCard(),
          const SizedBox(height: 16),
          const _ImportCard(),
          const SizedBox(height: 16),
          _DemoDataCard(
            seeded: demoSeeded,
            onSeed: () => _seedDemoData(context, ref),
            onRemove: () => _removeDemoData(context, ref),
          ),
          const SizedBox(height: 16),
          const _DangerCard(),
          const SizedBox(height: 16),
          const _AboutCard(),
        ],
      ),
    );
  }

  Future<void> _seedDemoData(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    await applyDemoSeed(db, buildDemoSeed());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data contoh 14 hari terpasang. Buka Insights / Riwayat buat lihat polanya.'),
      ),
    );
  }

  Future<void> _removeDemoData(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    await removeDemoData(db);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data contoh dihapus. Data aslimu tetap aman.')),
    );
  }
}

/// Card toggle Mode Puasa (spec §5.5D + §5.6).
class _FastingCard extends StatelessWidget {
  const _FastingCard({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        activeThumbColor: Colors.white,
        activeTrackColor: MuyesColors.primary,
        title: const Text(
          'Mode Puasa / Intermittent Fasting',
          style: TextStyle(
            fontFamily: kHeadingFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MuyesColors.textDark,
          ),
        ),
        subtitle: Text(
          'Kalau ON, peringatan "skip makan" dan "gap makan panjang" '
          'dimatikan — analisa lain tetap jalan.',
          style: TextStyle(
            fontFamily: kBodyFont,
            fontSize: 13,
            color: MuyesColors.textDark.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

/// Ekspor JSON (backup lengkap) + CSV (3 file buat Excel).
class _ExportCard extends ConsumerStatefulWidget {
  const _ExportCard();

  @override
  ConsumerState<_ExportCard> createState() => _ExportCardState();
}

class _ExportCardState extends ConsumerState<_ExportCard> {
  var _busy = false;

  Future<void> _exportJson() async {
    setState(() => _busy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final json = exportBackupJson(
        food: await FoodLogDao(db).getAll(),
        poop: await PoopLogDao(db).getAll(),
        mules: await MulesLogDao(db).getAll(),
      );
      final path = await _writeExportFile(
        'muyes-backup-${dayKey(DateTime.now())}.json',
        json,
      );
      await _shareFiles([path], 'Backup Muyes (JSON)');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _busy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final day = dayKey(DateTime.now());
      final files = <String>[
        await _writeExportFile(
          'muyes-makan-$day.csv',
          exportFoodCsv(await FoodLogDao(db).getAll()),
        ),
        await _writeExportFile(
          'muyes-eek-$day.csv',
          exportPoopCsv(await PoopLogDao(db).getAll()),
        ),
        await _writeExportFile(
          'muyes-mules-$day.csv',
          exportMulesCsv(await MulesLogDao(db).getAll()),
        ),
      ];
      await _shareFiles(files, 'Export Muyes (CSV)');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _writeExportFile(String name, String contents) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    await file.writeAsString(contents);
    return file.path;
  }

  Future<void> _shareFiles(List<String> paths, String title) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [for (final path in paths) XFile(path)],
        subject: title,
        text: 'Data Muyes — semua lokal, nggak dikirim ke server mana pun.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.ios_share_rounded,
      title: 'Ekspor Data',
      description:
          'JSON = backup lengkap (bisa diimpor balik). CSV = 3 file '
          'makan/eek/mules buat dibuka di Excel / Google Sheets.',
      children: [
        DuoButton.secondary(
          onPressed: _busy ? null : _exportJson,
          child: const Text('Ekspor JSON (backup)'),
        ),
        const SizedBox(height: 10),
        DuoButton.secondary(
          onPressed: _busy ? null : _exportCsv,
          child: const Text('Ekspor CSV (Excel)'),
        ),
      ],
    );
  }
}

/// Impor dari file backup JSON.
class _ImportCard extends ConsumerStatefulWidget {
  const _ImportCard();

  @override
  ConsumerState<_ImportCard> createState() => _ImportCardState();
}

class _ImportCardState extends ConsumerState<_ImportCard> {
  var _busy = false;

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final picked = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Backup Muyes (JSON)', extensions: ['json']),
        ],
      );
      if (picked == null) return;

      final BackupBundle bundle;
      try {
        bundle = parseBackupJson(await picked.readAsString());
      } on FormatException catch (error) {
        _showMessage('Gagal impor: ${error.message}');
        return;
      }

      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Impor data?'),
          content: Text(
            'File ini berisi ${bundle.summary}. Log dengan id yang sama '
            'akan di-update, sisanya ditambahkan. Data yang sudah ada '
            'nggak dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Impor'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final result = await importBundle(ref.read(appDatabaseProvider), bundle);
      _showMessage('Impor selesai: ${result.summary}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.download_rounded,
      title: 'Impor Data',
      description:
          'Pilih file backup JSON (hasil "Ekspor JSON") buat balikin / '
          'gabungin data.',
      children: [
        DuoButton.secondary(
          onPressed: _busy ? null : _import,
          child: const Text('Pilih file backup...'),
        ),
      ],
    );
  }
}

/// Isi / hapus data contoh (spec §10).
class _DemoDataCard extends StatelessWidget {
  const _DemoDataCard({
    required this.seeded,
    required this.onSeed,
    required this.onRemove,
  });

  final bool seeded;
  final VoidCallback onSeed;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.science_rounded,
      title: 'Data Contoh',
      description:
          '14 hari data dummy lengkap (pedas → mules, diare, makan larut '
          'malam, dll) buat coba semua analisa AI. Data asli kamu nggak '
          'kesentuh.',
      children: [
        DuoButton.secondary(
          onPressed: seeded ? null : onSeed,
          child: Text(seeded ? 'Data contoh terpasang' : 'Isi data contoh'),
        ),
        if (seeded) ...[
          const SizedBox(height: 10),
          DuoButton.secondary(
            onPressed: onRemove,
            child: const Text('Hapus data contoh'),
          ),
        ],
      ],
    );
  }
}

/// Hapus semua data — konfirmasi 2x (spec §5.6).
class _DangerCard extends ConsumerWidget {
  const _DangerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsCard(
      icon: Icons.delete_forever_rounded,
      iconColor: MuyesColors.red,
      title: 'Hapus Semua Data',
      description:
          'Menghapus SEMUA log makan / eek / mules + hasil analisa. '
          'Setting tetap. Nggak bisa dibatalkan.',
      children: [
        DuoButton(
          onPressed: () => _confirmDelete(context, ref),
          backgroundColor: MuyesColors.red,
          shadowColor: const Color(0xFF8E2A20),
          child: const Text('Hapus semua data'),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final first = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua data?'),
        content: const Text(
          'Semua catatan makan, eek, mules, dan hasil analisa bakal hilang '
          'permanen. Pastikan sudah ekspor backup kalau perlu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MuyesColors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
    if (first != true || !context.mounted) return;

    // Konfirmasi kedua — spec §5.6 minta konfirmasi 2x.
    final second = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yakin banget?'),
        content: const Text('Ini terakhir. Nggak ada undo, nggak ada recycle bin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MuyesColors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ya, hapus semuanya'),
          ),
        ],
      ),
    );
    if (second != true) return;

    await ref.read(appDatabaseProvider).deleteAllLogs();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua data sudah dihapus. Mulai dari bersih lagi.')),
    );
  }
}

/// Tentang + disclaimer medis (spec §5.6).
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.favorite_rounded,
      title: 'Tentang Muyes',
      description:
          'Muyes bantu kamu nyatet makan, eek, dan mules — terus dikasih '
          'analisa pola dari datamu sendiri.\n\n'
          'Semua data tersimpan di HP-mu. Nggak ada akun, nggak ada '
          'cloud, app jalan 100% offline.\n\n'
          'Disclaimer: Muyes bukan alat medis dan bukan pengganti dokter. '
          'Insight-nya cuma pola dari catatanmu. Kalau ada keluhan yang '
          'mengganggu / berlanjut, pertimbangkan konsultasi ke dokter.',
      children: const [],
    );
  }
}

/// Kartu dasar buat section Settings — ikon + judul + deskripsi + aksi.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.children,
    this.iconColor = MuyesColors.primary,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: kHeadingFont,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: MuyesColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontFamily: kBodyFont,
                fontSize: 13.5,
                height: 1.45,
                color: MuyesColors.textDark.withValues(alpha: 0.75),
              ),
            ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final child in children) ...[child, const SizedBox(height: 2)],
            ],
          ],
        ),
      ),
    );
  }
}
