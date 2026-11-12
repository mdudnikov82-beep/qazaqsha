import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/app/theme.dart';
import 'package:qazaqsha/features/grammar/rules_screen.dart';
import 'package:qazaqsha/features/grammar/grammar.dart';

void main() {
  test('every exercise works as «find the mistake» with each wrong option', () {
    final groups = parseGrammar(
      File('assets/data/grammar.json').readAsStringSync(),
    );
    var count = 0;
    final gapless = <String>[];
    for (final g in groups) {
      for (final r in g.rules) {
        // Questions without a gap («Сколько падежей?») stay as choices.
        // Only the word-order rules have no gaps at all.
        final gapped = r.tasks.where(
          (t) => '___'.allMatches(t.question).length == 1,
        );
        if (gapped.isEmpty) gapless.add(r.id);
        for (final t in r.tasks) {
          if (!gapped.contains(t)) {
            expect(grammarFix(t, t.wrong.first), isNull);
            continue;
          }
          for (final w in t.wrong) {
            final f = grammarFix(t, w);
            expect(f, isNotNull, reason: t.question);
            count++;
            // Putting the right word back gives the solved sentence, and
            // the shown word really differs from it.
            final fixed = [...f!.tokens]..[f.at] = f.right;
            expect(fixed.join(' '), t.solved, reason: t.question);
            expect(
              f.tokens[f.at].toLowerCase(),
              isNot(f.right.toLowerCase()),
              reason: t.question,
            );
          }
        }
      }
    }
    expect(count, (1400 - 27) * 3);
    expect(gapless, ['w001', 'w003', 'w004']);
  });

  final groups = parseGrammar(
    File('assets/data/grammar.json').readAsStringSync(),
  );
  final rules = [for (final g in groups) ...g.rules];

  test('350 rules: 150 verbs, 90 nouns, 110 other; numbered per part', () {
    expect(groups, hasLength(35));
    expect(rules.map((r) => r.id).toSet(), hasLength(350));
    for (final (part, count) in [
      ('verbs', 150),
      ('nouns', 90),
      ('other', 110),
    ]) {
      final own = rulesOfPart(groups, part);
      expect(own, hasLength(count), reason: part);
      expect(own.map((r) => r.number), List.generate(count, (i) => i + 1));
    }
    expect(
      {for (final g in groups) g.part},
      {for (final p in grammarParts) p.id},
    );
  });

  test('every rule explains, shows examples and has 4 sound tasks', () {
    for (final r in rules) {
      expect(r.text, isNotEmpty, reason: r.id);
      expect(r.examples.length, greaterThanOrEqualTo(3), reason: r.id);
      expect(r.tasks, hasLength(4), reason: r.id);
      for (final t in r.tasks) {
        expect(t.wrong, hasLength(3), reason: '${r.id}: ${t.question}');
        expect(t.wrong, isNot(contains(t.answer)), reason: r.id);
        expect(t.wrong.toSet(), hasLength(3), reason: r.id);
      }
    }
  });

  test('options hold the answer once; the gap is filled for feedback', () {
    final t = rules.first.tasks.first;
    final options = t.options(Random(1));
    expect(options.where((o) => o == t.answer), hasLength(1));
    expect(options, hasLength(4));
    const gap = GrammarTask(
      question: 'Мен ___.',
      hint: '',
      answer: 'барамын',
      wrong: ['a', 'b', 'c'],
    );
    expect(gap.solved, 'Мен барамын.');
  });

  test('a derived form highlights just the added ending', () {
    final span = formSpan(
      'кітап → кітаптар',
      const Color(0xFF00789A),
      AppColors.light,
    );
    final parts = [for (final c in span.children!) (c as TextSpan).text];
    expect(parts, ['кітап → ', 'кітап', 'тар']);
    // A form without an arrow stays whole.
    expect(
      formSpan('бару', const Color(0xFF00789A), AppColors.light).text,
      'бару',
    );
  });
}
