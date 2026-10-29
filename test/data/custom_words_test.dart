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
    expect(course.topics, hasLength(64));
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

  test('sets: create, add, rename, edit words, delete', () async {
    final work = await custom.createSet('  Работа  ');
    expect(isOwnSet(work), isTrue);
    expect(isOwnSet('custom'), isTrue);
    expect(isOwnSet('family'), isFalse);
    await custom.addWords(const [ImportedWord('тиін', 'белка')]);
    final r = await custom.addWords(const [
      ImportedWord('кеңсе қызметкері', 'офисный работник'),
      ImportedWord('жоспар', 'план'), // in the dictionary
    ], setId: work);
    expect((r.added, r.skipped), (1, 1));

    final sets = await custom.sets();
    expect(sets.map((s) => s.titleRu), ['Мои слова', 'Работа']);
    expect((await custom.words(work)).single.kk, 'кеңсе қызметкері');
    expect(await custom.words(), hasLength(2)); // all own words

    await custom.renameSet(work, 'Офис');
    expect((await custom.sets()).last.titleRu, 'Офис');

    final word = (await custom.words(work)).single;
    await custom.updateWord(
      word.id,
      kk: 'әріптесім',
      ru: 'мой коллега',
      note: 'о человеке',
    );
    final edited = (await custom.words(work)).single;
    expect(
      (edited.kk, edited.ru, edited.note),
      ('әріптесім', 'мой коллега', 'о человеке'),
    );
    expect(edited.searchText, 'мой коллега әріптесім');
    // A pair the dictionary already has is refused.
    await expectLater(
      custom.updateWord(word.id, kk: 'жоспар', ru: 'план'),
      throwsA(isA<DuplicateWord>()),
    );

    await custom.deleteSet(work);
    expect((await custom.sets()).map((s) => s.id), ['custom']);
    expect(await custom.words(), hasLength(1));
    // The default set is only emptied, never removed.
    await custom.deleteSet('custom');
    expect((await custom.sets()).map((s) => s.id), ['custom']);
    expect(await custom.words(), isEmpty);
  });

  test('a set id with LIKE wildcards never matches course topics', () async {
    // «my_» must not act as «my» + any character.
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'myX1',
            titleRu: 't',
            titleKk: 't',
            icon: 'x',
            sortOrder: 0,
          ),
        );
    expect((await custom.sets()).map((s) => s.id), isNot(contains('myX1')));
  });
}
