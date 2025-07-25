// // screens/ai_assistant/ai_assistant_screen.dart
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:record/record.dart';
// import 'package:share_plus/share_plus.dart';

// import 'package:sahayak_ai2/data/services/ai_teaching_assistant_service.dart';
// import 'package:sahayak_ai2/presentation/widgets/shayakCard.dart';

// import '../../providers/ai_assistant_provider.dart';

// class AIAssistantScreen extends StatefulWidget {
//   const AIAssistantScreen({super.key});

//   @override
//   State<AIAssistantScreen> createState() => _AIAssistantScreenState();
// }

// class _AIAssistantScreenState extends State<AIAssistantScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _chatController = TextEditingController();
//   final ScrollController _chatScrollController = ScrollController();
//   // final Record _audioRecorder = Record();
//   bool _isRecording = false;
//   String? _recordingPath;
//   File? _selectedImage;
//   final TextEditingController _readingTextController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 6, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _chatController.dispose();
//     _chatScrollController.dispose();
//     _readingTextController.dispose();
//     // _audioRecorder.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: AppBar(
//         title: const Text('AI Teaching Assistant'),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         bottom: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabs: const [
//             Tab(
//                 text: 'Ask AI',
//                 icon: Icon(Icons.chat_bubble_outline, size: 20)),
//             Tab(text: 'Local Content', icon: Icon(Icons.language, size: 20)),
//             Tab(text: 'Materials', icon: Icon(Icons.layers, size: 20)),
//             Tab(text: 'Visual Aids', icon: Icon(Icons.draw, size: 20)),
//             Tab(text: 'Games', icon: Icon(Icons.games, size: 20)),
//             Tab(
//                 text: 'Reading Test',
//                 icon: Icon(Icons.record_voice_over, size: 20)),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: () {},
//             // onPressed: _showHistory,
//             tooltip: 'History',
//           ),
//           PopupMenuButton<String>(
//             // onSelected: _handleMenuAction,
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                   value: 'clear_history', child: Text('Clear History')),
//               const PopupMenuItem(
//                   value: 'export_content', child: Text('Export Content')),
//               const PopupMenuItem(
//                   value: 'settings', child: Text('AI Settings')),
//             ],
//           ),
//         ],
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildKnowledgeBaseTab(),
//           _buildLocalContentTab(),
//           _buildDifferentiatedMaterialsTab(),
//           _buildVisualAidsTab(),
//           _buildEducationalGamesTab(),
//           _buildReadingAssessmentTab(),
//         ],
//       ),
//     );
//   }

//   // Knowledge Base Chat Tab
//   Widget _buildKnowledgeBaseTab() {
//     return Consumer<AIAssistantProvider>(
//       builder: (context, aiProvider, child) {
//         return Column(
//           children: [
//             // Recent suggestions
//             // if (aiProvider.getRecentSuggestions().isNotEmpty)
//             //   Container(
//             //     height: 100,
//             //     padding: const EdgeInsets.symmetric(vertical: 8),
//             //     child: ListView.builder(
//             //       scrollDirection: Axis.horizontal,
//             //       itemCount: aiProvider.getRecentSuggestions().length,
//             //       itemBuilder: (context, index) {
//             //         final suggestion = aiProvider.getRecentSuggestions()[index];
//             //         return _buildSuggestionChip(suggestion);
//             //       },
//             //     ),
//             //   ),

//             // Chat messages
//             Expanded(
//               child: aiProvider.chatHistory.isEmpty
//                   ? _buildEmptyChatState()
//                   : ListView.builder(
//                       controller: _chatScrollController,
//                       padding: const EdgeInsets.all(16),
//                       itemCount: aiProvider.chatHistory.length,
//                       itemBuilder: (context, index) {
//                         final message = aiProvider.chatHistory[index];
//                         return _buildChatMessage(message);
//                       },
//                     ),
//             ),

