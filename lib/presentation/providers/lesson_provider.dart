// providers/lesson_provider.dart

import 'package:Sahayak/data/models/lesson/enhanced_lesson_plan.dart';
import 'package:Sahayak/data/models/morningPrep/morningPrep_model.dart';
import 'package:Sahayak/data/services/ai_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LessonProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService(); // Fixed: Proper instantiation

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
        response: _lessonPlans, // Assuming this is the correct usage
      );

      _morningPrep = prepData;

      // Cache the morning prep
      await _cacheMorningPrep(prepData);
    } catch (e) {
      _error = 'Failed to generate morning preparation: $e';
      print('Morning prep error: $e');
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
          .doc(prep.date as String?)
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
            .doc(_morningPrep!.date as String?)
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
      print('Load lesson plans error: $e');
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
      final savedLessonPlan = lessonPlan.copyWith(
        id: docRef.id,
        lastModified: DateTime.now(),
      );

      // Add to local state
      _lessonPlans.insert(0, savedLessonPlan);
      _currentLesson = savedLessonPlan;

      return savedLessonPlan;
    } catch (e) {
      _error = 'Failed to generate lesson plan: $e';
      print('Generate lesson plan error: $e');
      return null;
    } finally {
      _isGeneratingLesson = false;
      notifyListeners();
    }
  }

  Future<void> updateLessonPlan(EnhancedLessonPlan lessonPlan) async {
    try {
      final updatedPlan = lessonPlan.copyWith(
        id: lessonPlan.id,
        lastModified: DateTime.now(),
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

      final savedPlan = duplicatedPlan.copyWith(
        id: docRef.id,
        lastModified: DateTime.now(),
      );

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
    final stats = {
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

extension on MorningPrepData {
  MorningPrepData? copyWith({required List<MorningPrepTask> tasks}) {
    return null;
  }
}
