import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';

class GarageHoursEditor extends StatelessWidget {
  const GarageHoursEditor({
    super.key,
    required this.hours,
    required this.onTap,
  });

  final String hours;
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.access_time_rounded,
          color: AppColors.accentBlue,
          size: 20,
        ),
      ),
      title: Text(
        'Operating Schedule',
        style: AppFonts.titleMedium(color: primaryTextColor),
      ),
      subtitle: Text(
        hours,
        style: AppFonts.labelSmall(color: secondaryTextColor),
      ),
      trailing: const Icon(Icons.edit_outlined, size: 18),
    );
  }
}
