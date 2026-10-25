import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import '../models/estimate_model.dart';
import '../models/garage_model.dart';
import '../models/invoice_model.dart';

class PdfGeneratorService {
  PdfGeneratorService._();

  static Future<Uint8List> generateEstimatePdf({
    required GarageModel garage,
    required EstimateModel estimate,
    required String customerName,
    required String vehicleDisplay,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        garage.name,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(garage.address,
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Phone: ${garage.phone} | Email: ${garage.email}',
                          style: const pw.TextStyle(fontSize: 10)),
                      if (garage.taxNumber.isNotEmpty)
                        pw.Text('GSTIN / Tax ID: ${garage.taxNumber}',
                            style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blue900, width: 2),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'ESTIMATE',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          estimate.estimateNumber,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Date: ${DateFormatter.formatDate(estimate.createdAt)}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ESTIMATED FOR:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        customerName,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Vehicle: $vehicleDisplay',
                          style: const pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'STATUS:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        estimate.status.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: estimate.isApproved
                              ? PdfColors.green700
                              : PdfColors.orange700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['#', 'Description', 'Type', 'Qty', 'Unit Price', 'Total'],
                data: List<List<dynamic>>.generate(
                  estimate.items.length,
                  (index) {
                    final item = estimate.items[index];
                    return [
                      '${index + 1}',
                      item.description,
                      item.type.toUpperCase(),
                      '${item.quantity}',
                      CurrencyFormatter.format(item.unitPrice,
                          currencyCode: estimate.currencyCode),
                      CurrencyFormatter.format(item.totalPrice,
                          currencyCode: estimate.currencyCode),
                    ];
                  },
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellHeight: 28,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 220,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _buildTotalRow('Subtotal:',
                            CurrencyFormatter.format(estimate.subtotal, currencyCode: estimate.currencyCode)),
                        if (estimate.discountAmount > 0)
                          _buildTotalRow('Discount:',
                              '-${CurrencyFormatter.format(estimate.discountAmount, currencyCode: estimate.currencyCode)}'),
                        if (estimate.taxAmount > 0)
                          _buildTotalRow('Tax (${estimate.taxRate}%):',
                              CurrencyFormatter.format(estimate.taxAmount, currencyCode: estimate.currencyCode)),
                        pw.Divider(thickness: 1, color: PdfColors.grey400),
                        _buildTotalRow(
                          'Estimated Total:',
                          CurrencyFormatter.format(estimate.totalAmount, currencyCode: estimate.currencyCode),
                          isBold: true,
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                'Note: This is an estimated cost. Final invoice may vary based on unforeseen parts or labor required during repairs.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated securely via WeFix Platform',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateInvoicePdf({
    required GarageModel garage,
    required InvoiceModel invoice,
    required String customerName,
    required String vehicleDisplay,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        garage.name,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(garage.address,
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Phone: ${garage.phone} | Email: ${garage.email}',
                          style: const pw.TextStyle(fontSize: 10)),
                      if (garage.taxNumber.isNotEmpty)
                        pw.Text('GSTIN / Tax ID: ${garage.taxNumber}',
                            style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blue900, width: 2),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'TAX INVOICE',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          invoice.invoiceNumber,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Issued: ${DateFormatter.formatDate(invoice.issuedAt ?? invoice.createdAt)}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILLED TO:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        customerName,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Vehicle: $vehicleDisplay',
                          style: const pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'PAYMENT STATUS:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        invoice.status.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: invoice.isPaid
                              ? PdfColors.green700
                              : PdfColors.red700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['#', 'Description', 'Type', 'Qty', 'Unit Price', 'Total'],
                data: List<List<dynamic>>.generate(
                  invoice.items.length,
                  (index) {
                    final item = invoice.items[index];
                    return [
                      '${index + 1}',
                      item.description,
                      item.type.toUpperCase(),
                      '${item.quantity}',
                      CurrencyFormatter.format(item.unitPrice,
                          currencyCode: invoice.currencyCode),
                      CurrencyFormatter.format(item.totalPrice,
                          currencyCode: invoice.currencyCode),
                    ];
                  },
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                cellHeight: 28,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 240,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _buildTotalRow('Subtotal:',
                            CurrencyFormatter.format(invoice.subtotal, currencyCode: invoice.currencyCode)),
                        if (invoice.discountAmount > 0)
                          _buildTotalRow('Discount:',
                              '-${CurrencyFormatter.format(invoice.discountAmount, currencyCode: invoice.currencyCode)}'),
                        if (invoice.taxAmount > 0)
                          _buildTotalRow('Tax (${invoice.taxRate}%):',
                              CurrencyFormatter.format(invoice.taxAmount, currencyCode: invoice.currencyCode)),
                        pw.Divider(thickness: 1, color: PdfColors.grey400),
                        _buildTotalRow(
                          'Grand Total:',
                          CurrencyFormatter.format(invoice.totalAmount, currencyCode: invoice.currencyCode),
                          isBold: true,
                          fontSize: 13,
                        ),
                        _buildTotalRow(
                          'Amount Paid:',
                          CurrencyFormatter.format(invoice.paidAmount, currencyCode: invoice.currencyCode),
                        ),
                        pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                        _buildTotalRow(
                          'Balance Due:',
                          CurrencyFormatter.format(invoice.balanceDue, currencyCode: invoice.currencyCode),
                          isBold: true,
                          fontSize: 14,
                          textColor: invoice.balanceDue > 0
                              ? PdfColors.red700
                              : PdfColors.green700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                'Thank you for your business. For any billing queries, contact ${garage.phone}.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated securely via WeFix Platform',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printOrShareEstimate({
    required GarageModel garage,
    required EstimateModel estimate,
    required String customerName,
    required String vehicleDisplay,
  }) async {
    final pdfBytes = await generateEstimatePdf(
      garage: garage,
      estimate: estimate,
      customerName: customerName,
      vehicleDisplay: vehicleDisplay,
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: '${estimate.estimateNumber}.pdf',
    );
  }

  static Future<void> printOrShareInvoice({
    required GarageModel garage,
    required InvoiceModel invoice,
    required String customerName,
    required String vehicleDisplay,
  }) async {
    final pdfBytes = await generateInvoicePdf(
      garage: garage,
      invoice: invoice,
      customerName: customerName,
      vehicleDisplay: vehicleDisplay,
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: '${invoice.invoiceNumber}.pdf',
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 11,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
