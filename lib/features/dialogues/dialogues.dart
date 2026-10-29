import 'dart:convert';

import '../../data/database/app_database.dart';
import '../grammar/grammar.dart';

/// A short everyday conversation with comprehension tasks.
class Dialogue {
  const Dialogue({
    required this.id,
    required this.title,
    required this.titleKk,
    required this.icon,
    required this.lines,
    required this.tasks,
  });

  final String id;
  final String title;
  final String titleKk;
  final String icon;

  /// Speaker, Kazakh line, Russian translation.
  final List<(String, String, String)> lines;
  final List<GrammarTask> tasks;

  /// Key of the dialogue's best score in the grammar progress table.
  String get progressKey => 'dlg:$id';
}

/// Parses assets/data/dialogues.json.
List<Dialogue> parseDialogues(String json) {
  final root = jsonDecode(json) as Map<String, dynamic>;
  return [
    for (final d in (root['dialogues'] as List).cast<Map<String, dynamic>>())
      Dialogue(
        id: d['id'] as String,
        title: d['title'] as String,
        titleKk: d['titleKk'] as String,
        icon: d['icon'] as String,
        lines: [
          for (final l in (d['lines'] as List).cast<List>())
            (l[0] as String, l[1] as String, l[2] as String),
        ],
        tasks: [
          for (final (i, t)
              in (d['tasks'] as List).cast<Map<String, dynamic>>().indexed)
            GrammarTask(
              ref: '${d['id']}#$i',
              question: t['q'] as String,
              hint: t['h'] as String,
              answer: t['a'] as String,
              wrong: (t['o'] as List).cast<String>(),
            ),
        ],
      ),
  ];
}

final _edges = RegExp(r'^[^\p{L}]+|[^\p{L}-]+$', unicode: true);

/// The dictionary word a token of running text comes from: the same word,
/// or the longest one it starts with (Kazakh adds endings: қалаға → қала).
/// Verbs are matched by their stem: барамын → бар- → бару.
Word? lookupWord(String token, List<Word> dictionary) {
  final t = token.toLowerCase().replaceAll(_edges, '');
  if (t.isEmpty) return null;
  Word? best;
  var bestLength = 0;
  var bestIsVerb = false;
  for (final w in dictionary) {
    final kk = w.kk.toLowerCase();
    if (kk.contains(' ')) continue;
    if (kk == t) return w;
    final isVerb = kk.endsWith('у') && kk.length > 3;
    for (final (stem, verb) in [
      (kk, false),
      if (isVerb) (kk.substring(0, kk.length - 1), true),
    ]) {
      // Verb endings are long (бар-амын), noun ones shorter (қала-ға).
      final enough = stem.length * (verb ? 3 : 2) >= t.length;
      if (stem.length < 3 || !t.startsWith(stem) || !enough) {
        continue;
      }
      // Longer match wins; on a tie, the verb (барамын: бару, not бар).
      if (stem.length > bestLength ||
          (stem.length == bestLength && verb && !bestIsVerb)) {
        best = w;
        bestLength = stem.length;
        bestIsVerb = verb;
      }
    }
  }
  return best;
}
