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

  /// Longest streak ever reached.
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();

  /// How the app greets the user; null = not set.
  TextColumn get userName => text().nullable()();
  BoolColumn get hapticsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Earned streak protections (see progress_rules.dart).
  IntColumn get streakFreezes => integer().withDefault(const Constant(0))();

  /// A streak that broke after one missed day, and the day it can still be
  /// won back on.
  IntColumn get repairStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get repairDay => dateTime().nullable()();

  /// Days a week with study that make the week «done».
  IntColumn get weeklyGoalDays => integer().withDefault(const Constant(5))();

  /// Daily reminder time, minutes after midnight (19:00 by default).
  IntColumn get reminderMinutes =>
      integer().withDefault(const Constant(19 * 60))();

  @override
  Set<Column> get primaryKey => {id};
}

/// What was done on one calendar day, for the activity calendar.
class DailyActivity extends Table {
  /// The day as a UTC date (see dayOf), so DST never splits a day.
  DateTimeColumn get day => dateTime()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get seconds => integer().withDefault(const Constant(0))();
  IntColumn get sessions => integer().withDefault(const Constant(0))();

  /// A missed day covered by a streak freeze (or won back).
  BoolColumn get frozen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {day};
}

/// A grammar rule whose exercises were done. [bestScore] in percent.
class GrammarProgress extends Table {
  TextColumn get ruleId => text()();
  IntColumn get bestScore => integer()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ruleId};
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
