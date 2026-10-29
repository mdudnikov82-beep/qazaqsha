import 'package:drift/drift.dart';

import '../../features/custom_words/word_import.dart';
import '../database/app_database.dart';
import '../database/seed.dart';

/// The default set of the user's own words. Created on first import.
const customCategoryId = 'custom';

/// Ids of further sets the user creates: `my_<millis>`.
const _setPrefix = 'my_';

/// LIKE pattern for set ids; `_` is a wildcard there, so it is escaped.
const _setPattern = r'my\_%';

/// Own sets sort after every course topic.
const _setsSortOrder = 1000;

/// A category made by the user rather than shipped with the course.
bool isOwnSet(String categoryId) =>
    categoryId == customCategoryId || categoryId.startsWith(_setPrefix);

class ImportResult {
  const ImportResult(this.added, this.skipped);

  final int added;

  /// Already in the dictionary (the built-in one or the user's).
  final int skipped;
}

/// Edit result when the new pair is already in the dictionary.
class DuplicateWord implements Exception {
  const DuplicateWord();
}

class CustomWordsRepository {
  CustomWordsRepository(this._db);

  final AppDatabase _db;

  /// All own sets, the default one first, then by creation.
  Future<List<Category>> sets() =>
      (_db.select(_db.categories)
            ..where(
              (c) =>
                  c.id.equals(customCategoryId) |
                  c.id.like(_setPattern, escapeChar: r'\'),
            )
            ..orderBy([
              (c) => OrderingTerm.asc(c.sortOrder),
              (c) => OrderingTerm.asc(c.id),
            ]))
          .get();

  Future<void> _ensureDefaultSet() => _db
      .into(_db.categories)
      .insert(
        CategoriesCompanion.insert(
          id: customCategoryId,
          titleRu: 'Мои слова',
          titleKk: 'Менің сөздерім',
          icon: 'bookmark',
          sortOrder: _setsSortOrder,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  /// Creates an empty set and returns its id.
  Future<String> createSet(String title, {DateTime? now}) async {
    final name = _setName(title);
    var millis = (now ?? DateTime.now()).millisecondsSinceEpoch;
    // Two sets made in the same millisecond (tests, quick taps).
    while (await _setExists('$_setPrefix$millis')) {
      millis++;
    }
    final id = '$_setPrefix$millis';
    await _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: id,
            titleRu: name,
            titleKk: name,
            icon: 'folder',
            sortOrder: _setsSortOrder + 1,
          ),
        );
    return id;
  }

  Future<bool> _setExists(String id) async =>
      await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(id))).getSingleOrNull() !=
      null;

  static String _setName(String title) {
    final t = title.trim();
    final name = t.isEmpty ? 'Новый набор' : t;
    return name.length > maxSetTitle ? name.substring(0, maxSetTitle) : name;
  }

  Future<void> renameSet(String id, String title) {
    final name = _setName(title);
    return (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        titleRu: Value(name),
        // The default set keeps its Kazakh title.
        titleKk: id == customCategoryId ? const Value.absent() : Value(name),
      ),
    );
  }

  /// Removes a set with its words and their progress. The default set is
  /// only emptied.
  Future<void> deleteSet(String id) => _db.transaction(() async {
    assert(isOwnSet(id));
    final ids = _db.selectOnly(_db.words)
      ..addColumns([_db.words.id])
      ..where(_db.words.categoryId.equals(id));
    await (_db.delete(
      _db.wordProgress,
    )..where((p) => p.wordId.isInQuery(ids))).go();
    await (_db.delete(_db.words)..where((w) => w.categoryId.equals(id))).go();
    if (id != customCategoryId) {
      await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
    }
  });

  /// Adds [words] to the set [setId]; pairs already in the dictionary (in
  /// any topic or set) are skipped.
  Future<ImportResult> addWords(
    List<ImportedWord> words, {
    String setId = customCategoryId,
  }) {
    assert(isOwnSet(setId));
    return _db.transaction(() async {
      if (setId == customCategoryId) await _ensureDefaultSet();

      final existing = {
        for (final w in await (_db.select(
          _db.words,
        )..where((w) => w.kk.isIn(words.map((w) => w.kk)))).get())
          ImportedWord(w.kk, w.ru),
      };
      final maxOrder = _db.words.sortOrder.max();
      var order =
          (await (_db.selectOnly(_db.words)
                    ..addColumns([maxOrder])
                    ..where(_db.words.categoryId.equals(setId)))
                  .map((r) => r.read(maxOrder))
                  .getSingle() ??
              -1) +
          1;

      var added = 0;
      for (final w in words) {
        if (existing.contains(w)) continue;
        await _db
            .into(_db.words)
            .insert(
              WordsCompanion.insert(
                categoryId: setId,
                ru: w.ru,
                kk: w.kk,
                sortOrder: order++,
                searchText: normalizeForSearch('${w.ru} ${w.kk}'),
              ),
            );
        existing.add(w);
        added++;
      }
      return ImportResult(added, words.length - added);
    });
  }

  /// Words of one set (all own words when [setId] is null), in the order
  /// they were added.
  Future<List<Word>> words([String? setId]) async {
    final query = _db.select(_db.words)
      ..orderBy([
        (w) => OrderingTerm.asc(w.categoryId),
        (w) => OrderingTerm.asc(w.sortOrder),
      ]);
    if (setId != null) {
      query.where((w) => w.categoryId.equals(setId));
    } else {
      query.where(
        (w) =>
            w.categoryId.equals(customCategoryId) |
            w.categoryId.like(_setPattern, escapeChar: r'\'),
      );
    }
    return query.get();
  }

  /// Changes an own word. Throws [DuplicateWord] if the new pair already
  /// exists. Progress stays with the word.
  Future<void> updateWord(
    int wordId, {
    required String kk,
    required String ru,
    String? note,
    String? setId,
  }) async {
    final k = kk.trim();
    final r = ru.trim();
    final n = note?.trim();
    final clash =
        await (_db.select(_db.words)..where(
              (w) =>
                  w.kk.equals(k) & w.ru.equals(r) & w.id.equals(wordId).not(),
            ))
            .getSingleOrNull();
    if (clash != null) throw const DuplicateWord();
    await (_db.update(
      _db.words,
    )..where((w) => w.id.equals(wordId) & _ownWord(w))).write(
      WordsCompanion(
        kk: Value(k),
        ru: Value(r),
        note: Value(n == null || n.isEmpty ? null : n),
        searchText: Value(normalizeForSearch('$r $k')),
        categoryId: setId == null ? const Value.absent() : Value(setId),
      ),
    );
  }

  static Expression<bool> _ownWord($WordsTable w) =>
      w.categoryId.equals(customCategoryId) |
      w.categoryId.like(_setPattern, escapeChar: r'\');

  /// Removes one of the user's words together with its progress.
  Future<void> delete(int wordId) => _db.transaction(() async {
    await (_db.delete(
      _db.wordProgress,
    )..where((p) => p.wordId.equals(wordId))).go();
    await (_db.delete(
      _db.words,
    )..where((w) => w.id.equals(wordId) & _ownWord(w))).go();
  });
}
