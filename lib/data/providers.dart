import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
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

final topicsProvider = StreamProvider<List<TopicState>>(
  (ref) => ref.watch(lessonRepositoryProvider).watchTopics(),
);

final unlockedAchievementsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(statsRepositoryProvider).watchUnlocked(),
);
