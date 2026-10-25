import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import '../Model/financial_metrics_model.dart';

class ProfitLossCard extends StatelessWidget {
  const ProfitLossCard({
    super.key,
    required this.metrics,
  });

  final FinancialMetricsModel metrics;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isProfit = metrics.isProfit;
    final statusColor = isProfit ? AppColors.success : AppColors.error;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isProfit
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isProfit
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isProfit ? 'Net Profit' : 'Net Loss',
                          style: AppFonts.labelLarge(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          '${isProfit ? "+" : ""}${CurrencyFormatter.format(metrics.netProfit, currencyCode: metrics.currencyCode)}',
                          style: AppFonts.displayMedium(
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${metrics.profitMargin.toStringAsFixed(1)}% Margin',
                    style: AppFonts.labelSmall(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Wrap(
              runSpacing: 12,
              spacing: 16,
              children: [
                _buildMetricItem(
                  context,
                  label: 'Gross Billed',
                  value: CurrencyFormatter.format(metrics.grossBilled,
                      currencyCode: metrics.currencyCode),
                  color: AppColors.accentBlue,
                ),
                _buildMetricItem(
                  context,
                  label: 'Discounts / Adjustments',
                  value:
                      '-${CurrencyFormatter.format(metrics.discountAdjustments, currencyCode: metrics.currencyCode)}',
                  color: AppColors.accentAmber,
                ),
                _buildMetricItem(
                  context,
                  label: 'Net Billed',
                  value: CurrencyFormatter.format(metrics.netBilled,
                      currencyCode: metrics.currencyCode),
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                _buildMetricItem(
                  context,
                  label: 'Actual Collected',
                  value: CurrencyFormatter.format(metrics.totalCollected,
                      currencyCode: metrics.currencyCode),
                  color: AppColors.success,
                ),
                _buildMetricItem(
                  context,
                  label: 'Estimated Costs (Parts+Labor)',
                  value: CurrencyFormatter.format(metrics.totalCost,
                      currencyCode: metrics.currencyCode),
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                _buildMetricItem(
                  context,
                  label: 'Uncollected Receivables',
                  value: CurrencyFormatter.format(metrics.pendingBalance,
                      currencyCode: metrics.currencyCode),
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.labelSmall(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppFonts.titleMedium(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
