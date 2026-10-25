import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';

class DailyBriefingModal extends StatelessWidget {
  const DailyBriefingModal({
    super.key,
    required this.todayDeliveries,
    required this.pendingDues,
    required this.yesterdayCompleted,
    required this.onDismiss,
    required this.onViewTodo,
  });

  final int todayDeliveries;
  final int pendingDues;
  final int yesterdayCompleted;
  final VoidCallback onDismiss;
  final VoidCallback onViewTodo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentBlue.withValues(alpha: 0.15),
            AppColors.accentAmber.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: AppColors.accentAmber,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Good Morning! Daily Garage Briefing',
                      style: AppFonts.titleMedium(color: AppColors.accentBlue),
                    ),
                    InkWell(
                      onTap: onDismiss,
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$todayDeliveries vehicle(s) scheduled for delivery today. $yesterdayCompleted vehicle(s) were completed yesterday. $pendingDues payment balances pending.',
                  style: AppFonts.bodyMedium(color: primaryTextColor),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: onViewTodo,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: const Text('View Today\'s Delivery & Task Pipeline'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
