import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../data/providers.dart';
import '../../data/repositories/lesson_repository.dart';
import '../gamification/progress_rules.dart';
import 'sections.dart';

/// Zigzag offsets of the ladder, repeating.
const _offsets = [0.0, 56.0, 112.0, 56.0];

class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  final _current = GlobalKey();
  bool _scrolled = false;

  void _scrollToCurrentOnce() {
    if (_scrolled) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _current.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, alignment: 0.35);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(courseProvider);
    final stats = ref.watch(statsProvider);
    if (course.value == null || stats.value == null) {
      return LoadingScaffold(error: course.error ?? stats.error);
    }
    final c = course.value!;
    final next = c.next;
    _scrollToCurrentOnce();

    // Flatten the course into ladder rows; steps zigzag across the width.
    var step = 0;
    final rows = <Widget>[_LevelCard(xp: stats.value!.xp)];
    for (final s in c.sections) {
      rows.add(_SectionHeader(s));
      for (final t in s.topics) {
        rows.add(_TopicLabel(t));
        for (var i = 0; i < t.lessonCount; i++) {
          final isCurrent =
              next is NextLesson &&
              next.topic.category.id == t.category.id &&
              next.topic.nextLesson == i;
          rows.add(
            Padding(
              key: isCurrent ? _current : null,
              padding: EdgeInsets.only(
                left: _offsets[step++ % _offsets.length],
                bottom: 14,
              ),
              child: _LessonStep(topic: t, index: i, current: isCurrent),
            ),
          );
        }
      }
      final examCurrent =
          next is NextExam && next.section.section.id == s.section.id;
      rows.add(
        Padding(
          key: examCurrent ? _current : null,
          padding: const EdgeInsets.only(top: 6, bottom: 20),
          child: _ExamStep(section: s, current: examCurrent),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Уроки')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final level = LevelProgress.fromXp(xp);
    return SurfaceCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.onGold,
            child: Text(
              '${level.level}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Уровень ${level.level}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
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
                const SizedBox(height: 6),
                ProgressBar(
                  value: level.fraction,
                  height: 8,
                  color: AppColors.gold,
                  semanticsLabel: 'До следующего уровня',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.section);

  final SectionState section;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final number = courseSections.indexOf(section.section) + 1;
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 6),
      child: Row(
        children: [
          Expanded(child: Divider(color: c.line, thickness: 2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!section.unlocked) ...[
                  Icon(Icons.lock_rounded, size: 14, color: c.muted),
                  const SizedBox(width: 4),
                ],
                Text(
                  'РАЗДЕЛ $number · ${section.section.title.toUpperCase()}',
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Divider(color: c.line, thickness: 2)),
        ],
      ),
    );
  }
}

class _TopicLabel extends StatelessWidget {
  const _TopicLabel(this.topic);

  final TopicState topic;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = topic;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Icon(
            categoryIcon(t.category.icon),
            size: 20,
            color: t.unlocked ? c.accent : c.muted,
          ),
          const SizedBox(width: 8),
          Text(
            t.category.titleKk,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: t.unlocked ? c.ink : c.muted,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '· ${t.category.titleRu} · ${t.lessonsDone}/${t.lessonCount}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c.muted, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonStep extends StatelessWidget {
  const _LessonStep({
    required this.topic,
    required this.index,
    required this.current,
  });

  final TopicState topic;
  final int index;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = index < topic.lessonsDone;
    final open = done || current;
    final label = 'Урок ${index + 1}';
    final path = '/lesson/${topic.category.id}/$index';

    final Widget circle;
    if (done) {
      circle = const _Circle(
        size: 64,
        color: AppColors.primary,
        shadow: AppColors.primaryShadow,
        child: Icon(Icons.check_rounded, color: Colors.white, size: 30),
      );
    } else if (current) {
      circle = Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.sky, width: 5),
        ),
        child: Icon(Icons.play_arrow_rounded, color: c.accent, size: 38),
      );
    } else {
      circle = _Circle(
        size: 64,
        color: c.track,
        shadow: c.line,
        child: Icon(Icons.lock_rounded, color: c.lockIcon, size: 22),
      );
    }

    return Semantics(
      button: open,
      label:
          '${topic.category.titleKk}, $label, '
          '${done
              ? 'пройден'
              : current
              ? 'следующий'
              : 'закрыт'}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: open ? () => context.push(path) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            circle,
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: open ? c.ink : c.muted,
                  ),
                ),
                if (current) ...[
                  const SizedBox(height: 4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.onGold,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () => context.push(path),
                    child: Text(
                      topic.lessonsDone == 0 ? 'Начать' : 'Продолжить',
                    ),
                  ),
                ] else if (done)
                  Text(
                    'повторить',
                    style: TextStyle(color: c.muted, fontSize: 13),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamStep extends StatelessWidget {
  const _ExamStep({required this.section, required this.current});

  final SectionState section;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = section;
    final open = s.examUnlocked;
    final best = s.examBestScore;
    final status = s.examPassed
        ? 'Сдан · лучший результат $best%'
        : open
        ? best == null
              ? 'Нужно $examPassScore% правильных ответов · +$examPassBonusXp XP'
              : 'Лучший результат $best% · нужно $examPassScore%'
        : 'Откроется после всех уроков раздела';

    return SurfaceCard(
      color: s.examPassed || open ? c.goldSoft : c.surface,
      radius: 20,
      onTap: open ? () => context.push('/exam/${s.section.id}') : null,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: open || s.examPassed ? AppColors.gold : c.track,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              s.examPassed
                  ? Icons.workspace_premium_rounded
                  : open
                  ? Icons.emoji_events_rounded
                  : Icons.lock_rounded,
              color: open || s.examPassed ? AppColors.onGold : c.lockIcon,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Емтихан · экзамен «${s.section.title}»',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: open || s.examPassed ? c.ink : c.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(status, style: TextStyle(color: c.muted, fontSize: 13)),
              ],
            ),
          ),
          if (open && !s.examPassed)
            Icon(Icons.chevron_right_rounded, color: c.ink),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({
    required this.size,
    required this.color,
    required this.shadow,
    required this.child,
  });

  final double size;
  final Color color;
  final Color shadow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }
}
