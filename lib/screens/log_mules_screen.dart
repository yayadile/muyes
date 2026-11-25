import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mules_log.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils/uuid_utils.dart';
import '../widgets/duo_button.dart';
import '../widgets/mules_level_picker.dart';
import '../widgets/muyes_icons.dart';
import '../widgets/time_field.dart';

/// Form mini catat mules (spec §5.2b). Target: 2 tap → Simpan.
class LogMulesScreen extends ConsumerStatefulWidget {
  const LogMulesScreen({super.key, this.existing});

  /// Kalau diisi, form jadi mode edit.
  final MulesLog? existing;

  static Route<bool> route({MulesLog? existing}) => MaterialPageRoute(
    builder: (_) => LogMulesScreen(existing: existing),
  );

  @override
  ConsumerState<LogMulesScreen> createState() => _LogMulesScreenState();
}

class _LogMulesScreenState extends ConsumerState<LogMulesScreen> {
  final _noteController = TextEditingController();

  late DateTime _feltAt;
  int? _painLevel;
  var _saving = false;

  bool get _isEditing => widget.existing != null;
  bool get _canSave => _painLevel != null && !_saving;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _feltAt = existing?.feltAt ?? DateTime.now();
    if (existing != null) {
      _painLevel = existing.painLevel;
      _noteController.text = existing.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePickerSheet(context, _feltAt);
    if (picked != null) setState(() => _feltAt = picked);
  }

  Future<void> _save() async {
    final level = _painLevel;
    if (level == null || _saving) return;

    setState(() => _saving = true);
    final now = DateTime.now();
    final log = MulesLog(
      id: widget.existing?.id ?? newUuid(),
      feltAt: _feltAt,
      painLevel: level,
      note: _emptyToNull(_noteController.text),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(mulesLogDaoProvider).upsert(log);
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
            const MuyesIconView(MuyesIcon.muyes, size: 28),
            const SizedBox(width: 10),
            Text(_isEditing ? 'Edit mules' : 'Catat mules'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Seberapa mules perutmu?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          MulesLevelPicker(
            value: _painLevel,
            onChanged: (value) => setState(() => _painLevel = value),
          ),
          const SizedBox(height: 20),
          TimeField(label: 'Waktu mules', value: _feltAt, onTap: _pickTime),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              hintText: 'Mis. habis makan seblak',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DuoButton.primary(
            // Pilih level → Simpan. 2 tap, kelar (spec §5.2b).
            onPressed: _canSave ? _save : null,
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

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
