import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/kazakh_letters.dart';
import '../../core/widgets/common.dart';
import '../../data/providers.dart';
import '../../data/repositories/custom_words_repository.dart';
import 'word_import.dart';

/// Adds the user's own words: one by one, or from a pasted list, an import
/// code or a link (as sent by the Telegram bot). [code] comes from a link.
class ImportWordsScreen extends ConsumerStatefulWidget {
  const ImportWordsScreen({super.key, this.code});

  final String? code;

  @override
  ConsumerState<ImportWordsScreen> createState() => _ImportWordsScreenState();
}

class _ImportWordsScreenState extends ConsumerState<ImportWordsScreen> {
  final _kk = TextEditingController();
  final _ru = TextEditingController();
  final _paste = TextEditingController();
  List<ImportedWord> _preview = const [];
  bool _pasteTried = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_kk, _ru, _paste]) {
      c.addListener(() => setState(() {}));
    }
    if (widget.code case final code?) {
      _preview = decodeWords(code) ?? const [];
      _pasteTried = true;
    }
  }

  @override
  void dispose() {
    for (final c in [_kk, _ru, _paste]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(List<ImportedWord> words) async {
    setState(() => _busy = true);
    final result = await ref
        .read(customWordsRepositoryProvider)
        .addWords(words);
    // The word list is cached; reload it so the new words show up.
    ref
      ..invalidate(allWordsProvider)
      ..invalidate(categoriesProvider);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.skipped == 0
              ? 'Добавлено слов: ${result.added}'
              : 'Добавлено: ${result.added}, уже были в словаре: ${result.skipped}',
        ),
      ),
    );
  }

  Future<void> _addOne() async {
    final w = ImportedWord(_kk.text.trim(), _ru.text.trim());
    if (w.kk.isEmpty || w.ru.isEmpty) return;
    await _save([w]);
    _kk.clear();
    _ru.clear();
  }

  Future<void> _addPreview() async {
    await _save(_preview);
    if (!mounted) return;
    setState(() {
      _preview = const [];
      _paste.clear();
      _pasteTried = false;
    });
    context.go('/dictionary/$customCategoryId');
  }

  void _insertLetter(String letter) {
    final v = _kk.value;
    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: v.text.length);
    _kk.value = TextEditingValue(
      text: v.text.replaceRange(sel.start, sel.end, letter),
      selection: TextSelection.collapsed(offset: sel.start + letter.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final code = widget.code;
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить слова')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          if (_preview.isNotEmpty || (_pasteTried && code != null)) ...[
            _PreviewCard(
              words: _preview,
              busy: _busy,
              onAdd: _preview.isEmpty ? null : _addPreview,
            ),
            // In a phone browser, offer to hand the same words to the app.
            if (kIsWeb && code != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => launchUrl(Uri.parse(appImportLink(code))),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Открыть в приложении Qazaqsha для Android'),
              ),
            ],
            const SizedBox(height: 24),
          ],
          const _Heading('Одно слово'),
          TextField(
            controller: _kk,
            decoration: const InputDecoration(labelText: 'Қазақша'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final l in kazakhExtraLetters)
                ActionChip(
                  label: Text(l, style: TextStyle(color: c.accent)),
                  tooltip: 'Вставить букву $l',
                  onPressed: () => _insertLetter(l),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ru,
            decoration: const InputDecoration(labelText: 'По-русски'),
            onSubmitted: (_) => _addOne(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed:
                _busy || _kk.text.trim().isEmpty || _ru.text.trim().isEmpty
                ? null
                : _addOne,
            child: const Text('Добавить слово'),
          ),
          const SizedBox(height: 32),
          const _Heading('Список, ссылка или код'),
          Text(
            'По одной паре на строке: «сөз — слово». Подойдёт и ссылка или '
            'код от Telegram-бота.',
            style: TextStyle(color: c.muted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _paste,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'кітап — книга\nқалам — ручка',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: _paste.text.trim().isEmpty
                ? null
                : () => setState(() {
                    _preview = parseImport(_paste.text);
                    _pasteTried = true;
                  }),
            child: const Text('Показать слова'),
          ),
          if (_pasteTried && _preview.isEmpty && code == null) ...[
            const SizedBox(height: 12),
            Text(
              'Не нашёл ни одной пары. Проверьте, что между словами стоит '
              'тире с пробелами: «сөз — слово».',
              style: TextStyle(color: c.badText),
            ),
          ],
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    ),
  );
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.words,
    required this.busy,
    required this.onAdd,
  });

  final List<ImportedWord> words;
  final bool busy;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (words.isEmpty) {
      return SurfaceCard(
        color: c.badSoft,
        child: Text(
          'Ссылка повреждена или устарела: слов в ней не нашлось.',
          style: TextStyle(color: c.badText, fontWeight: FontWeight.w700),
        ),
      );
    }
    return SurfaceCard(
      color: c.accentSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Новые слова: ${words.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final w in words.take(30))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: w.kk,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                      text: ' — ${w.ru}',
                      style: TextStyle(color: c.muted),
                    ),
                  ],
                ),
              ),
            ),
          if (words.length > 30)
            Text(
              '…и ещё ${words.length - 30}',
              style: TextStyle(color: c.muted),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: busy ? null : onAdd,
            child: Text('Добавить ${words.length} в «Мои слова»'),
          ),
        ],
      ),
    );
  }
}
