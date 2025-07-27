import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioUtils {
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  static Future<String> saveAudioToTempFile(
      Uint8List audioBytes, String extension) async {
    final directory = await getTemporaryDirectory();
    final fileName =
        'audio_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(audioBytes);
    return file.path;
  }

  static Future<void> cleanupTempAudioFiles() async {
    final directory = await getTemporaryDirectory();
    final files = directory.listSync();

    for (final file in files) {
      if (file is File &&
          (file.path.endsWith('.m4a') ||
              file.path.endsWith('.wav') ||
              file.path.endsWith('.mp3'))) {
        try {
          await file.delete();
        } catch (e) {
          print('Error deleting temp audio file: $e');
        }
      }
    }
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
