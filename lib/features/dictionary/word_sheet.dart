import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/widgets/latin_line.dart';
import '../../core/widgets/speak_button.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/custom_words_repository.dart';
import '../custom_words/import_screen.dart' show EditedPair, PairDialog;
import '../custom_words/word_import.dart';
import '../gamification/progress_rules.dart';
import '../lessons/sections.dart';
import '../quiz/quiz_engine.dart';
import '../quiz/srs.dart';

/// The word card: translation, topic and lesson, an example sentence,
/// how it is going, and actions.
Future<void> showWordSheet(BuildContext context, Word word) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _WordSheet(word: word, parent: context),
    );

String statusLabel(WordProgressData? p) => switch (p?.status) {
  null || LearningStatus.fresh => 'Новое',
  LearningStatus.learning => 'Изучаю',
  LearningStatus.learned => 'Выучено',
};

/// A sentence that uses [word], preferring its own topic.
Sentence? exampleFor(Word word, List<Sentence> sentences) {
  final kk = word.kk.toLowerCase().replaceAll(RegExp(r'[?!.…]'), '').trim();
  if (kk.isEmpty) return null;
  final single = !kk.contains(' ');
  bool uses(Sentence s) {
    final text = s.kk.toLowerCase();
    if (!single) return text.contains(kk);
    // Kazakh adds endings: «қала» is in «қалаға», «қаласы».
    return text
        .split(RegExp(r'[\s,.!?—–:;«»"]+'))
        .any((t) => kk.length >= 3 ? t.startsWith(kk) : t == kk);
  }

  final mine = sentences.where((s) => s.categoryId == word.categoryId);
  return mine.where(uses).firstOrNull ?? sentences.where(uses).firstOrNull;
}

class _WordSheet extends ConsumerWidget {
  const _WordSheet({required this.word, required this.parent});

  final Word word;

