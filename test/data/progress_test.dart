import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/dictionary_repository.dart';
import 'package:qazaqsha/data/repositories/lesson_repository.dart';
import 'package:qazaqsha/data/repositories/progress_repository.dart';
import 'package:qazaqsha/data/repositories/stats_repository.dart';
import 'package:qazaqsha/features/gamification/achievements.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ProgressRepository progress;
  late StatsRepository stats;
  late LessonRepository lessons;
  final now = DateTime(2026, 10, 28, 12);

  setUp(() {
    db = testDatabase();
    progress = ProgressRepository(db);
    stats = StatsRepository(db);
    lessons = LessonRepository(db, DictionaryRepository(db));
  });

  tearDown(() => db.close());

  test('session results schedule reviews and count answers', () async {
    await progress.applySession({1: true, 2: false}, now);
    final map = await progress.watchAll().first;
    expect(map[1]!.box, 1);
    expect(map[1]!.status, LearningStatus.learning);
    expect(map[1]!.nextReviewAt, now.add(const Duration(days: 1)));
    expect(map[2]!.wrongCount, 1);

    // Only the failed word is due right now.
    expect((await progress.dueWords(now)).map((w) => w.id), [2]);
    // Tomorrow both are.
    final tomorrow = now.add(const Duration(days: 1));
    expect((await progress.dueWords(tomorrow)).map((w) => w.id), [2, 1]);
  });

  test('favorites toggle and survive a session', () async {
    await progress.toggleFavorite(7);
    await progress.applySession({7: true}, now);
    expect((await progress.watchAll().first)[7]!.isFavorite, isTrue);
    await progress.toggleFavorite(7);
    expect((await progress.watchAll().first)[7]!.isFavorite, isFalse);
  });

  test('sessions add XP, daily XP and streak', () async {
    var s = await stats.recordSession(xp: 30, correct: 4, total: 5, now: now);
    expect((s.xp, s.dailyXp, s.streakDays, s.quizzesCompleted), (30, 30, 1, 1));

    s = await stats.recordSession(xp: 20, correct: 5, total: 5, now: now);
    expect((s.xp, s.dailyXp, s.streakDays), (50, 50, 1));

    final next = now.add(const Duration(days: 1));
    s = await stats.recordSession(xp: 10, correct: 1, total: 1, now: next);
    expect((s.xp, s.dailyXp, s.streakDays), (60, 10, 2));
    expect((s.answersCorrect, s.answersTotal), (10, 11));
  });

  test('achievements unlock once', () async {
    const facts = AchievementFacts(
      quizzesCompleted: 1,
      streakDays: 3,
      learnedWords: 0,
      totalXp: 50,
      lastSessionPerfect: true,
    );
    final first = await stats.unlockEarned(facts, now);
    expect(first.map((a) => a.id), ['first_lesson', 'perfect', 'streak_3']);
    expect(await stats.unlockEarned(facts, now), isEmpty);
  });

  Future<void> finishTopic(String categoryId, int lessonCount) async {
    for (var i = 0; i < lessonCount; i++) {
      await lessons.completeLesson(
        categoryId: categoryId,
        lessonIndex: i,
        score: 90,
        now: now,
      );
    }
  }

  test('topics unlock in order, lessons one by one', () async {
    var course = await lessons.watchCourse().first;
    final topics = course.sections.first.topics;
    expect(topics.first.unlocked, isTrue);
    expect(topics[1].unlocked, isFalse);
    expect(topics.first.lessonCount, 5);
    expect(course.sections.map((s) => s.topics.length), [6, 8, 4, 5, 8, 6, 9]);
    expect(course.next, isA<NextLesson>());

    await finishTopic('greetings', 5);
    course = await lessons.watchCourse().first;
    final after = course.sections.first.topics;
    expect(after.first.completed, isTrue);
    expect(after[1].unlocked, isTrue);
    expect(after[1].nextLesson, 0);
    expect(after[2].unlocked, isFalse);
    expect(course.lessonsDone, 5);

    final words = await lessons.lessonWords('greetings', 0);
    expect(words.map((w) => w.kk).first, 'сәлеметсіз бе');
  });

  test(
    'a section exam opens after its lessons and gates the next section',
    () async {
      var course = await lessons.watchCourse().first;
      final basics = course.sections.first;
      for (final t in basics.topics) {
        await finishTopic(t.category.id, t.lessonCount);
      }

      course = await lessons.watchCourse().first;
      expect(course.sections[0].examUnlocked, isTrue);
      expect(course.sections[1].unlocked, isFalse);
      expect(course.sections[1].topics.first.unlocked, isFalse);
      expect(course.next, isA<NextExam>());

      // 70% is not enough; the best score is still kept.
      expect(
        await lessons.recordExam(sectionId: 'basics', score: 70, now: now),
        isFalse,
      );
      course = await lessons.watchCourse().first;
      expect(course.sections[0].examBestScore, 70);
      expect(course.sections[1].unlocked, isFalse);
      expect(await lessons.examsPassed(), 0);

      expect(
        await lessons.recordExam(sectionId: 'basics', score: 85, now: now),
        isTrue,
      );
      course = await lessons.watchCourse().first;
      expect(course.sections[0].examPassed, isTrue);
      expect(course.sections[1].unlocked, isTrue);
      expect(course.sections[1].topics.first.unlocked, isTrue);
      expect(course.next, isA<NextLesson>());
      expect(await lessons.examsPassed(), 1);

      // A later, worse attempt doesn't take the pass away.
      await lessons.recordExam(sectionId: 'basics', score: 40, now: now);
      course = await lessons.watchCourse().first;
      expect(course.sections[0].examPassed, isTrue);
      expect(course.sections[0].examBestScore, 85);
    },
  );

  test('study time adds up from finished and abandoned sessions', () async {
    await stats.recordSession(
      xp: 10,
      correct: 1,
      total: 1,
      now: now,
      studySeconds: 300,
    );
    await stats.addStudyTime(45);
    await stats.addStudyTime(0);
    expect((await stats.get()).studySeconds, 345);
  });
}
