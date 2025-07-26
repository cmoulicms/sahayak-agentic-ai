import 'package:flutter/material.dart';
import 'package:myapp/data/models/aiModels/ai_models.dart';
import 'package:myapp/presentation/providers/ai_assistant_provider.dart';
import 'package:provider/provider.dart';



class SavedContentScreen extends StatelessWidget {
  const SavedContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Content'),
      ),
      body: Consumer<AIAssistantProvider>(
        builder: (context, provider, child) {
          if (provider.savedContent.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No saved content yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start saving content to see it here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.savedContent.length,
            itemBuilder: (context, index) {
              final item = provider.savedContent[index];
              return _buildSavedItem(item, provider, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildSavedItem(
      SavedContent item, AIAssistantProvider provider, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.bookmark),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatDateTime(item.savedAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAction(value, item, provider, context),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'view', child: Text('View')),
            PopupMenuItem(value: 'share', child: Text('Share')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => _showContentDetails(item, context),
      ),
    );
  }

  void _handleAction(String action, SavedContent item,
      AIAssistantProvider provider, BuildContext context) {
    switch (action) {
      case 'view':
        _showContentDetails(item, context);
        break;
      case 'share':
        // Implement share functionality
        break;
      case 'delete':
        provider.deleteSavedContent(item.id);
        break;
    }
  }

  void _showContentDetails(SavedContent item, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: SingleChildScrollView(
          child: Text(item.data['content'] ?? 'No content available'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
