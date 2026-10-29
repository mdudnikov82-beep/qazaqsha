import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;

import '../../features/gamification/progress_rules.dart';
import 'seed.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

typedef SeedLoader = Future<String> Function();

Future<String> _loadSeedFromAssets() =>
    rootBundle.loadString('assets/data/dictionary.json');

Future<String> _loadSentencesFromAssets() =>
    rootBundle.loadString('assets/data/sentences.json');

@DriftDatabase(
  tables: [
    Categories,
    Words,
    Sentences,
    WordProgress,
    UserStats,
    UnlockedAchievements,
    LessonProgress,
    ExamProgress,
    DailyActivity,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// [executor] and the loaders are overridable for tests.
  AppDatabase({
    QueryExecutor? executor,
    SeedLoader? loadSeed,
    SeedLoader? loadSentences,
  }) : _loadSeed = loadSeed ?? _loadSeedFromAssets,
       _loadSentences = loadSentences ?? _loadSentencesFromAssets,
       super(executor ?? _openConnection());

  final SeedLoader _loadSeed;
  final SeedLoader _loadSentences;

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
      await _seedSentences();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(wordProgress, wordProgress.box);
        await m.addColumn(userStats, userStats.dailyXp);
        await m.addColumn(userStats, userStats.dailyXpDate);
        await m.addColumn(userStats, userStats.quizzesCompleted);
        await m.addColumn(userStats, userStats.answersCorrect);
        await m.addColumn(userStats, userStats.answersTotal);
        await m.addColumn(userStats, userStats.themeMode);
        await m.createTable(lessonProgress);
      }
      if (from < 3) {
        // The table exists since v1 but was empty until v3.
        await _seedSentences();
      }
      if (from < 4) {
        await m.addColumn(userStats, userStats.studySeconds);
        await m.createTable(examProgress);
      }
      if (from < 5) {
        await m.addColumn(userStats, userStats.onboardingDone);
        // People upgrading already know the app: don't greet them again.
        await customStatement('UPDATE user_stats SET onboarding_done = 1');
      }
      if (from < 6) {
        await m.addColumn(userStats, userStats.bestStreak);
        await m.addColumn(userStats, userStats.userName);
        await m.addColumn(userStats, userStats.hapticsEnabled);
        await m.addColumn(userStats, userStats.reminderEnabled);
        await m.addColumn(userStats, userStats.reminderMinutes);
        await customStatement(
          'UPDATE user_stats SET best_streak = streak_days',
        );
        await m.createTable(dailyActivity);
        await _backfillActivity();
      }
      if (from < 7) {
        // Dictionary v2: 500 → 1500 words in three new course sections.
        await _addNewSeed();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Before v6 days weren't recorded; finished lessons and today's XP
  /// still tell which days had activity.
  Future<void> _backfillActivity() async {
    final days = <DateTime, DailyActivityCompanion>{};
    for (final l in await select(lessonProgress).get()) {
      final day = dayOf(l.completedAt);
      final old = days[day];
      days[day] = DailyActivityCompanion.insert(
        day: day,
        sessions: Value((old?.sessions.value ?? 0) + 1),
      );
    }
    final stats = await select(userStats).getSingleOrNull();
    if (stats?.dailyXpDate case final date?) {
      final day = dayOf(date);
      days[day] = DailyActivityCompanion.insert(
        day: day,
        xp: Value(stats!.dailyXp),
        sessions: Value(days[day]?.sessions.value ?? 1),
      );
    }
    await batch((b) => b.insertAll(dailyActivity, days.values));
  }

  /// Adds categories, words and sentences of a newer dictionary that this
  /// database doesn't have yet. Existing rows (and their ids, which
  /// progress refers to) are left alone; new words only ever come after
  /// the old ones in a category, so lessons keep their numbers.
  @visibleForTesting
  Future<void> addNewSeed() => _addNewSeed();

  Future<void> _addNewSeed() async {
    final categories = parseDictionary(await _loadSeed());
    final haveCategories = {
      for (final c in await select(this.categories).get()) c.id,
    };
    final haveWords = {for (final w in await select(words).get()) (w.ru, w.kk)};
    final haveSentences = {
      for (final s in await select(sentences).get()) (s.ru, s.kk),
    };
    final newSentences = parseSentences(await _loadSentences());
    await batch((b) {
      for (final (ci, c) in categories.indexed) {
        if (!haveCategories.contains(c.id)) {
          b.insert(
            this.categories,
            CategoriesCompanion.insert(
              id: c.id,
              titleRu: c.ru,
              titleKk: c.kk,
              icon: c.icon,
              sortOrder: ci,
            ),
          );
        }
        for (final (wi, w) in c.words.indexed) {
          if (haveWords.contains((w.ru, w.kk))) continue;
          b.insert(
            words,
            WordsCompanion.insert(
              categoryId: c.id,
              ru: w.ru,
              kk: w.kk,
              note: Value(w.note),
              sortOrder: wi,
              searchText: normalizeForSearch('${w.ru} ${w.kk}'),
            ),
            // Someone may have added the same pair as an own word.
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
      for (final s in newSentences) {
        if (haveSentences.contains((s.ru, s.kk))) continue;
        b.insert(
          sentences,
          SentencesCompanion.insert(
            categoryId: Value(s.categoryId),
            ru: s.ru,
            kk: s.kk,
          ),
        );
      }
    });
  }

  Future<void> _seed() async {
    final categories = parseDictionary(await _loadSeed());
    await batch((b) {
      for (final (ci, c) in categories.indexed) {
        b.insert(
          this.categories,
          CategoriesCompanion.insert(
            id: c.id,
            titleRu: c.ru,
            titleKk: c.kk,
            icon: c.icon,
            sortOrder: ci,
          ),
        );
        for (final (wi, w) in c.words.indexed) {
          b.insert(
            words,
            WordsCompanion.insert(
              categoryId: c.id,
              ru: w.ru,
              kk: w.kk,
              note: Value(w.note),
              sortOrder: wi,
              searchText: normalizeForSearch('${w.ru} ${w.kk}'),
            ),
          );
        }
      }
      b.insert(userStats, UserStatsCompanion.insert());
    });
  }

  Future<void> _seedSentences() async {
    final rows = parseSentences(await _loadSentences());
    await batch((b) {
      for (final s in rows) {
        b.insert(
          sentences,
          SentencesCompanion.insert(
            categoryId: Value(s.categoryId),
            ru: s.ru,
            kk: s.kk,
          ),
        );
      }
    });
  }

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'qazaqsha',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
