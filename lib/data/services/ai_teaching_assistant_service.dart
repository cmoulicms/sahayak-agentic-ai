// services/ai_teaching_assistant_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AITeachingAssistantService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _vertexAIUrl =
      'https://asia-south1-aiplatform.googleapis.com/v1';

  // Replace with your actual API key and project ID:
  static const String _apiKey = 'AIzaSyCEB7jMY2LbEWiKb4WlKulH8zwHGIf8_w4';
  static const String _projectId = 'com.example.myapp';

  Future<AIContentResponse> generateLocalContent({
    required String prompt,
    required String language,
    required String culturalContext,
    String? subject,
    String? gradeLevel,
  }) async {
    final enhancedPrompt = '''
Create educational content in $language for ${gradeLevel ?? 'mixed grade'} students.
Cultural Context: $culturalContext
Subject: ${subject ?? 'general'}
Request: $prompt
Please provide:
1. Simple, culturally relevant content
2. Easy-to-understand language appropriate for the grade level
3. Local examples and analogies
4. Interactive elements if applicable
Format the response as structured content that a teacher can easily use.
''';

    final response = await _callGeminiAPI(enhancedPrompt);

    return AIContentResponse(
      content: response['content'] ?? '',
      language: language,
      subject: subject ?? 'general',
      gradeLevel: gradeLevel ?? 'mixed',
      culturallyAdapted: true,
      generatedAt: DateTime.now(),
    );
  }

  Future<DifferentiatedMaterialsResponse> createDifferentiatedMaterials({
    required Uint8List imageBytes,
    required List<String> targetGrades,
    String? subject,
    String? language,
  }) async {
    final base64Image = base64Encode(imageBytes);
    final prompt = '''
    Analyze this textbook page and create differentiated worksheets for grades: ${targetGrades.join(', ')}.
    Subject: ${subject ?? 'general'}
    Language: ${language ?? 'English'}
    For each grade level, provide:
    1. Simplified version of the content
    2. Age-appropriate questions
    3. Visual aids descriptions
    4. Hands-on activities
    5. Assessment criteria
    Make sure content is progressively complex from lower to higher grades.
    ''';

    final response = await _callGeminiVisionAPI(prompt, base64Image);

    List<GradeLevelMaterial> materials = [];
    for (String grade in targetGrades) {
      materials.add(GradeLevelMaterial(
        gradeLevel: grade,
        content: response['content_$grade'] ?? response['content'] ?? '',
        activities: _extractActivities(response, grade),
        assessments: _extractAssessments(response, grade),
        visualAids: _extractVisualAids(response, grade),
      ));
    }
    return DifferentiatedMaterialsResponse(
      originalImage: imageBytes,
      materials: materials,
      subject: subject ?? 'general',
      language: language ?? 'English',
      generatedAt: DateTime.now(),
    );
  }

  Future<KnowledgeResponse> explainConcept({
    required String question,
    required String language,
    String? gradeLevel,
    bool includeAnalogy = true,
  }) async {
    final prompt = '''
    Explain this concept in $language for ${gradeLevel ?? 'elementary'} level students: "$question"
    Provide:
    1. Simple, clear explanation
    ${includeAnalogy ? '2. Easy-to-understand analogy or example from daily life' : ''}
    3. Key points to remember
    4. Common misconceptions to avoid
    5. Fun facts if relevant
    Keep the language simple and engaging for young learners.
    ''';

    final response = await _callGeminiAPI(prompt);

    return KnowledgeResponse(
      question: question,
      explanation: response['explanation'] ?? response['content'] ?? '',
      analogy: includeAnalogy ? response['analogy'] ?? '' : '',
      keyPoints: _extractKeyPoints(response),
      funFacts: _extractFunFacts(response),
      language: language,
      gradeLevel: gradeLevel ?? 'elementary',
      generatedAt: DateTime.now(),
    );
  }

  // Generate weekly lesson planner
  Future<WeeklyLessonPlanResponse> generateWeeklyPlan({
    required String subject,
    required String gradeLevel,
    required List<String> topics,
    int daysPerWeek = 5,
    int minutesPerDay = 45,
  }) async {
    try {
      final prompt = '''
        Create a weekly lesson plan for $subject, Grade $gradeLevel.
        Topics to cover: ${topics.join(', ')}
        Schedule: $daysPerWeek days per week, $minutesPerDay minutes per day

        For each day, provide:
        1. Learning objectives
        2. Activities breakdown with timing
        3. Materials needed
        4. Assessment methods
        5. Homework/follow-up activities
        6. Differentiation strategies

        Make it practical for a multi-grade classroom with limited resources.
      ''';

      final response = await _callGeminiAPI(prompt);

      List<DailyLessonPlan> dailyPlans = [];
      for (int i = 1; i <= daysPerWeek; i++) {
        dailyPlans.add(DailyLessonPlan(
          day: i,
          topic: topics.length >= i ? topics[i - 1] : 'Review/Assessment',
          objectives: _extractDailyObjectives(response, i),
          activities: _extractDailyActivities(response, i),
          materials: _extractDailyMaterials(response, i),
          assessment: _extractDailyAssessment(response, i),
          homework: _extractDailyHomework(response, i),
          duration: minutesPerDay,
        ));
      }

      return WeeklyLessonPlanResponse(
        subject: subject,
        gradeLevel: gradeLevel,
        topics: topics,
        dailyPlans: dailyPlans,
        totalDuration: daysPerWeek * minutesPerDay,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw AIServiceException('Failed to generate weekly lesson plan: $e');
    }
  }

  // Speech-to-text for reading assessment
  Future<ReadingAssessmentResponse> assessReading({
    required Uint8List audioBytes,
    required String expectedText,
    String? language,
  }) async {
    try {
      // Convert audio to text using Vertex AI Speech-to-Text
      final transcription = await _speechToText(audioBytes, language);

      // Analyze reading accuracy
      final analysisPrompt = '''
        Compare the expected text with the actual reading transcription.
        Expected: "$expectedText"
        Actual: "$transcription"

        Provide reading assessment with:
        1. Accuracy percentage
        2. Pronunciation errors
        3. Fluency rating (1-5)
        4. Areas for improvement
        5. Positive feedback
        6. Suggested practice activities
      ''';

      final analysis = await _callGeminiAPI(analysisPrompt);

      return ReadingAssessmentResponse(
        expectedText: expectedText,
        actualTranscription: transcription,
        accuracyPercentage: _calculateAccuracy(expectedText, transcription),
        fluencyRating: _extractFluencyRating(analysis),
        pronunciationErrors: _extractErrors(analysis),
        feedback: analysis['feedback'] ?? analysis['content'] ?? '',
        suggestions: _extractSuggestions(analysis),
        language: language ?? 'English',
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      throw AIServiceException('Failed to assess reading: $e');
    }
  }

  // Updated private helper methods with correct model names
  Future<Map<String, dynamic>> _callGeminiAPI(String prompt) async {
    // Updated model name - use gemini-1.5-flash for faster responses
    // or gemini-1.5-pro for more complex tasks
    final url =
        '$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
            'topP': 0.8,
            'topK': 40,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          return {'content': content};
        } else {
          throw Exception('No content generated by API');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'API call failed: ${response.statusCode} - ${errorData['error']['message']}');
      }
    } catch (e) {
      print('Error in _callGeminiAPI: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _callGeminiVisionAPI(
      String prompt, String base64Image) async {
    // Updated model name for vision capabilities
    final url =
        '$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
            'topP': 0.8,
            'topK': 40,
          }
        }),
      );

      print('Vision API Response Status: ${response.statusCode}');
      print('Vision API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          return {'content': content};
        } else {
          throw Exception('No content generated by Vision API');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Vision API call failed: ${response.statusCode} - ${errorData['error']['message']}');
      }
    } catch (e) {
      print('Error in _callGeminiVisionAPI: $e');
      rethrow;
    }
  }

  Future<String> _speechToText(Uint8List audioBytes, String? language) async {
    // Implement Vertex AI Speech-to-Text API call
    final url =
        '$_vertexAIUrl/projects/$_projectId/locations/asia-south1/publishers/google/models/speechtotext:predict';

    // This is a simplified implementation - you'll need to handle authentication
    // and proper audio encoding based on your specific requirements

    return "Transcribed text would appear here"; // Placeholder
  }

  // Helper extraction methods
  List<String> _extractActivities(Map<String, dynamic> response, String grade) {
    final content = response['content'] ?? '';
    final activities = <String>[];

    final lines = content.split('\n');
    for (String line in lines) {
      if (line.toLowerCase().contains('activity') ||
          line.toLowerCase().contains('exercise')) {
        activities.add(line.trim());
      }
    }

    return activities.isNotEmpty
        ? activities
        : ['Interactive discussion', 'Hands-on practice'];
  }

  Future<VisualAidResponse> generateVisualAid({
    required String concept,
    required String type,
    String? subject,
    String? gradeLevel,
  }) async {
    final prompt = '''
Create a detailed description for a $type to explain "$concept" for ${gradeLevel ?? 'elementary'} students.
Subject: ${subject ?? 'general'}
Provide:
1. Step-by-step drawing instructions for a teacher to recreate on blackboard
2. Labels and text to include
3. Colors or shading suggestions (if applicable)
4. Key elements to emphasize
5. Interactive elements students can participate in
Make it simple enough to draw with chalk on a blackboard.
''';

    final response = await _callGeminiAPI(prompt);

    return VisualAidResponse(
      concept: concept,
      type: type,
      drawingInstructions:
          response['instructions'] ?? response['content'] ?? '',
      labels: _extractLabels(response),
      materials: ['Chalk', 'Blackboard', 'Ruler/Scale'],
      estimatedTime: _estimateDrawingTime(type),
      subject: subject ?? 'general',
      gradeLevel: gradeLevel ?? 'elementary',
      generatedAt: DateTime.now(),
    );
  }

  Future<EducationalGameResponse> generateGame({
    required String topic,
    required String gameType,
    String? subject,
    String? gradeLevel,
    int duration = 15,
  }) async {
    final prompt = '''
Create an educational $gameType game about "$topic" for ${gradeLevel ?? 'elementary'} students.
Subject: ${subject ?? 'general'}
Duration: $duration minutes
Provide:
1. Game rules and setup
2. Materials needed (simple, low-resource)
3. Step-by-step instructions
4. Variations for different skill levels
5. Learning objectives
6. Assessment criteria
Make it suitable for a classroom with limited resources.
''';

    final response = await _callGeminiAPI(prompt);

    return EducationalGameResponse(
      topic: topic,
      gameType: gameType,
      title: response['title'] ?? '$gameType Game: $topic',
      rules: response['rules'] ?? '',
      instructions: response['instructions'] ?? response['content'] ?? '',
      materials: _extractMaterials(response),
      duration: duration,
      learningObjectives: _extractObjectives(response),
      variations: _extractVariations(response),
      subject: subject ?? 'general',
      gradeLevel: gradeLevel ?? 'elementary',
      generatedAt: DateTime.now(),
    );
  }

  // Additional helper methods remain the same...
  List<String> _extractAssessments(Map response, String grade) {
    return ['Oral questioning', 'Quick quiz'];
  }

  List<String> _extractVisualAids(Map response, String grade) {
    return ['Simple diagrams', 'Visual examples'];
  }

  List<String> _extractKeyPoints(Map response) {
    return ['Key concept explained', 'Important to remember'];
  }

  List<String> _extractFunFacts(Map response) {
    return ['Interesting related fact'];
  }

  List<String> _extractLabels(Map response) {
    return ['Main label', 'Secondary label'];
  }

  int _estimateDrawingTime(String type) {
    switch (type) {
      case 'diagram':
        return 10;
      case 'chart':
        return 8;
      case 'illustration':
        return 15;
      case 'flowchart':
        return 12;
      default:
        return 10;
    }
  }

  List<String> _extractMaterials(Map response) {
    return ['Paper', 'Pencil', 'Basic supplies'];
  }

  List<String> _extractObjectives(Map response) {
    return ['Learning objective 1', 'Learning objective 2'];
  }

  List<String> _extractVariations(Map response) {
    return ['Easier version', 'Advanced version'];
  }

  List<String> _extractDailyObjectives(Map<String, dynamic> response, int day) {
    return [
      'Day $day: Understanding core concepts',
      'Day $day: Practical application'
    ];
  }

  List<String> _extractDailyActivities(Map<String, dynamic> response, int day) {
    return [
      'Day $day: Introduction activity',
      'Day $day: Practice exercise',
      'Day $day: Review session'
    ];
  }

  List<String> _extractDailyMaterials(Map<String, dynamic> response, int day) {
    return ['Textbook', 'Worksheets', 'Basic supplies'];
  }

  String _extractDailyAssessment(Map<String, dynamic> response, int day) {
    return 'Day $day: Quick assessment through Q&A and observation';
  }

  String _extractDailyHomework(Map<String, dynamic> response, int day) {
    return 'Day $day: Practice exercises and reading assignment';
  }
}

