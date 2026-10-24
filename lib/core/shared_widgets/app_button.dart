import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../fonts/app_fonts.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  danger,
  ghost,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 48,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.accentBlue;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = isDark ? AppColors.cardDark : AppColors.backgroundLight;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        border = BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        );
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.accentBlueLight : AppColors.accentBlue;
        border = BorderSide(
          color: isDark ? AppColors.accentBlueLight : AppColors.accentBlue,
          width: 1.5,
        );
        break;
      case AppButtonVariant.danger:
        bg = AppColors.error;
        fg = Colors.white;
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      shadowColor: Colors.transparent,
      disabledBackgroundColor: bg.withValues(alpha: 0.5),
      disabledForegroundColor: fg.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: border ?? BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
    );

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppFonts.labelLarge(color: fg).copyWith(
            fontSize: fontSize ?? 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    Widget btn = SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: buttonStyle,
        child: content,
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}
