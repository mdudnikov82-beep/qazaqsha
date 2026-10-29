import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/kazakh_letters.dart';
import '../../core/widgets/common.dart';
import '../../data/database/app_database.dart';
import '../../data/database/seed.dart';
import '../../data/providers.dart';
import '../../data/repositories/custom_words_repository.dart';
import 'word_import.dart';

/// Dropdown value for "make a new set".
const _newSet = '__new__';

/// Adds the user's own words: one by one, or from a pasted list, an import
/// code or a link (as sent by the Telegram bot or shared by a friend).
/// [code] comes from a link; [setId] preselects the set to add to.
class ImportWordsScreen extends ConsumerStatefulWidget {
  const ImportWordsScreen({super.key, this.code, this.setId});

  final String? code;
  final String? setId;

  @override
  ConsumerState<ImportWordsScreen> createState() => _ImportWordsScreenState();
}

/// A pasted pair in the preview: can be switched off or corrected.
class _Row {
  _Row(this.word, {required this.known}) : on = !known;

  ImportedWord word;

  /// The pair is already in the dictionary; adding it would do nothing.
  bool known;
  bool on;
}

class _ImportWordsScreenState extends ConsumerState<ImportWordsScreen> {
  final _kk = TextEditingController();
  final _ru = TextEditingController();
  final _note = TextEditingController();
  final _paste = TextEditingController();
  final _newSetName = TextEditingController();
  List<_Row>? _rows;
  bool _busy = false;
  late String _target = widget.setId ?? customCategoryId;

  /// Name a shared link came with; the words go to a new set by that name.
  String? _sharedTitle;

  @override
  void initState() {
    super.initState();
    for (final c in [_kk, _ru, _note, _paste, _newSetName]) {
      c.addListener(() => setState(() {}));
    }
    if (widget.code case final code?) {
      final set = decodeWordSet(code);
      _sharedTitle = set?.title;
      if (_sharedTitle != null && widget.setId == null) {
        _target = _newSet;
        _newSetName.text = _sharedTitle!;
      }
      // Rows need the dictionary; built on the first frame that has it.
      _pending = set?.words ?? const [];
    }
  }

  List<ImportedWord>? _pending;