// Helper functions (moved outside the class)
double _calculateAccuracy(String expected, String actual) {
  final expectedWords = expected.toLowerCase().split(' ');
  final actualWords = actual.toLowerCase().split(' ');

  int matches = 0;
  int maxLength = expectedWords.length > actualWords.length
      ? expectedWords.length
      : actualWords.length;

  for (int i = 0;
      i < maxLength && i < expectedWords.length && i < actualWords.length;
      i++) {
    if (expectedWords[i] == actualWords[i]) matches++;
  }

  return maxLength > 0 ? (matches / maxLength) * 100.0 : 0.0;
}

int _extractFluencyRating(Map<String, dynamic> analysis) {
  final content = analysis['content'] ?? '';
  final ratingMatch = RegExp(r'(\d)/5').firstMatch(content);
  if (ratingMatch != null) {
    return int.tryParse(ratingMatch.group(1) ?? '3') ?? 3;
  }
  return 3;
}

List<String> _extractErrors(Map<String, dynamic> analysis) {
  final content = analysis['content'] ?? '';
  final errors = <String>[];

  final lines = content.split('\n');
  for (String line in lines) {
    if (line.toLowerCase().contains('error') ||
        line.toLowerCase().contains('mistake') ||
        line.toLowerCase().contains('pronunciation')) {
      errors.add(line.trim());
    }
  }

  return errors.isNotEmpty ? errors : ['Minor pronunciation variations'];
}

