// models/morning_prep.dart
class MorningPrepSession {
  final String id;
  final String teacherId;
  final DateTime date;
  final Map<String, dynamic> todaysSchedule;
  final List<String> quickReminders;
  final List<String> priorityTasks;
  final Map<String, String> wellnessCheck;
  final List<PrepTip> aiTips;
  final bool isCompleted;
  final int duration; // in minutes
  final DateTime createdAt;

  MorningPrepSession({
    required this.id,
    required this.teacherId,
    required this.date,
    required this.todaysSchedule,
    required this.quickReminders,
    required this.priorityTasks,
    required this.wellnessCheck,
    required this.aiTips,
    required this.isCompleted,
    required this.duration,
    required this.createdAt,
  });

  factory MorningPrepSession.fromMap(Map<String, dynamic> map) {
    return MorningPrepSession(
      id: map['id'],
      teacherId: map['teacherId'],
      date: DateTime.parse(map['date']),
      todaysSchedule: Map<String, dynamic>.from(map['todaysSchedule']),
      quickReminders: List<String>.from(map['quickReminders']),
      priorityTasks: List<String>.from(map['priorityTasks']),
      wellnessCheck: Map<String, String>.from(map['wellnessCheck']),
      aiTips: List<PrepTip>.from(
          map['aiTips']?.map((x) => PrepTip.fromMap(x)) ?? []),
      isCompleted: map['isCompleted'],
      duration: map['duration'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'date': date.toIso8601String(),
      'todaysSchedule': todaysSchedule,
      'quickReminders': quickReminders,
      'priorityTasks': priorityTasks,
      'wellnessCheck': wellnessCheck,
      'aiTips': aiTips.map((x) => x.toMap()).toList(),
      'isCompleted': isCompleted,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PrepTip {
  final String id;
  final String category;
  final String title;
  final String description;
  final String actionable;
  final int priority; // 1-5
  final bool isPersonalized;

  PrepTip({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.actionable,
    required this.priority,
    required this.isPersonalized,
  });

  factory PrepTip.fromMap(Map<String, dynamic> map) {
    return PrepTip(
      id: map['id'],
      category: map['category'],
      title: map['title'],
      description: map['description'],
      actionable: map['actionable'],
      priority: map['priority'],
      isPersonalized: map['isPersonalized'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'actionable': actionable,
      'priority': priority,
      'isPersonalized': isPersonalized,
    };
  }
}
