import 'dart:convert';
import 'dart:io';
import 'package:Sahayak/data/models/aiModels/ai_models.dart';
import 'package:Sahayak/data/models/stress/stress_analysis_model.dart';

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



// Add these methods to LocalStorageService class

// Stress Profile Management
static Future<void> saveStressProfile(StressProfile profile) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = json.encode(profile.toMap());
    await prefs.setString('stress_profile_${profile.teacherId}', profileJson);
  } catch (e) {
    print('Error saving stress profile: $e');
  }
}

static Future<StressProfile?> getStressProfile(String teacherId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('stress_profile_$teacherId');
    if (profileJson != null) {
      final profileMap = json.decode(profileJson);
      return StressProfile.fromMap(profileMap);
    }
  } catch (e) {
    print('Error loading stress profile: $e');
  }
  return null;
}

// Stress Logs Management
static Future<void> saveStressLog(DailyStressLog log) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final stressLogsDir = Directory('${directory.path}/stress_logs');
    if (!await stressLogsDir.exists()) {
      await stressLogsDir.create(recursive: true);
    }
    
    final file = File('${stressLogsDir.path}/${log.teacherId}_${log.date.millisecondsSinceEpoch}.json');
    await file.writeAsString(json.encode(log.toMap()));
    
    // Also maintain a list of all logs for quick access
    await _updateStressLogsList(log.teacherId, log.id);
  } catch (e) {
    print('Error saving stress log: $e');
  }
}

static Future<List<DailyStressLog>> getStressLogs(String teacherId, DateTime fromDate) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final stressLogsDir = Directory('${directory.path}/stress_logs');
    if (!await stressLogsDir.exists()) {
      return [];
    }

    final logs = <DailyStressLog>[];
    final files = stressLogsDir.listSync()
        .where((file) => file.path.contains(teacherId) && file.path.endsWith('.json'))
        .toList();

    for (final file in files) {
      try {
        final content = await File(file.path).readAsString();
        final logMap = json.decode(content);
        final log = DailyStressLog.fromMap(logMap);
        
        if (log.date.isAfter(fromDate) || log.date.isAtSameMomentAs(fromDate)) {
          logs.add(log);
        }
      } catch (e) {
        print('Error reading stress log file: ${file.path}');
      }
    }

    // Sort by date, most recent first
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  } catch (e) {
    print('Error loading stress logs: $e');
    return [];
  }
}

static Future<void> _updateStressLogsList(String teacherId, String logId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final key = 'stress_logs_list_$teacherId';
    final existingLogs = prefs.getStringList(key) ?? [];
    existingLogs.add(logId);
    await prefs.setStringList(key, existingLogs);
  } catch (e) {
    print('Error updating stress logs list: $e');
  }
}

// Stress Metrics Management
static Future<List<StressReductionMetrics>> getStressMetrics(String teacherId, DateTime fromDate) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final metricsDir = Directory('${directory.path}/stress_metrics');
    if (!await metricsDir.exists()) {
      return [];
    }

    final metrics = <StressReductionMetrics>[];
    final files = metricsDir.listSync()
        .where((file) => file.path.contains(teacherId) && file.path.endsWith('.json'))
        .toList();

    for (final file in files) {
      try {
        final content = await File(file.path).readAsString();
        final metricMap = json.decode(content);
        final metric = StressReductionMetrics(
          id: metricMap['id'] ?? '',
          teacherId: metricMap['teacherId'] ?? '',
          weekStart: DateTime.parse(metricMap['weekStart']),
          stressReductionPercentage: Map<String, double>.from(metricMap['stressReductionPercentage'] ?? {}),
          timeSavings: Map<String, double>.from(metricMap['timeSavings'] ?? {}),
          appFeatureUsage: Map<String, int>.from(metricMap['appFeatureUsage'] ?? {}),
          overallImprovement: (metricMap['overallImprovement'] ?? 0.0).toDouble(),
          achievements: List<String>.from(metricMap['achievements'] ?? []),
        );
        
        if (metric.weekStart.isAfter(fromDate) || metric.weekStart.isAtSameMomentAs(fromDate)) {
          metrics.add(metric);
        }
      } catch (e) {
        print('Error reading stress metric file: ${file.path}');
      }
    }

    return metrics;
  } catch (e) {
    print('Error loading stress metrics: $e');
    return [];
  }
}

// Worksheet Management
static Future<void> saveWorksheet(WorksheetTemplate worksheet) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final worksheetsDir = Directory('${directory.path}/worksheets');
    if (!await worksheetsDir.exists()) {
      await worksheetsDir.create(recursive: true);
    }
    
    final file = File('${worksheetsDir.path}/${worksheet.id}.json');
    await file.writeAsString(json.encode(worksheet.toMap()));
  } catch (e) {
    print('Error saving worksheet: $e');
  }
}

static Future<List<WorksheetTemplate>> getWorksheets(String teacherId) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final worksheetsDir = Directory('${directory.path}/worksheets');
    if (!await worksheetsDir.exists()) {
      return [];
    }

    final worksheets = <WorksheetTemplate>[];
    final files = worksheetsDir.listSync()
        .where((file) => file.path.endsWith('.json'))
        .toList();

    for (final file in files) {
      try {
        final content = await File(file.path).readAsString();
        final worksheetMap = json.decode(content);
        final worksheet = WorksheetTemplate.fromMap(worksheetMap);
        worksheets.add(worksheet);
      } catch (e) {
        print('Error reading worksheet file: ${file.path}');
      }
    }

    // Sort by creation date, most recent first
    worksheets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return worksheets;
  } catch (e) {
    print('Error loading worksheets: $e');
    return [];
  }
}

// Helper method to clear old stress data (optional cleanup)
static Future<void> clearOldStressData(String teacherId, {int daysToKeep = 30}) async {
  try {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    
    // Clear old stress logs
    final directory = await getApplicationDocumentsDirectory();
    final stressLogsDir = Directory('${directory.path}/stress_logs');
    if (await stressLogsDir.exists()) {
      final files = stressLogsDir.listSync()
          .where((file) => file.path.contains(teacherId))
          .toList();
      
      for (final file in files) {
        final stat = await File(file.path).stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await File(file.path).delete();
        }
      }
    }
  } catch (e) {
    print('Error clearing old stress data: $e');
  }
}

}
