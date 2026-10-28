import 'dart:math';

import '../../data/database/app_database.dart';
import 'answer_check.dart';
import 'questions.dart';

/// Words per lesson. A short tail (< [_minLessonSize]) joins the previous lesson.
const lessonSize = 5;
const _minLessonSize = 3;

/// "Build the sentence" tasks per lesson, and decoy tiles per task.
const sentencesPerLesson = 2;
const extraTiles = 2;

/// Section exam make-up: 8 choices + 4 typing + 1 pairs (5 words)
/// + 2 sentences = 15 tasks.
const examChoices = 8;
const examTyping = 4;
const examPairs = 5;
const examSentences = 2;

List<List<T>> splitIntoLessons<T>(List<T> words) {
  final lessons = <List<T>>[
    for (var i = 0; i < words.length; i += lessonSize)
      words.sublist(i, min(i + lessonSize, words.length)),
  ];
  if (lessons.length > 1 && lessons.last.length < _minLessonSize) {
    final tail = lessons.removeLast();
    lessons.last = [...lessons.last, ...tail];
  }
  return lessons;
}

/// How many lessons [wordCount] words split into (see [splitIntoLessons]).
int lessonCountFor(int wordCount) {
  final full = wordCount ~/ lessonSize;
  final rest = wordCount % lessonSize;
  if (rest == 0) return full;
  return full > 0 && rest < _minLessonSize ? full : full + 1;
}

class QuizEngine {
  QuizEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Intro cards → Russian→Kazakh choices → pairs → mixed practice →
  /// up to [sentencesPerLesson] "build the sentence" tasks from [sentences].
  /// [pool] supplies wrong options; same-category words are preferred.
  List<Question> buildLesson({
    required List<Word> lessonWords,
    required List<Word> pool,
    List<Sentence> sentences = const [],
    bool withIntro = true,
  }) {
    final mixed = <Question>[];
    for (final (i, w) in lessonWords.indexed) {
      // Alternate typing and reverse choice; typing needs a typeable word.
      final type = i.isEven && isTypeable(w.kk);
      mixed.add(type ? TypeQuestion(w) : _choice(w, pool, fromRussian: false));
    }
    return [
      if (withIntro) ...lessonWords.map(IntroCard.new),
      ..._shuffled(lessonWords.map((w) => _choice(w, pool, fromRussian: true))),
      if (lessonWords.length >= 3) MatchQuestion(_shuffled(lessonWords)),
      ..._shuffled(mixed),
      for (final s in _shuffled(sentences).take(sentencesPerLesson))
        _sentence(s, sentences, pool),
    ];
  }

  /// The sentence's own words plus [extraTiles] decoys taken from other
  /// sentences (or the dictionary), never equal to a word already present.
  SentenceQuestion _sentence(
    Sentence s,
    List<Sentence> others,
    List<Word> pool,
  ) {
    final own = sentenceTokens(s.kk);
    final taken = own.map(normalizeAnswer).toSet();
    final candidates = _shuffled([
      for (final o in others)
        if (o.id != s.id) ...sentenceTokens(o.kk),
      for (final w in pool)
        if (!w.kk.contains(' ') && isTypeable(w.kk)) w.kk,
    ]);
    final extra = <String>[];
    for (final c in candidates) {
      if (extra.length == extraTiles) break;
      if (taken.add(normalizeAnswer(c))) extra.add(c);
    }
    return SentenceQuestion(sentence: s, tiles: _shuffled([...own, ...extra]));
  }

  /// A section exam: choices in both directions, typing, one pairs task and
  /// sentences, each on different words where possible. No intro cards.
  List<Question> buildExam({
    required List<Word> sectionWords,
    required List<Sentence> sentences,
    required List<Word> pool,
  }) {
    final words = _shuffled(sectionWords);
    final used = <int>{};
    List<Word> take(Iterable<Word> from, int n) {
      final picked = from.where((w) => !used.contains(w.id)).take(n).toList();
      used.addAll(picked.map((w) => w.id));
      return picked;
    }

    final choices = take(words, examChoices);
    final typing = take(words.where((w) => isTypeable(w.kk)), examTyping);
    final pairs = take(words, examPairs);
    return [
      ..._shuffled([
        for (final w in choices)
          _choice(w, pool, fromRussian: _random.nextBool()),
        ...typing.map(TypeQuestion.new),
        if (pairs.length >= 3) MatchQuestion(pairs),
      ]),
      for (final s in _shuffled(sentences).take(examSentences))
        _sentence(s, sentences, pool),
    ];
  }

  /// One choice and, when possible, one typing task per due word.
  List<Question> buildReview({
    required List<Word> words,
    required List<Word> pool,
  }) {
    return _shuffled([
      for (final w in words) ...[
        _choice(w, pool, fromRussian: _random.nextBool()),
        if (isTypeable(w.kk)) TypeQuestion(w),
      ],
    ]);
  }

  ChoiceQuestion _choice(
    Word word,
    List<Word> pool, {
    required bool fromRussian,
  }) {
    String shown(Word w) => fromRussian ? w.kk : w.ru;

    // A distractor must not be another valid answer: skip words that share
    // the prompt (homonyms like күн = день / солнце) or the shown text.
    bool usable(Word w) =>
        w.id != word.id &&
        w.kk != word.kk &&
        w.ru != word.ru &&
        shown(w) != shown(word);

    final sameCategory = _shuffled(
      pool.where((w) => w.categoryId == word.categoryId && usable(w)),
    );
    final others = _shuffled(
      pool.where((w) => w.categoryId != word.categoryId && usable(w)),
    );

    final options = <String>[shown(word)];
    for (final w in [...sameCategory, ...others]) {
      if (options.length == 4) break;
      if (!options.contains(shown(w))) options.add(shown(w));
    }
    options.shuffle(_random);
    return ChoiceQuestion(
      word: word,
      fromRussian: fromRussian,
      options: options,
      correctIndex: options.indexOf(shown(word)),
    );
  }

  List<T> _shuffled<T>(Iterable<T> items) => items.toList()..shuffle(_random);
}
