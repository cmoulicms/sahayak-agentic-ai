// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:myapp/data/models/aiModels/ai_models.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// // import 'package:speech_to_text/speech_to_text.dart' as stt;

// // Import model classes

// class AITeachingAssistantService {
//   static const String _baseUrl =
//       'https://generativelanguage.googleapis.com/v1beta';
//   static const String _vertexAIUrl =
//       'https://asia-south1-aiplatform.googleapis.com/v1';
//   static const String _apiKey = 'AIzaSyCEB7jMY2LbEWiKb4WlKulH8zwHGIf8_w4';
//   static const String _projectId = 'com.example.myapp';

//   // Initialize services
//   // final stt.SpeechToText _speechToText = stt.SpeechToText();
//   final AudioRecorder _record = AudioRecorder();
//   final FlutterTts _flutterTts = FlutterTts();
//   String? _recordingPath;

//   // Initialize TTS
//   Future<void> initializeTTS() async {
//     await _flutterTts.setLanguage("en-US");
//     await _flutterTts.setSpeechRate(0.5);
//     await _flutterTts.setVolume(1.0);
//     await _flutterTts.setPitch(1.0);
//   }

//   // Text to Speech
//   Future<void> speak(String text) async {
//     await _flutterTts.speak(text);
//   }

//   Future<void> stopSpeaking() async {
//     await _flutterTts.stop();
//   }

//   // Generate local content
//   Future<AIContentResponse> generateLocalContent({
//     required String prompt,
//     required String language,
//     required String culturalContext,
//     String? subject,
//     String? gradeLevel,
//   }) async {
//     final enhancedPrompt =
//         '''
// Create educational content in $language for ${gradeLevel ?? 'mixed grade'} students.
// Cultural Context: $culturalContext
// Subject: ${subject ?? 'general'}
// Request: $prompt

// Please provide:
// 1. Simple, culturally relevant content
// 2. Easy-to-understand language appropriate for the grade level
// 3. Local examples and analogies
// 4. Interactive elements if applicable

// Format the response as structured content that a teacher can easily use.
// ''';

//     final response = await _callGeminiAPI(enhancedPrompt);

//     return AIContentResponse(
//       content: response['content'] ?? '',
//       language: language,
//       subject: subject ?? 'general',
//       gradeLevel: gradeLevel ?? 'mixed',
//       culturallyAdapted: true,
//       generatedAt: DateTime.now(),
//     );
//   }

//   // Create differentiated materials
//   Future<DifferentiatedMaterialsResponse> createDifferentiatedMaterials({
//     required Uint8List imageBytes,
//     required List<String> targetGrades,
//     String? subject,
//     String? language,
//   }) async {
//     final base64Image = base64Encode(imageBytes);
//     final prompt =
//         '''
// Analyze this textbook page and create differentiated worksheets for grades: ${targetGrades.join(', ')}.
// Subject: ${subject ?? 'general'}
// Language: ${language ?? 'English'}

// For each grade level, provide:
// 1. Simplified version of the content
// 2. Age-appropriate questions
// 3. Visual aids descriptions
// 4. Hands-on activities
// 5. Assessment criteria

// Make sure content is progressively complex from lower to higher grades.
// ''';

//     final response = await _callGeminiVisionAPI(prompt, base64Image);
//     List<GradeLevelMaterial> materials = [];

//     for (String grade in targetGrades) {
//       materials.add(
//         GradeLevelMaterial(
//           gradeLevel: grade,
//           content: response['content_$grade'] ?? response['content'] ?? '',
//           activities: _extractActivities(response, grade),
//           assessments: _extractAssessments(response, grade),
//           visualAids: _extractVisualAids(response, grade),
//         ),
//       );
//     }

//     return DifferentiatedMaterialsResponse(
//       originalImage: imageBytes,
//       materials: materials,
//       subject: subject ?? 'general',
//       language: language ?? 'English',
//       generatedAt: DateTime.now(),
//     );
//   }

//   // Generate visual aid
//   Future<VisualAidResponse> generateVisualAid({
//     required String concept,
//     required String type,
//     String? subject,
//     String? gradeLevel,
//     bool generateImage = true,
//   }) async {
//     final instructionsPrompt =
//         '''
// Create detailed instructions for a $type to explain "$concept" for ${gradeLevel ?? 'elementary'} students.
// Subject: ${subject ?? 'general'}

// Provide:
// 1. Step-by-step drawing instructions for a teacher to recreate on blackboard
// 2. Labels and text to include
// 3. Colors or shading suggestions (if applicable)
// 4. Key elements to emphasize
// 5. Interactive elements students can participate in

// Make it simple enough to draw with chalk on a blackboard.
// ''';

//     final instructionsResponse = await _callGeminiAPI(instructionsPrompt);

//     String? imageUrl;
//     String? svgContent;

//     if (generateImage) {
//       try {
//         imageUrl = await _generateImageWithVertexAI(
//           concept,
//           type,
//           subject,
//           gradeLevel,
//         );
//         if (imageUrl == null) {
//           svgContent = _generateEnhancedSVGContent(concept, type);
//         }
//       } catch (e) {
//         print('Image generation failed: $e');
//         svgContent = _generateEnhancedSVGContent(concept, type);
//       }
//     }

//     return VisualAidResponse(
//       concept: concept,
//       type: type,
//       drawingInstructions:
//           instructionsResponse['instructions'] ??
//           instructionsResponse['content'] ??
//           '',
//       labels: _extractLabels(instructionsResponse),
//       materials: [
//         'Chalk',
//         'Blackboard',
//         'Ruler/Scale',
//         'Colored chalk (optional)',
//       ],
//       estimatedTime: _estimateDrawingTime(type),
//       subject: subject ?? 'general',
//       gradeLevel: gradeLevel ?? 'elementary',
//       generatedAt: DateTime.now(),
//       imageUrl: imageUrl,
//       svgContent: svgContent,
//     );
//   }

