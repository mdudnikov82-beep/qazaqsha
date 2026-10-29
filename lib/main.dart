import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'data/providers.dart';
import 'features/splash/splash_gate.dart';

void main() {
  runApp(const ProviderScope(child: QazaqshaApp()));
}

class QazaqshaApp extends ConsumerStatefulWidget {
  const QazaqshaApp({super.key});

  @override
  ConsumerState<QazaqshaApp> createState() => _QazaqshaAppState();
}

class _QazaqshaAppState extends ConsumerState<QazaqshaApp> {
  /// Bumped when "onboarding done" changes, to re-run the router redirect.
  final _onboardingChanged = ValueNotifier(0);

  late final GoRouter _router = createRouter(
    onboardingDone: () => ref.read(statsProvider).value?.onboardingDone,
    refresh: _onboardingChanged,
  );

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      statsProvider.select((s) => s.value?.onboardingDone),
      (_, _) => _onboardingChanged.value++,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _onboardingChanged.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    final ready = ref.watch(statsProvider.select((s) => !s.isLoading));
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
      builder: (context, child) => SplashGate(ready: ready, child: child!),
    );
  }
}
