import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/custom_words_repository.dart';

String statusLabel(WordProgressData? p) => switch (p?.status) {
  null || LearningStatus.fresh => 'Новое',
  LearningStatus.learning => 'Изучаю',
  LearningStatus.learned => 'Выучено',
};

class WordTile extends ConsumerWidget {
  const WordTile({super.key, required this.word, required this.progress});

  final Word word;
  final WordProgressData? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final fav = progress?.isFavorite ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDetails(context, ref),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.kk,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        word.ru,
                        style: TextStyle(color: c.muted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: fav ? 'Убрать из избранного' : 'В избранное',
                  onPressed: () => ref
                      .read(progressRepositoryProvider)
                      .toggleFavorite(word.id),
                  icon: Icon(
                    fav ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: c.goldText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final p = progress;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word.kk,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(word.ru, style: TextStyle(color: c.muted, fontSize: 20)),
              if (word.note case final note?) ...[
                const SizedBox(height: 12),
                Text(note),
              ],
              const SizedBox(height: 16),
              Text(
                '${statusLabel(p)} · верно ${p?.correctCount ?? 0}, '
                'ошибок ${p?.wrongCount ?? 0}',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w700),
              ),
              if (word.categoryId == customCategoryId) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.badText,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () async {
                    Navigator.of(sheet).pop();
                    await ref
                        .read(customWordsRepositoryProvider)
                        .delete(word.id);
                    ref.invalidate(allWordsProvider);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Удалить из «Мои слова»'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