//   // Generate educational game
//   Future<EducationalGameResponse> generateGame({
//     required String topic,
//     required String gameType,
//     String? subject,
//     String? gradeLevel,
//     int duration = 15,
//   }) async {
//     final prompt =
//         '''
// Create an educational $gameType game about "$topic" for ${gradeLevel ?? 'elementary'} students.
// Subject: ${subject ?? 'general'}
// Duration: $duration minutes

// Provide:
// 1. Game rules and setup
// 2. Materials needed (simple, low-resource)
// 3. Step-by-step instructions
// 4. Variations for different skill levels
// 5. Learning objectives
// 6. Assessment criteria

// Make it suitable for a classroom with limited resources.
// ''';

//     final response = await _callGeminiAPI(prompt);

//     return EducationalGameResponse(
//       topic: topic,
//       gameType: gameType,
//       title: response['title'] ?? '$gameType Game: $topic',
//       rules: response['rules'] ?? '',
//       instructions: response['instructions'] ?? response['content'] ?? '',
//       materials: _extractMaterials(response),
//       duration: duration,
//       learningObjectives: _extractObjectives(response),
//       variations: _extractVariations(response),
//       subject: subject ?? 'general',
//       gradeLevel: gradeLevel ?? 'elementary',
//       generatedAt: DateTime.now(),
//     );
//   }

//   // Explain concept
//   Future<KnowledgeResponse> explainConcept({
//     required String question,
//     required String language,
//     String? gradeLevel,
//     bool includeAnalogy = true,
//   }) async {
//     final prompt =
//         '''
// Explain this concept in $language for ${gradeLevel ?? 'elementary'} level students: "$question"

// Provide:
// 1. Simple, clear explanation
// ${includeAnalogy ? '2. Easy-to-understand analogy or example from daily life' : ''}
// 3. Key points to remember
// 4. Common misconceptions to avoid
// 5. Fun facts if relevant

// Keep the language simple and engaging for young learners.
// ''';

//     final response = await _callGeminiAPI(prompt);

//     return KnowledgeResponse(
//       question: question,
//       explanation: response['explanation'] ?? response['content'] ?? '',
//       analogy: includeAnalogy ? response['analogy'] ?? '' : '',
//       keyPoints: _extractKeyPoints(response),
//       funFacts: _extractFunFacts(response),
//       language: language,
//       gradeLevel: gradeLevel ?? 'elementary',
//       generatedAt: DateTime.now(),
//     );
//   }

//   // Reading assessment
//   //   Future<ReadingAssessmentResponse> assessReading({
//   //     required Uint8List audioBytes,
//   //     required String expectedText,
//   //     String? language,
//   //     String? gradeLevel,
//   //   }) async {
//   //     try {
//   //       final transcription =
//   //           await _speechToTextFromBytes(audioBytes, language ?? 'en-US');

//   //       final analysisPrompt = '''
//   // Compare the expected text with the actual reading transcription for ${gradeLevel ?? 'elementary'} level assessment.

//   // Expected: "$expectedText"
//   // Actual: "$transcription"

//   // Provide detailed reading assessment with:
//   // 1. Accuracy percentage (0-100)
//   // 2. Specific pronunciation errors with corrections
//   // 3. Fluency rating (1-5 scale: 1=very slow/choppy, 5=smooth/natural)
//   // 4. Areas for improvement with specific suggestions
//   // 5. Positive feedback and encouragement
//   // 6. Suggested practice activities for improvement
//   // 7. Words or sounds that need special attention

//   // Format the response as structured data that can be easily parsed.
//   // ''';

//   //       final analysis = await _callGeminiAPI(analysisPrompt);

//   //       return ReadingAssessmentResponse(
//   //         expectedText: expectedText,
//   //         actualTranscription: transcription,
//   //         accuracyPercentage: _calculateAccuracy(expectedText, transcription),
//   //         fluencyRating: _extractFluencyRating(analysis),
//   //         pronunciationErrors: _extractErrors(analysis),
//   //         feedback: analysis['feedback'] ??
//   //             analysis['content'] ??
//   //             'Assessment completed.',
//   //         suggestions: _extractSuggestions(analysis),
//   //         language: language ?? 'English',
//   //         assessedAt: DateTime.now(),
//   //       );
//   //     } catch (e) {
//   //       throw AIServiceException('Failed to assess reading: $e');
//   //     }
//   //   }

//   // Audio recording methods
//   Future<void> startRecording() async {
//     try {
//       final status = await Permission.microphone.request();
//       if (status != PermissionStatus.granted) {
//         throw Exception('Microphone permission not granted');
//       }

//       if (await _record.hasPermission()) {
//         final Directory tempDir = await getTemporaryDirectory();
//         final String path =
//             '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

//         await _record.start(
//           const RecordConfig(
//             encoder: AudioEncoder.aacLc,
//             bitRate: 128000,
//             sampleRate: 44100,
//           ),
//           path: path,
//         );
//         _recordingPath = path;
//       } else {
//         throw Exception('Recording permission not granted');
//       }
//     } catch (e) {
//       throw AIServiceException('Failed to start recording: $e');
//     }
//   }

//   Future<Uint8List?> stopRecording() async {
//     try {
//       final String? path = await _record.stop();
//       if (path != null && _recordingPath != null) {
//         final File audioFile = File(_recordingPath!);
//         if (await audioFile.exists()) {
//           final Uint8List audioBytes = await audioFile.readAsBytes();
//           await audioFile.delete();
//           _recordingPath = null;
//           return audioBytes;
//         }
//       }
//       _recordingPath = null;
//       return null;
//     } catch (e) {
//       throw AIServiceException('Failed to stop recording: $e');
//     }
//   }

//   Future<bool> isRecording() async {
//     return await _record.isRecording();
//   }

