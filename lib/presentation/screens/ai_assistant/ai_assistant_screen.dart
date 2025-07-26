import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


import 'package:myapp/data/models/aiModels/ai_models.dart';
import 'package:myapp/presentation/widgets/shayakCard.dart';

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

  // Form controllers for various tabs
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _culturalContextController =
      TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  // Selected values for dropdowns
  String _selectedLanguage = 'English';
  String _selectedSubject = 'General';
  String _selectedGrade = 'Elementary';
  String _selectedVisualType = 'diagram';
  String _selectedGameType = 'quiz';
  int _selectedDuration = 15;
  List<String> _selectedGrades = ['4', '5', '6'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AIAssistantProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _readingTextController.dispose();
    _promptController.dispose();
    _culturalContextController.dispose();
    _conceptController.dispose();
    _topicController.dispose();
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
            onPressed: () => _showHistoryDialog(),
            tooltip: 'History',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
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

  // Menu and dialog handlers
  void _handleMenuAction(String action) async {
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);

    switch (action) {
      case 'clear_history':
        _showClearHistoryDialog();
        break;
      case 'export_content':
        final data = aiProvider.exportData();
        _showSnackBar('Export functionality would be implemented here');
        break;
      case 'settings':
        _showSnackBar('Settings would be implemented here');
        break;
    }
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to clear all history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AIAssistantProvider>(context, listen: false)
                  .clearHistory();
              Navigator.pop(context);
              _showSnackBar('History cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              AppBar(
                title: const Text('History'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: Consumer<AIAssistantProvider>(
                  builder: (context, aiProvider, child) {
                    if (aiProvider.history.isEmpty) {
                      return const Center(child: Text('No history items yet'));
                    }

                    return ListView.builder(
                      itemCount: aiProvider.history.length,
                      itemBuilder: (context, index) {
                        final item = aiProvider.history[index];
                        return _buildHistoryItem(item, aiProvider);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(HistoryItem item, AIAssistantProvider provider) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: _getHistoryIcon(item.type),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              _formatDateTime(item.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleHistoryAction(value, item, provider),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'share', child: Text('Share')),
            PopupMenuItem(value: 'copy', child: Text('Copy')),
            PopupMenuItem(value: 'download', child: Text('Download PDF')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => _showHistoryDetails(item),
      ),
    );
  }

  Icon _getHistoryIcon(HistoryItemType type) {
    switch (type) {
      case HistoryItemType.localContent:
        return const Icon(Icons.language);
      case HistoryItemType.materials:
        return const Icon(Icons.layers);
      case HistoryItemType.knowledge:
        return const Icon(Icons.lightbulb);
      case HistoryItemType.visualAid:
        return const Icon(Icons.draw);
      case HistoryItemType.game:
        return const Icon(Icons.games);
      case HistoryItemType.readingAssessment:
        return const Icon(Icons.record_voice_over);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleHistoryAction(
      String action, HistoryItem item, AIAssistantProvider provider) async {
    switch (action) {
      case 'share':
        await _shareHistoryItem(item, provider);
        break;
      case 'copy':
        await _copyHistoryItem(item, provider);
        break;
      case 'download':
        await _downloadHistoryItem(item, provider);
        break;
      case 'delete':
        provider.deleteHistoryItem(item.id);
        _showSnackBar('Item deleted');
        break;
    }
  }

  Future<void> _shareHistoryItem(
      HistoryItem item, AIAssistantProvider provider) async {
    String content = item.data['content'] ??
        item.data['explanation'] ??
        'Content not available';
    // Implement actual sharing here
    _showSnackBar('Sharing functionality would be implemented here');
  }

  Future<void> _copyHistoryItem(
      HistoryItem item, AIAssistantProvider provider) async {
    String content = item.data['content'] ??
        item.data['explanation'] ??
        'Content not available';
    await Clipboard.setData(ClipboardData(text: '${item.title}\n\n$content'));
    _showSnackBar('Copied to clipboard');
  }

  Future<void> _downloadHistoryItem(
      HistoryItem item, AIAssistantProvider provider) async {
    _showSnackBar('PDF download functionality would be implemented here');
  }

  void _showHistoryDetails(HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getHistoryIcon(item.type),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    item.data['content'] ??
                        item.data['explanation'] ??
                        'Content not available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _shareHistoryItem(
                        item,
                        Provider.of<AIAssistantProvider>(context,
                            listen: false)),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _copyHistoryItem(
                        item,
                        Provider.of<AIAssistantProvider>(context,
                            listen: false)),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _downloadHistoryItem(
                        item,
                        Provider.of<AIAssistantProvider>(context,
                            listen: false)),
                    icon: const Icon(Icons.download),
                    label: const Text('PDF'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                        return _buildChatMessage(message, aiProvider);
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

  Widget _buildChatMessage(ChatMessage message, AIAssistantProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
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
                        : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.content,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: message.isError
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer
                                        : null,
                                  ),
                        ),
                      ),
                      if (!message.isUser && !message.isError) ...[
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 20),
                          onPressed: () {
                            _showSnackBar(
                                'Text-to-speech would be implemented here');
                          },
                          tooltip: 'Listen',
                        ),
                      ],
                    ],
                  ),
                  if (message.knowledgeResponse != null) ...[
                    const SizedBox(height: 12),
                    _buildKnowledgeExtras(message.knowledgeResponse!),
                  ],
                  if (!message.isUser && !message.isError) ...[
                    const SizedBox(height: 8),
                    _buildMessageActions(message),
                  ],
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

  Widget _buildMessageActions(ChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.favorite_border, size: 16),
          onPressed: () {
            _showSnackBar('Like functionality would be implemented here');
          },
          tooltip: 'Like',
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 16),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: message.content));
            _showSnackBar('Copied to clipboard');
          },
          tooltip: 'Copy',
        ),
        IconButton(
          icon: const Icon(Icons.share, size: 16),
          onPressed: () {
            _showSnackBar('Share functionality would be implemented here');
          },
          tooltip: 'Share',
        ),
        IconButton(
          icon: const Icon(Icons.download, size: 16),
          onPressed: () {
            _showSnackBar('PDF download would be implemented here');
          },
          tooltip: 'Download PDF',
        ),
      ],
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
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Think of it this way:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 16),
                      onPressed: () {
                        _showSnackBar(
                            'Text-to-speech would be implemented here');
                      },
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
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up, size: 16),
                        onPressed: () {
                          _showSnackBar(
                              'Text-to-speech would be implemented here');
                        },
                      ),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up, size: 16),
                        onPressed: () {
                          _showSnackBar(
                              'Text-to-speech would be implemented here');
                        },
                      ),
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
                          strokeWidth: 2, color: Colors.white),
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
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          _buildLocalContentForm(),
          const SizedBox(height: 24),
          Consumer<AIAssistantProvider>(
            builder: (context, aiProvider, child) {
              if (aiProvider.lastContentResponse == null) {
                return const SizedBox();
              }
              return _buildLocalContentResults(aiProvider.lastContentResponse!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocalContentForm() {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Content Request',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'What would you like me to create?',
                hintText:
                    'e.g., Create a story about farmers to explain different soil types',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.translate),
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
                      'Odia',
                      'Punjabi',
                    ]
                        .map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedLanguage = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.subject),
                    ),
                    items: [
                      'General',
                      'Mathematics',
                      'Science',
                      'English',
                      'Social Studies',
                      'Arts',
                      'Physical Education',
                      'Environmental Studies',
                    ]
                        .map((subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSubject = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(
                      labelText: 'Grade Level',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: ['Elementary', 'Middle', 'High School']
                        .map((grade) => DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedGrade = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _culturalContextController,
              decoration: const InputDecoration(
                labelText: 'Cultural Context',
                hintText: 'e.g., Rural farming community in Maharashtra',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Consumer<AIAssistantProvider>(
              builder: (context, aiProvider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: aiProvider.isLoading ||
                            _promptController.text.trim().isEmpty
                        ? null
                        : () => aiProvider.generateLocalContent(
                              prompt: _promptController.text,
                              language: _selectedLanguage,
                              culturalContext: _culturalContextController.text,
                              subject: _selectedSubject,
                              gradeLevel: _selectedGrade,
                            ),
                    icon: aiProvider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      aiProvider.isLoading
                          ? 'Generating...'
                          : 'Generate Content',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalContentResults(AIContentResponse content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Generated Content',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            _buildContentActionButtons(content),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      content.language,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      content.subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (content.culturallyAdapted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Culturally Adapted',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildContentActionRow(content),
      ],
    );
  }

  Widget _buildContentActionButtons(dynamic content) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up, size: 20),
          onPressed: () {
            _showSnackBar('Text-to-speech would be implemented here');
          },
          tooltip: 'Listen',
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleContentAction(value, content),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'copy',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'download',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Download PDF'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'save',
              child: ListTile(
                leading: Icon(Icons.bookmark),
                title: Text('Save'),
                dense: true,
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildContentActionRow(dynamic content) {
    return Row(
      children: [
        IconButton.filled(
          onPressed: () =>
              _showSnackBar('Like functionality would be implemented here'),
          icon: const Icon(Icons.favorite_border),
          tooltip: 'Like',
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _handleContentAction('share', content),
          icon: const Icon(Icons.share, size: 16),
          label: const Text('Share'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _handleContentAction('copy', content),
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copy'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _handleContentAction('download', content),
          icon: const Icon(Icons.download, size: 16),
          label: const Text('PDF'),
        ),
      ],
    );
  }

  Future<void> _handleContentAction(String action, dynamic content) async {
    switch (action) {
      case 'share':
        _showSnackBar('Share functionality would be implemented here');
        break;
      case 'copy':
        String contentText = '';
        if (content is AIContentResponse) {
          contentText = content.content;
        } else if (content is VisualAidResponse) {
          contentText = content.drawingInstructions;
        }
        await Clipboard.setData(ClipboardData(text: contentText));
        _showSnackBar('Copied to clipboard');
        break;
      case 'download':
        _showSnackBar('PDF download would be implemented here');
        break;
      case 'save':
        _showSnackBar('Save functionality would be implemented here');
        break;
    }
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
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
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
            Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
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

  Widget _buildGradeSelectionSection() {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Target Grade Levels',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
            Row(
              children: [
                Icon(
                  Icons.layers,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Generated Materials',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...response.materials
                .map((material) => _buildGradeMaterial(material))
                .toList(),
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
                  _buildContentActionButtons(material),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                material.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
              const SizedBox(height: 12),
              _buildContentActionRow(material),
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
      _showSnackBar('Error picking image: $e');
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
            'Create drawing instructions and images for blackboard diagrams',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          _buildVisualAidForm(),
          const SizedBox(height: 24),
          Consumer<AIAssistantProvider>(
            builder: (context, aiProvider, child) {
              if (aiProvider.lastVisualAidResponse == null) {
                return const SizedBox();
              }
              return _buildVisualAidResults(aiProvider.lastVisualAidResponse!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisualAidForm() {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.draw,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Visual Aid Request',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _conceptController,
              decoration: const InputDecoration(
                labelText: 'Concept to Illustrate',
                hintText: 'e.g., Water cycle, Plant parts, Solar system',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lightbulb),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedVisualType,
                    decoration: const InputDecoration(
                      labelText: 'Visual Aid Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
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
                              value: type,
                              child: Text(type.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedVisualType = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.subject),
                    ),
                    items: [
                      'General',
                      'Science',
                      'Mathematics',
                      'History',
                      'Geography',
                      'Arts',
                    ]
                        .map((subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSubject = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGrade,
              decoration: const InputDecoration(
                labelText: 'Grade Level',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: ['Elementary', 'Middle', 'High School']
                  .map((grade) => DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGrade = value!),
            ),
            const SizedBox(height: 24),
            Consumer<AIAssistantProvider>(
              builder: (context, aiProvider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _conceptController.text.isEmpty || aiProvider.isLoading
                            ? null
                            : () => aiProvider.generateVisualAid(
                                  concept: _conceptController.text,
                                  type: _selectedVisualType,
                                  subject: _selectedSubject,
                                  gradeLevel: _selectedGrade,
                                ),
                    icon: aiProvider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.draw),
                    label: Text(
                      aiProvider.isLoading
                          ? 'Generating...'
                          : 'Generate Visual Aid',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualAidResults(VisualAidResponse response) {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.draw,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${response.type.toUpperCase()}: ${response.concept}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                _buildContentActionButtons(response),
              ],
            ),
            const SizedBox(height: 16),

            // Display SVG content if available
            if (response.svgContent != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: response.svgContent != null
                      ? SvgPicture.string(
                          response.svgContent!,
                          fit: BoxFit.contain,
                          placeholderBuilder: (context) => Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Center(
                              child: Icon(
                                Icons.draw,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Visual aid preview not available',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Drawing Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_list_numbered,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Drawing Instructions',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 18),
                        onPressed: () {
                          _showSnackBar(
                              'Text-to-speech would be implemented here');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    response.drawingInstructions,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Labels Section
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
                        avatar: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.label,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Materials and Time Info
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
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
                            Icon(
                              Icons.build,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Materials',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          response.materials.join(', '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${response.estimatedTime} min',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildContentActionRow(response),
          ],
        ),
      ),
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
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          _buildGameForm(),
          const SizedBox(height: 24),
          Consumer<AIAssistantProvider>(
            builder: (context, aiProvider, child) {
              if (aiProvider.lastGameResponse == null) {
                return const SizedBox();
              }
              return _buildGameResults(aiProvider.lastGameResponse!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameForm() {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.games,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Game Request',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic',
                hintText: 'e.g., Multiplication tables, Countries and capitals',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.topic),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGameType,
                    decoration: const InputDecoration(
                      labelText: 'Game Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.sports_esports),
                    ),
                    items: [
                      'quiz',
                      'memory',
                      'puzzle',
                      'word-game',
                      'activity',
                      'role-play',
                      'competition',
                      'card-game',
                    ]
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedGameType = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.subject),
                    ),
                    items: [
                      'General',
                      'Mathematics',
                      'Science',
                      'English',
                      'Social Studies',
                      'Arts',
                      'Physical Education',
                    ]
                        .map((subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSubject = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(
                      labelText: 'Grade Level',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: ['Elementary', 'Middle', 'High School']
                        .map((grade) => DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedGrade = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedDuration,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    items: [10, 15, 20, 30, 45, 60]
                        .map((mins) => DropdownMenuItem(
                              value: mins,
                              child: Text('$mins min'),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDuration = value!),
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
                        _topicController.text.isEmpty || aiProvider.isLoading
                            ? null
                            : () => aiProvider.generateGame(
                                  topic: _topicController.text,
                                  gameType: _selectedGameType,
                                  subject: _selectedSubject,
                                  gradeLevel: _selectedGrade,
                                  duration: _selectedDuration,
                                ),
                    icon: aiProvider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.games),
                    label: Text(
                      aiProvider.isLoading ? 'Generating...' : 'Generate Game',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameResults(EducationalGameResponse response) {
    return SahayakCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.games, color: Theme.of(context).colorScheme.primary),
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
                _buildContentActionButtons(response),
              ],
            ),
            const SizedBox(height: 16),

            // Game Info Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.category,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          response.gameType.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.timer,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${response.duration} min',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.school,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          response.gradeLevel,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Game Rules
            if (response.rules.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Game Rules'),
                leading: Icon(
                  Icons.rule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up, size: 18),
                  onPressed: () {
                    _showSnackBar('Text-to-speech would be implemented here');
                  },
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(response.rules),
                  ),
                ],
              ),
            ],

            // Game Instructions
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Instructions'),
              leading: Icon(
                Icons.list,
                color: Theme.of(context).colorScheme.primary,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up, size: 18),
                onPressed: () {
                  _showSnackBar('Text-to-speech would be implemented here');
                },
              ),
              initiallyExpanded: true,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(response.instructions),
                ),
              ],
            ),

            // Materials Needed
            if (response.materials.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Materials Needed'),
                leading: Icon(
                  Icons.build,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    child: Wrap(
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
                              avatar: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                child: const Icon(
                                  Icons.inventory,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],

            // Learning Objectives
            if (response.learningObjectives.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Learning Objectives'),
                leading: Icon(
                  Icons.flag,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: response.learningObjectives
                    .map(
                      (objective) => ListTile(
                        leading:
                            const Icon(Icons.check_circle_outline, size: 16),
                        title: Text(objective),
                        dense: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up, size: 16),
                          onPressed: () {
                            _showSnackBar(
                                'Text-to-speech would be implemented here');
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Game Variations
            if (response.variations.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Game Variations'),
                leading: Icon(
                  Icons.shuffle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                children: response.variations
                    .map(
                      (variation) => ListTile(
                        leading: const Icon(Icons.lightbulb_outline, size: 16),
                        title: Text(variation),
                        dense: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up, size: 16),
                          onPressed: () {
                            _showSnackBar(
                                'Text-to-speech would be implemented here');
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 16),
            _buildContentActionRow(response),
          ],
        ),
      ),
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
            'Assess student reading with voice recording and AI analysis',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          _buildReadingTextInput(),
          const SizedBox(height: 24),
          _buildRecordingSection(),
          const SizedBox(height: 24),
          Consumer<AIAssistantProvider>(
            builder: (context, aiProvider, child) {
              if (aiProvider.lastReadingAssessment == null) {
                return const SizedBox();
              }
              return _buildReadingAssessmentResults(
                  aiProvider.lastReadingAssessment!);
            },
          ),
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
            Row(
              children: [
                Icon(
                  Icons.text_fields,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reading Text',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _readingTextController,
              decoration: const InputDecoration(
                labelText: 'Enter text for the student to read',
                hintText: 'The quick brown fox jumps over the lazy dog...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _readingTextController.text =
                        "The quick brown fox jumps over the lazy dog. This pangram contains every letter of the alphabet and is commonly used for typing practice.";
                  },
                  icon: const Icon(Icons.text_snippet),
                  label: const Text('Sample Text'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _readingTextController.clear();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Consumer<AIAssistantProvider>(
      builder: (context, aiProvider, child) {
        return SahayakCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mic,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Voice Recording',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: aiProvider.isRecording
                        ? Colors.red.withOpacity(0.1)
                        : Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                    border: Border.all(
                      color: aiProvider.isRecording
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: InkWell(
                    // onTap: () => _handleRecordingToggle(aiProvider),
                    borderRadius: BorderRadius.circular(60),
                    child: Icon(
                      aiProvider.isRecording ? Icons.stop : Icons.mic,
                      size: 48,
                      color: aiProvider.isRecording
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  aiProvider.isRecording
                      ? 'Recording... Tap to stop'
                      : 'Tap to start recording',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: aiProvider.isRecording
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                      ),
                ),
                if (aiProvider.isRecording) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    backgroundColor: Colors.red.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Future<void> _handleRecordingToggle(AIAssistantProvider aiProvider) async {
  //   if (_readingTextController.text.trim().isEmpty) {
  //     _showSnackBar('Please enter text for reading assessment first');
  //     return;
  //   }

  //   if (aiProvider.isRecording) {
  //     // Stop recording and assess
  //     final audioBytes = await aiProvider.stopRecording();
  //     if (audioBytes != null) {
  //       await aiProvider.assessReading(
  //         audioBytes: audioBytes,
  //         expectedText: _readingTextController.text.trim(),
  //         language: 'en-US',
  //       );
  //     }
  //   } else {
  //     // Start recording
  //     await aiProvider.startRecording();
  //   }
  // }

  Widget _buildReadingAssessmentResults(ReadingAssessmentResponse assessment) {
    Color _getScoreColor(double score) {
      if (score >= 80) return Colors.green;
      if (score >= 60) return Colors.orange;
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
                const Spacer(),
                _buildContentActionButtons(assessment),
              ],
            ),
            const SizedBox(height: 20),

            // Score Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getScoreColor(assessment.accuracyPercentage)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getScoreColor(assessment.accuracyPercentage),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _getScoreColor(assessment.accuracyPercentage),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${assessment.accuracyPercentage.toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: _getScoreColor(
                                    assessment.accuracyPercentage),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Accuracy',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.speed,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${assessment.fluencyRating}/5',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Fluency',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Expected vs Actual Text
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('Expected vs Actual Text'),
              leading: Icon(
                Icons.compare,
                color: Theme.of(context).colorScheme.primary,
              ),
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expected Text:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(assessment.expectedText),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Actual Reading:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.volume_up,
                                      size: 18, color: Colors.blue),
                                  onPressed: () {
                                    _showSnackBar(
                                        'Text-to-speech would be implemented here');
                                  },
                                ),
                              ],
                            ),
                            Text(assessment.actualTranscription),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Pronunciation Errors
            if (assessment.pronunciationErrors.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Pronunciation Issues'),
                leading: const Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                ),
                children: assessment.pronunciationErrors
                    .map(
                      (error) => ListTile(
                        leading: const Icon(Icons.error_outline,
                            size: 16, color: Colors.orange),
                        title: Text(error),
                        dense: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up, size: 16),
                          onPressed: () {
                            _showSnackBar(
                                'Text-to-speech would be implemented here');
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Feedback
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Detailed Feedback'),
              leading: Icon(
                Icons.feedback,
                color: Theme.of(context).colorScheme.primary,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up, size: 18),
                onPressed: () {
                  _showSnackBar('Text-to-speech would be implemented here');
                },
              ),
              initiallyExpanded: true,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(assessment.feedback),
                ),
              ],
            ),

            // Improvement Suggestions
            if (assessment.suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Improvement Suggestions'),
                leading: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                ),
                children: assessment.suggestions
                    .map(
                      (suggestion) => ListTile(
                        leading: const Icon(Icons.arrow_right, size: 16),
                        title: Text(suggestion),
                        dense: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up, size: 16),
                          onPressed: () {
                            _showSnackBar(
                                'Text-to-speech would be implemented here');
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 16),
            _buildContentActionRow(assessment),
          ],
        ),
      ),
    );
  }
}

// Helper extension for String capitalize
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
