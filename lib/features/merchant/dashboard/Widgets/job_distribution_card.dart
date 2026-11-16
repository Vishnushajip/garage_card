import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../Model/dashboard_analytics_models.dart';
import 'clay_container.dart';
import 'clay_tooltip.dart';

class JobDistributionCard extends StatelessWidget {
  const JobDistributionCard({super.key, required this.operationalMetrics});

  final DashboardOperationalMetrics operationalMetrics;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final vTypes = operationalMetrics.vehicleTypeDistribution.entries
        .where((e) => e.value > 0)
        .toList();
    final categories =
        operationalMetrics.serviceCategoryDistribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categories.take(4).toList();

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
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: PhosphorIcon(
                    PhosphorIconsFill.wrench,
                    size: 20,
                    color: AppColors.primaryRed,
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
                          'Workshop Job & Fleet Mix',
                          style: AppFonts.titleMedium(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        const ClayTooltip(
                          message: 'Vehicle classification and high-demand repair categories handled by your garage.',
                          iconSize: 14,
                        ),
                      ],
                    ),
                    Text(
                      '${operationalMetrics.totalJobsReceived} jobs processed in this period',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Vehicle Fleet Distribution',
            style: AppFonts.labelMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (vTypes.isEmpty)
            Text(
              'No vehicles currently serviced',
              style: AppFonts.bodySmall(color: secondaryTextColor),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final minRequired = vTypes.length * 90.0;
                final shouldScroll = constraints.maxWidth < minRequired;

                final rowContent = Row(
                  children: vTypes.map((vt) {
                    final PhosphorIconData icon;
                    if (vt.key == 'Bikes') {
                      icon = PhosphorIconsFill.motorcycle;
                    } else if (vt.key == 'Scooters') {
                      icon = PhosphorIconsFill.scooter;
                    } else {
                      icon = PhosphorIconsFill.car;
                    }

                    final tile = Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2638)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          PhosphorIcon(
                            icon,
                            size: 20,
                            color: AppColors.primaryRed,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${vt.value}',
                            style: AppFonts.titleMedium(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            vt.key,
                            style: AppFonts.labelSmall(
                              color: secondaryTextColor,
                            ).copyWith(fontSize: 10.5),
                          ),
                        ],
                      ),
                    );

                    if (shouldScroll) {
                      return SizedBox(width: 88, child: tile);
                    }
                    return Expanded(child: tile);
                  }).toList(),
                );

                if (shouldScroll) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(width: minRequired, child: rowContent),
                  );
                }
                return rowContent;
              },
            ),
          const SizedBox(height: 22),
          Text(
            'Top Requested Services',
            style: AppFonts.labelMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (topCategories.isEmpty)
            Text(
              'No repair categories logged',
              style: AppFonts.bodySmall(color: secondaryTextColor),
            )
          else
            Column(
              children: topCategories.map((c) {
                final maxCount = topCategories.first.value;
                final progress = maxCount > 0 ? c.value / maxCount : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              c.key,
                              style: AppFonts.labelSmall(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${c.value} requests',
                            style: AppFonts.labelSmall(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryRed,
                          ),
                        ),
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
