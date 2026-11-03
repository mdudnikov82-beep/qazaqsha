import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Lesson progress as a string of beads, like a Kazakh necklace: done
/// beads in the section's colour, the current one ringed in gold.
/// Past [maxBeads] it becomes a plain thread with the ringed bead.
class BeadProgress extends StatelessWidget {
  const BeadProgress({
    super.key,
    required this.done,
    required this.total,
    this.color,
    this.semanticsLabel,
  });

  final int done;
  final int total;
  final Color? color;
  final String? semanticsLabel;

  static const maxBeads = 16;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: semanticsLabel,
      value: '${done.clamp(0, total)} из $total',
      child: SizedBox(
        height: 22,
        width: double.infinity,
        child: CustomPaint(
          painter: _BeadPainter(
            done: done,
            total: total,
            color: color ?? c.brand,
            track: c.line,
            surface: c.surface,
          ),
        ),
      ),
    );
  }
}

class _BeadPainter extends CustomPainter {
  _BeadPainter({
    required this.done,
    required this.total,
    required this.color,
    required this.track,
    required this.surface,
  });

  final int done;
  final int total;
  final Color color;
  final Color track;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;
    final y = size.height / 2;
    const r = 6.0, left = 8.0;
    final right = size.width - 8;
    final beads = total <= BeadProgress.maxBeads;
    final n = beads ? total : 1;
    double xOf(int i) => n == 1
        ? left + (right - left) * (done / total).clamp(0, 1)
        : left + (right - left) * i / (n - 1);
    final current = beads ? done.clamp(0, total - 1) : 0;
    final line = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, y), Offset(right, y), line..color = track);
    final at = beads ? xOf(current) : xOf(0);
    canvas.drawLine(Offset(left, y), Offset(at, y), line..color = color);

    final fill = Paint()..isAntiAlias = true;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    if (beads) {
      for (var i = 0; i < total; i++) {
        final o = Offset(xOf(i), y);
        if (i < done) {
          canvas.drawCircle(o, r, fill..color = color);
        } else if (i != current) {
          canvas.drawCircle(o, r - 1, fill..color = surface);
          canvas.drawCircle(
            o,
            r - 1,
            ring
              ..color = track
              ..strokeWidth = 2.5,
          );
        }
      }
    }
    if (done < total) {
      final o = Offset(at, y);
      canvas.drawCircle(o, r + 2, fill..color = surface);
      canvas.drawCircle(
        o,
        r + 2,
        ring
          ..color = AppColors.gold
          ..strokeWidth = 3.5,
      );
    }
  }

  @override
  bool shouldRepaint(_BeadPainter old) =>
      old.done != done ||
      old.total != total ||
      old.color != color ||
      old.track != track;
}