//   // Private helper methods
//   Future<Map<String, dynamic>> _callGeminiAPI(String prompt) async {
//     final url =
//         '$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey';

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {'text': prompt},
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.7,
//             'maxOutputTokens': 2048,
//             'topP': 0.8,
//             'topK': 40,
//           },
//           'safetySettings': [
//             {
//               'category': 'HARM_CATEGORY_HARASSMENT',
//               'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
//             },
//             {
//               'category': 'HARM_CATEGORY_HATE_SPEECH',
//               'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
//             },
//             {
//               'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
//               'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
//             },
//             {
//               'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
//               'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
//             },
//           ],
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['candidates'] != null && data['candidates'].isNotEmpty) {
//           final content = data['candidates'][0]['content']['parts'][0]['text'];
//           return {'content': content};
//         } else {
//           throw Exception('No content generated by API');
//         }
//       } else {
//         final errorData = jsonDecode(response.body);
//         throw Exception(
//           'API call failed: ${response.statusCode} - ${errorData['error']['message']}',
//         );
//       }
//     } catch (e) {
//       print('Error in _callGeminiAPI: $e');
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>> _callGeminiVisionAPI(
//     String prompt,
//     String base64Image,
//   ) async {
//     final url =
//         '$_baseUrl/models/gemini-2.5-flash:generateContent?key=$_apiKey';

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {'text': prompt},
//                 {
//                   'inline_data': {
//                     'mime_type': 'image/jpeg',
//                     'data': base64Image,
//                   },
//                 },
//               ],
//             },
//           ],
//           'generationConfig': {
//             'temperature': 0.7,
//             'maxOutputTokens': 2048,
//             'topP': 0.8,
//             'topK': 40,
//           },
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['candidates'] != null && data['candidates'].isNotEmpty) {
//           final content = data['candidates'][0]['content']['parts'][0]['text'];
//           return {'content': content};
//         } else {
//           throw Exception('No content generated by Vision API');
//         }
//       } else {
//         final errorData = jsonDecode(response.body);
//         throw Exception(
//           'Vision API call failed: ${response.statusCode} - ${errorData['error']['message']}',
//         );
//       }
//     } catch (e) {
//       print('Error in _callGeminiVisionAPI: $e');
//       rethrow;
//     }
//   }

//   Future<String?> _generateImageWithVertexAI(
//     String concept,
//     String type,
//     String? subject,
//     String? gradeLevel,
//   ) async {
//     // Placeholder for actual Vertex AI implementation
//     return null;
//   }

//   String _generateEnhancedSVGContent(String concept, String type) {
//     switch (type.toLowerCase()) {
//       case 'diagram':
//         return _generateDetailedDiagramSVG(concept);
//       case 'chart':
//         return _generateDetailedChartSVG(concept);
//       case 'flowchart':
//         return _generateDetailedFlowchartSVG(concept);
//       default:
//         return _generateDetailedGenericSVG(concept);
//     }
//   }

//   String _generateDetailedDiagramSVG(String concept) {
//     return '''
// <svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
//   <rect width="400" height="300" fill="white" stroke="#333" stroke-width="2"/>
//   <circle cx="200" cy="150" r="80" fill="#e8f4fd" stroke="#2196f3" stroke-width="3"/>
//   <text x="200" y="120" text-anchor="middle" font-family="Arial" font-size="16" font-weight="bold">$concept</text>
//   <text x="200" y="140" text-anchor="middle" font-family="Arial" font-size="12">Main Concept</text>
//   <rect x="50" y="50" width="100" height="40" fill="#fff3e0" stroke="#ff9800" stroke-width="2"/>
//   <text x="100" y="75" text-anchor="middle" font-family="Arial" font-size="10">Detail 1</text>
//   <rect x="250" y="50" width="100" height="40" fill="#f3e5f5" stroke="#9c27b0" stroke-width="2"/>
//   <text x="300" y="75" text-anchor="middle" font-family="Arial" font-size="10">Detail 2</text>
//   <line x1="150" y1="70" x2="160" y2="120" stroke="#666" stroke-width="2"/>
//   <line x1="250" y1="70" x2="240" y2="120" stroke="#666" stroke-width="2"/>
// </svg>
// ''';
//   }

//   String _generateDetailedChartSVG(String concept) {
//     return '''
// <svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
//   <rect width="400" height="300" fill="white" stroke="#333" stroke-width="2"/>
//   <text x="200" y="30" text-anchor="middle" font-family="Arial" font-size="16" font-weight="bold">$concept Chart</text>
//   <rect x="50" y="60" width="60" height="120" fill="#4caf50" stroke="#2e7d32" stroke-width="2"/>
//   <rect x="130" y="100" width="60" height="80" fill="#2196f3" stroke="#1565c0" stroke-width="2"/>
//   <rect x="210" y="80" width="60" height="100" fill="#ff9800" stroke="#ef6c00" stroke-width="2"/>
//   <rect x="290" y="120" width="60" height="60" fill="#f44336" stroke="#c62828" stroke-width="2"/>
//   <text x="80" y="200" text-anchor="middle" font-family="Arial" font-size="12">A</text>
//   <text x="160" y="200" text-anchor="middle" font-family="Arial" font-size="12">B</text>
//   <text x="240" y="200" text-anchor="middle" font-family="Arial" font-size="12">C</text>
//   <text x="320" y="200" text-anchor="middle" font-family="Arial" font-size="12">D</text>
//   <line x1="40" y1="190" x2="370" y2="190" stroke="#333" stroke-width="2"/>
//   <line x1="40" y1="60" x2="40" y2="190" stroke="#333" stroke-width="2"/>
// </svg>
// ''';
//   }

//   String _generateDetailedFlowchartSVG(String concept) {
//     return '''
// <svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
//   <rect width="400" height="300" fill="white" stroke="#333" stroke-width="2"/>
//   <text x="200" y="30" text-anchor="middle" font-family="Arial" font-size="16" font-weight="bold">$concept Process</text>
//   <ellipse cx="200" cy="70" rx="60" ry="25" fill="#e8f5e8" stroke="#4caf50" stroke-width="2"/>
//   <text x="200" y="75" text-anchor="middle" font-family="Arial" font-size="12">Start</text>
//   <rect x="150" y="120" width="100" height="40" fill="#e3f2fd" stroke="#2196f3" stroke-width="2"/>
//   <text x="200" y="145" text-anchor="middle" font-family="Arial" font-size="12">Process</text>
//   <ellipse cx="200" cy="210" rx="60" ry="25" fill="#fff3e0" stroke="#ff9800" stroke-width="2"/>
//   <text x="200" y="215" text-anchor="middle" font-family="Arial" font-size="12">Result</text>
//   <line x1="200" y1="95" x2="200" y2="120" stroke="#666" stroke-width="2" marker-end="url(#arrowhead)"/>
//   <line x1="200" y1="160" x2="200" y2="185" stroke="#666" stroke-width="2" marker-end="url(#arrowhead)"/>
//   <defs>
//     <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
//       <polygon points="0 0, 10 3.5, 0 7" fill="#666"/>
//     </marker>
//   </defs>
// </svg>
// ''';
//   }

//   String _generateDetailedGenericSVG(String concept) {
//     return '''
// <svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
//   <rect width="400" height="300" fill="white" stroke="#333" stroke-width="2"/>
//   <circle cx="200" cy="150" r="100" fill="#f5f5f5" stroke="#333" stroke-width="3"/>
//   <text x="200" y="130" text-anchor="middle" font-family="Arial" font-size="18" font-weight="bold">$concept</text>
//   <text x="200" y="160" text-anchor="middle" font-family="Arial" font-size="14">Visual Aid</text>
//   <text x="200" y="180" text-anchor="middle" font-family="Arial" font-size="12">Educational Diagram</text>
// </svg>
// ''';
//   }

//   // Future<String> _speechToTextFromBytes(
//   //     Uint8List audioBytes, String language) async {
//   //   try {
//   //     bool available = await _speechToText.initialize(
//   //       onStatus: (status) => print('Speech recognition status: $status'),
//   //       onError: (errorNotification) =>
//   //           print('Speech recognition error: $errorNotification'),
//   //     );

//   //     if (!available) {
//   //       throw Exception('Speech recognition not available on this device');
//   //     }

//   //     final Directory tempDir = await getTemporaryDirectory();
//   //     final File tempAudioFile = File(
//   //         '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav');
//   //     await tempAudioFile.writeAsBytes(audioBytes);

//   //     await Future.delayed(const Duration(seconds: 2));

//   //     if (await tempAudioFile.exists()) {
//   //       await tempAudioFile.delete();
//   //     }

//   //     return "This is a simulated transcription of the recorded audio. In a real implementation, this would contain the actual speech-to-text result from the audio file.";
//   //   } catch (e) {
//   //     print('Speech-to-text error: $e');
//   //     throw AIServiceException('Failed to transcribe audio: $e');
//   //   }
//   // }

//   // Helper extraction methods
//   List<String> _extractActivities(Map<String, dynamic> response, String grade) {
//     final content = response['content'] ?? '';
//     final activities = <String>[];
//     final lines = content.split('\n');

//     for (String line in lines) {
//       if (line.toLowerCase().contains('activity') ||
//           line.toLowerCase().contains('exercise')) {
//         activities.add(line.trim());
//       }
//     }

//     return activities.isNotEmpty
//         ? activities
//         : ['Interactive discussion', 'Hands-on practice'];
//   }

//   List<String> _extractAssessments(
//     Map<String, dynamic> response,
//     String grade,
//   ) {
//     return ['Oral questioning', 'Quick quiz', 'Practical demonstration'];
//   }

//   List<String> _extractVisualAids(Map<String, dynamic> response, String grade) {
//     return ['Simple diagrams', 'Visual examples', 'Interactive charts'];
//   }

//   List<String> _extractLabels(Map<String, dynamic> response) {
//     return ['Main concept', 'Key features', 'Important details'];
//   }

//   int _estimateDrawingTime(String type) {
//     switch (type.toLowerCase()) {
//       case 'diagram':
//         return 10;
//       case 'chart':
//         return 8;
//       case 'illustration':
//         return 15;
//       case 'flowchart':
//         return 12;
//       default:
//         return 10;
//     }
//   }

//   List<String> _extractKeyPoints(Map<String, dynamic> response) {
//     return ['Key concept explained', 'Important to remember'];
//   }

//   List<String> _extractFunFacts(Map<String, dynamic> response) {
//     return ['Interesting related fact'];
//   }

//   List<String> _extractMaterials(Map<String, dynamic> response) {
//     return ['Paper', 'Pencil', 'Basic supplies'];
//   }

//   List<String> _extractObjectives(Map<String, dynamic> response) {
//     return ['Learning objective 1', 'Learning objective 2'];
//   }

//   List<String> _extractVariations(Map<String, dynamic> response) {
//     return ['Easier version', 'Advanced version'];
//   }

//   double _calculateAccuracy(String expected, String actual) {
//     final expectedWords = expected.toLowerCase().split(' ');
//     final actualWords = actual.toLowerCase().split(' ');
//     int matches = 0;
//     int maxLength = expectedWords.length > actualWords.length
//         ? expectedWords.length
//         : actualWords.length;

//     for (
//       int i = 0;
//       i < maxLength && i < expectedWords.length && i < actualWords.length;
//       i++
//     ) {
//       if (expectedWords[i] == actualWords[i]) matches++;
//     }

//     return maxLength > 0 ? (matches / maxLength) * 100.0 : 0.0;
//   }

//   int _extractFluencyRating(Map<String, dynamic> analysis) {
//     final content = analysis['content'] ?? '';
//     final ratingMatch = RegExp(r'(\d)/5').firstMatch(content);
//     if (ratingMatch != null) {
//       return int.tryParse(ratingMatch.group(1) ?? '3') ?? 3;
//     }
//     return 3;
//   }

//   List<String> _extractErrors(Map<String, dynamic> analysis) {
//     final content = analysis['content'] ?? '';
//     final errors = <String>[];
//     final lines = content.split('\n');

//     for (String line in lines) {
//       if (line.toLowerCase().contains('error') ||
//           line.toLowerCase().contains('mistake') ||
//           line.toLowerCase().contains('pronunciation')) {
//         errors.add(line.trim());
//       }
//     }

//     return errors.isNotEmpty ? errors : ['Minor pronunciation variations'];
//   }

//   List<String> _extractSuggestions(Map<String, dynamic> analysis) {
//     final content = analysis['content'] ?? '';
//     final suggestions = <String>[];
//     final lines = content.split('\n');

//     for (String line in lines) {
//       if (line.toLowerCase().contains('suggest') ||
//           line.toLowerCase().contains('recommend') ||
//           line.toLowerCase().contains('practice')) {
//         suggestions.add(line.trim());
//       }
//     }

//     return suggestions.isNotEmpty
//         ? suggestions
//         : ['Practice reading aloud', 'Focus on difficult words'];
//   }
// }

// // String extension
// extension StringExtension on String {
//   String capitalize() {
//     if (isEmpty) return this;
//     return "${this[0].toUpperCase()}${substring(1)}";
//   }
// }

// // Exception class
// class AIServiceException implements Exception {
//   final String message;
//   AIServiceException(this.message);

//   @override
//   String toString() => 'AIServiceException: $message';
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:myapp/data/models/aiModels/ai_models.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// Import model classes

class AITeachingAssistantService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _vertexAIUrl =
      'https://asia-south1-aiplatform.googleapis.com/v1';

  static const String _apiKey = 'AIzaSyAQbAv78oT-MVMp6OncLPW_gZnDkjqwkhc';
  // static const String _apiKey = 'AIzaSyCEB7jMY2LbEWiKb4WlKulH8zwHGIf8_w4';

  static const String _projectId = 'com.example.myapp';

  // Initialize services
  // final stt.SpeechToText _speechToText = stt.SpeechToText();
  // final AudioRecorder _record = AudioRecorder();
  final FlutterTts _flutterTts = FlutterTts();
  String? _recordingPath;

  // Initialize TTS
  Future<void> initializeTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Text to Speech
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // Generate local content
  Future<AIContentResponse> generateLocalContent({
    required String prompt,
    required String language,
    required String culturalContext,
    String? subject,
    String? gradeLevel,
  }) async {
    final enhancedPrompt =
        '''
    Create educational content in $language for ${gradeLevel ?? 'mixed grade'} students.
    Cultural Context: $culturalContext
    Subject: ${subject ?? 'general'}
    Request: $prompt

    Please provide:
    1. Simple, culturally relevant content
    2. Easy-to-understand language appropriate for the grade level
    3. Local examples and analogies
    4. Interactive elements if applicable

    Format the response only as a JSON object containing the following schema, with no markdown, no asterisks, no headings, no backticks, no extra characters.:
     
      "content": "created local content with the title line on the first line", 
    ''';

    final response = await _callGeminiAPI(enhancedPrompt);

    print(response);

    return AIContentResponse(
      content: response['content']['content'] ?? '',
      language: language,
      subject: subject ?? 'general',
      gradeLevel: gradeLevel ?? 'mixed',
      culturallyAdapted: true,
      generatedAt: DateTime.now(),
    );
  }

  String cleanJson(String maybeInvalidJson) {
    if (maybeInvalidJson.contains('```')) {
      final withoutLeading = maybeInvalidJson.split('```json').last;
      final withoutTrailing = withoutLeading.split('```').first;
      return withoutTrailing;
    }
    return maybeInvalidJson;
  }

  // Create differentiated materials
  Future<DifferentiatedMaterialsResponse> createDifferentiatedMaterials({
    required Uint8List imageBytes,
    required List<String> targetGrades,
    String? subject,
    String? language,
  }) async {
    final base64Image = base64Encode(imageBytes);
    final prompt =
        '''
  Analyze this textbook page and create differentiated worksheets for grades: ${targetGrades.join(', ')}.
  Subject: ${subject ?? 'general'}
  Language: ${language ?? 'English'}

  For each grade level, provide:
  1. Simplified version of the content
  2. Age-appropriate questions
  3. Visual aids descriptions
  4. Hands-on activities
  5. Assessment criteria

  Make sure content is progressively complex from lower to higher grades.
  ''';

    final response = await _callGeminiVisionAPI(prompt, base64Image);
    List<GradeLevelMaterial> materials = [];

    for (String grade in targetGrades) {
      materials.add(
        GradeLevelMaterial(
          gradeLevel: grade,
          content: response['content_$grade'] ?? response['content'] ?? '',
          activities: _extractActivities(response, grade),
          assessments: _extractAssessments(response, grade),
          visualAids: _extractVisualAids(response, grade),
        ),
      );
    }

    return DifferentiatedMaterialsResponse(
      originalImage: imageBytes,
      materials: materials,
      subject: subject ?? 'general',
      language: language ?? 'English',
      generatedAt: DateTime.now(),
    );
  }

  // Generate visual aid
  Future<VisualAidResponse> generateVisualAid({
    required String concept,
    required String type,
    String? subject,
    String? gradeLevel,
    bool generateImage = true,
  }) async {
    final instructionsPrompt =
        '''
Create detailed instructions for a $type to explain "$concept" for ${gradeLevel ?? 'elementary'} students.
Subject: ${subject ?? 'general'}

Provide:
1. Step-by-step drawing instructions for a teacher to recreate on blackboard
2. Labels and text to include
3. Colors or shading suggestions (if applicable)
4. Key elements to emphasize
5. Interactive elements students can participate in

Make it simple enough to draw with chalk on a blackboard with no markdown, no asterisks, no headings, no backticks, no extra characters.
''';

    final instructionsResponse = await _callGeminiAPI(instructionsPrompt);

    String? imageUrl;
    String? svgContent;

    if (generateImage) {
      try {
        imageUrl = await _generateImageWithVertexAI(
          concept,
          type,
          subject,
          gradeLevel,
        );
        if (imageUrl == null) {
          svgContent = _generateEnhancedSVGContent(concept, type);
        }
      } catch (e) {
        print('Image generation failed: $e');
        svgContent = _generateEnhancedSVGContent(concept, type);
      }
    }

    return VisualAidResponse(
      concept: concept,
      type: type,
      drawingInstructions:
          instructionsResponse['instructions'] ??
          instructionsResponse['content'] ??
          '',
      labels: _extractLabels(instructionsResponse),
      materials: [
        'Chalk',
        'Blackboard',
        'Ruler/Scale',
        'Colored chalk (optional)',
      ],
      estimatedTime: _estimateDrawingTime(type),
      subject: subject ?? 'general',
      gradeLevel: gradeLevel ?? 'elementary',
      generatedAt: DateTime.now(),
      imageUrl: imageUrl,
      svgContent: svgContent,
    );
  }

  // Generate educational game
  Future<EducationalGameResponse> generateGame({
    required String topic,
    required String gameType,
    String? subject,
    String? gradeLevel,
    int duration = 15,
  }) async {
    final prompt =
        '''
Create an educational $gameType game about "$topic" for ${gradeLevel ?? 'elementary'} students.
Subject: ${subject ?? 'general'}
Duration: $duration minutes

Provide:
1. Game rules and setup
2. Materials needed (simple, low-resource)
3. Step-by-step instructions
4. Variations for different skill levels
5. Learning objectives
6. Assessment criteria

Make it suitable for a classroom with limited resources.
''';

    final response = await _callGeminiAPI(prompt);

    return EducationalGameResponse(
      topic: topic,
      gameType: gameType,
      title: response['title'] ?? '$gameType Game: $topic',
      rules: response['rules'] ?? '',
      instructions: response['instructions'] ?? response['content'] ?? '',
      materials: _extractMaterials(response),
      duration: duration,
      learningObjectives: _extractObjectives(response),
      variations: _extractVariations(response),
      subject: subject ?? 'general',
      gradeLevel: gradeLevel ?? 'elementary',
      generatedAt: DateTime.now(),
    );
  }

  // Explain concept
  Future<KnowledgeResponse> explainConcept({
    required String question,
    required String language,
    String? gradeLevel,
    bool includeAnalogy = true,
  }) async {
    final prompt =
        '''
Explain this concept in $language for ${gradeLevel ?? 'elementary'} level students: "$question"

Provide:
1. Simple, clear explanation
${includeAnalogy ? '2. Easy-to-understand analogy or example from daily life' : ''}
3. Key points to remember
4. Common misconceptions to avoid
5. Fun facts if relevant

Keep the language simple and engaging for young learners with no markdown, no asterisks, no headings, no backticks, no extra characters..
''';

    final response = await _callGeminiAPI(prompt);

    return KnowledgeResponse(
      question: question,
      explanation: response['explanation'] ?? response['content'] ?? '',
      analogy: includeAnalogy ? response['analogy'] ?? '' : '',
      keyPoints: _extractKeyPoints(response),
      funFacts: _extractFunFacts(response),
      language: language,
      gradeLevel: gradeLevel ?? 'elementary',
      generatedAt: DateTime.now(),
    );
  }

  // Reading assessment
//   Future<ReadingAssessmentResponse> assessReading({
//     required Uint8List audioBytes,
//     required String expectedText,
//     String? language,
//     String? gradeLevel,
//   }) async {
//     try {
//       final transcription = await _speechToTextFromBytes(
//         audioBytes,
//         language ?? 'en-US',
//       );

//       final analysisPrompt =
//           '''
// Compare the expected text with the actual reading transcription for ${gradeLevel ?? 'elementary'} level assessment.

// Expected: "$expectedText"
// Actual: "$transcription"

// Provide detailed reading assessment with:
// 1. Accuracy percentage (0-100)
// 2. Specific pronunciation errors with corrections
// 3. Fluency rating (1-5 scale: 1=very slow/choppy, 5=smooth/natural)
// 4. Areas for improvement with specific suggestions
// 5. Positive feedback and encouragement
// 6. Suggested practice activities for improvement
// 7. Words or sounds that need special attention

// Format the response as structured data that can be easily parsed.
// ''';

//       final analysis = await _callGeminiAPI(analysisPrompt);

//       return ReadingAssessmentResponse(
//         expectedText: expectedText,
//         actualTranscription: transcription,
//         accuracyPercentage: _calculateAccuracy(expectedText, transcription),
//         fluencyRating: _extractFluencyRating(analysis),
//         pronunciationErrors: _extractErrors(analysis),
//         feedback:
//             analysis['feedback'] ??
//             analysis['content'] ??
//             'Assessment completed.',
//         suggestions: _extractSuggestions(analysis),
//         language: language ?? 'English',
//         assessedAt: DateTime.now(),
//       );
//     } catch (e) {
//       throw AIServiceException('Failed to assess reading: $e');
//     }
//   }

  // Audio recording methods
  // Future<void> startRecording() async {
  //   try {
  //     final status = await Permission.microphone.request();
  //     if (status != PermissionStatus.granted) {
  //       throw Exception('Microphone permission not granted');
  //     }

  //     if (await _record.hasPermission()) {
  //       final Directory tempDir = await getTemporaryDirectory();
  //       final String path =
  //           '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

  //       await _record.start(
  //         const RecordConfig(
  //           encoder: AudioEncoder.aacLc,
  //           bitRate: 128000,
  //           sampleRate: 44100,
  //         ),
  //         path: path,
  //       );
  //       _recordingPath = path;
  //     } else {
  //       throw Exception('Recording permission not granted');
  //     }
  //   } catch (e) {
  //     throw AIServiceException('Failed to start recording: $e');
  //   }
  // }

  // Future<Uint8List?> stopRecording() async {
  //   try {
  //     final String? path = await _record.stop();
  //     if (path != null && _recordingPath != null) {
  //       final File audioFile = File(_recordingPath!);
  //       if (await audioFile.exists()) {
  //         final Uint8List audioBytes = await audioFile.readAsBytes();
  //         await audioFile.delete();
  //         _recordingPath = null;
  //         return audioBytes;
  //       }
  //     }
  //     _recordingPath = null;
  //     return null;
  //   } catch (e) {
  //     throw AIServiceException('Failed to stop recording: $e');
  //   }
  // }

  // Future<bool> isRecording() async {
  //   return await _record.isRecording();
  // }

  // Private helper methods
  Future<Map<String, dynamic>> _callGeminiAPI(String prompt) async {
    final url =
        '$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
            'topP': 0.8,
            'topK': 40,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          try {
            final validJson = cleanJson(text);
            final parsedContent = jsonDecode(validJson);
            return {'content': parsedContent};
          } catch (_) {
            // If the text isn't JSON, return as-is
            return {'content': text};
          }
        } else {
          throw Exception('No content generated by API');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'API call failed: ${response.statusCode} - ${errorData['error']['message']}',
        );
      }
    } catch (e) {
      print('Error in _callGeminiAPI: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _callGeminiVisionAPI(
    String prompt,
    String base64Image,
  ) async {
    final url =
        '$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
            'topP': 0.8,
            'topK': 40,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          return {'content': content};
        } else {
          throw Exception('No content generated by Vision API');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Vision API call failed: ${response.statusCode} - ${errorData['error']['message']}',
        );
      }
    } catch (e) {
      print('Error in _callGeminiVisionAPI: $e');
      rethrow;
    }
  }

  Future<String?> _generateImageWithVertexAI(
    String concept,
    String type,
    String? subject,
    String? gradeLevel,
  ) async {
    // Placeholder for actual Vertex AI implementation
    return null;
  }

  String _generateEnhancedSVGContent(String concept, String type) {
    switch (type.toLowerCase()) {
      case 'diagram':
        return _generateDetailedDiagramSVG(concept);
      case 'chart':
        return _generateDetailedChartSVG(concept);
      case 'flowchart':
        return _generateDetailedFlowchartSVG(concept);
      default:
        return _generateDetailedGenericSVG(concept);
    }
  }

  String _generateDetailedDiagramSVG(String concept) {
    return '''
<svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="400" height="300" fill="white" stroke="#333" stroke-width="2"/>
  <circle cx="200" cy="150" r="80" fill="#e8f4fd" stroke="#2196f3" stroke-width="3"/>
  <text x="200" y="120" text-anchor="middle" font-family="Arial" font-size="16" font-weight="bold">$concept</text>
  <text x="200" y="140" text-anchor="middle" font-family="Arial" font-size="12">Main Concept</text>
  <rect x="50" y="50" width="100" height="40" fill="#fff3e0" stroke="#ff9800" stroke-width="2"/>
  <text x="100" y="75" text-anchor="middle" font-family="Arial" font-size="10">Detail 1</text>
  <rect x="250" y="50" width="100" height="40" fill="#f3e5f5" stroke="#9c27b0" stroke-width="2"/>
  <text x="300" y="75" text-anchor="middle" font-family="Arial" font-size="10">Detail 2</text>
  <line x1="150" y1="70" x2="160" y2="120" stroke="#666" stroke-width="2"/>
  <line x1="250" y1="70" x2="240" y2="120" stroke="#666" stroke-width="2"/>
</svg>
''';
  }

  String _generateDetailedChartSVG(String concept) {
    return '''
<svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="400" height="300" fill="white" stroke="#333" stroke-width="2"/>
  <text x="200" y="30" text-anchor="middle" font-family="Arial" font-size="16" font-weight="bold">$concept Chart</text>
  <rect x="50" y="60" width="60" height="120" fill="#4caf50" stroke="#2e7d32" stroke-width="2"/>
  <rect x="130" y="100" width="60" height="80" fill="#2196f3" stroke="#1565c0" stroke-width="2"/>
  <rect x="210" y="80" width="60" height="100" fill="#ff9800" stroke="#ef6c00" stroke-width="2"/>
  <rect x="290" y="120" width="60" height="60" fill="#f44336" stroke="#c62828" stroke-width="2"/>
  <text x="80" y="200" text-anchor="middle" font-family="Arial" font-size="12">A</text>
  <text x="160" y="200" text-anchor="middle" font-family="Arial" font-size="12">B</text>
  <text x="240" y="200" text-anchor="middle" font-family="Arial" font-size="12">C</text>
  <text x="320" y="200" text-anchor="middle" font-family="Arial" font-size="12">D</text>
  <line x1="40" y1="190" x2="370" y2="190" stroke="#333" stroke-width="2"/>
  <line x1="40" y1="60" x2="40" y2="190" stroke="#333" stroke-width="2"/>
</svg>
''';
  }

  String _generateDetailedFlowchartSVG(String concept) {
    return '''
<svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="400" height="300" fill="white" stroke="#333" stroke-width="2"/>
  <text x="200" y="30" text-anchor="middle" font-family="Arial" font-size="16" font-weight="bold">$concept Process</text>
  <ellipse cx="200" cy="70" rx="60" ry="25" fill="#e8f5e8" stroke="#4caf50" stroke-width="2"/>
  <text x="200" y="75" text-anchor="middle" font-family="Arial" font-size="12">Start</text>
  <rect x="150" y="120" width="100" height="40" fill="#e3f2fd" stroke="#2196f3" stroke-width="2"/>
  <text x="200" y="145" text-anchor="middle" font-family="Arial" font-size="12">Process</text>
  <ellipse cx="200" cy="210" rx="60" ry="25" fill="#fff3e0" stroke="#ff9800" stroke-width="2"/>
  <text x="200" y="215" text-anchor="middle" font-family="Arial" font-size="12">Result</text>
  <line x1="200" y1="95" x2="200" y2="120" stroke="#666" stroke-width="2" marker-end="url(#arrowhead)"/>
  <line x1="200" y1="160" x2="200" y2="185" stroke="#666" stroke-width="2" marker-end="url(#arrowhead)"/>
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#666"/>
    </marker>
  </defs>
</svg>
''';
  }

  String _generateDetailedGenericSVG(String concept) {
    return '''
<svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="400" height="300" fill="white" stroke="#333" stroke-width="2"/>
  <circle cx="200" cy="150" r="100" fill="#f5f5f5" stroke="#333" stroke-width="3"/>
  <text x="200" y="130" text-anchor="middle" font-family="Arial" font-size="18" font-weight="bold">$concept</text>
  <text x="200" y="160" text-anchor="middle" font-family="Arial" font-size="14">Visual Aid</text>
  <text x="200" y="180" text-anchor="middle" font-family="Arial" font-size="12">Educational Diagram</text>
</svg>
''';
  }

  // Future<String> _speechToTextFromBytes(
  //   Uint8List audioBytes,
  //   String language,
  // ) async {
  //   try {
  //     bool available = await _speechToText.initialize(
  //       onStatus: (status) => print('Speech recognition status: $status'),
  //       onError: (errorNotification) =>
  //           print('Speech recognition error: $errorNotification'),
  //     );

  //     if (!available) {
  //       throw Exception('Speech recognition not available on this device');
  //     }

  //     final Directory tempDir = await getTemporaryDirectory();
  //     final File tempAudioFile = File(
  //       '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav',
  //     );
  //     await tempAudioFile.writeAsBytes(audioBytes);

  //     await Future.delayed(const Duration(seconds: 2));

  //     if (await tempAudioFile.exists()) {
  //       await tempAudioFile.delete();
  //     }

  //     return "This is a simulated transcription of the recorded audio. In a real implementation, this would contain the actual speech-to-text result from the audio file.";
  //   } catch (e) {
  //     print('Speech-to-text error: $e');
  //     throw AIServiceException('Failed to transcribe audio: $e');
  //   }
  // }

  // Helper extraction methods
  List<String> _extractActivities(Map<String, dynamic> response, String grade) {
    final content = response['content'] ?? '';
    final activities = <String>[];
    final lines = content.split('\n');

    for (String line in lines) {
      if (line.toLowerCase().contains('activity') ||
          line.toLowerCase().contains('exercise')) {
        activities.add(line.trim());
      }
    }

    return activities.isNotEmpty
        ? activities
        : ['Interactive discussion', 'Hands-on practice'];
  }

  List<String> _extractAssessments(
    Map<String, dynamic> response,
    String grade,
  ) {
    return ['Oral questioning', 'Quick quiz', 'Practical demonstration'];
  }

  List<String> _extractVisualAids(Map<String, dynamic> response, String grade) {
    return ['Simple diagrams', 'Visual examples', 'Interactive charts'];
  }

  List<String> _extractLabels(Map<String, dynamic> response) {
    return ['Main concept', 'Key features', 'Important details'];
  }

  int _estimateDrawingTime(String type) {
    switch (type.toLowerCase()) {
      case 'diagram':
        return 10;
      case 'chart':
        return 8;
      case 'illustration':
        return 15;
      case 'flowchart':
        return 12;
      default:
        return 10;
    }
  }

  List<String> _extractKeyPoints(Map<String, dynamic> response) {
    return ['Key concept explained', 'Important to remember'];
  }

  List<String> _extractFunFacts(Map<String, dynamic> response) {
    return ['Interesting related fact'];
  }

  List<String> _extractMaterials(Map<String, dynamic> response) {
    return ['Paper', 'Pencil', 'Basic supplies'];
  }

  List<String> _extractObjectives(Map<String, dynamic> response) {
    return ['Learning objective 1', 'Learning objective 2'];
  }

  List<String> _extractVariations(Map<String, dynamic> response) {
    return ['Easier version', 'Advanced version'];
  }

  double _calculateAccuracy(String expected, String actual) {
    final expectedWords = expected.toLowerCase().split(' ');
    final actualWords = actual.toLowerCase().split(' ');
    int matches = 0;
    int maxLength = expectedWords.length > actualWords.length
        ? expectedWords.length
        : actualWords.length;

    for (
      int i = 0;
      i < maxLength && i < expectedWords.length && i < actualWords.length;
      i++
    ) {
      if (expectedWords[i] == actualWords[i]) matches++;
    }

    return maxLength > 0 ? (matches / maxLength) * 100.0 : 0.0;
  }

  int _extractFluencyRating(Map<String, dynamic> analysis) {
    final content = analysis['content'] ?? '';
    final ratingMatch = RegExp(r'(\d)/5').firstMatch(content);
    if (ratingMatch != null) {
      return int.tryParse(ratingMatch.group(1) ?? '3') ?? 3;
    }
    return 3;
  }

  List<String> _extractErrors(Map<String, dynamic> analysis) {
    final content = analysis['content'] ?? '';
    final errors = <String>[];
    final lines = content.split('\n');

    for (String line in lines) {
      if (line.toLowerCase().contains('error') ||
          line.toLowerCase().contains('mistake') ||
          line.toLowerCase().contains('pronunciation')) {
        errors.add(line.trim());
      }
    }

    return errors.isNotEmpty ? errors : ['Minor pronunciation variations'];
  }

  List<String> _extractSuggestions(Map<String, dynamic> analysis) {
    final content = analysis['content'] ?? '';
    final suggestions = <String>[];
    final lines = content.split('\n');

    for (String line in lines) {
      if (line.toLowerCase().contains('suggest') ||
          line.toLowerCase().contains('recommend') ||
          line.toLowerCase().contains('practice')) {
        suggestions.add(line.trim());
      }
    }

    return suggestions.isNotEmpty
        ? suggestions
        : ['Practice reading aloud', 'Focus on difficult words'];
  }

  _extractContent(Map<String, dynamic> response) {}
}

// String extension
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// Exception class
class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);

  @override
  String toString() => 'AIServiceException: $message';
}
