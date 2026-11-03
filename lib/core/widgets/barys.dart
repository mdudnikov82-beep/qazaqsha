import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../motion.dart';

/// What Barys, the snow-leopard mascot, is feeling. He never scolds.
enum BarysMood {
  /// Greets: open eyes, a smile.
  hello,

  /// Praises a streak or a goal: happy eyes, a star.
  proud,

  /// Comforts after a break or a mistake: soft brows, a scarf, no hat.
  support,

  /// Celebrates a lesson or an exam: open mouth, confetti.
  celebrate,

  /// Thinks over a hard task: eyes up, a thought bubble.
  thinking,

  /// Listens to a recording: headphones on.
  listening,

  /// Rests once the day's goal is met: closed eyes, a «z».
  resting,
}

/// What Barys wears: changes by itself with the course section, never bought.
enum BarysOutfit {
  taqiya,
  panama,
  scarf,
  borik,
  gradCap,
  helmet;

  /// The outfit of a course section.
  static BarysOutfit ofSection(String? sectionId) => switch (sectionId) {
    'travel' => panama,
    'world' => scarf,
    'heritage' => borik,
    'career' => gradCap,
    'discovery' => helmet,
    _ => taqiya,
  };
}

/// The mascot, drawn in code so it stays sharp at any size. Bobs gently
/// unless the system asks for less motion.
class Barys extends StatefulWidget {
  const Barys({
    super.key,
    this.mood = BarysMood.hello,
    this.outfit = BarysOutfit.taqiya,
    this.size = 120,
    this.animate = true,
  });

  final BarysMood mood;
  final BarysOutfit outfit;

  /// Width; the height follows the 120×112 drawing.
  final double size;
  final bool animate;

  static String label(BarysMood mood) => switch (mood) {
    BarysMood.hello => 'Барыс здоровается',
    BarysMood.proud => 'Барыс хвалит',
    BarysMood.support => 'Барыс поддерживает',
    BarysMood.celebrate => 'Барыс радуется',
    BarysMood.thinking => 'Барыс думает',
    BarysMood.listening => 'Барыс слушает',
    BarysMood.resting => 'Барыс отдыхает',
  };

  @override
  State<Barys> createState() => _BarysState();
}

class _BarysState extends State<Barys> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: widget.mood == BarysMood.celebrate ? 1600 : 3000,
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.animate && !reduceMotion(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scarf = context.colors.brand;
    final jump = widget.mood == BarysMood.celebrate ? 14.0 : 5.0;
    return Semantics(
      image: true,
      label: Barys.label(widget.mood),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -jump * sin(_c.value * pi).abs()),
          child: child,
        ),
        child: CustomPaint(
          size: Size(widget.size, widget.size * 112 / 120),
          painter: BarysPainter(
            widget.mood,
            scarf: scarf,
            outfit: widget.outfit,
          ),
        ),
      ),
    );
  }
}

class BarysPainter extends CustomPainter {
  BarysPainter(
    this.mood, {
    required this.scarf,
    this.outfit = BarysOutfit.taqiya,
  });

  final BarysMood mood;
  final Color scarf;
  final BarysOutfit outfit;

