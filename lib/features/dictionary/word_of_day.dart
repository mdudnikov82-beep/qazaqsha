import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/ornament.dart';
import '../../data/database/app_database.dart';
import '../gamification/progress_rules.dart';

/// The same word all day, a different one the next day.
Word wordOfDay(List<Word> words, DateTime now) =>
    words[dayOf(now).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay %
        words.length];

class WordOfDayCard extends StatelessWidget {
  const WordOfDayCard({super.key, required this.word, this.onTap});

  final Word word;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // A dark card in the light theme; in the dark theme a gold outline
    // keeps it apart from the other cards.
    final bg = dark ? c.surface : const Color(0xFF13232E);
    final card = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: dark
            ? Border.all(color: AppColors.gold.withValues(alpha: 0.5))
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -14,
            child: RamHorns(
              width: 120,
              color: AppColors.gold.withValues(alpha: 0.25),
              strokeWidth: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'КҮННІҢ СӨЗІ · СЛОВО ДНЯ',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  word.kk,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  word.ru,
                  style: const TextStyle(
                    color: Color(0xFF9DB0BB),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return Semantics(
      button: true,
      label: 'Слово дня: ${word.kk} — ${word.ru}',
      excludeSemantics: true,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}
