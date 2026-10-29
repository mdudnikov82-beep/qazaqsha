import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/providers.dart';
import '../latin.dart';

/// [kazakh] in Latin letters, when the profile setting asks for it.
class LatinLine extends ConsumerWidget {
  const LatinLine(
    this.kazakh, {
    super.key,
    this.fontSize = 15,
    this.color,
    this.textAlign,
  });

  final String kazakh;
  final double fontSize;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(showLatinProvider)) return const SizedBox.shrink();
    return Text(
      toLatin(kazakh),
      textAlign: textAlign,
      style: TextStyle(
        color: color ?? context.colors.accent,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
