import 'package:drift/drift.dart';

import '../../features/gamification/quests.dart';
import '../database/app_database.dart';

/// Weekly counters behind the weekly quests.
class QuestRepository {
  QuestRepository(this._db);

  final AppDatabase _db;

  /// Adds [by] to this week's [key] counter.
  Future<void> add(QuestKey key, DateTime now, [int by = 1]) async {
    if (by <= 0 || key == QuestKey.days) return;
    await _db.customInsert(
      'INSERT INTO weekly_counts (week, key, value) VALUES (?, ?, ?) '
      'ON CONFLICT(week, key) DO UPDATE SET value = value + excluded.value',
      variables: [
        Variable.withDateTime(weekOf(now)),
        Variable.withString(key.name),
        Variable.withInt(by),
      ],
      updates: {_db.weeklyCounts},
    );
  }

  /// This week's counters, days with study included.
  Stream<Map<QuestKey, int>> watchWeek(DateTime now) {
    final week = weekOf(now);
    return _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([_db.weeklyCounts, _db.dailyActivity]),
        )
        .asyncMap((_) => _counts(week))
        .startWith(_counts(week));
  }

  Future<Map<QuestKey, int>> _counts(DateTime week) async {
    final rows = await (_db.select(
      _db.weeklyCounts,
    )..where((r) => r.week.equals(week))).get();
    final days =
        await (_db.select(_db.dailyActivity)..where(
              (d) =>
                  d.day.isBiggerOrEqualValue(week) &
                  d.day.isSmallerThanValue(week.add(const Duration(days: 7))) &
                  d.sessions.isBiggerThanValue(0),
            ))
            .get();
    final keys = QuestKey.values.asNameMap();
    return {
      for (final r in rows)
        if (keys.containsKey(r.key)) keys[r.key]!: r.value,
      QuestKey.days: days.length,
    };
  }

  /// Quests completed over all weeks, for achievements.
  Future<int> completedTotal() async {
    final weeks = <DateTime>{
      for (final r in await _db.select(_db.weeklyCounts).get()) r.week,
    };
    var total = 0;
    for (final w in weeks) {
      total += questsDone(w, await _counts(w));
    }
    return total;
  }
}

extension<T> on Stream<T> {
  /// Emits [first] before the stream's own events.
  Stream<T> startWith(Future<T> first) async* {
    yield await first;
    yield* this;
  }
}
