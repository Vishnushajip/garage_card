import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class MerchantJobRow extends StatelessWidget {
  const MerchantJobRow({super.key, required this.job, required this.onTap});

  final ServiceJobModel job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Row(
        children: [
          Text(
            job.jobNumber,
            style: AppFonts.labelLarge(color: AppColors.accentBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              job.vehicleDisplay,
              style: AppFonts.bodyLarge(color: primaryTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(
        'Customer: ${job.customerName} • ${DateFormatter.formatRelative(job.updatedAt)}',
        style: AppFonts.labelSmall(color: secondaryTextColor),
      ),
      trailing: AppStatusBadge(status: job.status),
    );
  }
}
