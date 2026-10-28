import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'repositories/custom_words_repository.dart';
import 'repositories/dictionary_repository.dart';
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

final unlockedAchievementsProvider = StreamProvider<Set<String>>(
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
