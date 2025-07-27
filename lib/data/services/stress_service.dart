import 'package:Sahayak/data/models/stress/stress_analysis_model.dart';
import 'package:Sahayak/data/services/local_storage_service.dart';

class StressService {
  // Create initial stress profile
  Future<StressProfile> createStressProfile(
    String teacherId,
    Map<String, int> initialStressLevels,
  ) async {
    final profile = StressProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teacherId: teacherId,
      stressLevels: initialStressLevels,
      timeImpact: {},
      copingStrategies: {},
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    // Save to local storage (you can extend this to use Firebase)
    await LocalStorageService.saveStressProfile(profile);
    return profile;
  }

  // Get stress profile
  Future<StressProfile?> getStressProfile(String teacherId) async {
    return await LocalStorageService.getStressProfile(teacherId);
  }

  // Update stress profile
  Future<void> updateStressProfile(StressProfile profile) async {
    await LocalStorageService.saveStressProfile(profile);
  }

  // Log daily stress
  Future<DailyStressLog> logDailyStress({
    required String teacherId,
    required Map<String, int> stressLevels,
    required List<String> triggers,
    required List<String> relievers,
    required int overallWellness,
    String notes = '',
  }) async {
    final log = DailyStressLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teacherId: teacherId,
      date: DateTime.now(),
      morningStress: stressLevels,
      midDayStress: stressLevels, // You can modify this for different times
      eveningStress: stressLevels,
      stressTriggers: triggers,
      stressRelievers: relievers,
      overallWellness: overallWellness,
      notes: notes,
    );

    await LocalStorageService.saveStressLog(log);
    return log;
  }

  // Get stress logs
  Future<List<DailyStressLog>> getStressLogs(
    String teacherId,
    DateTime fromDate,
  ) async {
    return await LocalStorageService.getStressLogs(teacherId, fromDate);
  }

  // Get stress metrics
  Future<List<StressReductionMetrics>> getStressMetrics(
    String teacherId,
    DateTime fromDate,
  ) async {
    return await LocalStorageService.getStressMetrics(teacherId, fromDate);
  }

  // Save worksheet
  Future<void> saveWorksheet(WorksheetTemplate worksheet) async {
    await LocalStorageService.saveWorksheet(worksheet);
  }

  // Get worksheets
  Future<List<WorksheetTemplate>> getWorksheets(String teacherId) async {
    return await LocalStorageService.getWorksheets(teacherId);
  }
}
