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
  Future<void> addStudyTime(int seconds, {DateTime? now}) async {
    if (seconds <= 0) return;
    final s = await get();
    await (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(
      UserStatsCompanion(studySeconds: Value(s.studySeconds + seconds)),
    );
    await _addActivity(now ?? DateTime.now(), seconds: seconds);
  }

  Future<void> _addActivity(
    DateTime now, {
    int xp = 0,
    int seconds = 0,
    int sessions = 0,
  }) => _db.customInsert(
    'INSERT INTO daily_activity (day, xp, seconds, sessions) '
    'VALUES (?, ?, ?, ?) ON CONFLICT(day) DO UPDATE SET '
    'xp = xp + excluded.xp, seconds = seconds + excluded.seconds, '
    'sessions = sessions + excluded.sessions',
    variables: [
      Variable.withDateTime(dayOf(now)),
      Variable.withInt(xp),
      Variable.withInt(seconds),
      Variable.withInt(sessions),
    ],
    // Lets the activity calendar stream see the change.
    updates: {_db.dailyActivity},
  );

  /// Days with activity from [since] on, oldest first.
  Stream<List<DailyActivityData>> watchActivity(DateTime since) =>
      (_db.select(_db.dailyActivity)
            ..where((d) => d.day.isBiggerOrEqualValue(dayOf(since)))
            ..orderBy([(d) => OrderingTerm.asc(d.day)]))
          .watch();

  /// Adds the session's XP, answers and time, and moves the streak forward.
  Future<UserStat> recordSession({
    required int xp,
    required int correct,
    required int total,
    required DateTime now,
    int studySeconds = 0,
  }) async {
    final s = await get();
    final streak = nextStreak(
      current: s.streakDays,
      lastActive: s.lastActiveDate,
      now: now,
    );
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
        streakDays: Value(streak),
        bestStreak: Value(streak > s.bestStreak ? streak : s.bestStreak),
        lastActiveDate: Value(now),
        quizzesCompleted: Value(s.quizzesCompleted + 1),
        answersCorrect: Value(s.answersCorrect + correct),
        answersTotal: Value(s.answersTotal + total),
        studySeconds: Value(s.studySeconds + studySeconds),
      ),
    );
    await _addActivity(now, xp: xp, seconds: studySeconds, sessions: 1);
    return get();
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(
        UserStatsCompanion(themeMode: Value(mode)),
      );

  Future<void> completeOnboarding({required int dailyGoalXp}) =>
      (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(
        UserStatsCompanion(
          onboardingDone: const Value(true),
          dailyGoalXp: Value(dailyGoalXp),
        ),
      );

  Future<void> setDailyGoal(int xp) =>
      _write(UserStatsCompanion(dailyGoalXp: Value(xp)));

  /// Blank or whitespace clears the name.
  Future<void> setUserName(String name) {
    final trimmed = name.trim();
    return _write(
      UserStatsCompanion(userName: Value(trimmed.isEmpty ? null : trimmed)),
    );
  }

  Future<void> setHaptics(bool on) =>
      _write(UserStatsCompanion(hapticsEnabled: Value(on)));

  Future<void> setReminder({required bool enabled, int? minutes}) => _write(
    UserStatsCompanion(
      reminderEnabled: Value(enabled),
      reminderMinutes: minutes == null ? const Value.absent() : Value(minutes),
    ),
  );

  Future<void> _write(UserStatsCompanion row) =>
      (_db.update(_db.userStats)..where((r) => r.id.equals(1))).write(row);

  /// Unlocked achievement ids with the time each was unlocked.
  Stream<Map<String, DateTime>> watchUnlocked() => _db
      .select(_db.unlockedAchievements)
      .watch()
      .map((rows) => {for (final r in rows) r.id: r.unlockedAt});

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
