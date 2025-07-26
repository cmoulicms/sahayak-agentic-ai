
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isListening = false;

  // Getters
  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  // Initialize the service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize TTS
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        print('TTS Error: $msg');
      });

      // Initialize Speech Recognition
      // _isInitialized = await _speechToText.initialize(
      //   onStatus: (status) => print('Speech recognition status: $status'),
      //   onError: (error) => print('Speech recognition error: $error'),
      // );

      return _isInitialized;
    } catch (e) {
      print('Error initializing speech service: $e');
      return false;
    }
  }

  // Text-to-Speech methods
  Future<void> speak(
    String text, {
    String? language,
    double? rate,
    double? volume,
    double? pitch,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (language != null) {
        await _flutterTts.setLanguage(language);
      }
      if (rate != null) {
        await _flutterTts.setSpeechRate(rate);
      }
      if (volume != null) {
        await _flutterTts.setVolume(volume);
      }
      if (pitch != null) {
        await _flutterTts.setPitch(pitch);
      }

      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking text: $e');
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('Error pausing speech: $e');
    }
  }

  // Get available languages
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      print('Error getting available languages: $e');
      return ['en-US'];
    }
  }

  // // Speech-to-Text methods
  Future<bool> startListening({
    String? localeId,
    Function(String)? onResult,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) return false;

    try {
      _isListening = await _speechToText.listen(
        onResult: (result) {
          if (onResult != null) {
            onResult(result.recognizedWords);
          }
        },
        localeId: localeId ?? 'en_US',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
      );

      return _isListening;
    } catch (e) {
      print('Error starting speech recognition: $e');
      if (onError != null) {
        onError(e.toString());
      }
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
    } catch (e) {
      print('Error canceling speech recognition: $e');
    }
  }

  // Get available speech recognition locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _speechToText.locales();
    } catch (e) {
      print('Error getting available locales: $e');
      return [];
    }
  }

  // Clean up resources
  Future<void> dispose() async {
    await stop();
    await stopListening();
    _isInitialized = false;
  }
}
