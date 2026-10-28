import 'dart:convert';

import '../../core/kazakh_letters.dart';

/// A user's own word pair, before it is saved.
class ImportedWord {
  const ImportedWord(this.kk, this.ru);

  final String kk;
  final String ru;

  @override
  bool operator ==(Object other) =>
      other is ImportedWord && other.kk == kk && other.ru == ru;

  @override
  int get hashCode => Object.hash(kk, ru);

  @override
  String toString() => '$kk — $ru';
}

/// At most this many words per import, and this many characters per side.
const maxImportWords = 100;
const maxWordLength = 60;

const webImportBase = 'https://mdudnikov82-beep.github.io/qazaqsha/#/import';
const appImportBase = 'qazaqsha://app/import';

/// Packs words into a URL-safe code: base64url of `{"v":1,"w":[[kk,ru],…]}`,
/// without padding. The Telegram bot produces exactly this format.
String encodeWords(List<ImportedWord> words) => base64Url
    .encode(
      utf8.encode(
        jsonEncode({
          'v': 1,
          'w': [
            for (final w in words) [w.kk, w.ru],
          ],
        }),
      ),
    )
    .replaceAll('=', '');

String webImportLink(String code) => '$webImportBase?w=$code';
String appImportLink(String code) => '$appImportBase?w=$code';

/// Unpacks a code made by [encodeWords]; null if it isn't one.
List<ImportedWord>? decodeWords(String code) {
  try {
    final padded = code.padRight((code.length + 3) ~/ 4 * 4, '=');
    final data = jsonDecode(utf8.decode(base64Url.decode(padded)));
    if (data is! Map || data['w'] is! List) return null;
    return _clean([
      for (final pair in data['w'] as List)
        if (pair is List && pair.length >= 2)
          ImportedWord('${pair[0]}', '${pair[1]}'),
    ]);
  } on FormatException {
    return null;
  }
}

final _codeParam = RegExp(r'[?&]w=([A-Za-z0-9_-]+)');
final _bareCode = RegExp(r'^[A-Za-z0-9_-]{8,}$');

/// Reads whatever the user pasted: an import link, a bare code, or plain
/// lines like «сөз — слово».
List<ImportedWord> parseImport(String input) {
  final text = input.trim();
  final fromLink = _codeParam.firstMatch(text);
  if (fromLink != null) return decodeWords(fromLink.group(1)!) ?? const [];
  if (_bareCode.hasMatch(text)) {
    final decoded = decodeWords(text);
    if (decoded != null) return decoded;
  }
  return parseWordLines(text);
}

/// Separators between the two halves of a line: a dash with spaces around
/// it (so «ата-ана» stays whole), a tab, «=» or «:».
final _separator = RegExp(r'\s+[—–-]\s+|\t+|\s*=\s*|\s*:\s+');
final _listMarker = RegExp(r'^\s*(?:[-•*]|\d+[.)])\s*');

/// Parses one pair per line. Kazakh is expected first, but a line written
/// the other way round is flipped when only its second half has Kazakh
/// letters.
List<ImportedWord> parseWordLines(String text) {
  final words = <ImportedWord>[];
  for (final raw in const LineSplitter().convert(text)) {
    final line = raw.replaceFirst(_listMarker, '').trim();
    final parts = line.split(_separator);
    if (parts.length != 2) continue;
    var (kk, ru) = (parts[0].trim(), parts[1].trim());
    if (!hasKazakhLetters(kk) && hasKazakhLetters(ru)) (kk, ru) = (ru, kk);
    words.add(ImportedWord(kk, ru));
  }
  return _clean(words);
}

final _kazakhOnly = RegExp(
  '[${kazakhExtraLetters.join()}${kazakhExtraLetters.join().toUpperCase()}]',
);

bool hasKazakhLetters(String s) => _kazakhOnly.hasMatch(s);

/// Drops empty or overlong halves and duplicates, keeps the first
/// [maxImportWords].
List<ImportedWord> _clean(List<ImportedWord> words) {
  final seen = <ImportedWord>{};
  return [
    for (final w in words)
      if (w.kk.isNotEmpty &&
          w.ru.isNotEmpty &&
          w.kk.length <= maxWordLength &&
          w.ru.length <= maxWordLength &&
          seen.add(w))
        w,
  ].take(maxImportWords).toList();
}
