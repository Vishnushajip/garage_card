import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ClayTooltip extends StatelessWidget {
  const ClayTooltip({
    super.key,
    required this.message,
    this.child,
    this.iconSize = 15.0,
  });

  final String message;
  final Widget? child;
  final double iconSize;

  void _showInfoDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF181F2C)
              : const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const PhosphorIcon(
                  PhosphorIconsFill.info,
                  color: AppColors.accentBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Metric Information',
                style: AppFonts.titleSmall(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppFonts.bodyMedium(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final trigger =
        child ??
        IconButton(
          onPressed: () => _showInfoDialog(context),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(
            width: iconSize + 10,
            height: iconSize + 10,
          ),
          visualDensity: VisualDensity.compact,
          icon: PhosphorIcon(
            PhosphorIconsRegular.info,
            size: iconSize,
            color: isDark
                ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                : AppColors.textSecondaryLight.withValues(alpha: 0.7),
          ),
        );

    return Tooltip(
      message: message,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      preferBelow: false,
      verticalOffset: 12,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      textStyle: AppFonts.labelSmall(color: Colors.white)
          .copyWith(height: 1.35, fontWeight: FontWeight.w500),
      child: trigger,
    );
  }
}
