// models/enhanced_lesson_plan.dart

class EnhancedLessonPlan {
  final String id;
  final String teacherId;
  final String subject;
  final String chapter;
  final String topic;
  final String gradeLevel;
  final int estimatedDuration;
  final List<LearningObjective> objectives;
  final List<LessonActivity> activities;
  final List<TeachingResource> resources;
  final AssessmentPlan assessment;
  final DifferentiationStrategy differentiation;
  final List<String> keywords;
  final Map<String, dynamic> aiSuggestions;
  final LessonStatus status;
  final DateTime createdAt;
  final DateTime scheduledFor;
  final DateTime? lastModified;

  EnhancedLessonPlan({
    required this.id,
    required this.teacherId,
    required this.subject,
    required this.chapter,
    required this.topic,
    required this.gradeLevel,
    required this.estimatedDuration,
    required this.objectives,
    required this.activities,
    required this.resources,
    required this.assessment,
    required this.differentiation,
    required this.keywords,
    required this.aiSuggestions,
    required this.status,
    required this.createdAt,
    required this.scheduledFor,
    this.lastModified,
  });

  factory EnhancedLessonPlan.fromMap(Map<String, dynamic> map) {
    return EnhancedLessonPlan(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      subject: map['subject'] ?? '',
      chapter: map['chapter'] ?? '',
      topic: map['topic'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      estimatedDuration: map['estimatedDuration'] ?? 0,
      objectives: List<LearningObjective>.from(
          map['objectives']?.map((x) => LearningObjective.fromMap(x)) ?? []),
      activities: List<LessonActivity>.from(
          map['activities']?.map((x) => LessonActivity.fromMap(x)) ?? []),
      resources: List<TeachingResource>.from(
          map['resources']?.map((x) => TeachingResource.fromMap(x)) ?? []),
      assessment: AssessmentPlan.fromMap(map['assessment'] ?? {}),
      differentiation:
          DifferentiationStrategy.fromMap(map['differentiation'] ?? {}),
      keywords: List<String>.from(map['keywords'] ?? []),
      aiSuggestions: Map<String, dynamic>.from(map['aiSuggestions'] ?? {}),
      status: LessonStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LessonStatus.draft,
      ),
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : map['createdAt'] ?? DateTime.now(),
      scheduledFor: map['scheduledFor'] is String
          ? DateTime.parse(map['scheduledFor'])
          : map['scheduledFor'] ?? DateTime.now(),
      lastModified: map['lastModified'] != null
          ? (map['lastModified'] is String
              ? DateTime.parse(map['lastModified'])
              : map['lastModified'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'subject': subject,
      'chapter': chapter,
      'topic': topic,
      'gradeLevel': gradeLevel,
      'estimatedDuration': estimatedDuration,
      'objectives': objectives.map((x) => x.toMap()).toList(),
      'activities': activities.map((x) => x.toMap()).toList(),
      'resources': resources.map((x) => x.toMap()).toList(),
      'assessment': assessment.toMap(),
      'differentiation': differentiation.toMap(),
      'keywords': keywords,
      'aiSuggestions': aiSuggestions,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  EnhancedLessonPlan copyWith({
    String? id,
    String? teacherId,
    String? subject,
    String? chapter,
    String? topic,
    String? gradeLevel,
    int? estimatedDuration,
    List<LearningObjective>? objectives,
    List<LessonActivity>? activities,
    List<TeachingResource>? resources,
    AssessmentPlan? assessment,
    DifferentiationStrategy? differentiation,
    List<String>? keywords,
    Map<String, dynamic>? aiSuggestions,
    LessonStatus? status,
    DateTime? createdAt,
    DateTime? scheduledFor,
    DateTime? lastModified,
  }) {
    return EnhancedLessonPlan(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      subject: subject ?? this.subject,
      chapter: chapter ?? this.chapter,
      topic: topic ?? this.topic,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      objectives: objectives ?? this.objectives,
      activities: activities ?? this.activities,
      resources: resources ?? this.resources,
      assessment: assessment ?? this.assessment,
      differentiation: differentiation ?? this.differentiation,
      keywords: keywords ?? this.keywords,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

// Keep all other classes (LearningObjective, LessonActivity, etc.) with proper copyWith methods

class LearningObjective {
  final String id;
  final String description;
  final String bloomsLevel;
  final bool isCompleted;

  LearningObjective({
    required this.id,
    required this.description,
    required this.bloomsLevel,
    required this.isCompleted,
  });

  factory LearningObjective.fromMap(Map<String, dynamic> map) {
    return LearningObjective(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      bloomsLevel: map['bloomsLevel'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'bloomsLevel': bloomsLevel,
      'isCompleted': isCompleted,
    };
  }

  LearningObjective copyWith({
    String? id,
    String? description,
    String? bloomsLevel,
    bool? isCompleted,
  }) {
    return LearningObjective(
      id: id ?? this.id,
      description: description ?? this.description,
      bloomsLevel: bloomsLevel ?? this.bloomsLevel,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class LessonActivity {
  final String id;
  final String title;
  final String description;
  final int duration;
  final String activityType;
  final List<String> materials;
  final String instructions;
  final Map<String, dynamic> aiGenerated;

  LessonActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.activityType,
    required this.materials,
    required this.instructions,
    required this.aiGenerated,
  });

  factory LessonActivity.fromMap(Map<String, dynamic> map) {
    return LessonActivity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0,
      activityType: map['activityType'] ?? '',
      materials: List<String>.from(map['materials'] ?? []),
      instructions: map['instructions'] ?? '',
      aiGenerated: Map<String, dynamic>.from(map['aiGenerated'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'activityType': activityType,
      'materials': materials,
      'instructions': instructions,
      'aiGenerated': aiGenerated,
    };
  }
}

class TeachingResource {
  final String id;
  final String name;
  final String type;
  final String url;
  final String description;
  final bool isRequired;

  TeachingResource({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.description,
    required this.isRequired,
  });

  factory TeachingResource.fromMap(Map<String, dynamic> map) {
    return TeachingResource(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      url: map['url'] ?? '',
      description: map['description'] ?? '',
      isRequired: map['isRequired'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'description': description,
      'isRequired': isRequired,
    };
  }
}

class AssessmentPlan {
  final String formativeType;
  final String summativeType;
  final List<String> rubrics;
  final Map<String, dynamic> aiQuestions;

  AssessmentPlan({
    required this.formativeType,
    required this.summativeType,
    required this.rubrics,
    required this.aiQuestions,
  });

  factory AssessmentPlan.fromMap(Map<String, dynamic> map) {
    return AssessmentPlan(
      formativeType: map['formativeType'] ?? '',
      summativeType: map['summativeType'] ?? '',
      rubrics: List<String>.from(map['rubrics'] ?? []),
      aiQuestions: Map<String, dynamic>.from(map['aiQuestions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'formativeType': formativeType,
      'summativeType': summativeType,
      'rubrics': rubrics,
      'aiQuestions': aiQuestions,
    };
  }
}

class DifferentiationStrategy {
  final Map<String, dynamic> learningStyles;
  final Map<String, dynamic> abilityLevels;
  final List<String> accommodations;

  DifferentiationStrategy({
    required this.learningStyles,
    required this.abilityLevels,
    required this.accommodations,
  });

  factory DifferentiationStrategy.fromMap(Map<String, dynamic> map) {
    return DifferentiationStrategy(
      learningStyles: Map<String, dynamic>.from(map['learningStyles'] ?? {}),
      abilityLevels: Map<String, dynamic>.from(map['abilityLevels'] ?? {}),
      accommodations: List<String>.from(map['accommodations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'learningStyles': learningStyles,
      'abilityLevels': abilityLevels,
      'accommodations': accommodations,
    };
  }
}

enum LessonStatus { draft, inProgress, completed, needsRevision, approved }

// Morning Prep Data Models (Add to lesson_provider.dart or separate file)
