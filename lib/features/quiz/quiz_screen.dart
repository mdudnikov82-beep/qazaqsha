import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/barys.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/ornament.dart';
import '../../core/widgets/confetti.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/stats_repository.dart';
import '../gamification/achievements.dart';
import '../review/review_mode.dart';
import '../lessons/sections.dart';
import 'answer_check.dart';
import 'questions.dart';
import 'quiz_engine.dart';
import 'quiz_session.dart';
import 'quiz_views.dart';

/// A lesson, a review of due words, or a section exam.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen.lesson({
    super.key,
    required String this.categoryId,
    required int this.lessonIndex,
  }) : sectionId = null,
       isCustom = false,
       reviewMode = ReviewMode.due,
       setId = null;

  const QuizScreen.review({super.key, this.reviewMode = ReviewMode.due})
    : categoryId = null,
      lessonIndex = null,
      sectionId = null,
      isCustom = false,
      setId = null;

  const QuizScreen.exam({super.key, required String this.sectionId})
    : categoryId = null,
      lessonIndex = null,
      isCustom = false,
      reviewMode = ReviewMode.due,
      setId = null;

  /// Practice of the user's own words: one set, or all of them.
  const QuizScreen.custom({super.key, this.setId})
    : categoryId = null,
      lessonIndex = null,
      sectionId = null,
      isCustom = true,
      reviewMode = ReviewMode.due;

  final String? categoryId;
  final int? lessonIndex;
  final String? sectionId;
  final bool isCustom;
  final ReviewMode reviewMode;

  /// Own word set to practise; null = all own words.
  final String? setId;

  bool get isLesson => categoryId != null;
  bool get isExam => sectionId != null;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

enum _Feedback { none, right, wrong, almost }

enum _Kind { lesson, review, exam, custom }

/// Words per practice of the user's own words.
const _customPracticeSize = 6;

class _Result {
  const _Result(
    this.kind,
    this.xp,
    this.score,
    this.newAchievements, {
    this.examPassed = false,
    this.seconds = 0,
  });

  final _Kind kind;
  final int xp;
  final int score;
  final List<Achievement> newAchievements;
  final bool examPassed;
  final int seconds;
}

/// Longest time one session can add to the study total.
const _maxSessionTime = Duration(hours: 1);

