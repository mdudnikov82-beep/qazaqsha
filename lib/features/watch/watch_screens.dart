import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/barys.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/lesson_repository.dart';
import '../dictionary/word_of_day.dart';
import '../gamification/progress_rules.dart';

/// Words in one watch workout.
const watchWorkoutSize = 5;

/// XP for a right answer on the watch.
const watchXpPerAnswer = 5;

/// Content of a round screen: centred, with room for the curved edges.
class _Round extends StatelessWidget {
  const _Round({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final side = MediaQuery.sizeOf(context).shortestSide;
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: side * .12,
          vertical: side * .07,
        ),
        children: children,
      ),
    );
  }
}

class WatchHome extends ConsumerWidget {
  const WatchHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider).value;
    final words = ref.watch(allWordsProvider).value;
    final progress = ref.watch(progressMapProvider).value ?? const {};
    if (stats == null || words == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final c = context.colors;
    final now = DateTime.now();
    final streak = visibleStreak(
      current: stats.streakDays,
      lastActive: stats.lastActiveDate,
      now: now,
      freezes: stats.streakFreezes,
    );
    final daily = todayXp(
      storedDailyXp: stats.dailyXp,
      storedDay: stats.dailyXpDate,
      now: now,
    );
    final due = progress.values
        .where(
          (p) =>
              p.status != LearningStatus.fresh &&
              p.nextReviewAt != null &&
              !p.nextReviewAt!.isAfter(now),
        )
        .length;
    final word = wordOfDay(words, now);
    final goalDone = daily >= stats.dailyGoalXp;

    return _Round(
      children: [
        Center(
          child: Barys(
            mood: goalDone ? BarysMood.proud : BarysMood.hello,
            size: 50,
          ),
        ),
        Text(
          '🔥 $streak  ·  ⚡ $daily/${stats.dailyGoalXp}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Text(
                'КҮННІҢ СӨЗІ',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
              Text(
                word.kk,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                word.ru,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(42),
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.onGold,
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WatchWorkout(review: false),
            ),
          ),
          child: const Text('Тренировка'),
        ),
        if (due > 0) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WatchWorkout(review: true),
              ),
            ),
            child: Text('Повторить $due'),
          ),
        ],
      ],
    );
  }
}

/// A one-minute workout: a Kazakh word, two translations to pick from.
class WatchWorkout extends ConsumerStatefulWidget {
  const WatchWorkout({super.key, required this.review, this.random});

  /// Due words; otherwise words of the current topic.
  final bool review;
  final Random? random;

  @override
  ConsumerState<WatchWorkout> createState() => _WatchWorkoutState();
}

class _WatchWorkoutState extends ConsumerState<WatchWorkout> {
  late final _random = widget.random ?? Random();
  List<Word>? _words;
  List<Word> _all = const [];
  var _index = 0;
  List<String> _options = const [];
  String? _picked;
  final _results = <int, bool>{};
  int? _xp;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final dictionary = ref.read(dictionaryRepositoryProvider);
    final all = await dictionary.allWords();
    var words = <Word>[];
    if (widget.review) {
      words = await ref
          .read(progressRepositoryProvider)
          .dueWords(now, limit: watchWorkoutSize);
    } else {
      final course = await ref
          .read(lessonRepositoryProvider)
          .watchCourse()
          .first;
      if (course.next case NextLesson(:final topic)) {
        words = (await dictionary.wordsInCategory(topic.category.id))
          ..shuffle(_random);
      }
    }
    if (words.isEmpty) words = [...all]..shuffle(_random);
    final picked = words
        .where((w) => !w.kk.contains('…'))
        .take(watchWorkoutSize)
        .toList();
    if (!mounted) return;
    setState(() {
      _all = all;
      _words = picked;
      _options = _optionsFor(picked.first);
    });
  }

  List<String> _optionsFor(Word w) {
    String other;
    do {
      other = _all[_random.nextInt(_all.length)].ru;
    } while (other == w.ru);
    return [w.ru, other]..shuffle(_random);
  }

  Future<void> _pick(String option) async {
    if (_picked != null) return;
    final word = _words![_index];
    final ok = option == word.ru;
    ok ? Haptics.success() : Haptics.error();
    setState(() {
      _picked = option;
      _results[word.id] = ok;
    });
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    if (_index + 1 < _words!.length) {
      setState(() {
        _index++;
        _picked = null;
        _options = _optionsFor(_words![_index]);
      });
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final now = DateTime.now();
    final right = _results.values.where((r) => r).length;
    final xp = right * watchXpPerAnswer;
    await ref.read(progressRepositoryProvider).applySession(_results, now);
    await ref
        .read(statsRepositoryProvider)
        .recordSession(
          xp: xp,
          correct: right,
          total: _results.length,
          now: now,
        );
    if (mounted) setState(() => _xp = xp);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final words = _words;
    if (words == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_xp case final xp?) {
      final right = _results.values.where((r) => r).length;
      return _Round(
        children: [
          const Center(child: Barys(mood: BarysMood.celebrate, size: 70)),
          const SizedBox(height: 6),
          const Text(
            'Керемет!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            '$right из ${words.length} · +$xp XP',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Готово'),
          ),
        ],
      );
    }
    final word = words[_index];
    return _Round(
      children: [
        const SizedBox(height: 8),
        Text(
          '${_index + 1} / ${words.length}',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.muted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        // Long words shrink to one line instead of breaking mid-word.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            word.kk,
            maxLines: 1,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 8),
        for (final o in _options) ...[
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              backgroundColor: _picked == null
                  ? c.surface
                  : o == word.ru
                  ? AppColors.okButton
                  : o == _picked
                  ? AppColors.badButton
                  : c.surface,
              foregroundColor: c.ink,
            ),
            onPressed: () => _pick(o),
            child: Text(
              o,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: _picked != null && (o == word.ru || o == _picked)
                    ? Colors.white
                    : c.ink,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
