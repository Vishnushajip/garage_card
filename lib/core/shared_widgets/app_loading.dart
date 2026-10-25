import 'package:flutter/material.dart';
import '../branding/app_logo.dart';
import '../colors/app_colors.dart';
import '../fonts/app_fonts.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
    this.showLogo = false,
  });

  final String? message;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            const AppLogo(size: 64),
            const SizedBox(height: 24),
          ],
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppFonts.bodyMedium(color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
