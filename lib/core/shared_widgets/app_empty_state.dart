import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_state_layout_size.dart';

export 'app_state_layout_size.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.description,
    this.icon = Icons.inbox_rounded,
    this.customIllustration,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.layoutSize = AppStateLayoutSize.standard,
    this.iconColor,
    this.iconBackgroundColor,
  });

  final String title;
  final String? message;
  final String? description;
  final IconData icon;
  final Widget? customIllustration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final AppStateLayoutSize layoutSize;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  String? get _effectiveDescription => description ?? message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final double padding = switch (layoutSize) {
      AppStateLayoutSize.compact => 16.0,
      AppStateLayoutSize.standard => 28.0,
      AppStateLayoutSize.fullScreen => 36.0,
    };

    final double iconSize = switch (layoutSize) {
      AppStateLayoutSize.compact => 32.0,
      AppStateLayoutSize.standard => 48.0,
      AppStateLayoutSize.fullScreen => 56.0,
    };

    final double circlePadding = switch (layoutSize) {
      AppStateLayoutSize.compact => 12.0,
      AppStateLayoutSize.standard => 20.0,
      AppStateLayoutSize.fullScreen => 24.0,
    };

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (customIllustration != null)
          customIllustration!
        else
          Container(
            padding: EdgeInsets.all(circlePadding),
            decoration: BoxDecoration(
              color:
                  iconBackgroundColor ??
                  (isDark ? AppColors.cardDark : AppColors.inputFillLight),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? secondaryTextColor,
            ),
          ),
        SizedBox(height: layoutSize == AppStateLayoutSize.compact ? 12 : 20),
        Text(
          context.tr(title),
          style: layoutSize == AppStateLayoutSize.compact
              ? AppFonts.titleMedium(color: primaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold)
              : AppFonts.titleLarge(color: primaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (_effectiveDescription != null) ...[
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              context.tr(_effectiveDescription!),
              style: layoutSize == AppStateLayoutSize.compact
                  ? AppFonts.bodySmall(color: secondaryTextColor)
                  : AppFonts.bodyMedium(color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: layoutSize == AppStateLayoutSize.compact ? 16 : 24),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppButton(
                label: context.tr(actionLabel!),
                onPressed: onAction,
                variant: AppButtonVariant.primary,
                height: layoutSize == AppStateLayoutSize.compact ? 38 : 46,
              ),
              if (secondaryActionLabel != null && onSecondaryAction != null)
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(
                    context.tr(secondaryActionLabel!),
                    style: AppFonts.labelLarge(color: AppColors.accentBlue),
                  ),
                ),
            ],
          ),
        ],
      ],
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: content,
        ),
      ),
    );
  }
}
