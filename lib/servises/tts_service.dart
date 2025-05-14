import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);   // Adjust as needed
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  static Future<void> speak(String text) async {
    await _tts.stop(); // Stop any ongoing speech
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}
