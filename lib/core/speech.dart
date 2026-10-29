import 'package:flutter_tts/flutter_tts.dart';

/// Kazakh text-to-speech, when the device has a Kazakh voice. Without one
/// the app hides its speaker buttons rather than read Kazakh with a
/// Russian voice.
abstract final class Speech {
  static FlutterTts? _tts;
  static Future<bool>? _ready;

  static const _languages = ['kk-KZ', 'kk'];

  /// Whether a Kazakh voice can be used. Checked once.
  static Future<bool> available() => _ready ??= _init();

  static Future<bool> _init() async {
    try {
      final tts = FlutterTts();
      for (final lang in _languages) {
        if (await tts.isLanguageAvailable(lang) == true) {
          await tts.setLanguage(lang);
          await tts.setSpeechRate(0.45);
          _tts = tts;
          return true;
        }
      }
    } catch (_) {
      // No TTS engine (tests, some browsers): stay silent.
    }
    return false;
  }

  static Future<void> say(String kazakh) async {
    if (!await available()) return;
    await _tts!.stop();
    await _tts!.speak(kazakh);
  }
}
