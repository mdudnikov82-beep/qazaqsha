import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/dictionary_repository.dart';
import 'package:qazaqsha/data/repositories/lesson_repository.dart';
import 'package:qazaqsha/features/lessons/sections.dart';
import 'package:qazaqsha/features/placement/placement_screen.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  test('two tasks per section, options from that section', () async {
    final words = await DictionaryRepository(db).allWords();
    final tasks = buildPlacement(words, Random(3));
    expect(tasks, hasLength(courseSections.length * placementPerSection));
    for (final t in tasks) {
      final s = courseSections[t.section];
      expect(s.categoryIds, contains(t.word.categoryId));
      expect(t.options, contains(t.word.kk));
      expect(t.options.toSet(), hasLength(t.options.length));
      expect(t.options.length, greaterThanOrEqualTo(3));
    }
    // Sections come in course order.
    expect(
      [for (final t in tasks) t.section],
      [
        ...[for (final t in tasks) t.section],
      ]..sort(),
    );
  });

  test('start is the first section not answered fully right', () {
    expect(placementStart({}), 0);
    expect(placementStart({0: 2, 1: 2, 2: 1}), 2);
    expect(placementStart({0: 2, 1: 0}), 1);
    final all = {for (var i = 0; i < courseSections.length; i++) i: 2};
    expect(placementStart(all), courseSections.length);
  });

  test('placing marks earlier sections done and opens the next', () async {
    final lessons = LessonRepository(db, DictionaryRepository(db));
    await lessons.placeBefore(
      courseSections.take(2).toList(),
      DateTime(2026, 10, 29),
    );
    final course = await lessons.watchCourse().first;
    expect(course.sections[0].examPassed, isTrue);
    expect(course.sections[1].examPassed, isTrue);
    expect(course.sections[2].examPassed, isFalse);
    final next = course.next as NextLesson;
    expect(next.topic.category.id, courseSections[2].categoryIds.first);
    expect(next.topic.nextLesson, 0);
    // Words aren't marked learned: placing never fakes knowledge.
    expect(await db.select(db.wordProgress).get(), isEmpty);
  });
}
