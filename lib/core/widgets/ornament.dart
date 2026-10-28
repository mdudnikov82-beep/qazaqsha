import 'dart:math';

import 'package:flutter/material.dart';

/// «Қошқар мүйіз» — the ram's-horn motif of Kazakh ornament (ою-өрнек),
/// drawn in an 80×40 box: two spirals curling out from a common stem.
Path ramHornsPath() {
  Path horn(double Function(double x) fx) => Path()
    ..moveTo(fx(40), 34)
    ..cubicTo(fx(34), 22, fx(25), 13, fx(15), 16)
    ..cubicTo(fx(6), 19, fx(6), 31, fx(14), 34)
    ..cubicTo(fx(20), 36, fx(25), 31, fx(22), 26)
    ..cubicTo(fx(20), 23, fx(16), 25, fx(17), 28);
  return Path()
    ..addPath(horn((x) => x), Offset.zero)
    ..addPath(horn((x) => 80 - x), Offset.zero);
}

final _horns = ramHornsPath();

class _HornsPainter extends CustomPainter {
  _HornsPainter({required this.color, required this.strokeWidth, this.tile});

  final Color color;
  final double strokeWidth;

  /// When set, repeats the motif across the width at this tile width.
  final double? tile;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    if (tile == null) {
      final scale = min(size.width / 80, size.height / 40);
      canvas
        ..save()
        ..translate(
          (size.width - 80 * scale) / 2,
          (size.height - 40 * scale) / 2,
        )
        ..scale(scale);
      paint.strokeWidth = strokeWidth / scale;
      canvas
        ..drawPath(_horns, paint)
        ..restore();
      return;
    }
    final scale = tile! / 80;
    paint.strokeWidth = strokeWidth / scale;
    for (var x = 0.0; x < size.width; x += tile!) {
      canvas
        ..save()
        ..translate(x, (size.height - 40 * scale) / 2)
        ..scale(scale)
        ..drawPath(_horns, paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_HornsPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth || old.tile != tile;
}

/// One ram's-horn motif.
class RamHorns extends StatelessWidget {
  const RamHorns({
    super.key,
    required this.width,
    required this.color,
    this.strokeWidth = 3,
  });

  final double width;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(width, width / 2),
      painter: _HornsPainter(color: color, strokeWidth: strokeWidth),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;
    // Dotted inner circle.
    for (var a = 0.0; a < 2 * pi; a += pi / 18) {
      canvas.drawCircle(
        center + Offset(cos(a), sin(a)) * (r * 0.72),
        1.6,
        Paint()..color = color,
      );
    }
    // Four ram's-horn motifs around it, pointing outwards.
    final scale = r * 0.42 / 80;
    for (var i = 0; i < 4; i++) {
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(i * pi / 2)
        ..translate(-40 * scale, -r)
        ..scale(scale);
      paint.strokeWidth = 2.5 / scale;
      canvas
        ..drawPath(_horns, paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color;
}

/// A ring of motifs, slowly turning (unless motion is reduced).
class OrnamentRing extends StatefulWidget {
  const OrnamentRing({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<OrnamentRing> createState() => _OrnamentRingState();
}

class _OrnamentRingState extends State<OrnamentRing>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    still ? _c.stop() : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RotationTransition(
      turns: _c,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _RingPainter(widget.color),
      ),
    ),
  );
}

/// A strip of repeated motifs, for headers and banners.
class OrnamentBand extends StatelessWidget {
  const OrnamentBand({
    super.key,
    required this.color,
    this.height = 40,
    this.tile = 66,
    this.strokeWidth = 2.6,
  });

  final Color color;
  final double height;
  final double tile;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(double.infinity, height),
      painter: _HornsPainter(
        color: color,
        strokeWidth: strokeWidth,
        tile: tile,
      ),
    ),
  );
}
