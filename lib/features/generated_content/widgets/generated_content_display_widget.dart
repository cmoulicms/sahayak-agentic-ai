import 'package:flutter/material.dart';
import 'package:myapp/features/generated_content/generated_content_model.dart';

import '../../../theme.dart';

class GeneratedContentDisplayWidget extends StatelessWidget {
  const GeneratedContentDisplayWidget({
    super.key,
    required this.generatedContent,
    this.subheading,
  });

  final GeneratedContent generatedContent;
  final Widget? subheading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(MarketplaceTheme.defaultBorderRadius),
            color: MarketplaceTheme.primary.withAlpha(128),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            generatedContent.text,
                            softWrap: true,
                            style: MarketplaceTheme.heading2,
                          ),
                          if (subheading != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: MarketplaceTheme.spacing7,
                              ),
                              child: subheading,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
