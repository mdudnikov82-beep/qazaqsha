import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/widgets/ornament.dart';
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
    final streak = visibleStreak(
      current: s.streakDays,
      lastActive: s.lastActiveDate,
      now: now,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light status bar icons over the teal header.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Header(streak: streak, xp: s.xp, name: s.userName),
            Transform.translate(
              offset: const Offset(0, -46),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RiseIn(
                      child: _GoalCard(daily: daily, goal: s.dailyGoalXp),
                    ),
                    const SizedBox(height: 14),
                    RiseIn(
                      delay: const Duration(milliseconds: 80),
                      child: _ContinueCard(next: course.value!.next),
                    ),
                    const SizedBox(height: 14),
                    RiseIn(
                      delay: const Duration(milliseconds: 160),
                      child: _StatsRow(
                        learnedWords: learned,
                        studySeconds: s.studySeconds,
                        mistakes: s.answersTotal - s.answersCorrect,
                        lessonsDone: course.value!.lessonsDone,
                      ),
                    ),
                    const SizedBox(height: 14),
                    RiseIn(
                      delay: const Duration(milliseconds: 240),
                      child: _WordOfDayCard(word: wordOfDay),
                    ),
                    if (due > 0) ...[
                      const SizedBox(height: 14),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.streak, required this.xp, this.name});

  final int streak;
  final int xp;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: OrnamentBand(
              color: AppColors.gold.withValues(alpha: 0.3),
              height: 44,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 22, 20, 70),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name == null ? 'Сәлем!' : 'Сәлем, $name!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        'Бүгін де жалғастырайық',
                        style: TextStyle(
                          color: Color(0xFFCDEFF6),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _HeaderPill(
                  semanticsLabel: 'Серия дней: $streak',
                  icon: const _Flame(),
                  text: '$streak',
                ),
                const SizedBox(width: 8),
                _HeaderPill(
                  semanticsLabel: '$xp очков опыта',
                  icon: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  text: '$xp',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.semanticsLabel,
    required this.icon,
    required this.text,
  });

  final String semanticsLabel;
  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticsLabel,
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

/// The streak flame, gently flickering.
class _Flame extends StatefulWidget {
  const _Flame();

  @override
  State<_Flame> createState() => _FlameState();
}

class _FlameState extends State<_Flame> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
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
  Widget build(BuildContext context) {
    const flame = Icon(
      Icons.local_fire_department_rounded,
      color: AppColors.gold,
      size: 20,
    );
    return AnimatedBuilder(
      animation: _c,
      child: flame,
      builder: (context, child) {
        final t = _c.value * 2 * pi;
        return Transform.rotate(
          angle: sin(t) * 0.07,
          alignment: Alignment.bottomCenter,
          child: Transform.scale(
            scale: 1 + sin(t * 2) * 0.05,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.daily, required this.goal});

  final int daily;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final left = goal - daily;
    final value = (daily / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Semantics(
            label: 'Цель дня: ${daily.clamp(0, goal)} из $goal XP',
            excludeSemantics: true,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: reduceMotion(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => SizedBox(
                width: 84,
                height: 84,
                child: CustomPaint(
                  painter: _RingPainter(
                    value: v,
                    track: c.track,
                    color: value >= 1 ? c.ok : c.sky,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${daily.clamp(0, goal)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          'из $goal XP',
                          style: TextStyle(
                            color: c.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ЦЕЛЬ ДНЯ',
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  left > 0
                      ? 'Ещё $left XP — и день засчитан'
                      : 'Цель на сегодня выполнена!',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (left > 0)
                  Text(
                    left <= 40 ? 'Это примерно один урок' : 'Пара уроков',
                    style: TextStyle(color: c.muted, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.track, required this.color});

  final double value;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, 0, 2 * pi, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(arc, -pi / 2, 2 * pi * value, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.next});

  final NextStep next;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final section = switch (next) {
      NextLesson(:final topic) => sectionOfCategory(topic.category.id),
      NextExam(:final section) => section.section,
      CourseFinished() => null,
    };
    final color = section?.color ?? AppColors.primary;
    final number = section == null ? 0 : courseSections.indexOf(section) + 1;
    final soft = Color.alphaBlend(color.withValues(alpha: 0.14), c.surface);

    final (icon, label, title, button, path) = switch (next) {
      NextLesson(:final topic) => (
        categoryIcon(topic.category.icon),
        'Раздел $number · урок ${topic.nextLesson + 1} из ${topic.lessonCount}',
        topic.category.titleKk,
        topic.lessonsDone == 0 ? 'Начать урок' : 'Продолжить урок',
        '/lesson/${topic.category.id}/${topic.nextLesson}',
      ),
      NextExam(:final section) => (
        Icons.emoji_events_rounded,
        'Раздел $number · экзамен «${section.section.title}»',
        'Емтихан',
        'Сдать экзамен',
        '/exam/${section.section.id}',
      ),
      CourseFinished() => (
        Icons.workspace_premium_rounded,
        'Курс пройден',
        'Керемет!',
        null,
        null,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: soft, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: c.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (next case NextLesson(:final topic)) ...[
            const SizedBox(height: 14),
            ExcludeSemantics(
              child: Row(
                children: [
                  for (var i = 0; i < topic.lessonCount; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: i < topic.lessonsDone ? color : c.track,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (next is CourseFinished)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Все разделы и экзамены пройдены. Повторяйте слова, чтобы '
                'не забыть.',
                style: TextStyle(color: c.muted),
              ),
            ),
          if (button != null && path != null) ...[
            const SizedBox(height: 14),
            GoldButton(label: button, onPressed: () => context.push(path)),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
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
    final c = context.colors;
    final tiles = [
      (
        Icons.menu_book_rounded,
        c.accent,
        c.accentSoft,
        '$learnedWords',
        'слов выучено',
      ),
      (
        Icons.timer_rounded,
        c.goldText,
        c.goldSoft,
        formatStudyTime(studySeconds),
        'время занятий',
      ),
      (Icons.close_rounded, c.badText, c.badSoft, '$mistakes', 'ошибок всего'),
      (
        Icons.check_rounded,
        c.okText,
        c.okSoft,
        '$lessonsDone',
        'уроков пройдено',
      ),
    ];
    return Semantics(
      label: 'Ваша статистика',
      child: Row(
        children: [
          for (final (i, (icon, fg, bg, value, label)) in tiles.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                label: '$label: $value',
                excludeSemantics: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: fg, size: 18),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        label.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WordOfDayCard extends StatelessWidget {
  const _WordOfDayCard({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // A dark card in the light theme; in the dark theme a gold outline
    // keeps it apart from the other cards.
    final bg = dark ? c.surface : const Color(0xFF13232E);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: dark
            ? Border.all(color: AppColors.gold.withValues(alpha: 0.5))
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -14,
            child: RamHorns(
              width: 120,
              color: AppColors.gold.withValues(alpha: 0.25),
              strokeWidth: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'КҮННІҢ СӨЗІ · СЛОВО ДНЯ',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  word.kk,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  word.ru,
                  style: const TextStyle(
                    color: Color(0xFF9DB0BB),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
