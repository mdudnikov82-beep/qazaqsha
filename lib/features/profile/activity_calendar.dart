import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../data/database/app_database.dart';
import '../gamification/progress_rules.dart';

/// How many weeks the profile loads; the calendar shows as many as fit.
const activityWeeks = 26;

/// GitHub-style grid: a column per week (Monday on top), the current week
/// on the right, darker cells for days with more XP.
class ActivityCalendar extends StatelessWidget {
  const ActivityCalendar({
    super.key,
    required this.days,
    required this.dailyGoalXp,
    required this.now,
  });

  final List<DailyActivityData> days;
  final int dailyGoalXp;
  final DateTime now;

  static const _gap = 4.0;
  static const _targetCell = 18.0;

  /// 0 = nothing; 1–4 = up to half the goal, the goal, twice the goal, more.
  int _level(DailyActivityData? d) {
    if (d == null || (d.sessions == 0 && d.xp == 0 && d.seconds == 0)) {
      return 0;
    }
    final ratio = d.xp / max(dailyGoalXp, 1);
    if (ratio < 0.5) return 1;
    if (ratio < 1) return 2;
    if (ratio < 2) return 3;
    return 4;
  }

  static Color cellColor(AppColors c, int level) => switch (level) {
    0 => c.track,
    _ => AppColors.primary.withValues(alpha: 0.25 + 0.25 * (level - 1)),
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Stored as UTC midnight; read back as local time, so convert back.
    final byDay = {for (final d in days) dayOf(d.day.toUtc()): d};
    final today = dayOf(now);

    return LayoutBuilder(
      builder: (context, box) {
        final weeks = ((box.maxWidth + _gap) / (_targetCell + _gap))
            .floor()
            .clamp(6, activityWeeks);
        final cell = (box.maxWidth - _gap * (weeks - 1)) / weeks;
        // Monday of the first shown week.
        final start = today.subtract(
          Duration(days: today.weekday - 1 + 7 * (weeks - 1)),
        );

        final labels = <Widget>[];
        for (var w = 0; w < weeks; w++) {
          final monday = start.add(Duration(days: 7 * w));
          final prev = monday.subtract(const Duration(days: 7));
          // Label a column when its week starts a new month, if there is
          // room for the text before the next label.
          if (w == 0 || monday.month != prev.month) {
            if (w > weeks - 2) continue;
            labels.add(
              Positioned(
                left: w * (cell + _gap),
                child: Text(
                  monthShort(monday),
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16, child: Stack(children: labels)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var w = 0; w < weeks; w++) ...[
                  if (w > 0) const SizedBox(width: _gap),
                  Column(
                    children: [
                      for (var d = 0; d < 7; d++) ...[
                        if (d > 0) const SizedBox(height: _gap),
                        _cell(
                          context,
                          start.add(Duration(days: 7 * w + d)),
                          today,
                          byDay,
                          cell,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _cell(
    BuildContext context,
    DateTime day,
    DateTime today,
    Map<DateTime, DailyActivityData> byDay,
    double size,
  ) {
    final c = context.colors;
    if (day.isAfter(today)) return SizedBox.square(dimension: size);
    final data = byDay[day];
    final level = _level(data);
    final what = data == null || level == 0
        ? 'без занятий'
        : '${data.xp} XP, ${data.sessions} '
              '${plural(data.sessions, 'занятие', 'занятия', 'занятий')}';
    return Tooltip(
      message: '${dayMonth(day)}: $what',
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: cellColor(c, level),
          borderRadius: BorderRadius.circular(size / 4),
          border: day == today
              ? Border.all(color: AppColors.gold, width: 2)
              : null,
        ),
      ),
    );
  }
}

/// «меньше ▢▢▢▢▢ больше».
class ActivityLegend extends StatelessWidget {
  const ActivityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = TextStyle(
      color: c.muted,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    );
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('меньше', style: style),
          const SizedBox(width: 6),
          for (var l = 0; l <= 4; l++)
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: ActivityCalendar.cellColor(c, l),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          const SizedBox(width: 6),
          Text('больше', style: style),
        ],
      ),
    );
  }
}
