import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/features/shared/models/job_status_history_model.dart';

class StatusTimelineView extends StatelessWidget {
  const StatusTimelineView({super.key, required this.history});

  final List<JobStatusHistoryModel> history;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No history recorded yet.',
          style: AppFonts.bodyMedium(color: secondaryTextColor),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final isLatest = index == 0;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLatest
                          ? AppColors.accentBlue
                          : AppColors.borderLight,
                      border: Border.all(
                        color: isLatest
                            ? AppColors.accentBlueLight
                            : AppColors.borderDark,
                        width: 2,
                      ),
                    ),
                  ),
                  if (index < history.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.toStatus.toUpperCase(),
                            style: AppFonts.labelLarge(
                              color: isLatest
                                  ? AppColors.accentBlue
                                  : primaryTextColor,
                            ),
                          ),
                          Text(
                            DateFormatter.formatDateTime(item.timestamp),
                            style: AppFonts.labelSmall(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      if (item.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.notes,
                          style: AppFonts.bodyMedium(color: secondaryTextColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
