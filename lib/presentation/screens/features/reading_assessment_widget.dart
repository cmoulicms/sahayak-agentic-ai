import 'package:flutter/material.dart';
import 'package:myapp/presentation/providers/ai_assistant_provider.dart';

import 'package:provider/provider.dart';

class ReadingAssessmentWidget extends StatefulWidget {
  final String expectedText;

  const ReadingAssessmentWidget({
    super.key,
    required this.expectedText,
  });

  @override
  State<ReadingAssessmentWidget> createState() =>
      _ReadingAssessmentWidgetState();
}

class _ReadingAssessmentWidgetState extends State<ReadingAssessmentWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIAssistantProvider>(
      builder: (context, provider, child) {
        if (provider.isRecording) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
        }

        return Column(
          children: [
            // Recording button with animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: provider.isRecording ? _pulseAnimation.value : 1.0,
                  child: GestureDetector(
                    // onTap: () => _handleRecordingToggle(provider),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.isRecording
                            ? Colors.red.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        border: Border.all(
                          color:
                              provider.isRecording ? Colors.red : Colors.blue,
                          width: 4,
                        ),
                      ),
                      child: Icon(
                        provider.isRecording ? Icons.stop : Icons.mic,
                        size: 48,
                        color: provider.isRecording ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 16),

            Text(
              provider.isRecording
                  ? 'Recording... Tap to stop'
                  : 'Tap to start recording',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: provider.isRecording ? Colors.red : Colors.blue,
              ),
            ),

            if (provider.isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.red.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  // Future<void> _handleRecordingToggle(AIAssistantProvider provider) async {
  //   if (provider.isRecording) {
  //     final audioBytes = await provider.stopRecording();
  //     if (audioBytes != null) {
  //       await provider.assessReading(
  //         audioBytes: audioBytes,
  //         expectedText: widget.expectedText,
  //         language: 'en-US',
  //       );
  //     }
  //   } else {
  //     await provider.startRecording();
  //   }
  // }
}
