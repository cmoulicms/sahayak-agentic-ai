import 'package:flutter/material.dart';
import 'package:myapp/features/generated_content/widgets/generated_content_dialog.dart';
import 'package:myapp/features/local_content/local_content_view_model.dart';
import 'package:myapp/theme.dart';
import 'package:myapp/util/marketplace_button.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

const double kAvatarSize = 50;
const double collapsedHeight = 100;
const double expandedHeight = 300;
const double elementPadding = MarketplaceTheme.spacing7;

class LocalContentScreen extends StatelessWidget {
  const LocalContentScreen({super.key, required this.canScroll});

  final bool canScroll;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LocalContentViewModel>();
    final TextEditingController promptController = TextEditingController();
    final TextEditingController languageController = TextEditingController();
    final TextEditingController standardsController = TextEditingController();
    bool isLoading = false;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(title: const Text('Vertex AI Prompt Generator')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: promptController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your prompt',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: languageController,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: standardsController,
                  decoration: const InputDecoration(
                    labelText: 'Standards (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await viewModel
                        .submitPrompt(
                          promptController.text,
                          languageController.text,
                          standardsController.text,
                        )
                        .then((_) async {
                          if (!context.mounted) return;
                          if (viewModel.generatedContent != null) {
                            bool? shouldSave = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  GeneratedContentDialogScreen(
                                    generatedContent:
                                        viewModel.generatedContent!,
                                    actions: [
                                      MarketplaceButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        buttonText: "Save Content",
                                        icon: Symbols.save,
                                      ),
                                    ],
                                  ),
                            );
                            if (shouldSave != null && shouldSave) {
                              viewModel.saveGeneratedContent();
                            }
                          }
                        });
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Generate'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
