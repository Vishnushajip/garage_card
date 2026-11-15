import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'clay_container.dart';
import 'clay_tooltip.dart';

class PaymentMethodBreakdownCard extends StatelessWidget {
  const PaymentMethodBreakdownCard({
    super.key,
    required this.breakdown,
    required this.percentages,
    required this.totalCollected,
  });

  final Map<String, double> breakdown;
  final Map<String, double> percentages;
  final double totalCollected;

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return AppColors.success;
      case 'upi':
        return AppColors.accentBlue;
      case 'card':
        return const Color(0xFF8B5CF6);
      case 'bank transfer':
        return AppColors.accentAmber;
      case 'other':
      default:
        return const Color(0xFF64748B);
    }
  }

  PhosphorIconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return PhosphorIconsFill.money;
      case 'upi':
        return PhosphorIconsFill.qrCode;
      case 'card':
        return PhosphorIconsFill.creditCard;
      case 'bank transfer':
        return PhosphorIconsFill.bank;
      case 'other':
      default:
        return PhosphorIconsFill.wallet;
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

    final activeEntries = breakdown.entries.where((e) => e.value > 0).toList();

    return ClayContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(
                    alpha: isDark ? 0.16 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: PhosphorIcon(
                    PhosphorIconsFill.wallet,
                    size: 20,
                    color: AppColors.accentAmber,
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
                          'Payment Channels',
                          style: AppFonts.titleMedium(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        const ClayTooltip(
                          message: 'Distribution of verified collected payments across Cash, UPI, Cards and Bank Transfers.',
                          iconSize: 14,
                        ),
                      ],
                    ),
                    Text(
                      'Distribution of ${CurrencyFormatter.format(totalCollected)} collected',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (activeEntries.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF121722)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'No settled payments recorded in this period',
                  style: AppFonts.bodySmall(color: secondaryTextColor),
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: activeEntries.map((e) {
                    final pct = percentages[e.key] ?? 0.0;
                    final flex = (pct * 10).toInt();
                    if (flex <= 0) return const SizedBox.shrink();
                    return Expanded(
                      flex: flex,
                      child: Container(color: _getMethodColor(e.key)),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Column(
              children: activeEntries.map((e) {
                final methodColor = _getMethodColor(e.key);
                final methodIcon = _getMethodIcon(e.key);
                final pct = percentages[e.key] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: methodColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            methodIcon,
                            size: 16,
                            color: methodColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.key,
                              style: AppFonts.labelMedium(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${pct.toStringAsFixed(1)}% of total receipts',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ).copyWith(fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(e.value),
                        style: AppFonts.labelLarge(color: primaryTextColor)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
