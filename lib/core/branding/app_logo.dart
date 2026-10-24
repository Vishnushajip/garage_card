import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.showBadge = true,
    this.customColor,
  });

  final double size;
  final bool showBadge;
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = customColor ??
        (isDark ? AppColors.accentBlueLight : AppColors.accentBlue);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: showBadge
            ? (isDark ? AppColors.surfaceDark : AppColors.cardLight)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: showBadge
            ? Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.5,
              )
            : null,
        boxShadow: showBadge
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          Icons.build_circle_rounded,
          size: size * 0.58,
          color: primaryColor,
        ),
      ),
    );
  }
}
