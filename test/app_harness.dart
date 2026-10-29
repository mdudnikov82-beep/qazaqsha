import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/database/app_database.dart';
import 'package:qazaqsha/data/providers.dart';
import 'package:qazaqsha/main.dart';

import 'helpers.dart';

/// Starts the whole app on a fresh in-memory database, on a tall phone,
/// with system "reduce motion" on (so looping animations don't keep the
/// test busy). Skips the welcome flow unless [keepWelcome].
Future<AppDatabase> startApp(
  WidgetTester tester, {
  bool keepWelcome = false,
}) async {
  tester.view.physicalSize = const Size(420, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  // rootBundle caches loaded assets as futures bound to the test that loaded
  // them; a later test awaiting one would wait forever. Seed from files
  // instead, and drop the cache so nothing leaks into the next test.
  addTearDown(rootBundle.clear);

  final db = testDatabase();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        grammarSourceProvider.overrideWithValue(
          () => File('assets/data/grammar.json').readAsString(),
        ),
        speechCheckProvider.overrideWithValue(() async => false),
        dialoguesSourceProvider.overrideWithValue(
          () => File('assets/data/dialogues.json').readAsString(),
        ),
      ],
      child: const QazaqshaApp(),
    ),
  );
  // Opening the database needs both real file I/O and fake-async
  // microtasks; blocking on either alone can deadlock.
  await advanceUntil(
    tester,
    () => find.text('Пропустить').evaluate().isNotEmpty,
  );
  if (!keepWelcome) {
    await tester.tap(find.text('Пропустить'));
    await advanceUntil(tester, () => find.text('Сәлем!').evaluate().isNotEmpty);
  }
  return db;
}

/// Alternates real time and fake time until [done] or about 10 seconds pass.
Future<void> advanceUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 100 && !done(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(done(), isTrue, reason: 'timed out waiting for the app');
}

/// Database work resolves over a few frames. Fixed-length pumps instead of
/// pumpAndSettle, which would wait forever on a loading spinner.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The database lives in the fake-async zone: close it there.
Future<void> closeApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  var closed = false;
  unawaited(db.close().then((_) => closed = true));
  await advanceUntil(tester, () => closed);
}
