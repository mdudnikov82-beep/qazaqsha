import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/widgets/common.dart';
import '../../data/database/app_database.dart';
import '../gamification/progress_rules.dart';

/// This week at a glance: which days had study, the weekly goal, streak
/// freezes, and a kind word about the streak — never a scolding one.
class WeekCard extends StatelessWidget {
  const WeekCard({
    super.key,
    required this.stats,
    required this.days,
    required this.learnedWords,
    required this.now,
  });

  final UserStat stats;
  final List<DailyActivityData> days;
  final int learnedWords;
  final DateTime now;

  static const _names = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final monday = weekStart(now);
    final today = dayOf(now);
    final byDay = {for (final d in days) dayOf(d.day.toUtc()): d};
    bool studied(DailyActivityData? d) =>
        d != null && (d.sessions > 0 || d.xp > 0);
    final week = [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
    final done = week.where((d) => studied(byDay[d])).length;
    final goal = stats.weeklyGoalDays;
    final message = _message(done, goal, today, studied(byDay[today]));

    return SurfaceCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Эта неделя',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '$done из $goal ${plural(goal, 'дня', 'дней', 'дней')}',
                style: TextStyle(
                  color: done >= goal ? c.okText : c.muted,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message:
                    'Заморозка спасает серию, если пропустить день. '
                    'Даётся каждые $freezeEveryDays дней подряд, до $maxFreezes штук.',
                triggerMode: TooltipTriggerMode.tap,
                child: Semantics(
                  label: 'Заморозки серии: ${stats.streakFreezes}',
                  excludeSemantics: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: c.accentSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit_rounded, size: 16, color: c.sky),
                        const SizedBox(width: 3),
                        Text(
                          '${stats.streakFreezes}',
                          style: TextStyle(
                            color: c.accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (i, d) in week.indexed)
                _Day(
                  name: _names[i],
                  studied: studied(byDay[d]),
                  frozen: byDay[d]?.frozen ?? false,
                  today: d == today,
                  future: d.isAfter(today),
                ),
            ],
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message.$1,
              style: TextStyle(
                color: message.$2 ? c.goldText : c.muted,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The line under the week, and whether it is a call to act.
  (String, bool)? _message(
    int done,
    int goal,
    DateTime today,
    bool studiedToday,
  ) {
    final s = stats;
    final target = repairGoalFactor * s.dailyGoalXp;
    final xpToday = todayXp(
      storedDailyXp: s.dailyXp,
      storedDay: s.dailyXpDate,
      now: now,
    );
    // Already broke today after one missed day: still winnable.
    if (s.repairStreak > 0 &&
        s.repairDay != null &&
        dayOf(s.repairDay!) == today) {
      final left = max(0, target - xpToday);
      return (
        'Ещё $left XP сегодня — и серия ${s.repairStreak} '
            '${plural(s.repairStreak, 'день', 'дня', 'дней')} вернётся.',
        true,
      );
    }
    final lapsed = streakLapsed(
      current: s.streakDays,
      lastActive: s.lastActiveDate,
      now: now,
      freezes: s.streakFreezes,
    );
    if (lapsed && daysBetween(s.lastActiveDate!, now) == 2) {
      return (
        'Вчера был перерыв — бывает. Наберите сегодня $target XP, и серия '
            '${s.streakDays} ${plural(s.streakDays, 'день', 'дня', 'дней')} вернётся.',
        true,
      );
    }
    if (lapsed) {
      return (
        'С возвращением! Серия начнётся заново с сегодняшнего занятия. '
            'Рекорд — ${s.bestStreak} ${plural(s.bestStreak, 'день', 'дня', 'дней')}, '
            '$learnedWords ${plural(learnedWords, 'слово', 'слова', 'слов')} '
            'выучено — ничего не пропало.',
        false,
      );
    }
    if (done >= goal) return ('Неделя выполнена! Отличный ритм.', false);
    if (s.streakFreezes > 0) {
      return ('Если пропустите день, заморозка сохранит серию.', false);
    }
    if (!studiedToday && s.streakDays > 0) {
      return ('Одно занятие сегодня — и серия продолжится.', false);
    }
    return null;
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.name,
    required this.studied,
    required this.frozen,
    required this.today,
    required this.future,
  });

  final String name;
  final bool studied;
  final bool frozen;
  final bool today;
  final bool future;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, child) = studied
        ? (
            AppColors.primary,
            const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          )
        : frozen
        ? (c.accentSoft, Icon(Icons.ac_unit_rounded, color: c.sky, size: 18))
        : (c.track, const SizedBox.shrink());
    return Semantics(
      label:
          '$name: ${studied
              ? 'занимались'
              : frozen
              ? 'заморозка'
              : future
              ? 'впереди'
              : 'без занятий'}',
      excludeSemantics: true,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: future ? Colors.transparent : bg,
              shape: BoxShape.circle,
              border: today
                  ? Border.all(color: AppColors.gold, width: 2.5)
                  : future
                  ? Border.all(color: c.line, width: 1.5)
                  : null,
            ),
            child: Center(child: child),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              color: today ? c.ink : c.muted,
              fontSize: 12,
              fontWeight: today ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
