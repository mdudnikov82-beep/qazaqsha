import 'dart:math';

import 'package:flutter/material.dart';

import '../motion.dart';

/// A burst of falling confetti over its area, played once. Nothing is shown
/// when the system asks for reduced motion.
class Confetti extends StatefulWidget {
  const Confetti({super.key, required this.colors, this.count = 44});

  final List<Color> colors;
  final int count;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _Piece {
  _Piece(Random r, this.color)
    : x = r.nextDouble(),
      delay = r.nextDouble() * 0.3,
      speed = 0.75 + r.nextDouble() * 0.5,
      width = 6 + r.nextDouble() * 6,
      spin = (r.nextDouble() - 0.5) * 14,
      sway = r.nextDouble() * 2 * pi;

  final double x;
  final double delay;
  final double speed;
  final double width;
  final double spin;
  final double sway;
  final Color color;
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final r = Random(42);
    _pieces = [
      for (var i = 0; i < widget.count; i++)
        _Piece(r, widget.colors[i % widget.colors.length]),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!reduceMotion(context) && !_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, _c),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.progress) : super(repaint: progress);

  final List<_Piece> pieces;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t == 0 || t == 1) return;
    final paint = Paint();
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local == 0) continue;
      final y = -20 + local * p.speed * (size.height + 60);
      final x = p.x * size.width + sin(local * 6 + p.sway) * 14;
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(local * p.spin)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.width,
              height: p.width * 1.6,
            ),
            const Radius.circular(2),
          ),
          paint..color = p.color.withValues(alpha: 1 - local * 0.3),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
