import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazaqsha/data/providers.dart';
import 'package:qazaqsha/features/watch/watch_screens.dart';
import 'package:qazaqsha/main_watch.dart';

import 'app_harness.dart';
import 'helpers.dart';

void main() {
  testWidgets('watch: word of the day, a 5-word workout, XP saved', (
    tester,
  ) async {
    // Galaxy Watch6: 432×432 pixels at density 2.
    tester.view.physicalSize = const Size(432, 432);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    // A pretend bezel: turns are sent from the test.
    MockStreamHandlerEventSink? bezel;
    tester.binding.defaultBinaryMessenger.setMockStreamHandler(
      const EventChannel('qazaqsha/rotary'),
      MockStreamHandler.inline(
        onListen: (_, sink) {
          bezel = sink;
        },
      ),
    );

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

    // The word of the day turns over to its translation.
    await tester.tap(find.text('нажмите — перевод и 🔊'));
    await tester.pump();
    expect(find.text('нажмите — перевод и 🔊'), findsNothing);

    // Turning the bezel scrolls the screen.
    final list = find.byType(Scrollable).first;
    double offset() => tester.state<ScrollableState>(list).position.pixels;
    expect(offset(), 0);
    bezel!.success(40.0);
    await tester.pump();
    expect(offset(), greaterThan(0));
    bezel!.success(-400.0);
    await tester.pump();
    expect(offset(), 0);

    final words = (await tester.runAsync(() => db.select(db.words).get()))!;
    // A long word of the day can push the button below the round edge.
    await tester.ensureVisible(find.text('Тренировка'));
    await tester.pump();
    await tester.tap(find.text('Тренировка'));
    await advanceUntil(tester, () => find.text('1 / 5').evaluate().isNotEmpty);

    // The answer to the task on screen; asked either way round.
    String answer() {
      final prompt = tester.widget<Text>(find.byKey(watchPromptKey)).data!;
      final w = words.firstWhere((w) => w.kk == prompt || w.ru == prompt);
      return prompt == w.kk ? w.ru : w.kk;
    }

    // First task wrong on purpose: it comes back as a sixth.
    final right = answer();
    final wrong = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(FilledButton),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data!)
        .firstWhere((t) => t != right);
    await tester.tap(find.text(wrong));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Вернётся в конце'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('2 / 6'), findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text(answer()));
      await tester.pump(const Duration(milliseconds: 900));
    }
    await advanceUntil(
      tester,
      () => find.text('Керемет!').evaluate().isNotEmpty,
    );
    // 4 right first time; the fixed one counts its 5 XP plus the fix bonus.
    expect(find.text('4 из 5 · +35 XP'), findsOneWidget);
    expect(find.text('Исправлено: 1'), findsOneWidget);
    final stats = await tester.runAsync(
      () => db.select(db.userStats).getSingle(),
    );
    expect((stats!.xp, stats.streakDays), (35, 1));

    await closeApp(tester, db);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