List<String> _extractSuggestions(Map<String, dynamic> analysis) {
  final content = analysis['content'] ?? '';
  final suggestions = <String>[];

  final lines = content.split('\n');
  for (String line in lines) {
    if (line.toLowerCase().contains('suggest') ||
        line.toLowerCase().contains('recommend') ||
        line.toLowerCase().contains('practice')) {
      suggestions.add(line.trim());
    }
  }

  return suggestions.isNotEmpty
      ? suggestions
      : ['Practice reading aloud', 'Focus on difficult words'];
}

// Data Models (keep these the same as in your original file)
class AIContentResponse {
  final String content;
  final String language;
  final String subject;
  final String gradeLevel;
  final bool culturallyAdapted;
  final DateTime generatedAt;

  AIContentResponse({
    required this.content,
    required this.language,
    required this.subject,
    required this.gradeLevel,
    required this.culturallyAdapted,
    required this.generatedAt,
  });
}

class DifferentiatedMaterialsResponse {
  final Uint8List originalImage;
  final List<GradeLevelMaterial> materials;
  final String subject;
  final String language;
  final DateTime generatedAt;

  DifferentiatedMaterialsResponse({
    required this.originalImage,
    required this.materials,
    required this.subject,
    required this.language,
    required this.generatedAt,
  });
}

