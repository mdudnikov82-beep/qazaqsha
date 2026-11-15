import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/bead_progress.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/gold_button.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../dialogues/dialogues.dart';
import '../gamification/quests.dart';
import '../quiz/quiz_session.dart';
import '../quiz/quiz_views.dart' show FixTiles;
import 'grammar.dart';
import 'rules_screen.dart' show partColor;

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

  /// Mistakes answered right on the retry round.
  int _fixed = 0;
  ({int score, int xp})? _result;

  /// Tasks shown as «find the mistake» on the first round.
  final _fixes = <GrammarTask, GrammarFix>{};

  /// The tile tapped in a «find the mistake» task.
  int? _pickedTile;

  /// «Find the mistake» tasks answered right, for the weekly quests.
  int _fixesFound = 0;

  /// The current task's «find the mistake» form, if it has one.
  GrammarFix? get _fix => _index < _total ? _fixes[_queue![_index]] : null;

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
    _fixes.clear();
    _pickedTile = null;
    _fixesFound = 0;
    final fixes = widget.ruleId != null
        ? grammarFixesPerRule
        : widget.groupId != null
        ? grammarFixesPerGroup
        : 0;
    for (final t in tasks) {
      if (_fixes.length == fixes) break;
      final wrong = t.wrong[_random.nextInt(t.wrong.length)];
      if (grammarFix(t, wrong) case final f?) _fixes[t] = f;
    }
    if (tasks.isEmpty) return;
    _index = 0;
    _correct = 0;
    _missed.clear();
    _retrying = false;
    _fixed = 0;
    _result = null;
    _picked = null;
    _options = tasks.first.options(_random);
  }

  void _pickTile(int i) {
    if (_pickedTile != null) return;
    final fix = _fix!;
    _pickedTile = i;
    if (i == fix.at) _fixesFound++;
    _answer(right: i == fix.at, given: fix.tokens[i]);
  }

  void _pick(String option) {
    if (_picked != null) return;
    _picked = option;
    _answer(right: option == _queue![_index].answer, given: option);
  }

  void _answer({required bool right, required String given}) {
    final task = _queue![_index];
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
        given: given,
      );
    }
    setState(() {
      if (_index < _total) {
        if (right) {
          _correct++;
        } else {
          _missed.add(task);
        }
      } else if (right) {
        _fixed++;
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
        _pickedTile = null;
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
        _fixed.clamp(0, fixedMistakeCap) * fixedMistakeXp;
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
    final quests = ref.read(questRepositoryProvider);
    if (_dialogue != null) {
      await quests.add(QuestKey.dialogues, now);
    } else if (!widget.mistakes) {
      await quests.add(QuestKey.rules, now);
    }
    await quests.add(QuestKey.fixes, now, _fixesFound);
    await quests.add(QuestKey.fixed, now, _fixed);
    await quests.add(
      QuestKey.seconds,
      now,
      _clock.elapsed.inSeconds.clamp(0, 3600),
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
    final fix = _fix;
    final answered = _picked != null || _pickedTile != null;
    final right = fix != null ? _pickedTile == fix.at : _picked == task.answer;
    final tint = _tint(grammar, c);
    final retry = _retrying && _index >= _total;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Закрыть',
                    icon: Icon(Icons.close_rounded, color: c.muted),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: BeadProgress(
                      done: _index,
                      total: _queue!.length,
                      color: tint,
                      semanticsLabel:
                          'Задание ${_index + 1} из ${_queue!.length}',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${_index + 1}/${_queue!.length}',
                    style: TextStyle(
                      color: c.muted,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
              child: Text(
                retry ? 'ПОВТОРИМ ОШИБКИ' : _title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: retry ? c.goldText : tint,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(_index),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        TintIcon(
                          fix != null
                              ? Icons.search_rounded
                              : Icons.edit_note_rounded,
                          color: tint,
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            fix != null
                                ? 'Найдите ошибку'
                                : task.question.contains('___')
                                ? 'Вставьте пропущенное'
                                : 'Выберите ответ',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: tint.withValues(alpha: .35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tint.withValues(alpha: .12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.hint.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 18,
                                    color: tint,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    task.hint,
                                    style: TextStyle(
                                      color: c.muted,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (fix != null) ...[
                            Text(
                              'Одно слово здесь неправильное. Нажмите на него.',
                              style: TextStyle(color: c.muted),
                            ),
                            const SizedBox(height: 12),
                            FixTiles(
                              tokens: fix.tokens,
                              wrongIndex: fix.at,
                              right: fix.right,
                              picked: _pickedTile,
                              onPick: _pickTile,
                            ),
                          ] else
                            _GapSentence(
                              question: task.question,
                              filled: answered ? task.answer : null,
                              tint: tint,
                            ),
                        ],
                      ),
                    ),
                    if (fix == null) ...[
                      const SizedBox(height: 18),
                      for (final (k, o) in _options.indexed) ...[
                        ReactionBox(
                          reaction: !answered
                              ? Reaction.none
                              : o == task.answer
                              ? Reaction.pop
                              : o == _picked
                              ? Reaction.shake
                              : Reaction.none,
                          child: _Option(
                            letter: 'АБВГДЕ'[k],
                            text: o,
                            tint: tint,
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
                    ],
                  ],
                ),
              ),
            ),
            if (answered)
              SlideUp(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: right ? c.okSoft : c.goldSoft,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: right
                                  ? AppColors.okButton
                                  : AppColors.tryButton,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              right
                                  ? Icons.check_rounded
                                  : Icons.lightbulb_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              right ? 'Дұрыс! Правильно' : 'Пока неверно',
                              style: TextStyle(
                                color: right ? c.okText : c.goldText,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        switch (fix) {
                          null =>
                            right ? task.solved : 'Правильно: ${task.answer}',
                          final f => '«${f.tokens[f.at]}» → «${f.right}»',
                        },
                        style: TextStyle(
                          color: right ? c.okText : c.goldText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!right && !retry) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Вопрос повторится в конце.',
                          style: TextStyle(
                            color: c.goldText,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      FilledButton(
                        autofocus: true,
                        style: FilledButton.styleFrom(
                          backgroundColor: right
                              ? AppColors.okButton
                              : AppColors.tryButton,
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: _next,
                        child: const Text('Дальше'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.track,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    fix != null
                        ? 'Нажмите на неправильное слово'
                        : 'Нажмите на вариант ответа',
                    style: TextStyle(
                      color: c.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The colour of what is practised: its part of speech, a dialogue's
  /// accent, gold for the mistakes notebook.
  Color _tint(List<GrammarGroup> grammar, AppColors c) {
    if (_dialogue != null) return c.accent;
    if (widget.mistakes) return c.goldText;
    final id = widget.groupId;
    final group = grammar.firstWhere(
      (g) => id != null ? g.id == id : g.rules.contains(_rule),
      orElse: () => grammar.first,
    );
    return partColor(group.part);
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

/// An answer option with its letter, in the colour of the rule.
class _Option extends StatelessWidget {
  const _Option({
    required this.letter,
    required this.text,
    required this.tint,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final Color tint;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, border) = switch (state) {
      _OptionState.idle => (c.surface, c.ink, c.line),
      _OptionState.right => (c.okSoft, c.okText, c.ok),
      _OptionState.wrong => (c.goldSoft, c.goldText, AppColors.tryButton),
      _OptionState.dim => (c.surface, c.muted, c.line),
    };
    final badge = switch (state) {
      _OptionState.right => c.ok,
      _OptionState.wrong => AppColors.tryButton,
      _OptionState.idle => tint,
      _OptionState.dim => c.lockIcon,
    };
    return Semantics(
      button: true,
      label: text,
      excludeSemantics: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: state == _OptionState.idle ? onTap : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border(
                top: BorderSide(color: border, width: 2),
                left: BorderSide(color: border, width: 2),
                right: BorderSide(color: border, width: 2),
                bottom: BorderSide(color: border, width: 4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      badge.withValues(alpha: .14),
                      c.surface,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: state == _OptionState.right
                      ? Icon(Icons.check_rounded, color: badge, size: 20)
                      : Text(
                          letter,
                          style: TextStyle(
                            color: badge,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The task sentence with its gap drawn as a box: empty while answering,
/// then holding the right answer.
class _GapSentence extends StatelessWidget {
  const _GapSentence({
    required this.question,
    required this.filled,
    required this.tint,
  });

  final String question;
  final String? filled;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const style = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w900,
      height: 1.4,
    );
    final i = question.indexOf('___');
    if (i < 0) return Text(question, style: style);
    final gap = Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      constraints: const BoxConstraints(minWidth: 64),
      decoration: BoxDecoration(
        color: filled == null
            ? Color.alphaBlend(tint.withValues(alpha: .10), c.surface)
            : c.okSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          bottom: BorderSide(color: filled == null ? tint : c.ok, width: 3),
        ),
      ),
      child: Text(
        filled ?? ' ',
        textAlign: TextAlign.center,
        style: style.copyWith(color: filled == null ? tint : c.okText),
      ),
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: question.substring(0, i)),
          WidgetSpan(alignment: PlaceholderAlignment.middle, child: gap),
          TextSpan(text: question.substring(i + 3)),
        ],
      ),
      semanticsLabel: question.replaceFirst('___', filled ?? 'пропуск'),
      style: style,
    );
  }
}
