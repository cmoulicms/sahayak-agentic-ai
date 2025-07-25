// // providers/ai_assistant_provider.dart
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:sahayak_ai2/data/services/ai_teaching_assistant_service.dart';

// class AIAssistantProvider extends ChangeNotifier {
//   final AITeachingAssistantService _aiService = AITeachingAssistantService();

//   bool _isLoading = false;
//   String? _error;

//   // Recent responses
//   AIContentResponse? _lastContentResponse;
//   DifferentiatedMaterialsResponse? _lastMaterialsResponse;
//   KnowledgeResponse? _lastKnowledgeResponse;
//   VisualAidResponse? _lastVisualAidResponse;
//   EducationalGameResponse? _lastGameResponse;
//   WeeklyLessonPlanResponse? _lastLessonPlanResponse;
//   ReadingAssessmentResponse? _lastReadingAssessment;

//   // Chat history for knowledge base
//   final List<ChatMessage> _chatHistory = [];

//   // Getters
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   AIContentResponse? get lastContentResponse => _lastContentResponse;
//   DifferentiatedMaterialsResponse? get lastMaterialsResponse =>
//       _lastMaterialsResponse;
//   KnowledgeResponse? get lastKnowledgeResponse => _lastKnowledgeResponse;
//   VisualAidResponse? get lastVisualAidResponse => _lastVisualAidResponse;
//   EducationalGameResponse? get lastGameResponse => _lastGameResponse;
//   WeeklyLessonPlanResponse? get lastLessonPlanResponse =>
//       _lastLessonPlanResponse;
//   ReadingAssessmentResponse? get lastReadingAssessment =>
//       _lastReadingAssessment;
//   List<ChatMessage> get chatHistory => _chatHistory;

//   // Recent suggestions
//   final List<AISuggestion> _recentSuggestions = [
//     AISuggestion(
//       title: 'Explain Water Cycle',
//       description: 'Simple explanation with local examples',
//       icon: Icons.water_drop,
//       category: 'Science',
//     ),
//     AISuggestion(
//       title: 'Math Problem Solving',
//       description: 'Step-by-step approach for basic math',
//       icon: Icons.calculate,
//       category: 'Mathematics',
//     ),
//     AISuggestion(
//       title: 'Story Writing Tips',
//       description: 'Creative writing guidance for students',
//       icon: Icons.book,
//       category: 'English',
//     ),
//     AISuggestion(
//       title: 'Local History',
//       description: 'Stories from your region',
//       icon: Icons.history_edu,
//       category: 'Social Studies',
//     ),
//   ];

