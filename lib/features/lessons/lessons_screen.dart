import 'dart:math';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/motion.dart';
import '../../core/widgets/barys.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/ornament.dart';
import '../../data/providers.dart';
import '../../data/repositories/lesson_repository.dart';
import '../gamification/progress_rules.dart';
import '../quiz/quiz_session.dart';
import 'sections.dart';

// Ladder geometry.
const _stepGap = 88.0;
const _stepSize = 60.0;
const _currentSize = 76.0;
const _bannerHeight = 88.0;
const _examSize = 72.0;
const _bubbleWidth = 190.0;

enum _StepState { done, current, locked }

class _Step {
  _Step(this.topic, this.index, this.at, this.color, this.state);

  final TopicState topic;
  final int index;
  final Offset at;
  final Color color;
  final _StepState state;

  String get key => '${topic.category.id}/$index';
}

class _Track {
  _Track(this.points, this.donePoints, this.color);

  final List<Offset> points;

  /// How many of [points], from the start, are reached (done or current).
  final int donePoints;
  final Color color;
}

/// Positions of everything on the ladder, for a given width.
class _Ladder {
  final banners = <(SectionState, double)>[];
  final steps = <_Step>[];
  final exams = <(SectionState, Offset, bool)>[];
  final tracks = <_Track>[];

  /// Section id, colour, and the stretch of the map it covers.
  final zones = <(String, Color, double, double)>[];
  double height = 0;

  _Step? get current {
    for (final s in steps) {
      if (s.state == _StepState.current) return s;
    }
    return null;
  }

  static _Ladder build(CourseState course, double width) {
    final ladder = _Ladder();
    final cx = width / 2;
    final amp = min(110.0, width / 2 - 64);
    final next = course.next;
    var y = 0.0;
    var k = 0;
    for (final s in course.sections) {
      final zoneTop = y;
      ladder.banners.add((s, y));
      y += _bannerHeight + 56;
      final points = <Offset>[];
      var reached = 0;
      for (final t in s.topics) {
        for (var i = 0; i < t.lessonCount; i++) {
          final at = Offset(cx + amp * sin(k * 0.85), y);
          final isCurrent =
              next is NextLesson &&
              next.topic.category.id == t.category.id &&
              next.topic.nextLesson == i;
          final state = i < t.lessonsDone
              ? _StepState.done
              : isCurrent
              ? _StepState.current
              : _StepState.locked;
          ladder.steps.add(_Step(t, i, at, s.section.color, state));
          points.add(at);
          if (state != _StepState.locked) reached = points.length;
          y += _stepGap;
          k++;
        }
      }
      final examAt = Offset(cx, y + 4);
      final examCurrent =
          next is NextExam && next.section.section.id == s.section.id;
      ladder.exams.add((s, examAt, examCurrent));
      points.add(examAt);
      if (s.examPassed || examCurrent) reached = points.length;
      ladder.tracks.add(_Track(points, reached, s.section.color));
      y += _examSize + 64;
      ladder.zones.add((s.section.id, s.section.color, zoneTop, y));
    }
    ladder.height = y;
    return ladder;
  }
}

