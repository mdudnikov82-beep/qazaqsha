import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/widgets/common.dart';
import '../../app/theme.dart';
import 'collection.dart';

/// The summer pasture that grows with learned words: grass, a yurt, a
/// horse… Progress shown as a picture rather than a number.
class ZhailauCard extends StatelessWidget {
  const ZhailauCard({super.key, required this.learnedWords});

  final int learnedWords;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final stage = zhailauStage(learnedWords);
    final next = stage < zhailauStages.length ? zhailauStages[stage] : null;
    final left = next == null ? 0 : next.words - learnedWords;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 2.2,
              child: Semantics(
                image: true,
                label: 'Жайлау: $stage из ${zhailauStages.length}',
                child: CustomPaint(painter: ZhailauPainter(stage)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Жайлау · $stage из ${zhailauStages.length}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  next == null
                      ? 'Жайлау расцвёл целиком. Керемет!'
                      : 'Выучите ещё $left '
                            '${plural(left, 'слово', 'слова', 'слов')} — '
                            'появится ${next.title}.',
                  style: TextStyle(color: c.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the first [stage] things of [zhailauStages] in simple shapes.
class ZhailauPainter extends CustomPainter {
  ZhailauPainter(this.stage);

  final int stage;

  bool has(int i) => stage > i;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final ground = h * 0.62;
    final p = Paint()..isAntiAlias = true;

    // Sky.
    p.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF8FD3F4), Color(0xFFD9F1FB)],
    ).createShader(Rect.fromLTWH(0, 0, w, ground));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, ground), p);
    p.shader = null;

    // Sun.
    p.color = const Color(0xFFFFC83D);
    canvas.drawCircle(Offset(w * 0.86, h * 0.2), h * 0.09, p);

    // 11: rainbow.
    if (has(11)) {
      const colors = [
        Color(0xFFE53935),
        Color(0xFFFB8C00),
        Color(0xFFFDD835),
        Color(0xFF43A047),
        Color(0xFF1E88E5),
        Color(0xFF8E24AA),
      ];
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.025;
      for (final (i, col) in colors.indexed) {
        stroke.color = col.withValues(alpha: 0.7);
        final r = w * 0.32 - i * h * 0.025;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(w * 0.5, ground), radius: r),
          pi,
          pi,
          false,
          stroke,
        );
      }
    }

    // 8: mountains.
    if (has(8)) {
      p.color = const Color(0xFF7E8FA6);
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.02, ground)
          ..lineTo(w * 0.2, h * 0.18)
          ..lineTo(w * 0.36, ground)
          ..close(),
        p,
      );
      p.color = const Color(0xFF94A3B8);
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.22, ground)
          ..lineTo(w * 0.4, h * 0.26)
          ..lineTo(w * 0.58, ground)
          ..close(),
        p,
      );
      p.color = Colors.white;
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.2, h * 0.18)
          ..lineTo(w * 0.155, h * 0.29)
          ..lineTo(w * 0.245, h * 0.29)
          ..close(),
        p,
      );
    }

    // Ground: bare steppe, green once the grass grows.
    p.color = has(0) ? const Color(0xFF7CC36B) : const Color(0xFFD8C79A);
    canvas.drawRect(Rect.fromLTWH(0, ground, w, h - ground), p);

    // 7: river.
    if (has(7)) {
      p.color = const Color(0xFF4FB3E8);
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.62, ground)
          ..quadraticBezierTo(w * 0.5, h * 0.8, w * 0.66, h)
          ..lineTo(w * 0.8, h)
          ..quadraticBezierTo(w * 0.62, h * 0.8, w * 0.68, ground)
          ..close(),
        p,
      );
    }

    // 0: grass tufts.
    if (has(0)) {
      final grass = Paint()
        ..color = const Color(0xFF4E9A3F)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 14; i++) {
        final x = w * (0.04 + i * 0.07);
        final y = ground + (h - ground) * (0.35 + (i % 3) * 0.2);
        canvas.drawLine(Offset(x, y), Offset(x - 3, y - 7), grass);
        canvas.drawLine(Offset(x, y), Offset(x + 3, y - 7), grass);
      }
    }

    // 1: flowers.
    if (has(1)) {
      const petals = [Color(0xFFE53935), Color(0xFFFDD835), Color(0xFFFFFFFF)];
      for (var i = 0; i < 9; i++) {
        p.color = petals[i % 3];
        canvas.drawCircle(
          Offset(
            w * (0.08 + i * 0.1),
            ground + (h - ground) * (0.25 + (i % 2) * 0.45),
          ),
          2.6,
          p,
        );
      }
    }

    // 4: trees.
    if (has(4)) {
      for (final x in [0.06, 0.93]) {
        p.color = const Color(0xFF7A5230);
        canvas.drawRect(
          Rect.fromLTWH(w * x - 2, ground - h * 0.12, 4, h * 0.13),
          p,
        );
        p.color = const Color(0xFF2E7D32);
        canvas.drawCircle(Offset(w * x, ground - h * 0.15), h * 0.07, p);
      }
    }

    void yurt(double cx, double s) {
      final base = ground + h * 0.02;
      p.color = const Color(0xFFF5EBDD);
      canvas.drawRect(Rect.fromLTWH(cx - s, base - s * 0.9, s * 2, s * 0.9), p);
      p.color = const Color(0xFFE2CDB0);
      canvas.drawPath(
        Path()
          ..moveTo(cx - s * 1.1, base - s * 0.9)
          ..quadraticBezierTo(cx, base - s * 1.9, cx + s * 1.1, base - s * 0.9)
          ..close(),
        p,
      );
      // Ornament band and door.
      p.color = const Color(0xFFB3261E);
      canvas.drawRect(
        Rect.fromLTWH(cx - s, base - s * 0.62, s * 2, s * 0.1),
        p,
      );
      p.color = const Color(0xFF8C5A00);
      canvas.drawRect(
        Rect.fromLTWH(cx - s * 0.22, base - s * 0.5, s * 0.44, s * 0.5),
        p,
      );
    }

    // 2 and 6: yurts.
    if (has(2)) yurt(w * 0.3, h * 0.13);
    if (has(6)) yurt(w * 0.47, h * 0.1);

    // 3: horse.
    if (has(3)) {
      final x = w * 0.78, y = ground + h * 0.12;
      p.color = const Color(0xFF8D5524);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 18, y - 22, 36, 14),
          const Radius.circular(7),
        ),
        p,
      );
      canvas.drawRect(Rect.fromLTWH(x + 12, y - 34, 7, 16), p);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 12, y - 36, 14, 7),
          const Radius.circular(3),
        ),
        p,
      );
      for (final dx in [-15.0, -8.0, 8.0, 14.0]) {
        canvas.drawRect(Rect.fromLTWH(x + dx, y - 10, 3, 12), p);
      }
    }

    // 5: sheep.
    if (has(5)) {
      for (final (dx, dy) in [(0.15, 0.2), (0.2, 0.28), (0.1, 0.3)]) {
        final o = Offset(w * dx, ground + h * dy);
        p.color = Colors.white;
        canvas.drawOval(Rect.fromCenter(center: o, width: 18, height: 12), p);
        p.color = const Color(0xFF3A3A3A);
        canvas.drawCircle(o + const Offset(9, -2), 3.5, p);
      }
    }

    // 9: eagle.
    if (has(9)) {
      final stroke = Paint()
        ..color = const Color(0xFF4A3A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final o = Offset(w * 0.62, h * 0.18);
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 18, o.dy)
          ..quadraticBezierTo(o.dx - 9, o.dy - 9, o.dx, o.dy)
          ..quadraticBezierTo(o.dx + 9, o.dy - 9, o.dx + 18, o.dy),
        stroke,
      );
    }

    // 10: camel.
    if (has(10)) {
      final x = w * 0.9, y = ground + h * 0.3;
      p.color = const Color(0xFFC79A5B);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 18, y - 20, 34, 12),
          const Radius.circular(6),
        ),
        p,
      );
      canvas.drawCircle(Offset(x - 8, y - 20), 7, p);
      canvas.drawCircle(Offset(x + 5, y - 20), 7, p);
      canvas.drawRect(Rect.fromLTWH(x + 12, y - 32, 5, 16), p);
      canvas.drawRect(Rect.fromLTWH(x + 12, y - 34, 10, 5), p);
      for (final dx in [-15.0, -9.0, 6.0, 11.0]) {
        canvas.drawRect(Rect.fromLTWH(x + dx, y - 9, 3, 12), p);
      }
    }
  }

  @override
  bool shouldRepaint(ZhailauPainter old) => old.stage != stage;
}
