import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'clay_container.dart';
import 'clay_tooltip.dart';

class RecentJobsSegmentedFeed extends StatelessWidget {
  const RecentJobsSegmentedFeed({
    super.key,
    required this.jobs,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onJobSelected,
    required this.onNavigateToJobs,
  });

  final List<ServiceJobModel> jobs;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onJobSelected;
  final VoidCallback onNavigateToJobs;

  static const List<(String, String)> _filters = [
    ('all', 'All Active'),
    ('in_progress', 'In Progress'),
    ('pending_assignment', 'Unassigned'),
    ('ready_for_pickup', 'Ready'),
    ('completed', 'Completed'),
    ('overdue', 'Overdue'),
  ];

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
                          PhosphorIconsFill.car,
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
                                'Workshop Jobs & Operations',
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 6),
                              const ClayTooltip(
                                message: 'Live repair pipeline with quick filtering by status, assignment, and completion.',
                                iconSize: 14,
                              ),
                            ],
                          ),
                          Text(
                            'Real-time status across garage bays',
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
                onPressed: onNavigateToJobs,
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
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isSelected = selectedFilter == f.$1;
                final chipColor = isSelected
                    ? AppColors.accentBlue
                    : (isDark
                          ? const Color(0xFF1E2638)
                          : const Color(0xFFF1F5F9));
                final textColor = isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onFilterChanged(f.$1),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentBlue
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.8)),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        f.$2,
                        style: AppFonts.labelSmall(color: textColor).copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          if (jobs.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF121722)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhosphorIcon(
                      PhosphorIconsRegular.checkCircle,
                      size: 28,
                      color: secondaryTextColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No jobs found matching selected filter',
                      style: AppFonts.bodySmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: jobs.take(6).map((job) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => onJobSelected(job.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2638)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                job.jobNumber,
                                style: AppFonts.labelLarge(
                                  color: AppColors.accentBlue,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              AppStatusBadge(status: job.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job.vehicleDisplay,
                            style: AppFonts.titleSmall(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              PhosphorIcon(
                                PhosphorIconsFill.user,
                                size: 12,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  job.customerName,
                                  style: AppFonts.labelSmall(
                                    color: secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (job.technicianName.isNotEmpty) ...[
                                PhosphorIcon(
                                  PhosphorIconsFill.wrench,
                                  size: 12,
                                  color: AppColors.accentBlue,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    job.technicianName,
                                    style: AppFonts.labelSmall(
                                      color: AppColors.accentBlue,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Unassigned',
                                    style: AppFonts.labelSmall(
                                      color: AppColors.error,
                                    ).copyWith(fontSize: 10),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.formatRelative(
                                  job.updatedAt ?? job.createdAt,
                                ),
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ).copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
