import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/features/quiz/answer_check.dart';
import 'package:qazaqsha/features/quiz/questions.dart';
import 'package:qazaqsha/features/quiz/quiz_engine.dart';
import 'package:qazaqsha/features/quiz/quiz_session.dart';

Word _w(int id, String ru, String kk, [String cat = 'c']) => Word(
  id: id,
  categoryId: cat,
  ru: ru,
  kk: kk,
  sortOrder: id,
  searchText: '$ru $kk',
);

void main() {
  final pool = [
    _w(1, 'день', 'күн', 'time'),
    _w(2, 'солнце', 'күн', 'nature'),
    _w(3, 'ночь', 'түн', 'time'),
    _w(4, 'утро', 'таң', 'time'),
    _w(5, 'вечер', 'кеш', 'time'),
    _w(6, 'год', 'жыл', 'time'),
    _w(7, 'луна', 'ай', 'nature'),
    _w(8, 'месяц', 'ай', 'time'),
  ];

  group('lessons split', () {
    test('chunks of 5, short tail merged', () {
      expect(splitIntoLessons(List.generate(25, (i) => i)).length, 5);
      expect(
        splitIntoLessons(List.generate(22, (i) => i)).map((l) => l.length),
        [5, 5, 5, 7],
      );
      expect(
        splitIntoLessons(List.generate(13, (i) => i)).map((l) => l.length),
        [5, 5, 3],
      );
      for (final n in [2, 10, 12, 13, 16, 22, 25, 39, 45]) {
        expect(
          lessonCountFor(n),
          splitIntoLessons(List.generate(n, (i) => i)).length,
          reason: 'n=$n',
        );
      }
    });
  });

  group('engine', () {
    final engine = QuizEngine(random: Random(1));

    test('a homonym is never offered as a wrong option', () {
      for (var i = 0; i < 50; i++) {
        final lesson = engine.buildLesson(
          lessonWords: [pool[0], pool[2], pool[3]],
          pool: pool,
        );
        for (final q in lesson.whereType<ChoiceQuestion>()) {
          expect(q.options.toSet(), hasLength(q.options.length));
          expect(
            q.options[q.correctIndex],
            q.fromRussian ? q.word.kk : q.word.ru,
          );
          if (q.word.id == 1 && !q.fromRussian) {
            // Prompt «күн»: «солнце» would also be right, so it must not appear.
            expect(q.options, isNot(contains('солнце')));
          }
          if (q.word.id == 1 && q.fromRussian) {
            expect(q.options.where((o) => o == 'күн'), hasLength(1));
          }
        }
      }
    });

    test('lesson order: intro cards first, then quizzes and pairs', () {
      final lesson = engine.buildLesson(
        lessonWords: pool.sublist(2, 6),
        pool: pool,
      );
      expect(lesson.take(4).every((q) => q is IntroCard), isTrue);
      expect(lesson.whereType<MatchQuestion>(), hasLength(1));
      expect(lesson.whereType<TypeQuestion>(), isNotEmpty);
      final noIntro = engine.buildLesson(
        lessonWords: pool.sublist(2, 6),
        pool: pool,
        withIntro: false,
      );
      expect(noIntro.whereType<IntroCard>(), isEmpty);
    });

    test('lessons end with sentence tasks: own words plus 2 decoys', () {
      const sentences = [
        Sentence(
          id: 1,
          categoryId: 'time',
          ru: 'Сегодня пятница.',
          kk: 'Бүгін жұма.',
        ),
        Sentence(
          id: 2,
          categoryId: 'time',
          ru: 'Я встаю рано.',
          kk: 'Мен ерте тұрамын.',
        ),
        Sentence(
          id: 3,
          categoryId: 'time',
          ru: 'Завтра я работаю.',
          kk: 'Ертең мен жұмыс істеймін.',
        ),
      ];
      for (var i = 0; i < 20; i++) {
        final lesson = engine.buildLesson(
          lessonWords: pool.sublist(2, 6),
          pool: pool,
          sentences: sentences,
        );
        final tasks = lesson.whereType<SentenceQuestion>().toList();
        expect(tasks, hasLength(sentencesPerLesson));
        expect(lesson.last, isA<SentenceQuestion>());
        for (final t in tasks) {
          final own = sentenceTokens(t.sentence.kk);
          expect(t.tiles, containsAll(own));
          expect(t.tiles, hasLength(own.length + extraTiles));
          // No decoy may duplicate a real word, or the answer gets ambiguous.
          expect(
            t.tiles.map((x) => x.toLowerCase()).toSet(),
            hasLength(t.tiles.length),
          );
        }
      }
      // Without sentences a lesson simply has none.
      final plain = engine.buildLesson(
        lessonWords: pool.sublist(2, 6),
        pool: pool,
      );
      expect(plain.whereType<SentenceQuestion>(), isEmpty);
    });

    test('an exam covers the section without repeating a word', () {
      final section = [
        for (var i = 0; i < 30; i++) _w(100 + i, 'слово$i', 'сөз$i', 'sec'),
      ];
      const sentences = [
        Sentence(
          id: 1,
          categoryId: 'sec',
          ru: 'Я пью чай.',
          kk: 'Мен шай ішемін.',
        ),
        Sentence(id: 2, categoryId: 'sec', ru: 'Мама дома.', kk: 'Анам үйде.'),
        Sentence(id: 3, categoryId: 'sec', ru: 'Снег белый.', kk: 'Қар ақ.'),
      ];
      final exam = engine.buildExam(
        sectionWords: section,
        sentences: sentences,
        pool: [...pool, ...section],
      );
      expect(exam.whereType<IntroCard>(), isEmpty);
      expect(exam.whereType<ChoiceQuestion>(), hasLength(examChoices));
      expect(exam.whereType<TypeQuestion>(), hasLength(examTyping));
      expect(
        exam.whereType<MatchQuestion>().single.pairs,
        hasLength(examPairs),
      );
      expect(exam.whereType<SentenceQuestion>(), hasLength(examSentences));
      expect(exam, hasLength(15));

      final wordIds = [for (final q in exam) ...q.words.map((w) => w.id)];
      expect(wordIds.toSet(), hasLength(wordIds.length));
      expect(wordIds.every((id) => id >= 100), isTrue);
    });
  });

  group('session', () {
    test('scores, XP, retry of a wrong answer', () {
      final a = ChoiceQuestion(
        word: pool[2],
        fromRussian: true,
        options: const ['түн', 'таң'],
        correctIndex: 0,
      );
      final b = TypeQuestion(pool[3]);
      final s = QuizSession([IntroCard(pool[2]), a, b]);

      s.answer(correct: true); // intro: not scored
      s.next();
      s.answer(correct: true);
      s.next();
      s.answer(correct: false); // b goes to the end once
      s.next();
      expect(s.isFinished, isFalse);
      expect(s.current, same(b));
      s.answer(correct: true);
      s.next();

      expect(s.isFinished, isTrue);
      expect(s.totalAnswers, 3);
      expect(s.correctAnswers, 2);
      // The fixed mistake earns full points plus the fix bonus.
      expect(s.xp, 10 + 15 + fixedMistakeXp);
      expect(s.fixedMistakes, 1);
      expect(s.perfect, isFalse);
      expect(s.wordResults, {3: true, 4: false});
    });

    test('fix bonus counts for a few mistakes per session only', () {
      final qs = [for (final w in pool.sublist(2, 6)) TypeQuestion(w)];
      final s = QuizSession(qs);
      for (var i = 0; i < 4; i++) {
        s.answer(correct: false);
        s.next();
      }
      while (!s.isFinished) {
        s.answer(correct: true);
        expect(s.lastFixed, isTrue);
        s.next();
      }
      expect(s.fixedMistakes, 4);
      expect(s.xp, 4 * 15 + fixedMistakeCap * fixedMistakeXp);
    });

    test('in an exam a wrong answer is final', () {
      final b = TypeQuestion(pool[3]);
      final s = QuizSession([b], retryMistakes: false);
      s.answer(correct: false);
      s.next();
      expect(s.isFinished, isTrue);
      expect(s.scorePercent, 0);
    });

    test('match mistakes only mark the mismatched words', () {
      final s = QuizSession([MatchQuestion(pool.sublist(2, 5))]);
      s.answer(correct: false, mistakeWordIds: {4});
      expect(s.wordResults, {3: true, 4: false, 5: true});
    });
  });
}
