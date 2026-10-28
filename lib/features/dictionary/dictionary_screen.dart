import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../data/database/app_database.dart';
import '../../data/database/seed.dart';
import '../../data/providers.dart';
import '../../data/repositories/custom_words_repository.dart';
import 'word_tile.dart';

enum _Filter { all, favorites, studying }

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  String _query = '';
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(allWordsProvider);
    final categories = ref.watch(categoriesProvider);
    if (words.value == null || categories.value == null) {
      return LoadingScaffold(error: words.error ?? categories.error);
    }
    final progress = ref.watch(progressMapProvider).value ?? const {};
    final c = context.colors;
    final q = normalizeForSearch(_query);

    List<Word>? list;
    if (q.isNotEmpty) {
      list = words.value!
          .where((w) => normalizeForSearch('${w.ru} ${w.kk}').contains(q))
          .toList();
    } else if (_filter == _Filter.favorites) {
      list = words.value!
          .where((w) => progress[w.id]?.isFavorite ?? false)
          .toList();
    } else if (_filter == _Filter.studying) {
      list = words.value!
          .where(
            (w) =>
                (progress[w.id]?.status ?? LearningStatus.fresh) !=
                LearningStatus.fresh,
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сөздік'),
        actions: [
          IconButton(
            tooltip: 'Добавить свои слова',
            onPressed: () => context.push('/import'),
            icon: const Icon(Icons.playlist_add_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${words.value!.length} слов',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'По-русски или қазақша',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final (f, label) in [
                (_Filter.all, 'Все темы'),
                (_Filter.favorites, 'Избранное'),
                (_Filter.studying, 'Изучаю'),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (list != null) ...[
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  q.isNotEmpty
                      ? 'Ничего не найдено'
                      : _filter == _Filter.favorites
                      ? 'Нажмите ☆ у слова, чтобы добавить его в избранное'
                      : 'Пройдите первый урок — слова появятся здесь',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.muted),
                ),
              ),
            for (final w in list) WordTile(word: w, progress: progress[w.id]),
          ] else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                for (final cat in categories.value!)
                  () {
                    final ids = words.value!
                        .where((w) => w.categoryId == cat.category.id)
                        .map((w) => w.id);
                    final learned = ids
                        .where(
                          (id) =>
                              progress[id]?.status == LearningStatus.learned,
                        )
                        .length;
                    return SurfaceCard(
                      radius: 18,
                      padding: const EdgeInsets.all(14),
                      onTap: () =>
                          context.push('/dictionary/${cat.category.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            categoryIcon(cat.category.icon),
                            color: c.accent,
                          ),
                          Text(
                            cat.category.titleKk,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${cat.category.titleRu} · ${cat.wordCount}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: c.muted, fontSize: 13),
                          ),
                          ProgressBar(
                            value: learned / cat.wordCount,
                            height: 6,
                            semanticsLabel: 'Выучено',
                          ),
                        ],
                      ),
                    );
                  }(),
              ],
            ),
        ],
      ),
    );
  }
}

class CategoryWordsScreen extends ConsumerWidget {
  const CategoryWordsScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(allWordsProvider);
    final categories = ref.watch(categoriesProvider);
    if (words.value == null || categories.value == null) {
      return LoadingScaffold(error: words.error ?? categories.error);
    }
    final progress = ref.watch(progressMapProvider).value ?? const {};
    final isCustom = categoryId == customCategoryId;
    final cat = categories.value!
        .where((c) => c.category.id == categoryId)
        .firstOrNull
        ?.category;
    final list = words.value!.where((w) => w.categoryId == categoryId).toList();
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(cat?.titleKk ?? 'Менің сөздерім')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(cat?.titleRu ?? 'Мои слова', style: TextStyle(color: c.muted)),
          const SizedBox(height: 12),
          if (isCustom) ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: list.isEmpty
                        ? null
                        : () => context.push('/practice/custom'),
                    icon: const Icon(Icons.fitness_center_rounded),
                    label: const Text('Тренировать'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: () => context.push('/import'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Добавить'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              Text(
                'Пока пусто. Добавьте слова вручную или пришлите их '
                'Telegram-боту.',
                style: TextStyle(color: c.muted),
              ),
          ],
          for (final w in list) WordTile(word: w, progress: progress[w.id]),
        ],
      ),
    );
  }
}
