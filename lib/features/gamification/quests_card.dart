import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../data/providers.dart';
import 'quests.dart';

/// This week's three quests on the home screen. Nothing is lost when a
/// week ends unfinished: next Monday brings new ones.
class WeeklyQuestsCard extends ConsumerWidget {
  const WeeklyQuestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final counts = ref.watch(weekCountsProvider).value ?? const {};
    final quests = questsForWeek(DateTime.now());
    final done = quests.where((q) => (counts[q.key] ?? 0) >= q.target).length;
    final daysLeft = 8 - DateTime.now().weekday;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TintIcon(Icons.flag_circle_rounded, color: c.flame, size: 36),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Задания недели',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                done == quests.length
                    ? 'Все выполнены!'
                    : '$done из ${quests.length} · ещё $daysLeft дн.',
                style: TextStyle(
                  color: done == quests.length ? c.okText : c.muted,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final q in quests)
            _QuestRow(quest: q, value: counts[q.key] ?? 0),
        ],
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  const _QuestRow({required this.quest, required this.value});

  final Quest quest;
  final int value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = value >= quest.target;
    return Semantics(
      label:
          '${quest.title}: ${quest.progressText(value)}${done ? ', выполнено' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle_rounded : quest.icon,
              color: done ? c.ok : c.accent,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: done ? c.muted : c.ink,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: min(1, value / quest.target),
                      minHeight: 6,
                      color: done ? c.ok : c.accent,
                      backgroundColor: c.track,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              quest.progressText(value),
              style: TextStyle(
                color: c.muted,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
