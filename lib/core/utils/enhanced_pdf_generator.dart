import 'dart:io';
import 'dart:typed_data';
import 'package:myapp/data/models/aiModels/ai_models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class EnhancedPDFGenerator {
  static Future<String> generateGamePDF(EducationalGameResponse game) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Educational Game',
            style: pw.TextStyle(color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          // Title
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              game.title,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Game Info Table
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(children: [
                _buildTableCell('Topic', game.topic),
                _buildTableCell('Type', game.gameType),
              ]),
              pw.TableRow(children: [
                _buildTableCell('Duration', '${game.duration} minutes'),
                _buildTableCell('Grade Level', game.gradeLevel),
              ]),
            ],
          ),

          pw.SizedBox(height: 20),

          // Rules Section
          if (game.rules.isNotEmpty) ...[
            _buildSectionTitle('Game Rules'),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue200),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(game.rules),
            ),
            pw.SizedBox(height: 16),
          ],

          // Instructions Section
          _buildSectionTitle('Instructions'),
          pw.Text(game.instructions),
          pw.SizedBox(height: 16),

          // Materials Section
          if (game.materials.isNotEmpty) ...[
            _buildSectionTitle('Materials Needed'),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: game.materials
                  .map(
                    (material) => pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(material,
                          style: const pw.TextStyle(fontSize: 10)),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 16),
          ],

          // Learning Objectives
          if (game.learningObjectives.isNotEmpty) ...[
            _buildSectionTitle('Learning Objectives'),
            ...game.learningObjectives.map(
              (objective) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Expanded(child: pw.Text(objective)),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // Variations
          if (game.variations.isNotEmpty) ...[
            _buildSectionTitle('Game Variations'),
            ...game.variations.map(
              (variation) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Expanded(child: pw.Text(variation)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return await _savePDF(pdf, 'game_${game.topic.replaceAll(' ', '_')}.pdf');
  }

  static Future<String> generateVisualAidPDF(
      VisualAidResponse visualAid) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Title
          pw.Text(
            '${visualAid.type}: ${visualAid.concept}',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),

          // Info boxes
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoBox('Subject', visualAid.subject),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildInfoBox('Grade Level', visualAid.gradeLevel),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildInfoBox('Time', '${visualAid.estimatedTime} min'),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Drawing Instructions
          _buildSectionTitle('Drawing Instructions'),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(visualAid.drawingInstructions),
          ),

          pw.SizedBox(height: 20),

          // Labels
          if (visualAid.labels.isNotEmpty) ...[
            _buildSectionTitle('Labels to Include'),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: visualAid.labels
                  .map(
                    (label) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(label,
                          style: const pw.TextStyle(fontSize: 10)),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Materials
          _buildSectionTitle('Materials Needed'),
          ...visualAid.materials.map(
            (material) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Text('• ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(material),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return await _savePDF(
        pdf, 'visual_aid_${visualAid.concept.replaceAll(' ', '_')}.pdf');
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue700,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static Future<String> _savePDF(pw.Document pdf, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
