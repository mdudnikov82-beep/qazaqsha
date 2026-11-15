import 'dart:math';

import 'package:flutter/material.dart';

import 'progress_rules.dart';

/// What the weekly counters count. Stored by [name] in WeeklyCounts.
enum QuestKey {
  lessons,
  reviews,
  rules,
  dictations,
  fixes,
  fixed,
  seconds,
  dialogues,

  /// Not stored: days with any study, read from the activity calendar.
  days,
}

/// One weekly challenge: reach [target] of [key] within the week.
class Quest {
  const Quest(this.key, this.target, this.title, this.icon);

  final QuestKey key;
  final int target;
  final String title;
  final IconData icon;

  /// «12 / 30 мин» style progress text.
  String progressText(int value) => key == QuestKey.seconds
      ? '${min(value, target) ~/ 60} / ${target ~/ 60} мин'
      : '${min(value, target)} / $target';
}

/// Quests a week can draw from; at most one per key in a week.
const questPool = [
  Quest(QuestKey.lessons, 5, 'Пройти 5 уроков', Icons.school_rounded),
  Quest(QuestKey.lessons, 8, 'Пройти 8 уроков', Icons.school_rounded),
  Quest(QuestKey.reviews, 3, 'Сделать 3 повторения', Icons.replay_rounded),
  Quest(QuestKey.rules, 2, 'Позаниматься 2 правилами', Icons.menu_book_rounded),
  Quest(QuestKey.rules, 4, 'Позаниматься 4 правилами', Icons.menu_book_rounded),
  Quest(QuestKey.dictations, 4, 'Написать 4 диктанта', Icons.hearing_rounded),
  Quest(
    QuestKey.fixes,
    5,
    'Найти 5 ошибок в предложениях',
    Icons.search_rounded,
  ),
  Quest(
    QuestKey.fixed,
    5,
    'Исправить 5 своих ошибок',
    Icons.auto_fix_high_rounded,
  ),
  Quest(QuestKey.seconds, 30 * 60, 'Заниматься 30 минут', Icons.timer_rounded),
  Quest(QuestKey.seconds, 60 * 60, 'Заниматься 60 минут', Icons.timer_rounded),
  Quest(
    QuestKey.days,
    3,
    'Заниматься в 3 разных дня',
    Icons.event_available_rounded,
  ),
  Quest(
    QuestKey.days,
    5,
    'Заниматься в 5 разных дней',
    Icons.event_available_rounded,
  ),
  Quest(QuestKey.dialogues, 1, 'Разобрать диалог', Icons.forum_rounded),
];

/// Quests per week.
const questsPerWeek = 3;

/// Monday of [t]'s week, as a UTC date.
DateTime weekOf(DateTime t) {
  final day = dayOf(t);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// The same three quests for everyone in a given week, a new set the next
/// week. Never two quests of one kind, and never more than one about
/// dictations or fixes (they need voices or sentences that not every
/// lesson has).
List<Quest> questsForWeek(DateTime week) {
  final number =
      weekOf(week).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay ~/ 7;
  final random = Random(number);
  final pool = [...questPool]..shuffle(random);
  final picked = <Quest>[];
  bool rare(QuestKey k) => k == QuestKey.dictations || k == QuestKey.fixes;
  for (final q in pool) {
    if (picked.length == questsPerWeek) break;
    if (picked.any((p) => p.key == q.key)) continue;
    if (rare(q.key) && picked.any((p) => rare(p.key))) continue;
    picked.add(q);
  }
  return picked;
}

/// How many quests of [week] are done, given its counters.
int questsDone(DateTime week, Map<QuestKey, int> counts) =>
    questsForWeek(week).where((q) => (counts[q.key] ?? 0) >= q.target).length;
