import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/latin.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import 'word_sheet.dart';

export 'word_sheet.dart' show statusLabel;

/// Height of a [WordTile] with its gap, so long lists can jump to a letter.
const wordTileExtent = 72.0;

class WordTile extends ConsumerWidget {
  const WordTile({
    super.key,
    required this.word,
    required this.progress,
    this.trailing,
  });

  final Word word;
  final WordProgressData? progress;

  /// Replaces the favourite star (e.g. mistake count in Review).
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final fav = progress?.isFavorite ?? false;
    final dot = switch (progress?.status) {
      LearningStatus.learned => c.ok,
      LearningStatus.learning => AppColors.gold,
      _ => c.track,
    };
    return SizedBox(
      height: wordTileExtent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => showWordSheet(context, word),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
              child: Row(
                children: [
                  Semantics(
                    label: statusLabel(progress),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: word.kk,
                            children: [
                              if (ref.watch(showLatinProvider))
                                TextSpan(
                                  text: '  ${toLatin(word.kk)}',
                                  style: TextStyle(
                                    color: c.accent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          word.ru,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: c.muted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  trailing ??
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
      ),
    );
  }
}
