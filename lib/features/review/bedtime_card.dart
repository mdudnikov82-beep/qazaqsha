import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'review_mode.dart';

/// Opens the bedtime review: a night-blue card with the moon and stars.
class BedtimeCard extends StatelessWidget {
  const BedtimeCard({super.key});

  static const _top = Color(0xFF283593);
  static const _bottom = Color(0xFF1A1F4E);
  static const _moon = Color(0xFFFFE082);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Повторение перед сном: $bedtimeSessionSize слов, без очков',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_top, _bottom],
            ),
          ),
          child: InkWell(
            onTap: () => context.push('/practice/review?mode=bedtime'),
            child: Stack(
              children: [
                // A few stars in the night sky.
                for (final (x, y, s) in const [
                  (.62, .18, 3.0),
                  (.74, .62, 2.0),
                  (.86, .30, 2.5),
                  (.55, .75, 2.0),
                ])
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment(x * 2 - 1, y * 2 - 1),
                      child: Container(
                        width: s,
                        height: s,
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.nightlight_round,
                          color: _moon,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Повторение перед сном',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '$bedtimeSessionSize слов · 2 минуты · без очков',
                              style: TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white70,
                      ),
                    ],
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
