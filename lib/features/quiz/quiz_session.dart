import 'questions.dart';

/// Bonus XP for finishing a lesson.
const lessonBonusXp = 20;

/// Extra XP for a mistake answered right on its second try: fixing an error
/// is worth more than never making one. Counted for a few per session, so
/// wrong answers on purpose don't pay.
const fixedMistakeXp = 10;
const fixedMistakeCap = 3;

/// Progress through one quiz: score, XP and per-word results.
/// A wrongly answered question is asked once more at the end, unless
/// [retryMistakes] is off (exams count each answer exactly once).
class QuizSession {
  QuizSession(List<Question> questions, {this.retryMistakes = true})
    : _queue = [...questions];

  final bool retryMistakes;
  final List<Question> _queue;
  final Set<Question> _requeued = {};
  int _index = 0;

  int xp = 0;
  int correctAnswers = 0;

  /// Mistakes answered right on the retry.
  int fixedMistakes = 0;

  /// XP the latest answer earned, and whether it fixed a mistake.
  int lastXp = 0;
  bool lastFixed = false;
  int totalAnswers = 0;

  /// wordId → answered correctly every time in this session.
  final Map<int, bool> wordResults = {};

  Question get current => _queue[_index];
  bool get isFinished => _index >= _queue.length;
  int get position => _index;
  int get length => _queue.length;
  double get progress => _queue.isEmpty ? 1 : _index / _queue.length;

  bool get perfect => totalAnswers > 0 && correctAnswers == totalAnswers;
  int get scorePercent =>
      totalAnswers == 0 ? 100 : (100 * correctAnswers / totalAnswers).round();

  /// Records the answer to [current]. For a [MatchQuestion] pass the ids of
  /// words matched wrongly at least once in [mistakeWordIds].
  void answer({required bool correct, Set<int> mistakeWordIds = const {}}) {
    final q = current;
    if (q is IntroCard) return;

    totalAnswers++;
    lastXp = 0;
    lastFixed = false;
    if (correct) {
      correctAnswers++;
      lastXp = xpFor(q);
      if (_requeued.contains(q)) {
        lastFixed = true;
        fixedMistakes++;
        if (fixedMistakes <= fixedMistakeCap) lastXp += fixedMistakeXp;
      }
      xp += lastXp;
    } else if (retryMistakes && !_requeued.contains(q)) {
      _requeued.add(q);
      _queue.add(q);
    }

    for (final w in q.words) {
      final ok = q is MatchQuestion ? !mistakeWordIds.contains(w.id) : correct;
      wordResults[w.id] = (wordResults[w.id] ?? true) && ok;
    }
  }

  void next() => _index++;
}
