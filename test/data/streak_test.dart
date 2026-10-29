import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/stats_repository.dart';
import 'package:qazaqsha/features/gamification/progress_rules.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late StatsRepository stats;

  setUp(() {
    db = testDatabase();
    stats = StatsRepository(db);
  });

  tearDown(() => db.close());

  Future<UserStat> study(DateTime at, {int xp = 30}) =>
      stats.recordSession(xp: xp, correct: 5, total: 5, now: at);

  DateTime day(int d, [int h = 10]) => DateTime(2026, 11, d, h);

  test('seven days earn a freeze; it covers a missed day later', () async {
    for (var d = 1; d <= 7; d++) {
      await study(day(d));
    }
    var s = await stats.get();
    expect((s.streakDays, s.streakFreezes), (7, 1));

    // Skip the 8th, study on the 9th: the streak goes on.
    s = await study(day(9));
    expect((s.streakDays, s.streakFreezes, s.bestStreak), (8, 0, 8));
    final frozen = await (db.select(
      db.dailyActivity,
    )..where((d) => d.frozen.equals(true))).get();
    expect(frozen.map((d) => dayOf(d.day.toUtc())), [
      DateTime.utc(2026, 11, 8),
    ]);
  });

  test('one missed day can be won back with a double goal', () async {
    await stats.setDailyGoal(50);
    for (var d = 1; d <= 3; d++) {
      await study(day(d));
    }
    // Skip the 4th. On the 5th the streak breaks, but stays winnable.
    var s = await study(day(5), xp: 40);
    expect((s.streakDays, s.repairStreak), (1, 3));
    expect(dayOf(s.repairDay!), DateTime.utc(2026, 11, 5));

    // 40 + 60 = 100 XP = twice the goal: back to 3 + the missed day + today.
    s = await study(day(5, 18), xp: 60);
    expect((s.streakDays, s.repairStreak, s.repairDay), (5, 0, null));
    final restored = await (db.select(
      db.dailyActivity,
    )..where((d) => d.frozen.equals(true))).get();
    expect(restored.map((d) => dayOf(d.day.toUtc())), [
      DateTime.utc(2026, 11, 4),
    ]);
  });

  test('the chance to win back ends with the day', () async {
    for (var d = 1; d <= 3; d++) {
      await study(day(d));
    }
    await study(day(5), xp: 10);
    final s = await study(day(6), xp: 500);
    expect((s.streakDays, s.repairStreak), (2, 0));
  });
}
