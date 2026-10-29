import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/ornament.dart';

/// Covers the app with the branded loading screen until [ready] and a short
/// minimum time have passed, then fades it out. Continues the native splash
/// (same teal, same «Ә» tile) so the start feels like one screen.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.ready, required this.child});

  final bool ready;
  final Widget child;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  static const _minShown = Duration(milliseconds: 1400);

  Timer? _timer;
  bool _minElapsed = false;
  bool _gone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timer != null || _minElapsed) return;
    // With reduced motion there is nothing to watch: leave as soon as ready.
    if (reduceMotion(context)) {
      _minElapsed = true;
    } else {
      _timer = Timer(_minShown, () => setState(() => _minElapsed = true));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final show = !(widget.ready && _minElapsed);
    // Without motion there is no fade: the splash just goes.
    final gone = _gone || (!show && reduceMotion(context));
    return Stack(
      children: [
        widget.child,
        if (!gone)
          IgnorePointer(
            ignoring: !show,
            child: AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: const Duration(milliseconds: 350),
              onEnd: () {
                if (!show && mounted) setState(() => _gone = true);
              },
              child: const SplashView(),
            ),
          ),
      ],
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final band = Colors.white.withValues(alpha: 0.16);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: AppColors.primary,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(child: _Bands(color: band)),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(child: _Bands(color: band)),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryShadow,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Ә',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 84,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Qazaqsha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Қазақ тілін үйрен!',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _LoadingDots(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bands extends StatelessWidget {
  const _Bands({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        OrnamentBand(color: color, height: 32, tile: 54),
        const SizedBox(height: 14),
        OrnamentBand(color: color, height: 32, tile: 54),
      ],
    ),
  );
}

/// Three dots lighting up in turn; static with reduced motion.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Загрузка',
    child: AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final active = (_c.value * 3).floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: i == active || !_c.isAnimating ? 1 : 0.4,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        );
      },
    ),
  );
}
