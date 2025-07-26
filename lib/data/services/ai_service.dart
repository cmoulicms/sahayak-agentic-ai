// services/ai_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/data/models/lesson/enhanced_lesson_plan.dart';
import 'package:myapp/data/models/morningPrep/morningPrep_model.dart';


class AIService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  // For demo purposes, we'll simulate AI responses
  final bool _isDemoMode = _apiKey.isEmpty;

  Future<EnhancedLessonPlan> generateLessonPlan({
    required String teacherId,
    required String subject,
    required String topic,
    required String gradeLevel,
    required int duration,
    String? chapter,
    List<String>? keywords,
  }) async {
    if (_isDemoMode) {
      return _generateDemoLessonPlan(
        teacherId: teacherId,
        subject: subject,
        topic: topic,
        gradeLevel: gradeLevel,
        duration: duration,
        chapter: chapter,
        keywords: keywords,
      );
    }

    try {
      final prompt = _buildLessonPlanPrompt(
        subject: subject,
        topic: topic,
        gradeLevel: gradeLevel,
        duration: duration,
        chapter: chapter,
        keywords: keywords,
      );

      final response = await _callGeminiAPI(prompt);
      return _parseLessonPlanResponse(
        response,
        teacherId: teacherId,
        subject: subject,
        topic: topic,
        gradeLevel: gradeLevel,
        duration: duration,
        chapter: chapter,
        keywords: keywords,
      );
    } catch (e) {
      throw Exception('Failed to generate lesson plan: $e');
    }
  }

  Future<MorningPrepData> generateMorningPrep({
    required String teacherId,
    required String date,
    required List<EnhancedLessonPlan> todayLessons,
    required List<EnhancedLessonPlan> response,
  }) async {
    if (_isDemoMode) {
      return _generateDemoMorningPrep(
          teacherId, date, todayLessons as String, response);
    }

    try {
      final prompt = _buildMorningPrepPrompt(date, todayLessons);
      final response = await _callGeminiAPI(prompt);
      return _parseMorningPrepResponse(response, teacherId, date);
    } catch (e) {
      throw Exception('Failed to generate morning prep: $e');
    }
  }

  Future<String> _callGeminiAPI(String prompt) async {
    final url =
        Uri.parse('$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey');

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('API call failed: ${response.statusCode}');
    }
  }

  String _buildLessonPlanPrompt({
    required String subject,
    required String topic,
    required String gradeLevel,
    required int duration,
    String? chapter,
    List<String>? keywords,
  }) {
    return '''
Create a comprehensive lesson plan for:
- Subject: $subject
- Topic: $topic
- Grade Level: $gradeLevel
- Duration: $duration minutes
${chapter != null ? '- Chapter: $chapter' : ''}
${keywords != null && keywords.isNotEmpty ? '- Keywords: ${keywords.join(', ')}' : ''}

Please provide a detailed lesson plan in JSON format with the following structure:
{
  "objectives": [
    {
      "description": "Learning objective description",
      "bloomsLevel": "Remember/Understand/Apply/Analyze/Evaluate/Create"
    }
  ],
  "activities": [
    {
      "title": "Activity title",
      "description": "Activity description",
      "duration": 15,
      "type": "Introduction/Explanation/Practice/Assessment",
      "materials": ["Material 1", "Material 2"],
      "instructions": "Detailed instructions"
    }
  ],
  "resources": [
    {
      "name": "Resource name",
      "type": "Video/Document/Website/Tool",
      "description": "Resource description",
      "isRequired": true
    }
  ],
  "assessment": {
    "formativeType": "Quiz/Discussion/Observation",
    "summativeType": "Test/Project/Presentation",
    "questions": ["Question 1", "Question 2"]
  },
  "differentiation": {
    "visualLearners": "Strategy for visual learners",
    "auditoryLearners": "Strategy for auditory learners",
    "kinestheticLearners": "Strategy for kinesthetic learners",
    "advancedStudents": "Extension activities",
    "strugglingStudents": "Support strategies"
  }
}

Make it engaging, age-appropriate, and aligned with modern educational standards.
''';
  }

  String _buildMorningPrepPrompt(
      String date, List<EnhancedLessonPlan> todayLessons) {
    final lessonsInfo = todayLessons
        .map((lesson) =>
            '${lesson.subject}: ${lesson.topic} (Grade ${lesson.gradeLevel}, ${lesson.estimatedDuration}min)')
        .join('\n');

    return '''
Generate a morning preparation checklist for a teacher on $date.
Today's lessons:
$lessonsInfo

Provide a JSON response with:
{
  "tasks": [
    {
      "title": "Task title",
      "description": "Task description",
      "estimatedMinutes": 5,
      "category": "materials/review/preparation/wellness"
    }
  ],
  "weather": {
    "condition": "Sunny",
    "temperature": 25,
    "suggestion": "Perfect weather for outdoor activities"
  },
  "quickTips": ["Tip 1", "Tip 2", "Tip 3"],
  "moodCheckIn": {
    "mood": "focused",
    "energyLevel": 8,
    "concerns": ["Time management", "Student engagement"],
    "motivationalQuote": "Inspiring quote for the day"
  }
}

Focus on practical, actionable tasks that will help the teacher have a successful day.
''';
  }

  EnhancedLessonPlan _parseLessonPlanResponse(
    String response, {
    required String teacherId,
    required String subject,
    required String topic,
    required String gradeLevel,
    required int duration,
    String? chapter,
    List<String>? keywords,
  }) {
    try {
      final jsonData = jsonDecode(response);

      return EnhancedLessonPlan(
        id: '', // Will be set when saved to Firebase
        teacherId: teacherId,
        subject: subject,
        chapter: chapter ?? '',
        topic: topic,
        gradeLevel: gradeLevel,
        estimatedDuration: duration,
        objectives: (jsonData['objectives'] as List? ?? [])
            .map((obj) => LearningObjective(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  description: obj['description'] ?? '',
                  bloomsLevel: obj['bloomsLevel'] ?? 'Understand',
                  isCompleted: false,
                ))
            .toList(),
        activities: (jsonData['activities'] as List? ?? [])
            .map((act) => LessonActivity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: act['title'] ?? '',
                  description: act['description'] ?? '',
                  duration: act['duration'] ?? 15,
                  activityType: act['type'] ?? 'Practice',
                  materials: List<String>.from(act['materials'] ?? []),
                  instructions: act['instructions'] ?? '',
                  aiGenerated: {
                    'generated': true,
                    'timestamp': DateTime.now().toIso8601String()
                  },
                ))
            .toList(),
        resources: (jsonData['resources'] as List? ?? [])
            .map((res) => TeachingResource(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: res['name'] ?? '',
                  type: res['type'] ?? 'Document',
                  url: '',
                  description: res['description'] ?? '',
                  isRequired: res['isRequired'] ?? false,
                ))
            .toList(),
        assessment: AssessmentPlan(
          formativeType: jsonData['assessment']?['formativeType'] ?? 'Quiz',
          summativeType: jsonData['assessment']?['summativeType'] ?? 'Test',
          rubrics: [],
          aiQuestions: jsonData['assessment'] ?? {},
        ),
        differentiation: DifferentiationStrategy(
          learningStyles:
              Map<String, String>.from(jsonData['differentiation'] ?? {}),
          abilityLevels: {
            'advanced': jsonData['differentiation']?['advancedStudents'] ?? '',
            'struggling':
                jsonData['differentiation']?['strugglingStudents'] ?? '',
          },
          accommodations: [],
        ),
        keywords: keywords ?? [],
        aiSuggestions: {'generated': true, 'model': 'gemini-pro'},
        status: LessonStatus.draft,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now().add(const Duration(days: 1)),
      );
    } catch (e) {
      throw Exception('Failed to parse lesson plan response: $e');
    }
  }

  MorningPrepData _parseMorningPrepResponse(
      String response, String teacherId, String date) {
    try {
      final jsonData = jsonDecode(response);

      return MorningPrepData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teacherId: teacherId,
        date: DateTime.now(),
        todaysSchedule: {
          'lessons': jsonData['todaysLessons'] ?? [],
          'notes': jsonData['notes'] ?? '',
        },
        quickReminders: List<String>.from(jsonData['quickReminders'] ?? []),
        priorityTasks: List<String>.from(jsonData['priorityTasks'] ?? []),
        wellnessCheck: Map<String, String>.from(
          jsonData['wellnessCheck'] ?? {},
        ),
        aiTips: (jsonData['aiTips'] as List? ?? [])
            .map((tip) => PrepTip.fromMap(tip))
            .toList(),
        isCompleted: jsonData['isCompleted'] ?? false,
        duration: jsonData['duration'] ?? 0,

        // aiTips: List<String>.from(jsonData['aiTips'] ?? []),
        tasks: (jsonData['tasks'] as List? ?? [])
            .map((task) => MorningPrepTask(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: task['title'] ?? '',
                  description: task['description'] ?? '',
                  estimatedMinutes: task['estimatedMinutes'] ?? 5,
                  isCompleted: false,
                  category: task['category'] ?? 'preparation',
                ))
            .toList(),
        weather: WeatherInfo(
          condition: jsonData['weather']?['condition'] ?? 'Sunny',
          temperature: jsonData['weather']?['temperature'] ?? 25,
          suggestion: jsonData['weather']?['suggestion'] ?? '',
        ),

        moodCheckIn: MoodCheckIn(
          mood: jsonData['moodCheckIn']?['mood'] ?? 'focused',
          energyLevel: jsonData['moodCheckIn']?['energyLevel'] ?? 8,
          concerns:
              List<String>.from(jsonData['moodCheckIn']?['concerns'] ?? []),
          motivationalQuote: jsonData['moodCheckIn']?['motivationalQuote'] ??
              'Have a great day teaching!',
        ),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to parse morning prep response: $e');
    }
  }

  // Demo implementations for development/testing
  EnhancedLessonPlan _generateDemoLessonPlan({
    required String teacherId,
    required String subject,
    required String topic,
    required String gradeLevel,
    required int duration,
    String? chapter,
    List<String>? keywords,
  }) {
    final random = Random();

    return EnhancedLessonPlan(
      id: '',
      teacherId: teacherId,
      subject: subject,
      chapter: chapter ?? 'Chapter ${random.nextInt(10) + 1}',
      topic: topic,
      gradeLevel: gradeLevel,
      estimatedDuration: duration,
      objectives: [
        LearningObjective(
          id: '1',
          description:
              'Students will understand the fundamental concepts of $topic',
          bloomsLevel: 'Understand',
          isCompleted: false,
        ),
        LearningObjective(
          id: '2',
          description:
              'Students will be able to apply $topic principles in practical scenarios',
          bloomsLevel: 'Apply',
          isCompleted: false,
        ),
        LearningObjective(
          id: '3',
          description:
              'Students will analyze and evaluate different aspects of $topic',
          bloomsLevel: 'Analyze',
          isCompleted: false,
        ),
      ],
      activities: [
        LessonActivity(
          id: '1',
          title: 'Introduction to $topic',
          description: 'Interactive introduction covering the basics of $topic',
          duration: (duration * 0.2).round(),
          activityType: 'Introduction',
          materials: ['Whiteboard', 'Projector', 'Handouts'],
          instructions:
              'Begin with a warm-up question about students\' prior knowledge of $topic',
          aiGenerated: {
            'generated': true,
            'timestamp': DateTime.now().toIso8601String()
          },
        ),
        LessonActivity(
          id: '2',
          title: 'Exploring $topic Concepts',
          description:
              'Hands-on exploration of key concepts through interactive activities',
          duration: (duration * 0.4).round(),
          activityType: 'Explanation',
          materials: ['Worksheets', 'Group activity materials', 'Timer'],
          instructions:
              'Divide students into groups and provide guided practice activities',
          aiGenerated: {
            'generated': true,
            'timestamp': DateTime.now().toIso8601String()
          },
        ),
        LessonActivity(
          id: '3',
          title: 'Practice and Application',
          description:
              'Students practice applying $topic concepts independently',
          duration: (duration * 0.3).round(),
          activityType: 'Practice',
          materials: ['Practice worksheets', 'Calculator (if needed)'],
          instructions:
              'Provide individual practice time with teacher support as needed',
          aiGenerated: {
            'generated': true,
            'timestamp': DateTime.now().toIso8601String()
          },
        ),
        LessonActivity(
          id: '4',
          title: 'Assessment and Wrap-up',
          description: 'Quick assessment and lesson summary',
          duration: (duration * 0.1).round(),
          activityType: 'Assessment',
          materials: ['Exit tickets', 'Assessment rubric'],
          instructions:
              'Conduct quick formative assessment and summarize key points',
          aiGenerated: {
            'generated': true,
            'timestamp': DateTime.now().toIso8601String()
          },
        ),
      ],
      resources: [
        TeachingResource(
          id: '1',
          name: '$subject Textbook - $topic Section',
          type: 'Document',
          url: '',
          description: 'Primary textbook resource covering $topic fundamentals',
          isRequired: true,
        ),
        TeachingResource(
          id: '2',
          name: 'Interactive $topic Simulation',
          type: 'Website',
          url: '',
          description: 'Online simulation tool for hands-on learning',
          isRequired: false,
        ),
        TeachingResource(
          id: '3',
          name: '$topic Video Explanation',
          type: 'Video',
          url: '',
          description:
              'Educational video providing visual explanation of concepts',
          isRequired: false,
        ),
      ],
      assessment: AssessmentPlan(
        formativeType: 'Quiz',
        summativeType: 'Test',
        rubrics: [
          'Understanding: 4 levels',
          'Application: 4 levels',
          'Communication: 4 levels'
        ],
        aiQuestions: {
          'questions': [
            'What are the key components of $topic?',
            'How would you apply $topic in a real-world scenario?',
            'Compare and contrast different approaches to $topic',
          ],
          'rubric': 'Standard 4-point rubric for $gradeLevel level',
        },
      ),
      differentiation: DifferentiationStrategy(
        learningStyles: {
          'visual':
              'Use diagrams, charts, and visual aids to explain $topic concepts',
          'auditory':
              'Include discussions, verbal explanations, and audio resources',
          'kinesthetic':
              'Incorporate hands-on activities and movement-based learning',
        },
        abilityLevels: {
          'advanced':
              'Provide extension activities and additional challenging problems',
          'struggling':
              'Offer additional support, simplified examples, and peer tutoring',
          'onLevel': 'Standard activities with appropriate scaffolding',
        },
        accommodations: [
          'Extended time for students with learning differences',
          'Alternative assessment formats for diverse learners',
          'Flexible grouping based on student needs',
        ],
      ),
      keywords: keywords ?? [topic.toLowerCase(), subject.toLowerCase()],
      aiSuggestions: {
        'generated': true,
        'model': 'demo-mode',
        'suggestions': [
          'Consider adding a real-world connection to increase engagement',
          'Include formative assessment checkpoints throughout the lesson',
          'Prepare extension activities for early finishers',
        ],
      },
      status: LessonStatus.draft,
      createdAt: DateTime.now(),
      scheduledFor: DateTime.now().add(const Duration(days: 1)),
    );
  }

  MorningPrepData _generateDemoMorningPrep(
    String response,
    String teacherId,
    String date,
    List<EnhancedLessonPlan> todayLessons,
  ) {
    final random = Random();
    final moods = ['focused', 'excited', 'calm', 'energetic', 'ready'];
    final conditions = ['Sunny', 'Cloudy', 'Partly Cloudy', 'Clear'];
    // final jsonData = jsonDecode(response);

    Map<String, dynamic> jsonData;

    try {
      // Try to parse the response if it's valid JSON
      jsonData = jsonDecode(response);
    } catch (e) {
      // If parsing fails, use demo data structure
      jsonData = {
        'todaysSchedule': {
          'lessons': todayLessons
              .map((lesson) => {
                    'subject': lesson.subject,
                    'topic': lesson.topic,
                    'duration': lesson.estimatedDuration,
                  })
              .toList(),
          'notes': 'Demo schedule for today',
        },
        'quickReminders': [
          'Check classroom temperature',
          'Review attendance sheets',
          'Prepare backup activities',
        ],
        'priorityTasks': [
          'Review lesson objectives',
          'Set up technology',
          'Prepare materials',
        ],
        'wellnessCheck': {
          'mood': 'focused',
          'energy': 'high',
          'readiness': 'prepared',
        },
        'aiTips': [
          {
            'category': 'engagement',
            'title': 'Student Engagement Tip',
            'description': 'Use interactive elements to maintain attention',
            'actionable': 'Start with a question or brief activity',
            'priority': 1,
            'isPersonalized': true,
          },
          {
            'category': 'preparation',
            'title': 'Material Preparation',
            'description': 'Organize materials in advance',
            'actionable': 'Set up stations before students arrive',
            'priority': 2,
            'isPersonalized': false,
          },
        ],
        'isCompleted': false,
        'duration': 0,
      };
    }

    final tasks = <MorningPrepTask>[
      MorningPrepTask(
        id: '1',
        title: 'Review Today\'s Lesson Plans',
        description:
            'Quick review of objectives and key activities for today\'s classes',
        estimatedMinutes: 5,
        isCompleted: false,
        category: 'review',
      ),
      MorningPrepTask(
        id: '2',
        title: 'Prepare Teaching Materials',
        description:
            'Gather handouts, worksheets, and any physical materials needed',
        estimatedMinutes: 8,
        isCompleted: false,
        category: 'materials',
      ),
      MorningPrepTask(
        id: '3',
        title: 'Set Up Classroom Technology',
        description:
            'Test projector, computer, and any digital tools for today\'s lessons',
        estimatedMinutes: 3,
        isCompleted: false,
        category: 'preparation',
      ),
      MorningPrepTask(
        id: '4',
        title: 'Mindfulness Moment',
        description:
            'Take 2 minutes for deep breathing and positive visualization',
        estimatedMinutes: 2,
        isCompleted: false,
        category: 'wellness',
      ),
    ];

    // Add lesson-specific tasks
    for (int i = 0; i < todayLessons.length && i < 2; i++) {
      final lesson = todayLessons[i];
      tasks.add(MorningPrepTask(
        id: 'lesson_${i + 1}',
        title: 'Prepare for ${lesson.subject}: ${lesson.topic}',
        description:
            'Review specific materials and setup for Grade ${lesson.gradeLevel} ${lesson.subject}',
        estimatedMinutes: 4,
        isCompleted: false,
        category: 'preparation',
      ));
    }

    return MorningPrepData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teacherId: teacherId,
      date: DateTime.now(),
      tasks: tasks,
      weather: WeatherInfo(
        condition: conditions[random.nextInt(conditions.length)],
        temperature: 20 + random.nextInt(15),
        suggestion:
            'Great weather for learning! Consider incorporating outdoor elements if possible.',
      ),
      todaysSchedule:
          Map<String, dynamic>.from(jsonData['todaysSchedule'] ?? {}),
      quickReminders: List<String>.from(jsonData['quickReminders'] ?? []),
      priorityTasks: List<String>.from(jsonData['priorityTasks'] ?? []),
      wellnessCheck: Map<String, String>.from(jsonData['priorityTasks'] ?? []),
      aiTips: (jsonData['aiTips'] as List? ?? [])
          .map((tip) => PrepTip(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                category: tip['category'] ?? '',
                title: tip['title'] ?? '',
                description: tip['description'] ?? '',
                actionable: tip['actionable'] ?? '',
                priority: tip['priority'] ?? 1,
                isPersonalized: tip['isPersonalized'] ?? false,
              ))
          .toList(),
      isCompleted: {}['isCompleted'] ?? false,
      duration: {}['duration'] ?? 0,
      moodCheckIn: MoodCheckIn(
        mood: moods[random.nextInt(moods.length)],
        energyLevel: 7 + random.nextInt(3),
        concerns: [
          'Time management',
          'Student engagement',
          'Lesson pacing',
        ].take(random.nextInt(2) + 1).toList(),
        motivationalQuote: _getRandomMotivationalQuote(),
      ),
      createdAt: DateTime.now(),
    );
  }

  String _getRandomMotivationalQuote() {
    final quotes = [
      'Teaching is the profession that teaches all other professions.',
      'The art of teaching is the art of assisting discovery.',
      'Education is not preparation for life; education is life itself.',
      'A teacher affects eternity; they can never tell where their influence stops.',
      'The best teachers are those who show you where to look but don\'t tell you what to see.',
      'Teaching kids to count is fine, but teaching them what counts is best.',
      'In teaching, you cannot see the fruit of a day\'s work. It is invisible and remains so, maybe for twenty years.',
      'Every student can learn, just not on the same day, or the same way.',
    ];

    return quotes[Random().nextInt(quotes.length)];
  }

  // Additional AI service methods for future features
  Future<List<String>> generateQuizQuestions({
    required String subject,
    required String topic,
    required String gradeLevel,
    required int questionCount,
  }) async {
    if (_isDemoMode) {
      return List.generate(
          questionCount,
          (index) =>
              'Demo question ${index + 1} about $topic for Grade $gradeLevel $subject');
    }

    final prompt = '''
Generate $questionCount quiz questions for:
- Subject: $subject
- Topic: $topic  
- Grade Level: $gradeLevel

Return as JSON array of strings:
["Question 1", "Question 2", ...]

Make questions age-appropriate and aligned with learning objectives.
''';

    try {
      final response = await _callGeminiAPI(prompt);
      final questions = List<String>.from(jsonDecode(response));
      return questions;
    } catch (e) {
      throw Exception('Failed to generate quiz questions: $e');
    }
  }

  Future<Map<String, dynamic>> generateActivitySuggestions({
    required String subject,
    required String topic,
    required String gradeLevel,
    required int duration,
    String activityType = 'any',
  }) async {
    if (_isDemoMode) {
      return {
        'activities': [
          {
            'title': 'Interactive $topic Exploration',
            'description': 'Hands-on activity exploring $topic concepts',
            'duration': duration,
            'materials': ['Worksheets', 'Manipulatives', 'Timer'],
            'instructions': 'Step-by-step guide for implementing this activity',
          }
        ]
      };
    }

    final prompt = '''
Suggest engaging activities for:
- Subject: $subject
- Topic: $topic
- Grade Level: $gradeLevel
- Duration: $duration minutes
- Activity Type: $activityType

Return as JSON with activity suggestions including title, description, materials, and instructions.
''';

    try {
      final response = await _callGeminiAPI(prompt);
      return jsonDecode(response);
    } catch (e) {
      throw Exception('Failed to generate activity suggestions: $e');
    }
  }

  Future<String> improveLessonPlan({
    required EnhancedLessonPlan lessonPlan,
    required String improvementFocus,
  }) async {
    if (_isDemoMode) {
      return 'Demo suggestion: Consider adding more interactive elements and differentiation strategies for $improvementFocus';
    }

    final prompt = '''
Analyze and improve this lesson plan with focus on: $improvementFocus

Current lesson plan:
- Subject: ${lessonPlan.subject}
- Topic: ${lessonPlan.topic}
- Grade: ${lessonPlan.gradeLevel}
- Duration: ${lessonPlan.estimatedDuration} minutes

Activities: ${lessonPlan.activities.map((a) => a.title).join(', ')}
Objectives: ${lessonPlan.objectives.map((o) => o.description).join(', ')}

Provide specific, actionable improvement suggestions.
''';

    try {
      final response = await _callGeminiAPI(prompt);
      return response;
    } catch (e) {
      throw Exception('Failed to improve lesson plan: $e');
    }
  }
}
