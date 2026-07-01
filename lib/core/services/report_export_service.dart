import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../../models/analytics_model.dart';

class ReportExportService {
  Future<File> exportAnalyticsPdf({
    required OverviewAnalytics overview,
    required FeeAnalytics fees,
    required List<MonthlyFeeData> monthlyFees,
    required List<AttendanceAnalytics> attendance,
    required List<MaterialAnalytics> materials,
    required List<BatchStudentCount> batchCounts,
  }) async {
    final pdf = pw.Document();
    
    // Load logo
    final logoBytes = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        // Header with logo + title + date
        pw.Row(children: [
          pw.Image(logoImage, height: 50),
          pw.SizedBox(width: 16),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Agate Classes - Analytics Report',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ]),
        ]),
        pw.Divider(),
        pw.SizedBox(height: 12),

        // Overview section
        _pdfSectionTitle('Overview'),
        _pdfStatsRow([
          'Total Students: ${overview.totalStudents}',
          'Total Teachers: ${overview.totalTeachers}',
          'Total Batches: ${overview.totalBatches}',
        ]),

        pw.SizedBox(height: 16),

        // Fee section
        _pdfSectionTitle('Fee Analytics'),
        _pdfTable(
          headers: ['Metric', 'Value'],
          rows: [
            ['Total Fee Assigned', 'Rs ${fees.totalFeeAssigned.toStringAsFixed(0)}'],
            ['Total Collected', 'Rs ${fees.totalCollected.toStringAsFixed(0)}'],
            ['Total Pending', 'Rs ${fees.totalPending.toStringAsFixed(0)}'],
            ['Collection Rate', '${fees.collectionPercentage.toStringAsFixed(1)}%'],
            ['Fully Paid Students', '${fees.paidCount}'],
            ['Partially Paid', '${fees.partialCount}'],
            ['Unpaid', '${fees.unpaidCount}'],
          ],
        ),

        pw.SizedBox(height: 16),

        // Attendance section
        _pdfSectionTitle('Attendance by Batch'),
        _pdfTable(
          headers: ['Batch', 'Present', 'Absent', 'Late', 'Rate %'],
          rows: attendance.map((a) => [
            a.batch, '${a.presentCount}', '${a.absentCount}',
            '${a.lateCount}', '${a.attendancePercentage}%'
          ]).toList(),
        ),

        pw.SizedBox(height: 16),

        // Study materials section
        _pdfSectionTitle('Study Materials by Batch'),
        _pdfTable(
          headers: ['Batch', 'Materials', 'Downloads'],
          rows: materials.map((m) => [
            m.batch, '${m.totalMaterials}', '${m.totalDownloads}'
          ]).toList(),
        ),
      ],
    ));

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/agate_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
    );
  }

  pw.Widget _pdfStatsRow(List<String> stats) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: stats.map((s) => pw.Text(s, style: const pw.TextStyle(fontSize: 11))).toList(),
    );
  }

  pw.Widget _pdfTable({required List<String> headers, required List<List<String>> rows}) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        for (var i = 1; i < headers.length; i++) i: pw.Alignment.centerRight,
      },
    );
  }

  Future<File> exportAnalyticsExcel({
    required OverviewAnalytics overview,
    required FeeAnalytics fees,
    required List<MonthlyFeeData> monthlyFees,
    required List<AttendanceAnalytics> attendance,
    required List<MaterialAnalytics> materials,
    required List<BatchStudentCount> batchCounts,
  }) async {
    final excel = Excel.createExcel();

    // Overview sheet
    final overviewSheet = excel['Overview'];
    overviewSheet.appendRow([TextCellValue('Metric'), TextCellValue('Value')]);
    overviewSheet.appendRow([TextCellValue('Total Students'), IntCellValue(overview.totalStudents)]);
    overviewSheet.appendRow([TextCellValue('Total Teachers'), IntCellValue(overview.totalTeachers)]);
    overviewSheet.appendRow([TextCellValue('Total Batches'), IntCellValue(overview.totalBatches)]);

    // Fee sheet
    final feeSheet = excel['Fee Analytics'];
    feeSheet.appendRow([TextCellValue('Metric'), TextCellValue('Value')]);
    feeSheet.appendRow([TextCellValue('Total Fee Assigned'), DoubleCellValue(fees.totalFeeAssigned)]);
    feeSheet.appendRow([TextCellValue('Total Collected'), DoubleCellValue(fees.totalCollected)]);
    feeSheet.appendRow([TextCellValue('Total Pending'), DoubleCellValue(fees.totalPending)]);
    feeSheet.appendRow([TextCellValue('Collection Rate %'), DoubleCellValue(fees.collectionPercentage)]);
    feeSheet.appendRow([TextCellValue('Paid Count'), IntCellValue(fees.paidCount)]);
    feeSheet.appendRow([TextCellValue('Partial Count'), IntCellValue(fees.partialCount)]);
    feeSheet.appendRow([TextCellValue('Unpaid Count'), IntCellValue(fees.unpaidCount)]);

    // Monthly fees sheet
    final monthlySheet = excel['Monthly Fees'];
    monthlySheet.appendRow([TextCellValue('Month'), TextCellValue('Collected (Rs)')]);
    for (final m in monthlyFees) {
      monthlySheet.appendRow([TextCellValue(m.month), DoubleCellValue(m.collected)]);
    }

    // Attendance sheet
    final attendanceSheet = excel['Attendance'];
    attendanceSheet.appendRow([TextCellValue('Batch'), TextCellValue('Present'), TextCellValue('Absent'), TextCellValue('Late'), TextCellValue('Rate %')]);
    for (final a in attendance) {
      attendanceSheet.appendRow([
        TextCellValue(a.batch), IntCellValue(a.presentCount), IntCellValue(a.absentCount), IntCellValue(a.lateCount), DoubleCellValue(a.attendancePercentage)
      ]);
    }

    // Materials sheet
    final materialsSheet = excel['Study Materials'];
    materialsSheet.appendRow([TextCellValue('Batch'), TextCellValue('Materials'), TextCellValue('Downloads')]);
    for (final m in materials) {
      materialsSheet.appendRow([TextCellValue(m.batch), IntCellValue(m.totalMaterials), IntCellValue(m.totalDownloads)]);
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/agate_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    
    final bytes = excel.save();
    if (bytes != null) {
      file.writeAsBytesSync(bytes);
    }
    return file;
  }
}
