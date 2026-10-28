import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'data/providers.dart';

void main() {
  runApp(const ProviderScope(child: QazaqshaApp()));
}

class QazaqshaApp extends ConsumerStatefulWidget {
  const QazaqshaApp({super.key});

  @override
  ConsumerState<QazaqshaApp> createState() => _QazaqshaAppState();
}

class _QazaqshaAppState extends ConsumerState<QazaqshaApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Qazaqsha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // AppThemeMode is declared in the same order as ThemeMode.
      themeMode: ThemeMode.values[mode.index],
      // Switch instantly: cross-fading every color of the theme makes the
      // tap feel laggy, especially on slower phones.
      themeAnimationStyle: AnimationStyle.noAnimation,
      routerConfig: _router,
    );
  }
}