class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  final _currentKey = GlobalKey();
  String? _selected;
  bool _scrolled = false;

  /// Brings the current step into view once, when the ladder first shows.
  void _scrollToCurrentOnce() {
    if (_scrolled) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _currentKey.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(courseProvider);
    final stats = ref.watch(statsProvider);
    if (course.value == null || stats.value == null) {
      return LoadingScaffold(error: course.error ?? stats.error);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Жол картасы'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/placement'),
            icon: const Icon(Icons.speed_rounded),
            label: const Text('Мой уровень'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LevelCard(xp: stats.value!.xp),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, box) {
                final ladder = _Ladder.build(course.value!, box.maxWidth);
                _scrollToCurrentOnce();
                final selected =
                    ladder.steps.where((s) => s.key == _selected).firstOrNull ??
                    ladder.current;
                return SizedBox(
                  height: ladder.height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _LandscapePainter(
                            ladder.zones,
                            ground: context.colors.bg,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TrackPainter(
                            ladder.tracks,
                            dotColor: context.colors.line,
                          ),
                        ),
                      ),
                      for (final (s, top) in ladder.banners)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: top,
                          height: _bannerHeight,
                          child: _SectionBanner(section: s),
                        ),
                      for (final step in ladder.steps)
                        if (step.index == 0) _topicChip(step, box.maxWidth),
                      for (final step in ladder.steps)
                        Positioned(
                          left: step.at.dx - _sizeOf(step) / 2,
                          top: step.at.dy - _sizeOf(step) / 2,
                          child: _StepNode(
                            key: step.state == _StepState.current
                                ? _currentKey
                                : null,
                            step: step,
                            onTap: () => _tapStep(step),
                          ),
                        ),
                      for (final (s, at, current) in ladder.exams)
                        _examNode(s, at, current, box.maxWidth),
                      if (ladder.current case final cur?)
                        Positioned(
                          left: cur.at.dx > box.maxWidth / 2
                              ? cur.at.dx - _currentSize / 2 - 58
                              : cur.at.dx + _currentSize / 2 + 4,
                          top: cur.at.dy - 56,
                          child: const IgnorePointer(
                            child: Barys(size: 54, animate: false),
                          ),
                        ),
                      if (selected != null) _bubble(selected, box.maxWidth),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static double _sizeOf(_Step s) =>
      s.state == _StepState.current ? _currentSize : _stepSize;

  void _tapStep(_Step step) {
    if (step.state == _StepState.locked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Сначала пройдите предыдущие уроки')),
        );
      return;
    }
    Haptics.tap();
    setState(() => _selected = step.key);
  }

  Widget _topicChip(_Step first, double width) {
    final c = context.colors;
    final t = first.topic;
    final onRight = first.at.dx < width / 2;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon(t.category.icon),
            size: 16,
            color: t.unlocked ? first.color : c.muted,
          ),
          const SizedBox(width: 6),
          Text(
            '${t.category.titleKk} · ${t.lessonsDone}/${t.lessonCount}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: t.unlocked ? c.ink : c.muted,
            ),
          ),
        ],
      ),
    );
    final gap = _stepSize / 2 + 12;
    return Positioned(
      top: first.at.dy - 15,
      left: onRight ? first.at.dx + gap : null,
      right: onRight ? null : width - first.at.dx + gap,
      child: chip,
    );
  }

  Widget _examNode(SectionState s, Offset at, bool current, double width) {
    final c = context.colors;
    final open = s.examUnlocked;
    final lit = open || s.examPassed;
    final best = s.examBestScore;
    final status = s.examPassed
        ? 'Сдан · $best%'
        : open
        ? best == null
              ? 'Нужно $examPassScore% · +$examPassBonusXp XP'
              : 'Лучший $best% · нужно $examPassScore%'
        : 'После всех уроков';
    return Positioned(
      left: at.dx - _examSize / 2,
      top: at.dy - _examSize / 2,
      child: Semantics(
        button: open,
        label: 'Экзамен «${s.section.title}»: $status',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: open ? () => context.push('/exam/${s.section.id}') : null,
          child: Row(
            children: [
              SizedBox(
                width: _examSize,
                height: _examSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: pi / 4,
                      child: Container(
                        width: _examSize * 0.78,
                        height: _examSize * 0.78,
                        decoration: BoxDecoration(
                          color: lit ? AppColors.gold : c.track,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: lit ? const Color(0xFFC99700) : c.line,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      s.examPassed
                          ? Icons.workspace_premium_rounded
                          : lit
                          ? Icons.emoji_events_rounded
                          : Icons.lock_rounded,
                      color: lit ? AppColors.onGold : c.lockIcon,
                      size: 30,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Емтихан',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: lit ? c.goldText : c.muted,
                    ),
                  ),
                  Text(status, style: TextStyle(fontSize: 12, color: c.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble(_Step step, double width) {
    final r = _sizeOf(step) / 2;
    // On the side with more room, the arrow pointing at the node.
    final onRight = step.at.dx < width / 2;
    final left = onRight
        ? step.at.dx + r + 12
        : step.at.dx - r - 12 - _bubbleWidth;
    final current = step.state == _StepState.current;
    final path = '/lesson/${step.topic.category.id}/${step.index}';
    return Positioned(
      left: left.clamp(0, width - _bubbleWidth),
      top: step.at.dy - 52,
      width: _bubbleWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 44,
            left: onRight ? -7 : null,
            right: onRight ? null : -7,
            child: Transform.rotate(
              angle: pi / 4,
              child: Container(
                width: 16,
                height: 16,
                color: const Color(0xFF13232E),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF13232E),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step.topic.category.titleKk,
                  style: const TextStyle(
                    color: Color(0xFF9DB0BB),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Урок ${step.index + 1} из ${step.topic.lessonCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.onGold,
                    minimumSize: const Size(0, 40),
                    textStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () => context.push(path),
                  child: Text(
                    current ? 'Начать · +$lessonBonusXp XP' : 'Повторить',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter(this.tracks, {required this.dotColor});

  final List<_Track> tracks;
  final Color dotColor;

  static Path _curve(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      final dy = (b.dy - a.dy) / 2;
      path.cubicTo(a.dx, a.dy + dy, b.dx, b.dy - dy, b.dx, b.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = dotColor;
    final solid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    for (final t in tracks) {
      if (t.points.length < 2) continue;
      // The whole way as dots, then the reached part as a solid line.
      for (final PathMetric m in _curve(t.points).computeMetrics()) {
        for (var d = 0.0; d < m.length; d += 22) {
          final pos = m.getTangentForOffset(d)?.position;
          if (pos != null) canvas.drawCircle(pos, 6, dot);
        }
      }
      if (t.donePoints >= 2) {
        canvas.drawPath(
          _curve(t.points.sublist(0, t.donePoints)),
          solid..color = t.color.withValues(alpha: 0.85),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TrackPainter old) => true;
}

class _StepNode extends StatefulWidget {
  const _StepNode({super.key, required this.step, required this.onTap});

  final _Step step;
  final VoidCallback onTap;

  @override
  State<_StepNode> createState() => _StepNodeState();
}

class _StepNodeState extends State<_StepNode>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(_StepNode old) {
    super.didUpdateWidget(old);
    _syncPulse();
  }

  void _syncPulse() {
    final on =
        widget.step.state == _StepState.current && !reduceMotion(context);
    if (on && !_pulse.isAnimating) _pulse.repeat();
    if (!on) _pulse.stop();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = widget.step;
    final label =
        '${s.topic.category.titleKk}, урок ${s.index + 1}, '
        '${switch (s.state) {
          _StepState.done => 'пройден',
          _StepState.current => 'следующий',
          _StepState.locked => 'закрыт',
        }}';

    final Widget node = switch (s.state) {
      _StepState.done => _Disc(
        size: _stepSize,
        color: s.color,
        shadow: Color.lerp(s.color, Colors.black, 0.25)!,
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
      ),
      _StepState.current => SizedBox(
        width: _currentSize,
        height: _currentSize,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) => _pulse.isAnimating
                  ? Transform.scale(
                      scale: 1 + _pulse.value * 0.55,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: s.color.withValues(
                              alpha: 0.55 * (1 - _pulse.value),
                            ),
                            width: 4,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Container(
              decoration: BoxDecoration(
                color: c.surface,
                shape: BoxShape.circle,
                border: Border.all(color: s.color, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: s.color.withValues(alpha: 0.3),
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(Icons.play_arrow_rounded, color: s.color, size: 40),
            ),
          ],
        ),
      ),
      _StepState.locked => _Disc(
        size: _stepSize,
        color: c.track,
        shadow: c.line,
        child: Icon(Icons.lock_rounded, color: c.lockIcon, size: 22),
      ),
    };

    return Semantics(
      button: s.state != _StepState.locked,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(onTap: widget.onTap, child: node),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({
    required this.size,
    required this.color,
    required this.shadow,
    required this.child,
  });

  final double size;
  final Color color;
  final Color shadow;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 5))],
    ),
    child: child,
  );
}

class _SectionBanner extends StatelessWidget {
  const _SectionBanner({required this.section});

  final SectionState section;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = section;
    final number = courseSections.indexOf(s.section) + 1;
    final total = s.topics.fold(0, (sum, t) => sum + t.lessonCount);
    final done = s.topics.fold(0, (sum, t) => sum + t.lessonsDone);
    final open = s.unlocked;
    final bg = open ? s.section.color : c.track;
    final fg = open ? Colors.white : c.muted;
    return Semantics(
      label:
          'Раздел $number, ${s.section.title}: пройдено $done из $total'
          '${open ? '' : ', закрыт'}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -14,
              top: -8,
              child: RamHorns(
                width: 150,
                color: (open ? AppColors.gold : c.lockIcon).withValues(
                  alpha: 0.25,
                ),
                strokeWidth: 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: open ? AppColors.gold : c.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: open
                          ? Text(
                              '$number',
                              style: const TextStyle(
                                color: AppColors.onGold,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : Icon(Icons.lock_rounded, color: c.lockIcon),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'РАЗДЕЛ $number · ${s.section.titleKk.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: fg.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          s.section.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: fg,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ProgressBar(
                          value: total == 0 ? 0 : done / total,
                          height: 8,
                          color: AppColors.gold,
                          trackColor: fg.withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$done / $total',
                    style: TextStyle(
                      color: fg,
                      fontSize: 14,
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

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final level = LevelProgress.fromXp(xp);
    return SurfaceCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.onGold,
            child: Text(
              '${level.level}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Уровень ${level.level}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '${level.xpIntoLevel} / ${level.xpForLevel} XP',
                      style: TextStyle(
                        color: c.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ProgressBar(
                  value: level.fraction,
                  height: 8,
                  color: AppColors.gold,
                  semanticsLabel: 'До следующего уровня',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// What a section's stretch of the map looks like.
enum _Scenery { steppe, aul, city, mountains, sea }

_Scenery _sceneryOf(String sectionId) => switch (sectionId) {
  'basics' || 'speech' => _Scenery.steppe,
  'life' || 'everyday' => _Scenery.aul,
  'city' || 'society' => _Scenery.city,
  'travel' || 'career' => _Scenery.mountains,
  _ => _Scenery.sea,
};

/// The map behind the trail: a tinted region per section with its
/// scenery along the bottom — steppe, aul, city, mountains, sea.
class _LandscapePainter extends CustomPainter {
  _LandscapePainter(this.zones, {required this.ground});

  final List<(String, Color, double, double)> zones;
  final Color ground;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    for (final (id, color, top, bottom) in zones) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(-8, top - 8, w + 8, bottom - 16),
        const Radius.circular(28),
      );
      canvas.save();
      canvas.clipRRect(rect);
      canvas.drawRRect(
        rect,
        Paint()..color = Color.alphaBlend(color.withValues(alpha: .08), ground),
      );
      final deco = Paint()..color = color.withValues(alpha: .16);
      final light = Paint()..color = color.withValues(alpha: .10);
      final base = bottom - 16;
      switch (_sceneryOf(id)) {
        case _Scenery.steppe:
          canvas.drawCircle(Offset(w - 40, top + 150), 26, light);
          canvas.drawPath(
            Path()
              ..moveTo(-8, base)
              ..lineTo(-8, base - 50)
              ..quadraticBezierTo(w * .3, base - 90, w * .55, base - 52)
              ..quadraticBezierTo(w * .8, base - 20, w + 8, base - 64)
              ..lineTo(w + 8, base)
              ..close(),
            deco,
          );
        case _Scenery.aul:
          canvas.drawPath(
            Path()
              ..moveTo(-8, base)
              ..lineTo(-8, base - 34)
              ..quadraticBezierTo(w * .5, base - 64, w + 8, base - 30)
              ..lineTo(w + 8, base)
              ..close(),
            light,
          );
          for (final (x, s) in [
            (w * .72, 1.0),
            (w * .88, .75),
            (w * .14, .8),
          ]) {
            final y = base - 34;
            canvas.drawPath(
              Path()
                ..moveTo(x - 26 * s, y)
                ..quadraticBezierTo(x, y - 40 * s, x + 26 * s, y)
                ..lineTo(x + 26 * s, y + 26 * s)
                ..lineTo(x - 26 * s, y + 26 * s)
                ..close(),
              deco,
            );
          }
        case _Scenery.city:
          var x = -4.0;
          var i = 0;
          while (x < w) {
            final bw = 26.0 + (i * 7) % 18;
            final bh = 40.0 + (i * 37) % 70;
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(x, base - bh, bw, bh),
                const Radius.circular(4),
              ),
              i.isEven ? deco : light,
            );
            x += bw + 6;
            i++;
          }
        case _Scenery.mountains:
          final path = Path()..moveTo(-8, base);
          const peaks = [
            (.0, 40.0),
            (.18, 110.0),
            (.36, 60.0),
            (.55, 130.0),
            (.75, 70.0),
            (.9, 100.0),
            (1.0, 50.0),
          ];
          for (final (fx, h) in peaks) {
            path.lineTo(fx * (w + 16) - 8, base - h);
          }
          path
            ..lineTo(w + 8, base)
            ..close();
          canvas.drawPath(path, deco);
          for (final (fx, h) in const [(.18, 110.0), (.55, 130.0)]) {
            final px = fx * (w + 16) - 8;
            canvas.drawPath(
              Path()
                ..moveTo(px, base - h)
                ..lineTo(px - 12, base - h + 16)
                ..lineTo(px + 12, base - h + 16)
                ..close(),
              Paint()..color = Colors.white.withValues(alpha: .7),
            );
          }
        case _Scenery.sea:
          for (var j = 0; j < 3; j++) {
            final y = base - 20 - j * 22.0;
            final path = Path()..moveTo(-8, y);
            for (var x = -8.0; x < w + 8; x += 40) {
              path.quadraticBezierTo(x + 10, y - 10, x + 20, y);
              path.quadraticBezierTo(x + 30, y + 10, x + 40, y);
            }
            canvas.drawPath(
              path,
              Paint()
                ..color = color.withValues(alpha: .18 - j * .04)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..strokeCap = StrokeCap.round,
            );
          }
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LandscapePainter old) =>
      old.zones.length != zones.length || old.ground != ground;
}
