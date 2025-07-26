import 'package:flutter/material.dart';
import 'package:myapp/data/models/aiModels/ai_models.dart';
import 'package:myapp/presentation/providers/ai_assistant_provider.dart';
import 'package:provider/provider.dart';



class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  HistoryItemType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'clear_all', child: Text('Clear All')),
              PopupMenuItem(value: 'export', child: Text('Export History')),
            ],
          ),
        ],
      ),
      body: Consumer<AIAssistantProvider>(
        builder: (context, provider, child) {
          List<HistoryItem> filteredHistory = provider.history;

          if (_searchQuery.isNotEmpty) {
            filteredHistory = provider.searchHistory(_searchQuery);
          }

          if (_selectedFilter != null) {
            filteredHistory = filteredHistory
                .where((item) => item.type == _selectedFilter)
                .toList();
          }

          return Column(
            children: [
              // Filter chips
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedFilter == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...HistoryItemType.values.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getTypeDisplayName(type)),
                          selected: _selectedFilter == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? type : null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // History list
              Expanded(
                child: filteredHistory.isEmpty
                    ? const Center(
                        child: Text('No history items found'),
                      )
                    : ListView.builder(
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final item = filteredHistory[index];
                          return _buildHistoryTile(item, provider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryTile(HistoryItem item, AIAssistantProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _getTypeIcon(item.type),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
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
          onSelected: (value) => _handleItemAction(value, item, provider),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'share', child: Text('Share')),
            PopupMenuItem(value: 'copy', child: Text('Copy')),
            PopupMenuItem(value: 'save', child: Text('Save')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search History'),
        content: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            border: OutlineInputBorder(),
          ),
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

  void _handleMenuAction(String action) {
    // Implement menu actions
  }

  void _handleItemAction(
      String action, HistoryItem item, AIAssistantProvider provider) {
    // Implement item actions
  }

  void _showItemDetails(HistoryItem item) {
    // Implement item details view
  }

  String _getTypeDisplayName(HistoryItemType type) {
    switch (type) {
      case HistoryItemType.localContent:
        return 'Content';
      case HistoryItemType.materials:
        return 'Materials';
      case HistoryItemType.knowledge:
        return 'Q&A';
      case HistoryItemType.visualAid:
        return 'Visual Aids';
      case HistoryItemType.game:
        return 'Games';
      case HistoryItemType.readingAssessment:
        return 'Assessments';
    }
  }

  Icon _getTypeIcon(HistoryItemType type) {
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
}
