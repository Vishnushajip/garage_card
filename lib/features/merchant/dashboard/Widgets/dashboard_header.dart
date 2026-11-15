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
        : (isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9));
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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryRed
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.9)),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryRed.withValues(alpha: 0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppFonts.labelSmall(color: textColor).copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required PhosphorIconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryRed
              : (isDark ? const Color(0xFF1E2638) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? AppColors.primaryRed
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppColors.primaryRed.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: 16,
              color: isPrimary
                  ? Colors.white
                  : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.labelSmall(
                color: isPrimary
                    ? Colors.white
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
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
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now);

    final cleanOwner =
        ownerName.trim().isNotEmpty &&
            !ownerName.contains('Vishnu') &&
            ownerName != 'User'
        ? ownerName
        : 'Garage Owner';

    return ClayContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $cleanOwner',
                          style: AppFonts.titleLarge(
                            color: primaryTextColor,
                          ).copyWith(fontWeight: FontWeight.w800, fontSize: 20),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIconsFill.calendarBlank,
                              size: 13,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formattedDate,
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildActionButton(
                          context: context,
                          label: 'Add New Job',
                          icon: PhosphorIconsBold.plus,
                          onTap: () =>
                              context.push(RoutePaths.merchantCreateJob),
                          isPrimary: true,
                          isDark: isDark,
                        ),
                        _buildActionButton(
                          context: context,
                          label: 'Create Invoice',
                          icon: PhosphorIconsBold.receipt,
                          onTap: onNavigateToInvoices,
                          isPrimary: false,
                          isDark: isDark,
                        ),
                        _buildActionButton(
                          context: context,
                          label: 'Add Client',
                          icon: PhosphorIconsBold.userPlus,
                          onTap: onNavigateToCustomers,
                          isPrimary: false,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $cleanOwner',
                    style: AppFonts.titleLarge(color: primaryTextColor)
                        .copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsFill.calendarBlank,
                        size: 12,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedDate,
                        style: AppFonts.labelSmall(color: secondaryTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionButton(
                          context: context,
                          label: 'Add New Job',
                          icon: PhosphorIconsBold.plus,
                          onTap: () =>
                              context.push(RoutePaths.merchantCreateJob),
                          isPrimary: true,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          context: context,
                          label: 'Create Invoice',
                          icon: PhosphorIconsBold.receipt,
                          onTap: onNavigateToInvoices,
                          isPrimary: false,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          context: context,
                          label: 'Add Client',
                          icon: PhosphorIconsBold.userPlus,
                          onTap: onNavigateToCustomers,
                          isPrimary: false,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              PhosphorIcon(
                PhosphorIconsRegular.slidersHorizontal,
                size: 14,
                color: secondaryTextColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Reporting Period:',
                style: AppFonts.labelSmall(color: secondaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: DashboardTimeRange.values.map((range) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _buildTimeChip(context, range, isDark),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
