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
  });

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

  /// 1-based, across all groups.
  final int number;
  final String title;
  final String text;

  /// Forms and their meaning, two columns.
  final List<(String, String)> table;

  /// Kazakh sentence and its translation.
  final List<(String, String)> examples;
  final List<GrammarTask> tasks;
}

class GrammarGroup {
  const GrammarGroup({
    required this.id,
    required this.title,
    required this.titleKk,
    required this.rules,
  });

  final String id;
  final String title;
  final String titleKk;
  final List<GrammarRule> rules;
}

/// Parses assets/data/grammar.json.
List<GrammarGroup> parseGrammar(String json) {
  final root = jsonDecode(json) as Map<String, dynamic>;
  var number = 0;
  (String, String) pair(Object? row) {
    final r = row as List;
    return (r[0] as String, r[1] as String);
  }

  return [
    for (final g in (root['groups'] as List).cast<Map<String, dynamic>>())
      GrammarGroup(
        id: g['id'] as String,
        title: g['title'] as String,
        titleKk: g['titleKk'] as String,
        rules: [
          for (final r in (g['rules'] as List).cast<Map<String, dynamic>>())
            GrammarRule(
              id: r['id'] as String,
              number: ++number,
              title: r['title'] as String,
              text: r['text'] as String,
              table: [for (final row in r['table'] as List) pair(row)],
              examples: [for (final row in r['examples'] as List) pair(row)],
              tasks: [
                for (final t
                    in (r['tasks'] as List).cast<Map<String, dynamic>>())
                  GrammarTask(
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

/// XP for one right answer, and the bonus for a rule done without mistakes.
const grammarXpPerAnswer = 5;
const grammarPerfectBonus = 10;

/// A rule counts as learned from this score on (percent).
const grammarPassScore = 75;

/// Tasks in a group check-up.
const grammarGroupTestSize = 10;
