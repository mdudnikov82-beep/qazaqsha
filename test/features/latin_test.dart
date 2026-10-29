import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/core/latin.dart';

void main() {
  test('Kazakh words in the 2021 Latin alphabet', () {
    expect(toLatin('сәлем'), 'sälem');
    expect(toLatin('Қазақстан'), 'Qazaqstan');
    expect(toLatin('рахмет'), 'rahmet');
    expect(toLatin('кітап'), 'kıtap');
    expect(toLatin('ұл бала'), 'ūl bala');
    expect(toLatin('үй'), 'üi');
    expect(toLatin('таң'), 'tañ');
    expect(toLatin('шай'), 'şai');
    expect(toLatin('ыдыс'), 'ydys');
  });

  test('capitals keep the dotted / dotless i apart', () {
    expect(toLatin('Іні'), 'Inı');
    expect(toLatin('Ит'), 'İt');
    expect(toLatin('Әже'), 'Äje');
  });

  test('punctuation, Latin text and loanword letters', () {
    expect(toLatin('Сәлем, қалайсың?'), 'Sälem, qalaisyñ?');
    expect(toLatin('Wi-Fi'), 'Wi-Fi');
    expect(toLatin('чай'), 'chai');
    expect(toLatin('объявление'), 'obiavlenie');
  });

  test('every example in the alphabet table matches the converter', () {
    for (final (_, _, example) in latinAlphabet) {
      for (final pair in example.split(', ')) {
        final [cyr, lat] = pair.split(' → ');
        expect(toLatin(cyr), lat, reason: pair);
      }
    }
  });
}
