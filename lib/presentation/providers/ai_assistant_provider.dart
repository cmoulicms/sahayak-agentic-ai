import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/data/models/aiModels/ai_models.dart';
import 'package:myapp/data/services/ai_teaching_assistant_service.dart';
import 'package:sahayak_ai2/data/models/aiModels/ai_models.dart';
import 'package:sahayak_ai2/data/services/ai_teaching_assistant_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Import service and models


class AIAssistantProvider extends ChangeNotifier {
  final AITeachingAssistantService _aiService = AITeachingAssistantService();

  bool _isLoading = false;
  String? _error;
  bool _isRecording = false;
  bool _isSpeaking = false;

  // Recent responses
  AIContentResponse? _lastContentResponse;
  DifferentiatedMaterialsResponse? _lastMaterialsResponse;
  KnowledgeResponse? _lastKnowledgeResponse;
  VisualAidResponse? _lastVisualAidResponse;
  EducationalGameResponse? _lastGameResponse;
  ReadingAssessmentResponse? _lastReadingAssessment;

  // Chat history for knowledge base
  final List<ChatMessage> _chatHistory = [];

  // History management
  final List<HistoryItem> _history = [];
  final List<SavedContent> _savedContent = [];
  final Set<String> _likedItems = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;
  bool get isSpeaking => _isSpeaking;
  String? get error => _error;
  AIContentResponse? get lastContentResponse => _lastContentResponse;
  DifferentiatedMaterialsResponse? get lastMaterialsResponse =>
      _lastMaterialsResponse;
  KnowledgeResponse? get lastKnowledgeResponse => _lastKnowledgeResponse;
  VisualAidResponse? get lastVisualAidResponse => _lastVisualAidResponse;
  EducationalGameResponse? get lastGameResponse => _lastGameResponse;
  ReadingAssessmentResponse? get lastReadingAssessment =>
      _lastReadingAssessment;
  List<ChatMessage> get chatHistory => _chatHistory;
  List<HistoryItem> get history => _history;
  List<SavedContent> get savedContent => _savedContent;
  Set<String> get likedItems => _likedItems;

  // Recent suggestions
  final List<AISuggestion> _recentSuggestions = [
    AISuggestion(
      title: 'Explain Water Cycle',
      description: 'Simple explanation with local examples',
      icon: Icons.water_drop,
      category: 'Science',
    ),
    AISuggestion(
      title: 'Math Problem Solving',
      description: 'Step-by-step approach for basic math',
      icon: Icons.calculate,
      category: 'Mathematics',
    ),
    AISuggestion(
      title: 'Story Writing Tips',
      description: 'Creative writing guidance for students',
      icon: Icons.book,
      category: 'English',
    ),
    AISuggestion(
      title: 'Local History',
      description: 'Stories from your region',
      icon: Icons.history_edu,
      category: 'Social Studies',
    ),
  ];

  List<AISuggestion> get recentSuggestions => _recentSuggestions;

