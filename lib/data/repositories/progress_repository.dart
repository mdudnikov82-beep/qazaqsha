import 'package:drift/drift.dart';

import '../../features/quiz/srs.dart';
import '../database/app_database.dart';

class ProgressRepository {
  ProgressRepository(this._db);

  final AppDatabase _db;

  /// Applies a finished session: [results] maps wordId → answered correctly
  /// every time. Updates counters and schedules the next review.
  Future<void> applySession(Map<int, bool> results, DateTime now) {
    return _db.transaction(() async {
      final existing = {
        for (final p in await (_db.select(
          _db.wordProgress,
        )..where((p) => p.wordId.isIn(results.keys))).get())
          p.wordId: p,
      };
      for (final MapEntry(key: wordId, value: correct) in results.entries) {
        final old = existing[wordId];
        final step = scheduleReview(
          box: old?.box ?? 0,
          correct: correct,
          now: now,
        );
        await _db
            .into(_db.wordProgress)
            .insertOnConflictUpdate(
              WordProgressCompanion.insert(
                wordId: Value(wordId),
                status: Value(step.status),
                box: Value(step.box),
                nextReviewAt: Value(step.nextReviewAt),
                lastSeenAt: Value(now),
                correctCount: Value(
                  (old?.correctCount ?? 0) + (correct ? 1 : 0),
                ),
                wrongCount: Value((old?.wrongCount ?? 0) + (correct ? 0 : 1)),
                isFavorite: Value(old?.isFavorite ?? false),
              ),
            );
      }
    });
  }

  Future<void> toggleFavorite(int wordId) async {
    final old = await (_db.select(
      _db.wordProgress,
    )..where((p) => p.wordId.equals(wordId))).getSingleOrNull();
    if (old == null) {
      await _db
          .into(_db.wordProgress)
          .insert(
            WordProgressCompanion.insert(
              wordId: Value(wordId),
              isFavorite: const Value(true),
            ),
          );
    } else {
      await (_db.update(_db.wordProgress)
            ..where((p) => p.wordId.equals(wordId)))
          .write(WordProgressCompanion(isFavorite: Value(!old.isFavorite)));
    }
  }

  /// wordId → progress, for every word the user has touched.
  Stream<Map<int, WordProgressData>> watchAll() => _db
      .select(_db.wordProgress)
      .watch()
      .map((rows) => {for (final p in rows) p.wordId: p});

  /// Studied words whose review time has come, most overdue first.
  Future<List<Word>> dueWords(DateTime now, {int limit = 10}) {
    final query =
        _db.select(_db.words).join([
            innerJoin(
              _db.wordProgress,
              _db.wordProgress.wordId.equalsExp(_db.words.id),
            ),
          ])
          ..where(
            _db.wordProgress.status.isNotValue(LearningStatus.fresh.index) &
                _db.wordProgress.nextReviewAt.isSmallerOrEqualValue(now),
          )
          ..orderBy([OrderingTerm.asc(_db.wordProgress.nextReviewAt)])
          ..limit(limit);
    return query.map((r) => r.readTable(_db.words)).get();
  }

  Future<int> learnedCount() async {
    final count = _db.wordProgress.wordId.count();
    final row =
        await (_db.selectOnly(_db.wordProgress)
              ..addColumns([count])
              ..where(
                _db.wordProgress.status.equalsValue(LearningStatus.learned),
              ))
            .getSingle();
    return row.read(count) ?? 0;
  }
}
