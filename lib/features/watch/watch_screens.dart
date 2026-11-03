import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/speech.dart';
import '../../core/voice.dart';
import '../../core/widgets/barys.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/lesson_repository.dart';
import '../dictionary/word_of_day.dart';
import '../dictionary/word_sheet.dart' show exampleFor;
import '../gamification/progress_rules.dart';
import '../quiz/quiz_session.dart' show fixedMistakeCap, fixedMistakeXp;

/// Words in one watch workout.
const watchWorkoutSize = 5;

/// XP for a right answer on the watch.
const watchXpPerAnswer = 5;

/// The prompt of a workout task, for tests.
const watchPromptKey = Key('watch-prompt');

/// Turns of the watch's (touch) bezel or crown, from MainActivity: one
/// native subscription shared by every screen.
final _bezelTurns = const EventChannel('qazaqsha/rotary')
    .receiveBroadcastStream()
    .asBroadcastStream();

/// Content of a round screen: centred, with room for the curved edges.
/// Scrolls with a finger and with the bezel.
class _Round extends StatefulWidget {
  const _Round({required this.children, this.ring});

  final List<Widget> children;

  /// Today's goal, 0..1, drawn as a ring along the screen's edge.
  final double? ring;

  @override
  State<_Round> createState() => _RoundState();
}

class _RoundState extends State<_Round> {
  final _scroll = ScrollController();
  StreamSubscription<dynamic>? _bezel;

  @override
  void initState() {
    super.initState();
    _bezel = _bezelTurns.listen(
      (delta) {
        // Only the screen on top scrolls.
        if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return;
        if (!_scroll.hasClients || delta is! num) return;
        final p = _scroll.position;
        _scroll.jumpTo(
          (p.pixels + delta.toDouble()).clamp(0, p.maxScrollExtent),
        );
      },
      // No bezel (phones, tests): nothing to listen to.
      onError: (Object _) {},
    );
  }

  @override
  void dispose() {
    _bezel?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final side = MediaQuery.sizeOf(context).shortestSide;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (widget.ring case final ring?)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _GoalRing(ring)),
              ),
            ),
          ListView(
            controller: _scroll,
            padding: EdgeInsets.symmetric(
              horizontal: side * .12,
              vertical: side * .08,
            ),
            children: widget.children,
          ),
        ],
      ),
    );
  }
}

/// A gold arc around the round screen, from the top, as the goal fills.
class _GoalRing extends CustomPainter {
  _GoalRing(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 6.0;
    final rect = (Offset.zero & size).deflate(w / 2 + 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, paint..color = Colors.white12);
    if (value > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * value.clamp(0, 1),
        false,
        paint..color = AppColors.gold,
      );
    }
  }

  @override
  bool shouldRepaint(_GoalRing old) => old.value != value;
}

/// Plays a word: a native speaker's recording if there is one, otherwise
/// the watch's voice (if it has Kazakh).
void _say(WidgetRef ref, String kk) {
  final key = ref.read(recordedVoiceProvider).value?[Voice.normalize(kk)];
  key != null ? Voice.play(key) : Speech.say(kk);
}

class WatchHome extends ConsumerStatefulWidget {
  const WatchHome({super.key});

  @override
  ConsumerState<WatchHome> createState() => _WatchHomeState();
}

class _WatchHomeState extends ConsumerState<WatchHome> {
  /// The word of the day shows its translation.
  var _flipped = false;

  @override
  Widget build(BuildContext context) {
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
    final quiet = stats.quietMode;
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
    final example = _flipped
        ? exampleFor(word, ref.watch(sentencesProvider).value ?? const [])
        : null;

    return _Round(
      ring: quiet ? null : daily / stats.dailyGoalXp,
      children: [
        Center(
          child: Barys(
            mood: goalDone ? BarysMood.resting : BarysMood.hello,
            outfit: ref.watch(barysOutfitProvider),
            size: 50,
          ),
        ),
        Text(
          quiet
              ? (goalDone ? 'На сегодня достаточно' : 'Сәлем!')
              : goalDone
              ? '🔥 $streak · на сегодня достаточно'
              : '🔥 $streak  ·  ⚡ $daily/${stats.dailyGoalXp}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Semantics(
          button: true,
          label: _flipped
              ? '${word.kk} — ${word.ru}'
              : 'Слово дня ${word.kk}. Нажмите, чтобы перевернуть',
          excludeSemantics: true,
          child: Material(
            color: _flipped ? c.accentSoft : c.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() => _flipped = !_flipped);
                if (_flipped) _say(ref, word.kk);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        word.kk,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (_flipped) ...[
                      Text(
                        word.ru,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (example != null)
                        Text(
                          example.kk,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.muted, fontSize: 11),
                        ),
                    ] else
                      Text(
                        'нажмите — перевод и 🔊',
                        style: TextStyle(color: c.muted, fontSize: 11),
                      ),
                  ],
                ),
              ),
            ),
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

/// One task of a workout: a word and which way it is asked.
class _Task {
  const _Task(this.word, {required this.fromRussian});

