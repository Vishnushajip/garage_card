import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../Model/dashboard_analytics_models.dart';
import 'clay_container.dart';
import 'clay_tooltip.dart';

class CustomerRetentionCard extends StatelessWidget {
  const CustomerRetentionCard({
    super.key,
    required this.customerMetrics,
    required this.onNavigateToCustomers,
  });

  final CustomerRetentionMetrics customerMetrics;
  final VoidCallback onNavigateToCustomers;

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
                        color: AppColors.accentBlue.withValues(
                          alpha: isDark ? 0.16 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: PhosphorIcon(
                          PhosphorIconsFill.usersThree,
                          size: 20,
                          color: AppColors.accentBlue,
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
                                'Customer Intelligence',
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 6),
                              const ClayTooltip(
                                message: 'Retention analysis comparing new versus returning workshop clients and lifetime spend.',
                                iconSize: 14,
                              ),
                            ],
                          ),
                          Text(
                            '${customerMetrics.totalCustomers} registered clients on file',
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
                onPressed: onNavigateToCustomers,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All'),
                    SizedBox(width: 4),
                    PhosphorIcon(PhosphorIconsRegular.caretRight, size: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'New Clients',
                  value: '${customerMetrics.newCustomersInPeriod}',
                  color: AppColors.accentBlue,
                  icon: PhosphorIconsFill.userPlus,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Returning',
                  value: '${customerMetrics.returningCustomersInPeriod}',
                  color: AppColors.success,
                  icon: PhosphorIconsFill.arrowsClockwise,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Repeat Rate',
                  value:
                      '${customerMetrics.repeatCustomerRate.toStringAsFixed(1)}%',
                  color: AppColors.accentAmber,
                  icon: PhosphorIconsFill.chartPieSlice,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Top Active Clients in Period',
            style: AppFonts.labelMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (customerMetrics.topCustomers.isEmpty)
            Text(
              'No client visits logged in this period',
              style: AppFonts.bodySmall(color: secondaryTextColor),
            )
          else
            Column(
              children: customerMetrics.topCustomers.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                            style: AppFonts.labelMedium(
                              color: AppColors.accentBlue,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: AppFonts.labelMedium(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${c.jobCount} services • ${c.vehicleDisplay}',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ).copyWith(fontSize: 10.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(c.totalSpent),
                            style: AppFonts.labelMedium(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (c.pendingBalance > 0)
                            Text(
                              'Due: ${CurrencyFormatter.format(c.pendingBalance)}',
                              style: AppFonts.labelSmall(color: AppColors.error)
                                  .copyWith(fontSize: 10.5),
                            ),
                        ],
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

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required PhosphorIconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          PhosphorIcon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppFonts.titleMedium(color: color)
                .copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppFonts.labelSmall(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ).copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
