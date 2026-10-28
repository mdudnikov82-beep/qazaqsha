import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/custom_words_repository.dart';
import 'package:qazaqsha/data/repositories/dictionary_repository.dart';
import 'package:qazaqsha/data/repositories/lesson_repository.dart';
import 'package:qazaqsha/data/repositories/progress_repository.dart';
import 'package:qazaqsha/features/custom_words/word_import.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late CustomWordsRepository custom;
  late DictionaryRepository dictionary;

  setUp(() {
    db = testDatabase();
    custom = CustomWordsRepository(db);
    dictionary = DictionaryRepository(db);
  });

  tearDown(() => db.close());

  test('first import creates "Мои слова" and skips known pairs', () async {
    expect(
      (await dictionary.categories()).map((c) => c.category.id),
      isNot(contains(customCategoryId)),
    );

    final result = await custom.addWords(const [
      ImportedWord('кесіртке', 'ящерица'),
      ImportedWord('рахмет', 'спасибо'), // already in the dictionary
      ImportedWord('тиін', 'белка'),
    ]);
    expect((result.added, result.skipped), (2, 1));

    final categories = await dictionary.categories();
    final mine = categories.firstWhere(
      (c) => c.category.id == customCategoryId,
    );
    expect(mine.category.titleRu, 'Мои слова');
    expect(mine.wordCount, 2);
    expect(categories.last.category.id, customCategoryId);

    // A repeat import adds nothing; order continues after existing words.
    final again = await custom.addWords(const [
      ImportedWord('тиін', 'белка'),
      ImportedWord('жираф', 'жираф'),
    ]);
    expect((again.added, again.skipped), (1, 1));
    expect((await custom.words()).map((w) => w.kk), [
      'кесіртке',
      'тиін',
      'жираф',
    ]);
    expect((await dictionary.search('ящер')).single.kk, 'кесіртке');
  });

  test('own words never enter the course ladder', () async {
    await custom.addWords(const [ImportedWord('тиін', 'белка')]);
    final course = await LessonRepository(db, dictionary).watchCourse().first;
    expect(course.topics, hasLength(23));
    expect(
      course.topics.map((t) => t.category.id),
      isNot(contains(customCategoryId)),
    );
  });

  test('deleting an own word removes its progress too', () async {
    await custom.addWords(const [ImportedWord('тиін', 'белка')]);
    final word = (await custom.words()).single;
    final progress = ProgressRepository(db);
    await progress.applySession({word.id: true}, DateTime(2026, 10, 28));

    await custom.delete(word.id);
    expect(await custom.words(), isEmpty);
    expect((await progress.watchAll().first).containsKey(word.id), isFalse);

    // Built-in words can't be deleted through this repository.
    Future<List<Word>> rakhmet() async => [
      for (final w in await dictionary.search('рахмет'))
        if (w.kk == 'рахмет') w,
    ];
    await custom.delete((await rakhmet()).single.id);
    expect(await rakhmet(), hasLength(1));
  });
}
