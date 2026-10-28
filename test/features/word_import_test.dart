import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/features/custom_words/word_import.dart';

void main() {
  const words = [
    ImportedWord('кітап', 'книга'),
    ImportedWord('жүрек', 'сердце'),
    ImportedWord('ата-ана', 'родители'),
  ];

  group('codes and links', () {
    test('a code round-trips Kazakh and Russian text', () {
      final code = encodeWords(words);
      expect(code, matches(RegExp(r'^[A-Za-z0-9_-]+$')), reason: 'URL-safe');
      expect(decodeWords(code), words);
    });

    test('links for the web and the app carry the same code', () {
      final code = encodeWords(words);
      expect(
        webImportLink(code),
        'https://mdudnikov82-beep.github.io/qazaqsha/#/import?w=$code',
      );
      expect(appImportLink(code), 'qazaqsha://app/import?w=$code');
      expect(parseImport(webImportLink(code)), words);
      expect(parseImport(appImportLink(code)), words);
      expect(parseImport('  $code\n'), words);
    });

    test('a damaged code gives nothing instead of crashing', () {
      expect(decodeWords('not-a-real-code'), isNull);
      expect(parseImport('https://x/#/import?w=AAAA'), isEmpty);
    });
  });

  group('plain text', () {
    test('understands common separators and list markers', () {
      const text = '''
кітап — книга
1. қалам - ручка
• дәптер – тетрадь
сабақ	урок
мектеп = школа
сынып: класс
''';
      expect(parseWordLines(text), const [
        ImportedWord('кітап', 'книга'),
        ImportedWord('қалам', 'ручка'),
        ImportedWord('дәптер', 'тетрадь'),
        ImportedWord('сабақ', 'урок'),
        ImportedWord('мектеп', 'школа'),
        ImportedWord('сынып', 'класс'),
      ]);
    });

    test('keeps hyphenated words whole', () {
      expect(parseWordLines('ата-ана — родители'), const [
        ImportedWord('ата-ана', 'родители'),
      ]);
    });

    test('flips lines written Russian first when the Kazakh is clear', () {
      expect(parseWordLines('сердце — жүрек'), const [
        ImportedWord('жүрек', 'сердце'),
      ]);
      // No Kazakh-only letters on either side: keep the documented order.
      expect(parseWordLines('бала — ребёнок'), const [
        ImportedWord('бала', 'ребёнок'),
      ]);
    });

    test('skips junk, duplicates and overlong lines; caps the count', () {
      final long = 'а' * (maxWordLength + 1);
      expect(
        parseWordLines('просто текст\nкітап — книга\nкітап — книга\n$long — x'),
        const [ImportedWord('кітап', 'книга')],
      );
      final many = [for (var i = 0; i < 150; i++) 'сөз$i — слово$i'].join('\n');
      expect(parseWordLines(many), hasLength(maxImportWords));
    });
  });
}
