import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Words recorded by a native speaker (assets/audio, made by
/// tools/review/import.py). Preferred over text-to-speech.
abstract final class Voice {
  static AudioPlayer? _player;

  /// Kazakh text → recording key.
  static Future<Map<String, String>> loadIndex() async {
    try {
      final raw = await rootBundle.loadString('assets/audio/index.json');
      return (jsonDecode(raw) as Map<String, dynamic>).cast<String, String>();
    } catch (_) {
      return const {};
    }
  }

  static String normalize(String kazakh) => kazakh.trim().toLowerCase();

  static Future<void> play(String key) async {
    final player = _player ??= AudioPlayer();
    await player.stop();
    await player.play(AssetSource('audio/$key.webm'));
  }
}
