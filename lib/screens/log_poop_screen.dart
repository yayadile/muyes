import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../models/poop_log.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils/uuid_utils.dart';
import '../widgets/bristol_picker.dart';
import '../widgets/duo_button.dart';
import '../widgets/muyes_icons.dart';
import '../widgets/time_field.dart';

/// Form cepat catat eek (spec §5.2).
///
/// Aturan inti: cuma `poopedAt` yang wajib. Tombol Simpan harus aktif
/// walau Bristol dan semua detail kosong. Target: buka → Simpan = <5 detik.
/// Detail lain (warna, urgensi, mules, dll) sembunyi di balik "Tambah detail".
class LogPoopScreen extends ConsumerStatefulWidget {
  const LogPoopScreen({super.key, this.existing});

  /// Kalau diisi, form jadi mode edit (spec §5.2 "Edit & hapus log").
  final PoopLog? existing;

  static Route<bool> route({PoopLog? existing}) => MaterialPageRoute(
    builder: (_) => LogPoopScreen(existing: existing),
  );

  @override
  ConsumerState<LogPoopScreen> createState() => _LogPoopScreenState();
}

class _LogPoopScreenState extends ConsumerState<LogPoopScreen> {
  final _noteController = TextEditingController();

  late DateTime _poopedAt;
  int? _bristol;
  String? _color;
  int? _urgency;
  int? _painLevel;
  bool? _hasBlood;
  bool? _hasMucus;
  String? _duration;
  var _detailsOpen = false;
  var _saving = false;

