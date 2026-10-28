import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/repositories/dictionary_repository.dart';
import 'package:qazaqsha/data/repositories/lesson_repository.dart';
import 'package:qazaqsha/features/lessons/sections.dart';
import 'package:qazaqsha/features/quiz/answer_check.dart';
import 'package:qazaqsha/features/quiz/quiz_engine.dart';
import 'package:qazaqsha/features/quiz/quiz_views.dart';

import 'app_harness.dart';

/// Answers for the first greetings lesson, read from the real database.
class _Answers {
  _Answers(List<Word> words, List<Sentence> sentences)
    : ruToKk = {for (final w in words) w.ru: w.kk},
      kkToRu = {for (final w in words) w.kk: w.ru},
      sentenceKk = {for (final s in sentences) s.ru: s.kk};

  final Map<String, String> ruToKk;
  final Map<String, String> kkToRu;
  final Map<String, String> sentenceKk;
}

Future<_Answers> _answers(WidgetTester tester, AppDatabase db) async {
  final repo = DictionaryRepository(db);
  final words = await tester.runAsync(() => repo.wordsInCategory('greetings'));
  final sentences = await tester.runAsync(
    () => repo.sentencesInCategory('greetings'),
  );
  return _Answers(words!.take(5).toList(), sentences!);
}

String _prompt(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(promptKey)).data!;

/// Answers whatever task is on screen correctly. Returns the prompt.
Future<String?> _answerRight(WidgetTester tester, _Answers a) async {
  if (find.text('Новое слово').evaluate().isNotEmpty) {
    await tester.tap(find.text('Дальше'));
    await settle(tester);
    return null;
  }

  final String prompt;
  if (find.text('Выберите перевод').evaluate().isNotEmpty) {
    prompt = _prompt(tester);
    await tester.tap(find.text(a.ruToKk[prompt] ?? a.kkToRu[prompt]!));
  } else if (find.text('Напишите по-казахски').evaluate().isNotEmpty) {
    prompt = _prompt(tester);
    await tester.enterText(find.byType(TextField), a.ruToKk[prompt]!);
    await tester.pump();
    await tester.tap(find.text('Проверить'));
  } else if (find.text('Соедините пары').evaluate().isNotEmpty) {
    prompt = 'pairs';
    for (final MapEntry(key: ru, value: kk) in a.ruToKk.entries) {
      // Exams know a whole section's words; only some are on screen.
      if (find.text(ru).evaluate().isEmpty) continue;
      await tester.tap(find.text(ru));
      await tester.pump();
      await tester.tap(find.text(kk));
      await tester.pump();
    }
  } else if (find.text('Соберите предложение').evaluate().isNotEmpty) {
    prompt = _prompt(tester);
    for (final token in sentenceTokens(a.sentenceKk[prompt]!)) {
      await tester.tap(
        find
            .descendant(
              of: find.byKey(tileBankKey),
              matching: find.widgetWithText(InkWell, token),
            )
            .first,
      );
      await tester.pump();
    }
    await tester.tap(find.text('Проверить'));
  } else {
    fail('Unknown screen');
  }
  await settle(tester);
  expect(find.text('Дұрыс! Правильно'), findsOneWidget, reason: prompt);
  await tester.tap(find.text('Далее'));
  await settle(tester);
  return prompt;
}

Future<UserStat> _stats(WidgetTester tester, AppDatabase db) async =>
    (await tester.runAsync(() => db.select(db.userStats).getSingle()))!;

