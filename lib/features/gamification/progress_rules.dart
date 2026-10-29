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

/// Study time for people: «0 мин», «12 мин», «1 ч 5 мин», «3 ч».
String formatStudyTime(int seconds) {
  final minutes = seconds ~/ 60;
  if (minutes < 60) return '$minutes мин';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h ч' : '$h ч $m мин';
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

/// Title for a level, in Kazakh and Russian.
({String kk, String ru}) rankForLevel(int level) => switch (level) {
  <= 2 => (kk: 'Жаңа бастаушы', ru: 'Новичок'),
  <= 4 => (kk: 'Үйренуші', ru: 'Ученик'),
  <= 7 => (kk: 'Білгір', ru: 'Знаток'),
  <= 10 => (kk: 'Шешен', ru: 'Оратор'),
  _ => (kk: 'Шебер', ru: 'Мастер'),
};

// --- Gentle streaks -------------------------------------------------------
//
// A streak should pull people back, not punish them. Missed days can be
// covered by freezes earned along the way; a single missed day can be won
// back the next day; and nothing else (XP, words, the best streak) is ever
// taken away.

/// A freeze is earned every this many days of a streak…
const freezeEveryDays = 7;

/// …and at most this many are kept.
const maxFreezes = 2;

/// Winning back a streak after one missed day takes this many daily goals.
const repairGoalFactor = 2;

/// What studying at some moment does to the streak.
class StreakStep {
  const StreakStep({
    required this.streak,
    required this.freezes,
    this.frozenDays = const [],
    this.repairable = 0,
  });

  final int streak;

  /// Freezes left afterwards.
  final int freezes;

  /// Missed days a freeze covered (UTC dates, see [dayOf]).
  final List<DateTime> frozenDays;

  /// Length of a streak that just broke after exactly one missed day and
  /// can still be won back today; 0 if none.
  final int repairable;
}

/// Streak after studying at [now], using freezes for missed days.
StreakStep advanceStreak({
  required int current,
  required DateTime? lastActive,
  required DateTime now,
  required int freezes,
}) {
  if (lastActive == null) return StreakStep(streak: 1, freezes: freezes);
  final gap = daysBetween(lastActive, now);
  if (gap <= 0) {
    return StreakStep(streak: current == 0 ? 1 : current, freezes: freezes);
  }
  final missed = gap - 1;
  if (missed == 0) {
    return StreakStep(
      streak: current + 1,
      freezes: _earn(freezes, current, current + 1),
    );
  }
  if (missed <= freezes && current > 0) {
    final first = dayOf(lastActive);
    return StreakStep(
      streak: current + 1,
      freezes: _earn(freezes - missed, current, current + 1),
      frozenDays: [
        for (var d = 1; d <= missed; d++) first.add(Duration(days: d)),
      ],
    );
  }
  return StreakStep(
    streak: 1,
    freezes: freezes,
    repairable: missed == 1 ? current : 0,
  );
}

/// One more freeze each time the streak passes a multiple of 7.
int _earn(int freezes, int before, int after) =>
    after ~/ freezeEveryDays > before ~/ freezeEveryDays
    ? (freezes + 1).clamp(0, maxFreezes)
    : freezes;

/// The streak after a broken one is won back: the missed day counts too.
StreakStep repairStreak({
  required int brokenStreak,
  required int currentStreak,
  required int freezes,
}) {
  final streak = brokenStreak + 1 + currentStreak;
  return StreakStep(
    streak: streak,
    freezes: _earn(freezes, brokenStreak, streak),
  );
}

/// Streak to show between sessions: kept while freezes still cover the
/// days missed so far.
int visibleStreak({
  required int current,
  required DateTime? lastActive,
  required DateTime now,
  int freezes = 0,
}) {
  if (lastActive == null) return 0;
  final missed = daysBetween(lastActive, now) - 1;
  // Today's gap isn't missed yet: there is still time to study.
  return missed <= freezes ? current : 0;
}

/// The streak is gone (more days missed than freezes cover) — say so
/// kindly, not as a failure.
bool streakLapsed({
  required int current,
  required DateTime? lastActive,
  required DateTime now,
  required int freezes,
}) =>
    current > 0 &&
    lastActive != null &&
    daysBetween(lastActive, now) - 1 > freezes;

/// Monday of the week [now] is in (UTC date).
DateTime weekStart(DateTime now) {
  final d = dayOf(now);
  return d.subtract(Duration(days: d.weekday - 1));
}
