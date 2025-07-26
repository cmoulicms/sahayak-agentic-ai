import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/data/models/aiModels/ai_models.dart';


class EnhancedVisualAidWidget extends StatelessWidget {
  final VisualAidResponse visualAid;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onSpeak;

  const EnhancedVisualAidWidget({
    super.key,
    required this.visualAid,
    this.onShare,
    this.onDownload,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual display (SVG or image)
            if (visualAid.svgContent != null)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: SvgPicture.string(
                  visualAid.svgContent!,
                  fit: BoxFit.contain,
                ),
              ),

            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onShare != null)
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: onShare,
                    tooltip: 'Share',
                  ),
                if (onDownload != null)
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: onDownload,
                    tooltip: 'Download PDF',
                  ),
                if (onSpeak != null)
                  IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: onSpeak,
                    tooltip: 'Read Aloud',
                  ),
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () {}, // Implement like functionality
                  tooltip: 'Like',
                ),
              ],
            ),

            // Instructions
            Text(
              'Drawing Instructions:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(visualAid.drawingInstructions),
          ],
        ),
      ),
    );
  }
}
