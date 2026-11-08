import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_date_text.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_icon.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

import 'job_whatsapp_share_dialog.dart';

class ActiveJobCard extends StatelessWidget {
  const ActiveJobCard({
    super.key,
    required this.job,
    required this.onViewDetails,
  });

  final ServiceJobModel job;
  final VoidCallback onViewDetails;

  void _openWhatsApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => JobWhatsAppShareDialog(
        type: WhatsAppNotificationType.jobCreated,
        customerName: job.customerName,
        customerPhone: job.customerPhone,
        bikeNumber: job.vehicleDisplay,
        jobNumber: job.jobNumber,
        mechanic: job.technicianName,
        problem: job.complaints.join(', '),
      ),
    );
  }

  Widget _buildViewDetailsButton(
    BuildContext context, {
    EdgeInsetsGeometry? padding,
  }) {
    return OutlinedButton.icon(
      onPressed: onViewDetails,
      icon: const Icon(Icons.visibility_outlined, size: 16),
      label: Text(
        context.tr('viewDetails'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildWhatsAppButton(
    BuildContext context, {
    EdgeInsetsGeometry? padding,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _openWhatsApp(context),
      icon: const AppWhatsAppIcon(size: 16, color: Colors.white),
      label: Text(
        context.tr('update'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final sectionBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.jobNumber,
                    style: AppFonts.labelMedium(color: AppColors.accentBlue)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.vehicleDisplay,
                    style: AppFonts.titleMedium(color: primaryTextColor)
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                AppStatusBadge(status: job.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 15,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${job.customerName}${job.customerPhone.isNotEmpty ? " • ${job.customerPhone}" : ""}',
                    style: AppFonts.bodySmall(color: secondaryTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.technicianName.isNotEmpty
                        ? job.technicianName
                        : 'Unassigned',
                    style: AppFonts.labelSmall(color: AppColors.accentAmber)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Received: ',
                  style: AppFonts.labelSmall(color: secondaryTextColor),
                ),
                AppDateText(
                  date: job.createdAt,
                  style: AppFonts.labelSmall(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (job.supplementalItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+${job.supplementalItems.length} Extra Work',
                      style: AppFonts.labelSmall(color: AppColors.accentAmber)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Issue: ',
                    style: AppFonts.labelSmall(color: secondaryTextColor)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      job.complaints.isNotEmpty
                          ? job.complaints.join(', ')
                          : 'Standard Maintenance Check',
                      style: AppFonts.bodySmall(color: primaryTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 480) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 120,
                          maxWidth: 180,
                        ),
                        child: _buildViewDetailsButton(context),
                      ),
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 120,
                          maxWidth: 180,
                        ),
                        child: _buildWhatsAppButton(context),
                      ),
                    ],
                  );
                }

                if (constraints.maxWidth < 330) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildViewDetailsButton(
                        context,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildWhatsAppButton(
                        context,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildViewDetailsButton(
                        context,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildWhatsAppButton(
                        context,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
