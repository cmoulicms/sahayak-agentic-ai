import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:myapp/util/json_parsing.dart';

class GeneratedContent {
  GeneratedContent({
    required this.id,
    required this.title,
    // this.image,
    required this.text,
    required this.createdBy,
    required this.language,
    required this.standard,
    this.likes = -1,
    this.downloads = -1,
  });

  final String id;
  final String title;
  // final XFile? image;
  final String text;
  final String createdBy;
  int likes;
  int downloads;
  final String language;
  final String standard;

  factory GeneratedContent.fromGeneratedContent(
    GenerateContentResponse content,
  ) {
    /// failures should be handled when the response is received
    assert(content.text != null);

    final validJson = cleanJson(content.text!);
    final json = jsonDecode(validJson);

    if (json case {
      "title": String title,
      "id": String id,
      "text": String text,
      "language": String language,
      "standard": String standard,
    }) {
      return GeneratedContent(
        id: id,
        title: title,
        text: text,
        createdBy: "Raja Ram",
        language: language,
        standard: standard,
      );
    }

    throw JsonUnsupportedObjectError(json);
  }

  Map<String, Object?> toFirestore() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'createdBy': createdBy,
      'language': language,
      'standard': standard,
      'likes': likes,
      'downloads': downloads,
    };
  }

  factory GeneratedContent.fromFirestore(Map<String, Object?> data) {
    if (data case {
      "title": String title,
      "id": String id,
      "text": String text,
      "createdBy": String createdBy,
      "language": String language,
      "standard": String standard,
      "likes": int likes,
      "downloads": int downloads,
    }) {
      return GeneratedContent(
        id: id,
        title: title,
        text: text,
        createdBy: createdBy,
        language: language,
        standard: standard,
        likes: likes,
        downloads: downloads,
      );
    }

    throw "Malformed Firestore data";
  }
}