class GradeLevelMaterial {
  final String gradeLevel;
  final String content;
  final List<String> activities;
  final List<String> assessments;
  final List<String> visualAids;

  GradeLevelMaterial({
    required this.gradeLevel,
    required this.content,
    required this.activities,
    required this.assessments,
    required this.visualAids,
  });
}

class KnowledgeResponse {
  final String question;
  final String explanation;
  final String analogy;
  final List<String> keyPoints;
  final List<String> funFacts;
  final String language;
  final String gradeLevel;
  final DateTime generatedAt;

  KnowledgeResponse({
    required this.question,
    required this.explanation,
    required this.analogy,
    required this.keyPoints,
    required this.funFacts,
    required this.language,
    required this.gradeLevel,
    required this.generatedAt,
  });
}

class VisualAidResponse {
  final String concept;
  final String type;
  final String drawingInstructions;
  final List<String> labels;
  final List<String> materials;
  final int estimatedTime;
  final String subject;
  final String gradeLevel;
  final DateTime generatedAt;

  VisualAidResponse({
    required this.concept,
    required this.type,
    required this.drawingInstructions,
    required this.labels,
    required this.materials,
    required this.estimatedTime,
    required this.subject,
    required this.gradeLevel,
    required this.generatedAt,
  });
}

class EducationalGameResponse {
  final String topic;
  final String gameType;
  final String title;
  final String rules;
  final String instructions;
  final List<String> materials;
  final int duration;
  final List<String> learningObjectives;
  final List<String> variations;
  final String subject;
  final String gradeLevel;
  final DateTime generatedAt;

