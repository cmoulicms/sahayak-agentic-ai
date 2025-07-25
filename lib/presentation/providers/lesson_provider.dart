// providers/lesson_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/data/models/lesson/enhanced_lesson_plan.dart';

class LessonProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final AIService _aiService = AIService();

  // State variables
  List<EnhancedLessonPlan> _lessonPlans = [];
  List<EnhancedLessonPlan> _todayLessons = [];
  EnhancedLessonPlan? _currentLesson;
  MorningPrepData? _morningPrep;

  bool _isLoading = false;
  bool _isMorningPrepLoading = false;
  bool _isGeneratingLesson = false;
  String? _error;

  // Getters
  List<EnhancedLessonPlan> get lessonPlans => _lessonPlans;
  List<EnhancedLessonPlan> get todayLessons => _todayLessons;
  EnhancedLessonPlan? get currentLesson => _currentLesson;
  MorningPrepData? get morningPrep => _morningPrep;

  bool get isLoading => _isLoading;
  bool get isMorningPrepLoading => _isMorningPrepLoading;
  bool get isGeneratingLesson => _isGeneratingLesson;
  String? get error => _error;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Initialize provider
  Future<void> initialize() async {
    await loadLessonPlans();
    await loadTodayLessons();
    await generateMorningPrep();
  }

  // MORNING PREP FUNCTIONALITY
  Future<void> generateMorningPrep() async {
    _isMorningPrepLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get today's lessons
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Generate AI-powered morning preparation
      final prepData = await _aiService.generateMorningPrep(
        teacherId: currentUserId,
        date: todayString,
        todayLessons: _todayLessons,
      );

      _morningPrep = prepData;

      // Cache the morning prep
      await _cacheMorningPrep(prepData);
    } catch (e) {
      _error = 'Failed to generate morning preparation: $e';
    } finally {
      _isMorningPrepLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cacheMorningPrep(MorningPrepData prep) async {
    try {
      await _firestore
          .collection('teachers')
          .doc(currentUserId)
          .collection('morningPrep')
          .doc(prep.date)
          .set(prep.toMap());
    } catch (e) {
      print('Failed to cache morning prep: $e');
    }
  }

  Future<void> markMorningPrepComplete(String taskId) async {
    if (_morningPrep != null) {
      final updatedTasks = _morningPrep!.tasks.map((task) {
        if (task.id == taskId) {
          return task.copyWith(isCompleted: true);
        }
        return task;
      }).toList();

      _morningPrep = _morningPrep!.copyWith(tasks: updatedTasks);
      notifyListeners();

      // Update in Firebase
      try {
        await _firestore
            .collection('teachers')
            .doc(currentUserId)
            .collection('morningPrep')
            .doc(_morningPrep!.date)
            .update({'tasks': updatedTasks.map((t) => t.toMap()).toList()});
      } catch (e) {
        print('Failed to update morning prep task: $e');
      }
    }
  }

  // LESSON PLANNING FUNCTIONALITY
  Future<void> loadLessonPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('lessonPlans')
          .where('teacherId', isEqualTo: currentUserId)
          .orderBy('scheduledFor', descending: true)
          .limit(50)
          .get();

      _lessonPlans = querySnapshot.docs
          .map((doc) => EnhancedLessonPlan.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      _error = 'Failed to load lesson plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayLessons() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('lessonPlans')
          .where('teacherId', isEqualTo: currentUserId)
          .where('scheduledFor', isGreaterThanOrEqualTo: startOfDay)
          .where('scheduledFor', isLessThan: endOfDay)
          .orderBy('scheduledFor')
          .get();

      _todayLessons = querySnapshot.docs
          .map((doc) => EnhancedLessonPlan.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Failed to load today\'s lessons: $e');
    }
  }

  Future<EnhancedLessonPlan?> generateLessonPlan({
    required String subject,
    required String topic,
    required String gradeLevel,
    required int duration,
    String? chapter,
    List<String>? keywords,
  }) async {
    _isGeneratingLesson = true;
    _error = null;
    notifyListeners();

    try {
      // Generate AI-powered lesson plan
      final lessonPlan = await _aiService.generateLessonPlan(
        teacherId: currentUserId,
        subject: subject,
        topic: topic,
        gradeLevel: gradeLevel,
        duration: duration,
        chapter: chapter,
        keywords: keywords,
      );

      // Save to Firebase
      final docRef =
          await _firestore.collection('lessonPlans').add(lessonPlan.toMap());
      final savedLessonPlan = lessonPlan.copyWith(id: docRef.id);

      // Add to local state
      _lessonPlans.insert(0, savedLessonPlan);
      _currentLesson = savedLessonPlan;

      return savedLessonPlan;
    } catch (e) {
      _error = 'Failed to generate lesson plan: $e';
      return null;
    } finally {
      _isGeneratingLesson = false;
      notifyListeners();
    }
  }

  // Future<EnhancedLessonPlan?> generateLessonPlan({
  //   required String subject,
  //   required String topic,
  //   required String gradeLevel,
  //   required int duration,
  //   String? chapter,
  //   List<String>? keywords,
  // }) async {
  //   _isGeneratingLesson = true;
  //   _error = null;
  //   notifyListeners();

  //   try {
  //     // Generate AI-powered lesson plan
  //     // final lessonPlan = await _aiService.generateLessonPlan(
  //     //   teacherId: currentUserId,
  //     //   subject: subject,
  //     //   topic: topic,
  //     //   gradeLevel: gradeLevel,
  //     //   duration: duration,
  //     //   chapter: chapter,
  //     //   keywords: keywords,
  //     // );

  //     // Save to Firebase
  //     // final docRef =
  //     //     await _firestore.collection('lessonPlans').add(lessonPlan.toMap());
  //     // final savedLessonPlan = lessonPlan.copyWith(id: docRef.id);

  //     // Add to local state
  //     _lessonPlans.insert(0, savedLessonPlan);
  //     _currentLesson = savedLessonPlan;

  //     return savedLessonPlan;
  //   } catch (e) {
  //     _error = 'Failed to generate lesson plan: $e';
  //     return null;
  //   } finally {
  //     _isGeneratingLesson = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> updateLessonPlan(EnhancedLessonPlan lessonPlan) async {
    try {
      final updatedPlan = lessonPlan.copyWith(
        id: lessonPlan.id,
        lastModified: DateTime.now().timeZoneName,
      );

      await _firestore
          .collection('lessonPlans')
          .doc(lessonPlan.id)
          .update(updatedPlan.toMap());

      // Update local state
      final index = _lessonPlans.indexWhere((plan) => plan.id == lessonPlan.id);
      if (index != -1) {
        _lessonPlans[index] = updatedPlan;
      }

      // Update current lesson if it matches
      if (_currentLesson?.id == lessonPlan.id) {
        _currentLesson = updatedPlan;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update lesson plan: $e';
      notifyListeners();
    }
  }

  Future<void> deleteLessonPlan(String lessonId) async {
    try {
      await _firestore.collection('lessonPlans').doc(lessonId).delete();

      _lessonPlans.removeWhere((plan) => plan.id == lessonId);
      _todayLessons.removeWhere((plan) => plan.id == lessonId);

      if (_currentLesson?.id == lessonId) {
        _currentLesson = null;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete lesson plan: $e';
      notifyListeners();
    }
  }

  void setCurrentLesson(EnhancedLessonPlan lesson) {
    _currentLesson = lesson;
    notifyListeners();
  }

  Future<void> duplicateLessonPlan(EnhancedLessonPlan originalPlan) async {
    try {
      final duplicatedPlan = EnhancedLessonPlan(
        id: '', // Will be set when saved
        teacherId: currentUserId,
        subject: originalPlan.subject,
        chapter: originalPlan.chapter,
        topic: '${originalPlan.topic} (Copy)',
        gradeLevel: originalPlan.gradeLevel,
        estimatedDuration: originalPlan.estimatedDuration,
        objectives: originalPlan.objectives,
        activities: originalPlan.activities,
        resources: originalPlan.resources,
        assessment: originalPlan.assessment,
        differentiation: originalPlan.differentiation,
        keywords: originalPlan.keywords,
        aiSuggestions: originalPlan.aiSuggestions,
        status: LessonStatus.draft,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now().add(const Duration(days: 1)),
      );

      final docRef = await _firestore
          .collection('lessonPlans')
          .add(duplicatedPlan.toMap());
      final savedPlan =
          duplicatedPlan.copyWith(id: docRef.id, lastModified: '');

      _lessonPlans.insert(0, savedPlan);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to duplicate lesson plan: $e';
      notifyListeners();
    }
  }

  // Search and filter functionality
  List<EnhancedLessonPlan> searchLessonPlans(String query) {
    if (query.isEmpty) return _lessonPlans;

    final lowercaseQuery = query.toLowerCase();
    return _lessonPlans.where((plan) {
      return plan.topic.toLowerCase().contains(lowercaseQuery) ||
          plan.subject.toLowerCase().contains(lowercaseQuery) ||
          plan.chapter.toLowerCase().contains(lowercaseQuery) ||
          plan.keywords
              .any((keyword) => keyword.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  List<EnhancedLessonPlan> filterBySubject(String subject) {
    return _lessonPlans.where((plan) => plan.subject == subject).toList();
  }

  List<EnhancedLessonPlan> filterByStatus(LessonStatus status) {
    return _lessonPlans.where((plan) => plan.status == status).toList();
  }

  // Statistics
  Map<String, int> getLessonStatistics() {
    final stats = <String, int>{
      'total': _lessonPlans.length,
      'draft': 0,
      'inProgress': 0,
      'completed': 0,
      'needsRevision': 0,
      'approved': 0,
    };

    for (final plan in _lessonPlans) {
      stats[plan.status.name] = (stats[plan.status.name] ?? 0) + 1;
    }

    return stats;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

}

class _aiService {
  static generateMorningPrep(
      {required String teacherId,
      required String date,
      required List<EnhancedLessonPlan> todayLessons}) {}

  static generateLessonPlan(
      {required String teacherId,
      required String subject,
      required String topic,
      required String gradeLevel,
      required int duration,
      String? chapter,
      List<String>? keywords}) {}
}

// Morning Prep Data Models
class MorningPrepData {
  final String id;
  final String teacherId;
  final String date;
  final List<MorningPrepTask> tasks;
  final WeatherInfo weather;
  final List<String> quickTips;
  final MoodCheckIn moodCheckIn;
  final DateTime createdAt;

  MorningPrepData({
    required this.id,
    required this.teacherId,
    required this.date,
    required this.tasks,
    required this.weather,
    required this.quickTips,
    required this.moodCheckIn,
    required this.createdAt,
  });

  factory MorningPrepData.fromMap(Map<String, dynamic> map) {
    return MorningPrepData(
      id: map['id'],
      teacherId: map['teacherId'],
      date: map['date'],
      tasks: List<MorningPrepTask>.from(
          map['tasks']?.map((x) => MorningPrepTask.fromMap(x)) ?? []),
      weather: WeatherInfo.fromMap(map['weather']),
      quickTips: List<String>.from(map['quickTips']),
      moodCheckIn: MoodCheckIn.fromMap(map['moodCheckIn']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'date': date,
      'tasks': tasks.map((x) => x.toMap()).toList(),
      'weather': weather.toMap(),
      'quickTips': quickTips,
      'moodCheckIn': moodCheckIn.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MorningPrepData copyWith({
    String? id,
    String? teacherId,
    String? date,
    List<MorningPrepTask>? tasks,
    WeatherInfo? weather,
    List<String>? quickTips,
    MoodCheckIn? moodCheckIn,
    DateTime? createdAt,
  }) {
    return MorningPrepData(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      weather: weather ?? this.weather,
      quickTips: quickTips ?? this.quickTips,
      moodCheckIn: moodCheckIn ?? this.moodCheckIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MorningPrepTask {
  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final bool isCompleted;
  final String category; // materials, review, preparation, wellness

  MorningPrepTask({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.isCompleted,
    required this.category,
  });

  factory MorningPrepTask.fromMap(Map<String, dynamic> map) {
    return MorningPrepTask(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      estimatedMinutes: map['estimatedMinutes'],
      isCompleted: map['isCompleted'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'estimatedMinutes': estimatedMinutes,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  MorningPrepTask copyWith({
    String? id,
    String? title,
    String? description,
    int? estimatedMinutes,
    bool? isCompleted,
    String? category,
  }) {
    return MorningPrepTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }
}

class WeatherInfo {
  final String condition;
  final int temperature;
  final String suggestion;

  WeatherInfo({
    required this.condition,
    required this.temperature,
    required this.suggestion,
  });

  factory WeatherInfo.fromMap(Map<String, dynamic> map) {
    return WeatherInfo(
      condition: map['condition'],
      temperature: map['temperature'],
      suggestion: map['suggestion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'condition': condition,
      'temperature': temperature,
      'suggestion': suggestion,
    };
  }
}

class MoodCheckIn {
  final String mood;
  final int energyLevel;
  final List<String> concerns;
  final String motivationalQuote;

  MoodCheckIn({
    required this.mood,
    required this.energyLevel,
    required this.concerns,
    required this.motivationalQuote,
  });

  factory MoodCheckIn.fromMap(Map<String, dynamic> map) {
    return MoodCheckIn(
      mood: map['mood'],
      energyLevel: map['energyLevel'],
      concerns: List<String>.from(map['concerns']),
      motivationalQuote: map['motivationalQuote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'energyLevel': energyLevel,
      'concerns': concerns,
      'motivationalQuote': motivationalQuote,
    };
  }
}
