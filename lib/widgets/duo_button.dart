import 'package:flutter/material.dart';

import '../theme.dart';

/// Tombol 3D ala Duolingo (spec §8.1).
///
/// Struktur: alas lebih gelap 4dp di bawah muka tombol. Saat ditekan,
/// muka tombol "turun" menutupi alas — chunky & playful. Dipakai untuk
/// tombol Simpan + tombol + Eek / + Makan / + Mules.
///
/// Muka tombol adalah [FilledButton] asli, jadi aksesibilitas &
/// disabled-state standar tetap jalan.
class DuoButton extends StatefulWidget {
  const DuoButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = MuyesColors.primary,
    this.foregroundColor = Colors.white,
    this.shadowColor = MuyesColors.primaryDark,
    this.borderColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.expand = false,
  });

  /// Tombol utama — orange penuh (tombol Simpan form, spec §8.1).
  const DuoButton.primary({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.expand = true,
  }) : backgroundColor = MuyesColors.primary,
       foregroundColor = Colors.white,
       shadowColor = MuyesColors.primaryDark,
       borderColor = null;

  /// Tombol sekunder — putih, border orange 2dp (tombol + Poop dll).
  const DuoButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    this.expand = false,
  }) : backgroundColor = Colors.white,
       foregroundColor = MuyesColors.textDark,
       shadowColor = MuyesColors.primaryDark,
       borderColor = MuyesColors.primary;

  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color shadowColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool expand;

  /// Kedalaman alas 3D (spec §8.1: 4dp).
  static const shadowDepth = 4.0;

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final radius = BorderRadius.circular(widget.borderRadius);
    final depth = enabled ? DuoButton.shadowDepth : 0.0;
    final sink = _pressed && enabled ? depth : 0.0;

    final face = FilledButton(
      onPressed: widget.onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        foregroundColor: widget.foregroundColor,
        disabledBackgroundColor: widget.backgroundColor.withValues(alpha: 0.45),
        disabledForegroundColor: widget.foregroundColor.withValues(alpha: 0.7),
        padding: widget.padding,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: widget.borderColor == null
              ? BorderSide.none
              : BorderSide(color: widget.borderColor!, width: 2),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontFamily: kHeadingFont,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: widget.child,
    );

    return Listener(
      onPointerDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onPointerUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onPointerCancel: enabled ? (_) => setState(() => _pressed = false) : null,
      child: DecoratedBox(
        // Alas 3D — lebih gelap; bagian bawahnya terlihat 4dp.
        decoration: BoxDecoration(
          color: enabled ? widget.shadowColor : const Color(0xFFD9D9D9),
          borderRadius: radius,
        ),
        child: AnimatedPadding(
          // Saat ditekan: muka turun menutupi alas → shadow "hilang".
          duration: const Duration(milliseconds: 60),
          padding: EdgeInsets.only(bottom: depth - sink),
          child: widget.expand
              ? SizedBox(width: double.infinity, child: face)
              : face,
        ),
      ),
    );
  }
}
