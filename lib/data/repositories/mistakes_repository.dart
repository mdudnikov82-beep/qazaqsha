import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// The «работа над ошибками» notebook: every task answered wrong, until
/// it is answered right again.
class MistakesRepository {
  MistakesRepository(this._db);

  final AppDatabase _db;

  Future<void> record({
    required MistakeKind kind,
    required String ref,
    required String prompt,
    required String answer,
    String given = '',
    DateTime? now,
  }) => _db.customInsert(
    'INSERT INTO mistakes (kind, ref, prompt, answer, given, times, last_at, resolved) '
    'VALUES (?, ?, ?, ?, ?, 1, ?, 0) '
    'ON CONFLICT(kind, ref) DO UPDATE SET times = times + 1, '
    'given = excluded.given, last_at = excluded.last_at, resolved = 0, '
    'prompt = excluded.prompt, answer = excluded.answer',
    variables: [
      Variable.withInt(kind.index),
      Variable.withString(ref),
      Variable.withString(prompt),
      Variable.withString(answer),
      Variable.withString(given),
      Variable.withDateTime(now ?? DateTime.now()),
    ],
    updates: {_db.mistakes},
  );

  /// A task was answered right: it leaves the notebook.
  Future<void> resolve(MistakeKind kind, String ref) =>
      (_db.update(_db.mistakes)
            ..where((m) => m.kind.equalsValue(kind) & m.ref.equals(ref)))
          .write(const MistakesCompanion(resolved: Value(true)));

  /// Open mistakes, newest first.
  Stream<List<Mistake>> watchOpen() =>
      (_db.select(_db.mistakes)
            ..where((m) => m.resolved.equals(false))
            ..orderBy([(m) => OrderingTerm.desc(m.lastAt)]))
          .watch();

  /// Refs of open mistakes of one kind, newest first.
  Future<List<String>> openRefs(MistakeKind kind) async => [
    for (final m
        in await (_db.select(_db.mistakes)
              ..where(
                (m) => m.kind.equalsValue(kind) & m.resolved.equals(false),
              )
              ..orderBy([(m) => OrderingTerm.desc(m.lastAt)]))
            .get())
      m.ref,
  ];

  /// Forgets mistakes that were fixed.
  Future<int> clearResolved() =>
      (_db.delete(_db.mistakes)..where((m) => m.resolved.equals(true))).go();
}
