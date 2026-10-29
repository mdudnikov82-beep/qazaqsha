import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/widgets/speak_button.dart';
import '../../core/widgets/teal_header.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import 'grammar.dart';

/// The «Правила» tab: rules by part of speech and topic, with progress.
class RulesScreen extends ConsumerStatefulWidget {
  const RulesScreen({super.key});

  @override
  ConsumerState<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends ConsumerState<RulesScreen> {
  String _part = grammarParts.first.id;

  @override
  Widget build(BuildContext context) {
    final grammar = ref.watch(grammarProvider);
    if (grammar.value == null) return LoadingScaffold(error: grammar.error);
    final all = grammar.value!;
    final groups = [
      for (final g in all)
        if (g.part == _part) g,
    ];
    final done = ref.watch(grammarProgressProvider).value ?? const {};
    final rules = rulesOfPart(all, _part);
    final total = [for (final g in all) ...g.rules].length;
    final part = grammarParts.firstWhere((p) => p.id == _part);
    final learned = rules
        .where((r) => (done[r.id]?.bestScore ?? 0) >= grammarPassScore)
        .length;
    final next = rules
        .where((r) => (done[r.id]?.bestScore ?? 0) < grammarPassScore)
        .firstOrNull;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            TealHeader(
              title: 'Ережелер',
              subtitle: 'Правила · $total',
              bottomPadding: 64,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _HeaderRing(done: learned, total: rules.length),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (next != null)
                      _NextCard(rule: next, started: learned > 0)
                    else
                      _AllDoneCard(part: part.title),
                    // Below the card: the part overlapping the header
                    // doesn't take taps.
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final p in grammarParts) ...[
                            ChoiceChip(
                              label: Text(p.title),
                              selected: p.id == _part,
                              onSelected: (_) => setState(() => _part = p.id),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final (i, g) in groups.indexed) ...[
                      _GroupCard(
                        number: i + 1,
                        group: g,
                        done: done,
                        initiallyExpanded:
                            next != null && g.rules.contains(next),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SurfaceCard(
                      radius: 20,
                      onTap: () => context.push('/latin'),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Center(
                              child: Text(
                                'Ää',
                                style: TextStyle(
                                  color: AppColors.onGold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Латиница',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text('Новый казахский алфавит и конвертер'),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRing extends StatelessWidget {
  const _HeaderRing({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Изучено правил: $done из $total',
    excludeSemantics: true,
    child: SizedBox.square(
      dimension: 60,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: total == 0 ? 0 : done / total,
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            color: AppColors.gold,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
          ),
          Center(
            child: Text(
              '$done',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.rule, required this.started});

  final GrammarRule rule;
  final bool started;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SurfaceCard(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            started ? 'СЛЕДУЮЩЕЕ ПРАВИЛО' : 'НАЧНИТЕ С ПЕРВОГО',
            style: TextStyle(
              color: c.accent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${rule.number}. ${rule.title}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          GoldButton(
            label: started ? 'Продолжить' : 'Открыть правило',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.push('/rules/${rule.id}'),
          ),
        ],
      ),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard({required this.part});

  final String part;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SurfaceCard(
      radius: 24,
      color: c.okSoft,
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: c.okText, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '«$part»: все правила изучены! Повторяйте темы проверками.',
              style: TextStyle(
                color: c.okText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.number,
    required this.group,
    required this.done,
    required this.initiallyExpanded,
  });

  final int number;
  final GrammarGroup group;
  final Map<String, GrammarProgressData> done;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final learned = group.rules
        .where((r) => (done[r.id]?.bestScore ?? 0) >= grammarPassScore)
        .length;
    final total = group.rules.length;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // No divider lines around the expanded tile.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: learned == total ? c.okSoft : c.accentSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: learned == total
                  ? Icon(Icons.check_rounded, color: c.okText)
                  : Text(
                      '$number',
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
          title: Text(
            group.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            '${group.titleKk} · $learned из $total',
            style: TextStyle(color: c.muted),
          ),
          children: [
            for (final r in group.rules)
              _RuleRow(rule: r, progress: done[r.id]),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => context.push('/rules/test/${group.id}'),
                icon: const Icon(Icons.quiz_rounded),
                label: const Text('Проверить тему · 10 заданий'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule, required this.progress});

  final GrammarRule rule;
  final GrammarProgressData? progress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final score = progress?.bestScore;
    final learned = (score ?? 0) >= grammarPassScore;
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: () => context.push('/rules/${rule.id}'),
      leading: SizedBox(
        width: 34,
        child: Text(
          '${rule.number}',
          textAlign: TextAlign.right,
          style: TextStyle(color: c.muted, fontWeight: FontWeight.w900),
        ),
      ),
      title: Text(
        rule.title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      trailing: score == null
          ? Icon(Icons.chevron_right_rounded, color: c.muted)
          : Text(
              learned ? '✓ $score%' : '$score%',
              style: TextStyle(
                color: learned ? c.okText : c.goldText,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

/// One rule: explanation, forms, examples, then exercises.
class RuleScreen extends ConsumerWidget {
  const RuleScreen({super.key, required this.ruleId});

  final String ruleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammar = ref.watch(grammarProvider);
    if (grammar.value == null) return LoadingScaffold(error: grammar.error);
    final group = grammar.value!
        .where((g) => g.rules.any((r) => r.id == ruleId))
        .firstOrNull;
    if (group == null) {
      return const LoadingScaffold(error: 'Правило не найдено');
    }
    final rules = rulesOfPart(grammar.value!, group.part);
    final i = rules.indexWhere((r) => r.id == ruleId);
    final rule = rules[i];
    final score = ref.watch(grammarProgressProvider).value?[rule.id]?.bestScore;
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text('Правило ${rule.number} из ${rules.length}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(
            group.title.toUpperCase(),
            style: TextStyle(
              color: c.accent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rule.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(rule.text, style: const TextStyle(fontSize: 16, height: 1.4)),
          if (rule.table.isNotEmpty) ...[
            const SizedBox(height: 18),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (final (j, (form, meaning)) in rule.table.indexed) ...[
                    if (j > 0) Divider(height: 1, color: c.line),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              form,
                              style: TextStyle(
                                color: c.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              meaning,
                              style: TextStyle(color: c.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          const Text(
            'Примеры',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final (kk, ru) in rule.examples)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                decoration: BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border(left: BorderSide(color: c.accent, width: 4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            kk,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SpeakButton(kk, size: 20),
                      ],
                    ),
                    Text(ru, style: TextStyle(color: c.muted)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          GoldButton(
            label: score == null
                ? 'Упражнения · ${rule.tasks.length} задания'
                : 'Ещё раз · лучший $score%',
            icon: Icons.edit_note_rounded,
            onPressed: () => context.push('/rules/${rule.id}/practice'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (i > 0)
                Expanded(
                  child: TextButton.icon(
                    onPressed: () =>
                        context.pushReplacement('/rules/${rules[i - 1].id}'),
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Назад'),
                  ),
                )
              else
                const Spacer(),
              if (i < rules.length - 1)
                Expanded(
                  child: TextButton.icon(
                    iconAlignment: IconAlignment.end,
                    onPressed: () =>
                        context.pushReplacement('/rules/${rules[i + 1].id}'),
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: const Text('Следующее'),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
