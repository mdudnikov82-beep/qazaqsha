import 'dart:convert';

/// Normalizes text for search: lowercase, ё→е, trimmed.
String normalizeForSearch(String s) =>
    s.toLowerCase().replaceAll('ё', 'е').trim();

class SeedWord {
  const SeedWord(this.ru, this.kk, this.note);

  final String ru;
  final String kk;
  final String? note;
}

class SeedCategory {
  const SeedCategory({
    required this.id,
    required this.ru,
    required this.kk,
    required this.icon,
    required this.words,
  });

  final String id;
  final String ru;
  final String kk;
  final String icon;
  final List<SeedWord> words;
}

class SeedSentence {
  const SeedSentence(this.categoryId, this.ru, this.kk);

  final String categoryId;
  final String ru;
  final String kk;
}

/// Parses assets/data/sentences.json: `[categoryId, ru, kk]` rows.
List<SeedSentence> parseSentences(String json) {
  final root = jsonDecode(json) as Map<String, dynamic>;
  return [
    for (final s in (root['sentences'] as List).cast<List>())
      SeedSentence(s[0] as String, s[1] as String, s[2] as String),
  ];
}

/// Parses assets/data/dictionary.json. Each word is `[ru, kk]` or
/// `[ru, kk, note]`.
List<SeedCategory> parseDictionary(String json) {
  final root = jsonDecode(json) as Map<String, dynamic>;
  return [
    for (final c in root['categories'] as List)
      SeedCategory(
        id: c['id'] as String,
        ru: c['ru'] as String,
        kk: c['kk'] as String,
        icon: c['icon'] as String,
        words: [
          for (final w in (c['words'] as List).cast<List>())
            SeedWord(
              w[0] as String,
              w[1] as String,
              w.length > 2 ? w[2] as String : null,
            ),
        ],
      ),
  ];
}
