import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/kazakh_letters.dart';
import '../../core/widgets/common.dart';
import '../../data/database/app_database.dart';
import 'answer_check.dart';
import 'questions.dart';

class _Prompt extends StatelessWidget {
  const _Prompt({required this.task, required this.label, required this.text});

  final String task;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          task,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: c.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class IntroView extends StatelessWidget {
  const IntroView({super.key, required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Новое слово',
          style: TextStyle(
            color: c.accent,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          radius: 24,
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Text(
                word.kk,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.ru,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted, fontSize: 20),
              ),
              if (word.note case final note?) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.goldSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(note, textAlign: TextAlign.center),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ChoiceView extends StatelessWidget {
  const ChoiceView({
    super.key,
    required this.question,
    required this.picked,
    required this.onPick,
  });

  final ChoiceQuestion question;
  final int? picked;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final q = question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Prompt(
          task: 'Выберите перевод',
          label: q.fromRussian ? 'по-русски' : 'по-казахски',
          text: q.prompt,
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.1,
          children: [
            for (final (i, text) in q.options.indexed)
              () {
                final answered = picked != null;
                final isAnswer = i == q.correctIndex;
                var bg = c.surface, border = c.line, fg = c.ink;
                IconData? icon;
                if (answered && isAnswer) {
                  (bg, border, fg, icon) = (
                    c.okSoft,
                    c.ok,
                    c.okText,
                    Icons.check_rounded,
                  );
                } else if (answered && i == picked) {
                  (bg, border, fg, icon) = (
                    c.badSoft,
                    c.bad,
                    c.badText,
                    Icons.close_rounded,
                  );
                }
                return Material(
                  color: bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: border, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: answered ? null : () => onPick(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: fg, size: 20),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fg,
                                fontSize: text.length > 14 ? 16 : 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }(),
          ],
        ),
      ],
    );
  }
}

class TypeView extends StatelessWidget {
  const TypeView({
    super.key,
    required this.question,
    required this.controller,
    required this.verdict,
    required this.onSubmit,
  });

  final TypeQuestion question;
  final TextEditingController controller;
  final TypedVerdict? verdict;
  final VoidCallback onSubmit;

  void _insert(String letter) {
    final v = controller.value;
    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: v.text.length);
    final text = v.text.replaceRange(sel.start, sel.end, letter);
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: sel.start + letter.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = verdict != null;
    final borderColor = switch (verdict) {
      null => c.sky,
      TypedVerdict.correct => c.ok,
      _ => c.bad,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Prompt(
          task: 'Напишите по-казахски',
          label: 'по-русски',
          text: question.word.ru,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          enabled: !done,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            labelText: 'Ваш ответ',
            hintText: 'Введите слово',
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final letter in kazakhExtraLetters)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Material(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: done ? null : () => _insert(letter),
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: Text(
                            letter,
                            semanticsLabel: 'Буква $letter',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: c.accent,
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
    );
  }
}

/// Tap word tiles in order to build the Kazakh sentence. Tapping a placed
/// tile puts it back.
class SentenceView extends StatelessWidget {
  const SentenceView({
    super.key,
    required this.question,
    required this.built,
    required this.locked,
    required this.onAdd,
    required this.onRemove,
  });

  final SentenceQuestion question;

  /// Indices into [SentenceQuestion.tiles], in the order they were placed.
  final List<int> built;
  final bool locked;
  final ValueChanged<int> onAdd;

  /// Receives the position inside [built] to take back.
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tiles = question.tiles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Prompt(
          task: 'Соберите предложение',
          label: 'по-русски',
          text: question.sentence.ru,
        ),
        const SizedBox(height: 20),
        Semantics(
          label: 'Ваш ответ',
          child: Container(
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: c.line, width: 2),
                top: BorderSide(color: c.line, width: 2),
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (pos, i) in built.indexed)
                  _WordTile(
                    text: tiles[i],
                    onTap: locked ? null : () => onRemove(pos),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: [
            for (final (i, text) in tiles.indexed)
              built.contains(i)
                  // Keep the slot so the bank does not jump around.
                  ? _WordTile(text: text, placeholder: true)
                  : _WordTile(
                      text: text,
                      onTap: locked ? null : () => onAdd(i),
                    ),
          ],
        ),
      ],
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({required this.text, this.onTap, this.placeholder = false});

  final String text;
  final VoidCallback? onTap;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: placeholder ? Colors.transparent : c.ink,
        ),
      ),
    );
    if (placeholder) {
      return ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: c.track,
            borderRadius: BorderRadius.circular(12),
          ),
          child: label,
        ),
      );
    }
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.line, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: label),
    );
  }
}

/// Tap a Russian word, then its Kazakh pair. Reports words that were
/// mismatched at least once via [onComplete].
class MatchView extends StatefulWidget {
  const MatchView({
    super.key,
    required this.question,
    required this.onComplete,
  });

  final MatchQuestion question;
  final ValueChanged<Set<int>> onComplete;

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  late final List<Word> _left = widget.question.pairs;
  late final List<Word> _right = [...widget.question.pairs]..shuffle();
  final Set<int> _matched = {};
  final Set<int> _mistakes = {};
  int? _selectedLeft;
  int? _wrongRight;

  void _tapRight(Word w) {
    final left = _selectedLeft;
    if (left == null) return;
    if (left == w.id) {
      setState(() {
        _matched.add(w.id);
        _selectedLeft = null;
        _wrongRight = null;
      });
      if (_matched.length == _left.length) widget.onComplete(_mistakes);
    } else {
      setState(() {
        _mistakes.add(left);
        _wrongRight = w.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Соедините пары',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (final w in _left)
                    _MatchTile(
                      text: w.ru,
                      matched: _matched.contains(w.id),
                      selected: _selectedLeft == w.id,
                      wrong: false,
                      onTap: () => setState(() {
                        _selectedLeft = w.id;
                        _wrongRight = null;
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  for (final w in _right)
                    _MatchTile(
                      text: w.kk,
                      matched: _matched.contains(w.id),
                      selected: false,
                      wrong: _wrongRight == w.id,
                      onTap: () => _tapRight(w),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.text,
    required this.matched,
    required this.selected,
    required this.wrong,
    required this.onTap,
  });

  final String text;
  final bool matched;
  final bool selected;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, border, fg) = matched
        ? (c.okSoft, c.okSoft, c.okText)
        : wrong
        ? (c.badSoft, c.bad, c.badText)
        : selected
        ? (c.accentSoft, c.sky, c.accent)
        : (c.surface, c.line, c.ink);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: matched ? null : onTap,
          child: SizedBox(
            height: 56,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
