import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/dictionary_repository.dart';
import 'package:qazaqsha/features/quiz/answer_check.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late DictionaryRepository repo;

  setUp(() {
    db = testDatabase();
    repo = DictionaryRepository(db);
  });

  tearDown(() => db.close());

  test('seeds 500 words in 23 categories', () async {
    expect(await repo.wordCount(), 500);

    final categories = await repo.categories();
    expect(categories, hasLength(23));
    expect(categories.first.category.id, 'greetings');
    expect(categories.every((c) => c.wordCount > 0), isTrue);
  });

  test('keeps word order and notes inside a category', () async {
    final family = await repo.wordsInCategory('family');
    expect(family.first.ru, 'семья');
    expect(family.first.kk, 'отбасы');
    final sister = family.firstWhere((w) => w.kk == 'сіңлі');
    expect(sister.note, contains('қарындас'));
  });

  test('search works in both languages, ignoring case and ё', () async {
    expect((await repo.search('Рахм')).map((w) => w.kk), contains('рахмет'));
    expect((await repo.search('қасқ')).map((w) => w.ru), contains('волк'));
    expect((await repo.search('желтый')).map((w) => w.kk), contains('сары'));
    expect(await repo.search('   '), isEmpty);
  });

  test('seeds 75 sentences, every topic has some', () async {
    final all = await db.select(db.sentences).get();
    expect(all, hasLength(75));
    for (final c in await repo.categories()) {
      final own = await repo.sentencesInCategory(c.category.id);
      expect(own.length, greaterThanOrEqualTo(2), reason: c.category.id);
    }
    // Every sentence can be built from at least two tiles.
    expect(all.where((s) => sentenceTokens(s.kk).length < 2), isEmpty);
  });

  test('creates the single user stats row with defaults', () async {
    final stats = await db.select(db.userStats).getSingle();
    expect(stats.xp, 0);
    expect(stats.streakDays, 0);
    expect(stats.dailyGoalXp, 50);
  });
}
