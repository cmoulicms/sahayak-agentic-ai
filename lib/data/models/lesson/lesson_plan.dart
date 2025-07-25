// models/lesson_plan.dart
class LessonPlan {
  final String id;
  final String teacherId;
  final String subject;
  final String chapter;
  final String gradeLevel;
  final int duration;
  final List<String> objectives;
  final List<Map<String, dynamic>> activities;
  final List<String> resources;
  final Map<String, dynamic> assessment;
  final DateTime createdAt;
  final DateTime scheduledFor;

  LessonPlan({
    required this.id,
    required this.teacherId,
    required this.subject,
    required this.chapter,
    required this.gradeLevel,
    required this.duration,
    required this.objectives,
    required this.activities,
    required this.resources,
    required this.assessment,
    required this.createdAt,
    required this.scheduledFor,
  });

  factory LessonPlan.fromMap(Map<String, dynamic> map) {
    return LessonPlan(
      id: map['id'],
      teacherId: map['teacherId'],
      subject: map['subject'],
      chapter: map['chapter'],
      gradeLevel: map['gradeLevel'],
      duration: map['duration'],
      objectives: List<String>.from(map['objectives']),
      activities: List<Map<String, dynamic>>.from(map['activities']),
      resources: List<String>.from(map['resources']),
      assessment: Map<String, dynamic>.from(map['assessment']),
      createdAt: DateTime.parse(map['createdAt']),
      scheduledFor: DateTime.parse(map['scheduledFor']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'subject': subject,
      'chapter': chapter,
      'gradeLevel': gradeLevel,
      'duration': duration,
      'objectives': objectives,
      'activities': activities,
      'resources': resources,
      'assessment': assessment,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor.toIso8601String(),
    };
  }
}
