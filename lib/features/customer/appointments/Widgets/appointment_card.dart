import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment});

  final AppointmentModel appointment;

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

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 12),
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
                Row(
                  children: [
                    const Icon(
                      Icons.event_available_rounded,
                      size: 18,
                      color: AppColors.accentBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormatter.formatDate(appointment.preferredDate)} (${appointment.preferredTime})',
                      style: AppFonts.labelLarge(color: primaryTextColor),
                    ),
                  ],
                ),
                AppStatusBadge(status: appointment.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.vehicleInfo,
              style: AppFonts.titleMedium(color: primaryTextColor),
            ),
            const SizedBox(height: 4),
            Text(
              appointment.issueDescription,
              style: AppFonts.bodyMedium(color: secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
