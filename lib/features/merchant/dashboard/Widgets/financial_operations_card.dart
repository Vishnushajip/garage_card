import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../Model/dashboard_analytics_models.dart';
import 'clay_container.dart';
import 'clay_tooltip.dart';

class FinancialOperationsCard extends StatelessWidget {
  const FinancialOperationsCard({
    super.key,
    required this.financialMetrics,
    required this.transactions,
    required this.onNavigateToInvoices,
  });

  final DashboardFinancialMetrics financialMetrics;
  final List<DashboardTransactionItem> transactions;
  final VoidCallback onNavigateToInvoices;

  PhosphorIconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return PhosphorIconsFill.money;
      case 'upi':
        return PhosphorIconsFill.qrCode;
      case 'card':
        return PhosphorIconsFill.creditCard;
      default:
        return PhosphorIconsFill.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return ClayContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(
                          alpha: isDark ? 0.16 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: PhosphorIcon(
                          PhosphorIconsFill.receipt,
                          size: 20,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Receivables & Settlements',
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 6),
                              const ClayTooltip(
                                message: 'Pending customer invoice balances and real-time payment audit log.',
                                iconSize: 14,
                              ),
                            ],
                          ),
                          Text(
                            'Active balance dues and verified collections',
                            style: AppFonts.labelSmall(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onNavigateToInvoices,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: AppColors.primaryRed,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Invoices'),
                    SizedBox(width: 4),
                    PhosphorIcon(PhosphorIconsRegular.arrowRight, size: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Outstanding',
                        style: AppFonts.labelSmall(color: secondaryTextColor),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyFormatter.format(
                            financialMetrics.totalOutstanding,
                          ),
                          style: AppFonts.displaySmall(
                            color: AppColors.error,
                          ).copyWith(fontWeight: FontWeight.w800, fontSize: 22),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (financialMetrics.overdueOutstanding > 0) ...[
                  Container(
                    height: 38,
                    width: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overdue Amount',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyFormatter.format(
                              financialMetrics.overdueOutstanding,
                            ),
                            style:
                                AppFonts.displaySmall(
                                  color: AppColors.accentAmber,
                                ).copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Recent Payment Transactions',
            style: AppFonts.labelMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (transactions.isEmpty)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF121722)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No recent transactions recorded',
                  style: AppFonts.bodySmall(color: secondaryTextColor),
                ),
              ),
            )
          else
            Column(
              children: transactions.take(5).map((t) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            _getPaymentIcon(t.method),
                            size: 16,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.invoiceNumber.isNotEmpty
                                  ? t.invoiceNumber
                                  : 'Invoice Payment',
                              style: AppFonts.labelMedium(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${t.method.toUpperCase()} • ${DateFormatter.formatRelative(t.recordedAt)}',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ).copyWith(fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+${CurrencyFormatter.format(t.amount)}',
                        style: AppFonts.labelLarge(color: AppColors.success)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
