import 'questions.dart';

/// Bonus XP for finishing a lesson, and for finishing it without mistakes.
const lessonBonusXp = 20;
const perfectBonusXp = 10;

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
    if (correct) {
      correctAnswers++;
      // A retry earns half: it still counts, but not like a first try.
      xp += _requeued.contains(q) ? xpFor(q) ~/ 2 : xpFor(q);
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
