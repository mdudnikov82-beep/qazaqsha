import 'dart:convert';
import 'dart:math';

/// One exercise: a sentence with a gap (`___`), a Russian hint, the right
/// answer and three wrong ones.
class GrammarTask {
  const GrammarTask({
    required this.question,
    required this.hint,
    required this.answer,
    required this.wrong,
    this.ref = '',
  });

  /// `ruleId#index`, to find the task again (mistakes notebook).
  final String ref;

  /// The rule (or dialogue) the task belongs to.
  String get owner => ref.split('#').first;

  final String question;
  final String hint;
  final String answer;
  final List<String> wrong;

  /// The answer and the wrong options, shuffled.
  List<String> options(Random random) => [answer, ...wrong]..shuffle(random);

  /// The question with the answer put in, for the feedback.
  String get solved => question.contains('___')
      ? question.replaceFirst('___', answer)
      : '$question — $answer';
}

class GrammarRule {
  const GrammarRule({
    required this.id,
    required this.number,
    required this.title,
    required this.text,
    required this.table,
    required this.examples,
    required this.tasks,
  });

  final String id;

  /// 1-based, within its part (verbs, nouns…).
  final int number;
  final String title;
  final String text;

  /// Forms and their meaning, two columns.
  final List<(String, String)> table;

  /// Kazakh sentence and its translation.
  final List<(String, String)> examples;
  final List<GrammarTask> tasks;
}

/// Parts of speech the rules are grouped by.
const grammarParts = [
  (id: 'verbs', title: 'Глаголы', titleKk: 'Етістік'),
  (id: 'nouns', title: 'Существительные', titleKk: 'Зат есім'),
  (id: 'other', title: 'Другие', titleKk: 'Басқа сөз таптары'),
];

class GrammarGroup {
  const GrammarGroup({
    required this.id,
    required this.part,
    required this.title,
    required this.titleKk,
    required this.rules,
  });

  final String id;

  /// One of [grammarParts].
  final String part;
  final String title;
  final String titleKk;
  final List<GrammarRule> rules;
}

/// Parses assets/data/grammar.json.
List<GrammarGroup> parseGrammar(String json) {
  final root = jsonDecode(json) as Map<String, dynamic>;
  final numbers = <String, int>{};
  (String, String) pair(Object? row) {
    final r = row as List;
    return (r[0] as String, r[1] as String);
  }

  return [
    for (final g in (root['groups'] as List).cast<Map<String, dynamic>>())
      GrammarGroup(
        id: g['id'] as String,
        part: g['part'] as String? ?? 'verbs',
        title: g['title'] as String,
        titleKk: g['titleKk'] as String,
        rules: [
          for (final r in (g['rules'] as List).cast<Map<String, dynamic>>())
            GrammarRule(
              id: r['id'] as String,
              number: numbers.update(
                g['part'] as String? ?? 'verbs',
                (n) => n + 1,
                ifAbsent: () => 1,
              ),
              title: r['title'] as String,
              text: r['text'] as String,
              table: [for (final row in r['table'] as List) pair(row)],
              examples: [for (final row in r['examples'] as List) pair(row)],
              tasks: [
                for (final (i, t)
                    in (r['tasks'] as List)
                        .cast<Map<String, dynamic>>()
                        .indexed)
                  GrammarTask(
                    ref: '${r['id']}#$i',
                    question: t['q'] as String,
                    hint: t['h'] as String,
                    answer: t['a'] as String,
                    wrong: (t['o'] as List).cast<String>(),
                  ),
              ],
            ),
        ],
      ),
  ];
}

/// Rules of one part, in order.
List<GrammarRule> rulesOfPart(List<GrammarGroup> groups, String part) => [
  for (final g in groups)
    if (g.part == part) ...g.rules,
];

/// XP for one right answer, and the bonus for a rule done without mistakes.
const grammarXpPerAnswer = 5;
const grammarPerfectBonus = 10;

/// A rule counts as learned from this score on (percent).
const grammarPassScore = 75;

/// Tasks in a group check-up.
const grammarGroupTestSize = 10;
