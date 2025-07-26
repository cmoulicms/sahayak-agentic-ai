// models/morning_prep.dart
class MorningPrepData {
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
  final List<MorningPrepTask> tasks;
  final WeatherInfo weather;
  final MoodCheckIn moodCheckIn;

  MorningPrepData({
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
    required this.tasks,
    required this.weather,
    required this.moodCheckIn,
  });

  factory MorningPrepData.fromMap(Map<String, dynamic> map) {
    return MorningPrepData(
      id: map['id'],
      teacherId: map['teacherId'],
      date: DateTime.parse(map['date']),
      todaysSchedule: Map<String, dynamic>.from(map['todaysSchedule']),
      quickReminders: List<String>.from(map['quickReminders']),
      priorityTasks: List<String>.from(map['priorityTasks']),
      wellnessCheck: Map<String, String>.from(map['wellnessCheck']),
      aiTips: (map['aiTips'] as List? ?? [])
          .map((x) => PrepTip.fromMap(Map<String, dynamic>.from(x)))
          .toList(),
      isCompleted: map['isCompleted'],
      duration: map['duration'],
      createdAt: DateTime.parse(
        map['createdAt'],
      ),
      tasks: List<MorningPrepTask>.from(
          map['tasks']?.map((x) => MorningPrepTask.fromMap(x)) ?? []),
      weather: WeatherInfo.fromMap(map['weather'] ?? {}),
      moodCheckIn: MoodCheckIn.fromMap(map['moodCheckIn'] ?? {}),
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
      'tasks': tasks.map((x) => x.toMap()).toList(),
      'weather': weather.toMap(),
      'moodCheckIn': moodCheckIn.toMap(),
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

class MorningPrepTask {
  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final bool isCompleted;
  final String category;

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
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      estimatedMinutes: map['estimatedMinutes'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      category: map['category'] ?? '',
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
      condition: map['condition'] ?? '',
      temperature: map['temperature'] ?? 0,
      suggestion: map['suggestion'] ?? '',
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
      mood: map['mood'] ?? '',
      energyLevel: map['energyLevel'] ?? 0,
      concerns: List<String>.from(map['concerns'] ?? []),
      motivationalQuote: map['motivationalQuote'] ?? '',
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
