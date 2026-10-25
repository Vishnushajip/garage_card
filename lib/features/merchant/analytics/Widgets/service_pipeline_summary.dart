import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';

class ServicePipelineSummary extends StatelessWidget {
  const ServicePipelineSummary({
    super.key,
    required this.yesterdayCompleted,
    required this.todayDeliveries,
    required this.inProgressCount,
    required this.pendingDuesCount,
  });

  final int yesterdayCompleted;
  final int todayDeliveries;
  final int inProgressCount;
  final int pendingDuesCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final count = isWide ? 4 : 2;

        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWide ? 1.8 : 1.5,
          children: [
            _buildCard(
              context,
              title: 'Completed Yesterday',
              value: '$yesterdayCompleted',
              subtitle: 'Delivered & signed off',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
            _buildCard(
              context,
              title: 'Due for Delivery Today',
              value: '$todayDeliveries',
              subtitle: 'Ready / in final testing',
              icon: Icons.alarm_rounded,
              color: AppColors.accentBlue,
            ),
            _buildCard(
              context,
              title: 'Jobs in Progress',
              value: '$inProgressCount',
              subtitle: 'Active on workshop bays',
              icon: Icons.engineering_outlined,
              color: AppColors.accentAmber,
            ),
            _buildCard(
              context,
              title: 'Payments Due',
              value: '$pendingDuesCount',
              subtitle: 'Unsettled bill balances',
              icon: Icons.receipt_long_rounded,
              color: AppColors.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Card(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppFonts.labelSmall(color: secondaryTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            Text(value, style: AppFonts.titleLarge(color: primaryTextColor)),
            Text(
              subtitle,
              style: AppFonts.labelSmall(color: secondaryTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
