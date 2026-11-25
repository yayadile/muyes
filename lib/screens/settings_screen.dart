import 'package:flutter/material.dart';

import '../theme.dart';

/// Pengaturan (spec §5.6) — shell tampilan dulu.
///
/// Fitur asli (export CSV/JSON, Mode Puasa, Isi data contoh) masuk di
/// Phase 6. Layar ini sengaja jujur kosong, bukan fitur palsu.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuyesColors.cream,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.settings_rounded,
                        color: MuyesColors.primary,
                        size: 26,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Segera hadir',
                        style: TextStyle(
                          fontFamily: kHeadingFont,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: MuyesColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ekspor data (CSV/JSON), Mode Puasa / Intermittent '
                    'Fasting, dan Isi data contoh bakal muncul di sini '
                    'setelah tahap Insights selesai.',
                    style: TextStyle(
                      fontFamily: kBodyFont,
                      fontSize: 14,
                      height: 1.4,
                      color: MuyesColors.textDark.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
