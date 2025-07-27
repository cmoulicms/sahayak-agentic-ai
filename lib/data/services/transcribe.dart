import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FirebaseSpeechService {
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Uploads audio file to Firebase Storage to trigger Speech-to-Text Firebase Extension
  /// Returns the transcription once the extension processes it
  Future<String?> speechToText(File audioFile) async {
    final id = _uuid.v4();
    final ref = _storage.ref().child('audio/$id.wav');

    // Upload audio file
    await ref.putFile(audioFile);

    // Listen for transcription in Firestore
    final docRef = _firestore.collection('transcripts').doc(id);

    // Wait up to 30 seconds for transcript to be generated
    for (int i = 0; i < 30; i++) {
      final doc = await docRef.get();
      if (doc.exists && doc.data()?['transcription'] != null) {
        return doc['transcription'];
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    return null; // Timed out or failed
  }

  /// Sends a TTS request to Firestore
  /// Returns audio URL after Firebase Extension (or Function) generates it
  Future<String?> textToSpeech(
    String text, {
    String languageCode = 'en-US',
    String voice = 'en-US-Wavenet-D',
  }) async {
    final id = _uuid.v4();

    final docRef = _firestore.collection('audio').doc(id);

    await docRef.set({
      'text': text,
      'languageCode': languageCode,
      'voice': voice,
      'status': 'pending',
    });

    // Wait up to 30 seconds for audio URL
    for (int i = 0; i < 30; i++) {
      final doc = await docRef.get();
      final data = doc.data();
      if (data != null && data['audioPath'] != null) {
        return data['audioPath'];
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    return null; // Timed out or failed
  }
}
