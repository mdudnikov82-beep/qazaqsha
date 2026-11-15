import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/widgets/common.dart';
import '../../data/providers.dart';
import 'collection.dart';

/// The album: cards about Kazakh culture and nature that open with finished
/// topics. A collection to look at, never something to spend.
class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final finished = ref.watch(finishedTopicsProvider);
    final open = cardsOpen(finished);
    final next = open < albumCards.length ? topicsForCard(open) - finished : 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Альбом')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Собрано $open из ${albumCards.length}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    open == albumCards.length
                        ? 'Весь альбом собран. Керемет!'
                        : 'Следующая карточка — после ещё $next '
                              '${plural(next, 'темы', 'тем', 'тем')}. '
                              'Нажмите на карточку, чтобы прочитать.',
                    style: TextStyle(color: c.muted, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  ProgressBar(
                    value: open / albumCards.length,
                    semanticsLabel: 'Собрано $open из ${albumCards.length}',
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: albumCards.length,
              itemBuilder: (context, i) => i < open
                  ? AlbumCardTile(
                      card: albumCards[i],
                      onTap: () => showCardSheet(context, albumCards[i]),
                    )
                  : _LockedCard(index: i),
            ),
          ),
        ],
      ),
    );
  }
}

/// The colour of a card, from its place in the album.
Color _cardColor(AlbumCard card) {
  const hues = [
    Color(0xFF00789A),
    Color(0xFFB85F00),
    Color(0xFF5B4BC4),
    Color(0xFF1B7F4E),
    Color(0xFFB3366A),
    Color(0xFF2A62B0),
  ];
  return hues[albumCards.indexOf(card) % hues.length];
}

class AlbumCardTile extends StatelessWidget {
  const AlbumCardTile({super.key, required this.card, this.onTap});

  final AlbumCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = _cardColor(card);
    return Semantics(
      button: onTap != null,
      label: '${card.kk}, ${card.ru}',
      excludeSemantics: true,
      child: Material(
        color: c.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: Color.alphaBlend(
                    color.withValues(alpha: 0.16),
                    c.surface,
                  ),
                  alignment: Alignment.center,
                  child: Text(card.emoji, style: const TextStyle(fontSize: 52)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  children: [
                    Text(
                      card.kk,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      card.ru,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: c.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final topics = topicsForCard(index);
    return Semantics(
      label: 'Карточка ${index + 1}: откроется после $topics тем',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: c.track,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '?',
              style: TextStyle(
                color: c.lockIcon,
                fontSize: 44,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$topics ${plural(topics, 'тема', 'темы', 'тем')}',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

/// The card's fact in a bottom sheet.
void showCardSheet(BuildContext context, AlbumCard card) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final c = context.colors;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(card.emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text(
                card.kk,
                style: TextStyle(
                  color: _cardColor(card),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(card.ru, style: TextStyle(color: c.muted, fontSize: 16)),
              const SizedBox(height: 16),
              Text(
                card.fact,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, height: 1.4),
              ),
            ],
          ),
        ),
      );
    },
  );
}
