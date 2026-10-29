import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/providers.dart';
import '../speech.dart';

/// 🔊 next to a Kazakh word or sentence; nothing if there is no voice.
class SpeakButton extends ConsumerWidget {
  const SpeakButton(this.kazakh, {super.key, this.size = 24, this.color});

  final String kazakh;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!(ref.watch(speechAvailableProvider).value ?? false)) {
      return const SizedBox.shrink();
    }
    return IconButton(
      tooltip: 'Послушать',
      iconSize: size,
      onPressed: () => Speech.say(kazakh),
      icon: Icon(
        Icons.volume_up_rounded,
        color: color ?? context.colors.accent,
      ),
    );
  }
}
