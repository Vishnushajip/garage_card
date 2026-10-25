import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';

class BillAnalyticsList extends StatelessWidget {
  const BillAnalyticsList({
    super.key,
    required this.invoices,
    required this.onSelectInvoice,
  });

  final List<InvoiceModel> invoices;
  final ValueChanged<String> onSelectInvoice;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Card(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
                      'Bill-by-Bill Revenue & Settlement Log',
                      style: AppFonts.titleMedium(color: primaryTextColor),
                    ),
                    Text(
                      'Billed amount vs discount vs paid vs balance',
                      style: AppFonts.bodyMedium(color: secondaryTextColor),
                    ),
                  ],
                ),
                Text(
                  '${invoices.length} Bills',
                  style: AppFonts.labelSmall(color: AppColors.accentBlue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (invoices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No invoices recorded for this period',
                    style: AppFonts.bodyMedium(color: secondaryTextColor),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoices.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final inv = invoices[index];
                  final hasDiscount = inv.discountAmount > 0;

                  return InkWell(
                    onTap: () => onSelectInvoice(inv.id),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                inv.invoiceNumber,
                                style: AppFonts.labelLarge(
                                  color: AppColors.accentBlue,
                                ),
                              ),
                              AppStatusBadge(status: inv.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                inv.issuedAt != null
                                    ? DateFormatter.formatDate(inv.issuedAt!)
                                    : 'Recent',
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                              Row(
                                children: [
                                  if (hasDiscount) ...[
                                    Text(
                                      CurrencyFormatter.format(
                                        inv.totalAmount + inv.discountAmount,
                                        currencyCode: inv.currencyCode,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        decoration: TextDecoration.lineThrough,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentAmber.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '-${CurrencyFormatter.format(inv.discountAmount, currencyCode: inv.currencyCode)} Off',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentAmber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    CurrencyFormatter.format(
                                      inv.totalAmount,
                                      currencyCode: inv.currencyCode,
                                    ),
                                    style: AppFonts.labelLarge(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Paid: ${CurrencyFormatter.format(inv.paidAmount, currencyCode: inv.currencyCode)}',
                                style: AppFonts.labelSmall(
                                  color: AppColors.success,
                                ),
                              ),
                              if (inv.balanceDue > 0)
                                Text(
                                  'Due: ${CurrencyFormatter.format(inv.balanceDue, currencyCode: inv.currencyCode)}',
                                  style: AppFonts.labelSmall(
                                    color: AppColors.error,
                                  ),
                                )
                              else
                                const Text(
                                  'Settled in Full',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
