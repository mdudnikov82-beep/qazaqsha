import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/alphabet.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/teal_header.dart';
import '../../data/database/app_database.dart';
import '../../data/database/seed.dart';
import '../../data/providers.dart';
import '../../data/repositories/custom_words_repository.dart';
import '../custom_words/set_actions.dart';
import '../../data/repositories/dictionary_repository.dart';
import '../lessons/sections.dart';
import '../quiz/quiz_engine.dart';
import 'word_of_day.dart';
import 'word_sheet.dart';
import 'word_tile.dart';

enum _Mode { topics, az, favorites, studying }

enum _Sort { alphabet, freshFirst, learnedFirst }

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _search = TextEditingController();
  final _list = ScrollController();
  _Mode _mode = _Mode.topics;
  _Sort _sort = _Sort.alphabet;

  /// А–Я: sort by the Kazakh word (true) or the Russian one.
  bool _byKazakh = true;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    _list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(allWordsProvider);
    final categories = ref.watch(categoriesProvider);
    if (words.value == null || categories.value == null) {
      return LoadingScaffold(error: words.error ?? categories.error);
    }
    final all = words.value!;
    final progress = ref.watch(progressMapProvider).value ?? const {};
    final learned = progress.values
        .where((p) => p.status == LearningStatus.learned)
        .length;
    final q = normalizeForSearch(_search.text);

    final Widget body;
    if (q.isNotEmpty) {
      final found = all.where((w) => w.searchText.contains(q)).toList()
        ..sort((a, b) {
          // Words that start with the query first.
          bool starts(Word w) => w0(w).split('|').any((t) => t.startsWith(q));
          final sa = starts(a) ? 0 : 1;
          final sb = starts(b) ? 0 : 1;
          return sa != sb ? sa - sb : a.kk.length - b.kk.length;
        });
      body = _WordList(
        words: found,
        progress: progress,
        empty: 'Ничего не найдено. Можно добавить слово в «Мои слова».',
      );
    } else {
      body = switch (_mode) {
        _Mode.topics => _Topics(
          categories: categories.value!,
          words: all,
          progress: progress,
        ),
        _Mode.az => _alphabetical(all, progress),
        _Mode.favorites => _favorites(all, progress),
        _Mode.studying => _WordList(
          words: [
            for (final w in all)
              if ((progress[w.id]?.status ?? LearningStatus.fresh) !=
                  LearningStatus.fresh)
                w,
          ],
          progress: progress,
          empty: 'Пройдите первый урок — слова появятся здесь',
        ),
      };
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TealHeader(
              title: 'Сөздік',
              subtitle: '${all.length} слов · выучено $learned',
              bottomPadding: 20,
              actions: [
                IconButton(
                  tooltip: 'Добавить свои слова',
                  color: Colors.white,
                  onPressed: () => context.push('/import'),
                  icon: const Icon(Icons.playlist_add_rounded),
                ),
              ],
              bottom: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'По-русски или қазақша',
                      filled: true,
                      fillColor: context.colors.surface,
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Очистить',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: _search.clear,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final l in 'әғқңөұүһі'.split(''))
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Material(
                              color: Colors.white.withValues(alpha: .16),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _type(l),
                                child: SizedBox(
                                  height: 38,
                                  child: Center(
                                    child: Text(
                                      l,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (q.isEmpty)
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  children: [
                    for (final (m, label) in [
                      (_Mode.topics, 'Темы'),
                      (_Mode.az, 'А–Я'),
                      (_Mode.favorites, 'Избранное'),
                      (_Mode.studying, 'Изучаю'),
                    ]) ...[
                      ChoiceChip(
                        label: Text(label),
                        selected: _mode == m,
                        onSelected: (_) => setState(() => _mode = m),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  /// Puts a Kazakh letter at the cursor of the search field.
  void _type(String letter) {
    final v = _search.value;
    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: v.text.length);
    _search.value = TextEditingValue(
      text: v.text.replaceRange(sel.start, sel.end, letter),
      selection: TextSelection.collapsed(offset: sel.start + letter.length),
    );
  }

  /// The word itself (either language) starts with the query.
  static String w0(Word w) => '${normalizeForSearch(w.kk)}|${w.searchText}';

  Widget _favorites(List<Word> all, Map<int, WordProgressData> progress) {
    final favs = [
      for (final w in all)
        if (progress[w.id]?.isFavorite ?? false) w,
    ];
    return _WordList(
      words: favs,
      progress: progress,
      empty: 'Нажмите ☆ у слова, чтобы добавить его в избранное',
      header: favs.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton.icon(
                onPressed: () => context.push('/flashcards/favorites'),
                icon: const Icon(Icons.style_rounded),
                label: const Text('Карточки избранного'),
              ),
            ),
    );
  }

  Widget _alphabetical(List<Word> all, Map<int, WordProgressData> progress) {
    final alphabet = _byKazakh ? kazakhAlphabet : russianAlphabet;
    String key(Word w) => _byKazakh ? w.kk : w.ru;
    int rank(Word w) => switch (progress[w.id]?.status) {
      LearningStatus.learned => _sort == _Sort.learnedFirst ? 0 : 2,
      LearningStatus.learning => 1,
      _ => _sort == _Sort.learnedFirst ? 2 : 0,
    };
    final sorted = [...all]
      ..sort((a, b) {
        if (_sort != _Sort.alphabet) {
          final r = rank(a) - rank(b);
          if (r != 0) return r;
        }
        return compareIn(alphabet, key(a), key(b));
      });
    // First index of each letter, for the jump strip.
    final letters = <String, int>{};
    if (_sort == _Sort.alphabet) {
      for (final (i, w) in sorted.indexed) {
        if (firstLetter(alphabet, key(w)) case final l?) {
          letters.putIfAbsent(l, () => i);
        }
      }
    }
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
          child: Row(
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: true, label: Text('Қазақша')),
                  ButtonSegment(value: false, label: Text('По-русски')),
                ],
                selected: {_byKazakh},
                onSelectionChanged: (v) => setState(() => _byKazakh = v.first),
              ),
              const Spacer(),
              PopupMenuButton<_Sort>(
                tooltip: 'Сортировка',
                initialValue: _sort,
                icon: Icon(Icons.sort_rounded, color: c.accent),
                onSelected: (s) => setState(() => _sort = s),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _Sort.alphabet,
                    child: Text('По алфавиту'),
                  ),
                  PopupMenuItem(
                    value: _Sort.freshFirst,
                    child: Text('Сначала новые'),
                  ),
                  PopupMenuItem(
                    value: _Sort.learnedFirst,
                    child: Text('Сначала выученные'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (letters.isNotEmpty)
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                for (final MapEntry(key: l, value: i) in letters.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _list.jumpTo(
                          (i * wordTileExtent).clamp(
                            0,
                            _list.position.maxScrollExtent,
                          ),
                        ),
                        child: SizedBox(
                          width: 34,
                          child: Center(
                            child: Text(
                              l,
                              style: TextStyle(
                                color: c.accent,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: _WordList(
            words: sorted,
            progress: progress,
            controller: _list,
            empty: '',
          ),
        ),
      ],
    );
  }
}

/// A long list of words, built lazily.
class _WordList extends StatelessWidget {
  const _WordList({
    required this.words,
    required this.progress,
    required this.empty,
    this.header,
    this.controller,
  });

  final List<Word> words;
  final Map<int, WordProgressData> progress;
  final String empty;
  final Widget? header;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          empty,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colors.muted),
        ),
      );
    }
    return CustomScrollView(
      controller: controller,
      slivers: [
        if (header != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverToBoxAdapter(child: header),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          sliver: SliverFixedExtentList(
            itemExtent: wordTileExtent,
            delegate: SliverChildBuilderDelegate(
              (context, i) =>
                  WordTile(word: words[i], progress: progress[words[i].id]),
              childCount: words.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _Topics extends ConsumerWidget {
  const _Topics({
    required this.categories,
    required this.words,
    required this.progress,
  });

  final List<CategoryWithCount> categories;
  final List<Word> words;
  final Map<int, WordProgressData> progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final byId = {for (final x in categories) x.category.id: x};
    final learnedIn = <String, int>{};
    for (final w in words) {
      if (progress[w.id]?.status == LearningStatus.learned) {
        learnedIn[w.categoryId] = (learnedIn[w.categoryId] ?? 0) + 1;
      }
    }
    final today = wordOfDay(words, DateTime.now());
    final ownSets = [
      for (final x in categories)
        if (isOwnSet(x.category.id)) x,
    ];

    Widget grid(List<CategoryWithCount> list, Color color) => GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 128,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        for (final x in list)
          _TopicTile(
            category: x,
            learned: learnedIn[x.category.id] ?? 0,
            color: color,
          ),
      ],
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      children: [
        WordOfDayCard(word: today, onTap: () => showWordSheet(context, today)),
        for (final (i, s) in courseSections.indexed) ...[
          const SizedBox(height: 22),
          Semantics(
            header: true,
            label: 'Раздел ${i + 1}: ${s.title}',
            excludeSemantics: true,
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    s.titleKk,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          grid([for (final id in s.categoryIds) ?byId[id]], s.color),
        ],
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Свои слова',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            TextButton.icon(
              onPressed: () => createSetFlow(context, ref),
              icon: const Icon(Icons.create_new_folder_rounded),
              label: const Text('Новый набор'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (ownSets.isNotEmpty)
          grid(ownSets, c.goldText)
        else
          SurfaceCard(
            onTap: () => context.push('/import'),
            child: Row(
              children: [
                Icon(Icons.add_circle_rounded, color: c.accent, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Добавьте свои слова — вручную, списком или через '
                    'Telegram-бота',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.category,
    required this.learned,
    required this.color,
  });

  final CategoryWithCount category;
  final int learned;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cat = category.category;
    final total = category.wordCount;
    return Semantics(
      button: true,
      label: '${cat.titleKk}, ${cat.titleRu}: выучено $learned из $total',
      excludeSemantics: true,
      child: SurfaceCard(
        radius: 18,
        padding: const EdgeInsets.all(14),
        onTap: () => context.push('/dictionary/${cat.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(categoryIcon(cat.icon), color: color, size: 22),
            ),
            const Spacer(),
            Text(
              cat.titleRu,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            Text(
              '${cat.titleKk} · $learned из $total',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ProgressBar(
              value: total == 0 ? 0 : learned / total,
              height: 6,
              color: color,
            ),
          ],
        ),
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
    final isCustom = isOwnSet(categoryId);
    final cat = categories.value!
        .where((c) => c.category.id == categoryId)
        .firstOrNull
        ?.category;
    final list = words.value!.where((w) => w.categoryId == categoryId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final learned = list
        .where((w) => progress[w.id]?.status == LearningStatus.learned)
        .length;
    final c = context.colors;
    final color = isCustom
        ? context.colors.brand
        : sectionOfCategory(categoryId)?.color ?? context.colors.brand;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: TealHeader(
                color: color,
                leading: const BackButton(color: Colors.white),
                title: cat?.titleKk ?? 'Менің сөздерім',
                subtitle: [
                  // An own set has one name; don't print it twice.
                  if (cat == null || cat.titleRu != cat.titleKk)
                    cat?.titleRu ?? 'Мои слова',
                  '${list.length} слов',
                  'выучено $learned',
                ].join(' · '),
                actions: [
                  if (isCustom && cat != null) ...[
                    IconButton(
                      tooltip: 'Поделиться набором',
                      color: Colors.white,
                      onPressed: list.isEmpty
                          ? null
                          : () => shareSet(context, cat, list),
                      icon: const Icon(Icons.share_rounded),
                    ),
                    SetMenu(set: cat),
                  ],
                ],
                bottom: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.onGold,
                        ),
                        onPressed: list.isEmpty
                            ? null
                            : () => context.push('/flashcards/$categoryId'),
                        icon: const Icon(Icons.style_rounded),
                        label: const Text('Карточки'),
                      ),
                    ),
                    if (isCustom) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: context.colors.brand,
                          ),
                          onPressed: list.isEmpty
                              ? null
                              : () => context.push(
                                  '/practice/custom?set=$categoryId',
                                ),
                          icon: const Icon(Icons.fitness_center_rounded),
                          label: const Text('Тренировать'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'Добавить',
                        color: Colors.white,
                        onPressed: () =>
                            context.push('/import?set=$categoryId'),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isCustom && list.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Пока пусто. Добавьте слова вручную или пришлите их '
                    'Telegram-боту.',
                    style: TextStyle(color: c.muted),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              sliver: SliverList.builder(
                itemCount: list.length,
                itemBuilder: (context, i) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lesson boundaries, so the list matches the course.
                    if (!isCustom && i % lessonSize == 0)
                      Padding(
                        padding: EdgeInsets.only(
                          top: i == 0 ? 0 : 10,
                          bottom: 6,
                        ),
                        child: Text(
                          'УРОК ${i ~/ lessonSize + 1}',
                          style: TextStyle(
                            color: c.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    WordTile(word: list[i], progress: progress[list[i].id]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
