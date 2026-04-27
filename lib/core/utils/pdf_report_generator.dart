import 'dart:io';

import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfReportGenerator {
  static Future<File> generate({
    required String monthYear,
    required List<TransactionEntity> transactions,
    required double totalIncome,
    required double totalExpense,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Moneywise Financial Report - $monthYear', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Total Income:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('৳${totalIncome.toStringAsFixed(2)}', style: const pw.TextStyle(color: PdfColors.green)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Total Expense:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('৳${totalExpense.toStringAsFixed(2)}', style: const pw.TextStyle(color: PdfColors.red)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Net Balance:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('৳${(totalIncome - totalExpense).toStringAsFixed(2)}', 
                    style: pw.TextStyle(color: (totalIncome - totalExpense) >= 0 ? PdfColors.green : PdfColors.red)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ['Date', 'Title', 'Category', 'Type', 'Amount'],
            data: transactions.map((t) => [
              '${t.date.day}/${t.date.month}/${t.date.year}',
              t.title,
              t.categoryId, // Should ideally be category name
              t.type == TransactionType.income ? 'Income' : 'Expense',
              '৳${t.amount.toStringAsFixed(2)}',
            ]).toList(),
          ),
        ],
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/report_$monthYear.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
