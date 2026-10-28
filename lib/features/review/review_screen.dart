import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../dictionary/word_tile.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(allWordsProvider);
    final progress = ref.watch(progressMapProvider);
    if (words.value == null || progress.value == null) {
      return LoadingScaffold(error: words.error ?? progress.error);
    }
    final c = context.colors;
    final now = DateTime.now();
    final byId = {for (final w in words.value!) w.id: w};
    final studied = progress.value!.values
        .where((p) => p.status != LearningStatus.fresh)
        .toList();
    final due = studied
        .where((p) => p.nextReviewAt != null && !p.nextReviewAt!.isAfter(now))
        .length;
    final hard = [...studied.where((p) => p.wrongCount > 0)]
      ..sort((a, b) => b.wrongCount.compareTo(a.wrongCount));

    return Scaffold(
      appBar: AppBar(title: const Text('Қайталау')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(
            'Повторение слов',
            style: TextStyle(color: c.muted, fontSize: 15),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            radius: 24,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  due > 0 ? Icons.replay_rounded : Icons.check_circle_rounded,
                  size: 48,
                  color: due > 0 ? c.accent : c.ok,
                ),
                const SizedBox(height: 12),
                Text(
                  due > 0
                      ? 'Ждут повторения: $due'
                      : studied.isEmpty
                      ? 'Пока нечего повторять'
                      : 'Всё повторено!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  studied.isEmpty
                      ? 'Пройдите урок — выученные слова будут возвращаться сюда, чтобы не забыться.'
                      : 'Слова возвращаются через 1, 3, 7, 16 и 35 дней. '
                            'Ошибка — и слово снова повторяется сразу.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.muted),
                ),
                if (due > 0) ...[
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () => context.push('/practice/review'),
                    child: const Text('Начать повторение'),
                  ),
                ],
              ],
            ),
          ),
          if (hard.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Сложные слова',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final p in hard.take(10))
              if (byId[p.wordId] case final w?) WordTile(word: w, progress: p),
          ],
        ],
      ),
    );
  }
}