//   // Helper methods for state management
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _setError(String error) {
//     _error = error;
//     notifyListeners();
//   }

//   void _clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   // Generate hyper-local content
//   Future<void> generateLocalContent({
//     required String prompt,
//     required String language,
//     required String culturalContext,
//     String? subject,
//     String? gradeLevel,
//   }) async {
//     _setLoading(true);
//     try {
//       _lastContentResponse = await _aiService.generateLocalContent(
//         prompt: prompt,
//         language: language,
//         culturalContext: culturalContext,
//         subject: subject,
//         gradeLevel: gradeLevel,
//       );
//       _clearError();
//     } catch (e) {
//       _setError('Failed to generate content: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Create differentiated materials
//   Future<void> createDifferentiatedMaterials({
//     required Uint8List imageBytes,
//     required List<String> targetGrades,
//     String? subject,
//     String? language,
//   }) async {
//     _setLoading(true);
//     try {
//       _lastMaterialsResponse = await _aiService.createDifferentiatedMaterials(
//         imageBytes: imageBytes,
//         targetGrades: targetGrades,
//         subject: subject,
//         language: language,
//       );
//       _clearError();
//     } catch (e) {
//       _setError('Failed to create differentiated materials: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Explain concept (Knowledge Base)
//   Future<void> explainConcept({
//     required String question,
//     required String language,
//     String? gradeLevel,
//     bool includeAnalogy = true,
//   }) async {
//     _setLoading(true);

//     // Add user question to chat history
//     _chatHistory.add(ChatMessage(
//       content: question,
//       isUser: true,
//       timestamp: DateTime.now(),
//     ));

//     try {
//       _lastKnowledgeResponse = await _aiService.explainConcept(
//         question: question,
//         language: language,
//         gradeLevel: gradeLevel,
//         includeAnalogy: includeAnalogy,
//       );

//       // Add AI response to chat history
//       _chatHistory.add(ChatMessage(
//         content: _lastKnowledgeResponse!.explanation,
//         isUser: false,
//         timestamp: DateTime.now(),
//         knowledgeResponse: _lastKnowledgeResponse,
//       ));

//       _clearError();
//     } catch (e) {
//       _setError('Failed to explain concept: $e');
//       // Add error message to chat
//       _chatHistory.add(ChatMessage(
//         content: 'Sorry, I couldn\'t process that question. Please try again.',
//         isUser: false,
//         timestamp: DateTime.now(),
//         isError: true,
//       ));
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Generate visual aid
//   Future<void> generateVisualAid({
//     required String concept,
//     required String type,
//     String? subject,
//     String? gradeLevel,
//   }) async {
//     _setLoading(true);
//     try {
//       _lastVisualAidResponse = await _aiService.generateVisualAid(
//         concept: concept,
//         type: type,
//         subject: subject,
//         gradeLevel: gradeLevel,
//       );
//       _clearError();
//     } catch (e) {
//       _setError('Failed to generate visual aid: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Generate educational game
//   Future<void> generateGame({
//     required String topic,
//     required String gameType,
//     String? subject,
//     String? gradeLevel,
//     int duration = 15,
//   }) async {
//     _setLoading(true);
//     try {
//       _lastGameResponse = await _aiService.generateGame(
//         topic: topic,
//         gameType: gameType,
//         subject: subject,
//         gradeLevel: gradeLevel,
//         duration: duration,
//       );
//       _clearError();
//     } catch (e) {
//       _setError('Failed to generate game: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Generate weekly lesson plan
//   Future<void> generateWeeklyPlan({
//     required String subject,
//     required String gradeLevel,
//     required List<String> topics,
//     int daysPerWeek = 5,
//     int minutesPerDay = 45,
//   }) async {
//     _setLoading(true);
//     try {
//       _lastLessonPlanResponse = await _aiService.generateWeeklyPlan(
//         subject: subject,
//         gradeLevel: gradeLevel,
//         topics: topics,
//         daysPerWeek: daysPerWeek,
//         minutesPerDay: minutesPerDay,
//       );
//       _clearError();
//     } catch (e) {
//       _setError('Failed to generate weekly plan: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Assess reading
//   Future<void> assessReading({
//     required Uint8List audioBytes,
//     required String expectedText,
//     String? language,
//   }) async {
//     _setLoading(true);
//     try {
//       _lastReadingAssessment = await _aiService.assessReading(
//         audioBytes: audioBytes,
//         expectedText: expectedText,
//         language: language,
//       );
//       _clearError();
//     } catch (e) {
//       _setError('Failed to assess reading: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Clear chat history
//   void clearChatHistory() {
//     _chatHistory.clear();
//     notifyListeners();
//   }
// }
// providers/ai_assistant_provider.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:myapp/data/services/ai_teaching_assistant_service.dart';

class AIAssistantProvider extends ChangeNotifier {
  final AITeachingAssistantService _aiService = AITeachingAssistantService();

  bool _isLoading = false;
  String? _error;

  // Recent responses
  AIContentResponse? _lastContentResponse;
  DifferentiatedMaterialsResponse? _lastMaterialsResponse;
  KnowledgeResponse? _lastKnowledgeResponse;
  VisualAidResponse? _lastVisualAidResponse;
  EducationalGameResponse? _lastGameResponse;
  WeeklyLessonPlanResponse? _lastLessonPlanResponse;
  ReadingAssessmentResponse? _lastReadingAssessment;

  // Chat history for knowledge base
  final List<ChatMessage> _chatHistory = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AIContentResponse? get lastContentResponse => _lastContentResponse;
  DifferentiatedMaterialsResponse? get lastMaterialsResponse =>
      _lastMaterialsResponse;
  KnowledgeResponse? get lastKnowledgeResponse => _lastKnowledgeResponse;
  VisualAidResponse? get lastVisualAidResponse => _lastVisualAidResponse;
  EducationalGameResponse? get lastGameResponse => _lastGameResponse;
  WeeklyLessonPlanResponse? get lastLessonPlanResponse =>
      _lastLessonPlanResponse;
  ReadingAssessmentResponse? get lastReadingAssessment =>
      _lastReadingAssessment;
  List<ChatMessage> get chatHistory => _chatHistory;

  // Recent suggestions getter
  List<AISuggestion> get recentSuggestions => _recentSuggestions;

  // Recent suggestions list
  final List<AISuggestion> _recentSuggestions = [
    AISuggestion(
      title: 'Explain Water Cycle',
      description: 'Simple explanation with local examples',
      icon: Icons.water_drop,
      category: 'Science',
    ),
    AISuggestion(
      title: 'Math Problem Solving',
      description: 'Step-by-step approach for basic math',
      icon: Icons.calculate,
      category: 'Mathematics',
    ),
    AISuggestion(
      title: 'Story Writing Tips',
      description: 'Creative writing guidance for students',
      icon: Icons.book,
      category: 'English',
    ),
    AISuggestion(
      title: 'Local History',
      description: 'Stories from your region',
      icon: Icons.history_edu,
      category: 'Social Studies',
    ),
  ];

  // Helper methods for state management
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

  // Generate hyper-local content
  Future<void> generateLocalContent({
    required String prompt,
    required String language,
    required String culturalContext,
    String? subject,
    String? gradeLevel,
  }) async {
    _setLoading(true);
    try {
      _lastContentResponse = await _aiService.generateLocalContent(
        prompt: prompt,
        language: language,
        culturalContext: culturalContext,
        subject: subject,
        gradeLevel: gradeLevel,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to generate content: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create differentiated materials
  Future<void> createDifferentiatedMaterials({
    required Uint8List imageBytes,
    required List<String> targetGrades,
    String? subject,
    String? language,
  }) async {
    _setLoading(true);
    try {
      _lastMaterialsResponse = await _aiService.createDifferentiatedMaterials(
        imageBytes: imageBytes,
        targetGrades: targetGrades,
        subject: subject,
        language: language,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to create differentiated materials: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Explain concept (Knowledge Base)
  Future<void> explainConcept({
    required String question,
    required String language,
    String? gradeLevel,
    bool includeAnalogy = true,
  }) async {
    _setLoading(true);

    // Add user question to chat history
    _chatHistory.add(ChatMessage(
      content: question,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    try {
      _lastKnowledgeResponse = await _aiService.explainConcept(
        question: question,
        language: language,
        gradeLevel: gradeLevel,
        includeAnalogy: includeAnalogy,
      );
      // Add AI response to chat history
      _chatHistory.add(ChatMessage(
        content: _lastKnowledgeResponse!.explanation,
        isUser: false,
        timestamp: DateTime.now(),
        knowledgeResponse: _lastKnowledgeResponse,
      ));
      _clearError();
    } catch (e) {
      _setError('Failed to explain concept: $e');
      // Add error message to chat
      _chatHistory.add(ChatMessage(
        content: 'Sorry, I couldn\'t process that question. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Generate visual aid
  Future<void> generateVisualAid({
    required String concept,
    required String type,
    String? subject,
    String? gradeLevel,
  }) async {
    _setLoading(true);
    try {
      _lastVisualAidResponse = await _aiService.generateVisualAid(
        concept: concept,
        type: type,
        subject: subject,
        gradeLevel: gradeLevel,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to generate visual aid: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate educational game
  Future<void> generateGame({
    required String topic,
    required String gameType,
    String? subject,
    String? gradeLevel,
    int duration = 15,
  }) async {
    _setLoading(true);
    try {
      _lastGameResponse = await _aiService.generateGame(
        topic: topic,
        gameType: gameType,
        subject: subject,
        gradeLevel: gradeLevel,
        duration: duration,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to generate game: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate weekly lesson plan
  Future<void> generateWeeklyPlan({
    required String subject,
    required String gradeLevel,
    required List<String> topics,
    int daysPerWeek = 5,
    int minutesPerDay = 45,
  }) async {
    _setLoading(true);
    try {
      _lastLessonPlanResponse = await _aiService.generateWeeklyPlan(
        subject: subject,
        gradeLevel: gradeLevel,
        topics: topics,
        daysPerWeek: daysPerWeek,
        minutesPerDay: minutesPerDay,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to generate weekly plan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Assess reading
  Future<void> assessReading({
    required Uint8List audioBytes,
    required String expectedText,
    String? language,
  }) async {
    _setLoading(true);
    try {
      _lastReadingAssessment = await _aiService.assessReading(
        audioBytes: audioBytes,
        expectedText: expectedText,
        language: language,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to assess reading: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear chat history
  void clearChatHistory() {
    _chatHistory.clear();
    notifyListeners();
  }
}
