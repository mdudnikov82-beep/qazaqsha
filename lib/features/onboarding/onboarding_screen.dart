import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/widgets/ornament.dart';
import '../../data/providers.dart';
import '../lessons/sections.dart';

/// First-launch welcome: greeting → daily goal → how the course works.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

const _goals = [
  (20, 'Лёгкая', 'около 5 минут в день'),
  (50, 'Обычная', 'около 10 минут в день'),
  (100, 'Серьёзная', 'около 20 минут в день'),
];

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  int _goal = 50;
  bool _saving = false;

  Future<void> _finish({required bool startLesson}) async {
    if (_saving) return;
    setState(() => _saving = true);
    await ref
        .read(statsRepositoryProvider)
        .completeOnboarding(dailyGoalXp: _goal);
    if (!mounted) return;
    context.go('/home');
    if (startLesson) context.push('/lesson/greetings/0');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final last = _step == 2;
    final page = switch (_step) {
      0 => const _Welcome(),
      1 => _GoalStep(
        goal: _goal,
        onPick: (g) {
          Haptics.tap();
          setState(() => _goal = g);
        },
      ),
      _ => const _CourseStep(),
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Semantics(
                    label: 'Шаг ${_step + 1} из 3',
                    excludeSemantics: true,
                    child: Row(
                      children: [
                        for (var i = 0; i < 3; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 6),
                            width: i == _step ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _step ? AppColors.primary : c.line,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => _finish(startLesson: false),
                    child: Text(
                      'Пропустить',
                      style: TextStyle(
                        color: c.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: reduceMotion(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(_step), child: page),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: last
                  ? GoldButton(
                      label: 'Начать первый урок',
                      onPressed: () => _finish(startLesson: true),
                    )
                  : FilledButton(
                      onPressed: () => setState(() => _step++),
                      child: const Text('Дальше'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      children: [
        Center(
          child: _Floating(
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: c.accentSoft,
                      shape: BoxShape.circle,
                    ),
                  ),
                  for (var i = 0; i < 2; i++)
                    Align(
                      alignment: i == 0
                          ? const Alignment(0, -0.62)
                          : const Alignment(0, 0.62),
                      child: Transform.rotate(
                        angle: i * pi,
                        child: RamHorns(
                          width: 150,
                          color: c.sky,
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Ә',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 70,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Сәлем! Давайте учить казахский',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Короткие уроки по 5 минут: слова, фразы и игры. '
          'Без рекламы и без интернета.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.muted, fontSize: 17, height: 1.45),
        ),
      ],
    );
  }
}

/// Bobs gently up and down.
class _Floating extends StatefulWidget {
  const _Floating({required this.child});

  final Widget child;

  @override
  State<_Floating> createState() => _FloatingState();
}

class _FloatingState extends State<_Floating>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduceMotion(context) ? _c.stop() : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) => Transform.translate(
      offset: Offset(0, -8 * sin(_c.value * pi)),
      child: child,
    ),
  );
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.goal, required this.onPick});

  final int goal;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      children: [
        const Text(
          'Сколько заниматься в день?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Цель можно поменять в профиле в любой момент.',
          style: TextStyle(color: c.muted, fontSize: 16),
        ),
        const SizedBox(height: 18),
        for (final (xp, title, sub) in _goals) ...[
          _GoalTile(
            xp: xp,
            title: title,
            subtitle: sub,
            selected: xp == goal,
            onTap: () => onPick(xp),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.xp,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final int xp;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final border = selected ? c.sky : c.line;
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: border, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: selected ? c.accentSoft : c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: border, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : c.track,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '$xp',
                        style: TextStyle(
                          color: selected ? Colors.white : c.muted,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '$subtitle · $xp XP',
                          style: TextStyle(color: c.muted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (selected) Icon(Icons.check_rounded, color: c.accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseStep extends StatelessWidget {
  const _CourseStep();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      children: [
        const Text(
          'Ваша тропа к казахскому',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${courseSections.length} разделов, 2200 слов, около 450 уроков. '
          'В конце раздела — экзамен, и откроется следующий.',
          style: TextStyle(color: c.muted, fontSize: 16),
        ),
        const SizedBox(height: 18),
        for (final (i, s) in courseSections.indexed) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: s.color,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.titleKk,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(s.title, style: TextStyle(color: c.muted)),
                    ],
                  ),
                ),
                Icon(Icons.emoji_events_rounded, color: c.goldText),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
