import 'dart:io';

import 'package:Sahayak/data/models/aiModels/ai_models.dart';
import 'package:Sahayak/presentation/providers/ai_assistant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

class ShowHistoryDetials extends StatefulWidget {
  const ShowHistoryDetials({this.item, super.key});

  final HistoryItem? item;

  @override
  State<ShowHistoryDetials> createState() => _ShowHistoryDetialsState();
}

class _ShowHistoryDetialsState extends State<ShowHistoryDetials> {
  bool _isLoading = false;

  Future<void> sharePdf(String content) async {
    final file = await generatePdf(content, 'SharedContent');
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Sharing content from MyApp');
  }

  Future<void> downloadPdf() async {
    setState(() => _isLoading = true);
    try {
      final file = await generatePdf(
        widget.item!.data['content'] ??
            widget.item!.data['explanation'] ??
            'Content not available',
        'SharedContent',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved to: ${file.path}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving PDF: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<File> generatePdf(String content, String fileName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Sahayak',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(content, style: pw.TextStyle(fontSize: 14)),
            ],
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/$fileName.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
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

  Future<void> _downloadHistoryItem(
    HistoryItem item,
    AIAssistantProvider provider,
  ) async {
    // _showSnackBar('PDF download functionality would be implemented here');
    await downloadPdf();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _shareHistoryItem(
    HistoryItem item,
    AIAssistantProvider provider,
  ) async {
    String content =
        item.data['content'] ??
        item.data['explanation'] ??
        'Content not available';
    // Implement actual sharing here
    // _showSnackBar('Sharing functionality would be implemented here');
    await sharePdf(content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History Details')),
      body: widget.item != null
          ? Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getHistoryIcon(widget.item!.type),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.item!.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.close),
                      //   onPressed: () => Navigator.pop(context),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.item!.data['content'] ??
                            widget.item!.data['explanation'] ??
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
                          widget.item!,
                          Provider.of<AIAssistantProvider>(
                            context,
                            listen: false,
                          ),
                        ),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _copyHistoryItem(
                          widget.item!,
                          Provider.of<AIAssistantProvider>(
                            context,
                            listen: false,
                          ),
                        ),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _isLoading
                            ? null
                            : _downloadHistoryItem(
                                widget.item!,
                                Provider.of<AIAssistantProvider>(
                                  context,
                                  listen: false,
                                ),
                              ),
                        icon: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.download_rounded),
                        label: const Text('PDF'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(child: Text('No history item selected')),
    );
  }
}
