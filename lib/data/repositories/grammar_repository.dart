import 'package:drift/drift.dart';

import '../database/app_database.dart';

class GrammarRepository {
  GrammarRepository(this._db);

  final AppDatabase _db;

  /// Done rules by id.
  Stream<Map<String, GrammarProgressData>> watch() => _db
      .select(_db.grammarProgress)
      .watch()
      .map((rows) => {for (final r in rows) r.ruleId: r});

  /// Saves a finished rule (or dialogue): the best score, and when it was
  /// last done (for today's tasks on Home).
  Future<void> record(String ruleId, int score, DateTime now) async {
    final old = await (_db.select(
      _db.grammarProgress,
    )..where((g) => g.ruleId.equals(ruleId))).getSingleOrNull();
    if (old != null && old.bestScore > score) score = old.bestScore;
    await _db
        .into(_db.grammarProgress)
        .insertOnConflictUpdate(
          GrammarProgressCompanion.insert(
            ruleId: ruleId,
            bestScore: score,
            completedAt: now,
          ),
        );
  }

  /// Whether a rule (not a dialogue) was practised since [since].
  Stream<bool> watchRuleSince(DateTime since) =>
      (_db.select(_db.grammarProgress)..where(
            (g) =>
                g.completedAt.isBiggerOrEqualValue(since) &
                g.ruleId.like('dlg:%').not(),
          ))
          .watch()
          .map((rows) => rows.isNotEmpty);
}
