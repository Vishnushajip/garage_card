import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/documents/pdf_generator_service.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';

class InvoiceCardItem extends StatelessWidget {
  const InvoiceCardItem({
    super.key,
    required this.invoice,
  });

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: AppFonts.titleLarge(color: primaryTextColor),
                    ),
                    Text(
                      'Issued on ${DateFormatter.formatDate(invoice.issuedAt ?? invoice.createdAt)}',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
                AppStatusBadge(status: invoice.status),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount',
                        style: AppFonts.labelSmall(color: secondaryTextColor)),
                    Text(
                      CurrencyFormatter.format(invoice.totalAmount,
                          currencyCode: invoice.currencyCode),
                      style: AppFonts.titleMedium(color: primaryTextColor),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Balance Due',
                        style: AppFonts.labelSmall(color: secondaryTextColor)),
                    Text(
                      CurrencyFormatter.format(invoice.balanceDue,
                          currencyCode: invoice.currencyCode),
                      style: AppFonts.titleMedium(
                        color: invoice.balanceDue > 0
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download PDF'),
                onPressed: () {
                  final dummyGarage = GarageModel(
                    id: invoice.garageId,
                    name: 'Apex Precision Automotive',
                    address: 'Near MG Road, Ravipuram, Kochi, Kerala',
                    phone: '+91 98460 12345',
                    email: 'service@apexprecision.com',
                    ownerUid: 'merchant_1',
                  );
                  PdfGeneratorService.printOrShareInvoice(
                    garage: dummyGarage,
                    invoice: invoice,
                    customerName: 'Arjun Menon',
                    vehicleDisplay: '2020 Honda City (KL 07 BX 9021)',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
