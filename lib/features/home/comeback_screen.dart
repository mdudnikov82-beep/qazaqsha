import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/barys.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/gold_button.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../gamification/progress_rules.dart';

/// After a long break: a warm welcome, what was kept, and an easy way
/// back in. Never a word about what was lost.
class ComebackScreen extends ConsumerWidget {
  const ComebackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider).value;
    final progress = ref.watch(progressMapProvider).value;
    if (stats == null || progress == null) return const LoadingScaffold();
    final c = context.colors;
    final learned = progress.values
        .where((p) => p.status == LearningStatus.learned)
        .length;
    final studied = progress.values
        .where((p) => p.status != LearningStatus.fresh)
        .length;
    final level = LevelProgress.fromXp(stats.xp).level;

    return Scaffold(
      backgroundColor: c.accentSoft,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
          children: [
            const Center(child: Barys(mood: BarysMood.support, size: 180)),
            const SizedBox(height: 8),
            const Text(
              'Қош келдің!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'С возвращением — мы скучали',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.accent,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            SurfaceCard(
              radius: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Перерыв — это нормально',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Серия начнётся заново с сегодняшнего занятия. Всё, что '
                    'вы выучили, никуда не делось:',
                    style: TextStyle(color: c.muted, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final (i, (value, label)) in [
                        ('$learned', 'слов выучено'),
                        ('${stats.bestStreak}', 'дней — рекорд'),
                        ('$level', 'уровень'),
                      ].indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: c.bg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: c.muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (studied > 0) ...[
              const SizedBox(height: 12),
              SurfaceCard(
                radius: 22,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.goldSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.replay_rounded, color: c.goldText),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Лёгкий старт',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Знакомые слова за пару минут — вспомнить, что знаете',
                            style: TextStyle(color: c.muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            if (studied > 0) ...[
              GoldButton(
                label: 'Начать с лёгкого',
                icon: Icons.play_arrow_rounded,
                onPressed: () =>
                    context.pushReplacement('/practice/review?mode=random'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => context.pop(),
              child: const Text('Продолжить с того места'),
            ),
          ],
        ),
      ),
    );
  }
}
