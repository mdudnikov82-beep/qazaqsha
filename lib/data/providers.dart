import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/grammar/grammar.dart';

import 'database/app_database.dart';
import 'repositories/backup_repository.dart';
import 'repositories/custom_words_repository.dart';
import 'repositories/dictionary_repository.dart';
import 'repositories/grammar_repository.dart';
import 'repositories/lesson_repository.dart';
import 'repositories/progress_repository.dart';
import 'repositories/stats_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final dictionaryRepositoryProvider = Provider<DictionaryRepository>(
  (ref) => DictionaryRepository(ref.watch(appDatabaseProvider)),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(appDatabaseProvider)),
);

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(appDatabaseProvider)),
);

final customWordsRepositoryProvider = Provider<CustomWordsRepository>(
  (ref) => CustomWordsRepository(ref.watch(appDatabaseProvider)),
);

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(customWordsRepositoryProvider),
  ),
);

/// Activity of the last [weeks] weeks, for the profile calendar.
final activityProvider = StreamProvider.family<List<DailyActivityData>, int>(
  (ref, weeks) => ref
      .watch(statsRepositoryProvider)
      .watchActivity(DateTime.now().subtract(Duration(days: weeks * 7))),
);

final grammarRepositoryProvider = Provider<GrammarRepository>(
  (ref) => GrammarRepository(ref.watch(appDatabaseProvider)),
);

/// Reads the grammar rules; tests read the file instead of the bundle.
final grammarSourceProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString('assets/data/grammar.json'),
);

final grammarProvider = FutureProvider<List<GrammarGroup>>(
  (ref) async => parseGrammar(await ref.watch(grammarSourceProvider)()),
);

final grammarProgressProvider =
    StreamProvider<Map<String, GrammarProgressData>>(
      (ref) => ref.watch(grammarRepositoryProvider).watch(),
    );

final lessonRepositoryProvider = Provider<LessonRepository>(
  (ref) => LessonRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(dictionaryRepositoryProvider),
  ),
);

/// The 500-word dictionary changes only with app updates: load it once.
final allWordsProvider = FutureProvider<List<Word>>(
  (ref) => ref.watch(dictionaryRepositoryProvider).allWords(),
);

/// Example sentences of all topics, for the word card.
final sentencesProvider = FutureProvider<List<Sentence>>(
  (ref) => ref
      .watch(appDatabaseProvider)
      .select(ref.watch(appDatabaseProvider).sentences)
      .get(),
);

final categoriesProvider = FutureProvider<List<CategoryWithCount>>(
  (ref) => ref.watch(dictionaryRepositoryProvider).categories(),
);

final statsProvider = StreamProvider<UserStat>(
  (ref) => ref.watch(statsRepositoryProvider).watch(),
);

final progressMapProvider = StreamProvider<Map<int, WordProgressData>>(
  (ref) => ref.watch(progressRepositoryProvider).watchAll(),
);

final courseProvider = StreamProvider<CourseState>(
  (ref) => ref.watch(lessonRepositoryProvider).watchCourse(),
);

final unlockedAchievementsProvider = StreamProvider<Map<String, DateTime>>(
  (ref) => ref.watch(statsRepositoryProvider).watchUnlocked(),
);

/// The theme choice. Switching updates the UI at once and saves in the
/// background, instead of waiting for the database round trip.
class ThemeModeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() =>
      // Only the theme field: other stats changes (XP…) don't rebuild this.
      ref.watch(statsProvider.select((s) => s.value?.themeMode)) ??
      AppThemeMode.system;

  Future<void> set(AppThemeMode mode) async {
    state = mode;
    await ref.read(statsRepositoryProvider).setThemeMode(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(
  ThemeModeNotifier.new,
);
