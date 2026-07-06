import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_branding.dart';
import '../../domain/entities/entities.dart';

class PdfExportService {
  static const _accent = PdfColor.fromInt(0xFF9D4EDD);
  static const _muted = PdfColor.fromInt(0xFF666666);
  static const _mistakesSection = 'Mistakes & Yaad Rakhna';
  static const _sections = [
    'Revision Summary',
    'Core Idea',
    'Pattern',
    'Algorithm',
    'Time Complexity',
    'Mistakes I Made',
    'Important Edge Cases',
    'Interview Tricks',
  ];

  Future<File> exportNotes(
    List<ProblemEntity> problems, {
    List<ShortNoteEntity> shortNotes = const [],
  }) async {
    final withNotes = problems.where((p) => p.hasNotes).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final reminders = List<ShortNoteEntity>.from(shortNotes)
      ..sort((a, b) => a.order.compareTo(b.order));

    final pdf = pw.Document();
    final exportDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    if (withNotes.isEmpty && reminders.isEmpty) {
      pdf.addPage(
        pw.Page(
          pageTheme: _theme(),
          build: (_) => pw.Center(
            child: pw.Text(
              'No Notes Available',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: _accent,
              ),
            ),
          ),
        ),
      );
    } else {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: _theme(),
          footer: (ctx) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                AppBranding.name,
                style: const pw.TextStyle(fontSize: 8, color: _muted),
              ),
              pw.Text(
                'Page ${ctx.pageNumber}',
                style: const pw.TextStyle(fontSize: 8, color: _muted),
              ),
            ],
          ),
          build: (ctx) => _buildCompactNotes(withNotes, reminders, exportDate),
        ),
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/lekhraj_dsa_notes.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  List<pw.Widget> _buildCompactNotes(
    List<ProblemEntity> problems,
    List<ShortNoteEntity> shortNotes,
    String exportDate,
  ) {
    final widgets = <pw.Widget>[
      pw.Text(
        AppBranding.notesPdfTitle,
        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _accent),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Exported $exportDate  |  ${problems.length} problem notes  |  ${shortNotes.length} short notes',
        style: const pw.TextStyle(fontSize: 10, color: _muted),
      ),
      pw.SizedBox(height: 6),
      pw.Divider(color: _accent, thickness: 0.5),
      pw.SizedBox(height: 10),
    ];

    if (problems.isNotEmpty) {
      var index = 1;
      String? currentTopic;

      for (final p in problems) {
        if (p.topicName != currentTopic) {
          currentTopic = p.topicName;
          widgets.addAll([
            pw.SizedBox(height: index == 1 ? 0 : 10),
            pw.Text(
              currentTopic,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _accent,
              ),
            ),
            pw.SizedBox(height: 4),
          ]);
        }

        final comment = _extractComment(p);
        widgets.add(_numberedLine(index, p.name, comment));
        index++;
      }
    } else {
      widgets.add(
        pw.Text(
          'No problem notes yet.',
          style: pw.TextStyle(fontSize: 10, color: _muted, fontStyle: pw.FontStyle.italic),
        ),
      );
    }

    if (shortNotes.isNotEmpty) {
      widgets.addAll([
        pw.SizedBox(height: 16),
        pw.Divider(color: _accent, thickness: 0.5),
        pw.SizedBox(height: 10),
        pw.Text(
          _mistakesSection,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _accent),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Formats, tricks aur cheezein jo yaad rakhni hain',
          style: const pw.TextStyle(fontSize: 9, color: _muted),
        ),
        pw.SizedBox(height: 8),
      ]);

      for (var i = 0; i < shortNotes.length; i++) {
        final note = shortNotes[i];
        if (note.title.isNotEmpty) {
          widgets.add(_numberedLine(i + 1, note.title, note.text));
        } else {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: '${i + 1}) ',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.TextSpan(
                      text: note.text,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  pw.Widget _numberedLine(int index, String label, String body) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$index) ',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(
              text: label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(
              text: ' -- $body',
              style: pw.TextStyle(
                fontSize: 10,
                color: body == 'No comment' ? _muted : PdfColors.black,
                fontStyle: body == 'No comment' ? pw.FontStyle.italic : pw.FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractComment(ProblemEntity p) {
    final parsed = _parseSections(p.notes);
    for (final section in _sections) {
      final value = parsed[section]?.trim();
      if (value != null && value.isNotEmpty) {
        return _compactLine(value);
      }
    }
    final raw = p.notes.trim();
    if (raw.isEmpty) return 'No comment';
    return _compactLine(raw);
  }

  String _compactLine(String text) {
    final line = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (line.length <= 220) return line;
    return '${line.substring(0, 217)}...';
  }

  pw.PageTheme _theme() => pw.PageTheme(
        theme: pw.ThemeData.withFont(base: pw.Font.helvetica(), bold: pw.Font.helveticaBold()),
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      );

  Map<String, String?> _parseSections(String notes) {
    const allSections = [
      'Pattern',
      'Core Idea',
      'Algorithm',
      'Pseudo Code',
      'Time Complexity',
      'Space Complexity',
      'Mistakes I Made',
      'Important Edge Cases',
      'Interview Tricks',
      'Revision Summary',
      'Confidence',
    ];
    final result = <String, String?>{for (final s in allSections) s: null};
    if (notes.trim().isEmpty) return result;

    var current = '';
    final buffer = StringBuffer();
    for (final line in notes.split('\n')) {
      final trimmed = line.trim();
      final heading = trimmed.replaceAll(RegExp(r'^#+\s*'), '');
      final match = allSections.where((s) => s.toLowerCase() == heading.toLowerCase());
      if (match.isNotEmpty) {
        if (current.isNotEmpty) result[current] = buffer.toString().trim();
        current = match.first;
        buffer.clear();
      } else {
        buffer.writeln(line);
      }
    }
    if (current.isNotEmpty) result[current] = buffer.toString().trim();
    return result;
  }

  Future<void> shareNotesPdf(
    List<ProblemEntity> problems, {
    List<ShortNoteEntity> shortNotes = const [],
  }) async {
    final file = await exportNotes(problems, shortNotes: shortNotes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${AppBranding.notesPdfTitle} Export',
    );
  }
}
