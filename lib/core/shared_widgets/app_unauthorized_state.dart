import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_state_layout_size.dart';

class AppUnauthorizedState extends StatelessWidget {
  const AppUnauthorizedState({
    super.key,
    this.isSessionExpired = false,
    this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.layoutSize = AppStateLayoutSize.standard,
  });

  final bool isSessionExpired;
  final String? title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final AppStateLayoutSize layoutSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final effectiveTitle =
        title ?? (isSessionExpired ? 'Session Expired' : 'Access Restricted');

    final effectiveDescription =
        description ??
        (isSessionExpired
            ? 'Your security session has timed out. Please sign in again to access your account securely.'
            : 'You do not have authorization to view this section or document. Verify your permissions or switch accounts.');

    final effectiveActionLabel =
        actionLabel ?? (isSessionExpired ? 'Sign In Again' : 'Return to Home');

    final double padding = switch (layoutSize) {
      AppStateLayoutSize.compact => 16.0,
      AppStateLayoutSize.standard => 28.0,
      AppStateLayoutSize.fullScreen => 36.0,
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSessionExpired
                      ? AppColors.accentAmber.withValues(alpha: 0.12)
                      : AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSessionExpired
                      ? Icons.lock_clock_outlined
                      : Icons.shield_outlined,
                  size: layoutSize == AppStateLayoutSize.compact ? 36 : 46,
                  color: isSessionExpired
                      ? AppColors.accentAmber
                      : AppColors.error,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                effectiveTitle,
                style: layoutSize == AppStateLayoutSize.compact
                    ? AppFonts.titleMedium(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold)
                    : AppFonts.titleLarge(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Text(
                  effectiveDescription,
                  style: layoutSize == AppStateLayoutSize.compact
                      ? AppFonts.bodySmall(color: secondaryTextColor)
                      : AppFonts.bodyMedium(color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onAction != null) ...[
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppButton(
                      label: effectiveActionLabel,
                      onPressed: onAction,
                      variant: AppButtonVariant.primary,
                      height: layoutSize == AppStateLayoutSize.compact
                          ? 38
                          : 46,
                    ),
                    if (secondaryActionLabel != null &&
                        onSecondaryAction != null)
                      TextButton(
                        onPressed: onSecondaryAction,
                        child: Text(
                          secondaryActionLabel!,
                          style: AppFonts.labelLarge(
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
