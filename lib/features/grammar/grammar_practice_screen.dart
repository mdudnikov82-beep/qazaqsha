import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/gold_button.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../dialogues/dialogues.dart';
import 'grammar.dart';

/// Exercises of one rule ([ruleId]) or a check-up of a topic ([groupId]).
/// Wrong answers come back once at the end, like in lessons.
class GrammarPracticeScreen extends ConsumerStatefulWidget {
  const GrammarPracticeScreen.rule({super.key, required String this.ruleId})
    : groupId = null,
      dialogueId = null,
      mistakes = false;

  const GrammarPracticeScreen.group({super.key, required String this.groupId})
    : ruleId = null,
      dialogueId = null,
      mistakes = false;

  /// Tasks from the mistakes notebook.
  const GrammarPracticeScreen.mistakes({super.key})
    : ruleId = null,
      groupId = null,
      dialogueId = null,
      mistakes = true;

  /// Comprehension tasks of a dialogue.
  const GrammarPracticeScreen.dialogue({
    super.key,
    required String this.dialogueId,
  }) : ruleId = null,
       groupId = null,
       mistakes = false;

  final String? ruleId;
  final String? groupId;
  final String? dialogueId;
  final bool mistakes;

  MistakeKind get mistakeKind =>
      dialogueId != null ? MistakeKind.dialogue : MistakeKind.grammar;

  @override
  ConsumerState<GrammarPracticeScreen> createState() =>
      _GrammarPracticeScreenState();
}

class _GrammarPracticeScreenState extends ConsumerState<GrammarPracticeScreen> {
  final _random = Random();
  final _clock = Stopwatch()..start();

  List<GrammarTask>? _queue;
  GrammarRule? _rule;
  String _title = '';
  int _total = 0;
  int _index = 0;
  List<String> _options = const [];
  String? _picked;
  int _correct = 0;
  final _missed = <GrammarTask>{};
  bool _retrying = false;
  ({int score, int xp})? _result;

  /// Open grammar mistakes, as task refs; loaded before the first start.
  List<String>? _mistakeRefs;

  Dialogue? _dialogue;

  void _start(List<GrammarGroup> all, List<Dialogue> dialogues) {
    final List<GrammarTask> tasks;
    if (widget.dialogueId case final id?) {
      final d = dialogues.firstWhere((x) => x.id == id);
      _dialogue = d;
      _title = d.titleKk;
      tasks = [...d.tasks]..shuffle(_random);
    } else if (widget.mistakes) {
      final byRef = {
        for (final g in all)
          for (final r in g.rules)
            for (final t in r.tasks) t.ref: t,
      };
      _title = 'Работа над ошибками';
      tasks = [for (final ref in _mistakeRefs ?? const <String>[]) ?byRef[ref]]
          .take(grammarGroupTestSize)
          .toList();
    } else if (widget.ruleId case final id?) {
      final rule = [for (final g in all) ...g.rules]
          .firstWhere((r) => r.id == id);
      _rule = rule;
      _title = '${rule.number}. ${rule.title}';
      tasks = [...rule.tasks]..shuffle(_random);
    } else {
      final group = all.firstWhere((g) => g.id == widget.groupId);
      _title = 'Проверка: ${group.title}';
      tasks = ([
        for (final r in group.rules) ...r.tasks,
      ]..shuffle(_random)).take(grammarGroupTestSize).toList();
    }
    _queue = tasks;
    _total = tasks.length;
    if (tasks.isEmpty) return;
    _index = 0;
    _correct = 0;
    _missed.clear();
    _retrying = false;
    _result = null;
    _picked = null;
    _options = tasks.first.options(_random);
  }

  void _pick(String option) {
    if (_picked != null) return;
    final task = _queue![_index];
    final right = option == task.answer;
    right ? Haptics.success() : Haptics.error();
    final notebook = ref.read(mistakesRepositoryProvider);
    if (right) {
      notebook.resolve(widget.mistakeKind, task.ref);
    } else {
      notebook.record(
        kind: widget.mistakeKind,
        ref: task.ref,
        prompt: task.question,
        answer: task.answer,
        given: option,
      );
    }
    setState(() {
      _picked = option;
      if (_index < _total) {
        if (right) {
          _correct++;
        } else {
          _missed.add(task);
        }
      }
    });
  }

