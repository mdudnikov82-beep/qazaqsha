import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/lesson_repository.dart';
import '../gamification/progress_rules.dart';
import '../lessons/sections.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final course = ref.watch(courseProvider);
    final words = ref.watch(allWordsProvider);
    final progress = ref.watch(progressMapProvider).value ?? const {};
    if (stats.value == null || course.value == null || words.value == null) {
      return LoadingScaffold(error: stats.error ?? course.error ?? words.error);
    }
    final s = stats.value!;
    final now = DateTime.now();
    final c = context.colors;

    final daily = todayXp(
      storedDailyXp: s.dailyXp,
      storedDay: s.dailyXpDate,
      now: now,
    );
    final learned = progress.values
        .where((p) => p.status == LearningStatus.learned)
        .length;
    final due = progress.values
        .where(
          (p) =>
              p.status != LearningStatus.fresh &&
              p.nextReviewAt != null &&
              !p.nextReviewAt!.isAfter(now),
        )
        .length;
    final all = words.value!;
    final wordOfDay =
        all[dayOf(now).millisecondsSinceEpoch ~/
            Duration.millisecondsPerDay %
            all.length];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Сәлем!',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Бүгін де жалғастырайық',
                        style: TextStyle(
                          color: c.muted,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Pill(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: c.flame,
                  text:
                      '${visibleStreak(current: s.streakDays, lastActive: s.lastActiveDate, now: now)}',
                  background: c.goldSoft,
                  foreground: c.ink,
                  semanticsLabel: 'Серия дней',
                ),
                const SizedBox(width: 8),
                Pill(
                  icon: Icons.bolt_rounded,
                  text: '${s.xp}',
                  background: c.accentSoft,
                  foreground: c.accent,
                  semanticsLabel: '${s.xp} очков опыта',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DailyGoalCard(daily: daily, goal: s.dailyGoalXp),
            const SizedBox(height: 16),
            _ContinueCard(next: course.value!.next),
            const SizedBox(height: 16),
            _StatsCard(
              learnedWords: learned,
              studySeconds: s.studySeconds,
              mistakes: s.answersTotal - s.answersCorrect,
              lessonsDone: course.value!.lessonsDone,
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Слово дня',
                    style: TextStyle(
                      color: c.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    wordOfDay.kk,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    wordOfDay.ru,
                    style: TextStyle(color: c.muted, fontSize: 15),
                  ),
                ],
              ),
            ),
            if (due > 0) ...[
              const SizedBox(height: 16),
              SurfaceCard(
                color: c.goldSoft,
                radius: 18,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                onTap: () => context.go('/review'),
                child: Row(
                  children: [
                    Icon(Icons.replay_rounded, color: c.goldText),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Повторить слова: $due',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.daily, required this.goal});

  final int daily;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final left = goal - daily;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Цель дня',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${daily.clamp(0, goal)} / $goal XP',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(value: daily / goal, semanticsLabel: 'Цель дня'),
          const SizedBox(height: 10),
          Text(
            left > 0 ? 'Осталось $left XP' : 'Цель на сегодня выполнена!',
            style: TextStyle(color: c.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.learnedWords,
    required this.studySeconds,
    required this.mistakes,
    required this.lessonsDone,
  });

  final int learnedWords;
  final int studySeconds;
  final int mistakes;
  final int lessonsDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ваша статистика',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.1,
          children: [
            _StatTile(
              icon: Icons.menu_book_rounded,
              value: '$learnedWords',
              label: 'слов выучено',
            ),
            _StatTile(
              icon: Icons.timer_rounded,
              value: formatStudyTime(studySeconds),
              label: 'время занятий',
            ),
            _StatTile(
              icon: Icons.close_rounded,
              value: '$mistakes',
              label: 'ошибок всего',
            ),
            _StatTile(
              icon: Icons.check_circle_rounded,
              value: '$lessonsDone',
              label: 'уроков пройдено',
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: SurfaceCard(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: c.accent, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.next});

  final NextStep next;

  @override
  Widget build(BuildContext context) {
    final (label, title, subtitle, progress, button, path) = switch (next) {
      NextLesson(:final topic) => (
        'ПРОДОЛЖИТЬ',
        topic.category.titleKk,
        '${topic.category.titleRu} · урок ${topic.nextLesson + 1} '
            'из ${topic.lessonCount}',
        topic.lessonsDone / topic.lessonCount,
        'Начать урок',
        '/lesson/${topic.category.id}/${topic.nextLesson}',
      ),
      NextExam(:final section) => (
        'ЭКЗАМЕН РАЗДЕЛА',
        'Емтихан',
        '«${section.section.title}» · нужно $examPassScore% правильных',
        1.0,
        'Сдать экзамен',
        '/exam/${section.section.id}',
      ),
      CourseFinished() => (
        'ВСЁ ПРОЙДЕНО',
        'Керемет!',
        'Курс пройден. Повторяйте слова, чтобы не забыть.',
        null,
        null,
        null,
      ),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCDEFF6),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFFE0F4F8), fontSize: 16),
          ),
          if (progress != null) ...[
            const SizedBox(height: 14),
            ProgressBar(
              value: progress,
              height: 8,
              color: AppColors.gold,
              trackColor: Colors.white.withValues(alpha: 0.25),
            ),
          ],
          if (button != null && path != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.onGold,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 22),
              ),
              onPressed: () => context.push(path),
              icon: const Icon(Icons.arrow_forward_rounded),
              iconAlignment: IconAlignment.end,
              label: Text(button),
            ),
          ],
        ],
      ),
    );
  }
}
