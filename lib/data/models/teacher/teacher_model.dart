class Teacher {
  final String id;
  final String name;
  final String email;
  final List<String> classesHandling;
  final List<String> subjects;
  final String syllabusType;
  final String medium;
  final String schoolContext;
  final Map<String, dynamic> stressProfile;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.classesHandling,
    required this.subjects,
    required this.syllabusType,
    required this.medium,
    required this.schoolContext,
    required this.stressProfile,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      classesHandling: List<String>.from(map['classesHandling']),
      subjects: List<String>.from(map['subjects']),
      syllabusType: map['syllabusType'],
      medium: map['medium'],
      schoolContext: map['schoolContext'],
      stressProfile: Map<String, dynamic>.from(map['stressProfile']),
      createdAt: DateTime.parse(map['createdAt']),
      lastActiveAt: DateTime.parse(map['lastActiveAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'classesHandling': classesHandling,
      'subjects': subjects,
      'syllabusType': syllabusType,
      'medium': medium,
      'schoolContext': schoolContext,
      'stressProfile': stressProfile,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }
}