  Future<void> _next() async {
    final queue = _queue!;
    if (_index == _total - 1 && !_retrying && _missed.isNotEmpty) {
      // Mistakes once more, for practice; the score is already counted.
      queue.addAll(_missed);
      _retrying = true;
    }
    if (_index + 1 < queue.length) {
      setState(() {
        _index++;
        _picked = null;
        _options = queue[_index].options(_random);
      });
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final score = (100 * _correct / _total).round();
    final xp =
        _correct * grammarXpPerAnswer +
        (_correct == _total ? grammarPerfectBonus : 0);
    final now = DateTime.now();
    if (_rule case final rule?) {
      await ref.read(grammarRepositoryProvider).record(rule.id, score, now);
    }
    if (_dialogue case final d?) {
      await ref
          .read(grammarRepositoryProvider)
          .record(d.progressKey, score, now);
    }
    if (!mounted) return;
    await ref
        .read(statsRepositoryProvider)
        .recordSession(
          xp: xp,
          correct: _correct,
          total: _total,
          now: now,
          studySeconds: _clock.elapsed.inSeconds.clamp(0, 3600),
        );
    if (mounted) setState(() => _result = (score: score, xp: xp));
  }

  @override
  Widget build(BuildContext context) {
    final grammar = ref.watch(grammarProvider).value;
    final dialogues = ref.watch(dialoguesProvider).value;
    if (grammar == null || dialogues == null) return const LoadingScaffold();
    if (widget.mistakes && _mistakeRefs == null) {
      ref
          .read(mistakesRepositoryProvider)
          .openRefs(MistakeKind.grammar)
          .then((refs) => mounted ? setState(() => _mistakeRefs = refs) : null);
      return const LoadingScaffold();
    }
    if (_queue == null) _start(grammar, dialogues);
    if (_queue!.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Ошибок в правилах нет — отлично!')),
      );
    }
    if (_result case final r?) {
      return _resultView(context, grammar, dialogues, r);
    }

    final c = context.colors;
    final task = _queue![_index];
    final answered = _picked != null;
    final right = _picked == task.answer;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Закрыть',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProgressBar(
                value: _index / _queue!.length,
                semanticsLabel: 'Задание ${_index + 1} из ${_queue!.length}',
              ),
              if (_retrying && _index >= _total) ...[
                const SizedBox(height: 8),
                Text(
                  'Повторим ошибки',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.goldText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                task.hint.isEmpty ? 'Выберите ответ' : task.hint,
                style: TextStyle(color: c.muted, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                answered ? task.solved : task.question,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              for (final o in _options) ...[
                ReactionBox(
                  reaction: !answered
                      ? Reaction.none
                      : o == task.answer
                      ? Reaction.pop
                      : o == _picked
                      ? Reaction.shake
                      : Reaction.none,
                  child: _Option(
                    text: o,
                    state: !answered
                        ? _OptionState.idle
                        : o == task.answer
                        ? _OptionState.right
                        : o == _picked
                        ? _OptionState.wrong
                        : _OptionState.dim,
                    onTap: () => _pick(o),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const Spacer(),
              if (answered)
                SlideUp(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: right ? c.okSoft : c.badSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          right
                              ? 'Дұрыс! Правильно'
                              : 'Қате. Правильно: ${task.answer}',
                          style: TextStyle(
                            color: right ? c.okText : c.badText,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: right
                                ? AppColors.okButton
                                : AppColors.badButton,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          onPressed: _next,
                          child: const Text('Дальше'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultView(
    BuildContext context,
    List<GrammarGroup> grammar,
    List<Dialogue> dialogues,
    ({int score, int xp}) r,
  ) {
    final c = context.colors;
    final passed = r.score >= grammarPassScore;
    final rule = _rule;
    final part = grammar
        .firstWhere((g) => rule == null || g.rules.contains(rule))
        .part;
    final rules = rulesOfPart(grammar, part);
    final next = rule == null
        ? null
        : rules.skipWhile((x) => x.id != rule.id).skip(1).firstOrNull;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                size: 72,
                color: passed ? AppColors.gold : c.accent,
              ),
              const SizedBox(height: 12),
              Text(
                passed
                    ? (widget.dialogueId != null
                          ? 'Диалог понят!'
                          : widget.mistakes
                          ? 'Ошибки исправлены!'
                          : rule == null
                          ? 'Тема проверена!'
                          : 'Правило изучено!')
                    : 'Почти! Попробуйте ещё раз',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Верно $_correct из $_total · ${r.score}%'
                '${ref.watch(quietModeProvider) ? '' : ' · +${r.xp} XP'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.muted,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!passed) ...[
                const SizedBox(height: 6),
                Text(
                  'Правило считается изученным от $grammarPassScore%.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.muted),
                ),
              ],
              const SizedBox(height: 28),
              if (passed && next != null)
                GoldButton(
                  label: 'Следующее правило',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => context.pushReplacement('/rules/${next.id}'),
                )
              else
                GoldButton(
                  label: 'Ещё раз',
                  icon: Icons.replay_rounded,
                  onPressed: () => setState(() => _start(grammar, dialogues)),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () => context.pop(),
                child: const Text('Готово'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _OptionState { idle, right, wrong, dim }

class _Option extends StatelessWidget {
  const _Option({required this.text, required this.state, required this.onTap});

  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, border) = switch (state) {
      _OptionState.idle => (c.surface, c.ink, c.line),
      _OptionState.right => (c.okSoft, c.okText, c.ok),
      _OptionState.wrong => (c.badSoft, c.badText, c.bad),
      _OptionState.dim => (c.surface, c.muted, c.line),
    };
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: state == _OptionState.idle ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
