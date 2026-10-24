import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../fonts/app_fonts.dart';
import 'app_button.dart';

class AppDialog {
  AppDialog._();

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            title,
            style: AppFonts.titleLarge(color: primaryTextColor),
          ),
          content: Text(
            message,
            style: AppFonts.bodyMedium(color: secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(
                cancelLabel,
                style: AppFonts.labelLarge(color: secondaryTextColor),
              ),
            ),
            AppButton(
              label: confirmLabel,
              onPressed: () => Navigator.pop(dialogCtx, true),
              variant: isDestructive
                  ? AppButtonVariant.danger
                  : AppButtonVariant.primary,
              height: 40,
            ),
          ],
        );
      },
    );
  }

  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    String okLabel = 'OK',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            title,
            style: AppFonts.titleLarge(color: primaryTextColor),
          ),
          content: Text(
            message,
            style: AppFonts.bodyMedium(color: secondaryTextColor),
          ),
          actions: [
            AppButton(
              label: okLabel,
              onPressed: () => Navigator.pop(dialogCtx),
              height: 40,
            ),
          ],
        );
      },
    );
  }
}
