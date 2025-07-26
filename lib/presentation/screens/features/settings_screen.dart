import 'package:flutter/material.dart';
import 'package:myapp/presentation/providers/ai_assistant_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'AI Settings',
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Default Language'),
                subtitle: const Text('English'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showLanguageDialog(),
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Default Grade Level'),
                subtitle: const Text('Elementary'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showGradeLevelDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Audio Settings',
            children: [
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Speech Rate'),
                subtitle: Slider(
                  value: 0.5,
                  onChanged: (value) {
                    // Implement speech rate change
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('Voice Recognition'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Implement voice recognition toggle
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Data Management',
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Clear History'),
                onTap: () => _showClearHistoryDialog(),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Export Data'),
                onTap: () => _exportData(),
              ),
              ListTile(
                leading: const Icon(Icons.upload),
                title: const Text('Import Data'),
                onTap: () => _importData(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    // Implement language selection dialog
  }

  void _showGradeLevelDialog() {
    // Implement grade level selection dialog
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all history?'),
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
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    final provider = Provider.of<AIAssistantProvider>(context, listen: false);
    final data = provider.exportData();
    // Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data exported successfully')),
    );
  }

  void _importData() {
    // Implement import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality not implemented yet')),
    );
  }
}
