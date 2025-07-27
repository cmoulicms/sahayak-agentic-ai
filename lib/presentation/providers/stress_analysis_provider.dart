import 'package:flutter/foundation.dart';
import 'package:myapp/data/models/stress/stress_analysis_model.dart';

import 'package:myapp/data/services/ai_teaching_assistant_service.dart';
import 'package:myapp/data/services/stress_service.dart';

class StressAnalysisProvider with ChangeNotifier {
  final StressService _stressService = StressService();
  final AITeachingAssistantService _aiService = AITeachingAssistantService();

  // State variables
  StressProfile? _stressProfile;
  List<DailyStressLog> _stressLogs = [];
  List<StressReductionMetrics> _metrics = [];
  List<WorksheetTemplate> _worksheets = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  StressProfile? get stressProfile => _stressProfile;
  List<DailyStressLog> get stressLogs => _stressLogs;
  List<StressReductionMetrics> get metrics => _metrics;
  List<WorksheetTemplate> get worksheets => _worksheets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Current stress levels for real-time monitoring
  Map<String, int> _currentStressLevels = {};
  Map<String, int> get currentStressLevels => _currentStressLevels;

  // Initialize stress profile
  Future<void> initializeStressProfile(
      String teacherId, Map<String, int> initialStressLevels) async {
    _setLoading(true);
    try {
      _stressProfile = await _stressService.createStressProfile(
          teacherId, initialStressLevels);
      _currentStressLevels = Map.from(initialStressLevels);
      await loadStressData(teacherId);
      _clearError();
    } catch (e) {
      _setError('Failed to initialize stress profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all stress-related data
  Future<void> loadStressData(String teacherId) async {
    try {
      final results = await Future.wait([
        _stressService.getStressProfile(teacherId),
        _stressService.getStressLogs(
            teacherId, DateTime.now().subtract(const Duration(days: 30))),
        _stressService.getStressMetrics(
            teacherId, DateTime.now().subtract(const Duration(days: 7))),
      ]);

      _stressProfile = results[0] as StressProfile?;
      _stressLogs = results[1] as List<DailyStressLog>;
      _metrics = results[2] as List<StressReductionMetrics>;

      if (_stressProfile != null) {
        _currentStressLevels = Map.from(_stressProfile!.stressLevels);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load stress data: $e');
    }
  }

  // Log daily stress check-in
  Future<void> logDailyStress({
    required String teacherId,
    required Map<String, int> stressLevels,
    required List<String> triggers,
    required List<String> relievers,
    required int overallWellness,
    String notes = '',
  }) async {
    _setLoading(true);
    try {
      final log = await _stressService.logDailyStress(
        teacherId: teacherId,
        stressLevels: stressLevels,
        triggers: triggers,
        relievers: relievers,
        overallWellness: overallWellness,
        notes: notes,
      );

      _stressLogs.insert(0, log);
      _currentStressLevels = Map.from(stressLevels);

      // Update stress profile
      await _updateStressProfile(teacherId, stressLevels);

      // Check for interventions needed
      await _checkStressInterventions(teacherId, stressLevels);

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to log stress data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Check if stress intervention is needed
  Future<void> _checkStressInterventions(
      String teacherId, Map<String, int> stressLevels) async {
    final highStressAreas =
        stressLevels.entries.where((entry) => entry.value >= 4).toList();

    if (highStressAreas.isNotEmpty) {
      // Generate personalized stress relief suggestions
      final suggestions =
          await _generateStressReliefSuggestions(highStressAreas);

      // You can implement notification system here
      // _notificationService.showStressAlert(suggestions);
    }
  }

  // Generate stress relief suggestions using AI
  Future<List<String>> _generateStressReliefSuggestions(
      List<MapEntry<String, int>> highStressAreas) async {
    try {
      final prompt = '''
      Generate personalized stress relief suggestions for a teacher experiencing high stress in these areas:
      ${highStressAreas.map((e) => '${e.key}: Level ${e.value}/5').join(', ')}
      
      Provide 3-5 actionable, immediate stress relief techniques that can be done in school.
      ''';

      final response = await _aiService.generateLocalContent(
        prompt: prompt,
        language: 'English',
        culturalContext: 'School environment',
      );

      // Parse suggestions from AI response
      return response.content
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .take(5)
          .toList();
    } catch (e) {
      return [
        'Take 5 deep breaths and focus on your breathing',
        'Step outside for 2 minutes of fresh air',
        'Drink a glass of water mindfully',
        'Do some neck and shoulder stretches',
        'Write down 3 things you\'re grateful for today'
      ];
    }
  }

  // Generate AI worksheet
  Future<WorksheetTemplate?> generateWorksheet({
    required String subject,
    required String gradeLevel,
    required String topic,
    required String difficulty,
    required int questionCount,
    List<String> questionTypes = const [
      'multiple_choice',
      'fill_blanks',
      'short_answer'
    ],
  }) async {
    _setLoading(true);
    try {
      final prompt = '''
      Create a comprehensive worksheet for:
      - Subject: $subject
      - Grade Level: $gradeLevel
      - Topic: $topic
      - Difficulty: $difficulty
      - Question Count: $questionCount
      - Question Types: ${questionTypes.join(', ')}
      
      Generate structured content with:
      1. Clear instructions for each section
      2. Varied question types as requested
      3. Appropriate difficulty progression
      4. Answer key with explanations
      5. Scoring rubric
      
      Format as JSON with sections, questions, and metadata.
      ''';

      final response = await _aiService.generateLocalContent(
        prompt: prompt,
        language: 'English',
        culturalContext: 'Indian classroom',
        subject: subject,
        gradeLevel: gradeLevel,
      );

      final worksheet = _parseWorksheetFromAI(
          response.content, subject, gradeLevel, topic, difficulty);

      if (worksheet != null) {
        _worksheets.insert(0, worksheet);
        await _stressService.saveWorksheet(worksheet);
      }

      _clearError();
      notifyListeners();
      return worksheet;
    } catch (e) {
      _setError('Failed to generate worksheet: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Parse AI response into worksheet structure
  WorksheetTemplate? _parseWorksheetFromAI(String content, String subject,
      String gradeLevel, String topic, String difficulty) {
    try {
      // This is a simplified parser - you'd want more robust JSON parsing
      final sections = <WorksheetSection>[];

      // Create sample sections for demonstration
      sections.add(WorksheetSection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Multiple Choice Questions',
        type: 'multiple_choice',
        questions: [
          WorksheetQuestion(
            id: '1',
            question: 'Sample question from AI: $topic',
            options: ['Option A', 'Option B', 'Option C', 'Option D'],
            correctAnswer: 'Option A',
            explanation: 'Explanation from AI',
            points: 2,
          ),
        ],
        instructions: 'Choose the best answer for each question.',
        points: 10,
      ));

      return WorksheetTemplate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '$topic Worksheet - Grade $gradeLevel',
        subject: subject,
        gradeLevel: gradeLevel,
        difficulty: difficulty,
        sections: sections,
        aiGeneratedContent: {
          'content': content,
          'generated_at': DateTime.now().toIso8601String()
        },
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error parsing worksheet: $e');
      return null;
    }
  }

  // Get stress reduction insights
  Map<String, dynamic> getStressInsights() {
    if (_stressLogs.isEmpty) return {};

    final last7Days = _stressLogs
        .where((log) => DateTime.now().difference(log.date).inDays <= 7)
        .toList();

    if (last7Days.isEmpty) return {};

    final insights = <String, dynamic>{};

    // Calculate average stress levels
    final avgStress = <String, double>{};
    final stressFactors = [
      'workload',
      'resources',
      'behavior',
      'admin',
      'parents',
      'technology'
    ];

    for (final factor in stressFactors) {
      final values = last7Days
          .map((log) =>
              (log.morningStress[factor] ??
                  0 + log.midDayStress[factor]! ??
                  0) /
              3)
          .toList();

      if (values.isNotEmpty) {
        avgStress[factor] = values.reduce((a, b) => a + b) / values.length;
      }
    }

    insights['averageStress'] = avgStress;
    insights['trendDirection'] = _calculateStressTrend(last7Days);
    insights['recommendations'] = _generateRecommendations(avgStress);

    return insights;
  }

  String _calculateStressTrend(List<DailyStressLog> logs) {
    if (logs.length < 2) return 'stable';

    final recent =
        logs.take(3).map((l) => l.overallWellness).reduce((a, b) => a + b) / 3;
    final older = logs
            .skip(3)
            .take(3)
            .map((l) => l.overallWellness)
            .reduce((a, b) => a + b) /
        3;

    if (recent > older + 1) return 'improving';
    if (recent < older - 1) return 'declining';
    return 'stable';
  }

  List<String> _generateRecommendations(Map<String, double> avgStress) {
    final recommendations = <String>[];

    avgStress.forEach((factor, level) {
      if (level >= 4.0) {
        switch (factor) {
          case 'workload':
            recommendations.add(
                'Consider using AI lesson planning to reduce preparation time');
            break;
          case 'resources':
            recommendations
                .add('Explore the AI resource generator for quick materials');
            break;
          case 'admin':
            recommendations.add('Try automated progress tracking features');
            break;
          case 'parents':
            recommendations
                .add('Use communication templates for parent interactions');
            break;
        }
      }
    });

    return recommendations.take(3).toList();
  }

  // Update stress profile with new data
  Future<void> _updateStressProfile(
      String teacherId, Map<String, int> newStressLevels) async {
    if (_stressProfile == null) return;

    try {
      final updatedProfile = _stressProfile!.copyWith(
        stressLevels: newStressLevels,
        lastUpdated: DateTime.now(),
      );

      await _stressService.updateStressProfile(updatedProfile);
      _stressProfile = updatedProfile;
    } catch (e) {
      print('Error updating stress profile: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

// Extension for copying StressProfile
extension StressProfileExtension on StressProfile {
  StressProfile copyWith({
    String? id,
    String? teacherId,
    Map<String, int>? stressLevels,
    Map<String, double>? timeImpact,
    Map<String, String>? copingStrategies,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return StressProfile(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      stressLevels: stressLevels ?? this.stressLevels,
      timeImpact: timeImpact ?? this.timeImpact,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
