import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'main_shell.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: MuyesApp()));
}

/// Muyes — Makan apa, eek gimana, perut bilang apa.
///
/// Local-first: tanpa akun, tanpa backend, tanpa internet.
class MuyesApp extends StatelessWidget {
  const MuyesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muyes',
      debugShowCheckedModeBanner: false,
      locale: const Locale('id'),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildMuyesTheme(),
      home: const MainShell(),
    );
  }
}
