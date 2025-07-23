import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/features/generated_content/generated_content_model.dart';

const generatedContentPath = '/generatedContent';
final firestore = FirebaseFirestore.instance;

class FirestoreService {
  /*
  Class to store the generatedContent
*/
  static Future<Null> saveGeneratedContent(
    GeneratedContent generatedContent,
  ) async {
    await firestore
        .collection(generatedContentPath)
        .doc(generatedContent.id)
        .set(generatedContent.toFirestore());
  }

  static Future<Null> deleteGeneratedContent(
    GeneratedContent generatedContent,
  ) async {
    await firestore
        .doc("$generatedContentPath/${generatedContent.id}")
        .delete();
  }

  static Future<Null> updateGeneratedContent(
    GeneratedContent generatedContent,
  ) async {
    await firestore
        .doc("$generatedContentPath/${generatedContent.id}")
        .update(generatedContent.toFirestore());
  }
}
