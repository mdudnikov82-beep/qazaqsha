import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/providers.dart';
import 'package:qazaqsha/main_watch.dart';

import 'app_harness.dart';
import 'helpers.dart';

void main() {
  testWidgets('watch: word of the day, a 5-word workout, XP saved', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final db = testDatabase();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          grammarSourceProvider.overrideWithValue(
            () => File('assets/data/grammar.json').readAsString(),
          ),
        ],
        child: const WatchApp(),
      ),
    );
    await advanceUntil(
      tester,
      () => find.text('Тренировка').evaluate().isNotEmpty,
    );
    expect(find.text('КҮННІҢ СӨЗІ'), findsOneWidget);

    final words = (await tester.runAsync(() => db.select(db.words).get()))!;
    await tester.tap(find.text('Тренировка'));
    await advanceUntil(tester, () => find.text('1 / 5').evaluate().isNotEmpty);

    for (var i = 0; i < 5; i++) {
      final shown = words.firstWhere(
        (w) => find.text(w.kk).evaluate().isNotEmpty,
      );
      await tester.tap(find.text(shown.ru));
      await tester.pump(const Duration(milliseconds: 900));
    }
    await advanceUntil(
      tester,
      () => find.text('Керемет!').evaluate().isNotEmpty,
    );
    expect(find.text('5 из 5 · +25 XP'), findsOneWidget);
    final stats = await tester.runAsync(
      () => db.select(db.userStats).getSingle(),
    );
    expect((stats!.xp, stats.streakDays), (25, 1));

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
