import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:shuttlebee/core/utils/logger.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

/// Report Service - خدمة توليد التقارير
class ReportService {
  ReportService._();
  
  static final ReportService instance = ReportService._();

  /// توليد تقرير PDF
  Future<File> generatePDFReport({
    required String title,
    required Map<String, dynamic> data,
    String? subtitle,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      pw.SizedBox(height: 8),
                      pw.Text(
                        subtitle,
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'تاريخ التقرير: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Divider(),
                  ],
                ),
              ),

              // Content
              pw.SizedBox(height: 20),
              ...data.entries.map((entry) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        entry.key,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        entry.value.toString(),
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }),

              // Footer
              pw.SizedBox(height: 40),
              pw.Divider(),
              pw.Text(
                'تم إنشاء هذا التقرير تلقائياً بواسطة ShuttleBee',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF
      final output = await getTemporaryDirectory();
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      AppLogger.info('PDF Report generated: ${file.path}');
      return file;
    } catch (e) {
      AppLogger.error('Failed to generate PDF report', e.toString());
      rethrow;
    }
  }

  /// توليد تقرير Excel
  Future<File> generateExcelReport({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> headers,
  }) async {
    try {
      // Create workbook
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      // Set sheet name
      sheet.name = title;

      // Add title
      sheet.getRangeByIndex(1, 1, 1, headers.length).merge();
      sheet.getRangeByIndex(1, 1).setText(title);
      sheet.getRangeByIndex(1, 1).cellStyle.fontSize = 16;
      sheet.getRangeByIndex(1, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(1, 1).cellStyle.hAlign = xlsio.HAlignType.center;

      // Add date
      sheet.getRangeByIndex(2, 1, 2, headers.length).merge();
      sheet.getRangeByIndex(2, 1).setText(
        'تاريخ التقرير: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
      );
      sheet.getRangeByIndex(2, 1).cellStyle.fontSize = 10;

      // Add headers
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.getRangeByIndex(4, i + 1);
        cell.setText(headers[i]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#4CAF50';
        cell.cellStyle.fontColor = '#FFFFFF';
      }

      // Add data
      for (int i = 0; i < data.length; i++) {
        final row = data[i];
        for (int j = 0; j < headers.length; j++) {
          final key = headers[j];
          final value = row[key];
          sheet.getRangeByIndex(i + 5, j + 1).setText(value?.toString() ?? '');
        }
      }

      // Auto-fit columns
      for (int i = 1; i <= headers.length; i++) {
        sheet.autoFitColumn(i);
      }

      // Save Excel
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final output = await getTemporaryDirectory();
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(bytes);

      AppLogger.info('Excel Report generated: ${file.path}');
      return file;
    } catch (e) {
      AppLogger.error('Failed to generate Excel report', e.toString());
      rethrow;
    }
  }

  /// توليد تقرير الرحلات (PDF)
  Future<File> generateTripsReport({
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> trips,
  }) async {
    final data = {
      'الفترة': '${DateFormat('yyyy-MM-dd').format(startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate)}',
      'عدد الرحلات': trips.length.toString(),
      'الرحلات المكتملة': trips.where((t) => t['state'] == 'completed').length.toString(),
      'الرحلات الجارية': trips.where((t) => t['state'] == 'ongoing').length.toString(),
      'الرحلات الملغاة': trips.where((t) => t['state'] == 'cancelled').length.toString(),
    };

    return generatePDFReport(
      title: 'تقرير الرحلات',
      subtitle: 'تقرير شامل عن جميع الرحلات',
      data: data,
    );
  }

  /// توليد تقرير الرحلات (Excel)
  Future<File> generateTripsExcelReport({
    required List<Map<String, dynamic>> trips,
  }) async {
    return generateExcelReport(
      title: 'تقرير الرحلات',
      headers: ['الاسم', 'التاريخ', 'النوع', 'الحالة', 'السائق', 'المركبة'],
      data: trips.map((trip) {
        return {
          'الاسم': trip['name'] ?? '',
          'التاريخ': trip['date'] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(trip['date']))
              : '',
          'النوع': trip['trip_type'] ?? '',
          'الحالة': trip['state'] ?? '',
          'السائق': trip['driver_name'] ?? '',
          'المركبة': trip['vehicle_name'] ?? '',
        };
      }).toList(),
    );
  }
}

