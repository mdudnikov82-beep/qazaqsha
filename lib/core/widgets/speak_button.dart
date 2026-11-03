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

/// The big «Послушать» button of the word card: says whose voice it is.
/// Nothing if there is neither a recording nor a phone voice.
class ListenButton extends ConsumerWidget {
  const ListenButton(this.kazakh, {super.key});

  final String kazakh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recorded = ref.watch(
      recordedVoiceProvider.select(
        (index) => index.value?[Voice.normalize(kazakh)],
      ),
    );
    final tts = ref.watch(speechAvailableProvider).value ?? false;
    if (recorded == null && !tts) return const SizedBox.shrink();
    final c = context.colors;
    return Tooltip(
      message: recorded != null ? 'Послушать (живой голос)' : 'Послушать',
      child: Material(
        color: c.brand,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () =>
              recorded != null ? Voice.play(recorded) : Speech.say(kazakh),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Послушать',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        recorded != null
                            ? 'Живой голос носителя'
                            : 'Голос телефона',
                        style: TextStyle(
                          color: c.onBrandMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (recorded != null)
                  const Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.gold,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
