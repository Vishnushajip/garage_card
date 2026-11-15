import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../Model/dashboard_analytics_models.dart';
import 'clay_container.dart';
import 'clay_tooltip.dart';

class MechanicProductivityCard extends StatelessWidget {
  const MechanicProductivityCard({super.key, required this.mechanics});

  final List<MechanicPerformanceMetric> mechanics;

  Color _getWorkloadColor(String status) {
    switch (status) {
      case 'Available':
        return AppColors.success;
      case 'High Workload':
        return AppColors.error;
      case 'Normal':
      default:
        return AppColors.info;
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
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6)
                      .withValues(alpha: isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: PhosphorIcon(
                    PhosphorIconsFill.wrench,
                    size: 20,
                    color: Color(0xFF8B5CF6),
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
                          'Technician Productivity & Bays',
                          style: AppFonts.titleMedium(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        const ClayTooltip(
                          message: 'Mechanic workload allocation, active job volume, and completion turnaround times.',
                          iconSize: 14,
                        ),
                      ],
                    ),
                    Text(
                      '${mechanics.length} technicians assigned across workshop bays',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (mechanics.isEmpty)
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
                      PhosphorIconsRegular.users,
                      size: 28,
                      color: secondaryTextColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No technicians assigned to active jobs',
                      style: AppFonts.bodySmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                horizontalMargin: 8,
                columnSpacing: 20,
                columns: [
                  DataColumn(
                    label: Text(
                      'Technician',
                      style: AppFonts.labelSmall(color: secondaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Active',
                      style: AppFonts.labelSmall(color: secondaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Completed',
                      style: AppFonts.labelSmall(color: secondaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Turnaround',
                      style: AppFonts.labelSmall(color: secondaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: AppFonts.labelSmall(color: secondaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: mechanics.map((m) {
                  final statusColor = _getWorkloadColor(m.workloadStatus);
                  final avgTime = m.averageCompletionHours != null
                      ? '${m.averageCompletionHours!.toStringAsFixed(1)} hrs'
                      : 'N/A';

                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              m.name,
                              style: AppFonts.labelMedium(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              m.specialization,
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ).copyWith(fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          '${m.activeJobsCount}',
                          style: AppFonts.labelMedium(
                            color: m.activeJobsCount > 0
                                ? AppColors.info
                                : secondaryTextColor,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${m.completedJobsCount}',
                          style: AppFonts.labelMedium(color: AppColors.success)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(
                        Text(
                          avgTime,
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            m.workloadStatus,
                            style: AppFonts.labelSmall(color: statusColor)
                                .copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
