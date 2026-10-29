import '../database/app_database.dart';

class GrammarRepository {
  GrammarRepository(this._db);

  final AppDatabase _db;

  /// Done rules by id.
  Stream<Map<String, GrammarProgressData>> watch() => _db
      .select(_db.grammarProgress)
      .watch()
      .map((rows) => {for (final r in rows) r.ruleId: r});

  /// Saves a finished rule; keeps the best score.
  Future<void> record(String ruleId, int score, DateTime now) async {
    final old = await (_db.select(
      _db.grammarProgress,
    )..where((g) => g.ruleId.equals(ruleId))).getSingleOrNull();
    if (old != null && old.bestScore >= score) return;
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
}
