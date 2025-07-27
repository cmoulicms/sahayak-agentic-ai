import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/data/models/aiModels/ai_models.dart';
import 'package:myapp/presentation/providers/ai_assistant_provider.dart';
import 'package:myapp/presentation/screens/ai_assistant/show_history_details.dart';
import 'package:provider/provider.dart';

class ShowHistory extends StatefulWidget {
  const ShowHistory({super.key});

  @override
  State<ShowHistory> createState() => _ShowHistoryState();
}

class _ShowHistoryState extends State<ShowHistory> {
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
    String action,
    HistoryItem item,
    AIAssistantProvider provider,
  ) async {
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
    HistoryItem item,
    AIAssistantProvider provider,
  ) async {
    String content =
        item.data['content'] ??
        item.data['explanation'] ??
        'Content not available';
    // Implement actual sharing here
    _showSnackBar('Sharing functionality would be implemented here');
  }

  Future<void> _copyHistoryItem(
    HistoryItem item,
    AIAssistantProvider provider,
  ) async {
    String content =
        item.data['content'] ??
        item.data['explanation'] ??
        'Content not available';
    await Clipboard.setData(ClipboardData(text: '${item.title}\n\n$content'));
    _showSnackBar('Copied to clipboard');
  }

  Future<void> _downloadHistoryItem(
    HistoryItem item,
    AIAssistantProvider provider,
  ) async {
    _showSnackBar('PDF download functionality would be implemented here');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowHistoryDetials(item: item),
          ),
        ),
      ),
    );
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
                      Provider.of<AIAssistantProvider>(context, listen: false),
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _copyHistoryItem(
                      item,
                      Provider.of<AIAssistantProvider>(context, listen: false),
                    ),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _downloadHistoryItem(
                      item,
                      Provider.of<AIAssistantProvider>(context, listen: false),
                    ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Consumer<AIAssistantProvider>(
        builder: (context, aiProvider, child) {
          if (aiProvider.history.isEmpty) {
            return const Center(child: Text('No history items yet'));
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: aiProvider.history.length,
              itemBuilder: (context, index) {
                final item = aiProvider.history[index];
                return _buildHistoryItem(item, aiProvider);
              },
            ),
          );
        },
      ),
    );
  }
}