  /// Penjelasan Bristol saat pertama kali buka form eek (spec §8).
  var _showBristolIntro = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _poopedAt = existing?.poopedAt ?? DateTime.now();
    if (existing != null) {
      _bristol = existing.bristol;
      _color = existing.color;
      _urgency = existing.urgency;
      _painLevel = existing.painLevel;
      _hasBlood = existing.hasBlood;
      _hasMucus = existing.hasMucus;
      _duration = existing.duration;
      _noteController.text = existing.note ?? '';
      _detailsOpen = _hasAnyDetail(existing);
    }
    _loadBristolIntro();
  }

  Future<void> _loadBristolIntro() async {
    final seen = await ref
        .read(appDatabaseProvider)
        .getBoolSetting(SettingKeys.seenBristolIntro);
    if (!mounted || seen) return;
    setState(() => _showBristolIntro = true);
  }

  Future<void> _dismissBristolIntro() async {
    setState(() => _showBristolIntro = false);
    await ref
        .read(appDatabaseProvider)
        .setBoolSetting(SettingKeys.seenBristolIntro, true);
  }

  static bool _hasAnyDetail(PoopLog log) =>
      log.color != null ||
      log.urgency != null ||
      log.painLevel != null ||
      log.hasBlood != null ||
      log.hasMucus != null ||
      log.duration != null ||
      (log.note != null && log.note!.isNotEmpty);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePickerSheet(context, _poopedAt);
    if (picked != null) setState(() => _poopedAt = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final log = PoopLog(
      id: widget.existing?.id ?? newUuid(),
      poopedAt: _poopedAt,
      bristol: _bristol,
      color: _color,
      urgency: _urgency,
      painLevel: _painLevel,
      hasBlood: _hasBlood,
      hasMucus: _hasMucus,
      duration: _duration,
      note: _emptyToNull(_noteController.text),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    // Cuma butuh 1 insert — field kosong tersimpan sebagai NULL,
    // bukan 0 / normal (spec §5.5).
    await ref.read(poopLogDaoProvider).upsert(log);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: MuyesColors.cream,
      appBar: AppBar(
        title: Row(
          children: [
            const MuyesIconView(MuyesIcon.poop, size: 28),
            const SizedBox(width: 10),
            Text(_isEditing ? 'Edit eek' : 'Catat eek'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TimeField(label: 'Waktu eek', value: _poopedAt, onTap: _pickTime),
          const SizedBox(height: 8),
          Text(
            'Cuma isi waktu juga udah cukup — detail lainnya opsional semua.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bentuk eek (Bristol) — opsional',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_bristol != null)
                TextButton(
                  onPressed: () => setState(() => _bristol = null),
                  child: const Text('Kosongkan'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap salah satu kalau mau. Nggak diisi pun nggak masalah.',
            style: theme.textTheme.bodySmall,
          ),
          if (_showBristolIntro) ...[
            const SizedBox(height: 10),
            _BristolIntroCard(onDismiss: _dismissBristolIntro),
          ],
          const SizedBox(height: 8),
          BristolPicker(
            value: _bristol,
            onChanged: (value) => setState(() => _bristol = value),
          ),
          const SizedBox(height: 16),
          _DetailsExpansion(
            expanded: _detailsOpen,
            onToggle: () => setState(() => _detailsOpen = !_detailsOpen),
            child: _DetailsForm(
              color: _color,
              urgency: _urgency,
              painLevel: _painLevel,
              hasBlood: _hasBlood,
              hasMucus: _hasMucus,
              duration: _duration,
              noteController: _noteController,
              onColorChanged: (value) => setState(() => _color = value),
              onUrgencyChanged: (value) => setState(() => _urgency = value),
              onPainChanged: (value) => setState(() => _painLevel = value),
              onBloodChanged: (value) => setState(() => _hasBlood = value),
              onMucusChanged: (value) => setState(() => _hasMucus = value),
              onDurationChanged: (value) => setState(() => _duration = value),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DuoButton.primary(
            // Selalu aktif — waktu udah keisi otomatis (spec §5.2).
            onPressed: _saving ? null : _save,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_rounded),
                const SizedBox(width: 8),
                Text(_isEditing ? 'Simpan perubahan' : 'Simpan'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BristolIntroCard extends StatelessWidget {
  const _BristolIntroCard({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.primary.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('ℹ️ '),
                Expanded(
                  child: Text(
                    'Bristol itu apa?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Skala Bristol itu patokan bentuk eek, dari 1 sampai 7. '
              'Yang paling ideal itu nomor 4 (sosis halus). Nomor 1-2 '
              'artinya keras, nomor 6-7 artinya lembek / cair.\n\n'
              'Nggak wajib diisi. Tapi makin sering diisi, makin jago '
              'AI-nya baca pola perutmu.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDismiss,
                child: const Text('Oke, ngerti'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsExpansion extends StatelessWidget {
  const _DetailsExpansion({
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: onToggle,
          icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          label: Text(expanded ? 'Tutup detail' : 'Tambah detail (opsional)'),
        ),
        if (expanded) ...[const SizedBox(height: 12), child],
      ],
    );
  }
}

class _DetailsForm extends StatelessWidget {
  const _DetailsForm({
    required this.color,
    required this.urgency,
    required this.painLevel,
    required this.hasBlood,
    required this.hasMucus,
    required this.duration,
    required this.noteController,
    required this.onColorChanged,
    required this.onUrgencyChanged,
    required this.onPainChanged,
    required this.onBloodChanged,
    required this.onMucusChanged,
    required this.onDurationChanged,
  });

  final String? color;
  final int? urgency;
  final int? painLevel;
  final bool? hasBlood;
  final bool? hasMucus;
  final String? duration;
  final TextEditingController noteController;
  final ValueChanged<String?> onColorChanged;
  final ValueChanged<int?> onUrgencyChanged;
  final ValueChanged<int?> onPainChanged;
  final ValueChanged<bool?> onBloodChanged;
  final ValueChanged<bool?> onMucusChanged;
  final ValueChanged<String?> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DetailTitle('Warna'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in PoopColors.all)
              ChoiceChip(
                label: Text(option),
                selected: color == option,
                onSelected: (selected) =>
                    onColorChanged(selected ? option : null),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const _DetailTitle('Urgensi'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var level = 0; level <= 3; level++)
              ChoiceChip(
                label: Text(_urgencyLabel(level)),
                selected: urgency == level,
                onSelected: (selected) =>
                    onUrgencyChanged(selected ? level : null),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const _DetailTitle('Mules / nyeri perut'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in const [
              (0, 'Nggak mules'),
              (1, 'Ringan'),
              (3, 'Sedang'),
              (5, 'Parah'),
            ])
              ChoiceChip(
                label: Text(option.$2),
                selected: painLevel == option.$1,
                onSelected: (selected) =>
                    onPainChanged(selected ? option.$1 : null),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Kalau mulesnya udah dicatat terpisah di + Mules, skip aja bagian ini.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        const _DetailTitle('Ada darah?'),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Nggak')),
            ButtonSegment(value: true, label: Text('Ada')),
          ],
          selected: hasBlood == null ? const {} : {hasBlood!},
          emptySelectionAllowed: true,
          onSelectionChanged: (value) =>
              onBloodChanged(value.isEmpty ? null : value.first),
        ),
        const SizedBox(height: 16),
        const _DetailTitle('Ada lendir?'),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Nggak')),
            ButtonSegment(value: true, label: Text('Ada')),
          ],
          selected: hasMucus == null ? const {} : {hasMucus!},
          emptySelectionAllowed: true,
          onSelectionChanged: (value) =>
              onMucusChanged(value.isEmpty ? null : value.first),
        ),
        const SizedBox(height: 16),
        const _DetailTitle('Durasi'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in PoopDurations.all)
              ChoiceChip(
                label: Text(option),
                selected: duration == option,
                onSelected: (selected) =>
                    onDurationChanged(selected ? option : null),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: noteController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Catatan (opsional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  static String _urgencyLabel(int level) => switch (level) {
    0 => 'Santai',
    1 => 'Lumayan kebelet',
    2 => 'Harus buru-buru',
    _ => 'Hampir nggak ketahan',
  };
}

class _DetailTitle extends StatelessWidget {
  const _DetailTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
