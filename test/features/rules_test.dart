import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/tables.dart';
import 'package:qazaqsha/features/gamification/progress_rules.dart';
import 'package:qazaqsha/features/quiz/answer_check.dart';
import 'package:qazaqsha/features/quiz/srs.dart';

void main() {
  group('levels', () {
    test('thresholds grow by 100 more each level', () {
      expect(
        [for (var l = 1; l <= 5; l++) levelStartXp(l)],
        [0, 100, 300, 600, 1000],
      );
      expect(levelForXp(0), 1);
      expect(levelForXp(99), 1);
      expect(levelForXp(100), 2);
      expect(levelForXp(340), 3);
    });

    test('progress inside a level', () {
      final p = LevelProgress.fromXp(340);
      expect(p.level, 3);
      expect(p.xpIntoLevel, 40);
      expect(p.xpForLevel, 300);
    });
  });

  group('streak', () {
    final mon = DateTime(2026, 10, 26, 22);
    final tue = DateTime(2026, 10, 27, 8);
    final thu = DateTime(2026, 10, 29, 8);

    StreakStep step(
      int current,
      DateTime? last,
      DateTime now, {
      int freezes = 0,
    }) => advanceStreak(
      current: current,
      lastActive: last,
      now: now,
      freezes: freezes,
    );
    final wed = DateTime(2026, 10, 28, 9);
    final sun = DateTime(2026, 11, 1, 9);

    test('first activity starts a streak', () {
      expect(step(0, null, mon).streak, 1);
    });
    test('next calendar day extends it, even under 24 hours later', () {
      expect(step(3, mon, tue).streak, 4);
    });
    test('same day keeps it', () {
      expect(step(3, tue, tue).streak, 3);
    });
    test('without freezes a skipped day resets it, but it can be won back', () {
      final s = step(3, mon, wed);
      expect((s.streak, s.repairable), (1, 3));
      // Two missed days: no way back, start over.
      expect(step(3, mon, thu).repairable, 0);
      expect(visibleStreak(current: 3, lastActive: mon, now: wed), 0);
      expect(visibleStreak(current: 3, lastActive: mon, now: tue), 3);
    });
    test('a freeze covers a missed day and is used up', () {
      final s = step(5, mon, wed, freezes: 1);
      expect((s.streak, s.freezes), (6, 0));
      expect(s.frozenDays, [DateTime.utc(2026, 10, 27)]);
      expect(
        visibleStreak(current: 5, lastActive: mon, now: wed, freezes: 1),
        5,
      );
      expect(
        streakLapsed(current: 5, lastActive: mon, now: wed, freezes: 1),
        isFalse,
      );
      expect(
        streakLapsed(current: 5, lastActive: mon, now: thu, freezes: 1),
        isTrue,
      );
    });
    test('two freezes cover two days; not enough freezes, no cover', () {
      expect(step(5, mon, thu, freezes: 2).streak, 6);
      expect(step(5, mon, sun, freezes: 2).streak, 1);
    });
    test('every 7 days earn a freeze, at most 2', () {
      expect(step(6, mon, tue).freezes, 1);
      expect(step(13, mon, tue, freezes: 1).freezes, 2);
      expect(step(20, mon, tue, freezes: 2).freezes, 2);
      expect(step(7, mon, tue).freezes, 0);
    });
    test('winning back joins the old streak, the missed day and today', () {
      final s = repairStreak(brokenStreak: 6, currentStreak: 1, freezes: 0);
      expect(s.streak, 8);
      expect(s.freezes, 1); // passed 7 on the way
    });
    test('weeks start on Monday', () {
      expect(weekStart(thu), DateTime.utc(2026, 10, 26));
      expect(weekStart(sun), DateTime.utc(2026, 10, 26));
    });
    test('study time reads naturally', () {
      expect(formatStudyTime(0), '0 мин');
      expect(formatStudyTime(59), '0 мин');
      expect(formatStudyTime(12 * 60 + 30), '12 мин');
      expect(formatStudyTime(60 * 60), '1 ч');
      expect(formatStudyTime(65 * 60), '1 ч 5 мин');
    });

    test('daily XP resets on a new day', () {
      expect(todayXp(storedDailyXp: 40, storedDay: tue, now: tue), 40);
      expect(todayXp(storedDailyXp: 40, storedDay: mon, now: tue), 0);
      expect(todayXp(storedDailyXp: 40, storedDay: null, now: tue), 0);
    });
  });

  group('spaced repetition', () {
    final now = DateTime(2026, 10, 28);

    test('correct answers move the word to longer gaps', () {
      final s1 = scheduleReview(box: 0, correct: true, now: now);
      expect(s1.box, 1);
      expect(s1.nextReviewAt, now.add(const Duration(days: 1)));
      expect(s1.status, LearningStatus.learning);

      final s3 = scheduleReview(box: 2, correct: true, now: now);
      expect(s3.status, LearningStatus.learned);

      final top = scheduleReview(box: 5, correct: true, now: now);
      expect(top.box, 5);
    });

    test('a mistake sends the word back to box 0, due now', () {
      final s = scheduleReview(box: 4, correct: false, now: now);
      expect(s.box, 0);
      expect(s.nextReviewAt, now);
      expect(s.status, LearningStatus.learning);
    });
  });

  group('typed answers', () {
    test('ignores case, spaces, punctuation and ё', () {
      expect(checkTyped('  Рахмет! ', 'рахмет'), TypedVerdict.correct);
      expect(checkTyped('кім', 'кім?'), TypedVerdict.correct);
      expect(checkTyped('қайырлы   таң', 'қайырлы таң'), TypedVerdict.correct);
    });

    test('Russian look-alike letters are "almost"', () {
      expect(checkTyped('журек', 'жүрек'), TypedVerdict.almost);
      expect(checkTyped('кой', 'қой'), TypedVerdict.almost);
    });

    test('other answers are wrong', () {
      expect(checkTyped('жүрк', 'жүрек'), TypedVerdict.wrong);
      expect(checkTyped('', 'жүрек'), TypedVerdict.wrong);
    });

    test('sentences split into tiles without punctuation', () {
      expect(sentenceTokens('Көп рахмет, сау болыңыз!'), [
        'Көп',
        'рахмет',
        'сау',
        'болыңыз',
      ]);
      expect(sentenceTokens('Наурыз — үлкен мереке.'), [
        'Наурыз',
        'үлкен',
        'мереке',
      ]);
    });

    test('a built sentence must have the right words in the right order', () {
      const s = 'Менің әкем дәрігер.';
      expect(checkSentence(['менің', 'әкем', 'дәрігер'], s), isTrue);
      expect(checkSentence(['әкем', 'менің', 'дәрігер'], s), isFalse);
      expect(checkSentence(['менің', 'әкем'], s), isFalse);
      expect(checkSentence(['менің', 'әкем', 'дәрігер', 'үй'], s), isFalse);
    });

    test('phrase templates are not typeable', () {
      expect(isTypeable('менің атым…'), isFalse);
      expect(isTypeable('жүрек'), isTrue);
    });
  });
}
