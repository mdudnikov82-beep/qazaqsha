/// Pure rules for levels, streaks and daily XP. No I/O, easy to test.
library;

/// Calendar day of [t] as a UTC date, so DST shifts never break day math.
DateTime dayOf(DateTime t) => DateTime.utc(t.year, t.month, t.day);

int daysBetween(DateTime from, DateTime to) =>
    dayOf(to).difference(dayOf(from)).inDays;

/// XP at which [level] starts: 0, 100, 300, 600, 1000… (grows by 100 more each level).
int levelStartXp(int level) => 50 * level * (level - 1);

int levelForXp(int xp) {
  var level = 1;
  while (xp >= levelStartXp(level + 1)) {
    level++;
  }
  return level;
}

class LevelProgress {
  const LevelProgress(this.level, this.xpIntoLevel, this.xpForLevel);

  factory LevelProgress.fromXp(int xp) {
    final level = levelForXp(xp);
    final start = levelStartXp(level);
    return LevelProgress(level, xp - start, levelStartXp(level + 1) - start);
  }

  final int level;
  final int xpIntoLevel;
  final int xpForLevel;

  double get fraction => xpIntoLevel / xpForLevel;
}

/// Streak after the user studies at [now].
int nextStreak({
  required int current,
  required DateTime? lastActive,
  required DateTime now,
}) {
  if (lastActive == null) return 1;
  final gap = daysBetween(lastActive, now);
  if (gap <= 0) return current == 0 ? 1 : current;
  if (gap == 1) return current + 1;
  return 1;
}

/// Streak to display: it is lost once a whole day was skipped.
int visibleStreak({
  required int current,
  required DateTime? lastActive,
  required DateTime now,
}) {
  if (lastActive == null) return 0;
  return daysBetween(lastActive, now) > 1 ? 0 : current;
}

/// Today's XP, given the stored counter and the day it belongs to.
int todayXp({
  required int storedDailyXp,
  required DateTime? storedDay,
  required DateTime now,
}) {
  if (storedDay == null || daysBetween(storedDay, now) != 0) return 0;
  return storedDailyXp;
}
