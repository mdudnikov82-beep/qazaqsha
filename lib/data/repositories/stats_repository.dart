import 'package:drift/drift.dart';

import '../../features/gamification/achievements.dart';
import '../../features/gamification/progress_rules.dart';
import '../database/app_database.dart';

class StatsRepository {
  StatsRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$UserStatsTable, UserStat> get _row =>
      _db.select(_db.userStats)..where((s) => s.id.equals(1));

  Stream<UserStat> watch() => _row.watchSingle();
  Future<UserStat> get() => _row.getSingle();

  /// Adds time from a session that was left before the end.
  Future<void> addStudyTime(int seconds) async {
    if (seconds <= 0) return;
    final s = await get();
    await (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(
      UserStatsCompanion(studySeconds: Value(s.studySeconds + seconds)),
    );
  }

  /// Adds the session's XP, answers and time, and moves the streak forward.
  Future<UserStat> recordSession({
    required int xp,
    required int correct,
    required int total,
    required DateTime now,
    int studySeconds = 0,
  }) async {
    final s = await get();
    final daily = todayXp(
      storedDailyXp: s.dailyXp,
      storedDay: s.dailyXpDate,
      now: now,
    );
    await (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(
      UserStatsCompanion(
        xp: Value(s.xp + xp),
        dailyXp: Value(daily + xp),
        dailyXpDate: Value(now),
        streakDays: Value(
          nextStreak(
            current: s.streakDays,
            lastActive: s.lastActiveDate,
            now: now,
          ),
        ),
        lastActiveDate: Value(now),
        quizzesCompleted: Value(s.quizzesCompleted + 1),
        answersCorrect: Value(s.answersCorrect + correct),
        answersTotal: Value(s.answersTotal + total),
        studySeconds: Value(s.studySeconds + studySeconds),
      ),
    );
    return get();
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(
        UserStatsCompanion(themeMode: Value(mode)),
      );

  Future<void> setDailyGoal(int xp) =>
      (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(
        UserStatsCompanion(dailyGoalXp: Value(xp)),
      );

  Stream<Set<String>> watchUnlocked() => _db
      .select(_db.unlockedAchievements)
      .watch()
      .map((rows) => {for (final r in rows) r.id});

  /// Unlocks every achievement [facts] now satisfy. Returns the new ones.
  Future<List<Achievement>> unlockEarned(
    AchievementFacts facts,
    DateTime now,
  ) async {
    final have = {
      for (final r in await _db.select(_db.unlockedAchievements).get()) r.id,
    };
    final fresh = [
      for (final a in achievements)
        if (!have.contains(a.id) && a.isEarned(facts)) a,
    ];
    await _db.batch((b) {
      for (final a in fresh) {
        b.insert(
          _db.unlockedAchievements,
          UnlockedAchievementsCompanion.insert(id: a.id, unlockedAt: now),
        );
      }
    });
    return fresh;
  }
}
