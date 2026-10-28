import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  int get schemaVersion => 5;

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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

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
