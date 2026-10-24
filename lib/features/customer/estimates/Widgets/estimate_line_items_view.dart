import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';

class EstimateLineItemsView extends StatelessWidget {
  const EstimateLineItemsView({
    super.key,
    required this.estimate,
  });

  final EstimateModel estimate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...estimate.items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.type == 'part'
                        ? AppColors.infoBg
                        : AppColors.warningBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.type.toUpperCase(),
                    style: TextStyle(
                      color: item.type == 'part'
                          ? AppColors.info
                          : AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description,
                        style: AppFonts.bodyLarge(color: primaryTextColor),
                      ),
                      Text(
                        '${item.quantity} x ${CurrencyFormatter.format(item.unitPrice, currencyCode: estimate.currencyCode)}',
                        style: AppFonts.labelSmall(color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(item.totalPrice,
                      currencyCode: estimate.currencyCode),
                  style: AppFonts.labelLarge(color: primaryTextColor),
                ),
              ],
            ),
          );
        }),
        const Divider(height: 24),
        _buildRow('Subtotal',
            CurrencyFormatter.format(estimate.subtotal, currencyCode: estimate.currencyCode), secondaryTextColor),
        if (estimate.discountAmount > 0)
          _buildRow(
              'Discount',
              '-${CurrencyFormatter.format(estimate.discountAmount, currencyCode: estimate.currencyCode)}',
              AppColors.success),
        if (estimate.taxAmount > 0)
          _buildRow(
              'Tax (${estimate.taxRate}%)',
              CurrencyFormatter.format(estimate.taxAmount, currencyCode: estimate.currencyCode),
              secondaryTextColor),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Estimated Total',
              style: AppFonts.titleLarge(color: primaryTextColor),
            ),
            Text(
              CurrencyFormatter.format(estimate.totalAmount,
                  currencyCode: estimate.currencyCode),
              style: AppFonts.numberLarge(color: AppColors.accentBlue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 13)),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
