enum TypedVerdict { correct, almost, wrong }

final _punctuation = RegExp(r'[?!.,…«»"()\-–—]');
final _spaces = RegExp(r'\s+');

/// Lowercase, ё→е, no punctuation, single spaces.
String normalizeAnswer(String s) => s
    .toLowerCase()
    .replaceAll('ё', 'е')
    .replaceAll(_punctuation, ' ')
    .replaceAll(_spaces, ' ')
    .trim();

/// Kazakh-only letters mapped to the Russian letters people type instead.
const _kazakhToRussian = {
  'ә': 'а',
  'ғ': 'г',
  'қ': 'к',
  'ң': 'н',
  'ө': 'о',
  'ұ': 'у',
  'ү': 'у',
  'һ': 'х',
  'і': 'и',
};

String _foldKazakh(String s) =>
    s.split('').map((ch) => _kazakhToRussian[ch] ?? ch).join();

/// `almost` = right word typed without the special Kazakh letters
/// (e.g. «журек» for «жүрек»). Still counted as a mistake, with a hint.
TypedVerdict checkTyped(String input, String expected) {
  final a = normalizeAnswer(input);
  final b = normalizeAnswer(expected);
  if (a.isEmpty) return TypedVerdict.wrong;
  if (a == b) return TypedVerdict.correct;
  if (_foldKazakh(a) == _foldKazakh(b)) return TypedVerdict.almost;
  return TypedVerdict.wrong;
}

final _edgePunctuation = RegExp(r'^[«"(]+|[.,!?…»")]+$');

/// Word tiles of a sentence: split on spaces, punctuation and lone dashes
/// dropped. «Көп рахмет, сау болыңыз!» → [Көп, рахмет, сау, болыңыз].
List<String> sentenceTokens(String sentence) => [
  for (final raw in sentence.split(_spaces))
    if (raw.replaceAll(_edgePunctuation, '') case final t
        when t.isNotEmpty && t != '—' && t != '–' && t != '-')
      t,
];

/// Whether the tiles in [built] spell [sentence] (case-insensitive).
bool checkSentence(List<String> built, String sentence) {
  final want = sentenceTokens(sentence).map(normalizeAnswer).toList();
  final got = built.map(normalizeAnswer).toList();
  if (want.length != got.length) return false;
  for (var i = 0; i < want.length; i++) {
    if (want[i] != got[i]) return false;
  }
  return true;
}

/// Words like «менің атым…» are phrase templates, not typeable answers.
bool isTypeable(String kk) => !kk.contains('…');
