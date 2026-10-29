import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/widgets/teal_header.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/progress_repository.dart';
import '../dictionary/word_tile.dart';
import '../gamification/progress_rules.dart';
import '../quiz/srs.dart';
import 'review_mode.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(allWordsProvider);
    final progress = ref.watch(progressMapProvider);
    if (words.value == null || progress.value == null) {
      return LoadingScaffold(error: words.error ?? progress.error);
    }
    final now = DateTime.now();
    final byId = {for (final w in words.value!) w.id: w};
    final studied = progress.value!.values
        .where(
          (p) => p.status != LearningStatus.fresh && byId[p.wordId] != null,
        )
        .toList();
    final due = studied
        .where((p) => p.nextReviewAt != null && !p.nextReviewAt!.isAfter(now))
        .length;
    final hard = [...studied.where((p) => p.wrongCount > 0)]
      ..sort((a, b) => hardness(b).compareTo(hardness(a)));
    final favorites = progress.value!.values
        .where((p) => p.isFavorite && byId[p.wordId] != null)
        .length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            const TealHeader(
              leading: BackButton(color: Colors.white),
              title: 'Қайталау',
              subtitle: 'Повторение слов',
              bottomPadding: 64,
            ),
            Transform.translate(
              offset: const Offset(0, -44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DueCard(due: due, studied: studied, now: now),
                    const SizedBox(height: 16),
                    if (studied.isNotEmpty) ...[
                      _Forecast(studied: studied, now: now),
                      const SizedBox(height: 24),
                    ],
                    const _Title('Другие тренировки'),
                    _Modes(
                      hard: hard.length,
                      favorites: favorites,
                      studied: studied.length,
                    ),
                    if (studied.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const _Title('Память по ступеням'),
                      _Boxes(studied: studied),
                    ],
                    if (hard.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _Title(
                        'Сложные слова',
                        action: TextButton.icon(
                          onPressed: () =>
                              context.push('/practice/review?mode=hard'),
                          icon: const Icon(Icons.fitness_center_rounded),
                          label: const Text('Тренировать'),
                        ),
                      ),
                      for (final p in hard.take(10))
                        WordTile(
                          word: byId[p.wordId]!,
                          progress: p,
                          trailing: _Mistakes(progress: p),
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

class _Title extends StatelessWidget {
  const _Title(this.text, {this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        ?action,
      ],
    ),
  );
}

class _DueCard extends StatelessWidget {
  const _DueCard({required this.due, required this.studied, required this.now});

  final int due;
  final List<WordProgressData> studied;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final next = studied
        .map((p) => p.nextReviewAt)
        .whereType<DateTime>()
        .where((t) => t.isAfter(now))
        .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
    final String title;
    final String text;
    if (studied.isEmpty) {
      title = 'Пока нечего повторять';
      text = 'Пройдите урок — выученные слова будут возвращаться сюда, чтобы не забыться.';
    } else if (due > 0) {
      title = 'Ждут повторения';
      text = 'Повторите сейчас, пока слова не забылись.';
    } else {
      title = 'Всё повторено!';
      text = next == null
          ? 'Новые слова появятся после уроков.'
          : 'Следующие слова вернутся ${_when(next)}.';
    }
    return SurfaceCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: studied.isEmpty
                          ? 0
                          : 1 - min(due, studied.length) / studied.length,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      color: due > 0 ? AppColors.gold : c.ok,
                      backgroundColor: c.track,
                    ),
                    Center(
                      child: due > 0
                          ? Text(
                              '$due',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : Icon(Icons.check_rounded, color: c.ok, size: 40),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(text, style: TextStyle(color: c.muted)),
                  ],
                ),
              ),
            ],
          ),
          if (due > 0) ...[
            const SizedBox(height: 18),
            GoldButton(
              label: () {
                final n = min(due, reviewSessionSize);
                return 'Повторить $n ${plural(n, 'слово', 'слова', 'слов')}';
              }(),
              icon: Icons.replay_rounded,
              onPressed: () => context.push('/practice/review'),
            ),
          ],
        ],
      ),
    );
  }

  String _when(DateTime next) {
    final days = daysBetween(now, next);
    if (days <= 0) return 'сегодня';
    if (days == 1) return 'завтра';
    return dayMonth(next);
  }
}

/// How many words come back on each of the next seven days.
class _Forecast extends StatelessWidget {
  const _Forecast({required this.studied, required this.now});

  final List<WordProgressData> studied;
  final DateTime now;