//             // Input area
//             _buildChatInput(aiProvider),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildSuggestionChip(AISuggestion suggestion) {
//     return Container(
//       margin: const EdgeInsets.only(left: 16, right: 8),
//       child: SahayakCard(
//         onTap: () => _applySuggestion(suggestion),
//         child: Container(
//           width: 200,
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(suggestion.icon,
//                       size: 16, color: Theme.of(context).colorScheme.primary),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       suggestion.title,
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleSmall
//                           ?.copyWith(fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 suggestion.description,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: Theme.of(context)
//                           .colorScheme
//                           .onSurface
//                           .withOpacity(0.7),
//                     ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyChatState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.chat_bubble_outline,
//             size: 64,
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Ask me anything!',
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   color:
//                       Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//                 ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'I can explain concepts, answer questions,\nand provide teaching suggestions',
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   color:
//                       Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
//                 ),
//           ),
//           const SizedBox(height: 24),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               _buildQuickQuestion('Why is the sky blue?'),
//               _buildQuickQuestion('How do plants grow?'),
//               _buildQuickQuestion('What is gravity?'),
//               _buildQuickQuestion('Explain photosynthesis'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickQuestion(String question) {
//     return ActionChip(
//       label: Text(question),
//       onPressed: () {
//         _chatController.text = question;
//         _sendMessage();
//       },
//       backgroundColor:
//           Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
//     );
//   }

//   Widget _buildChatMessage(ChatMessage message) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (!message.isUser) ...[
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: Theme.of(context).colorScheme.primaryContainer,
//               child: Icon(Icons.smart_toy,
//                   size: 16, color: Theme.of(context).colorScheme.primary),
//             ),
//             const SizedBox(width: 12),
//           ],
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: message.isUser
//                     ? Theme.of(context).colorScheme.primaryContainer
//                     : message.isError
//                         ? Theme.of(context).colorScheme.errorContainer
//                         : Theme.of(context).colorScheme.surfaceVariant,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     message.content,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: message.isError
//                               ? Theme.of(context).colorScheme.onErrorContainer
//                               : null,
//                         ),
//                   ),
//                   if (message.knowledgeResponse != null) ...[
//                     const SizedBox(height: 12),
//                     _buildKnowledgeExtras(message.knowledgeResponse!),
//                   ],
//                   const SizedBox(height: 8),
//                   // Text(
//                   //   _formatTime(message.timestamp),
//                   //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   //         color: Theme.of(context)
//                   //             .colorScheme
//                   //             .onSurface
//                   //             .withOpacity(0.5),
//                   //       ),
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//           if (message.isUser) ...[
//             const SizedBox(width: 12),
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               child: const Icon(Icons.person, size: 16, color: Colors.white),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildKnowledgeExtras(KnowledgeResponse response) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (response.analogy.isNotEmpty) ...[
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Theme.of(context)
//                   .colorScheme
//                   .primaryContainer
//                   .withOpacity(0.3),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.lightbulb_outline,
//                         size: 16, color: Theme.of(context).colorScheme.primary),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Think of it this way:',
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleSmall
//                           ?.copyWith(fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(response.analogy),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//         if (response.keyPoints.isNotEmpty) ...[
//           ExpansionTile(
//             title: const Text('Key Points'),
//             leading: const Icon(Icons.key),
//             children: response.keyPoints
//                 .map((point) => ListTile(
//                       leading: const Icon(Icons.arrow_right, size: 16),
//                       title: Text(point),
//                       dense: true,
//                     ))
//                 .toList(),
//           ),
//         ],
//         if (response.funFacts.isNotEmpty) ...[
//           ExpansionTile(
//             title: const Text('Fun Facts'),
//             leading: const Icon(Icons.star),
//             children: response.funFacts
//                 .map((fact) => ListTile(
//                       leading: const Icon(Icons.star_border, size: 16),
//                       title: Text(fact),
//                       dense: true,
//                     ))
//                 .toList(),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildChatInput(AIAssistantProvider aiProvider) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         border: Border(
//           top: BorderSide(
//             color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _chatController,
//               decoration: InputDecoration(
//                 hintText: 'Ask a question...',
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//               maxLines: null,
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           const SizedBox(width: 8),
//           CircleAvatar(
//             backgroundColor: Theme.of(context).colorScheme.primary,
//             child: IconButton(
//               icon: aiProvider.isLoading
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                           strokeWidth: 2, color: Colors.white),
//                     )
//                   : const Icon(Icons.send, color: Colors.white),
//               onPressed: aiProvider.isLoading ? null : _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Local Content Generation Tab
//   Widget _buildLocalContentTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Generate Hyper-Local Content',
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineSmall
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Create culturally relevant content in your local language',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   color:
//                       Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//                 ),
//           ),
//           const SizedBox(height: 24),
//           _buildLocalContentForm(),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocalContentForm() {
//     final promptController = TextEditingController();
//     final culturalContextController = TextEditingController();
//     String selectedLanguage = 'English';
//     String selectedSubject = 'General';
//     String selectedGrade = 'Mixed';

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return SahayakCard(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Content Request',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleLarge
//                       ?.copyWith(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: promptController,
//                   decoration: const InputDecoration(
//                     labelText: 'What would you like me to create?',
//                     hintText:
//                         'e.g., Create a story about farmers to explain different soil types',
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedLanguage,
//                         decoration: const InputDecoration(
//                           labelText: 'Language',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: [
//                           'English',
//                           'Hindi',
//                           'Marathi',
//                           'Tamil',
//                           'Telugu',
//                           'Bengali',
//                           'Gujarati'
//                         ]
//                             .map((lang) => DropdownMenuItem(
//                                 value: lang, child: Text(lang)))
//                             .toList(),
//                         onChanged: (value) =>
//                             setState(() => selectedLanguage = value!),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedSubject,
//                         decoration: const InputDecoration(
//                           labelText: 'Subject',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: [
//                           'General',
//                           'Mathematics',
//                           'Science',
//                           'English',
//                           'Social Studies',
//                           'Arts'
//                         ]
//                             .map((subject) => DropdownMenuItem(
//                                 value: subject, child: Text(subject)))
//                             .toList(),
//                         onChanged: (value) =>
//                             setState(() => selectedSubject = value!),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedGrade,
//                         decoration: const InputDecoration(
//                           labelText: 'Grade Level',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: ['Mixed', '1-3', '4-6', '7-9', '10-12']
//                             .map((grade) => DropdownMenuItem(
//                                 value: grade, child: Text(grade)))
//                             .toList(),
//                         onChanged: (value) =>
//                             setState(() => selectedGrade = value!),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: culturalContextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Cultural Context',
//                     hintText: 'e.g., Rural farming community in Maharashtra',
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 2,
//                 ),
//                 const SizedBox(height: 24),
//                 Consumer<AIAssistantProvider>(
//                   builder: (context, aiProvider, child) {
//                     return SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: aiProvider.isLoading
//                             ? null
//                             : () => _generateLocalContent(
//                                   promptController.text,
//                                   selectedLanguage,
//                                   culturalContextController.text,
//                                   selectedSubject,
//                                   selectedGrade,
//                                 ),
//                         icon: aiProvider.isLoading
//                             ? const SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child:
//                                     CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : const Icon(Icons.auto_awesome),
//                         label: Text(aiProvider.isLoading
//                             ? 'Generating...'
//                             : 'Generate Content'),
//                         style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.all(16)),
//                       ),
//                     );
//                   },
//                 ),
//                 // Show generated content
//                 Consumer<AIAssistantProvider>(
//                   builder: (context, aiProvider, child) {
//                     if (aiProvider.lastContentResponse != null) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 24),
//                           const Divider(),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Generated Content',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleLarge
//                                 ?.copyWith(fontWeight: FontWeight.w600),
//                           ),
//                           const SizedBox(height: 12),
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .primaryContainer
//                                   .withOpacity(0.3),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(Icons.language,
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .primary),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       '${aiProvider.lastContentResponse!.language} • ${aiProvider.lastContentResponse!.subject}',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleSmall
//                                           ?.copyWith(
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .primary,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Text(aiProvider.lastContentResponse!.content),
//                                 const SizedBox(height: 12),
//                                 // Row(
//                                 //   children: [
//                                 //     TextButton.icon(
//                                 //       onPressed: () => _shareContent(aiProvider
//                                 //           .lastContentResponse!.content),
//                                 //       icon: const Icon(Icons.share, size: 16),
//                                 //       label: const Text('Share'),
//                                 //     ),
//                                 //     TextButton.icon(
//                                 //       onPressed: () => _saveContent(
//                                 //           aiProvider.lastContentResponse!),
//                                 //       icon: const Icon(Icons.save, size: 16),
//                                 //       label: const Text('Save'),
//                                 //     ),
//                                 //   ],
//                                 // ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       );
//                     }
//                     return const SizedBox();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Differentiated Materials Tab
//   Widget _buildDifferentiatedMaterialsTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Create Differentiated Materials',
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineSmall
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Upload a textbook page to create grade-specific worksheets',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   color:
//                       Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//                 ),
//           ),
//           const SizedBox(height: 24),
//           _buildImageUploadSection(),
//           const SizedBox(height: 24),
//           _buildGradeSelectionSection(),
//           const SizedBox(height: 24),
//           _buildDifferentiatedMaterialsResults(),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageUploadSection() {
//     return SahayakCard(
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           children: [
//             if (_selectedImage != null) ...[
//               Container(
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border:
//                       Border.all(color: Theme.of(context).colorScheme.outline),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.file(_selectedImage!, fit: BoxFit.cover),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//             Icon(
//               Icons.cloud_upload_outlined,
//               size: 64,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Upload Textbook Page',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge
//                   ?.copyWith(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Take a photo or select an image from gallery',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context)
//                         .colorScheme
//                         .onSurface
//                         .withOpacity(0.7),
//                   ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text('Camera'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   icon: const Icon(Icons.photo_library),
//                   label: const Text('Gallery'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGradeSelectionSection() {
//     List<String> selectedGrades = ['4', '5', '6'];

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return SahayakCard(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Target Grade Levels',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleLarge
//                       ?.copyWith(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 16),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: List.generate(12, (index) {
//                     final grade = (index + 1).toString();
//                     final isSelected = selectedGrades.contains(grade);

//                     return FilterChip(
//                       label: Text('Grade $grade'),
//                       selected: isSelected,
//                       onSelected: (selected) {
//                         setState(() {
//                           if (selected) {
//                             selectedGrades.add(grade);
//                           } else {
//                             selectedGrades.remove(grade);
//                           }
//                         });
//                       },
//                     );
//                   }),
//                 ),
//                 const SizedBox(height: 24),
//                 // Consumer<AIAssistantProvider>(
//                 //   builder: (context, aiProvider, child) {
//                 //     return SizedBox(
//                 //       width: double.infinity,
//                 //       child: ElevatedButton.icon(
//                 //         onPressed: selectedGrades.isEmpty ||
//                 //                 aiProvider.isLoading ||
//                 //                 _selectedImage == null
//                 //             ? null
//                 //             : () =>
//                 //               // aiProvider._createDifferentiatedMaterials(selectedGrades),
//                 //         icon: aiProvider.isLoading
//                 //             ? const SizedBox(
//                 //                 width: 24,
//                 //                 height: 24,
//                 //                 child: CircularProgressIndicator())
//                 //             : const Icon(Icons.add),
//                 //         label: const Text('Create Differentiated Materials'),
//                 //       ),
//                 //     );
//                 //   },
//                 // ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDifferentiatedMaterialsResults() {
//     return Consumer<AIAssistantProvider>(
//       builder: (context, aiProvider, child) {
//         if (aiProvider.lastMaterialsResponse == null) {
//           return const SizedBox();
//         }

//         final response = aiProvider.lastMaterialsResponse!;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Generated Materials',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge
//                   ?.copyWith(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 16),
//             ...response.materials
//                 .map((material) => _buildGradeMaterial(material)),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildGradeMaterial(GradeLevelMaterial material) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: SahayakCard(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.primaryContainer,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       'Grade ${material.gradeLevel}',
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.primary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   PopupMenuButton<String>(
//                     // onSelected: (value) =>
//                     //     _handleMaterialAction(value, material),
//                     itemBuilder: (context) => [
//                       const PopupMenuItem(value: 'share', child: Text('Share')),
//                       const PopupMenuItem(value: 'save', child: Text('Save')),
//                       const PopupMenuItem(value: 'print', child: Text('Print')),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(material.content,
//                   style: Theme.of(context).textTheme.bodyMedium),
//               if (material.activities.isNotEmpty) ...[
//                 const SizedBox(height: 12),
//                 ExpansionTile(
//                   title: const Text('Activities'),
//                   leading: const Icon(Icons.assignment),
//                   children: material.activities
//                       .map((activity) => ListTile(
//                             leading:
//                                 const Icon(Icons.play_circle_outline, size: 16),
//                             title: Text(activity),
//                             dense: true,
//                           ))
//                       .toList(),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Visual Aids Tab
//   Widget _buildVisualAidsTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Generate Visual Aids',
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineSmall
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Create drawing instructions for blackboard diagrams',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   color:
//                       Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//                 ),
//           ),
//           const SizedBox(height: 24),
//           _buildVisualAidForm(),
//           const SizedBox(height: 24),
//           _buildVisualAidResults(),
//         ],
//       ),
//     );
//   }

//   Widget _buildVisualAidForm() {
//     final conceptController = TextEditingController();
//     String selectedType = 'diagram';
//     String selectedSubject = 'General';
//     String selectedGrade = 'Elementary';

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return SahayakCard(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Visual Aid Request',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleLarge
//                       ?.copyWith(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: conceptController,
//                   decoration: const InputDecoration(
//                     labelText: 'Concept to Illustrate',
//                     hintText: 'e.g., Water cycle, Plant parts, Solar system',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedType,
//                         decoration: const InputDecoration(
//                           labelText: 'Visual Aid Type',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: [
//                           'diagram',
//                           'chart',
//                           'illustration',
//                           'flowchart',
//                           'map',
//                           'timeline'
//                         ]
//                             .map((type) => DropdownMenuItem(
//                                   value: type,
//                                   child: Text(type.capitalize()),
//                                 ))
//                             .toList(),
//                         onChanged: (value) =>
//                             setState(() => selectedType = value!),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedSubject,
//                         decoration: const InputDecoration(
//                           labelText: 'Subject',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: [
//                           'General',
//                           'Science',
//                           'Mathematics',
//                           'History',
//                           'Geography'
//                         ]
//                             .map((subject) => DropdownMenuItem(
//                                 value: subject, child: Text(subject)))
//                             .toList(),
//                         onChanged: (value) =>
//                             setState(() => selectedSubject = value!),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: selectedGrade,
//                   decoration: const InputDecoration(
//                     labelText: 'Grade Level',
//                     border: OutlineInputBorder(),
//                   ),
//                   items: ['Elementary', 'Middle', 'High School']
//                       .map((grade) =>
//                           DropdownMenuItem(value: grade, child: Text(grade)))
//                       .toList(),
//                   onChanged: (value) => setState(() => selectedGrade = value!),
//                 ),
//                 const SizedBox(height: 24),
//                 Consumer<AIAssistantProvider>(
//                   builder: (context, aiProvider, child) {
//                     return SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: conceptController.text.isEmpty ||
//                                 aiProvider.isLoading
//                             ? null
//                             : () => _generateVisualAid(
//                                   conceptController.text,
//                                   selectedType,
//                                   selectedSubject,
//                                   selectedGrade,
//                                 ),
//                         icon: aiProvider.isLoading
//                             ? const SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child:
//                                     CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : const Icon(Icons.draw),
//                         label: Text(aiProvider.isLoading
//                             ? 'Generating...'
//                             : 'Generate Visual Aid'),
//                         style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.all(16)),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildVisualAidResults() {
//     return Consumer<AIAssistantProvider>(
//       builder: (context, aiProvider, child) {
//         if (aiProvider.lastVisualAidResponse == null) {
//           return const SizedBox();
//         }

//         final response = aiProvider.lastVisualAidResponse!;

//         return SahayakCard(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.draw,
//                         color: Theme.of(context).colorScheme.primary),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         '${response.type.capitalize()}: ${response.concept}',
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleLarge
//                             ?.copyWith(fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context)
//                         .colorScheme
//                         .surfaceVariant
//                         .withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: Theme.of(context)
//                           .colorScheme
//                           .outline
//                           .withOpacity(0.3),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Drawing Instructions',
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleMedium
//                             ?.copyWith(fontWeight: FontWeight.w600),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(response.drawingInstructions),
//                     ],
//                   ),
//                 ),
//                 if (response.labels.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   Text(
//                     'Labels to Include',
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleMedium
//                         ?.copyWith(fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: response.labels
//                         .map((label) => Chip(
//                               label: Text(label),
//                               backgroundColor: Theme.of(context)
//                                   .colorScheme
//                                   .primaryContainer
//                                   .withOpacity(0.5),
//                             ))
//                         .toList(),
//                   ),
//                 ],
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Icon(Icons.access_time,
//                         size: 16,
//                         color: Theme.of(context)
//                             .colorScheme
//                             .onSurface
//                             .withOpacity(0.7)),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Estimated time: ${response.estimatedTime} minutes',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .onSurface
//                                 .withOpacity(0.7),
//                           ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Row(
//                 //   children: [
//                 //     TextButton.icon(
//                 //       onPressed: () =>
//                 //           _shareContent(response.drawingInstructions),
//                 //       icon: const Icon(Icons.share, size: 16),
//                 //       label: const Text('Share'),
//                 //     ),
//                 //     TextButton.icon(
//                 //       onPressed: () => _saveVisualAid(response),
//                 //       icon: const Icon(Icons.save, size: 16),
//                 //       label: const Text('Save'),
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Educational Games Tab
//   Widget _buildEducationalGamesTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Create Educational Games',
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineSmall
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Generate interactive games for classroom learning',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   color:
//                       Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//                 ),
//           ),
//           const SizedBox(height: 24),
//           _buildGameForm(),
//           const SizedBox(height: 24),
//           _buildGameResults(),
//         ],
//       ),
//     );
//   }

//   Widget _buildGameForm() {
//     final topicController = TextEditingController();
//     String selectedGameType = 'quiz';
//     String selectedSubject = 'General';
//     String selectedGrade = 'Elementary';
//     int duration = 15;

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return SahayakCard(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Game Request',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleLarge
//                       ?.copyWith(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: topicController,
//                   decoration: const InputDecoration(
//                     labelText: 'Topic',
//                     hintText:
//                         'e.g., Multiplication tables, Countries and capitals',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedGameType,
//                         decoration: const InputDecoration(
//                           labelText: 'Game Type',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: [
//                           'quiz',
//                           'memory',
//                           'puzzle',
//                           'activity',
//                           'role-play',
//                           'competition'
//                         ]
//                             .map((type) => DropdownMenuItem(
//                                   value: type,
//                                   child: Text(type.capitalize()),
//                                 ))
//                             .toList(),
//                         onChanged: (value) =>
//                             setState(() => selectedGameType = value!),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedSubject,
//                         decoration: const InputDecoration(
//                           labelText: 'Subject',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: [
//                           'General',
//                           'Mathematics',
//                           'Science',
//                           'English',
//                           'Social Studies'
//                         ]
//                             .map((subject) => DropdownMenuItem(
//                                 value: subject, child: Text(subject)))
//                             .toList(),
//                         onChanged: (value) =>
//                             setState(() => selectedSubject = value!),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedGrade,
//                         decoration: const InputDecoration(
//                           labelText: 'Grade Level',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: ['Elementary', 'Middle', 'High School']
//                             .map((grade) => DropdownMenuItem(
//                                 value: grade, child: Text(grade)))
//                             .toList(),
//                         onChanged: (value) =>
//                             setState(() => selectedGrade = value!),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: DropdownButtonFormField<int>(
//                         value: duration,
//                         decoration: const InputDecoration(
//                           labelText: 'Duration (minutes)',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: [10, 15, 20, 30, 45]
//                             .map((mins) => DropdownMenuItem(
//                                 value: mins, child: Text('$mins min')))
//                             .toList(),
//                         onChanged: (value) => setState(() => duration = value!),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 // Consumer<AIAssistantProvider>(
//                 //   builder: (context, aiProvider, child) {
//                 //     return SizedBox(
//                 //       width: double.infinity,
//                 //       child: ElevatedButton.icon(
//                 //         onPressed:
//                 //             topicController.text.isEmpty || aiProvider.isLoading
//                 //                 ? null
//                 //                 : () => _generateGame(
//                 //                       topicController.text,
//                 //                       selectedGameType,
//                 //                       selectedSubject,
//                 //                       selectedGrade,
//                 //                       duration,
//                 //                     ),
//                 //         icon: aiProvider.isLoading
//                 //             ? const SizedBox(
//                 //                 width: 16,
//                 //                 height: 16,
//                 //                 child:
//                 //                     CircularProgressIndicator(strokeWidth: 2),
//                 //               )
//                 //             : const Icon(Icons.games),
//                 //         label: Text(aiProvider.isLoading
//                 //             ? 'Generating...'
//                 //             : 'Generate Game'),
//                 //         style: ElevatedButton.styleFrom(
//                 //             padding: const EdgeInsets.all(16)),
//                 //       ),
//                 //     );
//                 //   },
//                 // ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGameResults() {
//     return Consumer<AIAssistantProvider>(
//       builder: (context, aiProvider, child) {
//         if (aiProvider.lastGameResponse == null) {
//           return const SizedBox();
//         }

//         final response = aiProvider.lastGameResponse!;

//         return SahayakCard(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.games,
//                         color: Theme.of(context).colorScheme.primary),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         response.title,
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleLarge
//                             ?.copyWith(fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 if (response.rules.isNotEmpty) ...[
//                   Text(
//                     'Game Rules',
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleMedium
//                         ?.copyWith(fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context)
//                           .colorScheme
//                           .primaryContainer
//                           .withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(response.rules),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//                 Text(
//                   'Instructions',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleMedium
//                       ?.copyWith(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(response.instructions),
//                 if (response.materials.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   Text(
//                     'Materials Needed',
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleMedium
//                         ?.copyWith(fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: response.materials
//                         .map((material) => Chip(
//                               label: Text(material),
//                               backgroundColor: Theme.of(context)
//                                   .colorScheme
//                                   .secondaryContainer
//                                   .withOpacity(0.5),
//                             ))
//                         .toList(),
//                   ),
//                 ],
//                 if (response.learningObjectives.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   ExpansionTile(
//                     title: const Text('Learning Objectives'),
//                     leading: const Icon(Icons.flag),
//                     children: response.learningObjectives
//                         .map((objective) => ListTile(
//                               leading: const Icon(Icons.check_circle_outline,
//                                   size: 16),
//                               title: Text(objective),
//                               dense: true,
//                             ))
//                         .toList(),
//                   ),
//                 ],
//                 if (response.variations.isNotEmpty) ...[
//                   ExpansionTile(
//                     title: const Text('Game Variations'),
//                     leading: const Icon(Icons.shuffle),
//                     children: response.variations
//                         .map((variation) => ListTile(
//                               leading:
//                                   const Icon(Icons.lightbulb_outline, size: 16),
//                               title: Text(variation),
//                               dense: true,
//                             ))
//                         .toList(),
//                   ),
//                 ],
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Icon(Icons.timer,
//                         size: 16,
//                         color: Theme.of(context)
//                             .colorScheme
//                             .onSurface
//                             .withOpacity(0.7)),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Duration: ${response.duration} minutes',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .onSurface
//                                 .withOpacity(0.7),
//                           ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Row(
//                 //   children: [
//                 //     TextButton.icon(
//                 //       onPressed: () => _shareContent(response.instructions),
//                 //       icon: const Icon(Icons.share, size: 16),
//                 //       label: const Text('Share'),
//                 //     ),
//                 //     TextButton.icon(
//                 //       onPressed: () => _saveGame(response),
//                 //       icon: const Icon(Icons.save, size: 16),
//                 //       label: const Text('Save'),
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Reading Assessment Tab
//   Widget _buildReadingAssessmentTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Reading Assessment',
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineSmall
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Assess student reading with voice recording',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   color:
//                       Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//                 ),
//           ),
//           const SizedBox(height: 24),
//           _buildReadingTextInput(),
//           const SizedBox(height: 24),
//           // _buildRecordingSection(),
//           const SizedBox(height: 24),
//           _buildReadingAssessmentResults(),
//         ],
//       ),
//     );
//   }

//   Widget _buildReadingTextInput() {
//     return SahayakCard(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Reading Text',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge
//                   ?.copyWith(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _readingTextController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter text for the student to read',
//                 hintText: 'The quick brown fox jumps over the lazy dog...',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 5,
//             ),
//             const SizedBox(height: 16),
//             // Row(
//             //   children: [
//             //     TextButton.icon(
//             //       onPressed: () => _loadSampleText(),
//             //       icon: const Icon(Icons.library_books, size: 16),
//             //       label: const Text('Load Sample'),
//             //     ),
//             //     TextButton.icon(
//             //       onPressed: () => _uploadTextFile(),
//             //       icon: const Icon(Icons.upload_file, size: 16),
//             //       label: const Text('Upload File'),
//             //     ),
//             //   ],
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildRecordingSection() {
//   //   return SahayakCard(
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(20),
//   //       child: Column(
//   //         children: [
//   //           Icon(
//   //             _isRecording ? Icons.mic : Icons.mic_none,
//   //             size: 64,
//   //             color: _isRecording
//   //                 ? Colors.red
//   //                 : Theme.of(context).colorScheme.primary,
//   //           ),
//   //           const SizedBox(height: 16),
//   //           Text(
//   //             _isRecording ? 'Recording...' : 'Ready to Record',
//   //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//   //                   fontWeight: FontWeight.w600,
//   //                   color: _isRecording ? Colors.red : null,
//   //                 ),
//   //           ),
//   //           const SizedBox(height: 24),
//   //           Row(
//   //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   //             children: [
//   //               ElevatedButton.icon(
//   //                 onPressed: _isRecording ? _stopRecording : _startRecording,
//   //                 icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
//   //                 label: Text(_isRecording ? 'Stop' : 'Start Recording'),
//   //                 style: ElevatedButton.styleFrom(
//   //                   backgroundColor: _isRecording ? Colors.red : null,
//   //                   foregroundColor: _isRecording ? Colors.white : null,
//   //                 ),
//   //               ),
//   //               if (_recordingPath != null)
//   //                 ElevatedButton.icon(
//   //                   onPressed: _playRecording,
//   //                   icon: const Icon(Icons.play_circle_outline),
//   //                   label: const Text('Play'),
//   //                 ),
//   //             ],
//   //           ),
//   //           if (_recordingPath != null) ...[
//   //             const SizedBox(height: 16),
//   //             Consumer<AIAssistantProvider>(
//   //               builder: (context, aiProvider, child) {
//   //                 return SizedBox(
//   //                   width: double.infinity,
//   //                   child: ElevatedButton.icon(
//   //                     onPressed: aiProvider.isLoading ? null : _assessReading,
//   //                     icon: aiProvider.isLoading
//   //                         ? const SizedBox(
//   //                             width: 16,
//   //                             height: 16,
//   //                             child: CircularProgressIndicator(strokeWidth: 2),
//   //                           )
//   //                         : const Icon(Icons.assessment),
//   //                     label: Text(aiProvider.isLoading
//   //                         ? 'Assessing...'
//   //                         : 'Assess Reading'),
//   //                   ),
//   //                 );
//   //               },
//   //             ),
//   //           ],
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   Widget _buildReadingAssessmentResults() {
//     return Consumer<AIAssistantProvider>(
//       builder: (context, aiProvider, child) {
//         if (aiProvider.lastReadingAssessment == null) {
//           return const SizedBox();
//         }

//         final assessment = aiProvider.lastReadingAssessment!;

//         return SahayakCard(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.assessment,
//                         color: Theme.of(context).colorScheme.primary),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Reading Assessment Results',
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleLarge
//                           ?.copyWith(fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Row(
//                 //   children: [
//                 //     Expanded(
//                 //       child: _buildScoreCard(
//                 //         'Accuracy',
//                 //         '${assessment.accuracyPercentage.toStringAsFixed(1)}%',
//                 //         Icons.check_circle,
//                 //         _getScoreColor(assessment.accuracyPercentage),
//                 //       ),
//                 //     ),
//                 //     const SizedBox(width: 12),
//                 //     // Expanded(
//                 //     //   child: _buildScoreCard(
//                 //     //     'Fluency',
//                 //     //     '${assessment.fluencyRating}/5',
//                 //     //     Icons.speed,
//                 //     //     _getScoreColor(assessment.fluencyRating * 20),
//                 //     //   ),
//                 //     // ),
//                 //   ],
//                 // ),

//                 // const SizedBox(height: 16),
//                 Text(
//                   'Transcription',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleMedium
//                       ?.copyWith(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context)
//                         .colorScheme
//                         .surfaceVariant
//                         .withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(assessment.actualTranscription),
//                 ),
//                 if (assessment.pronunciationErrors.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   ExpansionTile(
//                     title: const Text('Pronunciation Issues'),
//                     leading: const Icon(Icons.warning_amber),
//                     children: assessment.pronunciationErrors
//                         .map((error) => ListTile(
//                               leading:
//                                   const Icon(Icons.error_outline, size: 16),
//                               title: Text(error),
//                               dense: true,
//                             ))
//                         .toList(),
//                   ),
//                 ],
//                 const SizedBox(height: 16),
//                 Text(
//                   'Feedback',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleMedium
//                       ?.copyWith(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context)
//                         .colorScheme
//                         .primaryContainer
//                         .withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(assessment.feedback),
//                 ),
//                 if (assessment.suggestions.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   ExpansionTile(
//                     title: const Text('Improvement Suggestions'),
//                     leading: const Icon(Icons.lightbulb_outline),
//                     children: assessment.suggestions
//                         .map((suggestion) => ListTile(
//                               leading: const Icon(Icons.arrow_right, size: 16),
//                               title: Text(suggestion),
//                               dense: true,
//                             ))
//                         .toList(),
//                   ),
//                 ],
//                 const SizedBox(height: 16),
//                 // Row(
//                 //   children: [
//                 //     TextButton.icon(
//                 //       onPressed: () => _shareAssessment(assessment),
//                 //       icon: const Icon(Icons.share, size: 16),
//                 //       label: const Text('Share'),
//                 //     ),
//                 //     TextButton.icon(
//                 //       onPressed: () => _saveAssessment(assessment),
//                 //       icon: const Icon(Icons.save, size: 16),
//                 //       label: const Text('Save'),
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildScoreCard(
//       String title, String score, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 32),
//           const SizedBox(height: 8),
//           Text(
//             score,
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   color: color,
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           Text(
//             title,
//             style:
//                 Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Methods
//   void _sendMessage() {
//     if (_chatController.text.trim().isEmpty) return;

//     final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
//     aiProvider.explainConcept(
//       question: _chatController.text.trim(),
//       language: 'English',
//       gradeLevel: 'Elementary',
//     );

//     _chatController.clear();
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_chatScrollController.hasClients) {
//         _chatScrollController.animateTo(
//           _chatScrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   void _applySuggestion(AISuggestion suggestion) {
//     _chatController.text = suggestion.title;
//     _sendMessage();
//   }

//   void _generateLocalContent(
//     String prompt,
//     String language,
//     String culturalContext,
//     String subject,
//     String gradeLevel,
//   ) {
//     final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
//     aiProvider.generateLocalContent(
//       prompt: prompt,
//       language: language,
//       culturalContext: culturalContext,
//       subject: subject,
//       gradeLevel: gradeLevel,
//     );
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(source: source);

//       if (image != null) {
//         setState(() {
//           _selectedImage = File(image.path);
//         });
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//     }
//   }

//   Widget _generateVisualAid(String text, String selectedType,
//       String selectedSubject, String selectedGrade) {
//     return const SizedBox();
//   }
// }
// screens/ai_assistant/ai_assistant_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/data/services/ai_teaching_assistant_service.dart';
import 'package:myapp/presentation/widgets/sahayakCard.dart';
import 'package:provider/provider.dart';

import '../../providers/ai_assistant_provider.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  File? _selectedImage;
  final TextEditingController _readingTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _readingTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('AI Teaching Assistant'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
                text: 'Ask AI',
                icon: Icon(Icons.chat_bubble_outline, size: 20)),
            Tab(text: 'Local Content', icon: Icon(Icons.language, size: 20)),
            Tab(text: 'Materials', icon: Icon(Icons.layers, size: 20)),
            Tab(text: 'Visual Aids', icon: Icon(Icons.draw, size: 20)),
            Tab(text: 'Games', icon: Icon(Icons.games, size: 20)),
            Tab(
                text: 'Reading Test',
                icon: Icon(Icons.record_voice_over, size: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Implement history view
            },
            tooltip: 'History',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement menu actions
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: 'clear_history', child: Text('Clear History')),
              PopupMenuItem(
                  value: 'export_content', child: Text('Export Content')),
              PopupMenuItem(value: 'settings', child: Text('AI Settings')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKnowledgeBaseTab(),
          _buildLocalContentTab(),
          _buildDifferentiatedMaterialsTab(),
          _buildVisualAidsTab(),
          _buildEducationalGamesTab(),
          _buildReadingAssessmentTab(),
        ],
      ),
    );
  }

  // ------------------------------ Knowledge Base Tab ------------------------------
  Widget _buildKnowledgeBaseTab() {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        return Column(
          children: [
            Expanded(
              child: aiProvider.chatHistory.isEmpty
                  ? _buildEmptyChatState()
                  : ListView.builder(
                      controller: _chatScrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: aiProvider.chatHistory.length,
                      itemBuilder: (context, index) {
                        final message = aiProvider.chatHistory[index];
                        return _buildChatMessage(message);
                      },
                    ),
            ),
            _buildChatInput(aiProvider),
          ],
        );
      },
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Ask me anything!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'I can explain concepts, answer questions,\nand provide teaching suggestions',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickQuestion('Why is the sky blue?'),
              _buildQuickQuestion('How do plants grow?'),
              _buildQuickQuestion('What is gravity?'),
              _buildQuickQuestion('Explain photosynthesis'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestion(String question) {
    return ActionChip(
      label: Text(question),
      onPressed: () {
        _chatController.text = question;
        _sendMessage();
      },
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.smart_toy,
                  size: 16, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primaryContainer
                    : message.isError
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: message.isError
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : null,
                        ),
                  ),
                  if (message.knowledgeResponse != null) ...[
                    const SizedBox(height: 12),
                    _buildKnowledgeExtras(message.knowledgeResponse!),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKnowledgeExtras(KnowledgeResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (response.analogy.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Think of it this way:',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(response.analogy),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (response.keyPoints.isNotEmpty) ...[
          ExpansionTile(
            title: const Text('Key Points'),
            leading: const Icon(Icons.key),
            children: response.keyPoints
                .map((point) => ListTile(
                      leading: const Icon(Icons.arrow_right, size: 16),
                      title: Text(point),
                      dense: true,
                    ))
                .toList(),
          ),
        ],
        if (response.funFacts.isNotEmpty) ...[
          ExpansionTile(
            title: const Text('Fun Facts'),
            leading: const Icon(Icons.star),
            children: response.funFacts
                .map((fact) => ListTile(
                      leading: const Icon(Icons.star_border, size: 16),
                      title: Text(fact),
                      dense: true,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildChatInput(AIAssistantProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: aiProvider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: aiProvider.isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    aiProvider.explainConcept(
      question: _chatController.text.trim(),
      language: 'English',
      gradeLevel: 'Elementary',
    );
    _chatController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _applySuggestion(AISuggestion suggestion) {
    _chatController.text = suggestion.title;
    _sendMessage();
  }

  // ------------------------------ Local Content Tab ------------------------------

  Widget _buildLocalContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate Hyper-Local Content',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create culturally relevant content in your local language',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          _buildLocalContentForm(),
        ],
      ),
    );
  }

  Widget _buildLocalContentForm() {
    final promptController = TextEditingController();
    final culturalContextController = TextEditingController();

    String selectedLanguage = 'English';
    String selectedSubject = 'General';
    String selectedGrade = 'Mixed';

    return StatefulBuilder(builder: (context, setState) {
      return SahayakCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content Request',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: promptController,
                decoration: const InputDecoration(
                  labelText: 'What would you like me to create?',
                  hintText:
                      'e.g., Create a story about farmers to explain different soil types',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Language',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'English',
                        'Hindi',
                        'Kannada',
                        'Marathi',
                        'Tamil',
                        'Telugu',
                        'Bengali',
                        'Gujarati',
                      ]
                          .map((lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedLanguage = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'General',
                        'Mathematics',
                        'Science',
                        'English',
                        'Social Studies',
                        'Arts',
                      ]
                          .map((subject) => DropdownMenuItem(
                              value: subject, child: Text(subject)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedSubject = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedGrade,
                      decoration: const InputDecoration(
                        labelText: 'Grade Level',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Mixed', '1-3', '4-6', '7-9', '10-12']
                          .map((grade) => DropdownMenuItem(
                              value: grade, child: Text(grade)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedGrade = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: culturalContextController,
                decoration: const InputDecoration(
                  labelText: 'Cultural Context',
                  hintText: 'e.g., Rural farming community in Maharashtra',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Consumer<AIAssistantProvider>(
                builder: (context, aiProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: aiProvider.isLoading
                          ? null
                          : () => aiProvider.generateLocalContent(
                                prompt: promptController.text,
                                language: selectedLanguage,
                                culturalContext: culturalContextController.text,
                                subject: selectedSubject,
                                gradeLevel: selectedGrade,
                              ),
                      icon: aiProvider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(aiProvider.isLoading
                          ? 'Generating...'
                          : 'Generate Content'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Consumer<AIAssistantProvider>(
                builder: (context, aiProvider, child) {
                  if (aiProvider.lastContentResponse == null) {
                    return const SizedBox();
                  }
                  final content = aiProvider.lastContentResponse!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Generated Content',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.language,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                '${content.language} • ${content.subject}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ]),
                            const SizedBox(height: 12),
                            Text(content.content),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  // ------------------------------ Differentiated Materials Tab ------------------------------

  Widget _buildDifferentiatedMaterialsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Differentiated Materials',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a textbook page to create grade-specific worksheets',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          _buildImageUploadSection(),
          const SizedBox(height: 24),
          _buildGradeSelectionSection(),
          const SizedBox(height: 24),
          _buildDifferentiatedMaterialsResults(),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return SahayakCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Icon(Icons.cloud_upload_outlined,
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Upload Textbook Page',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo or select an image from gallery',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final List<String> _selectedGrades = ['4', '5', '6'];

  Widget _buildGradeSelectionSection() {
    return StatefulBuilder(
      builder: (context, setState) {
        return SahayakCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Grade Levels',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(12, (index) {
                    final grade = (index + 1).toString();
                    final isSelected = _selectedGrades.contains(grade);
                    return FilterChip(
                      label: Text('Grade $grade'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (!_selectedGrades.contains(grade)) {
                              _selectedGrades.add(grade);
                            }
                          } else {
                            _selectedGrades.remove(grade);
                          }
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Consumer<AIAssistantProvider>(
                  builder: (context, aiProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _selectedImage == null ||
                                _selectedGrades.isEmpty ||
                                aiProvider.isLoading
                            ? null
                            : () {
                                final bytes = _selectedImage!.readAsBytesSync();
                                aiProvider.createDifferentiatedMaterials(
                                  imageBytes: bytes,
                                  targetGrades: _selectedGrades,
                                );
                              },
                        icon: aiProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              )
                            : const Icon(Icons.add),
                        label: const Text('Create Differentiated Materials'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifferentiatedMaterialsResults() {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        final response = aiProvider.lastMaterialsResponse;
        if (response == null) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generated Materials',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...response.materials.map(_buildGradeMaterial),
          ],
        );
      },
    );
  }

  Widget _buildGradeMaterial(GradeLevelMaterial material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SahayakCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Grade ${material.gradeLevel}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // TODO: implement material share/save/print
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'share', child: Text('Share')),
                      PopupMenuItem(value: 'save', child: Text('Save')),
                      PopupMenuItem(value: 'print', child: Text('Print')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(material.content,
                  style: Theme.of(context).textTheme.bodyMedium),
              if (material.activities.isNotEmpty) ...[
                const SizedBox(height: 12),
                ExpansionTile(
                  title: const Text('Activities'),
                  leading: const Icon(Icons.assignment),
                  children: material.activities
                      .map(
                        (activity) => ListTile(
                          leading:
                              const Icon(Icons.play_circle_outline, size: 16),
                          title: Text(activity),
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      // Handle errors e.g. show snackbar or toast
      debugPrint('Error picking image: $e');
    }
  }

  // ------------------------------ Visual Aids Tab ------------------------------
  Widget _buildVisualAidsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate Visual Aids',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create drawing instructions for blackboard diagrams',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          _buildVisualAidForm(),
          const SizedBox(height: 24),
          _buildVisualAidResults(),
        ],
      ),
    );
  }

  Widget _buildVisualAidForm() {
    final conceptController = TextEditingController();
    String selectedType = 'diagram';
    String selectedSubject = 'General';
    String selectedGrade = 'Elementary';

    return StatefulBuilder(builder: (context, setState) {
      return SahayakCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visual Aid Request',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: conceptController,
                decoration: const InputDecoration(
                  labelText: 'Concept to Illustrate',
                  hintText: 'e.g., Water cycle, Plant parts, Solar system',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Visual Aid Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'diagram',
                        'chart',
                        'illustration',
                        'flowchart',
                        'map',
                        'timeline'
                      ]
                          .map((type) => DropdownMenuItem(
                              value: type, child: Text(type.capitalize())))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedType = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'General',
                        'Science',
                        'Mathematics',
                        'History',
                        'Geography',
                      ]
                          .map((subject) => DropdownMenuItem(
                              value: subject, child: Text(subject)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedSubject = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGrade,
                decoration: const InputDecoration(
                  labelText: 'Grade Level',
                  border: OutlineInputBorder(),
                ),
                items: ['Elementary', 'Middle', 'High School']
                    .map((grade) =>
                        DropdownMenuItem(value: grade, child: Text(grade)))
                    .toList(),
                onChanged: (value) => setState(() => selectedGrade = value!),
              ),
              const SizedBox(height: 24),
              Consumer<AIAssistantProvider>(
                builder: (context, aiProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          conceptController.text.isEmpty || aiProvider.isLoading
                              ? null
                              : () => aiProvider.generateVisualAid(
                                    concept: conceptController.text,
                                    type: selectedType,
                                    subject: selectedSubject,
                                    gradeLevel: selectedGrade,
                                  ),
                      icon: aiProvider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.draw),
                      label: Text(aiProvider.isLoading
                          ? 'Generating...'
                          : 'Generate Visual Aid'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVisualAidResults() {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        final response = aiProvider.lastVisualAidResponse;
        if (response == null) return const SizedBox();

        return SahayakCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.draw,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${response.type.capitalize()}: ${response.concept}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drawing Instructions',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(response.drawingInstructions),
                    ],
                  ),
                ),
                if (response.labels.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Labels to Include',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: response.labels
                        .map(
                          (label) => Chip(
                            label: Text(label),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.5),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      'Estimated time: ${response.estimatedTime} minutes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------ Educational Games Tab ------------------------------
  Widget _buildEducationalGamesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Educational Games',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate interactive games for classroom learning',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          _buildGameForm(),
          const SizedBox(height: 24),
          _buildGameResults(),
        ],
      ),
    );
  }

  Widget _buildGameForm() {
    final topicController = TextEditingController();
    String selectedGameType = 'quiz';
    String selectedSubject = 'General';
    String selectedGrade = 'Elementary';
    int duration = 15;

    return StatefulBuilder(builder: (context, setState) {
      return SahayakCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Game Request',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  hintText:
                      'e.g., Multiplication tables, Countries and capitals',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedGameType,
                      decoration: const InputDecoration(
                        labelText: 'Game Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'quiz',
                        'memory',
                        'puzzle',
                        'activity',
                        'role-play',
                        'competition',
                      ]
                          .map((type) => DropdownMenuItem(
                              value: type, child: Text(type.capitalize())))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedGameType = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'General',
                        'Mathematics',
                        'Science',
                        'English',
                        'Social Studies',
                      ]
                          .map((subject) => DropdownMenuItem(
                              value: subject, child: Text(subject)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedSubject = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedGrade,
                      decoration: const InputDecoration(
                        labelText: 'Grade Level',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Elementary', 'Middle', 'High School']
                          .map((grade) => DropdownMenuItem(
                              value: grade, child: Text(grade)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedGrade = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: duration,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      items: [10, 15, 20, 30, 45]
                          .map((mins) => DropdownMenuItem(
                              value: mins, child: Text('$mins min')))
                          .toList(),
                      onChanged: (value) => setState(() => duration = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<AIAssistantProvider>(
                builder: (context, aiProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          topicController.text.isEmpty || aiProvider.isLoading
                              ? null
                              : () => aiProvider.generateGame(
                                    topic: topicController.text,
                                    gameType: selectedGameType,
                                    subject: selectedSubject,
                                    gradeLevel: selectedGrade,
                                    duration: duration,
                                  ),
                      icon: aiProvider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.games),
                      label: Text(aiProvider.isLoading
                          ? 'Generating...'
                          : 'Generate Game'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGameResults() {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        final response = aiProvider.lastGameResponse;
        if (response == null) return const SizedBox();

        return SahayakCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.games,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        response.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (response.rules.isNotEmpty) ...[
                  Text(
                    'Game Rules',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(response.rules),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Instructions',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(response.instructions),
                if (response.materials.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Materials Needed',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: response.materials
                        .map(
                          (material) => Chip(
                            label: Text(material),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withOpacity(0.5),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (response.learningObjectives.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Learning Objectives'),
                    leading: const Icon(Icons.flag),
                    children: response.learningObjectives
                        .map(
                          (objective) => ListTile(
                            leading: const Icon(Icons.check_circle_outline,
                                size: 16),
                            title: Text(objective),
                            dense: true,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (response.variations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Game Variations'),
                    leading: const Icon(Icons.shuffle),
                    children: response.variations
                        .map(
                          (variation) => ListTile(
                            leading:
                                const Icon(Icons.lightbulb_outline, size: 16),
                            title: Text(variation),
                            dense: true,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.timer,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      'Duration: ${response.duration} minutes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------ Reading Assessment Tab ------------------------------

  Widget _buildReadingAssessmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading Assessment',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Assess student reading with voice recording',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          _buildReadingTextInput(),
          const SizedBox(height: 24),
          // TODO: Implement recording section
          // _buildRecordingSection(),
          const SizedBox(height: 24),
          _buildReadingAssessmentResults(),
        ],
      ),
    );
  }

  Widget _buildReadingTextInput() {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Text',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _readingTextController,
              decoration: const InputDecoration(
                labelText: 'Enter text for the student to read',
                hintText: 'The quick brown fox jumps over the lazy dog...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingAssessmentResults() {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        final assessment = aiProvider.lastReadingAssessment;
        if (assessment == null) return const SizedBox();

        Color getScoreColor(double score) {
          if (score >= 80) return Colors.green;
          if (score >= 50) return Colors.orange;
          return Colors.red;
        }

        return SahayakCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assessment,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Reading Assessment Results',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Transcription',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(assessment.actualTranscription),
                ),
                if (assessment.pronunciationErrors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Pronunciation Issues'),
                    leading: const Icon(Icons.warning_amber),
                    children: assessment.pronunciationErrors
                        .map(
                          (error) => ListTile(
                            leading: const Icon(Icons.error_outline, size: 16),
                            title: Text(error),
                            dense: true,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Feedback',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(assessment.feedback),
                ),
                if (assessment.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Improvement Suggestions'),
                    leading: const Icon(Icons.lightbulb_outline),
                    children: assessment.suggestions
                        .map(
                          (suggestion) => ListTile(
                            leading: const Icon(Icons.arrow_right, size: 16),
                            title: Text(suggestion),
                            dense: true,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

// String extension for capitalize
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
