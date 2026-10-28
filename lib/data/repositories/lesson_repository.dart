import 'dart:math';

import 'package:drift/drift.dart';

import '../../features/quiz/quiz_engine.dart';
import '../database/app_database.dart';
import 'dictionary_repository.dart';

class TopicState {
  const TopicState({
    required this.category,
    required this.lessonCount,
    required this.lessonsDone,
    required this.unlocked,
  });

  final Category category;
  final int lessonCount;
  final int lessonsDone;
  final bool unlocked;

  bool get completed => lessonsDone >= lessonCount;

  /// The lesson to start next, or the last one when everything is done.
  int get nextLesson => min(lessonsDone, lessonCount - 1);
}

class LessonRepository {
  LessonRepository(this._db, this._dictionary);

  final AppDatabase _db;
  final DictionaryRepository _dictionary;

  /// Topics in course order. A topic opens when the previous one is done;
  /// inside a topic lessons open one after another.
  Stream<List<TopicState>> watchTopics() async* {
    final categories = await _dictionary.categories();
    yield* _db.select(_db.lessonProgress).watch().map((rows) {
      final done = <String, Set<int>>{};
      for (final r in rows) {
        done.putIfAbsent(r.categoryId, () => {}).add(r.lessonIndex);
      }
      var previousDone = true;
      return [
        for (final c in categories)
          () {
            final count = lessonCountFor(c.wordCount);
            final finished = done[c.category.id] ?? const <int>{};
            // Count the unbroken run 0, 1, 2… so a gap never skips lessons.
            var inOrder = 0;
            while (finished.contains(inOrder)) {
              inOrder++;
            }
            final state = TopicState(
              category: c.category,
              lessonCount: count,
              lessonsDone: min(inOrder, count),
              unlocked: previousDone,
            );
            previousDone = state.completed;
            return state;
          }(),
      ];
    });
  }

  Future<List<Word>> lessonWords(String categoryId, int lessonIndex) async {
    final lessons = splitIntoLessons(
      await _dictionary.wordsInCategory(categoryId),
    );
    return lessons[lessonIndex];
  }

  /// Saves a finished lesson, keeping the best score.
  Future<void> completeLesson({
    required String categoryId,
    required int lessonIndex,
    required int score,
    required DateTime now,
  }) async {
    final old =
        await (_db.select(_db.lessonProgress)..where(
              (l) =>
                  l.categoryId.equals(categoryId) &
                  l.lessonIndex.equals(lessonIndex),
            ))
            .getSingleOrNull();
    await _db
        .into(_db.lessonProgress)
        .insertOnConflictUpdate(
          LessonProgressCompanion.insert(
            categoryId: categoryId,
            lessonIndex: lessonIndex,
            bestScore: max(score, old?.bestScore ?? 0),
            completedAt: now,
          ),
        );
  }
}
