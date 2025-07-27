import 'dart:convert';

class StressProfile {
  final String id;
  final String teacherId;
  final Map<String, int> stressLevels; // 1-5 scale
  final Map<String, double> timeImpact; // hours spent on stressful activities
  final Map<String, String> copingStrategies;
  final DateTime createdAt;
  final DateTime lastUpdated;

  StressProfile({
    required this.id,
    required this.teacherId,
    required this.stressLevels,
    required this.timeImpact,
    required this.copingStrategies,
    required this.createdAt,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'stressLevels': stressLevels,
      'timeImpact': timeImpact,
      'copingStrategies': copingStrategies,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory StressProfile.fromMap(Map<String, dynamic> map) {
    return StressProfile(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      stressLevels: Map<String, int>.from(map['stressLevels'] ?? {}),
      timeImpact: Map<String, double>.from(map['timeImpact'] ?? {}),
      copingStrategies: Map<String, String>.from(map['copingStrategies'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}

class DailyStressLog {
  final String id;
  final String teacherId;
  final DateTime date;
  final Map<String, int> morningStress;
  final Map<String, int> midDayStress;
  final Map<String, int> eveningStress;
  final List<String> stressTriggers;
  final List<String> stressRelievers;
  final int overallWellness; // 1-10 scale
  final String notes;

  DailyStressLog({
    required this.id,
    required this.teacherId,
    required this.date,
    required this.morningStress,
    required this.midDayStress,
    required this.eveningStress,
    required this.stressTriggers,
    required this.stressRelievers,
    required this.overallWellness,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'date': date.toIso8601String(),
      'morningStress': morningStress,
      'midDayStress': midDayStress,
      'eveningStress': eveningStress,
      'stressTriggers': stressTriggers,
      'stressRelievers': stressRelievers,
      'overallWellness': overallWellness,
      'notes': notes,
    };
  }

  factory DailyStressLog.fromMap(Map<String, dynamic> map) {
    return DailyStressLog(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      date: DateTime.parse(map['date']),
      morningStress: Map<String, int>.from(map['morningStress'] ?? {}),
      midDayStress: Map<String, int>.from(map['midDayStress'] ?? {}),
      eveningStress: Map<String, int>.from(map['eveningStress'] ?? {}),
      stressTriggers: List<String>.from(map['stressTriggers'] ?? []),
      stressRelievers: List<String>.from(map['stressRelievers'] ?? []),
      overallWellness: map['overallWellness'] ?? 5,
      notes: map['notes'] ?? '',
    );
  }
}

class StressReductionMetrics {
  final String id;
  final String teacherId;
  final DateTime weekStart;
  final Map<String, double> stressReductionPercentage;
  final Map<String, double> timeSavings; // hours saved per category
  final Map<String, int> appFeatureUsage;
  final double overallImprovement;
  final List<String> achievements;

  StressReductionMetrics({
    required this.id,
    required this.teacherId,
    required this.weekStart,
    required this.stressReductionPercentage,
    required this.timeSavings,
    required this.appFeatureUsage,
    required this.overallImprovement,
    required this.achievements,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'weekStart': weekStart.toIso8601String(),
      'stressReductionPercentage': stressReductionPercentage,
      'timeSavings': timeSavings,
      'appFeatureUsage': appFeatureUsage,
      'overallImprovement': overallImprovement,
      'achievements': achievements,
    };
  }
}

class WorksheetTemplate {
  final String id;
  final String title;
  final String subject;
  final String gradeLevel;
  final String difficulty;
  final List<WorksheetSection> sections;
  final Map<String, dynamic> aiGeneratedContent;
  final DateTime createdAt;

  WorksheetTemplate({
    required this.id,
    required this.title,
    required this.subject,
    required this.gradeLevel,
    required this.difficulty,
    required this.sections,
    required this.aiGeneratedContent,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'difficulty': difficulty,
      'sections': sections.map((s) => s.toMap()).toList(),
      'aiGeneratedContent': aiGeneratedContent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorksheetTemplate.fromMap(Map<String, dynamic> map) {
    return WorksheetTemplate(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      difficulty: map['difficulty'] ?? '',
      sections: (map['sections'] as List? ?? [])
          .map((s) => WorksheetSection.fromMap(s))
          .toList(),
      aiGeneratedContent: map['aiGeneratedContent'] ?? {},
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class WorksheetSection {
  final String id;
  final String title;
  final String type; // multiple_choice, fill_blanks, essay, matching, etc.
  final List<WorksheetQuestion> questions;
  final String instructions;
  final int points;

  WorksheetSection({
    required this.id,
    required this.title,
    required this.type,
    required this.questions,
    required this.instructions,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'questions': questions.map((q) => q.toMap()).toList(),
      'instructions': instructions,
      'points': points,
    };
  }

  factory WorksheetSection.fromMap(Map<String, dynamic> map) {
    return WorksheetSection(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      questions: (map['questions'] as List? ?? [])
          .map((q) => WorksheetQuestion.fromMap(q))
          .toList(),
      instructions: map['instructions'] ?? '',
      points: map['points'] ?? 0,
    );
  }
}

class WorksheetQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final int points;

  WorksheetQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'points': points,
    };
  }

  factory WorksheetQuestion.fromMap(Map<String, dynamic> map) {
    return WorksheetQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
      explanation: map['explanation'] ?? '',
      points: map['points'] ?? 1,
    );
  }
}
