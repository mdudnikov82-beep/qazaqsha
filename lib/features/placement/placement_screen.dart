import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/barys.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/gold_button.dart';
import '../../data/database/app_database.dart';
import '../../data/providers.dart';
import '../lessons/sections.dart';

/// Tasks per section in the placement test.
const placementPerSection = 2;

/// One placement task: which section it checks, the word, the options.
class PlacementTask {
  const PlacementTask(this.section, this.word, this.options);

  final int section;
  final Word word;
  final List<String> options;
}

/// Two words of every section, Russian → Kazakh, with options from the
/// same section so they are equally hard.
List<PlacementTask> buildPlacement(List<Word> words, Random random) {
  final tasks = <PlacementTask>[];
  for (final (i, s) in courseSections.indexed) {
    final pool = [
      for (final w in words)
        if (s.categoryIds.contains(w.categoryId) && !w.kk.contains('…')) w,
    ]..shuffle(random);
    for (final w in pool.take(placementPerSection)) {
      final wrong = {
        for (final o in pool)
          if (o.kk != w.kk) o.kk,
      }.take(3);
      tasks.add(PlacementTask(i, w, [w.kk, ...wrong]..shuffle(random)));
    }
  }
  return tasks;
}

/// Where to start: the first section not answered fully right.
int placementStart(Map<int, int> rightBySection) {
  for (var i = 0; i < courseSections.length; i++) {
    if ((rightBySection[i] ?? 0) < placementPerSection) return i;
  }
  return courseSections.length;
}

/// «Определи уровень»: for people who already know some Kazakh.
class PlacementScreen extends ConsumerStatefulWidget {
  const PlacementScreen({super.key});

  @override
  ConsumerState<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends ConsumerState<PlacementScreen> {
  List<PlacementTask>? _tasks;
  var _index = 0;
  var _started = false;
  String? _picked;
  final _right = <int, int>{};
  final _wrong = <int, int>{};
  int? _start;
  bool _saving = false;

  void _pick(String option) {
    if (_picked != null) return;
    final task = _tasks![_index];
    final ok = option == task.word.kk;
    ok ? Haptics.success() : Haptics.error();
    setState(() {
      _picked = option;
      final map = ok ? _right : _wrong;
      map[task.section] = (map[task.section] ?? 0) + 1;
    });
  }

  void _next() {
    final tasks = _tasks!;
    final section = tasks[_index].section;
    final sectionDone =
        _index + 1 == tasks.length || tasks[_index + 1].section != section;
    // A section with no right answer at all ends the test there.
    final stop = sectionDone && (_wrong[section] ?? 0) >= placementPerSection;
    if (_index + 1 >= tasks.length || stop) {
      setState(() => _start = placementStart(_right));
      return;
    }
    setState(() {
      _index++;
      _picked = null;
    });
  }

  Future<void> _apply() async {
    setState(() => _saving = true);
    final start = _start!;
    await ref
        .read(lessonRepositoryProvider)
        .placeBefore(courseSections.take(start).toList(), DateTime.now());
    // Taken from the welcome flow: that counts as having finished it.
    final stats = ref.read(statsRepositoryProvider);
    final s = await stats.get();
    if (!s.onboardingDone) {
      await stats.completeOnboarding(dailyGoalXp: s.dailyGoalXp);
    }
    if (mounted) context.go('/lessons');
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(allWordsProvider).value;
    if (words == null) return const LoadingScaffold();
    _tasks ??= buildPlacement(words, Random());
    final c = context.colors;

    if (!_started) {
      return _Intro(onStart: () => setState(() => _started = true));
    }
    if (_start case final start?) {
      return _Result(start: start, saving: _saving, onApply: _apply);
    }

    final task = _tasks![_index];
    final answered = _picked != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Закрыть',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Определи уровень'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProgressBar(
                value: _index / _tasks!.length,
                semanticsLabel: 'Задание ${_index + 1}',
              ),
              const SizedBox(height: 8),
              Text(
                'Раздел ${task.section + 1} · ${courseSections[task.section].title}',
                style: TextStyle(color: c.muted, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              Text('Как по-казахски?', style: TextStyle(color: c.muted)),
              Text(
                task.word.ru,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              for (final o in task.options) ...[
                _Choice(
                  text: o,
                  state: !answered
                      ? 0
                      : o == task.word.kk
                      ? 1
                      : o == _picked
                      ? 2
                      : 3,
                  onTap: () => _pick(o),
                ),
                const SizedBox(height: 10),
              ],
              const Spacer(),
              TextButton(
                onPressed: answered ? null : () => _pick(''),
                child: const Text('Не знаю'),
              ),
              if (answered)
                FilledButton(onPressed: _next, child: const Text('Дальше')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.text, required this.state, required this.onTap});

  final String text;

  /// 0 idle, 1 right, 2 wrong pick, 3 other.
  final int state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, border) = switch (state) {
      1 => (c.okSoft, c.ok),
      2 => (c.badSoft, c.bad),
      _ => (c.surface, c.line),
    };
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: state == 0 ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: state == 3 ? c.muted : c.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            const Center(child: Barys(size: 150)),
            const SizedBox(height: 10),
            const Text(
              'Определи уровень',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Уже знаете казахский немного? По два слова из каждого раздела '
              '— и курс начнётся там, где вам интересно. Около 3 минут. '
              'Не знаете ответ — так и нажмите «Не знаю».',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted, fontSize: 16, height: 1.35),
            ),
            const SizedBox(height: 28),
            GoldButton(
              label: 'Начать тест',
              icon: Icons.play_arrow_rounded,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.start,
    required this.saving,
    required this.onApply,
  });

  final int start;
  final bool saving;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final all = start >= courseSections.length;
    final section = all ? null : courseSections[start];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Center(
              child: Barys(
                mood: start == 0 ? BarysMood.hello : BarysMood.proud,
                size: 150,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              start == 0
                  ? 'Начнём с основ!'
                  : all
                  ? 'Вы знаете весь курс — керемет!'
                  : 'Начнём с раздела ${start + 1}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              start == 0
                  ? 'Так даже лучше: основы сделают всё остальное лёгким.'
                  : all
                  ? 'Все разделы будут открыты. Повторяйте слова и правила.'
                  : '«${section!.title} · ${section.titleKk}». Разделы 1–$start '
                        'будут отмечены пройденными; их слова останутся в '
                        'словаре — повторить можно карточками.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted, fontSize: 16, height: 1.35),
            ),
            const SizedBox(height: 28),
            if (start > 0) ...[
              GoldButton(
                label: 'Начать отсюда',
                icon: Icons.flag_rounded,
                onPressed: saving ? () {} : onApply,
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => context.pop(),
              child: Text(
                start > 0 ? 'Нет, пройду всё по порядку' : 'К урокам',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
