import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_skeleton_loader.dart';
import 'package:garage_card/core/shared_widgets/app_state_layout_size.dart';

enum AppSkeletonType { card, list, grid, profile }

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.title,
    this.description,
    this.layoutSize = AppStateLayoutSize.standard,
    this.useSkeleton = false,
    this.skeletonType = AppSkeletonType.list,
    this.itemCount = 4,
    this.onCancel,
    this.cancelLabel = 'Cancel',
  });

  final String? title;
  final String? description;
  final AppStateLayoutSize layoutSize;
  final bool useSkeleton;
  final AppSkeletonType skeletonType;
  final int itemCount;
  final VoidCallback? onCancel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    if (useSkeleton) {
      switch (skeletonType) {
        case AppSkeletonType.card:
          return AppSkeletonLoader.card(height: 140);
        case AppSkeletonType.list:
          return AppSkeletonLoader.list(itemCount: itemCount);
        case AppSkeletonType.grid:
          return AppSkeletonLoader.grid(itemCount: itemCount);
        case AppSkeletonType.profile:
          return AppSkeletonLoader.profile();
      }
    }

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
      AppStateLayoutSize.fullScreen => 40.0,
    };

    final double spinnerSize = switch (layoutSize) {
      AppStateLayoutSize.compact => 36.0,
      AppStateLayoutSize.standard => 52.0,
      AppStateLayoutSize.fullScreen => 64.0,
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppLoading(size: spinnerSize),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                style: AppFonts.titleMedium(color: primaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: AppFonts.bodySmall(color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 18),
              TextButton(
                onPressed: onCancel,
                child: Text(
                  cancelLabel,
                  style: AppFonts.labelMedium(color: secondaryTextColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
