import 'package:drift/drift.dart';

/// Where a word is in the learning cycle.
enum LearningStatus { fresh, learning, learned }

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get titleRu => text()();
  TextColumn get titleKk => text()();

  /// Material icon name, mapped to IconData in the UI.
  TextColumn get icon => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get ru => text()();
  TextColumn get kk => text()();

  /// Usage hint, e.g. who says this form.
  TextColumn get note => text().nullable()();
  IntColumn get sortOrder => integer()();

  /// Lowercased "ru kk" with ё→е. SQLite's LIKE only folds ASCII case,
  /// so search runs against this column instead of ru/kk.
  TextColumn get searchText => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {ru, kk},
  ];
}

/// Example sentences for "build the sentence" quizzes (filled in step 6).
class Sentences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get ru => text()();
  TextColumn get kk => text()();
}

/// One row per word the user has seen. Missing row = never studied.
class WordProgress extends Table {
  IntColumn get wordId => integer().references(Words, #id)();
  IntColumn get status =>
      intEnum<LearningStatus>().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  IntColumn get wrongCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get nextReviewAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  /// Spaced-repetition box (Leitner): 0 = just failed, higher = longer gap.
  IntColumn get box => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {wordId};
}

/// Matches Flutter's ThemeMode order: system, light, dark.
enum AppThemeMode { system, light, dark }

/// Single-row table (id = 1) with the player's gamification state.
class UserStats extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get streakDays => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActiveDate => dateTime().nullable()();
  IntColumn get dailyGoalXp => integer().withDefault(const Constant(50))();

  /// XP earned on [dailyXpDate]; reset when a new day starts.
  IntColumn get dailyXp => integer().withDefault(const Constant(0))();
  DateTimeColumn get dailyXpDate => dateTime().nullable()();
  IntColumn get quizzesCompleted => integer().withDefault(const Constant(0))();
  IntColumn get answersCorrect => integer().withDefault(const Constant(0))();
  IntColumn get answersTotal => integer().withDefault(const Constant(0))();
  IntColumn get themeMode =>
      intEnum<AppThemeMode>().withDefault(const Constant(0))();

  /// Time spent in lessons, reviews and exams.
  IntColumn get studySeconds => integer().withDefault(const Constant(0))();

  /// The welcome flow was finished or skipped.
  BoolColumn get onboardingDone =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Best result of a section exam. [passedAt] is set once it was passed.
class ExamProgress extends Table {
  TextColumn get sectionId => text()();
  IntColumn get bestScore => integer()();
  DateTimeColumn get passedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {sectionId};
}

/// A finished lesson. Lesson = a chunk of a category's words.
class LessonProgress extends Table {
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get lessonIndex => integer()();

  /// Best result in percent of correct answers.
  IntColumn get bestScore => integer()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {categoryId, lessonIndex};
}

class UnlockedAchievements extends Table {
  TextColumn get id => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
