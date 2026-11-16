import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../Model/dashboard_analytics_models.dart';
import 'clay_container.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.ownerName,
    required this.garageName,
    this.garageAddress,
    required this.selectedTimeRange,
    this.customStartDate,
    this.customEndDate,
    required this.onTimeRangeSelected,
    required this.onNavigateToJobs,
    required this.onNavigateToCustomers,
    required this.onNavigateToInvoices,
  });

  final String ownerName;
  final String garageName;
  final String? garageAddress;
  final DashboardTimeRange selectedTimeRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final void Function(DashboardTimeRange, [DateTime?, DateTime?])
  onTimeRangeSelected;
  final VoidCallback onNavigateToJobs;
  final VoidCallback onNavigateToCustomers;
  final VoidCallback onNavigateToInvoices;

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: customStartDate ?? now.subtract(const Duration(days: 30)),
        end: customEndDate ?? now,
      ),
    );

    if (picked != null) {
      onTimeRangeSelected(DashboardTimeRange.custom, picked.start, picked.end);
    }
  }

  Widget _buildTimeChip(
    BuildContext context,
    DashboardTimeRange range,
    bool isDark,
  ) {
    final isSelected = selectedTimeRange == range;
    final String label;

    if (range == DashboardTimeRange.custom &&
        customStartDate != null &&
        customEndDate != null &&
        isSelected) {
      label =
          '${DateFormat('dd MMM').format(customStartDate!)} - ${DateFormat('dd MMM').format(customEndDate!)}';
    } else {
      label = range.label;
    }

    final Color chipBg = isSelected
        ? AppColors.primaryRed
        : (isDark ? const Color(0xFF1E2638) : Colors.transparent);
    final Color textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return InkWell(
      onTap: () {
        if (range == DashboardTimeRange.custom) {
          _pickCustomRange(context);
        } else {
          onTimeRangeSelected(range);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppFonts.labelSmall(color: textColor).copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
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

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy • HH:mm').format(now);
    final cleanGarageName = garageName.trim().isNotEmpty
        ? garageName
        : 'Apex Garage Workshop';
    final branchName = garageAddress?.trim().isNotEmpty == true
        ? garageAddress!
        : 'Main Bay - Bengaluru';

    return ClayContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              final leftHeader = Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withValues(alpha: 0.35),
                          offset: const Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsFill.wrench,
                        size: 22,
                        color: Colors.white,
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
                            Flexible(
                              child: Text(
                                cleanGarageName,
                                style:
                                    AppFonts.titleLarge(color: primaryTextColor)
                                        .copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 17,
                                        ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white12
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                branchName,
                                style:
                                    AppFonts.labelSmall(
                                      color: secondaryTextColor,
                                    ).copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIconsFill.calendarBlank,
                              size: 12,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '$formattedDate IST',
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor,
                                ).copyWith(fontSize: 10.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final rightRangePills = Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2638)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PhosphorIcon(
                              PhosphorIconsRegular.funnel,
                              size: 12,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Range',
                              style:
                                  AppFonts.labelSmall(color: secondaryTextColor)
                                      .copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                          ],
                        ),
                      ),
                      ...DashboardTimeRange.values.map((range) {
                        return _buildTimeChip(context, range, isDark);
                      }),
                    ],
                  ),
                ),
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 5, child: leftHeader),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: rightRangePills,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leftHeader,
                  const SizedBox(height: 14),
                  rightRangePills,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Live Synced',
                        style: AppFonts.labelSmall(
                          color: const Color(0xFF16A34A),
                        ).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: onNavigateToCustomers,
                  icon: const PhosphorIcon(
                    PhosphorIconsBold.userPlus,
                    size: 14,
                  ),
                  label: const Text('Add Client'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: primaryTextColor,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onNavigateToInvoices,
                  icon: const PhosphorIcon(PhosphorIconsBold.receipt, size: 14),
                  label: const Text('Create Invoice'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: primaryTextColor,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => context.push(RoutePaths.merchantCreateJob),
                  icon: const PhosphorIcon(PhosphorIconsBold.plus, size: 14),
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Add New Job'),
                      SizedBox(width: 4),
                      PhosphorIcon(PhosphorIconsBold.arrowRight, size: 12),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