  final Word word;

  /// Shows the Russian word, offers Kazakh ones.
  final bool fromRussian;

  String get prompt => fromRussian ? word.ru : word.kk;
  String get answer => fromRussian ? word.kk : word.ru;
}

/// A one-minute workout: a word, two translations to pick from, both ways.
/// A missed word comes back once at the end; fixing it earns a bonus.
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
  List<_Task>? _queue;
  List<Word> _all = const [];
  var _index = 0;
  List<String> _options = const [];
  String? _picked;

  /// Word id → right on the first try.
  final _results = <int, bool>{};
  final _requeued = <int>{};
  var _fixed = 0;
  var _earned = 0;
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
      _queue = [
        for (final w in picked) _Task(w, fromRussian: _random.nextBool()),
      ];
      _options = _optionsFor(_queue!.first);
    });
  }

  List<String> _optionsFor(_Task t) {
    String side(Word w) => t.fromRussian ? w.kk : w.ru;
    String other;
    do {
      other = side(_all[_random.nextInt(_all.length)]);
    } while (other == t.answer);
    return [t.answer, other]..shuffle(_random);
  }

  Future<void> _pick(String option) async {
    if (_picked != null) return;
    final queue = _queue!;
    final task = queue[_index];
    final id = task.word.id;
    final ok = option == task.answer;
    ok ? Haptics.success() : Haptics.error();
    setState(() {
      _picked = option;
      _results[id] = (_results[id] ?? true) && ok;
      if (ok) {
        _earned += watchXpPerAnswer;
        if (_requeued.contains(id) && ++_fixed <= fixedMistakeCap) {
          _earned += fixedMistakeXp;
        }
      } else if (_requeued.add(id)) {
        queue.add(_Task(task.word, fromRussian: task.fromRussian));
      }
    });
    await Future<void>.delayed(Duration(milliseconds: ok ? 800 : 1400));
    if (!mounted) return;
    if (_index + 1 < queue.length) {
      setState(() {
        _index++;
        _picked = null;
        _options = _optionsFor(queue[_index]);
      });
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final now = DateTime.now();
    final right = _results.values.where((r) => r).length;
    await ref.read(progressRepositoryProvider).applySession(_results, now);
    await ref
        .read(statsRepositoryProvider)
        .recordSession(
          xp: _earned,
          correct: right,
          total: _results.length,
          now: now,
        );
    if (mounted) setState(() => _xp = _earned);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final queue = _queue;
    if (queue == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final quiet = ref.watch(quietModeProvider);
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
            quiet
                ? '$right из ${_results.length}'
                : '$right из ${_results.length} · +$xp XP',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
          ),
          if (_fixed > 0)
            Text(
              'Исправлено: $_fixed',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.okText, fontWeight: FontWeight.w800),
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
    final task = queue[_index];
    final wrong = _picked != null && _picked != task.answer;
    final retry = _requeued.contains(task.word.id) && _picked == null;
    return _Round(
      children: [
        const SizedBox(height: 8),
        Text(
          retry
              ? 'Ещё раз · ${_index + 1} / ${queue.length}'
              : '${_index + 1} / ${queue.length}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: retry ? AppColors.gold : c.muted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        // Long words shrink to one line instead of breaking mid-word.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            task.prompt,
            key: watchPromptKey,
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
                  : o == task.answer
                  ? AppColors.okButton
                  : o == _picked
                  ? AppColors.tryButton
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
                color: _picked != null && (o == task.answer || o == _picked)
                    ? Colors.white
                    : c.ink,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (wrong)
          Text(
            'Вернётся в конце',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}