  /// The screen under the sheet, to navigate from after closing it.
  final BuildContext parent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final p = ref.watch(progressMapProvider).value?[word.id];
    final words = ref.watch(allWordsProvider).value ?? const [];
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final sentences = ref.watch(sentencesProvider).value ?? const [];
    final category = categories
        .where((x) => x.category.id == word.categoryId)
        .firstOrNull
        ?.category;
    final isCustom = isOwnSet(word.categoryId);
    final section = sectionOfCategory(word.categoryId);
    final accent = section?.color ?? context.colors.brand;
    final topicWords = [
      for (final w in words)
        if (w.categoryId == word.categoryId) w,
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final index = topicWords.indexWhere((w) => w.id == word.id);
    final example = exampleFor(word, sentences);
    final fav = p?.isFavorite ?? false;
    final now = DateTime.now();

    final (statusFg, statusBg) = switch (p?.status) {
      LearningStatus.learned => (c.okText, c.okSoft),
      LearningStatus.learning => (c.goldText, c.goldSoft),
      _ => (c.muted, c.track),
    };

    void go(String location) {
      Navigator.of(context).pop();
      parent.push(location);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.kk,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.6,
                          height: 1.1,
                        ),
                      ),
                      LatinLine(word.kk, fontSize: 18),
                      const SizedBox(height: 2),
                      Text(
                        word.ru,
                        style: TextStyle(color: c.muted, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
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
            if (word.note case final note?) ...[
              const SizedBox(height: 10),
              Text(note, style: const TextStyle(fontSize: 15)),
            ],
            const SizedBox(height: 14),
            ListenButton(word.kk),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(text: statusLabel(p), fg: statusFg, bg: statusBg),
                if (category != null)
                  _Chip(
                    text: isCustom
                        ? category.titleRu
                        : '${category.titleRu} · урок ${index ~/ lessonSize + 1}',
                    fg: Colors.white,
                    bg: accent,
                    onTap: () => go('/dictionary/${word.categoryId}'),
                  ),
              ],
            ),
            if (example != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ПРИМЕР',
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      _highlight(example.kk, word.kk, c.goldSoft),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(example.ru, style: TextStyle(color: c.muted)),
                  ],
                ),
              ),
            ],
            if (p != null && p.status != LearningStatus.fresh) ...[
              const SizedBox(height: 16),
              _MemorySteps(
                box: p.box,
                correct: p.correctCount,
                next: switch (p.nextReviewAt) {
                  final next? => _when(next, now),
                  null => null,
                },
              ),
            ],
            if (!isCustom && topicWords.length > 1) ...[
              const SizedBox(height: 16),
              Text(
                'ИЗ ТОЙ ЖЕ ТЕМЫ',
                style: TextStyle(
                  color: c.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .6,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final w in _neighbours(topicWords, index))
                    ActionChip(
                      label: Text('${w.kk} · ${w.ru}'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showWordSheet(parent, w);
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => go('/flashcards/${word.categoryId}'),
              icon: const Icon(Icons.style_rounded),
              label: const Text('Карточки этой темы'),
            ),
            if (isCustom) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => _edit(context, ref),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Изменить'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.badText,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ref.read(customWordsRepositoryProvider).delete(word.id);
                  ref.invalidate(allWordsProvider);
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text('Удалить из «${category?.titleRu ?? 'Мои слова'}»'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<EditedPair>(
      context: context,
      builder: (_) => PairDialog(
        initial: ImportedWord(word.kk, word.ru),
        note: word.note ?? '',
      ),
    );
    if (result == null) return;
    try {
      await ref
          .read(customWordsRepositoryProvider)
          .updateWord(
            word.id,
            kk: result.word.kk,
            ru: result.word.ru,
            note: result.note,
          );
      ref.invalidate(allWordsProvider);
      if (context.mounted) Navigator.of(context).pop();
    } on DuplicateWord {
      messenger.showSnackBar(
        const SnackBar(content: Text('Такое слово уже есть в словаре')),
      );
    }
  }

  /// Up to three words next to [index] in its topic.
  static List<Word> _neighbours(List<Word> topic, int index) {
    final start = (index - 1).clamp(
      0,
      (topic.length - 4).clamp(0, topic.length),
    );
    return [
      for (final (i, w) in topic.indexed)
        if (i >= start && i != index) w,
    ].take(3).toList();
  }

  /// [text] with the word [kk] (with any ending) on a highlight.
  static TextSpan _highlight(String text, String kk, Color mark) {
    final stem = kk.toLowerCase().replaceAll(RegExp(r'[?!.…]'), '').trim();
    final spans = <InlineSpan>[];
    var marked = false;
    for (final m in RegExp(
      r'[^\s,.!?—–:;«»"]+|[\s,.!?—–:;«»"]+',
    ).allMatches(text)) {
      final t = m[0]!;
      final hit =
          !marked &&
          stem.isNotEmpty &&
          !stem.contains(' ') &&
          (stem.length >= 3
              ? t.toLowerCase().startsWith(stem)
              : t.toLowerCase() == stem);
      marked |= hit;
      spans.add(
        TextSpan(
          text: t,
          style: hit ? TextStyle(backgroundColor: mark) : null,
        ),
      );
    }
    return TextSpan(children: spans);
  }

  static String _when(DateTime next, DateTime now) {
    final days = daysBetween(now, next);
    if (days <= 0) return 'сегодня';
    if (days == 1) return 'завтра';
    return dayMonth(next);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.fg,
    required this.bg,
    this.onTap,
  });

  final String text;
  final Color fg;
  final Color bg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: bg,
    borderRadius: BorderRadius.circular(999),
    child: InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(color: fg, fontWeight: FontWeight.w800),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, color: fg, size: 18),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Five steps of memory (spaced-repetition boxes), filled as a word is
/// remembered for longer.
class _MemorySteps extends StatelessWidget {
  const _MemorySteps({required this.box, required this.correct, this.next});

  final int box;
  final int correct;
  final String? next;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final steps = reviewIntervals.length - 1;
    return Semantics(
      label: 'Память: ступень ${box.clamp(0, steps)} из $steps',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Память',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ),
                if (next != null)
                  Text(
                    'повторим $next',
                    style: TextStyle(
                      color: c.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < steps; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: i < box ? c.ok : c.line,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ступень ${box.clamp(0, steps)} из $steps · верно $correct '
              '${plural(correct, 'раз', 'раза', 'раз')}',
              style: TextStyle(
                color: c.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