  Future<void> initialize() async {
    await _loadHistory();
    await _loadSavedContent();
    await _loadLikedItems();
    await _aiService.initializeTTS();
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setRecording(bool recording) {
    _isRecording = recording;
    notifyListeners();
  }

  void _setSpeaking(bool speaking) {
    _isSpeaking = speaking;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Text-to-Speech functionality
  Future<void> speakText(String text) async {
    try {
      _setSpeaking(true);
      await _aiService.speak(text);
    } catch (e) {
      _setError('Failed to speak text: $e');
    } finally {
      _setSpeaking(false);
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _aiService.stopSpeaking();
      _setSpeaking(false);
    } catch (e) {
      _setError('Failed to stop speaking: $e');
    }
  }

  // Generate hyper-local content
  Future<void> generateLocalContent({
    required String prompt,
    required String language,
    required String culturalContext,
    String? subject,
    String? gradeLevel,
  }) async {
    _setLoading(true);
    try {
      _lastContentResponse = await _aiService.generateLocalContent(
        prompt: prompt,
        language: language,
        culturalContext: culturalContext,
        subject: subject,
        gradeLevel: gradeLevel,
      );

      _addToHistory(HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: HistoryItemType.localContent,
        title: 'Local Content: $prompt',
        description: 'Generated content for $subject',
        timestamp: DateTime.now(),
        data: _lastContentResponse!.toMap(),
      ));

      _clearError();
    } catch (e) {
      _setError('Failed to generate content: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create differentiated materials
  Future<void> createDifferentiatedMaterials({
    required Uint8List imageBytes,
    required List<String> targetGrades,
    String? subject,
    String? language,
  }) async {
    _setLoading(true);
    try {
      _lastMaterialsResponse = await _aiService.createDifferentiatedMaterials(
        imageBytes: imageBytes,
        targetGrades: targetGrades,
        subject: subject,
        language: language,
      );

      _addToHistory(HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: HistoryItemType.materials,
        title: 'Materials for Grades ${targetGrades.join(", ")}',
        description: 'Differentiated materials for $subject',
        timestamp: DateTime.now(),
        data: _lastMaterialsResponse!.toMap(),
      ));

      _clearError();
    } catch (e) {
      _setError('Failed to create differentiated materials: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Explain concept (Knowledge Base)
  Future<void> explainConcept({
    required String question,
    required String language,
    String? gradeLevel,
    bool includeAnalogy = true,
  }) async {
    _setLoading(true);

    _chatHistory.add(ChatMessage(
      content: question,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    try {
      _lastKnowledgeResponse = await _aiService.explainConcept(
        question: question,
        language: language,
        gradeLevel: gradeLevel,
        includeAnalogy: includeAnalogy,
      );

      _chatHistory.add(ChatMessage(
        content: _lastKnowledgeResponse!.explanation,
        isUser: false,
        timestamp: DateTime.now(),
        knowledgeResponse: _lastKnowledgeResponse,
      ));

      _addToHistory(HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: HistoryItemType.knowledge,
        title: 'Q: $question',
        description: 'Knowledge base response',
        timestamp: DateTime.now(),
        data: _lastKnowledgeResponse!.toMap(),
      ));

      _clearError();
    } catch (e) {
      _setError('Failed to explain concept: $e');
      _chatHistory.add(ChatMessage(
        content: 'Sorry, I couldn\'t process that question. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Generate visual aid
  Future<void> generateVisualAid({
    required String concept,
    required String type,
    String? subject,
    String? gradeLevel,
  }) async {
    _setLoading(true);
    try {
      _lastVisualAidResponse = await _aiService.generateVisualAid(
        concept: concept,
        type: type,
        subject: subject,
        gradeLevel: gradeLevel,
      );

      _addToHistory(HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: HistoryItemType.visualAid,
        title: '$type: $concept',
        description: 'Visual aid for $subject',
        timestamp: DateTime.now(),
        data: _lastVisualAidResponse!.toMap(),
      ));

      _clearError();
    } catch (e) {
      _setError('Failed to generate visual aid: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate educational game
  Future<void> generateGame({
    required String topic,
    required String gameType,
    String? subject,
    String? gradeLevel,
    int duration = 15,
  }) async {
    _setLoading(true);
    try {
      _lastGameResponse = await _aiService.generateGame(
        topic: topic,
        gameType: gameType,
        subject: subject,
        gradeLevel: gradeLevel,
        duration: duration,
      );

      _addToHistory(HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: HistoryItemType.game,
        title: '$gameType: $topic',
        description: 'Educational game for $subject',
        timestamp: DateTime.now(),
        data: _lastGameResponse!.toMap(),
      ));

      _clearError();
    } catch (e) {
      _setError('Failed to generate game: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Assess reading with enhanced recording
  Future<void> assessReading({
    required Uint8List audioBytes,
    required String expectedText,
    String? language,
  }) async {
    _setLoading(true);
    try {
      _lastReadingAssessment = await _aiService.assessReading(
        audioBytes: audioBytes,
        expectedText: expectedText,
        language: language,
      );

      _addToHistory(HistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: HistoryItemType.readingAssessment,
        title: 'Reading Assessment',
        description: 'Assessment for reading accuracy',
        timestamp: DateTime.now(),
        data: _lastReadingAssessment!.toMap(),
      ));

      _clearError();
    } catch (e) {
      _setError('Failed to assess reading: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Audio recording methods
  // Future<void> startRecording() async {
  //   try {
  //     await _aiService.startRecording();
  //     _setRecording(true);
  //   } catch (e) {
  //     _setError('Failed to start recording: $e');
  //   }
  // }

  // Future<Uint8List?> stopRecording() async {
  //   try {
  //     final audioBytes = await _aiService.stopRecording();
  //     _setRecording(false);
  //     return audioBytes;
  //   } catch (e) {
  //     _setError('Failed to stop recording: $e');
  //     _setRecording(false);
  //     return null;
  //   }
  // }

  // PDF Generation functionality
  Future<String> generatePDF({
    required String title,
    required String content,
    String? additionalInfo,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                content,
                style: const pw.TextStyle(fontSize: 12),
              ),
              if (additionalInfo != null) ...[
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  additionalInfo,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated on: ${DateTime.now().toString()}',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey,
                ),
              ),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  // Share functionality
  Future<void> shareContent({
    required String title,
    required String content,
    String? filePath,
  }) async {
    try {
      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: '$title\n\n$content',
        );
      } else {
        await Share.share('$title\n\n$content');
      }
    } catch (e) {
      _setError('Failed to share content: $e');
    }
  }

  // Copy to clipboard functionality
  Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      _setError('Failed to copy to clipboard: $e');
    }
  }

  // Like/Unlike functionality
  void toggleLike(String itemId) {
    if (_likedItems.contains(itemId)) {
      _likedItems.remove(itemId);
    } else {
      _likedItems.add(itemId);
    }
    _saveLikedItems();
    notifyListeners();
  }

  bool isLiked(String itemId) {
    return _likedItems.contains(itemId);
  }

  // Download content as PDF
  Future<String?> downloadContentAsPDF({
    required String title,
    required String content,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      String additionalInfo = '';

      if (additionalData != null) {
        if (additionalData.containsKey('keyPoints')) {
          additionalInfo += 'Key Points:\n';
          for (String point in additionalData['keyPoints']) {
            additionalInfo += '• $point\n';
          }
          additionalInfo += '\n';
        }

        if (additionalData.containsKey('activities')) {
          additionalInfo += 'Activities:\n';
          for (String activity in additionalData['activities']) {
            additionalInfo += '• $activity\n';
          }
          additionalInfo += '\n';
        }

        if (additionalData.containsKey('materials')) {
          additionalInfo += 'Materials:\n';
          for (String material in additionalData['materials']) {
            additionalInfo += '• $material\n';
          }
        }
      }

      return await generatePDF(
        title: title,
        content: content,
        additionalInfo: additionalInfo.isNotEmpty ? additionalInfo : null,
      );
    } catch (e) {
      _setError('Failed to download PDF: $e');
      return null;
    }
  }

  // History management methods
  void _addToHistory(HistoryItem item) {
    _history.insert(0, item);
    if (_history.length > 100) {
      _history.removeRange(100, _history.length);
    }
    _saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _chatHistory.clear();
    _saveHistory();
    notifyListeners();
  }

  void deleteHistoryItem(String id) {
    _history.removeWhere((item) => item.id == id);
    _saveHistory();
    notifyListeners();
  }

  void saveContent(String id, String title, Map<String, dynamic> data) {
    final savedItem = SavedContent(
      id: id,
      title: title,
      data: data,
      savedAt: DateTime.now(),
    );
    _savedContent.insert(0, savedItem);
    _saveSavedContent();
    notifyListeners();
  }

  void deleteSavedContent(String id) {
    _savedContent.removeWhere((item) => item.id == id);
    _saveSavedContent();
    notifyListeners();
  }

  // Search functionality
  List<HistoryItem> searchHistory(String query) {
    if (query.isEmpty) return _history;
    return _history
        .where((item) =>
            item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<HistoryItem> filterHistoryByType(HistoryItemType type) {
    return _history.where((item) => item.type == type).toList();
  }

  // Persistence methods
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('ai_assistant_history');
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _history.clear();
        _history.addAll(historyList.map((item) => HistoryItem.fromMap(item)));
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson =
          json.encode(_history.map((item) => item.toMap()).toList());
      await prefs.setString('ai_assistant_history', historyJson);
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  Future<void> _loadSavedContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('ai_assistant_saved');
      if (savedJson != null) {
        final List<dynamic> savedList = json.decode(savedJson);
        _savedContent.clear();
        _savedContent
            .addAll(savedList.map((item) => SavedContent.fromMap(item)));
      }
    } catch (e) {
      print('Error loading saved content: $e');
    }
  }

  Future<void> _saveSavedContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson =
          json.encode(_savedContent.map((item) => item.toMap()).toList());
      await prefs.setString('ai_assistant_saved', savedJson);
    } catch (e) {
      print('Error saving content: $e');
    }
  }

  Future<void> _loadLikedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedList = prefs.getStringList('ai_assistant_liked') ?? [];
      _likedItems.clear();
      _likedItems.addAll(likedList);
    } catch (e) {
      print('Error loading liked items: $e');
    }
  }

  Future<void> _saveLikedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('ai_assistant_liked', _likedItems.toList());
    } catch (e) {
      print('Error saving liked items: $e');
    }
  }

  // Export functionality
  Map<String, dynamic> exportData() {
    return {
      'history': _history.map((item) => item.toMap()).toList(),
      'savedContent': _savedContent.map((item) => item.toMap()).toList(),
      'likedItems': _likedItems.toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      if (data['history'] != null) {
        final List<dynamic> historyList = data['history'];
        _history.clear();
        _history.addAll(historyList.map((item) => HistoryItem.fromMap(item)));
      }

      if (data['savedContent'] != null) {
        final List<dynamic> savedList = data['savedContent'];
        _savedContent.clear();
        _savedContent
            .addAll(savedList.map((item) => SavedContent.fromMap(item)));
      }

      if (data['likedItems'] != null) {
        final List<dynamic> likedList = data['likedItems'];
        _likedItems.clear();
        _likedItems.addAll(likedList.cast<String>());
      }

      await _saveHistory();
      await _saveSavedContent();
      await _saveLikedItems();
      notifyListeners();
    } catch (e) {
      _setError('Failed to import data: $e');
    }
  }
}
