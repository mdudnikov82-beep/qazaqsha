import 'dart:math';

import 'package:drift/drift.dart';

import '../../features/lessons/sections.dart';
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

class SectionState {
  const SectionState({
    required this.section,
    required this.topics,
    required this.unlocked,
    required this.examBestScore,
    required this.examPassed,
  });

  final CourseSection section;
  final List<TopicState> topics;

  /// The previous section's exam is passed (always true for the first).
  final bool unlocked;
  final int? examBestScore;
  final bool examPassed;

  /// The exam opens once every lesson of the section is done.
  bool get examUnlocked => unlocked && topics.every((t) => t.completed);
}

/// What the "Continue" button leads to.
sealed class NextStep {
  const NextStep();
}

class NextLesson extends NextStep {
  const NextLesson(this.topic);

  final TopicState topic;
}

class NextExam extends NextStep {
  const NextExam(this.section);

  final SectionState section;
}

class CourseFinished extends NextStep {
  const CourseFinished();
}

class CourseState {
  const CourseState(this.sections);

  final List<SectionState> sections;

  Iterable<TopicState> get topics => sections.expand((s) => s.topics);

  int get examsPassed => sections.where((s) => s.examPassed).length;

  int get lessonsDone => topics.fold(0, (sum, t) => sum + t.lessonsDone);

  NextStep get next {
    for (final s in sections) {
      for (final t in s.topics) {
        if (t.unlocked && !t.completed) return NextLesson(t);
      }
      if (s.examUnlocked && !s.examPassed) return NextExam(s);
    }
    return const CourseFinished();
  }
}

class LessonRepository {
  LessonRepository(this._db, this._dictionary);

  final AppDatabase _db;
  final DictionaryRepository _dictionary;

  /// The course, recomputed whenever a lesson or an exam is saved.
  ///
  /// Sections open one after another once the previous exam is passed;
  /// inside a section topics open in order, and inside a topic lessons do.
  Stream<CourseState> watchCourse() async* {
    final counts = {
      for (final c in await _dictionary.categories()) c.category.id: c,
    };
    Future<CourseState> load() async => _compute(
      counts,
      await _db.select(_db.lessonProgress).get(),
      await _db.select(_db.examProgress).get(),
    );
    yield await load();
    yield* _db
        .tableUpdates(
          TableUpdateQuery.onAllTables([_db.lessonProgress, _db.examProgress]),
        )
        .asyncMap((_) => load());
  }

  CourseState _compute(
    Map<String, CategoryWithCount> counts,
    List<LessonProgressData> lessons,
    List<ExamProgressData> exams,
  ) {
    final done = <String, Set<int>>{};
    for (final r in lessons) {
      done.putIfAbsent(r.categoryId, () => {}).add(r.lessonIndex);
    }
    final examById = {for (final e in exams) e.sectionId: e};

    var sectionOpen = true;
    final sections = <SectionState>[];
    for (final section in courseSections) {
      var previousDone = sectionOpen;
      final topics = <TopicState>[];
      for (final id in section.categoryIds) {
        final c = counts[id];
        if (c == null) continue;
        final count = lessonCountFor(c.wordCount);
        final finished = done[id] ?? const <int>{};
        // Count the unbroken run 0, 1, 2… so a gap never skips lessons.
        var inOrder = 0;
        while (finished.contains(inOrder)) {
          inOrder++;
        }
        final topic = TopicState(
          category: c.category,
          lessonCount: count,
          lessonsDone: min(inOrder, count),
          unlocked: previousDone,
        );
        topics.add(topic);
        previousDone = topic.completed;
      }
      final exam = examById[section.id];
      final state = SectionState(
        section: section,
        topics: topics,
        unlocked: sectionOpen,
        examBestScore: exam?.bestScore,
        examPassed: exam?.passedAt != null,
      );
      sections.add(state);
      sectionOpen = state.examPassed;
    }
    return CourseState(sections);
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

  /// Whether any lesson was finished since [since].
  Stream<bool> watchLessonSince(DateTime since) =>
      (_db.select(_db.lessonProgress)
            ..where((l) => l.completedAt.isBiggerOrEqualValue(since)))
          .watch()
          .map((rows) => rows.isNotEmpty);

  Future<int> examsPassed() async => (await (_db.select(
    _db.examProgress,
  )..where((e) => e.passedAt.isNotNull())).get()).length;

  /// Saves an exam attempt. Returns whether it was passed this time.
  Future<bool> recordExam({
    required String sectionId,
    required int score,
    required DateTime now,
  }) async {
    final old = await (_db.select(
      _db.examProgress,
    )..where((e) => e.sectionId.equals(sectionId))).getSingleOrNull();
    final passed = score >= examPassScore;
    await _db
        .into(_db.examProgress)
        .insertOnConflictUpdate(
          ExamProgressCompanion.insert(
            sectionId: sectionId,
            bestScore: max(score, old?.bestScore ?? 0),
            passedAt: Value(old?.passedAt ?? (passed ? now : null)),
          ),
        );
    return passed;
  }
}
