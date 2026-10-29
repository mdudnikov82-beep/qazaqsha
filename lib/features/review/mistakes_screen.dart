import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/dates.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/teal_header.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../dictionary/word_sheet.dart';
import '../grammar/grammar.dart';

/// Every task answered wrong, with the right answer and why, and a way to
/// practise exactly those. A mistake leaves once it is answered right.
class MistakesScreen extends ConsumerWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(openMistakesProvider);
    if (open.value == null) return LoadingScaffold(error: open.error);
    final mistakes = open.value!;
    final grammar = ref.watch(grammarProvider).value ?? const [];
    final rulesById = {
      for (final g in grammar)
        for (final r in g.rules) r.id: (r, g),
    };
    final words = {
      for (final w in ref.watch(allWordsProvider).value ?? const <Word>[])
        w.id: w,
    };
    int count(MistakeKind k) => mistakes.where((m) => m.kind == k).length;
    final c = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            TealHeader(
              leading: const BackButton(color: Colors.white),
              title: 'Қателер',
              subtitle: mistakes.isEmpty
                  ? 'Работа над ошибками'
                  : 'Работа над ошибками · ${mistakes.length}',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (mistakes.isEmpty)
                    SurfaceCard(
                      color: c.okSoft,
                      child: Text(
                        'Ошибок нет! Неверные ответы из уроков, правил и '
                        'диалогов будут собираться здесь — с правильным '
                        'ответом и объяснением.',
                        style: TextStyle(
                          color: c.okText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      'Ошибка — это подсказка, что повторить. Ответьте '
                      'верно — и она уйдёт из списка.',
                      style: TextStyle(color: c.muted),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _PracticeTile(
                            icon: Icons.translate_rounded,
                            title: 'Слова',
                            count: count(MistakeKind.word),
                            onTap: () =>
                                context.push('/practice/review?mode=mistakes'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PracticeTile(
                            icon: Icons.rule_rounded,
                            title: 'Правила',
                            count: count(MistakeKind.grammar),
                            onTap: () => context.push('/rules/mistakes'),
                          ),
                        ),
                      ],
                    ),
                    if (count(MistakeKind.sentence) +
                            count(MistakeKind.dialogue) >
                        0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Предложения и диалоги исправятся, когда вы ответите '
                        'на них верно в уроке или диалоге.',
                        style: TextStyle(color: c.muted, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 20),
                    for (final m in mistakes) ...[
                      _MistakeCard(
                        mistake: m,
                        rule: m.kind == MistakeKind.grammar
                            ? rulesById[m.ref.split('#').first]
                            : null,
                        word: m.kind == MistakeKind.word
                            ? words[int.tryParse(m.ref)]
                            : null,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeTile extends StatelessWidget {
  const _PracticeTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final none = count == 0;
    return Semantics(
      button: true,
      enabled: !none,
      label: '$title: $count, исправить',
      excludeSemantics: true,
      child: SurfaceCard(
        radius: 18,
        color: none ? c.surface : c.badSoft,
        padding: const EdgeInsets.all(14),
        onTap: none ? null : onTap,
        child: Row(
          children: [
            Icon(icon, color: none ? c.muted : c.badText),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$title: $count',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    none ? 'всё верно' : 'исправить',
                    style: TextStyle(
                      color: none ? c.muted : c.badText,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.mistake, this.rule, this.word});

  final Mistake mistake;
  final (GrammarRule, GrammarGroup)? rule;
  final Word? word;

  static String _kind(MistakeKind k) => switch (k) {
    MistakeKind.word => 'СЛОВО',
    MistakeKind.grammar => 'ПРАВИЛО',
    MistakeKind.sentence => 'ПРЕДЛОЖЕНИЕ',
    MistakeKind.dialogue => 'ДИАЛОГ',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final m = mistake;
    return SurfaceCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      onTap: word == null ? null : () => showWordSheet(context, word!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _kind(m.kind),
                style: TextStyle(
                  color: c.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                m.times > 1
                    ? '${m.times} ${plural(m.times, 'раз', 'раза', 'раз')}'
                    : dayMonth(m.lastAt),
                style: TextStyle(color: c.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            m.prompt,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          if (m.given.isNotEmpty)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Ваш ответ: ',
                    style: TextStyle(color: c.muted),
                  ),
                  TextSpan(
                    text: m.given,
                    style: TextStyle(
                      color: c.badText,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Правильно: ',
                  style: TextStyle(color: c.muted),
                ),
                TextSpan(
                  text: m.answer,
                  style: TextStyle(
                    color: c.okText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (rule case (final r, final g)?) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Почему так? ${grammarParts.firstWhere((p) => p.id == g.part).title}, '
                    'правило ${r.number} «${r.title}»',
                    style: TextStyle(
                      color: c.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/rules/${r.id}'),
                      child: const Text('Открыть правило'),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (word != null) ...[
            const SizedBox(height: 4),
            Text(
              'Нажмите, чтобы открыть карточку слова с примером',
              style: TextStyle(color: c.muted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
