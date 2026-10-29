import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Keeps the Android home-screen widget (QazaqshaWidget.kt) in step with
/// the app: word of the day, streak and freezes, today's tasks left.
abstract final class HomeWidgetSync {
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static String? _last;

  static Future<void> update({
    required String wordKk,
    required String wordRu,
    required int streak,
    required int freezes,
    required int tasksLeft,
  }) async {
    if (!supported) return;
    final streakLine = freezes > 0
        ? 'Серия $streak · заморозки $freezes'
        : 'Серия $streak';
    final tasks = tasksLeft == 0
        ? 'Задания дня выполнены — керемет!'
        : 'Задания дня: осталось $tasksLeft из 3';
    final key = '$wordKk|$wordRu|$streakLine|$tasks';
    if (key == _last) return;
    _last = key;
    try {
      await HomeWidget.saveWidgetData('word_kk', wordKk);
      await HomeWidget.saveWidgetData('word_ru', wordRu);
      await HomeWidget.saveWidgetData('streak', streakLine);
      await HomeWidget.saveWidgetData('tasks', tasks);
      await HomeWidget.updateWidget(
        qualifiedAndroidName: 'com.maxim.qazaqsha.QazaqshaWidget',
      );
    } catch (_) {
      // No widget host (tests) or none placed: nothing to update.
      _last = null;
    }
  }
}
