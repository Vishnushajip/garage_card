import 'dart:convert';
import 'dart:typed_data';

import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:printing/printing.dart';

class TaxExportService {
  TaxExportService._();

  static String generateTaxCsv(
    List<InvoiceModel> invoices, {
    String garageName = 'Garage',
    String taxNumber = '32AAACH7890Q1ZS',
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Invoice Number,Invoice Date,Customer ID,Tax Number / GSTIN,Subtotal Taxable (INR),Discount (INR),CGST Rate (%),CGST Amount (INR),SGST Rate (%),SGST Amount (INR),IGST Rate (%),IGST Amount (INR),Total Tax (INR),Total Invoice Value (INR),Amount Paid (INR),Balance Due (INR),Payment Status,Payment Records Count',
    );

    for (final inv in invoices) {
      final dateStr = DateFormatter.formatDate(inv.issuedAt ?? inv.createdAt);
      final hasTax = inv.taxRate > 0;
      final cgstRate = hasTax ? (inv.taxRate / 2) : 0.0;
      final sgstRate = hasTax ? (inv.taxRate / 2) : 0.0;
      final cgstAmount = hasTax ? (inv.taxAmount / 2) : 0.0;
      final sgstAmount = hasTax ? (inv.taxAmount / 2) : 0.0;
      const igstRate = 0.0;
      const igstAmount = 0.0;

      final row = [
        _escapeCsv(inv.invoiceNumber),
        _escapeCsv(dateStr),
        _escapeCsv(inv.customerId),
        _escapeCsv(taxNumber),
        inv.subtotal.toStringAsFixed(2),
        inv.discountAmount.toStringAsFixed(2),
        cgstRate.toStringAsFixed(1),
        cgstAmount.toStringAsFixed(2),
        sgstRate.toStringAsFixed(1),
        sgstAmount.toStringAsFixed(2),
        igstRate.toStringAsFixed(1),
        igstAmount.toStringAsFixed(2),
        inv.taxAmount.toStringAsFixed(2),
        inv.totalAmount.toStringAsFixed(2),
        inv.paidAmount.toStringAsFixed(2),
        inv.balanceDue.toStringAsFixed(2),
        _escapeCsv(inv.status.toUpperCase()),
        inv.paymentRecords.length.toString(),
      ];

      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  static Future<void> shareTaxCsv(
    List<InvoiceModel> invoices, {
    String garageName = 'Garage',
    String taxNumber = '32AAACH7890Q1ZS',
  }) async {
    final csvContent = generateTaxCsv(
      invoices,
      garageName: garageName,
      taxNumber: taxNumber,
    );
    final bytes = Uint8List.fromList(utf8.encode(csvContent));
    final filename =
        'GST_Tax_Report_${DateTime.now().millisecondsSinceEpoch}.csv';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