  EducationalGameResponse({
    required this.topic,
    required this.gameType,
    required this.title,
    required this.rules,
    required this.instructions,
    required this.materials,
    required this.duration,
    required this.learningObjectives,
    required this.variations,
    required this.subject,
    required this.gradeLevel,
    required this.generatedAt,
  });
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final KnowledgeResponse? knowledgeResponse;
  final bool isError;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.knowledgeResponse,
    this.isError = false,
  });
}

class AISuggestion {
  final String title;
  final String description;
  final dynamic icon;
  final String category;

  AISuggestion({
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });
}

class ReadingAssessmentResponse {
  final String expectedText;
  final String actualTranscription;
  final double accuracyPercentage;
  final int fluencyRating;
  final List<String> pronunciationErrors;
  final String feedback;
  final List<String> suggestions;
  final String language;
  final DateTime assessedAt;

  ReadingAssessmentResponse({
    required this.expectedText,
    required this.actualTranscription,
    required this.accuracyPercentage,
    required this.fluencyRating,
    required this.pronunciationErrors,
    required this.feedback,
    required this.suggestions,
    required this.language,
    required this.assessedAt,
  });
}

class DailyLessonPlan {
  final int day;
  final String topic;
  final List<String> objectives;
  final List<String> activities;
  final List<String> materials;
  final String assessment;
  final String homework;
  final int duration;

  DailyLessonPlan({
    required this.day,
    required this.topic,
    required this.objectives,
    required this.activities,
    required this.materials,
    required this.assessment,
    required this.homework,
    required this.duration,
  });
}

class WeeklyLessonPlanResponse {
  final String subject;
  final String gradeLevel;
  final List<String> topics;
  final List<DailyLessonPlan> dailyPlans;
  final int totalDuration;
  final DateTime generatedAt;

  WeeklyLessonPlanResponse({
    required this.subject,
    required this.gradeLevel,
    required this.topics,
    required this.dailyPlans,
    required this.totalDuration,
    required this.generatedAt,
  });
}

class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);

  @override
  String toString() => 'AIServiceException: $message';
}
