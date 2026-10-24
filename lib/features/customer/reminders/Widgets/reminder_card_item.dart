import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/models/service_reminder_model.dart';

class ReminderCardItem extends StatelessWidget {
  const ReminderCardItem({
    super.key,
    required this.reminder,
  });

  final ServiceReminderModel reminder;

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: AppFonts.titleMedium(color: primaryTextColor),
                  ),
                ),
                AppStatusBadge(
                  status: reminder.isOverdue ? 'overdue' : reminder.status,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              reminder.vehicleDisplay,
              style: AppFonts.bodyMedium(color: secondaryTextColor),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 16,
                  color: reminder.isOverdue
                      ? AppColors.error
                      : AppColors.accentBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  'Due: ${DateFormatter.formatDate(reminder.dueDate)} (${DateFormatter.formatRelative(reminder.dueDate)})',
                  style: AppFonts.labelSmall(
                    color: reminder.isOverdue
                        ? AppColors.error
                        : secondaryTextColor,
                  ),
                ),
                if (reminder.dueMileage > 0) ...[
                  const SizedBox(width: 12),
                  Text(
                    '• ${reminder.dueMileage} km',
                    style: AppFonts.labelSmall(color: secondaryTextColor),
                  ),
                ],
              ],
            ),
            if (reminder.isCustomerReported) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Self-reported external maintenance record',
                  style: AppFonts.labelSmall(color: secondaryTextColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
