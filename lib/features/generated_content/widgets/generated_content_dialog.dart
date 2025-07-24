import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:myapp/features/generated_content/generated_content_model.dart';
import 'package:myapp/features/generated_content/widgets/generated_content_display_widget.dart';
import 'package:myapp/util/marketplace_button.dart';
import '../../../theme.dart';

class GeneratedContentDialogScreen extends StatelessWidget {
  const GeneratedContentDialogScreen({
    super.key,
    required this.generatedContent,
    required this.actions,
    this.subheading,
  });

  final GeneratedContent generatedContent;
  final List<Widget> actions;
  final Widget? subheading;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: GeneratedContentDisplayWidget(
              generatedContent: generatedContent,
              subheading: subheading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: MarketplaceTheme.spacing5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MarketplaceButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  buttonText: 'Close',
                  icon: Symbols.close,
                ),
                ...actions,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
