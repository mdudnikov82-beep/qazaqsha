import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'data/providers.dart';

void main() {
  runApp(const ProviderScope(child: QazaqshaApp()));
}

class QazaqshaApp extends ConsumerWidget {
  const QazaqshaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(statsProvider).value?.themeMode;
    return MaterialApp.router(
      title: 'Qazaqsha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // AppThemeMode is declared in the same order as ThemeMode.
      themeMode: mode == null ? ThemeMode.system : ThemeMode.values[mode.index],
      routerConfig: appRouter,
    );
  }
}
