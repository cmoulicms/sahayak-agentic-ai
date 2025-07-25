// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/data/models/teacher/teacher_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Teacher? _teacher;
  bool _isLoading = false;
  bool _isInitialized = false; // Add this to track initialization

  User? get user => _user;
  Teacher? get teacher => _teacher;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized; // Expose initialization state

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize auth state and listen for changes
  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    // Get current user immediately
    _user = _auth.currentUser;

    if (_user != null) {
      await _loadTeacherProfile();
    }

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();

    // Listen for auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (_user?.uid == user?.uid) return; // Avoid unnecessary updates

    _user = user;
    if (user != null) {
      await _loadTeacherProfile();
    } else {
      _teacher = null;
    }
    notifyListeners();
  }

  Future<void> _loadTeacherProfile() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('teachers').doc(_user!.uid).get();
      if (doc.exists) {
        _teacher = Teacher.fromMap(doc.data()!);

        // Update last active timestamp
        await _firestore.collection('teachers').doc(_user!.uid).update({
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error loading teacher profile: $e');
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail(
      String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await _createTeacherProfile(credential.user!, name);
        return true;
      }
      return false;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createTeacherProfile(User user, String name) async {
    final teacher = Teacher(
      id: user.uid,
      name: name,
      email: user.email!,
      classesHandling: [],
      subjects: [],
      syllabusType: '',
      medium: '',
      schoolContext: '',
      stressProfile: {},
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    await _firestore.collection('teachers').doc(user.uid).set(teacher.toMap());
    _teacher = teacher;
  }

  Future<void> updateTeacherProfile(Map<String, dynamic> updates) async {
    if (_user == null) return;

    try {
      await _firestore.collection('teachers').doc(_user!.uid).update(updates);
      await _loadTeacherProfile();
    } catch (e) {
      print('Error updating teacher profile: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _teacher = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }


  // Method to check if user setup is complete
  bool get isSetupComplete {
    if (_teacher == null) return false;

    // Check if all required onboarding fields are filled
    return _teacher!.classesHandling.isNotEmpty &&
        _teacher!.subjects.isNotEmpty &&
        _teacher!.syllabusType.isNotEmpty &&
        _teacher!.medium.isNotEmpty &&
        _teacher!.schoolContext.isNotEmpty;
  }
}
