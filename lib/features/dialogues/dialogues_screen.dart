import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/widgets/latin_line.dart';
import '../../core/widgets/teal_header.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../dictionary/word_sheet.dart';
import '../grammar/grammar.dart';
import 'dialogues.dart';

/// Everyday conversations to read, with comprehension tasks.
class DialoguesScreen extends ConsumerWidget {
  const DialoguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogues = ref.watch(dialoguesProvider);
    if (dialogues.value == null) {
      return LoadingScaffold(error: dialogues.error);
    }
    final done = ref.watch(grammarProgressProvider).value ?? const {};
    final c = context.colors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            TealHeader(
              leading: const BackButton(color: Colors.white),
              title: 'Диалогтар',
              subtitle: 'Диалоги · ${dialogues.value!.length}',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Живые разговоры из жизни. Нажмите на слово — увидите '
                    'перевод, на реплику — перевод всей фразы.',
                    style: TextStyle(color: c.muted),
                  ),
                  const SizedBox(height: 14),
                  for (final d in dialogues.value!) ...[
                    _DialogueTile(
                      dialogue: d,
                      score: done[d.progressKey]?.bestScore,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogueTile extends StatelessWidget {
  const _DialogueTile({required this.dialogue, required this.score});

  final Dialogue dialogue;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final passed = (score ?? 0) >= grammarPassScore;
    return SurfaceCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/dialogues/${dialogue.id}'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: passed ? c.okSoft : c.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              passed ? Icons.check_rounded : categoryIcon(dialogue.icon),
              color: passed ? c.okText : c.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dialogue.titleKk,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${dialogue.title} · ${dialogue.lines.length} реплик',
                  style: TextStyle(color: c.muted),
                ),
              ],
            ),
          ),
          if (score != null)
            Text(
              '$score%',
              style: TextStyle(
                color: passed ? c.okText : c.goldText,
                fontWeight: FontWeight.w900,
              ),
            )
          else
            Icon(Icons.chevron_right_rounded, color: c.muted),
        ],
      ),
    );
  }
}

/// One dialogue as chat bubbles.
class DialogueScreen extends ConsumerStatefulWidget {
  const DialogueScreen({super.key, required this.dialogueId});

  final String dialogueId;

  @override
  ConsumerState<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends ConsumerState<DialogueScreen> {
  bool _allTranslations = false;
  final _shown = <int>{};

  void _wordTapped(String token, List<Word> dictionary) {
    final word = lookupWord(token, dictionary);
    final c = context.colors;
    final clean = token.replaceAll(RegExp(r'[^\p{L}-]', unicode: true), '');
    if (word != null) {
      showWordSheet(context, word);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                clean,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Этого слова пока нет в словаре. Перевод всей реплики — '
                'нажмите на неё.',
                style: TextStyle(color: c.muted),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.of(sheet).pop();
                  context.push('/import');
                },
                icon: const Icon(Icons.playlist_add_rounded),
                label: const Text('Добавить в свои слова'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogues = ref.watch(dialoguesProvider).value;
    final dictionary = ref.watch(allWordsProvider).value;
    if (dialogues == null || dictionary == null) return const LoadingScaffold();
    final d = dialogues.where((x) => x.id == widget.dialogueId).firstOrNull;
    if (d == null) return const LoadingScaffold(error: 'Диалог не найден');
    final score = ref
        .watch(grammarProgressProvider)
        .value?[d.progressKey]
        ?.bestScore;
    final c = context.colors;
    final speakers = <String>[];
    for (final (s, _, _) in d.lines) {
      if (!speakers.contains(s)) speakers.add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(d.titleKk),
        actions: [
          IconButton(
            tooltip: _allTranslations ? 'Скрыть перевод' : 'Показать перевод',
            onPressed: () => setState(() {
              _allTranslations = !_allTranslations;
              _shown.clear();
            }),
            icon: Icon(
              _allTranslations
                  ? Icons.translate_rounded
                  : Icons.g_translate_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Text(
            d.title,
            style: TextStyle(color: c.muted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final (i, (speaker, kk, ru)) in d.lines.indexed)
            _Bubble(
              speaker: speaker,
              kk: kk,
              ru: ru,
              right: speakers.indexOf(speaker).isOdd,
              translated: _allTranslations || _shown.contains(i),
              onTap: () => setState(
                () => _shown.contains(i) ? _shown.remove(i) : _shown.add(i),
              ),
              onWord: (t) => _wordTapped(t, dictionary),
            ),
          const SizedBox(height: 16),
          GoldButton(
            label: score == null
                ? 'Проверить понимание · ${d.tasks.length} задания'
                : 'Ещё раз · лучший $score%',
            icon: Icons.quiz_rounded,
            onPressed: () => context.push('/dialogues/${d.id}/practice'),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.speaker,
    required this.kk,
    required this.ru,
    required this.right,
    required this.translated,
    required this.onTap,
    required this.onWord,
  });

  final String speaker;
  final String kk;
  final String ru;
  final bool right;
  final bool translated;
  final VoidCallback onTap;
  final ValueChanged<String> onWord;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = right ? context.colors.brand : c.surface;
    final fg = right ? Colors.white : c.ink;
    final muted = right ? context.colors.onBrandMuted : c.muted;
    return Align(
      alignment: right ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(right ? 18 : 4),
              bottomRight: Radius.circular(right ? 4 : 18),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      speaker,
                      style: TextStyle(
                        color: right ? AppColors.gold : c.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      children: [
                        for (final token in kk.split(' '))
                          GestureDetector(
                            onTap: () => onWord(token),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                token,
                                style: TextStyle(
                                  color: fg,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                  decorationColor: muted.withValues(alpha: 0.4),
                                  decorationStyle: TextDecorationStyle.dotted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    LatinLine(kk, fontSize: 13, color: muted),
                    if (translated) ...[
                      const SizedBox(height: 4),
                      Text(ru, style: TextStyle(color: muted)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