class _QuizScreenState extends ConsumerState<QuizScreen>
    with WidgetsBindingObserver {
  final _engine = QuizEngine();
  final _typed = TextEditingController();
  QuizSession? _session;
  Object? _error;
  _Result? _result;
  bool _saving = false;

  /// Runs only while the app is in the foreground.
  final _clock = Stopwatch();

  /// Read up front: `ref` can't be used any more in [dispose].
  late final StatsRepository _statsRepo = ref.read(statsRepositoryProvider);

  int get _studySeconds => _clock.elapsed > _maxSessionTime
      ? _maxSessionTime.inSeconds
      : _clock.elapsed.inSeconds;

  _Kind get _kind => widget.isExam
      ? _Kind.exam
      : widget.isLesson
      ? _Kind.lesson
      : widget.isCustom
      ? _Kind.custom
      : _Kind.review;

  _Feedback _feedback = _Feedback.none;
  int? _picked;
  TypedVerdict? _verdict;
  Set<int>? _matchMistakes;

  /// Indices into the current [SentenceQuestion.tiles], in tapped order.
  final List<int> _built = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _statsRepo; // Resolve now, while ref is usable.
    _typed.addListener(() => setState(() {}));
    _clock.start();
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_result == null) _clock.start();
    } else {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Time of a session left before the end still counts.
    if (_result == null && !_saving) {
      _statsRepo.addStudyTime(_studySeconds);
    }
    _typed.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final pool = await ref.read(allWordsProvider.future);
      final List<Question> questions;
      if (widget.isLesson) {
        final words = await ref
            .read(lessonRepositoryProvider)
            .lessonWords(widget.categoryId!, widget.lessonIndex!);
        final progress = await ref.read(progressMapProvider.future);
        final sentences = await ref
            .read(dictionaryRepositoryProvider)
            .sentencesInCategory(widget.categoryId!);
        questions = _engine.buildLesson(
          lessonWords: words,
          pool: pool,
          sentences: sentences,
          withIntro: words.any(
            (w) =>
                (progress[w.id]?.status ?? LearningStatus.fresh) ==
                LearningStatus.fresh,
          ),
        );
      } else if (widget.isCustom) {
        final progress = await ref.read(progressMapProvider.future);
        // Fresh words first, then the weakest (lowest repetition box).
        final words =
            [
              ...await ref
                  .read(customWordsRepositoryProvider)
                  .words(widget.setId),
            ]..sort(
              (a, b) => (progress[a.id]?.box ?? -1).compareTo(
                progress[b.id]?.box ?? -1,
              ),
            );
        final picked = words.take(_customPracticeSize).toList();
        questions = _engine.buildLesson(
          lessonWords: picked,
          pool: pool,
          withIntro: picked.any((w) => progress[w.id] == null),
        );
      } else if (widget.isExam) {
        final section = sectionById(widget.sectionId!)!;
        final dictionary = ref.read(dictionaryRepositoryProvider);
        questions = _engine.buildExam(
          sectionWords: await dictionary.wordsInCategories(section.categoryIds),
          sentences: await dictionary.sentencesInCategories(
            section.categoryIds,
          ),
          pool: pool,
        );
      } else {
        final due = await ref
            .read(progressRepositoryProvider)
            .reviewWords(widget.reviewMode, DateTime.now());
        questions = _engine.buildReview(words: due, pool: pool);
      }
      setState(
        () => _session = QuizSession(questions, retryMistakes: !widget.isExam),
      );
    } catch (e) {
      setState(() => _error = e);
    }
  }

  void _close() => context.canPop() ? context.pop() : context.go('/lessons');

  // --- answering ---------------------------------------------------------

  /// Right answers in a row; shown in the header and praised.
  int _combo = 0;

  void _react(bool correct) {
    correct ? Haptics.success() : Haptics.error();
    _combo = correct ? _combo + 1 : 0;
  }

  /// Wrong answers go to the mistakes notebook; right ones take a word
  /// back out of it.
  void _note(
    bool correct,
    Word word, {
    String? prompt,
    String? answer,
    String given = '',
  }) {
    final repo = ref.read(mistakesRepositoryProvider);
    final id = '${word.id}';
    if (correct) {
      repo.resolve(MistakeKind.word, id);
    } else {
      repo.record(
        kind: MistakeKind.word,
        ref: id,
        prompt: prompt ?? word.ru,
        answer: answer ?? word.kk,
        given: given,
      );
    }
  }

  void _pick(int i) {
    final q = _session!.current as ChoiceQuestion;
    final correct = i == q.correctIndex;
    _note(
      correct,
      q.word,
      prompt: q.prompt,
      answer: q.answer,
      given: q.options[i],
    );
    _session!.answer(correct: correct);
    _react(correct);
    setState(() {
      _picked = i;
      _feedback = correct ? _Feedback.right : _Feedback.wrong;
    });
  }

  void _checkTyped() {
    final q = _session!.current as TypeQuestion;
    if (_typed.text.trim().isEmpty || _verdict != null) return;
    final verdict = checkTyped(_typed.text, q.word.kk);
    _note(verdict == TypedVerdict.correct, q.word, given: _typed.text.trim());
    _session!.answer(correct: verdict == TypedVerdict.correct);
    _react(verdict == TypedVerdict.correct);
    setState(() {
      _verdict = verdict;
      _feedback = switch (verdict) {
        TypedVerdict.correct => _Feedback.right,
        TypedVerdict.almost => _Feedback.almost,
        TypedVerdict.wrong => _Feedback.wrong,
      };
    });
  }

  void _checkSentence() {
    final q = _session!.current as SentenceQuestion;
    if (_built.isEmpty || _feedback != _Feedback.none) return;
    final built = [for (final i in _built) q.tiles[i]];
    final correct = checkSentence(built, q.sentence.kk);
    final mistakes = ref.read(mistakesRepositoryProvider);
    final id = '${q.sentence.id}';
    if (correct) {
      mistakes.resolve(MistakeKind.sentence, id);
    } else {
      mistakes.record(
        kind: MistakeKind.sentence,
        ref: id,
        prompt: q.sentence.ru,
        answer: q.sentence.kk,
        given: built.join(' '),
      );
    }
    _session!.answer(correct: correct);
    _react(correct);
    setState(() => _feedback = correct ? _Feedback.right : _Feedback.wrong);
  }

  void _matched(Set<int> mistakes) {
    for (final w in (_session!.current as MatchQuestion).pairs) {
      _note(!mistakes.contains(w.id), w);
    }
    _session!.answer(correct: mistakes.isEmpty, mistakeWordIds: mistakes);
    _react(mistakes.isEmpty);
    setState(() {
      _matchMistakes = mistakes;
      _feedback = mistakes.isEmpty ? _Feedback.right : _Feedback.wrong;
    });
  }

  void _next() {
    final s = _session!;
    s.next();
    _typed.clear();
    setState(() {
      _feedback = _Feedback.none;
      _picked = null;
      _verdict = null;
      _matchMistakes = null;
      _built.clear();
    });
    if (s.isFinished) _finish();
  }

  Future<void> _finish() async {
    final s = _session!;
    if (_saving) return;
    setState(() => _saving = true);
    _clock.stop();
    final now = DateTime.now();
    final lessons = ref.read(lessonRepositoryProvider);
    final progress = ref.read(progressRepositoryProvider);
    final stats = ref.read(statsRepositoryProvider);

    var xp = s.xp;
    var examPassed = false;
    if (widget.isLesson) {
      xp += lessonBonusXp;
      await lessons.completeLesson(
        categoryId: widget.categoryId!,
        lessonIndex: widget.lessonIndex!,
        score: s.scorePercent,
        now: now,
      );
    }
    if (widget.isExam) {
      examPassed = await lessons.recordExam(
        sectionId: widget.sectionId!,
        score: s.scorePercent,
        now: now,
      );
      if (examPassed) xp += examPassBonusXp;
    }

    await progress.applySession(s.wordResults, now);
    final after = await stats.recordSession(
      xp: xp,
      correct: s.correctAnswers,
      total: s.totalAnswers,
      now: now,
      studySeconds: _studySeconds,
    );
    final unlocked = await stats.unlockEarned(
      AchievementFacts(
        quizzesCompleted: after.quizzesCompleted,
        streakDays: after.streakDays,
        learnedWords: await progress.learnedCount(),
        totalXp: after.xp,
        lastSessionPerfect: s.perfect,
        examsPassed: await lessons.examsPassed(),
      ),
      now,
    );
    if (mounted) {
      setState(
        () => _result = _Result(
          _kind,
          xp,
          s.scorePercent,
          unlocked,
          examPassed: examPassed,
          seconds: _studySeconds,
        ),
      );
    }
  }

  // --- UI ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final s = _session;
    if (s == null) return LoadingScaffold(error: _error);
    if (s.length == 0) return _EmptyReview(onClose: _close);
    if (_result != null) {
      return _ResultView(result: _result!, onClose: _close);
    }
    if (s.isFinished) return const LoadingScaffold();

    final c = context.colors;
    final q = s.current;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Закрыть',
                    onPressed: _close,
                    icon: Icon(Icons.close_rounded, color: c.muted),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: s.progress),
                      duration: reduceMotion(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => ProgressBar(
                        value: v,
                        height: 14,
                        semanticsLabel: 'Прогресс урока',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  if (_combo >= 2)
                    ReactionBox(
                      reaction: Reaction.pop,
                      trigger: _combo,
                      child: Pill(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: c.flame,
                        text: '$_combo',
                        background: c.goldSoft,
                        foreground: c.ink,
                        semanticsLabel: 'Правильных подряд: $_combo',
                      ),
                    )
                  else
                    Text(
                      '${s.position + 1}/${s.length}',
                      style: TextStyle(
                        color: c.muted,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: switch (q) {
                  IntroCard(:final word) => IntroView(word: word),
                  ChoiceQuestion() => ChoiceView(
                    question: q,
                    xp: s.lastXp,
                    picked: _picked,
                    onPick: _pick,
                  ),
                  TypeQuestion() => TypeView(
                    question: q,
                    controller: _typed,
                    verdict: _verdict,
                    onSubmit: _checkTyped,
                  ),
                  MatchQuestion() => MatchView(
                    key: ObjectKey(q),
                    question: q,
                    onComplete: _matched,
                  ),
                  SentenceQuestion() => SentenceView(
                    question: q,
                    built: _built,
                    locked: _feedback != _Feedback.none,
                    reaction: switch (_feedback) {
                      _Feedback.none => Reaction.none,
                      _Feedback.right => Reaction.pop,
                      _ => Reaction.shake,
                    },
                    onAdd: (i) => setState(() => _built.add(i)),
                    onRemove: (pos) => setState(() => _built.removeAt(pos)),
                  ),
                },
              ),
            ),
            _BottomPanel(
              question: q,
              feedback: _feedback,
              xp: s.lastXp,
              fixed: s.lastFixed,
              canCheck: q is SentenceQuestion
                  ? _built.isNotEmpty
                  : _typed.text.trim().isNotEmpty,
              matchMistakes: _matchMistakes?.length ?? 0,
              onCheck: q is SentenceQuestion ? _checkSentence : _checkTyped,
              onNext: _next,
              retriesMistakes: s.retryMistakes,
              combo: _combo,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends ConsumerWidget {
  const _BottomPanel({
    required this.question,
    required this.feedback,
    required this.xp,
    required this.fixed,
    required this.canCheck,
    required this.matchMistakes,
    required this.onCheck,
    required this.onNext,
    required this.retriesMistakes,
    required this.combo,
  });

  final Question question;
  final _Feedback feedback;
  final int xp;
  final bool fixed;
  final bool canCheck;
  final int matchMistakes;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final bool retriesMistakes;
  final int combo;

  String get _answer => switch (question) {
    ChoiceQuestion(:final answer, :final word, :final fromRussian) =>
      fromRussian ? '$answer — ${word.ru}' : '${word.kk} — $answer',
    TypeQuestion(:final word) => '${word.kk} — ${word.ru}',
    SentenceQuestion(:final sentence) => '${sentence.kk} — ${sentence.ru}',
    _ => '',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiet = ref.watch(quietModeProvider);
    final c = context.colors;
    final q = question;

    if (feedback == _Feedback.none) {
      final Widget child = switch (q) {
        IntroCard() => FilledButton(
          onPressed: onNext,
          child: const Text('Дальше'),
        ),
        TypeQuestion() || SentenceQuestion() => FilledButton(
          onPressed: canCheck ? onCheck : null,
          child: const Text('Проверить'),
        ),
        _ => Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.track,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            q is MatchQuestion
                ? 'Нажмите слово слева, затем его пару'
                : 'Нажмите на вариант ответа',
            style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
          ),
        ),
      };
      return Padding(padding: const EdgeInsets.all(20), child: child);
    }

    final right = feedback == _Feedback.right;
    final (title, details) = switch (feedback) {
      _Feedback.right when fixed => ('Исправлено! Так и учатся', _answer),
      _Feedback.right => ('Дұрыс! Правильно', _answer),
      _Feedback.almost => (
        'Почти! Обратите внимание на буквы',
        'Правильно: $_answer',
      ),
      _ when q is MatchQuestion => (
        'Пары собраны',
        'Ошибок: $matchMistakes. Эти слова попадут в повторение.',
      ),
      _ => (
        'Пока неверно',
        retriesMistakes
            ? 'Правильно: $_answer. Вопрос повторится в конце.'
            : 'Правильно: $_answer.',
      ),
    };
    final fg = right ? c.okText : c.badText;
    // Kazakh praise for a run of right answers.
    final praise = !right || combo < 3
        ? null
        : combo >= 5
        ? 'Керемет! $combo подряд'
        : 'Жарайсың! $combo подряд';

    return SlideUp(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: right ? c.okSoft : c.badSoft,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  right ? Icons.check_circle_rounded : Icons.info_rounded,
                  color: fg,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: fg,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (right && !quiet)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '+$xp XP',
                      style: TextStyle(color: fg, fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                details,
                style: TextStyle(color: fg, fontWeight: FontWeight.w700),
              ),
            ],
            if (praise != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: c.flame,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    praise,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            FilledButton(
              autofocus: true,
              style: FilledButton.styleFrom(
                backgroundColor: right
                    ? AppColors.okButton
                    : AppColors.badButton,
              ),
              onPressed: onNext,
              child: Text(right ? 'Далее' : 'Понятно'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.result, required this.onClose});

  final _Result result;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiet = ref.watch(quietModeProvider);
    final c = context.colors;
    final failedExam = result.kind == _Kind.exam && !result.examPassed;
    final (title, subtitle) = switch (result.kind) {
      _Kind.lesson => ('Сабақ аяқталды!', 'Урок пройден'),
      _Kind.review => ('Қайталау аяқталды!', 'Повторение завершено'),
      _Kind.custom => ('Жаттығу аяқталды!', 'Тренировка своих слов завершена'),
      _Kind.exam when result.examPassed => (
        'Емтихан тапсырылды!',
        'Экзамен сдан — следующий раздел открыт',
      ),
      _Kind.exam => (
        'Тағы бір рет!',
        'Для сдачи нужно $examPassScore% правильных ответов. '
            'Повторите слова раздела и попробуйте снова.',
      ),
    };
    final minutes = result.seconds ~/ 60;
    final seconds = (result.seconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                Center(
                  child: SizedBox(
                    width: 168,
                    height: 168,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        OrnamentRing(
                          size: 168,
                          color: AppColors.gold.withValues(alpha: 0.55),
                        ),
                        _PopIn(
                          child: Barys(
                            mood: failedExam
                                ? BarysMood.support
                                : BarysMood.celebrate,
                            size: 140,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                RiseIn(
                  delay: const Duration(milliseconds: 250),
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.muted, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                RiseIn(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      if (!quiet) ...[
                        Expanded(
                          child: _ResultStat(
                            // Counts up to the earned XP.
                            value: TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: result.xp),
                              duration: reduceMotion(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) => Text('+$v'),
                            ),
                            label: 'XP',
                            color: c.goldText,
                            border: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: _ResultStat(
                          value: Text('${result.score}%'),
                          label: 'точность',
                          color: result.score >= examPassScore
                              ? c.ok
                              : c.goldText,
                          border: result.score >= examPassScore
                              ? c.ok
                              : AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultStat(
                          value: Text('$minutes:$seconds'),
                          label: 'время',
                          color: c.accent,
                          border: c.sky,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final (i, a) in result.newAchievements.indexed) ...[
                  const SizedBox(height: 12),
                  RiseIn(
                    delay: Duration(milliseconds: 600 + 120 * i),
                    child: _AchievementBanner(achievement: a),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(onPressed: onClose, child: const Text('Готово')),
              ],
            ),
          ),
          if (!failedExam)
            Positioned.fill(
              child: Confetti(
                colors: [
                  AppColors.gold,
                  c.sky,
                  context.colors.brand,
                  c.flame,
                  c.ok,
                  const Color(0xFFB3366A),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Grows in with a little overshoot, once.
class _PopIn extends StatelessWidget {
  const _PopIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      child: child,
      builder: (context, t, child) =>
          Transform.scale(scale: 0.3 + 0.7 * t, child: child),
    );
  }
}

class _AchievementBanner extends StatefulWidget {
  const _AchievementBanner({required this.achievement});

  final Achievement achievement;

  @override
  State<_AchievementBanner> createState() => _AchievementBannerState();
}

class _AchievementBannerState extends State<_AchievementBanner>
    with SingleTickerProviderStateMixin {
  // A light sweeping across the card now and then.
  late final _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduceMotion(context) ? _shine.stop() : _shine.repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final a = widget.achievement;
    return Container(
      decoration: BoxDecoration(
        color: c.goldSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (_shine.isAnimating)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shine,
                builder: (context, _) => FractionalTranslation(
                  // Sweeps during the first 60% of each cycle, then rests.
                  translation: Offset(-1.2 + (_shine.value / 0.6) * 6, 0),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.2,
                    child: Transform(
                      transform: Matrix4.skewX(-0.35),
                      child: ColoredBox(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(a.icon, color: AppColors.onGold, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'НОВОЕ ДОСТИЖЕНИЕ',
                        style: TextStyle(
                          color: c.goldText,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        a.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(a.description, style: TextStyle(color: c.muted)),
                    ],
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

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.value,
    required this.label,
    required this.color,
    required this.border,
  });

  final Widget value;
  final String label;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 2),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
              child: value,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _EmptyReview extends StatelessWidget {
  const _EmptyReview({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Сейчас нечего повторять',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onClose, child: const Text('Назад')),
          ],
        ),
      ),
    );
  }
}
