// core/providers/morning_prep_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/data/models/morningPrep/morningPrep_model.dart';

class MorningPrepProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MorningPrepSession? _currentSession;
  bool _isLoading = false;
  String? _error;
  List<PrepTip> _todaysTips = [];

  // Getters
  MorningPrepSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PrepTip> get todaysTips => _todaysTips;
  bool get hasCompletedToday => _currentSession?.isCompleted ?? false;

  // Initialize today's session
  Future<void> initializeTodaySession() async {
    if (_auth.currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';

      // Check if session exists for today
      final sessionDoc = await _firestore
          .collection('teachers')
          .doc(_auth.currentUser!.uid)
          .collection('morningPrep')
          .where('date', isEqualTo: todayString)
          .limit(1)
          .get();

      if (sessionDoc.docs.isNotEmpty) {
        _currentSession =
            MorningPrepSession.fromMap(sessionDoc.docs.first.data());
      } else {
        // Create new session
        _currentSession = await _createNewSession(today);
      }

      await _loadTodaysTips();
    } catch (e) {
      _error = e.toString();
      print('Error initializing morning prep session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MorningPrepSession> _createNewSession(DateTime date) async {
    final sessionId = _firestore.collection('dummy').doc().id;

    // Generate AI-powered prep data
    final prepData = await _generateMorningPrepData();

    final session = MorningPrepSession(
      id: sessionId,
      teacherId: _auth.currentUser!.uid,
      date: date,
      todaysSchedule: prepData['schedule'],
      quickReminders: List<String>.from(prepData['reminders']),
      priorityTasks: List<String>.from(prepData['tasks']),
      wellnessCheck: Map<String, String>.from(prepData['wellness']),
      aiTips: List<PrepTip>.from(
          prepData['tips'].map((tip) => PrepTip.fromMap(tip))),
      isCompleted: false,
      duration: 0,
      createdAt: DateTime.now(),
    );

    // Save to Firebase
    await _firestore
        .collection('teachers')
        .doc(_auth.currentUser!.uid)
        .collection('morningPrep')
        .doc(sessionId)
        .set(session.toMap());

    return session;
  }

  Future<Map<String, dynamic>> _generateMorningPrepData() async {
    // This would integrate with your AI service (Vertex AI/Gemini)
    // For now, returning mock data
    return {
      'schedule': {
        'classes': [
          {
            'time': '09:00',
            'subject': 'Mathematics',
            'grade': 'Class 5',
            'topic': 'Fractions',
            'room': 'Room 12'
          },
          {
            'time': '10:30',
            'subject': 'Science',
            'grade': 'Class 6',
            'topic': 'Photosynthesis',
            'room': 'Lab 1'
          },
          {
            'time': '12:00',
            'subject': 'English',
            'grade': 'Class 4',
            'topic': 'Story Writing',
            'room': 'Room 8'
          }
        ],
        'meetings': [],
        'events': []
      },
      'reminders': [
        'Parent-teacher meeting at 3 PM',
        'Submit monthly reports by Friday',
        'Science lab equipment needs checking',
        'Library books due for return'
      ],
      'tasks': [
        'Review yesterday\'s homework submissions',
        'Prepare materials for fraction teaching',
        'Check science lab safety equipment',
        'Update student progress records'
      ],
      'wellness': {
        'mood': 'energetic',
        'stress_level': 'moderate',
        'sleep_quality': 'good',
        'energy_level': 'high'
      },
      'tips': [
        {
          'id': '1',
          'category': 'Teaching Strategy',
          'title': 'Interactive Fraction Learning',
          'description':
              'Use visual aids and manipulatives to make fractions concrete',
          'actionable':
              'Prepare pizza cut-outs and fraction bars for today\'s math class',
          'priority': 5,
          'isPersonalized': true
        },
        {
          'id': '2',
          'category': 'Classroom Management',
          'title': 'Morning Energy Boost',
          'description':
              'Start with a 2-minute movement activity to engage students',
          'actionable':
              'Try the "Math Dance" - students move to represent fractions',
          'priority': 4,
          'isPersonalized': true
        },
        {
          'id': '3',
          'category': 'Wellness',
          'title': 'Stress Management',
          'description': 'Take 3 deep breaths between classes',
          'actionable':
              'Set a gentle reminder on your phone for transition times',
          'priority': 3,
          'isPersonalized': false
        }
      ]
    };
  }

  Future<void> _loadTodaysTips() async {
    if (_currentSession != null) {
      _todaysTips = _currentSession!.aiTips;
    }
  }

  Future<void> completeSession(int actualDuration) async {
    if (_currentSession == null || _auth.currentUser == null) return;

    try {
      final updatedSession = MorningPrepSession(
        id: _currentSession!.id,
        teacherId: _currentSession!.teacherId,
        date: _currentSession!.date,
        todaysSchedule: _currentSession!.todaysSchedule,
        quickReminders: _currentSession!.quickReminders,
        priorityTasks: _currentSession!.priorityTasks,
        wellnessCheck: _currentSession!.wellnessCheck,
        aiTips: _currentSession!.aiTips,
        isCompleted: true,
        duration: actualDuration,
        createdAt: _currentSession!.createdAt,
      );

      await _firestore
          .collection('teachers')
          .doc(_auth.currentUser!.uid)
          .collection('morningPrep')
          .doc(_currentSession!.id)
          .update({
        'isCompleted': true,
        'duration': actualDuration,
      });

      _currentSession = updatedSession;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error completing session: $e');
      notifyListeners();
    }
  }

  Future<void> updateWellnessCheck(Map<String, String> wellness) async {
    if (_currentSession == null || _auth.currentUser == null) return;

    try {
      await _firestore
          .collection('teachers')
          .doc(_auth.currentUser!.uid)
          .collection('morningPrep')
          .doc(_currentSession!.id)
          .update({
        'wellnessCheck': wellness,
      });

      _currentSession = MorningPrepSession(
        id: _currentSession!.id,
        teacherId: _currentSession!.teacherId,
        date: _currentSession!.date,
        todaysSchedule: _currentSession!.todaysSchedule,
        quickReminders: _currentSession!.quickReminders,
        priorityTasks: _currentSession!.priorityTasks,
        wellnessCheck: wellness,
        aiTips: _currentSession!.aiTips,
        isCompleted: _currentSession!.isCompleted,
        duration: _currentSession!.duration,
        createdAt: _currentSession!.createdAt,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error updating wellness check: $e');
      notifyListeners();
    }
  }

  Future<void> markTaskComplete(String taskId) async {
    // Implementation for marking specific tasks as complete
    // This would update the task status in Firebase
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
