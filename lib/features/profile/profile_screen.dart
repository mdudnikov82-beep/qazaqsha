import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../gamification/achievements.dart';
import '../gamification/progress_rules.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    if (stats.value == null) return LoadingScaffold(error: stats.error);
    final s = stats.value!;
    final progress = ref.watch(progressMapProvider).value ?? const {};
    final unlocked = ref.watch(unlockedAchievementsProvider).value ?? const {};
    final c = context.colors;
    final level = LevelProgress.fromXp(s.xp);
    final learned = progress.values
        .where((p) => p.status == LearningStatus.learned)
        .length;
    final accuracy = s.answersTotal == 0
        ? '—'
        : '${(100 * s.answersCorrect / s.answersTotal).round()}%';
    final repo = ref.read(statsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Уровень ${level.level}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${level.xpIntoLevel} / ${level.xpForLevel} XP',
                      style: TextStyle(
                        color: c.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(
                  value: level.fraction,
                  color: AppColors.gold,
                  semanticsLabel: 'До уровня ${level.level + 1}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2,
            children: [
              _Stat(
                '${visibleStreak(current: s.streakDays, lastActive: s.lastActiveDate, now: DateTime.now())}',
                'дней подряд',
              ),
              _Stat('$learned', 'слов выучено'),
              _Stat('${s.quizzesCompleted}', 'занятий пройдено'),
              _Stat(accuracy, 'правильных ответов'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Достижения',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 10,
            childAspectRatio: 0.8,
            children: [
              for (final a in achievements)
                _Badge(achievement: a, unlocked: unlocked.contains(a.id)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Цель дня',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 20, label: Text('20 XP')),
              ButtonSegment(value: 50, label: Text('50 XP')),
              ButtonSegment(value: 100, label: Text('100 XP')),
            ],
            selected: {s.dailyGoalXp},
            onSelectionChanged: (v) => repo.setDailyGoal(v.first),
          ),
          const SizedBox(height: 24),
          const Text(
            'Тема оформления',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(value: AppThemeMode.system, label: Text('Авто')),
              ButtonSegment(value: AppThemeMode.light, label: Text('Светлая')),
              ButtonSegment(value: AppThemeMode.dark, label: Text('Тёмная')),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => repo.setThemeMode(v.first),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.colors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.achievement, required this.unlocked});

  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: achievement.description,
      child: Semantics(
        label:
            '${achievement.title}: ${unlocked ? 'получено' : 'ещё не получено'}',
        excludeSemantics: true,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: unlocked ? c.goldSoft : c.track,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                unlocked ? achievement.icon : Icons.lock_rounded,
                color: unlocked ? c.goldText : c.lockIcon,
                size: unlocked ? 30 : 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: unlocked ? c.ink : c.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
