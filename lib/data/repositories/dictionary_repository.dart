import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/seed.dart';

class CategoryWithCount {
  const CategoryWithCount(this.category, this.wordCount);

  final Category category;
  final int wordCount;
}

class DictionaryRepository {
  DictionaryRepository(this._db);

  final AppDatabase _db;

  Future<List<CategoryWithCount>> categories() async {
    final count = _db.words.id.count();
    final query =
        _db.select(_db.categories).join([
            leftOuterJoin(
              _db.words,
              _db.words.categoryId.equalsExp(_db.categories.id),
            ),
          ])
          ..addColumns([count])
          ..groupBy([_db.categories.id])
          ..orderBy([OrderingTerm.asc(_db.categories.sortOrder)]);
    final rows = await query.get();
    return [
      for (final r in rows)
        CategoryWithCount(r.readTable(_db.categories), r.read(count) ?? 0),
    ];
  }

  Future<List<Word>> allWords() =>
      (_db.select(_db.words)..orderBy([(w) => OrderingTerm.asc(w.id)])).get();

  Future<List<Word>> wordsInCategory(String categoryId) =>
      (_db.select(_db.words)
            ..where((w) => w.categoryId.equals(categoryId))
            ..orderBy([(w) => OrderingTerm.asc(w.sortOrder)]))
          .get();

  Future<List<Sentence>> sentencesInCategory(String categoryId) => (_db.select(
    _db.sentences,
  )..where((s) => s.categoryId.equals(categoryId))).get();

  Future<List<Word>> wordsInCategories(List<String> categoryIds) => (_db.select(
    _db.words,
  )..where((w) => w.categoryId.isIn(categoryIds))).get();

  Future<List<Sentence>> sentencesInCategories(List<String> categoryIds) =>
      (_db.select(
        _db.sentences,
      )..where((s) => s.categoryId.isIn(categoryIds))).get();

  /// Finds words whose Russian or Kazakh text contains [query].
  Future<List<Word>> search(String query, {int limit = 50}) {
    final q = normalizeForSearch(query);
    if (q.isEmpty) return Future.value(const []);
    return (_db.select(_db.words)
          ..where((w) => w.searchText.contains(q))
          ..limit(limit))
        .get();
  }

  Future<int> wordCount() async {
    final count = _db.words.id.count();
    final row = await (_db.selectOnly(
      _db.words,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }
}
