import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/core/alphabet.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/progress_repository.dart';
import 'package:qazaqsha/features/dictionary/word_sheet.dart';
import 'package:qazaqsha/features/review/review_mode.dart';

import '../helpers.dart';

void main() {
  group('review modes', () {
    late AppDatabase db;
    late ProgressRepository progress;
    final now = DateTime(2026, 10, 28, 12);

    setUp(() {
      db = testDatabase();
      progress = ProgressRepository(db);
    });

    tearDown(() => db.close());

    List<int> ids(List<Word> words) => [for (final w in words) w.id];

    test('hard words come most-mistaken first', () async {
      await progress.applySession({1: true, 2: false, 3: false}, now);
      await progress.applySession({3: false, 4: true}, now);
      expect(ids(await progress.reviewWords(ReviewMode.hard, now)), [3, 2]);
    });

    test('favourites and random take studied words only', () async {
      await progress.applySession({1: true, 2: true, 3: false}, now);
      await progress.toggleFavorite(2);
      await progress.toggleFavorite(50); // never studied, still a favourite
      expect(
        ids(await progress.reviewWords(ReviewMode.favorites, now)).toSet(),
        {2, 50},
      );
      final random = await progress.reviewWords(
        ReviewMode.random,
        now,
        random: Random(1),
      );
      expect(ids(random).toSet(), {1, 2, 3});
    });

    test('due mode is the spaced-repetition queue', () async {
      await progress.applySession({1: true, 2: false}, now);
      expect(ids(await progress.reviewWords(ReviewMode.due, now)), [2]);
      expect(ReviewMode.parse('hard'), ReviewMode.hard);
      expect(ReviewMode.parse(null), ReviewMode.due);
      expect(ReviewMode.parse('nonsense'), ReviewMode.due);
    });
  });

  test('Kazakh alphabet order: ә after а, қ after к, і near the end', () {
    final words = ['қала', 'іні', 'әке', 'ана', 'кітап', 'ұл', 'үй', 'бала'];
    words.sort((a, b) => compareIn(kazakhAlphabet, a, b));
    expect(words, ['ана', 'әке', 'бала', 'кітап', 'қала', 'ұл', 'үй', 'іні']);
    expect(firstLetter(kazakhAlphabet, 'Әже'), 'Ә');
    expect(firstLetter(russianAlphabet, '«ёлка»'), 'Ё');
  });

  test('example sentence finds the word with endings, own topic first', () {
    Word word(String kk, String cat) => Word(
      id: 1,
      categoryId: cat,
      ru: '',
      kk: kk,
      sortOrder: 0,
      searchText: '',
    );
    Sentence sentence(String kk, String cat) =>
        Sentence(id: kk.length, categoryId: cat, ru: 'ru', kk: kk);
    final sentences = [
      sentence('Біз қалаға барамыз.', 'travel'),
      sentence('Бұл қала үлкен.', 'city'),
      sentence('Ол ұл бала.', 'family'),
    ];
    expect(exampleFor(word('қала', 'city'), sentences)!.kk, 'Бұл қала үлкен.');
    expect(
      exampleFor(word('қала', 'travel'), sentences)!.kk,
      'Біз қалаға барамыз.',
    );
    // Short words must match whole: «ол» is not in «болды».
    expect(exampleFor(word('ұл', 'x'), sentences)!.kk, 'Ол ұл бала.');
    expect(exampleFor(word('су', 'x'), sentences), isNull);
  });
}
