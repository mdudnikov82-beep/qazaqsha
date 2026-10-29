import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/features/grammar/grammar.dart';

import 'app_harness.dart';

void main() {
  testWidgets('home shows the first lesson and tabs switch', (tester) async {
    final db = await startApp(tester);

    expect(find.text('Сәлем!'), findsOneWidget);
    expect(find.text('Амандасу'), findsOneWidget);
    expect(find.text('Начать урок'), findsOneWidget);

    await tester.tap(find.text('Уроки'));
    await settle(tester);
    expect(find.text('Основы'), findsOneWidget);
    expect(find.textContaining('Урок 1 из 5'), findsOneWidget);

    await tester.tap(find.text('Словарь'));
    await settle(tester);
    expect(find.text('Сөздік'), findsOneWidget);

    await tester.tap(find.text('Профиль'));
    await settle(tester);
    expect(find.text('Уровень 1'), findsOneWidget);
    expect(find.text('Тема оформления'), findsOneWidget);

    // Theme switches within a single frame, without waiting for the database.
    Brightness brightness() =>
        Theme.of(tester.element(find.text('Тема оформления'))).brightness;
    await tester.tap(find.text('Тёмная'));
    await tester.pump();
    expect(brightness(), Brightness.dark);
    await tester.tap(find.text('Светлая'));
    await tester.pump();
    expect(brightness(), Brightness.light);
    await tester.tap(find.text('Тёмная'));
    await tester.pump();
    expect(brightness(), Brightness.dark);

    // …and the choice is saved.
    await settle(tester);
    final saved = await tester.runAsync(
      () => db.select(db.userStats).getSingle(),
    );
    expect(saved!.themeMode, AppThemeMode.dark);

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('first launch: welcome, goal choice, straight into a lesson', (
    tester,
  ) async {
    final db = await startApp(tester, keepWelcome: true);
    expect(find.text('Сәлем! Давайте учить казахский'), findsOneWidget);

    await tester.tap(find.text('Дальше'));
    await settle(tester);
    expect(find.text('Сколько заниматься в день?'), findsOneWidget);
    await tester.tap(find.text('Серьёзная'));
    await tester.pump();

    await tester.tap(find.text('Дальше'));
    await settle(tester);
    expect(find.text('Ваша тропа к казахскому'), findsOneWidget);
    expect(find.text('Негіздер'), findsOneWidget);

    await tester.tap(find.text('Начать первый урок'));
    await advanceUntil(
      tester,
      () => find.text('Новое слово').evaluate().isNotEmpty,
    );

    final stats = await tester.runAsync(
      () => db.select(db.userStats).getSingle(),
    );
    expect(stats!.onboardingDone, isTrue);
    expect(stats.dailyGoalXp, 100);

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('profile: name, achievement details, activity', (tester) async {
    final db = await startApp(tester);
    await tester.tap(find.text('Профиль'));
    await settle(tester);

    expect(find.text('Жаңа бастаушы · Новичок'), findsOneWidget);
    expect(find.text('Активность'), findsOneWidget);
    expect(find.text('0 из 9'), findsOneWidget);

    await tester.tap(find.text('Как вас зовут?'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Максим');
    await tester.tap(find.text('Сохранить'));
    // The avatar shows the first letter once the name is saved.
    await advanceUntil(tester, () => find.text('М').evaluate().isNotEmpty);
    await settle(tester); // the dialog fades out
    expect(find.text('Максим'), findsOneWidget);

    await tester.tap(find.text('50 слов'));
    await settle(tester);
    expect(find.text('Выучить 50 слов'), findsOneWidget);
    expect(find.text('0 из 50'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await settle(tester);

    await tester.tap(find.text('Главная'));
    await settle(tester);
    expect(find.text('Сәлем, Максим!'), findsOneWidget);

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('dictionary: search, word card, А–Я, flashcards', (tester) async {
    final db = await startApp(tester);
    await tester.tap(find.text('Словарь'));
    await settle(tester);
    expect(find.text('КҮННІҢ СӨЗІ · СЛОВО ДНЯ'), findsOneWidget);
    expect(find.text('РАЗДЕЛ 1 · НЕГІЗДЕР'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'волк');
    await settle(tester);
    expect(find.text('қасқыр'), findsOneWidget);
    await tester.tap(find.text('қасқыр'));
    await settle(tester);
    expect(find.text('Новое'), findsOneWidget);
    expect(find.textContaining('Животные · урок'), findsOneWidget);
    expect(find.text('Карточки этой темы'), findsOneWidget);

    // Into the topic's flashcards, straight from the card.
    await tester.tap(find.text('Карточки этой темы'));
    await settle(tester);
    expect(find.text('1 из 25'), findsOneWidget);
    for (var i = 0; i < 25; i++) {
      await tester.tap(find.text('Перевернуть'));
      await tester.pump();
      await tester.tap(find.text(i.isEven ? 'Знаю' : 'Не знаю'));
      await tester.pump();
    }
    await settle(tester);
    expect(find.text('Знаю: 13 из 25'), findsOneWidget);
    final seen = await tester.runAsync(() => db.select(db.wordProgress).get());
    expect(seen, hasLength(25));

    await tester.tap(find.text('Готово'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), '');
    await settle(tester);
    await tester.tap(find.text('А–Я'));
    await settle(tester);
    expect(find.text('Қазақша'), findsOneWidget);
    expect(find.text('Ә'), findsOneWidget); // letter strip

    await tester.tap(find.text('Главная'));
    await settle(tester);
    await tester.tap(find.text('Повторение'));
    await settle(tester);
    expect(find.text('Ждут повторения'), findsOneWidget);
    expect(find.text('Прогноз на неделю'), findsOneWidget);
    expect(find.text('Память по ступеням'), findsOneWidget);

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('rules: open a rule, do its exercises, progress is saved', (
    tester,
  ) async {
    final db = await startApp(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Правила'),
      ),
    );
    await advanceUntil(
      tester,
      () => find.text('Открыть правило').evaluate().isNotEmpty,
    );
    expect(find.text('1. Начальная форма на -у'), findsOneWidget);
    expect(find.text('Основы глагола'), findsOneWidget);

    // Nouns are a part of their own, numbered from 1.
    await tester.tap(find.text('Существительные'));
    await settle(tester);
    expect(find.text('1. -лар / -лер'), findsOneWidget);
    await tester.tap(find.text('Глаголы'));
    await settle(tester);

    await tester.tap(find.text('Открыть правило'));
    await settle(tester);
    expect(find.text('Правило 1 из 100'), findsOneWidget);
    await tester.tap(find.text('Упражнения · 4 задания'));
    await settle(tester);

    final grammar = parseGrammar(
      File('assets/data/grammar.json').readAsStringSync(),
    );
    for (var i = 0; i < 4; i++) {
      // Tasks come shuffled: find the one on screen by its question.
      final task = grammar.first.rules.first.tasks.firstWhere(
        (t) => find.text(t.question).evaluate().isNotEmpty,
      );
      await tester.tap(find.text(task.answer));
      await settle(tester);
      await tester.tap(find.text('Дальше'));
      await settle(tester);
    }
    await advanceUntil(
      tester,
      () => find.text('Правило изучено!').evaluate().isNotEmpty,
    );
    expect(find.textContaining('+30 XP'), findsOneWidget);
    final saved = await tester.runAsync(
      () => db.select(db.grammarProgress).getSingle(),
    );
    expect((saved!.ruleId, saved.bestScore), ('v001', 100));

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
