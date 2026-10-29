import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/latin_line.dart';
import '../../core/widgets/gold_button.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';

/// Flip-through cards for a topic (or `favorites`): see the word, think,
/// turn the card, say whether you knew it. Unknown words go to review.
class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key, required this.source});

  /// A category id, or `favorites`.
  final String source;

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  List<Word>? _deck;
  var _index = 0;
  var _flipped = false;

  /// Show the Russian side first.
  var _russianFirst = false;
  final _known = <int, bool>{};

  void _start(List<Word> words) {
    setState(() {
      _deck = [...words]..shuffle(Random());
      _index = 0;
      _flipped = false;
      _known.clear();
    });
  }

  Future<void> _answer(bool knew) async {
    final word = _deck![_index];
    knew ? Haptics.success() : Haptics.tap();
    _known[word.id] = knew;
    setState(() {
      _index++;
      _flipped = false;
    });
    if (_index == _deck!.length) {
      await ref
          .read(progressRepositoryProvider)
          .applySession(Map.of(_known), DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(allWordsProvider).value;
    final progress = ref.watch(progressMapProvider).value;
    final categories = ref.watch(categoriesProvider).value;
    if (words == null || progress == null || categories == null) {
      return const LoadingScaffold();
    }
    final favorites = widget.source == 'favorites';
    final title = favorites
        ? 'Избранное'
        : categories
                  .where((x) => x.category.id == widget.source)
                  .firstOrNull
                  ?.category
                  .titleKk ??
              'Карточки';
    if (_deck == null) {
      final pool = [
        for (final w in words)
          if (favorites
              ? progress[w.id]?.isFavorite ?? false
              : w.categoryId == widget.source)
            w,
      ];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _deck == null) _start(pool);
      });
      return const LoadingScaffold();
    }
    final deck = _deck!;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: _russianFirst
                ? 'Сначала казахское слово'
                : 'Сначала русское слово',
            onPressed: () => setState(() {
              _russianFirst = !_russianFirst;
              _flipped = false;
            }),
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: deck.isEmpty
              ? Center(
                  child: Text(
                    favorites
                        ? 'В избранном пока пусто'
                        : 'В этой теме пока нет слов',
                    style: TextStyle(color: context.colors.muted),
                  ),
                )
              : _index >= deck.length
              ? _Summary(
                  known: _known.values.where((k) => k).length,
                  total: deck.length,
                  onAgain: _known.values.any((k) => !k)
                      ? () => _start([
                          for (final w in deck)
                            if (_known[w.id] == false) w,
                        ])
                      : null,
                  onDone: () => context.pop(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProgressBar(
                      value: _index / deck.length,
                      semanticsLabel:
                          'Карточка ${_index + 1} из ${deck.length}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_index + 1} из ${deck.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _Card(
                        key: ValueKey(_index),
                        word: deck[_index],
                        flipped: _flipped,
                        russianFirst: _russianFirst,
                        onTap: () => setState(() => _flipped = !_flipped),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_flipped)
                      GoldButton(
                        label: 'Перевернуть',
                        icon: Icons.flip_rounded,
                        onPressed: () => setState(() => _flipped = true),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.badButton,
                                minimumSize: const Size.fromHeight(56),
                              ),
                              onPressed: () => _answer(false),
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Не знаю'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.okButton,
                                minimumSize: const Size.fromHeight(56),
                              ),
                              onPressed: () => _answer(true),
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Знаю'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    super.key,
    required this.word,
    required this.flipped,
    required this.russianFirst,
    required this.onTap,
  });

  final Word word;
  final bool flipped;
  final bool russianFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final showKazakh = flipped == russianFirst;
    final face = Container(
      key: ValueKey(flipped),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: flipped ? context.colors.brand : c.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: flipped ? context.colors.brandDeep : c.line,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            showKazakh ? 'ҚАЗАҚША' : 'ПО-РУССКИ',
            style: TextStyle(
              color: flipped ? AppColors.gold : c.muted,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            showKazakh ? word.kk : word.ru,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: flipped ? Colors.white : c.ink,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (showKazakh)
            LatinLine(
              word.kk,
              fontSize: 18,
              textAlign: TextAlign.center,
              color: flipped ? AppColors.gold : null,
            ),
          if (flipped && word.note != null) ...[
            const SizedBox(height: 12),
            Text(
              word.note!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.onBrandMuted,
                fontSize: 15,
              ),
            ),
          ],
          if (!flipped) ...[
            const SizedBox(height: 18),
            Text(
              'Вспомните перевод и нажмите на карточку',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted),
            ),
          ],
        ],
      ),
    );
    return Semantics(
      button: true,
      label: flipped
          ? 'Перевод: ${word.kk} — ${word.ru}'
          : 'Перевернуть карточку',
      child: GestureDetector(
        onTap: onTap,
        child: reduceMotion(context)
            ? face
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, animation) => AnimatedBuilder(
                  animation: animation,
                  child: child,
                  builder: (context, child) {
                    // Turn around the vertical axis; only the half facing us shows.
                    final angle = (1 - animation.value) * pi / 2;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: child,
                    );
                  },
                ),
                layoutBuilder: (current, previous) =>
                    Stack(children: [?current]),
                child: face,
              ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.known,
    required this.total,
    required this.onAgain,
    required this.onDone,
  });

  final int known;
  final int total;
  final VoidCallback? onAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.style_rounded, size: 64, color: c.accent),
        const SizedBox(height: 12),
        const Text(
          'Карточки пройдены!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Знаю: $known из $total',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          known == total
              ? 'Отлично! Слова вернутся в повторение позже.'
              : 'Незнакомые слова попадут в повторение уже сегодня.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.muted),
        ),
        const SizedBox(height: 28),
        if (onAgain != null) ...[
          GoldButton(
            label: 'Ещё раз незнакомые',
            icon: Icons.replay_rounded,
            onPressed: onAgain!,
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: onDone,
          child: const Text('Готово'),
        ),
      ],
    );
  }
}
