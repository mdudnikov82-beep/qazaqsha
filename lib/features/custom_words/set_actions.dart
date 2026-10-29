import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/custom_words_repository.dart';
import 'word_import.dart';

/// Asks for a name and opens the new set.
Future<void> createSetFlow(BuildContext context, WidgetRef ref) async {
  final name = await askSetName(context, title: 'Новый набор');
  if (name == null || !context.mounted) return;
  final id = await ref.read(customWordsRepositoryProvider).createSet(name);
  ref.invalidate(categoriesProvider);
  if (context.mounted) context.push('/dictionary/$id');
}

Future<String?> askSetName(
  BuildContext context, {
  required String title,
  String? initial,
}) => showDialog<String>(
  context: context,
  builder: (_) => _NameDialog(title: title, initial: initial),
);

/// A link that adds [words] as a set named like [set] — in the app or the
/// web version. Over [maxImportWords] words, only the first ones go.
String shareLink(Category set, List<Word> words) => webImportLink(
  encodeWords([
    for (final w in words.take(maxImportWords)) ImportedWord(w.kk, w.ru),
  ], title: set.titleRu),
);

Future<void> shareSet(
  BuildContext context,
  Category set,
  List<Word> words,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final link = shareLink(set, words);
  final cut = words.length > maxImportWords;
  final text =
      'Слова «${set.titleRu}» для Qazaqsha — изучения казахского: $link';
  try {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Qazaqsha: ${set.titleRu}'),
    );
  } catch (_) {
    // No share sheet (some desktop browsers): copy instead.
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(const SnackBar(content: Text('Ссылка скопирована')));
  }
  if (cut) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('В ссылку попали первые $maxImportWords слов набора.'),
      ),
    );
  }
}

/// ⋮ menu of an own set: rename, delete (the default set: empty).
class SetMenu extends ConsumerWidget {
  const SetMenu({super.key, required this.set});

  final Category set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDefault = set.id == customCategoryId;
    return PopupMenuButton<String>(
      tooltip: 'Ещё',
      iconColor: Colors.white,
      onSelected: (action) async {
        final repo = ref.read(customWordsRepositoryProvider);
        if (action == 'rename') {
          final name = await askSetName(
            context,
            title: 'Переименовать набор',
            initial: set.titleRu,
          );
          if (name == null) return;
          await repo.renameSet(set.id, name);
          ref.invalidate(categoriesProvider);
        } else if (action == 'delete') {
          final sure = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                isDefault ? 'Очистить «${set.titleRu}»?' : 'Удалить набор?',
              ),
              content: Text(
                'Слова набора «${set.titleRu}» и прогресс по ним удалятся. '
                'Это нельзя отменить.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB3261E),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(isDefault ? 'Очистить' : 'Удалить'),
                ),
              ],
            ),
          );
          if (sure != true) return;
          await repo.deleteSet(set.id);
          ref
            ..invalidate(allWordsProvider)
            ..invalidate(categoriesProvider);
          if (!isDefault && context.mounted) context.pop();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'rename', child: Text('Переименовать')),
        PopupMenuItem(
          value: 'delete',
          child: Text(isDefault ? 'Очистить набор' : 'Удалить набор'),
        ),
      ],
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, this.initial});

  final String title;
  final String? initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _name,
      autofocus: true,
      maxLength: maxSetTitle,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        hintText: 'например: Работа, Из сериала',
      ),
      onSubmitted: (v) => Navigator.pop(context, v),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _name.text),
        child: const Text('Готово'),
      ),
    ],
  );
}