  static const _weekdays = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final counts = List.filled(7, 0);
    for (final p in studied) {
      final at = p.nextReviewAt;
      if (at == null) continue;
      // Overdue words count for today.
      final d = max(0, daysBetween(now, at));
      if (d < 7) counts[d]++;
    }
    final top = max(1, counts.reduce(max));
    final total = counts.reduce((a, b) => a + b);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Прогноз на неделю',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '$total ${plural(total, 'слово', 'слова', 'слов')}',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Semantics(
            label: [for (var d = 0; d < 7; d++) '${_label(d)}: ${counts[d]}']
                .join(', '),
            excludeSemantics: true,
            child: SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var d = 0; d < 7; d++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${counts[d]}',
                              style: TextStyle(
                                color: counts[d] == 0 ? c.muted : c.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: max(4, 70 * counts[d] / top),
                              decoration: BoxDecoration(
                                color: counts[d] == 0
                                    ? c.track
                                    : d == 0
                                    ? AppColors.gold
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _label(d),
                              style: TextStyle(
                                color: d == 0 ? c.accent : c.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(int d) => d == 0 ? 'сег' : _weekdays[(now.weekday - 1 + d) % 7];
}

class _Modes extends StatelessWidget {
  const _Modes({
    required this.hard,
    required this.favorites,
    required this.studied,
  });

  final int hard;
  final int favorites;
  final int studied;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final modes = [
      (
        ReviewMode.hard,
        Icons.local_fire_department_rounded,
        'Сложные',
        hard == 0 ? 'Ошибок пока нет' : '$hard с ошибками',
        hard,
        c.badText,
        c.badSoft,
      ),
      (
        ReviewMode.favorites,
        Icons.star_rounded,
        'Избранное',
        favorites == 0
            ? 'Отметьте слова ☆'
            : '$favorites ${plural(favorites, 'слово', 'слова', 'слов')}',
        favorites,
        c.goldText,
        c.goldSoft,
      ),
      (
        ReviewMode.random,
        Icons.shuffle_rounded,
        'Случайные',
        studied == 0 ? 'После первого урока' : '$reviewSessionSize из $studied',
        studied,
        c.accent,
        c.accentSoft,
      ),
    ];
    return Row(
      children: [
        for (final (i, (mode, icon, title, sub, count, fg, bg))
            in modes.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              button: true,
              enabled: count > 0,
              label: '$title: $sub',
              excludeSemantics: true,
              child: SurfaceCard(
                radius: 18,
                padding: const EdgeInsets.all(12),
                onTap: count == 0
                    ? null
                    : () => context.push('/practice/review?mode=${mode.name}'),
                child: Opacity(
                  opacity: count == 0 ? 0.55 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: fg, size: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        sub,
                        maxLines: 2,
                        style: TextStyle(color: c.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Words per spaced-repetition box: a word climbs a step with every right
/// answer and falls to the bottom after a mistake.
class _Boxes extends StatelessWidget {
  const _Boxes({required this.studied});

  final List<WordProgressData> studied;

  static String _interval(int box) => switch (box) {
    0 => 'сразу',
    _ => () {
      final d = reviewIntervals[box].inDays;
      return 'через $d ${plural(d, 'день', 'дня', 'дней')}';
    }(),
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final counts = List.filled(reviewIntervals.length, 0);
    for (final p in studied) {
      counts[p.box.clamp(0, counts.length - 1)]++;
    }
    final top = max(1, counts.reduce(max));
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var b = 0; b < counts.length; b++) ...[
            if (b > 0) const SizedBox(height: 10),
            Semantics(
              label: 'Ступень ${b + 1}, повтор ${_interval(b)}: ${counts[b]}',
              excludeSemantics: true,
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: b >= learnedBox ? c.okSoft : c.track,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${b + 1}',
                        style: TextStyle(
                          color: b >= learnedBox ? c.okText : c.muted,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 104,
                    child: Text(
                      _interval(b),
                      style: TextStyle(
                        color: c.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ProgressBar(
                      value: counts[b] / top,
                      height: 10,
                      color: b >= learnedBox ? c.ok : AppColors.gold,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${counts[b]}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Верный ответ поднимает слово на ступень выше, ошибка — '
            'возвращает вниз. С ${learnedBox + 1}-й ступени слово считается выученным.',
            style: TextStyle(color: c.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Mistakes extends StatelessWidget {
  const _Mistakes({required this.progress});

  final WordProgressData progress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${progress.wrongCount} ${plural(progress.wrongCount, 'ошибка', 'ошибки', 'ошибок')}',
            style: TextStyle(
              color: c.badText,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'точность ${accuracyOf(progress)}%',
            style: TextStyle(color: c.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
