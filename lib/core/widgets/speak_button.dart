import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/providers.dart';
import '../speech.dart';
import '../voice.dart';

/// 🔊 next to a Kazakh word or sentence: a native speaker's recording if
/// there is one, otherwise the device voice; nothing if neither exists.
class SpeakButton extends ConsumerWidget {
  const SpeakButton(this.kazakh, {super.key, this.size = 24, this.color});

  final String kazakh;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recorded = ref.watch(
      recordedVoiceProvider.select(
        (index) => index.value?[Voice.normalize(kazakh)],
      ),
    );
    final tts = ref.watch(speechAvailableProvider).value ?? false;
    if (recorded == null && !tts) return const SizedBox.shrink();
    return IconButton(
      tooltip: recorded != null ? 'Послушать (живой голос)' : 'Послушать',
      iconSize: size,
      onPressed: () =>
          recorded != null ? Voice.play(recorded) : Speech.say(kazakh),
      icon: Icon(
        Icons.volume_up_rounded,
        color: color ?? context.colors.accent,
      ),
    );
  }
}
