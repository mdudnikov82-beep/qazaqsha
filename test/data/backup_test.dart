import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/backup_repository.dart';
import 'package:qazaqsha/data/repositories/custom_words_repository.dart';
import 'package:qazaqsha/data/repositories/progress_repository.dart';
import 'package:qazaqsha/data/repositories/stats_repository.dart';
import 'package:qazaqsha/features/custom_words/word_import.dart';
import 'package:qazaqsha/features/gamification/achievements.dart';
import 'package:qazaqsha/features/gamification/progress_rules.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late StatsRepository stats;

  BackupRepository backupOf(AppDatabase db) =>
      BackupRepository(db, CustomWordsRepository(db));

  setUp(() {
    db = testDatabase();
    stats = StatsRepository(db);
  });

  tearDown(() => db.close());

  /// Two sessions on two days, one own word learned, an achievement.
  Future<void> study() async {
    final day1 = DateTime(2026, 10, 27, 18);
    final day2 = DateTime(2026, 10, 28, 9);
    await CustomWordsRepository(db)
        .addWords(const [ImportedWord('тиін', 'белка')]);
    final squirrel = await (db.select(
      db.words,
    )..where((w) => w.kk.equals('тиін'))).getSingle();
    await ProgressRepository(db)
        .applySession({1: true, squirrel.id: false}, day1);
    await stats.recordSession(
      xp: 30,
      correct: 5,
      total: 6,
      now: day1,
      studySeconds: 120,
    );
    await stats.recordSession(
      xp: 40,
      correct: 6,
      total: 6,
      now: day2,
      studySeconds: 60,
    );
    await stats.addStudyTime(15, now: day2);
    await stats.unlockEarned(
      const AchievementFacts(
        quizzesCompleted: 2,
        streakDays: 2,
        learnedWords: 0,
        totalXp: 70,
        fixedMistakes: 10,
      ),
      day2,
    );
    await stats.setUserName('  Максим ');
  }

  test('sessions are recorded per day, with the best streak', () async {
    await study();
    final days = await db.select(db.dailyActivity).get();
    expect(
      [
        for (final d in days)
          (dayOf(d.day.toUtc()), d.xp, d.seconds, d.sessions),
      ],
      [
        (DateTime.utc(2026, 10, 27), 30, 120, 1),
        (DateTime.utc(2026, 10, 28), 40, 75, 1),
      ],
    );
    final s = await stats.get();
    expect((s.streakDays, s.bestStreak, s.userName), (2, 2, 'Максим'));
  });

  test('a backup code restores everything into a fresh install', () async {
    await study();
    final code = await backupOf(db).exportCode();
    expect(code, startsWith('QZB1-'));

    final other = testDatabase();
    addTearDown(other.close);
    await backupOf(other).importCode('  $code\n');

    final s = await StatsRepository(other).get();
    expect(
      (s.xp, s.bestStreak, s.quizzesCompleted, s.studySeconds, s.userName),
      (70, 2, 2, 195, 'Максим'),
    );
    expect(await other.select(other.dailyActivity).get(), hasLength(2));
    expect(
      (await other.select(other.unlockedAchievements).get()).map((a) => a.id),
      containsAll(['first_lesson', 'fixed_10']),
    );
    // The own word came along, with its progress.
    final squirrel = await (other.select(
      other.words,
    )..where((w) => w.kk.equals('тиін'))).getSingle();
    final progress = await other.select(other.wordProgress).get();
    expect(progress.map((p) => p.wordId), containsAll([1, squirrel.id]));
  });

  test('own sets travel in the backup with names and notes', () async {
    final repo = CustomWordsRepository(db);
    final work = await repo.createSet('Работа');
    await repo.addWords(const [
      ImportedWord('кеңсе қызметкері', 'офисный работник'),
    ], setId: work);
    final w = (await repo.words(work)).single;
    await repo.updateWord(w.id, kk: w.kk, ru: w.ru, note: 'о человеке');
    final code = await backupOf(db).exportCode();

    final other = testDatabase();
    addTearDown(other.close);
    await backupOf(other).importCode(code);
    final otherRepo = CustomWordsRepository(other);
    final sets = await otherRepo.sets();
    expect(sets.map((s) => s.titleRu), ['Работа']);
    final restored = (await otherRepo.words(sets.last.id)).single;
    expect((restored.kk, restored.note), ('кеңсе қызметкері', 'о человеке'));
  });

  test('a broken code changes nothing', () async {
    await study();
    final backup = backupOf(db);
    for (final bad in ['', 'привет', 'QZB1-!!!', 'QZB1-e30']) {
      await expectLater(backup.importCode(bad), throwsA(isA<BadBackupCode>()));
    }
    expect((await stats.get()).xp, 70);
  });

  test('reset clears progress but keeps own words and settings', () async {
    await study();
    await stats.setDailyGoal(100);
    await backupOf(db).resetProgress();

    final s = await stats.get();
    expect((s.xp, s.streakDays, s.bestStreak, s.studySeconds), (0, 0, 0, 0));
    expect((s.dailyGoalXp, s.userName), (100, 'Максим'));
    expect(await db.select(db.wordProgress).get(), isEmpty);
    expect(await db.select(db.dailyActivity).get(), isEmpty);
    expect(await db.select(db.unlockedAchievements).get(), isEmpty);
    expect(
      await (db.select(db.words)..where((w) => w.kk.equals('тиін'))).get(),
      hasLength(1),
    );
  });
}
