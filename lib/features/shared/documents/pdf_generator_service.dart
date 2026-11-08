import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';

import '../models/estimate_model.dart';
import '../models/garage_model.dart';
import '../models/invoice_model.dart';
import '../models/service_job_model.dart';

class PdfGeneratorService {
  PdfGeneratorService._();

  static Future<Uint8List> generateEstimatePdf({
    required GarageModel garage,
    required EstimateModel estimate,
    required String customerName,
    required String vehicleDisplay,
  }) async {
    final logoBytes = await _loadGarageLogo(garage.logoUrl);
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
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (logoBytes != null) ...[
                          pw.Container(
                            width: 48,
                            height: 48,
                            margin: const pw.EdgeInsets.only(right: 12),
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(
                                color: PdfColors.grey300,
                                width: 1,
                              ),
                            ),
                            child: pw.ClipRRect(
                              horizontalRadius: 7,
                              verticalRadius: 7,
                              child: pw.Image(
                                pw.MemoryImage(logoBytes),
                                fit: pw.BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                garage.name.isNotEmpty
                                    ? garage.name
                                    : 'WeFix Workshop',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text(
                                garage.address,
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                              pw.Text(
                                'Phone: ${garage.phone} | Email: ${garage.email}',
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                              if (garage.taxNumber.isNotEmpty)
                                pw.Text(
                                  'GSTIN / Tax ID: ${garage.taxNumber}',
                                  style: const pw.TextStyle(fontSize: 9),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                      pw.Text(
                        'Vehicle: $vehicleDisplay',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
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
                headers: [
                  '#',
                  'Description',
                  'Type',
                  'Qty',
                  'Unit Price',
                  'Total',
                ],
                data: List<List<dynamic>>.generate(estimate.items.length, (
                  index,
                ) {
                  final item = estimate.items[index];
                  return [
                    '${index + 1}',
                    item.description,
                    item.type.toUpperCase(),
                    '${item.quantity}',
                    _formatPdfCurrency(item.unitPrice, estimate.currencyCode),
                    _formatPdfCurrency(item.totalPrice, estimate.currencyCode),
                  ];
                }),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue900,
                ),
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
                        _buildTotalRow(
                          'Subtotal:',
                          _formatPdfCurrency(
                            estimate.subtotal,
                            estimate.currencyCode,
                          ),
                        ),
                        if (estimate.discountAmount > 0)
                          _buildTotalRow(
                            'Discount:',
                            '-${_formatPdfCurrency(estimate.discountAmount, estimate.currencyCode)}',
                          ),
                        if (estimate.taxAmount > 0)
                          _buildTotalRow(
                            'Tax (${estimate.taxRate}%):',
                            _formatPdfCurrency(
                              estimate.taxAmount,
                              estimate.currencyCode,
                            ),
                          ),
                        pw.Divider(thickness: 1, color: PdfColors.grey400),
                        _buildTotalRow(
                          'Estimated Total:',
                          _formatPdfCurrency(
                            estimate.totalAmount,
                            estimate.currencyCode,
                          ),
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
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated securely via WeFix Platform',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
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
    final logoBytes = await _loadGarageLogo(garage.logoUrl);
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
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (logoBytes != null) ...[
                          pw.Container(
                            width: 48,
                            height: 48,
                            margin: const pw.EdgeInsets.only(right: 12),
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(
                                color: PdfColors.grey300,
                                width: 1,
                              ),
                            ),
                            child: pw.ClipRRect(
                              horizontalRadius: 7,
                              verticalRadius: 7,
                              child: pw.Image(
                                pw.MemoryImage(logoBytes),
                                fit: pw.BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                garage.name.isNotEmpty
                                    ? garage.name
                                    : 'WeFix Workshop',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Text(
                                garage.address,
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                              pw.Text(
                                'Phone: ${garage.phone} | Email: ${garage.email}',
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                              if (garage.taxNumber.isNotEmpty)
                                pw.Text(
                                  'GSTIN / Tax ID: ${garage.taxNumber}',
                                  style: const pw.TextStyle(fontSize: 9),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                      pw.Text(
                        'Vehicle: $vehicleDisplay',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
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
                headers: [
                  '#',
                  'Description',
                  'Type',
                  'Qty',
                  'Unit Price',
                  'Total',
                ],
                data: List<List<dynamic>>.generate(invoice.items.length, (
                  index,
                ) {
                  final item = invoice.items[index];
                  return [
                    '${index + 1}',
                    item.description,
                    item.type.toUpperCase(),
                    '${item.quantity}',
                    _formatPdfCurrency(item.unitPrice, invoice.currencyCode),
                    _formatPdfCurrency(item.totalPrice, invoice.currencyCode),
                  ];
                }),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue900,
                ),
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
                        _buildTotalRow(
                          'Subtotal:',
                          _formatPdfCurrency(
                            invoice.subtotal,
                            invoice.currencyCode,
                          ),
                        ),
                        if (invoice.discountAmount > 0)
                          _buildTotalRow(
                            'Discount:',
                            '-${_formatPdfCurrency(invoice.discountAmount, invoice.currencyCode)}',
                          ),
                        if (invoice.taxAmount > 0)
                          _buildTotalRow(
                            'Tax (${invoice.taxRate}%):',
                            _formatPdfCurrency(
                              invoice.taxAmount,
                              invoice.currencyCode,
                            ),
                          ),
                        pw.Divider(thickness: 1, color: PdfColors.grey400),
                        _buildTotalRow(
                          'Grand Total:',
                          _formatPdfCurrency(
                            invoice.totalAmount,
                            invoice.currencyCode,
                          ),
                          isBold: true,
                          fontSize: 13,
                        ),
                        _buildTotalRow(
                          'Amount Paid:',
                          _formatPdfCurrency(
                            invoice.paidAmount,
                            invoice.currencyCode,
                          ),
                        ),
                        pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                        _buildTotalRow(
                          'Balance Due:',
                          _formatPdfCurrency(
                            invoice.balanceDue,
                            invoice.currencyCode,
                          ),
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
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated securely via WeFix Platform',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
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

  static Future<Uint8List> generateJobInvoicePdf({
    required GarageModel garage,
    required ServiceJobModel job,
    required InvoiceModel invoice,
  }) async {
    final logoBytes = await _loadGarageLogo(garage.logoUrl);
    final pdf = pw.Document();

    final partItems = invoice.items
        .where((i) => i.type.toLowerCase() == 'part')
        .toList();
    final laborItems = invoice.items
        .where(
          (i) =>
              i.type.toLowerCase() == 'labor' ||
              i.type.toLowerCase() == 'labour',
        )
        .toList();
    final extraItems = invoice.items
        .where(
          (i) =>
              i.type.toLowerCase() == 'extra' ||
              i.type.toLowerCase() == 'supplemental',
        )
        .toList();

    final partsTotal = partItems.fold<double>(0.0, (s, i) => s + i.totalPrice);
    final laborTotal = laborItems.fold<double>(0.0, (s, i) => s + i.totalPrice);
    final extraTotal = extraItems.fold<double>(0.0, (s, i) => s + i.totalPrice);

    final paymentMethod = invoice.paymentRecords.isNotEmpty
        ? invoice.paymentRecords.last.method.toUpperCase()
        : 'CASH';

    final originalWork = job.complaints.isNotEmpty
        ? job.complaints.join(', ')
        : 'Vehicle Service';
    final extraWorkDesc = job.supplementalItems.isNotEmpty
        ? job.supplementalItems
              .map(
                (e) =>
                    '${e.title} (${_formatPdfCurrency(e.totalAmount, invoice.currencyCode)})',
              )
              .join(', ')
        : (extraItems.isNotEmpty
              ? extraItems.map((e) => e.description).join(', ')
              : '-');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (logoBytes != null) ...[
                          pw.Container(
                            width: 48,
                            height: 48,
                            margin: const pw.EdgeInsets.only(right: 12),
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(
                                color: PdfColors.grey300,
                                width: 1,
                              ),
                            ),
                            child: pw.ClipRRect(
                              horizontalRadius: 7,
                              verticalRadius: 7,
                              child: pw.Image(
                                pw.MemoryImage(logoBytes),
                                fit: pw.BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                garage.name.isNotEmpty
                                    ? garage.name
                                    : 'WeFix Workshop',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              if (garage.address.isNotEmpty) ...[
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  garage.address,
                                  style: const pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ],
                              if (garage.phone.isNotEmpty) ...[
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  'Phone: ${garage.phone}',
                                  style: const pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.blueGrey700,
                        width: 1.5,
                      ),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'TAX INVOICE',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey800,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          invoice.invoiceNumber,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Date: ${DateFormatter.formatGarageDate(invoice.issuedAt ?? invoice.createdAt)}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CUSTOMER DETAILS',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        job.customerName.isNotEmpty
                            ? job.customerName
                            : 'Customer',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (job.customerPhone.isNotEmpty)
                        pw.Text(
                          'Phone: ${job.customerPhone}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      pw.Text(
                        'Vehicle: ${job.vehicleDisplay}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'JOB INFORMATION',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Job ID: ${job.jobNumber}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Mechanic: ${job.technicianName.isNotEmpty ? job.technicianName : "General"}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Status: ${invoice.status.toUpperCase()}',
                        style: pw.TextStyle(
                          fontSize: 10,
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
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'WORK DETAILS',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    _buildWorkDetailBullet('Original Problem', originalWork),
                    if (extraWorkDesc != '-')
                      _buildWorkDetailBullet('Extra Work', extraWorkDesc),
                    _buildWorkDetailBullet(
                      'Labour Charges',
                      _formatPdfCurrency(laborTotal, invoice.currencyCode),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'PARTS DETAILS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              if (partItems.isNotEmpty)
                pw.TableHelper.fromTextArray(
                  headers: ['Part Name', 'Quantity', 'Unit Price', 'Total'],
                  data: partItems.map((p) {
                    return [
                      p.description,
                      '${p.quantity}',
                      _formatPdfCurrency(p.unitPrice, invoice.currencyCode),
                      _formatPdfCurrency(p.totalPrice, invoice.currencyCode),
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 9,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey800,
                  ),
                  cellHeight: 22,
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                  },
                )
              else
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    'No spare parts billed for this job.',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 240,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _buildTotalRow(
                          'Parts Total:',
                          _formatPdfCurrency(partsTotal, invoice.currencyCode),
                        ),
                        _buildTotalRow(
                          'Labour Charges:',
                          _formatPdfCurrency(laborTotal, invoice.currencyCode),
                        ),
                        if (extraTotal > 0)
                          _buildTotalRow(
                            'Extra Work Charges:',
                            _formatPdfCurrency(
                              extraTotal,
                              invoice.currencyCode,
                            ),
                          ),
                        if (invoice.discountAmount > 0)
                          _buildTotalRow(
                            'Discount:',
                            '-${_formatPdfCurrency(invoice.discountAmount, invoice.currencyCode)}',
                          ),
                        pw.Divider(thickness: 1, color: PdfColors.grey400),
                        _buildTotalRow(
                          'Final Bill Amount:',
                          _formatPdfCurrency(
                            invoice.totalAmount,
                            invoice.currencyCode,
                          ),
                          isBold: true,
                          fontSize: 12,
                        ),
                        _buildTotalRow(
                          'Amount Paid:',
                          _formatPdfCurrency(
                            invoice.paidAmount,
                            invoice.currencyCode,
                          ),
                        ),
                        pw.Divider(
                          thickness: 1.5,
                          color: PdfColors.blueGrey800,
                        ),
                        _buildTotalRow(
                          'Balance Due:',
                          _formatPdfCurrency(
                            invoice.balanceDue,
                            invoice.currencyCode,
                          ),
                          isBold: true,
                          fontSize: 12,
                          textColor: invoice.balanceDue > 0
                              ? PdfColors.red700
                              : PdfColors.green700,
                        ),
                        pw.SizedBox(height: 3),
                        _buildTotalRow('Payment Method:', paymentMethod),
                        _buildTotalRow(
                          'Payment Status:',
                          invoice.status.toUpperCase(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Thank you for your business. Generated via WeFix Platform.',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Page 1 of 1',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printOrShareJobInvoice({
    required GarageModel garage,
    required ServiceJobModel job,
    required InvoiceModel invoice,
  }) async {
    final pdfBytes = await generateJobInvoicePdf(
      garage: garage,
      job: job,
      invoice: invoice,
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Invoice_${invoice.invoiceNumber}.pdf',
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

  static Future<Uint8List?> _loadGarageLogo(String? logoUrl) async {
    if (logoUrl == null || logoUrl.trim().isEmpty) return null;
    try {
      final res = await http
          .get(Uri.parse(logoUrl.trim()))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        return res.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  static String _formatPdfCurrency(
    double amount, [
    String currencyCode = 'INR',
  ]) {
    final code = currencyCode.toUpperCase();
    final prefix = switch (code) {
      'INR' => 'Rs. ',
      'AED' => 'AED ',
      'USD' => '\$ ',
      'EUR' => 'EUR ',
      'GBP' => 'GBP ',
      'SAR' => 'SAR ',
      'QAR' => 'QAR ',
      'OMR' => 'OMR ',
      _ => '$code ',
    };
    final formatter = NumberFormat('#,##0.00');
    return '$prefix${formatter.format(amount)}';
  }

  static pw.Widget _buildWorkDetailBullet(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 3.5, right: 6),
            width: 3.5,
            height: 3.5,
            decoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey800,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
                children: [
                  pw.TextSpan(
                    text: '$label: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
