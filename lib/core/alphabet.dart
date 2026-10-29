/// Dictionary order for Russian and Kazakh (Cyrillic) words.
library;

const kazakhAlphabet = 'аәбвгғдеёжзийкқлмнңоөпрстуұүфхһцчшщъыіьэюя';
const russianAlphabet = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя';

/// Compares [a] and [b] letter by letter in [alphabet]; other characters
/// (spaces, punctuation) sort before letters.
int compareIn(String alphabet, String a, String b) {
  final x = a.toLowerCase();
  final y = b.toLowerCase();
  for (var i = 0; i < x.length && i < y.length; i++) {
    final cx = alphabet.indexOf(x[i]);
    final cy = alphabet.indexOf(y[i]);
    if (cx != cy) return cx.compareTo(cy);
    if (cx == -1 && x[i] != y[i]) return x[i].compareTo(y[i]);
  }
  return x.length.compareTo(y.length);
}

/// Upper-case first letter for the A–Я index, or null for none.
String? firstLetter(String alphabet, String word) {
  for (final ch in word.toLowerCase().split('')) {
    if (alphabet.contains(ch)) return ch.toUpperCase();
  }
  return null;
}
