import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/features/dialogues/dialogues.dart';

void main() {
  final dialogues = parseDialogues(
    File('assets/data/dialogues.json').readAsStringSync(),
  );

  test('12 dialogues, each with lines and 4 sound tasks', () {
    expect(dialogues, hasLength(12));
    expect(dialogues.map((d) => d.id).toSet(), hasLength(12));
    for (final d in dialogues) {
      expect(d.lines.length, greaterThanOrEqualTo(6), reason: d.id);
      expect(d.tasks, hasLength(4), reason: d.id);
      for (final t in d.tasks) {
        expect(t.wrong, isNot(contains(t.answer)), reason: d.id);
        expect(t.ref, startsWith('${d.id}#'));
      }
    }
  });

  group('tapping a word finds it in the dictionary', () {
    var id = 0;
    Word w(String kk, String ru) => Word(
      id: ++id,
      categoryId: 'x',
      ru: ru,
      kk: kk,
      sortOrder: 0,
      searchText: '',
    );
    final dictionary = [
      w('қала', 'город'),
      w('бар', 'есть'),
      w('бару', 'идти'),
      w('сәлем', 'привет'),
      w('қалам', 'ручка'),
    ];
    String? find(String token) => lookupWord(token, dictionary)?.ru;

    test('the word itself, ignoring case and punctuation', () {
      expect(find('Сәлем!'), 'привет');
      expect(find('«қала»,'), 'город');
    });
    test('with endings: the longest dictionary word it starts with', () {
      expect(find('қалаға'), 'город');
      expect(find('қаламмен'), 'ручка');
    });
    test('verbs by their stem', () {
      expect(find('барамын'), 'идти');
      expect(find('бар'), 'есть');
    });
    test('nothing for unknown or too loose matches', () {
      expect(find('Алматыда'), isNull);
      expect(find('барлығымыздың'), isNull);
    });
  });
}
