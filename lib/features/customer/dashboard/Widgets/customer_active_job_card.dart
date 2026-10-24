import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class CustomerActiveJobCard extends StatelessWidget {
  const CustomerActiveJobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  final ServiceJobModel job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job.jobNumber,
                    style: AppFonts.labelSmall(color: AppColors.accentBlue)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppStatusBadge(status: job.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.vehicleDisplay,
                style: AppFonts.titleMedium(color: primaryTextColor),
              ),
              if (job.complaints.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  job.complaints.first,
                  style: AppFonts.bodyMedium(color: secondaryTextColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 16, color: AppColors.accentBlue),
                      const SizedBox(width: 6),
                      Text(
                        job.estimatedCompletionDate != null
                            ? 'Est: ${DateFormatter.formatDateTime(job.estimatedCompletionDate)}'
                            : 'Updated: ${DateFormatter.formatRelative(job.updatedAt)}',
                        style: AppFonts.labelSmall(color: secondaryTextColor),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.accentBlue,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
