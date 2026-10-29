import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/features/grammar/grammar.dart';

void main() {
  final groups = parseGrammar(
    File('assets/data/grammar.json').readAsStringSync(),
  );
  final rules = [for (final g in groups) ...g.rules];

  test('200 rules: 100 verbs, 50 nouns, 50 other; numbered per part', () {
    expect(groups, hasLength(20));
    expect(rules.map((r) => r.id).toSet(), hasLength(200));
    for (final (part, count) in [
      ('verbs', 100),
      ('nouns', 50),
      ('other', 50),
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
}