  @override
  void dispose() {
    for (final c in [_kk, _ru, _note, _paste, _newSetName]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Pairs as the user meant them: a pair the dictionary knows the other
  /// way round is turned around.
  List<_Row> _rowsFor(List<ImportedWord> words, List<Word> dictionary) {
    final known = {for (final w in dictionary) (w.kk, w.ru)};
    return [
      for (final w in words)
        if (known.contains((w.ru, w.kk)) && !known.contains((w.kk, w.ru)))
          _Row(ImportedWord(w.ru, w.kk), known: true)
        else
          _Row(w, known: known.contains((w.kk, w.ru))),
    ];
  }

  Future<String> _resolveTarget() async {
    if (_target != _newSet) return _target;
    final id = await ref
        .read(customWordsRepositoryProvider)
        .createSet(_newSetName.text);
    setState(() => _target = id);
    return id;
  }

  Future<void> _save(List<ImportedWord> words, {String? note}) async {
    setState(() => _busy = true);
    final repo = ref.read(customWordsRepositoryProvider);
    final setId = await _resolveTarget();
    final result = await repo.addWords(words, setId: setId);
    if (note != null && note.trim().isNotEmpty && result.added == 1) {
      final added = (await repo.words(setId)).last;
      await repo.updateWord(added.id, kk: added.kk, ru: added.ru, note: note);
    }
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
    await _save([w], note: _note.text);
    _kk.clear();
    _ru.clear();
    _note.clear();
  }

  Future<void> _addRows() async {
    final words = [
      for (final r in _rows!)
        if (r.on) r.word,
    ];
    await _save(words);
    if (!mounted) return;
    final setId = _target;
    setState(() {
      _rows = null;
      _paste.clear();
    });
    context.go('/dictionary/$setId');
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

  Future<void> _editRow(_Row row, List<Word> dictionary) async {
    final result = await showDialog<EditedPair>(
      context: context,
      builder: (_) => PairDialog(initial: row.word),
    );
    if (result == null) return;
    final edited = result.word;
    setState(() {
      row.word = edited;
      row.known = dictionary.any((w) => w.kk == edited.kk && w.ru == edited.ru);
      row.on = !row.known;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dictionary = ref.watch(allWordsProvider).value;
    final categories = ref.watch(categoriesProvider).value;
    if (dictionary == null || categories == null) {
      return const LoadingScaffold();
    }
    if (_pending case final pending?) {
      _rows = _rowsFor(pending, dictionary);
      _pending = null;
    }
    final sets = [
      for (final x in categories)
        if (isOwnSet(x.category.id)) x.category,
    ];
    final code = widget.code;
    final rows = _rows;

    return Scaffold(
      appBar: AppBar(title: const Text('Добавить слова')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _SetPicker(
            sets: sets,
            value: _target,
            newSetName: _newSetName,
            onChanged: (v) => setState(() => _target = v),
          ),
          const SizedBox(height: 20),
          if (rows != null) ...[
            _Preview(
              rows: rows,
              title: _sharedTitle,
              busy: _busy,
              onToggle: (r, on) => setState(() => r.on = on),
              onEdit: (r) => _editRow(r, dictionary),
              onSwapAll: () => setState(() {
                _rows = _rowsFor([
                  for (final r in rows) ImportedWord(r.word.ru, r.word.kk),
                ], dictionary);
              }),
              onAdd: rows.any((r) => r.on) ? _addRows : null,
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
            const SizedBox(height: 28),
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
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'Пояснение (необязательно)',
              hintText: 'например: вежливо, к старшим',
            ),
            onSubmitted: (_) => _addOne(),
          ),
          _Suggestions(
            kk: _kk.text,
            ru: _ru.text,
            dictionary: dictionary,
            onUse: (w) => setState(() {
              _kk.text = w.kk;
              _ru.text = w.ru;
            }),
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
            'По одной паре на строке: «сөз — слово», «сөз = слово» или через '
            'табуляцию. Порядок языков неважен. Подойдёт и ссылка от '
            'Telegram-бота или друга.',
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
                : () {
                    final set = parseImportSet(_paste.text);
                    setState(() {
                      _rows = _rowsFor(set.words, dictionary);
                      if (set.title != null) {
                        _sharedTitle = set.title;
                        _target = _newSet;
                        _newSetName.text = set.title!;
                      }
                    });
                  },
            child: const Text('Показать слова'),
          ),
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

class _SetPicker extends StatelessWidget {
  const _SetPicker({
    required this.sets,
    required this.value,
    required this.newSetName,
    required this.onChanged,
  });

  final List<Category> sets;
  final String value;
  final TextEditingController newSetName;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ids = {for (final s in sets) s.id};
    // The default set may not exist yet; it is created on the first word.
    final items = [
      if (!ids.contains(customCategoryId))
        const DropdownMenuItem(
          value: customCategoryId,
          child: Text('Мои слова'),
        ),
      for (final s in sets)
        DropdownMenuItem(value: s.id, child: Text(s.titleRu)),
      const DropdownMenuItem(value: _newSet, child: Text('＋ Новый набор…')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: items.any((i) => i.value == value)
              ? value
              : customCategoryId,
          decoration: const InputDecoration(
            labelText: 'Куда добавить',
            prefixIcon: Icon(Icons.folder_rounded),
          ),
          items: items,
          onChanged: (v) => onChanged(v ?? customCategoryId),
        ),
        if (value == _newSet) ...[
          const SizedBox(height: 10),
          TextField(
            controller: newSetName,
            maxLength: maxSetTitle,
            decoration: const InputDecoration(
              labelText: 'Название набора',
              hintText: 'например: Работа, Из сериала',
            ),
          ),
        ],
      ],
    );
  }
}

/// Words from the dictionary that match what is being typed, so nobody
/// adds what the app already teaches.
class _Suggestions extends ConsumerWidget {
  const _Suggestions({
    required this.kk,
    required this.ru,
    required this.dictionary,
    required this.onUse,
  });

  final String kk;
  final String ru;
  final List<Word> dictionary;
  final ValueChanged<Word> onUse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final k = normalizeForSearch(kk);
    final r = normalizeForSearch(ru);
    if (k.length < 2 && r.length < 2) return const SizedBox.shrink();
    int score(Word w) {
      final wk = normalizeForSearch(w.kk);
      final wr = normalizeForSearch(w.ru);
      if ((k.isNotEmpty && wk == k) || (r.isNotEmpty && wr == r)) return 0;
      if ((k.length >= 2 && wk.startsWith(k)) ||
          (r.length >= 2 && wr.startsWith(r))) {
        return 1;
      }
      if ((k.length >= 3 && wk.contains(k)) ||
          (r.length >= 3 && wr.contains(r))) {
        return 2;
      }
      return 3;
    }

    final found = [
      for (final w in dictionary)
        if (score(w) < 3) w,
    ]..sort((a, b) => score(a) - score(b));
    if (found.isEmpty) return const SizedBox.shrink();
    final exact = score(found.first) == 0;
    final progress = ref.watch(progressMapProvider).value ?? const {};

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SurfaceCard(
        color: exact ? c.goldSoft : c.accentSoft,
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              exact
                  ? 'Это слово уже есть в словаре. Отметьте ☆ — и тренируйте '
                        'его в «Повторение → Избранное».'
                  : 'Похожие слова в словаре',
              style: TextStyle(
                color: exact ? c.goldText : c.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            for (final w in found.take(4))
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => onUse(w),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: w.kk,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: ' — ${w.ru}',
                                style: TextStyle(color: c.muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'В избранное',
                    onPressed: () => ref
                        .read(progressRepositoryProvider)
                        .toggleFavorite(w.id),
                    icon: Icon(
                      progress[w.id]?.isFavorite ?? false
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: c.goldText,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.rows,
    required this.title,
    required this.busy,
    required this.onToggle,
    required this.onEdit,
    required this.onSwapAll,
    required this.onAdd,
  });

  final List<_Row> rows;
  final String? title;
  final bool busy;
  final void Function(_Row row, bool on) onToggle;
  final ValueChanged<_Row> onEdit;
  final VoidCallback onSwapAll;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (rows.isEmpty) {
      return SurfaceCard(
        color: c.badSoft,
        child: Text(
          'Не нашёл ни одной пары. Проверьте, что между словами стоит '
          'тире с пробелами: «сөз — слово». Если это ссылка — она '
          'повреждена или устарела.',
          style: TextStyle(color: c.badText, fontWeight: FontWeight.w700),
        ),
      );
    }
    final selected = rows.where((r) => r.on).length;
    final known = rows.where((r) => r.known).length;
    return SurfaceCard(
      color: c.accentSoft,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title == null ? 'Найдено пар: ${rows.length}' : '«$title»',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onSwapAll,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Поменять'),
              ),
            ],
          ),
          if (known > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: Text(
                'Уже в словаре: $known — они выключены.',
                style: TextStyle(color: c.muted),
              ),
            ),
          for (final r in rows)
            Row(
              children: [
                Checkbox(
                  value: r.on,
                  onChanged: r.known ? null : (v) => onToggle(r, v ?? false),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: r.word.kk,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        TextSpan(
                          text: ' — ${r.word.ru}',
                          style: TextStyle(color: c.muted),
                        ),
                        if (r.known)
                          TextSpan(
                            text: '  · есть в словаре',
                            style: TextStyle(
                              color: c.goldText,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Исправить',
                  onPressed: () => onEdit(r),
                  icon: Icon(Icons.edit_rounded, color: c.accent, size: 20),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: busy ? null : onAdd,
              child: Text('Добавить $selected'),
            ),
          ),
        ],
      ),
    );
  }
}

/// What [PairDialog] returns.
typedef EditedPair = ({ImportedWord word, String note});

/// Edits a Kazakh–Russian pair (and, for saved words, the note).
class PairDialog extends StatefulWidget {
  const PairDialog({super.key, required this.initial, this.note});

  final ImportedWord initial;

  /// Shown as a third field when not null.
  final String? note;

  @override
  State<PairDialog> createState() => _PairDialogState();
}

class _PairDialogState extends State<PairDialog> {
  late final _kk = TextEditingController(text: widget.initial.kk);
  late final _ru = TextEditingController(text: widget.initial.ru);
  late final _note = TextEditingController(text: widget.note);

  @override
  void dispose() {
    _kk.dispose();
    _ru.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Исправить слово'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _kk,
          maxLength: maxWordLength,
          decoration: const InputDecoration(labelText: 'Қазақша'),
        ),
        TextField(
          controller: _ru,
          maxLength: maxWordLength,
          decoration: const InputDecoration(labelText: 'По-русски'),
        ),
        if (widget.note != null)
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'Пояснение'),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(
        onPressed: () {
          final kk = _kk.text.trim();
          final ru = _ru.text.trim();
          if (kk.isEmpty || ru.isEmpty) return;
          Navigator.pop<EditedPair>(context, (
            word: ImportedWord(kk, ru),
            note: _note.text,
          ));
        },
        child: const Text('Готово'),
      ),
    ],
  );
}
