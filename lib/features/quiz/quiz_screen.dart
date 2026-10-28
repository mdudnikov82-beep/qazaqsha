import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/stats_repository.dart';
import '../gamification/achievements.dart';
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
  }) : sectionId = null;

  const QuizScreen.review({super.key})
    : categoryId = null,
      lessonIndex = null,
      sectionId = null;

  const QuizScreen.exam({super.key, required String this.sectionId})
    : categoryId = null,
      lessonIndex = null;

  final String? categoryId;
  final int? lessonIndex;
  final String? sectionId;

  bool get isLesson => categoryId != null;
  bool get isExam => sectionId != null;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

enum _Feedback { none, right, wrong, almost }

enum _Kind { lesson, review, exam }

class _Result {
  const _Result(
    this.kind,
    this.xp,
    this.score,
    this.newAchievements, {
    this.examPassed = false,
  });

  final _Kind kind;
  final int xp;
  final int score;
  final List<Achievement> newAchievements;
  final bool examPassed;
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
            .dueWords(DateTime.now());
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

  void _pick(int i) {
    final q = _session!.current as ChoiceQuestion;
    final correct = i == q.correctIndex;
    _session!.answer(correct: correct);
    setState(() {
      _picked = i;
      _feedback = correct ? _Feedback.right : _Feedback.wrong;
    });
  }

  void _checkTyped() {
    final q = _session!.current as TypeQuestion;
    if (_typed.text.trim().isEmpty || _verdict != null) return;
    final verdict = checkTyped(_typed.text, q.word.kk);
    _session!.answer(correct: verdict == TypedVerdict.correct);
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
    final correct = checkSentence([
      for (final i in _built) q.tiles[i],
    ], q.sentence.kk);
    _session!.answer(correct: correct);
    setState(() => _feedback = correct ? _Feedback.right : _Feedback.wrong);
  }

  void _matched(Set<int> mistakes) {
    _session!.answer(correct: mistakes.isEmpty, mistakeWordIds: mistakes);
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
    if (s.perfect) xp += perfectBonusXp;

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
                    child: ProgressBar(
                      value: s.progress,
                      height: 14,
                      semanticsLabel: 'Прогресс урока',
                    ),
                  ),
                  const SizedBox(width: 14),
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
                    onAdd: (i) => setState(() => _built.add(i)),
                    onRemove: (pos) => setState(() => _built.removeAt(pos)),
                  ),
                },
              ),
            ),
            _BottomPanel(
              question: q,
              feedback: _feedback,
              xp: xpFor(q),
              canCheck: q is SentenceQuestion
                  ? _built.isNotEmpty
                  : _typed.text.trim().isNotEmpty,
              matchMistakes: _matchMistakes?.length ?? 0,
              onCheck: q is SentenceQuestion ? _checkSentence : _checkTyped,
              onNext: _next,
              retriesMistakes: s.retryMistakes,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.question,
    required this.feedback,
    required this.xp,
    required this.canCheck,
    required this.matchMistakes,
    required this.onCheck,
    required this.onNext,
    required this.retriesMistakes,
  });

  final Question question;
  final _Feedback feedback;
  final int xp;
  final bool canCheck;
  final int matchMistakes;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final bool retriesMistakes;

  String get _answer => switch (question) {
    ChoiceQuestion(:final answer, :final word, :final fromRussian) =>
      fromRussian ? '$answer — ${word.ru}' : '${word.kk} — $answer',
    TypeQuestion(:final word) => '${word.kk} — ${word.ru}',
    SentenceQuestion(:final sentence) => '${sentence.kk} — ${sentence.ru}',
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
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

    return Container(
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
              if (right)
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
          const SizedBox(height: 14),
          FilledButton(
            autofocus: true,
            style: FilledButton.styleFrom(
              backgroundColor: right ? AppColors.okButton : AppColors.badButton,
            ),
            onPressed: onNext,
            child: Text(right ? 'Далее' : 'Понятно'),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.onClose});

  final _Result result;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final failedExam = result.kind == _Kind.exam && !result.examPassed;
    final (title, subtitle) = switch (result.kind) {
      _Kind.lesson => ('Сабақ аяқталды!', 'Урок пройден'),
      _Kind.review => ('Қайталау аяқталды!', 'Повторение завершено'),
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
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Icon(
              failedExam ? Icons.refresh_rounded : Icons.emoji_events_rounded,
              size: 96,
              color: failedExam ? c.goldText : AppColors.gold,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _ResultStat(
                    value: '+${result.xp}',
                    label: 'XP',
                    color: c.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultStat(
                    value: '${result.score}%',
                    label: 'правильно',
                    color: result.score >= examPassScore ? c.ok : c.goldText,
                  ),
                ),
              ],
            ),
            for (final a in result.newAchievements) ...[
              const SizedBox(height: 12),
              SurfaceCard(
                color: c.goldSoft,
                child: Row(
                  children: [
                    Icon(a.icon, color: c.goldText, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Новое достижение: ${a.title}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(a.description),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(onPressed: onClose, child: const Text('Готово')),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: TextStyle(color: context.colors.muted)),
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
