import 'package:drift/drift.dart';

import '../../features/custom_words/word_import.dart';
import '../database/app_database.dart';
import '../database/seed.dart';

/// Category that holds the user's own words. Created on first import.
const customCategoryId = 'custom';

class ImportResult {
  const ImportResult(this.added, this.skipped);

  final int added;

  /// Already in the dictionary (the built-in one or the user's).
  final int skipped;
}

class CustomWordsRepository {
  CustomWordsRepository(this._db);

  final AppDatabase _db;

  Future<ImportResult> addWords(List<ImportedWord> words) {
    return _db.transaction(() async {
      await _db
          .into(_db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: customCategoryId,
              titleRu: 'Мои слова',
              titleKk: 'Менің сөздерім',
              icon: 'bookmark',
              // After every course topic.
              sortOrder: 1000,
            ),
            mode: InsertMode.insertOrIgnore,
          );

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
                    ..where(_db.words.categoryId.equals(customCategoryId)))
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
                categoryId: customCategoryId,
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

  Future<List<Word>> words() =>
      (_db.select(_db.words)
            ..where((w) => w.categoryId.equals(customCategoryId))
            ..orderBy([(w) => OrderingTerm.asc(w.sortOrder)]))
          .get();

  /// Removes one of the user's words together with its progress.
  Future<void> delete(int wordId) => _db.transaction(() async {
    await (_db.delete(
      _db.wordProgress,
    )..where((p) => p.wordId.equals(wordId))).go();
    await (_db.delete(_db.words)..where(
          (w) => w.id.equals(wordId) & w.categoryId.equals(customCategoryId),
        ))
        .go();
  });
}
