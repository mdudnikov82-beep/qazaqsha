import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/providers.dart';
import 'package:qazaqsha/main.dart';

void main() {
  testWidgets('home shows the first lesson and tabs switch', (tester) async {
    // A tall phone, so whole screens fit without scrolling.
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const QazaqshaApp(),
      ),
    );
    // Database setup runs on real async I/O.
    await tester.runAsync(() => db.select(db.words).get());
    await tester.pumpAndSettle();

    expect(find.text('Сәлем!'), findsOneWidget);
    expect(find.text('Амандасу'), findsOneWidget);
    expect(find.text('Начать урок'), findsOneWidget);

    await tester.tap(find.text('Словарь'));
    await tester.pumpAndSettle();
    expect(find.text('Сөздік'), findsOneWidget);

    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(find.text('Уровень 1'), findsOneWidget);
    expect(find.text('Тема оформления'), findsOneWidget);
    expect(find.text('Тёмная'), findsOneWidget);

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
    await tester.pumpAndSettle();
    final saved = await tester.runAsync(
      () => db.select(db.userStats).getSingle(),
    );
    expect(saved!.themeMode, AppThemeMode.dark);

    // The database lives in the test's fake-async zone, so it must be closed
    // there too: start closing, then let both fake and real time advance.
    await tester.pumpWidget(const SizedBox());
    var closed = false;
    unawaited(db.close().then((_) => closed = true));
    for (var i = 0; i < 40 && !closed; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(closed, isTrue, reason: 'database did not close');
  });
}
