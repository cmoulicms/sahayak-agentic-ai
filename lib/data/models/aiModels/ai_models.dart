import 'dart:typed_data';

// Core response models
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

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'language': language,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'culturallyAdapted': culturallyAdapted,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory AIContentResponse.fromMap(Map<String, dynamic> map) {
    return AIContentResponse(
      content: map['content'] ?? '',
      language: map['language'] ?? '',
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      culturallyAdapted: map['culturallyAdapted'] ?? false,
      generatedAt: DateTime.parse(map['generatedAt']),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'materials': materials.map((m) => m.toMap()).toList(),
      'subject': subject,
      'language': language,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'gradeLevel': gradeLevel,
      'content': content,
      'activities': activities,
      'assessments': assessments,
      'visualAids': visualAids,
    };
  }

  factory GradeLevelMaterial.fromMap(Map<String, dynamic> map) {
    return GradeLevelMaterial(
      gradeLevel: map['gradeLevel'] ?? '',
      content: map['content'] ?? '',
      activities: List<String>.from(map['activities'] ?? []),
      assessments: List<String>.from(map['assessments'] ?? []),
      visualAids: List<String>.from(map['visualAids'] ?? []),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'explanation': explanation,
      'analogy': analogy,
      'keyPoints': keyPoints,
      'funFacts': funFacts,
      'language': language,
      'gradeLevel': gradeLevel,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory KnowledgeResponse.fromMap(Map<String, dynamic> map) {
    return KnowledgeResponse(
      question: map['question'] ?? '',
      explanation: map['explanation'] ?? '',
      analogy: map['analogy'] ?? '',
      keyPoints: List<String>.from(map['keyPoints'] ?? []),
      funFacts: List<String>.from(map['funFacts'] ?? []),
      language: map['language'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      generatedAt: DateTime.parse(map['generatedAt']),
    );
  }
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
  final String? imageUrl;
  final String? svgContent;

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
    this.imageUrl,
    this.svgContent,
  });

  Map<String, dynamic> toMap() {
    return {
      'concept': concept,
      'type': type,
      'drawingInstructions': drawingInstructions,
      'labels': labels,
      'materials': materials,
      'estimatedTime': estimatedTime,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'generatedAt': generatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'svgContent': svgContent,
    };
  }

  factory VisualAidResponse.fromMap(Map<String, dynamic> map) {
    return VisualAidResponse(
      concept: map['concept'] ?? '',
      type: map['type'] ?? '',
      drawingInstructions: map['drawingInstructions'] ?? '',
      labels: List<String>.from(map['labels'] ?? []),
      materials: List<String>.from(map['materials'] ?? []),
      estimatedTime: map['estimatedTime'] ?? 0,
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      generatedAt: DateTime.parse(map['generatedAt']),
      imageUrl: map['imageUrl'],
      svgContent: map['svgContent'],
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'gameType': gameType,
      'title': title,
      'rules': rules,
      'instructions': instructions,
      'materials': materials,
      'duration': duration,
      'learningObjectives': learningObjectives,
      'variations': variations,
      'subject': subject,
      'gradeLevel': gradeLevel,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory EducationalGameResponse.fromMap(Map<String, dynamic> map) {
    return EducationalGameResponse(
      topic: map['topic'] ?? '',
      gameType: map['gameType'] ?? '',
      title: map['title'] ?? '',
      rules: map['rules'] ?? '',
      instructions: map['instructions'] ?? '',
      materials: List<String>.from(map['materials'] ?? []),
      duration: map['duration'] ?? 0,
      learningObjectives: List<String>.from(map['learningObjectives'] ?? []),
      variations: List<String>.from(map['variations'] ?? []),
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] ?? '',
      generatedAt: DateTime.parse(map['generatedAt']),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'expectedText': expectedText,
      'actualTranscription': actualTranscription,
      'accuracyPercentage': accuracyPercentage,
      'fluencyRating': fluencyRating,
      'pronunciationErrors': pronunciationErrors,
      'feedback': feedback,
      'suggestions': suggestions,
      'language': language,
      'assessedAt': assessedAt.toIso8601String(),
    };
  }

  factory ReadingAssessmentResponse.fromMap(Map<String, dynamic> map) {
    return ReadingAssessmentResponse(
      expectedText: map['expectedText'] ?? '',
      actualTranscription: map['actualTranscription'] ?? '',
      accuracyPercentage: (map['accuracyPercentage'] ?? 0.0).toDouble(),
      fluencyRating: map['fluencyRating'] ?? 0,
      pronunciationErrors: List<String>.from(map['pronunciationErrors'] ?? []),
      feedback: map['feedback'] ?? '',
      suggestions: List<String>.from(map['suggestions'] ?? []),
      language: map['language'] ?? '',
      assessedAt: DateTime.parse(map['assessedAt']),
    );
  }
}

// Chat and UI models
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

// History and persistence models
enum HistoryItemType {
  localContent,
  materials,
  knowledge,
  visualAid,
  game,
  readingAssessment,
}

class HistoryItem {
  final String id;
  final HistoryItemType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  HistoryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      type: HistoryItemType.values[map['type']],
      title: map['title'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      data: Map<String, dynamic>.from(map['data']),
    );
  }
}

class SavedContent {
  final String id;
  final String title;
  final Map<String, dynamic> data;
  final DateTime savedAt;

  SavedContent({
    required this.id,
    required this.title,
    required this.data,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'data': data,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedContent.fromMap(Map<String, dynamic> map) {
    return SavedContent(
      id: map['id'],
      title: map['title'],
      data: Map<String, dynamic>.from(map['data']),
      savedAt: DateTime.parse(map['savedAt']),
    );
  }
}