  static const _ink = Color(0xFF13232E);
  static const _fur = Color(0xFFEEF3F6);
  static const _furDark = Color(0xFFDCE5EA);
  static const _spots = Color(0xFF6B7C86);
  static const _pink = Color(0xFFF2C4C4);
  static const _blush = Color(0xFFF5B8B8);
  static const _nose = Color(0xFFD98C8C);
  static const _iris = Color(0xFF8FC2B0);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120, size.height / 112);
    final fill = Paint()..isAntiAlias = true;
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;

    if (mood == BarysMood.celebrate) {
      final bits = [
        (const Offset(11, 17), AppColors.gold),
        (const Offset(107, 43), AppColors.gold),
        (const Offset(100, 12), const Color(0xFF00AFCA)),
        (const Offset(14, 46), const Color(0xFF00AFCA)),
      ];
      for (final (o, c) in bits) {
        canvas.drawCircle(o, 3, fill..color = c);
      }
    }

    // Tақия, the skullcap, with its little ornament; behind the ears.
    // The scarf and the space helmet keep it on.
    final hat = mood != BarysMood.support;
    if (hat &&
        (outfit == BarysOutfit.taqiya ||
            outfit == BarysOutfit.scarf ||
            outfit == BarysOutfit.helmet)) {
      canvas.drawPath(
        Path()
          ..moveTo(40, 29)
          ..quadraticBezierTo(60, 4, 80, 29)
          ..close(),
        fill..color = AppColors.gold,
      );
      canvas.drawPath(
        Path()
          ..moveTo(50, 23)
          ..cubicTo(54, 17, 58, 17, 60, 22)
          ..cubicTo(62, 17, 66, 17, 70, 23),
        stroke(Colors.white, 1.8),
      );
    }

    for (final x in [30.0, 90.0]) {
      canvas.drawCircle(Offset(x, 32), 15, fill..color = _furDark);
      canvas.drawCircle(Offset(x, 33), 8, fill..color = _pink);
    }
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 64), width: 92, height: 80),
      fill..color = _fur,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 80), width: 40, height: 28),
      fill..color = Colors.white,
    );
    for (final (o, r) in [
      (const Offset(27, 54), 3.5),
      (const Offset(21, 66), 2.8),
      (const Offset(93, 54), 3.5),
      (const Offset(99, 66), 2.8),
      (const Offset(50, 38), 2.6),
      (const Offset(70, 38), 2.6),
      (const Offset(60, 44), 2.0),
    ]) {
      canvas.drawCircle(o, r, fill..color = _spots);
    }
    if (hat) _hat(canvas, fill, stroke);

    // Eyes.
    final happy = mood == BarysMood.proud || mood == BarysMood.celebrate;
    for (final x in [44.0, 76.0]) {
      if (mood == BarysMood.resting) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 8, 63)
            ..quadraticBezierTo(x, 69, x + 8, 63),
          stroke(_ink, 3),
        );
      } else if (mood == BarysMood.thinking) {
        canvas.drawCircle(Offset(x + 2, 60), 8, fill..color = _iris);
        canvas.drawCircle(Offset(x + 4, 57), 5, fill..color = _ink);
        canvas.drawCircle(Offset(x + 5.5, 55), 1.8, fill..color = Colors.white);
      } else if (happy) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 9, 63)
            ..quadraticBezierTo(x, 53, x + 9, 63),
          stroke(_ink, 3.4),
        );
      } else {
        final r = mood == BarysMood.support ? 8.0 : 9.0;
        final y = mood == BarysMood.support ? 63.0 : 62.0;
        canvas.drawCircle(Offset(x, y), r, fill..color = _iris);
        canvas.drawCircle(Offset(x, y + 1), r * .61, fill..color = _ink);
        canvas.drawCircle(
          Offset(x + 2.5, y - 2),
          2,
          fill..color = Colors.white,
        );
      }
    }
    if (mood == BarysMood.support) {
      canvas.drawLine(
        const Offset(35, 49),
        const Offset(47, 53),
        stroke(_spots, 2.6),
      );
      canvas.drawLine(
        const Offset(85, 49),
        const Offset(73, 53),
        stroke(_spots, 2.6),
      );
    }

    for (final x in [33.0, 87.0]) {
      canvas.drawCircle(
        Offset(x, 77),
        happy ? 6 : 5,
        fill..color = _blush.withValues(alpha: .75),
      );
    }

    // Nose.
    canvas.drawPath(
      Path()
        ..moveTo(54, 73)
        ..lineTo(66, 73)
        ..lineTo(60, 79)
        ..close(),
      fill..color = _nose,
    );
    canvas.drawPath(
      Path()
        ..moveTo(54, 73)
        ..lineTo(66, 73)
        ..lineTo(60, 79)
        ..close(),
      Paint()
        ..color = _nose
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    // Mouth.
    switch (mood) {
      case BarysMood.thinking || BarysMood.resting:
        canvas.drawPath(
          Path()
            ..moveTo(54, 86)
            ..quadraticBezierTo(60, 83, 66, 86),
          stroke(_ink, 2.2),
        );
        if (mood == BarysMood.thinking) {
          canvas.drawCircle(const Offset(104, 22), 4, fill..color = _furDark);
          canvas.drawCircle(const Offset(112, 10), 6, fill..color = _furDark);
        } else {
          final z = stroke(AppColors.primary, 2.6);
          for (final (x, y, w) in [(94.0, 16.0, 9.0), (106.0, 4.0, 6.0)]) {
            canvas.drawPath(
              Path()
                ..moveTo(x, y)
                ..lineTo(x + w, y)
                ..lineTo(x, y + w)
                ..lineTo(x + w, y + w),
              z,
            );
          }
        }
      case BarysMood.hello || BarysMood.listening:
        canvas.drawPath(
          Path()
            ..moveTo(60, 80)
            ..lineTo(60, 83)
            ..quadraticBezierTo(55, 88, 50, 85)
            ..moveTo(60, 83)
            ..quadraticBezierTo(65, 88, 70, 85),
          stroke(_ink, 2.2),
        );
      case BarysMood.proud:
        canvas.drawPath(
          Path()
            ..moveTo(50, 83)
            ..quadraticBezierTo(60, 92, 70, 83),
          stroke(_ink, 2.4),
        );
        _star(canvas, const Offset(106, 24), 7, fill..color = AppColors.gold);
      case BarysMood.support:
        canvas.drawPath(
          Path()
            ..moveTo(52, 85)
            ..quadraticBezierTo(60, 89, 68, 85),
          stroke(_ink, 2.2),
        );
        canvas.drawPath(
          Path()
            ..moveTo(18, 98)
            ..quadraticBezierTo(28, 84, 40, 92)
            ..quadraticBezierTo(36, 102, 18, 98)
            ..close(),
          fill..color = scarf,
        );
      case BarysMood.celebrate:
        canvas.drawPath(
          Path()
            ..moveTo(49, 81)
            ..quadraticBezierTo(60, 97, 71, 81)
            ..close(),
          fill..color = _ink,
        );
        canvas.drawPath(
          Path()
            ..moveTo(54, 87)
            ..quadraticBezierTo(60, 92, 66, 87)
            ..quadraticBezierTo(60, 84, 54, 87)
            ..close(),
          fill..color = const Color(0xFFE98A8A),
        );
    }

    if (mood == BarysMood.listening) {
      canvas.drawPath(
        Path()
          ..moveTo(18, 52)
          ..quadraticBezierTo(18, 6, 60, 6)
          ..quadraticBezierTo(102, 6, 102, 52),
        stroke(_ink, 5),
      );
      for (final x in [8.0, 94.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, 46, 18, 28),
            const Radius.circular(8),
          ),
          fill..color = AppColors.primary,
        );
      }
    }
    if (outfit == BarysOutfit.scarf && hat) {
      canvas.drawPath(
        Path()
          ..moveTo(24, 92)
          ..quadraticBezierTo(60, 110, 96, 92)
          ..lineTo(96, 100)
          ..quadraticBezierTo(60, 118, 24, 100)
          ..close(),
        fill..color = _scarfRed,
      );
      canvas.drawPath(
        Path()
          ..moveTo(78, 100)
          ..lineTo(84, 112)
          ..lineTo(92, 112)
          ..lineTo(86, 98)
          ..close(),
        fill..color = _scarfRed,
      );
    }
    if (outfit == BarysOutfit.helmet && hat) {
      canvas.drawCircle(
        const Offset(60, 58),
        56,
        fill..color = const Color(0x47BFE6EF),
      );
      canvas.drawCircle(
        const Offset(60, 58),
        56,
        stroke(const Color(0xFFC9D5DB), 4),
      );
      canvas.drawPath(
        Path()
          ..moveTo(24, 30)
          ..quadraticBezierTo(34, 14, 52, 10),
        stroke(const Color(0xE6FFFFFF), 5),
      );
    }
  }

  static const _scarfRed = Color(0xFFC2552B);

  /// Hats drawn over the head: panama, бөрік, graduation cap.
  void _hat(Canvas canvas, Paint fill, Paint Function(Color, double) stroke) {
    switch (outfit) {
      case BarysOutfit.panama:
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(60, 27), width: 80, height: 16),
          fill..color = const Color(0xFF2A62B0),
        );
        canvas.drawPath(
          Path()
            ..moveTo(36, 26)
            ..quadraticBezierTo(38, 4, 60, 4)
            ..quadraticBezierTo(82, 4, 84, 26)
            ..close(),
          fill..color = const Color(0xFF3D7BD0),
        );
        canvas.drawLine(
          const Offset(37, 21),
          const Offset(83, 21),
          stroke(AppColors.gold, 3.5)..strokeCap = StrokeCap.butt,
        );
      case BarysOutfit.borik:
        canvas.drawPath(
          Path()
            ..moveTo(38, 30)
            ..quadraticBezierTo(40, 2, 60, 2)
            ..quadraticBezierTo(80, 2, 82, 30)
            ..close(),
          fill..color = const Color(0xFFB3261E),
        );
        canvas.drawPath(
          Path()
            ..moveTo(48, 14)
            ..quadraticBezierTo(54, 8, 60, 14)
            ..quadraticBezierTo(66, 8, 72, 14),
          stroke(AppColors.gold, 2),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(30, 24, 60, 12),
            const Radius.circular(6),
          ),
          fill..color = const Color(0xFF8A6A44),
        );
      case BarysOutfit.gradCap:
        canvas.drawPath(
          Path()
            ..moveTo(38, 27)
            ..lineTo(38, 36)
            ..quadraticBezierTo(60, 46, 82, 36)
            ..lineTo(82, 27)
            ..close(),
          fill..color = const Color(0xFF26384A),
        );
        canvas.drawPath(
          Path()
            ..moveTo(60, 6)
            ..lineTo(100, 20)
            ..lineTo(60, 34)
            ..lineTo(20, 20)
            ..close(),
          fill..color = _ink,
        );
        canvas.drawPath(
          Path()
            ..moveTo(60, 20)
            ..lineTo(96, 24)
            ..lineTo(96, 40),
          stroke(AppColors.gold, 2.5),
        );
        canvas.drawCircle(
          const Offset(96, 43),
          4,
          fill..color = AppColors.gold,
        );
      case BarysOutfit.taqiya || BarysOutfit.scarf || BarysOutfit.helmet:
        break;
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -pi / 2 + i * pi / 5;
      final rr = i.isEven ? r : r * .45;
      final p = c + Offset(cos(a) * rr, sin(a) * rr);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(BarysPainter old) =>
      old.mood != mood || old.scarf != scarf || old.outfit != outfit;
}
