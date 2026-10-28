import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../data/providers.dart';
import '../../data/repositories/lesson_repository.dart';
import '../gamification/progress_rules.dart';

/// Section headers, shown before the topic that starts each section.
const _sections = {
  'greetings': 'Раздел 1 · Основы',
  'food': 'Раздел 2 · Быт',
  'city': 'Раздел 3 · Город и люди',
  'verbs': 'Раздел 4 · Речь',
};

/// Zigzag offsets of the path, repeating.
const _offsets = [0.0, 64.0, 128.0, 64.0];

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider);
    final stats = ref.watch(statsProvider);
    if (topics.value == null || stats.value == null) {
      return LoadingScaffold(error: topics.error ?? stats.error);
    }
    final level = LevelProgress.fromXp(stats.value!.xp);
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Уроки')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          SurfaceCard(
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
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
          ),
          for (final (i, t) in topics.value!.indexed) ...[
            if (_sections[t.category.id] case final title?)
              _SectionHeader(title),
            Padding(
              padding: EdgeInsets.only(
                left: _offsets[i % _offsets.length],
                bottom: 14,
              ),
              child: _TopicNode(topic: t),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(child: Divider(color: c.line, thickness: 2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: c.muted,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Expanded(child: Divider(color: c.line, thickness: 2)),
        ],
      ),
    );
  }
}

class _TopicNode extends StatelessWidget {
  const _TopicNode({required this.topic});

  final TopicState topic;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = topic;
    final current = t.unlocked && !t.completed;

    final Widget circle;
    if (t.completed) {
      circle = _Circle(
        size: 72,
        color: AppColors.primary,
        shadow: AppColors.primaryShadow,
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 34),
      );
    } else if (current) {
      circle = Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.sky, width: 5),
        ),
        child: Icon(categoryIcon(t.category.icon), color: c.accent, size: 34),
      );
    } else {
      circle = _Circle(
        size: 72,
        color: c.track,
        shadow: c.line,
        child: Icon(Icons.lock_rounded, color: c.lockIcon, size: 26),
      );
    }

    final subtitle = t.completed
        ? '${t.category.titleRu} · пройдено'
        : current
        ? '${t.category.titleRu} · урок ${t.nextLesson + 1} из ${t.lessonCount}'
        : '${t.category.titleRu} · закрыто';

    return Semantics(
      button: t.unlocked,
      label: '${t.category.titleKk}, $subtitle',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(44),
        onTap: t.unlocked ? () => _showLessons(context) : null,
        child: Row(
          children: [
            circle,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.category.titleKk,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: t.unlocked ? c.ink : c.muted,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: c.muted, fontSize: 14),
                  ),
                  if (current) ...[
                    const SizedBox(height: 6),
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
                      onPressed: () => context.push(
                        '/lesson/${t.category.id}/${t.nextLesson}',
                      ),
                      child: const Text('Продолжить'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLessons(BuildContext context) {
    final c = context.colors;
    final t = topic;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(
              '${t.category.titleKk} · ${t.category.titleRu}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < t.lessonCount; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: i <= t.lessonsDone,
                leading: Icon(
                  i < t.lessonsDone
                      ? Icons.check_circle_rounded
                      : i == t.lessonsDone
                      ? Icons.play_circle_fill_rounded
                      : Icons.lock_rounded,
                  color: i < t.lessonsDone
                      ? c.ok
                      : i == t.lessonsDone
                      ? c.accent
                      : c.lockIcon,
                ),
                title: Text(
                  'Урок ${i + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  i < t.lessonsDone
                      ? 'Пройден — можно повторить'
                      : i == t.lessonsDone
                      ? 'Следующий'
                      : 'Откроется после урока $i',
                ),
                onTap: () {
                  Navigator.of(sheet).pop();
                  context.push('/lesson/${t.category.id}/$i');
                },
              ),
          ],
        ),
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
