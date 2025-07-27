import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:myapp/config/authtoken.dart';

/// Service to transcribe speech audio using Google Cloud Speech-to-Text API.
class SpeechService {
  static const _speechApiUrl =
      'https://speech.googleapis.com/v1/speech:recognize';

  /// Transcribes a WAV audio file (16000Hz, LINEAR16).
  static Future<String> transcribeAudio(String filePath) async {
    final token = await AuthTokenService.getAccessToken();

    final audioBytes = base64Encode(File(filePath).readAsBytesSync());
    final requestBody = jsonEncode({
      "config": {
        "encoding": "LINEAR16",
        "languageCode": "en-US",
        "sampleRateHertz": 16000,
      },
      "audio": {"content": audioBytes},
    });

    final response = await http.post(
      Uri.parse(_speechApiUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: requestBody,
    );

    if (response.statusCode != 200) {
      throw Exception("Speech API Error: ${response.body}");
    }

    final json = jsonDecode(response.body);
    final transcript = (json['results'] as List?)
            ?.map((res) => res['alternatives'][0]['transcript'])
            .join(' ') ??
        '';
    return transcript;
  }
}
