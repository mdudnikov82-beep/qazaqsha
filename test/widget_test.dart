import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';

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
}
