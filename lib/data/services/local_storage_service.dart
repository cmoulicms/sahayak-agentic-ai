import 'dart:convert';
import 'dart:io';
import 'package:myapp/data/models/aiModels/ai_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _historyKey = 'ai_assistant_history';
  static const String _savedContentKey = 'ai_assistant_saved_content';
  static const String _preferencesKey = 'ai_assistant_preferences';
  static const String _cacheKey = 'ai_assistant_cache';

  // History management
  static Future<void> saveHistory(List<HistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        json.encode(history.map((item) => item.toMap()).toList());
    await prefs.setString(_historyKey, historyJson);
  }

  static Future<List<HistoryItem>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.map((item) => HistoryItem.fromMap(item)).toList();
      }
    } catch (e) {
      print('Error loading history: $e');
    }
    return [];
  }

  // Saved content management
  static Future<void> saveSavedContent(List<SavedContent> savedContent) async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson =
        json.encode(savedContent.map((item) => item.toMap()).toList());
    await prefs.setString(_savedContentKey, savedJson);
  }

  static Future<List<SavedContent>> loadSavedContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_savedContentKey);
      if (savedJson != null) {
        final List<dynamic> savedList = json.decode(savedJson);
        return savedList.map((item) => SavedContent.fromMap(item)).toList();
      }
    } catch (e) {
      print('Error loading saved content: $e');
    }
    return [];
  }

  // User preferences
  static Future<void> saveUserPreferences(
      Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = json.encode(preferences);
    await prefs.setString(_preferencesKey, prefsJson);
  }

  static Future<Map<String, dynamic>> loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString(_preferencesKey);
      if (prefsJson != null) {
        return Map<String, dynamic>.from(json.decode(prefsJson));
      }
    } catch (e) {
      print('Error loading preferences: $e');
    }
    return {
      'defaultLanguage': 'English',
      'defaultGradeLevel': 'Elementary',
      'autoSave': true,
      'speechRate': 0.5,
      'speechVolume': 1.0,
    };
  }

  // Cache management for API responses
  static Future<void> cacheResponse(
      String key, Map<String, dynamic> response) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final file = File('${cacheDir.path}/$key.json');
      final cacheData = {
        'data': response,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await file.writeAsString(json.encode(cacheData));
    } catch (e) {
      print('Error caching response: $e');
    }
  }

  static Future<Map<String, dynamic>?> getCachedResponse(String key,
      {Duration? maxAge}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/cache/$key.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final cacheData = json.decode(content);
        final timestamp = DateTime.parse(cacheData['timestamp']);

        if (maxAge != null && DateTime.now().difference(timestamp) > maxAge) {
          await file.delete();
          return null;
        }

        return Map<String, dynamic>.from(cacheData['data']);
      }
    } catch (e) {
      print('Error reading cached response: $e');
    }
    return null;
  }

  static Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // File management for generated content
  static Future<String> saveGeneratedFile(
      String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/generated/$fileName');

    // Create directory if it doesn't exist
    await file.parent.create(recursive: true);

    await file.writeAsString(content);
    return file.path;
  }

  static Future<List<FileSystemEntity>> getGeneratedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final generatedDir = Directory('${directory.path}/generated');
      if (await generatedDir.exists()) {
        return generatedDir.listSync();
      }
    } catch (e) {
      print('Error listing generated files: $e');
    }
    return [];
  }

  static Future<void> deleteGeneratedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
