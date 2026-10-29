import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/features/grammar/grammar.dart';

void main() {
  final groups = parseGrammar(
    File('assets/data/grammar.json').readAsStringSync(),
  );
  final rules = [for (final g in groups) ...g.rules];

  test('100 verb rules in 10 topics, numbered in order', () {
    expect(groups, hasLength(10));
    expect(rules, hasLength(100));
    expect(rules.map((r) => r.number), List.generate(100, (i) => i + 1));
    expect(rules.map((r) => r.id).toSet(), hasLength(100));
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
