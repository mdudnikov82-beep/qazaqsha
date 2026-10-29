import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// True when the system asks for less motion (accessibility setting, and
/// in tests). Decorative and looping animations are skipped then.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

abstract final class Haptics {
  /// Follows the "Вибрация" setting in the profile.
  static bool enabled = true;

  static void success() {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void error() {
    if (enabled) HapticFeedback.heavyImpact();
  }

  static void tap() {
    if (enabled) HapticFeedback.selectionClick();
  }
}

enum Reaction { none, pop, shake }

/// Plays a one-off "pop" (right answer) or "shake" (wrong answer) whenever
/// [reaction] changes to that value, or [trigger] changes while it is set.
class ReactionBox extends StatefulWidget {
  const ReactionBox({
    super.key,
    required this.reaction,
    required this.child,
    this.trigger,
  });

  final Reaction reaction;
  final Widget child;
  final Object? trigger;

  @override
  State<ReactionBox> createState() => _ReactionBoxState();
}

class _ReactionBoxState extends State<ReactionBox>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  static final _pop = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.08), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.97), weight: 25),
    TweenSequenceItem(tween: Tween(begin: 0.97, end: 1), weight: 40),
  ]);

  static final _shake = TweenSequence<double>([
    for (final (a, b) in [
      (0.0, -10.0),
      (-10.0, 9.0),
      (9.0, -6.0),
      (-6.0, 4.0),
      (4.0, 0.0),
    ])
      TweenSequenceItem(
        tween: Tween(begin: a, end: b),
        weight: 20,
      ),
  ]);

  @override
  void didUpdateWidget(ReactionBox old) {
    super.didUpdateWidget(old);
    final changed =
        widget.reaction != old.reaction || widget.trigger != old.trigger;
    if (changed && widget.reaction != Reaction.none && !reduceMotion(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        if (!_c.isAnimating) return child!;
        return switch (widget.reaction) {
          Reaction.pop => Transform.scale(
            scale: _pop.evaluate(_c),
            child: child,
          ),
          Reaction.shake => Transform.translate(
            offset: Offset(_shake.evaluate(_c), 0),
            child: child,
          ),
          Reaction.none => child!,
        };
      },
    );
  }
}

/// «+10 XP» floating up from where it is placed, once.
class FlyingXp extends StatelessWidget {
  const FlyingXp({super.key, required this.xp, required this.color});

  final int xp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
          builder: (context, t, _) => Opacity(
            opacity: t < 0.2 ? t / 0.2 : (1 - (t - 0.2) / 0.8).clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, -90 * t),
              child: Text(
                '+$xp XP',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Slides up from below when first built (feedback panels).
class SlideUp extends StatelessWidget {
  const SlideUp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, t, child) =>
          FractionalTranslation(translation: Offset(0, t), child: child),
    );
  }
}

/// Slides in from below and fades in once, when first built.
class RiseIn extends StatelessWidget {
  const RiseIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    final total = delay + const Duration(milliseconds: 420);
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}
