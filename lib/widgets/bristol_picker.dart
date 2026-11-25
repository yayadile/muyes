import 'package:flutter/material.dart';

import '../utils/bristol_info.dart';

/// Picker Bristol visual 1-7 (spec §5.2 / §8).
///
/// Wajib ada bentuk + deskripsi, bukan dropdown angka. Tetap opsional:
/// tap pilihan yang sama dua kali untuk membatalkan (kembali kosong).
class BristolPicker extends StatelessWidget {
  const BristolPicker({super.key, this.value, required this.onChanged});

  /// Nilai terpilih 1-7, atau null kalau belum diisi.
  final int? value;

  /// Dipanggil dengan 1-7, atau null kalau dibatalkan.
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final info in BristolInfo.all) ...[
          _BristolTile(
            info: info,
            selected: value == info.scale,
            onTap: () => onChanged(value == info.scale ? null : info.scale),
          ),
          if (info.scale != 7) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _BristolTile extends StatelessWidget {
  const _BristolTile({
    required this.info,
    required this.selected,
    required this.onTap,
  });

  final BristolInfo info;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accent : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? accent.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            _BristolShape(scale: info.scale, selected: selected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${info.scale}. ${info.title}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(info.description, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: accent, size: 20)
            else
              Icon(
                Icons.radio_button_unchecked,
                color: theme.colorScheme.outlineVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Bentuk visual per skala — makin besar angka makin melebar / cair.
class _BristolShape extends StatelessWidget {
  const _BristolShape({required this.scale, required this.selected});

  final int scale;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return SizedBox(
      width: 44,
      height: 40,
      child: CustomPaint(painter: _BristolShapePainter(scale, color)),
    );
  }
}

class _BristolShapePainter extends CustomPainter {
  const _BristolShapePainter(this.scale, this.color);

  final int scale;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (scale) {
      case 1:
        // Kelereng kecil-kecil.
        for (final offset in const [
          Offset(-10, -8),
          Offset(2, -12),
          Offset(-2, 4),
          Offset(10, 2),
        ]) {
          canvas.drawCircle(
            Offset(cx + offset.dx, cy + offset.dy),
            4,
            paint,
          );
        }
      case 2:
        // Sosis bergumpal.
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(Offset(cx - 10 + i * 10.0, cy), 6, paint);
        }
      case 3:
        // Sosis dengan retakan.
        _roundedBar(canvas, size, paint, crack: true);
      case 4:
        // Sosis halus.
        _roundedBar(canvas, size, paint, crack: false);
      case 5:
        // Gumpalan lunak bertumpuk.
        for (final offset in const [
          Offset(-8, -4),
          Offset(6, -6),
          Offset(0, 6),
        ]) {
          canvas.drawCircle(Offset(cx + offset.dx, cy + offset.dy), 7, paint);
        }
      case 6:
        // Lembek — tidak beraturan.
        for (final offset in const [
          Offset(-12, 2),
          Offset(-2, -6),
          Offset(8, 0),
          Offset(0, 8),
        ]) {
          canvas.drawCircle(Offset(cx + offset.dx, cy + offset.dy), 6.5, paint);
        }
      case 7:
        // Cair — gelombang.
        final wave = Path()..moveTo(4, cy + 6);
        for (var x = 4.0; x <= size.width - 4; x += 8) {
          wave.quadraticBezierTo(x + 4, cy - 8, x + 8, cy + 2);
        }
        canvas.drawPath(
          wave,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  /// Bentuk sosis (skala 3 & 4).
  void _roundedBar(
    Canvas canvas,
    Size size,
    Paint paint, {
    required bool crack,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(5, size.height / 2 - 7, size.width - 10, 14),
      const Radius.circular(7),
    );
    canvas.drawRRect(rect, paint);
    if (crack) {
      canvas.drawLine(
        Offset(size.width * 0.4, size.height / 2 - 5),
        Offset(size.width * 0.45, size.height / 2 + 1),
        Paint()
          ..color = const Color(0xFFFBF6EF)
          ..strokeWidth = 2.5,
      );
      canvas.drawLine(
        Offset(size.width * 0.62, size.height / 2 + 1),
        Offset(size.width * 0.66, size.height / 2 + 6),
        Paint()
          ..color = const Color(0xFFFBF6EF)
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(_BristolShapePainter oldDelegate) =>
      oldDelegate.scale != scale || oldDelegate.color != color;
}
