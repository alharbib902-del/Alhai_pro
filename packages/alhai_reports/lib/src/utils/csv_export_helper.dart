/// CSV Export Helper
///
/// Utility for exporting report data as CSV and sharing it.
/// Uses dart:convert for CSV generation and share_plus / printing for sharing.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_font_helper.dart';

/// Result of a CSV export operation
class CsvExportResult {
  final bool success;
  final String? filePath;
  final String? error;

  const CsvExportResult({required this.success, this.filePath, this.error});
}

/// Helper class for building and exporting CSV data
class CsvExportHelper {
  /// Build a CSV string from headers and rows
  static String buildCsv(List<String> headers, List<List<dynamic>> rows) {
    final buffer = StringBuffer();

    // Write BOM for Excel Arabic support
    buffer.write('\uFEFF');

    // Headers
    buffer.writeln(headers.map(_escapeCsv).join(','));

    // Rows
    for (final row in rows) {
      buffer.writeln(row.map((cell) => _escapeCsv(cell.toString())).join(','));
    }

    return buffer.toString();
  }

  /// Escape a single CSV cell value
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Export data as CSV and share/download it
  static Future<CsvExportResult> exportAndShare({
    required BuildContext context,
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    try {
      final csv = buildCsv(headers, rows);
      final bytes = utf8.encode(csv);

      if (kIsWeb) {
        // Web: Embed in a simple PDF and share via printing
        await _shareAsTextPdf(
          context: context,
          fileName: fileName,
          headers: headers,
          rows: rows,
        );
        return const CsvExportResult(success: true);
      }

      // Native: Write to temp file then share
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName.csv');
      await file.writeAsBytes(bytes);

      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: '$fileName.csv',
      );

      // تنظيف الملف المؤقت بعد المشاركة (M109 fix)
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}

      return CsvExportResult(success: true, filePath: file.path);
    } catch (e) {
      return CsvExportResult(success: false, error: e.toString());
    }
  }

  /// Fallback: Share data as a PDF table (for web or when CSV sharing fails)
  static Future<void> _shareAsTextPdf({
    required BuildContext context,
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final pdf = await PdfFontHelper.createDocument();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(fileName,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header row
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.blueGrey700),
                children: headers
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              // Data rows
              ...rows.take(50).map((row) => pw.TableRow(
                    children: row
                        .map((cell) => pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(cell.toString(),
                                  style: const pw.TextStyle(fontSize: 9)),
                            ))
                        .toList(),
                  )),
            ],
          ),
          if (rows.length > 50)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Text(
                'ملاحظة: يعرض أول 50 صف فقط. استخدم تصدير CSV للحصول على كامل البيانات.',
                style:
                    const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ),
        ],
      ),
    ));

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
  }

  /// Show a snackbar notification for export result
  static void showResultSnackBar(BuildContext context, CsvExportResult result) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'تم تصدير التقرير بنجاح'
              : 'فشل التصدير: ${result.error ?? "خطأ غير معروف"}',
        ),
        backgroundColor: result.success ? Colors.green : Colors.red,
        action: result.success
            ? SnackBarAction(
                label: 'حسناً',
                textColor: Colors.white,
                onPressed: () {},
              )
            : null,
      ),
    );
  }
}
