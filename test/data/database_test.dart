import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/dictionary_repository.dart';
import 'package:qazaqsha/features/lessons/sections.dart';
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

  test('seeds 1505 words in 46 categories', () async {
    expect(await repo.wordCount(), 1505);

    final categories = await repo.categories();
    expect(categories, hasLength(46));
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

  test('seeds 144 sentences, every topic has some', () async {
    final all = await db.select(db.sentences).get();
    expect(all, hasLength(144));
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

  test('every course topic exists and is in exactly one section', () async {
    final ids = [for (final c in await repo.categories()) c.category.id];
    final inSections = [for (final s in courseSections) ...s.categoryIds];
    expect(inSections.toSet(), hasLength(inSections.length));
    expect(inSections.toSet(), ids.toSet());
  });

  test(
    'dictionary update adds new words and keeps old ids and progress',
    () async {
      // A database created from the 500-word dictionary.
      var dictionary = File('test/data/dictionary_v1.json').readAsStringSync();
      var sentences = File('test/data/sentences_v1.json').readAsStringSync();
      final old = AppDatabase(
        executor: NativeDatabase.memory(),
        loadSeed: () async => dictionary,
        loadSentences: () async => sentences,
      );
      addTearDown(old.close);
      final oldRepo = DictionaryRepository(old);
      expect(await oldRepo.wordCount(), 500);
      final wolf = (await oldRepo.search('волк')).single;
      await old
          .into(old.wordProgress)
          .insert(
            WordProgressCompanion.insert(
              wordId: Value(wolf.id),
              correctCount: const Value(3),
            ),
          );

      dictionary = File('assets/data/dictionary.json').readAsStringSync();
      sentences = File('assets/data/sentences.json').readAsStringSync();
      await old.addNewSeed();
      await old.addNewSeed(); // running twice adds nothing more

      expect(await oldRepo.wordCount(), 1505);
      expect(await old.select(old.sentences).get(), hasLength(144));
      expect((await oldRepo.search('волк')).single.id, wolf.id);
      final progress = await old.select(old.wordProgress).getSingle();
      expect((progress.wordId, progress.correctCount), (wolf.id, 3));
      // New topics come after the old ones, words in the file's order.
      final topics = [
        for (final c in await oldRepo.categories()) c.category.id,
      ];
      expect(topics.indexOf('phrases'), greaterThan(topics.indexOf('culture')));
      final shopping = await oldRepo.wordsInCategory('shopping');
      expect(shopping.first.ru, 'цена');
    },
  );
}
