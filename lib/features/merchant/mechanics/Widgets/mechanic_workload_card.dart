import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';

import '../Model/mechanic_workload_model.dart';

class MechanicWorkloadCard extends StatelessWidget {
  const MechanicWorkloadCard({
    super.key,
    required this.workload,
    required this.enableIncentives,
    this.onTapJob,
  });

  final MechanicWorkloadModel workload;
  final bool enableIncentives;
  final ValueChanged<String>? onTapJob;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final sectionBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final m = workload.mechanic;

    return Card(
      color: cardBg,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.accentBlue.withValues(alpha: 0.15),
                  child: Text(
                    m.name.isNotEmpty ? m.name[0].toUpperCase() : 'M',
                    style: AppFonts.titleMedium(color: AppColors.accentBlue)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: AppFonts.titleMedium(color: primaryText)
                            .copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (m.phone.isNotEmpty) ...[
                            Icon(
                              Icons.phone_rounded,
                              size: 13,
                              color: secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              m.phone,
                              style: AppFonts.labelSmall(color: secondaryText),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              m.specialization.isNotEmpty
                                  ? m.specialization
                                  : 'General Specialist',
                              style: AppFonts.labelSmall(
                                color: AppColors.accentAmber,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: workload.activeJobsCount > 0
                        ? AppColors.primaryRed.withValues(alpha: 0.12)
                        : AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        workload.activeJobsCount > 0
                            ? Icons.engineering_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 14,
                        color: workload.activeJobsCount > 0
                            ? AppColors.primaryRed
                            : AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workload.activeJobsCount} Active',
                        style: AppFonts.labelSmall(
                          color: workload.activeJobsCount > 0
                              ? AppColors.primaryRed
                              : AppColors.success,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('completedThisMonth'),
                          style: AppFonts.labelSmall(color: secondaryText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${workload.completedJobsCount} Jobs',
                          style: AppFonts.titleMedium(color: primaryText)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (enableIncentives) ...[
                    Container(width: 1, height: 36, color: borderColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('earnedCommission'),
                            style: AppFonts.labelSmall(color: secondaryText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(workload.earnedCommission),
                            style: AppFonts.titleMedium(
                              color: AppColors.success,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (workload.activeJobs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Assigned Active Vehicles:',
                style: AppFonts.labelSmall(color: secondaryText)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: workload.activeJobs.map((j) {
                  return InkWell(
                    onTap: onTapJob != null ? () => onTapJob!(j.id) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.two_wheeler_rounded,
                            size: 14,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            j.vehicleDisplay.isNotEmpty
                                ? j.vehicleDisplay
                                : j.jobNumber,
                            style: AppFonts.labelSmall(
                              color: AppColors.accentBlue,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
