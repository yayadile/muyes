import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart' show FoodNameCount;
import '../models/food_log.dart';
import '../providers.dart';
import '../theme.dart';
import '../utils/uuid_utils.dart';
import '../widgets/category_selector.dart';
import '../widgets/duo_button.dart';
import '../widgets/muyes_icons.dart';
import '../widgets/spicy_picker.dart';
import '../widgets/time_field.dart';

/// Form cepat catat makan (spec §5.1). Target <10 detik.
class LogFoodScreen extends ConsumerStatefulWidget {
  const LogFoodScreen({super.key, this.existing});

  /// Kalau diisi, form jadi mode edit (spec §5.1 "Edit & hapus log").
  final FoodLog? existing;

  static Route<bool> route({FoodLog? existing}) => MaterialPageRoute(
    builder: (_) => LogFoodScreen(existing: existing),
  );

  @override
  ConsumerState<LogFoodScreen> createState() => _LogFoodScreenState();
}

class _LogFoodScreenState extends ConsumerState<LogFoodScreen> {
  final _nameController = TextEditingController();
  final _drinkController = TextEditingController();
  final _noteController = TextEditingController();

  late DateTime _eatenAt;
  var _categories = <String>{};
  var _spicyLevel = 0;
  var _portion = FoodPortion.sedang;
  var _saving = false;

  /// Chip "Makan lagi" — makanan yang sering dimakan (spec §5.1).
  List<FoodNameCount> _quickAdds = const [];

  bool get _isEditing => widget.existing != null;
  bool get _canSave => _nameController.text.trim().isNotEmpty && !_saving;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _eatenAt = existing?.eatenAt ?? DateTime.now();
    if (existing != null) {
      _nameController.text = existing.foodName;
      _drinkController.text = existing.drink ?? '';
      _noteController.text = existing.note ?? '';
      _categories = existing.categories.toSet();
      _spicyLevel = existing.spicyLevel;
      _portion = existing.portion;
    }
    _nameController.addListener(() => setState(() {}));
    _loadQuickAdds();
  }

  Future<void> _loadQuickAdds() async {
    final top = await ref.read(foodLogDaoProvider).topFoodNames(limit: 8);
    if (!mounted) return;
    setState(() => _quickAdds = top);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _drinkController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePickerSheet(context, _eatenAt);
    if (picked != null) setState(() => _eatenAt = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving) return;

    setState(() => _saving = true);
    final now = DateTime.now();
    final log = FoodLog(
      id: widget.existing?.id ?? newUuid(),
      eatenAt: _eatenAt,
      foodName: name,
      categories: _categories.toList(growable: false),
      spicyLevel: _spicyLevel,
      portion: _portion,
      drink: _emptyToNull(_drinkController.text),
      note: _emptyToNull(_noteController.text),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(foodLogDaoProvider).upsert(log);
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
            const MuyesIconView(MuyesIcon.meal, size: 28),
            const SizedBox(width: 10),
            Text(_isEditing ? 'Edit makan' : 'Catat makan'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TimeField(label: 'Waktu makan', value: _eatenAt, onTap: _pickTime),
          const SizedBox(height: 16),
          if (_quickAdds.isNotEmpty) ...[
            Text(
              'Makan lagi',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _quickAdds)
                  ActionChip(
                    avatar: const Icon(Icons.replay, size: 16),
                    label: Text(
                      item.count > 1 ? '${item.name} (${item.count}x)' : item.name,
                    ),
                    onPressed: () => setState(() {
                      _nameController.text = item.name;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            autofocus: !_isEditing,
            decoration: const InputDecoration(
              labelText: 'Makan apa?',
              hintText: 'Mis. Mie ayam level 3',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Kategori (boleh banyak)'),
          CategorySelector(
            selected: _categories,
            onChanged: (value) => setState(() => _categories = value),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Level pedas'),
          SpicyPicker(
            value: _spicyLevel,
            onChanged: (value) => setState(() => _spicyLevel = value),
          ),
          const SizedBox(height: 20),
          _SectionTitle('Porsi'),
          SegmentedButton<String>(
            segments: [
              for (final portion in FoodPortion.all)
                ButtonSegment(value: portion, label: Text(portion)),
            ],
            selected: {_portion},
            onSelectionChanged: (value) =>
                setState(() => _portion = value.first),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _drinkController,
            decoration: const InputDecoration(
              labelText: 'Minuman (opsional)',
              hintText: 'Mis. Es teh manis',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Waktu defaultnya "sekarang". Kalau cuma isi nama + simpan, '
            'udah cukup kok.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DuoButton.primary(
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

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
