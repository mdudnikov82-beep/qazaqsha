import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/theme.dart';
import 'data/providers.dart';
import 'features/watch/watch_screens.dart';

/// Entry point of the Galaxy Watch / Wear OS build:
/// flutter build apk --flavor watch -t lib/main_watch.dart
void main() {
  runApp(const ProviderScope(child: WatchApp()));
}

class WatchApp extends ConsumerWidget {
  const WatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches are dark: an OLED screen and little light at night.
    return MaterialApp(
      title: 'Qazaqsha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(ref.watch(paletteProvider), Brightness.dark),
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const WatchHome(),
    );
  }
}
