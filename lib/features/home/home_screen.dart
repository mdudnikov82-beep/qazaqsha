import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../dictionary/word_of_day.dart';
import '../profile/activity_calendar.dart' show activityWeeks;
import 'week_card.dart';
import '../dictionary/word_sheet.dart';
import '../../core/motion.dart';
import '../../core/dates.dart';
import '../../core/home_widget_sync.dart';
import '../../core/widgets/barys.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/widgets/ornament.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/lesson_repository.dart';
import '../gamification/progress_rules.dart';
import '../grammar/grammar.dart';
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
    final today = wordOfDay(all, now);
    final streak = visibleStreak(
      current: s.streakDays,
      lastActive: s.lastActiveDate,
      now: now,
      freezes: s.streakFreezes,
    );
    final activity =
        ref.watch(activityProvider(activityWeeks)).value ?? const [];
    final lessonDone = ref.watch(lessonDoneTodayProvider).value ?? false;
    final ruleDone = ref.watch(ruleDoneTodayProvider).value ?? false;
    final grammar = ref.watch(grammarProvider).value ?? const [];
    final rulesDone = ref.watch(grammarProgressProvider).value ?? const {};
    final nextRule = grammar
        .expand((g) => g.rules)
        .where((r) => (rulesDone[r.id]?.bestScore ?? 0) < grammarPassScore)
        .firstOrNull;
    final next = course.value!.next;
    final lessonPath = switch (next) {
      NextLesson(:final topic) =>
        '/lesson/${topic.category.id}/${topic.nextLesson}',
      NextExam(:final section) => '/exam/${section.section.id}',
      CourseFinished() => null,
    };
    final left = [lessonDone, due == 0, ruleDone].where((d) => !d).length;
    final lapsed = streakLapsed(
      current: s.streakDays,
      lastActive: s.lastActiveDate,
      now: now,
      freezes: s.streakFreezes,
    );
    final (mood, message) = lapsed
        ? (
            BarysMood.support,
            'С возвращением! Перерыв — это нормально, всё выученное на месте.',
          )
        : left == 0
        ? (BarysMood.proud, 'Все задания на сегодня сделаны — керемет!')
        : (
            BarysMood.hello,
            'Сегодня осталось $left ${plural(left, 'задание', 'задания', 'заданий')} '
                'из 3 — минут на ${const ['пять', 'десять', 'пятнадцать'][left - 1]}.',
          );
    HomeWidgetSync.update(
      wordKk: today.kk,
      wordRu: today.ru,
      streak: streak,
      freezes: s.streakFreezes,
      tasksLeft: left,
    );
    if (lapsed && !s.quietMode && !_comebackShown) {
      _comebackShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.push('/comeback');
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light status bar icons over the palette-coloured header.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Header(
              streak: streak,
              freezes: s.streakFreezes,
              xp: s.xp,
              quiet: s.quietMode,
              name: s.userName,
              mood: mood,
              message: message,
              now: now,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RiseIn(
                    child: _ContinueCard(
                      next: next,
                      daily: daily,
                      goal: s.dailyGoalXp,
                    ),
                  ),
                  const SizedBox(height: 18),
                  RiseIn(
                    delay: const Duration(milliseconds: 60),
                    child: _TodayTasks(
                      lessonDone: lessonDone,
                      lessonPath: lessonPath,
                      due: due,
                      ruleDone: ruleDone,
                      rule: nextRule,
                    ),
                  ),
                  if (!s.quietMode) ...[
                    const SizedBox(height: 14),
                    RiseIn(
                      delay: const Duration(milliseconds: 120),
                      child: WeekCard(
                        stats: s,
                        days: activity,
                        learnedWords: learned,
                        now: now,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.replay_rounded,
                          title: 'Повторение',
                          subtitle: due > 0 ? 'Ждут: $due' : 'Всё повторено',
                          fg: c.goldText,
                          bg: c.goldSoft,
                          onTap: () => context.push('/review'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.forum_rounded,
                          title: 'Диалоги',
                          subtitle: '12 сцен',
                          fg: c.okText,
                          bg: c.okSoft,
                          onTap: () => context.push('/dialogues'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  WordOfDayCard(
                    word: today,
                    onTap: () => showWordSheet(context, today),
                  ),
                  const SizedBox(height: 14),
                  _StatsRow(
                    learnedWords: learned,
                    studySeconds: s.studySeconds,
                    mistakes: s.answersTotal - s.answersCorrect,
                    lessonsDone: course.value!.lessonsDone,
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

/// The «welcome back» screen opens once per app run after a long break.
bool _comebackShown = false;

const _weekdaysKk = [
  'Дүйсенбі', 'Сейсенбі', 'Сәрсенбі', 'Бейсенбі', 'Жұма', 'Сенбі', //
  'Жексенбі',
];
const _monthsKk = [
  'қаңтар', 'ақпан', 'наурыз', 'сәуір', 'мамыр', 'маусым', //
  'шілде', 'тамыз', 'қыркүйек', 'қазан', 'қараша', 'желтоқсан',
];

/// The palette-coloured top: today's date, streak, freezes and XP, and
/// Barys saying what today holds.
class _Header extends StatelessWidget {
  const _Header({
    required this.streak,
    required this.freezes,
    required this.xp,
    required this.quiet,
    required this.name,
    required this.mood,
    required this.message,
    required this.now,
  });

  final int streak;
  final int freezes;
  final int xp;
  final bool quiet;
  final String? name;
  final BarysMood mood;
  final String message;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: BoxDecoration(
        color: c.brand,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 4,
            child: OrnamentBand(
              color: AppColors.gold.withValues(alpha: 0.22),
              height: 40,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 14, 20, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_weekdaysKk[now.weekday - 1]}, ${now.day} '
                        '${_monthsKk[now.month - 1]}',
                        style: TextStyle(
                          color: c.onBrandMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!quiet) ...[
                      _HeaderPill(
                        semanticsLabel: 'Серия дней: $streak',
                        icon: const _Flame(),
                        text: '$streak',
                      ),
                      const SizedBox(width: 6),
                      _HeaderPill(
                        semanticsLabel: 'Заморозки серии: $freezes',
                        icon: const Icon(
                          Icons.ac_unit_rounded,
                          color: Color(0xFF9EE7F5),
                          size: 16,
                        ),
                        text: '$freezes',
                      ),
                      const SizedBox(width: 6),
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
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Barys(mood: mood, size: 86),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name == null ? 'Сәлем!' : 'Сәлем, $name!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              message,
                              style: TextStyle(color: c.muted, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three small things for today: a lesson, a review, a rule.
class _TodayTasks extends StatelessWidget {
  const _TodayTasks({
    required this.lessonDone,
    required this.lessonPath,
    required this.due,
    required this.ruleDone,
    required this.rule,
  });

  final bool lessonDone;
  final String? lessonPath;
  final int due;
  final bool ruleDone;
  final GrammarRule? rule;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = rule;
    final tasks = [
      (
        lessonDone,
        'Пройти урок',
        lessonDone ? 'Готово на сегодня' : 'Следующий урок на тропе',
        AppColors.gold,
        lessonPath,
      ),
      (
        due == 0,
        due == 0
            ? 'Повторение'
            : 'Повторить $due ${plural(due, 'слово', 'слова', 'слов')}',
        due == 0
            ? 'Сейчас повторять нечего'
            : 'Слова возвращаются, чтобы не забыться',
        AppColors.gold,
        due == 0 ? null : '/practice/review',
      ),
      (
        ruleDone,
        'Одно правило',
        ruleDone
            ? 'Готово на сегодня'
            : r == null
            ? 'Все правила изучены'
            : '№ ${r.number} · ${r.title}',
        c.sky,
        r == null ? null : '/rules/${r.id}',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Задания дня',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              for (final (i, (done, title, sub, ring, path))
                  in tasks.indexed) ...[
                if (i > 0) Divider(height: 1, color: c.line, indent: 58),
                Semantics(
                  label: '$title: ${done ? 'выполнено' : 'не выполнено'}',
                  child: ListTile(
                    onTap: done || path == null
                        ? null
                        : () => context.push(path),
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? c.ok : null,
                        border: done
                            ? null
                            : Border.all(color: ring, width: 2.5),
                      ),
                      child: done
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: done ? c.muted : c.ink,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: c.muted, fontSize: 12),
                    ),
                    trailing: done || path == null
                        ? null
                        : Icon(Icons.chevron_right_rounded, color: c.muted),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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

/// The daily goal as a ring, with the next step's icon inside.
class _GoalRing extends StatelessWidget {
  const _GoalRing({
    required this.daily,
    required this.goal,
    required this.icon,
    required this.color,
  });

  final int daily;
  final int goal;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final value = (daily / goal).clamp(0.0, 1.0);
    return Semantics(
      label: 'Цель дня: ${daily.clamp(0, goal)} из $goal XP',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: reduceMotion(context)
            ? Duration.zero
            : const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => SizedBox.square(
          dimension: 84,
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
                  Icon(icon, color: color, size: 22),
                  Text(
                    '${daily.clamp(0, goal)}/$goal',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

/// «Сейчас»: today's goal ring and the next step on the trail.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.next,
    required this.daily,
    required this.goal,
  });

  final NextStep next;
  final int daily;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final section = switch (next) {
      NextLesson(:final topic) => sectionOfCategory(topic.category.id),
      NextExam(:final section) => section.section,
      CourseFinished() => null,
    };
    final color = section?.color ?? context.colors.brand;
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
              _GoalRing(daily: daily, goal: goal, icon: icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'СЕЙЧАС',
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
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

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.fg,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color fg;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$title: $subtitle',
    excludeSemantics: true,
    child: SurfaceCard(
      color: bg,
      radius: 18,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