void main() {
  testWidgets('a lesson can be finished with all answers right', (
    tester,
  ) async {
    final db = await startApp(tester);
    final answers = await _answers(tester, db);

    await tester.tap(find.text('Начать урок'));
    await settle(tester);

    var steps = 0;
    while (find.text('Сабақ аяқталды!').evaluate().isEmpty) {
      expect(++steps, lessThan(40), reason: 'lesson never ended');
      await _answerRight(tester, answers);
    }

    // 5 choices ×10 + pairs 20 + 3 typed ×15 + 2 reverse choices ×10
    // + 2 sentences ×20 + lesson bonus 20 + no-mistakes bonus 10.
    expect(find.text('+205'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.textContaining('Первые шаги'), findsOneWidget);
    expect(find.textContaining('Без ошибок'), findsOneWidget);

    final stats = await _stats(tester, db);
    expect((stats.xp, stats.streakDays, stats.quizzesCompleted), (205, 1, 1));

    await tester.tap(find.text('Готово'));
    await settle(tester);
    // Back home, the next lesson of the topic is offered.
    expect(find.textContaining('урок 2 из 5'), findsOneWidget);
    expect(find.text('205'), findsOneWidget);

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('a wrong answer is asked again and costs XP', (tester) async {
    final db = await startApp(tester);
    final answers = await _answers(tester, db);

    await tester.tap(find.text('Начать урок'));
    await settle(tester);
    while (find.text('Новое слово').evaluate().isNotEmpty) {
      await _answerRight(tester, answers);
    }

    // First task after the intro cards is a Russian → Kazakh choice.
    expect(find.text('Выберите перевод'), findsOneWidget);
    final missed = _prompt(tester);
    final right = answers.ruToKk[missed]!;
    final wrongOption = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(InkWell),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data!)
        // The prompt card is tappable too: skip its label and the prompt.
        .firstWhere(
          (text) =>
              text != right &&
              text != missed &&
              text != 'по-русски' &&
              text != 'по-казахски',
        );
    await tester.tap(find.text(wrongOption));
    await settle(tester);
    expect(find.text('Пока неверно'), findsOneWidget);
    expect(find.textContaining('Вопрос повторится в конце'), findsOneWidget);
    await tester.tap(find.text('Понятно'));
    await settle(tester);

    final prompts = <String?>[];
    var steps = 0;
    while (find.text('Сабақ аяқталды!').evaluate().isEmpty) {
      expect(++steps, lessThan(40), reason: 'lesson never ended');
      prompts.add(await _answerRight(tester, answers));
    }
    expect(prompts.last, missed, reason: 'the missed word comes back last');

    // 205 − 10 for the miss + 5 for the retry − 10 lost no-mistakes bonus.
    expect(find.text('+190'), findsOneWidget);
    expect((await _stats(tester, db)).xp, 190);
    final progress = await tester.runAsync(
      () => db.select(db.wordProgress).get(),
    );
    // Exactly the missed word is marked wrong and goes back to box 0.
    final wrong = progress!.where((p) => p.wrongCount > 0).toList();
    expect(wrong, hasLength(1));
    expect(wrong.single.box, 0);
    final word = await tester.runAsync(
      () => (db.select(
        db.words,
      )..where((w) => w.id.equals(wrong.single.wordId))).getSingle(),
    );
    expect(word!.ru, missed);

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('a section exam can be passed and opens the next section', (
    tester,
  ) async {
    final db = await startApp(tester);
    final basics = courseSections.first;
    final dictionary = DictionaryRepository(db);
    final lessons = LessonRepository(db, dictionary);

    // Mark every lesson of the first section as done.
    await tester.runAsync(() async {
      for (final c in await dictionary.categories()) {
        if (!basics.categoryIds.contains(c.category.id)) continue;
        for (var i = 0; i < lessonCountFor(c.wordCount); i++) {
          await lessons.completeLesson(
            categoryId: c.category.id,
            lessonIndex: i,
            score: 100,
            now: DateTime(2026, 10, 28),
          );
        }
      }
    });
    await advanceUntil(
      tester,
      () => find.text('Сдать экзамен').evaluate().isNotEmpty,
    );
    final answers = _Answers(
      (await tester.runAsync(
        () => dictionary.wordsInCategories(basics.categoryIds),
      ))!,
      (await tester.runAsync(
        () => dictionary.sentencesInCategories(basics.categoryIds),
      ))!,
    );

    await tester.tap(find.text('Сдать экзамен'));
    await settle(tester);
    expect(find.text('Новое слово'), findsNothing);

    var steps = 0;
    while (find.text('Емтихан тапсырылды!').evaluate().isEmpty) {
      expect(++steps, lessThanOrEqualTo(15), reason: 'exam has 15 tasks');
      await _answerRight(tester, answers);
    }

    // 8 choices ×10 + 4 typed ×15 + pairs 20 + 2 sentences ×20
    // + exam bonus 50 + no-mistakes bonus 10.
    expect(find.text('+260'), findsOneWidget);
    expect(find.textContaining('Первый экзамен'), findsOneWidget);

    await tester.tap(find.text('Готово'));
    await settle(tester);
    // The next section's first topic is now the one to continue with.
    expect(find.text('Тағам'), findsOneWidget);
    expect(find.textContaining('урок 1 из 5'), findsOneWidget);

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('own words can be pasted, added and practised', (tester) async {
    final db = await startApp(tester);

    await tester.tap(find.text('Словарь'));
    await settle(tester);
    await tester.tap(find.byTooltip('Добавить свои слова'));
    await settle(tester);

    // Russian-first line on purpose: the app should flip it.
    await tester.enterText(
      find.widgetWithText(TextField, 'кітап — книга\nқалам — ручка'),
      'тиін — белка\nящерица — кесіртке\nрахмет — спасибо',
    );
    await tester.pump();
    await tester.tap(find.text('Показать слова'));
    await settle(tester);
    expect(find.text('Новые слова: 3'), findsOneWidget);
    // The Russian-first line was flipped: Kazakh word first.
    expect(
      find.textContaining('кесіртке — ящерица', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('Добавить 3 в «Мои слова»'));
    // The word list reloads from the database right after saving.
    await advanceUntil(tester, () => find.text('тиін').evaluate().isNotEmpty);
    // «рахмет» is already in the built-in dictionary.
    expect(find.text('Добавлено: 2, уже были в словаре: 1'), findsOneWidget);
    expect(find.text('тиін'), findsOneWidget);
    expect(find.text('кесіртке'), findsOneWidget);

    await tester.tap(find.text('Тренировать'));
    await settle(tester);
    expect(find.text('Новое слово'), findsOneWidget);

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
