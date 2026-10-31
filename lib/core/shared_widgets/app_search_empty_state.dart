import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_state_layout_size.dart';

class AppSearchEmptyState extends StatelessWidget {
  const AppSearchEmptyState({
    super.key,
    this.searchQuery,
    this.title,
    this.message,
    this.hasActiveFilters = false,
    this.onClearFilters,
    this.clearFiltersLabel = 'Clear All Filters',
    this.onModifyQuery,
    this.modifyQueryLabel = 'Change Search Query',
    this.layoutSize = AppStateLayoutSize.standard,
  });

  final String? searchQuery;
  final String? title;
  final String? message;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;
  final String clearFiltersLabel;
  final VoidCallback? onModifyQuery;
  final String modifyQueryLabel;
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
        title ??
        (searchQuery != null && searchQuery!.trim().isNotEmpty
            ? 'No matches for "$searchQuery"'
            : 'No results found');

    final effectiveMessage =
        message ??
        (hasActiveFilters
            ? 'No results matched both your keywords and applied filters. Try clearing some filters or searching for broader terms.'
            : 'We could not find any records matching your search. Check for spelling errors or try different keywords.');

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
                width: layoutSize == AppStateLayoutSize.compact ? 64 : 84,
                height: layoutSize == AppStateLayoutSize.compact ? 64 : 84,
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: layoutSize == AppStateLayoutSize.compact
                            ? 34
                            : 44,
                        color: AppColors.accentAmber,
                      ),
                    ],
                  ),
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
                  effectiveMessage,
                  style: layoutSize == AppStateLayoutSize.compact
                      ? AppFonts.bodySmall(color: secondaryTextColor)
                      : AppFonts.bodyMedium(color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (hasActiveFilters && onClearFilters != null)
                    AppButton(
                      label: clearFiltersLabel,
                      icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                      onPressed: onClearFilters,
                      variant: AppButtonVariant.primary,
                      height: layoutSize == AppStateLayoutSize.compact
                          ? 38
                          : 44,
                    ),
                  if (onModifyQuery != null)
                    OutlinedButton.icon(
                      onPressed: onModifyQuery,
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: Text(
                        modifyQueryLabel,
                        style: AppFonts.labelMedium(
                          color: AppColors.accentBlue,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        side: const BorderSide(
                          color: AppColors.accentBlue,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
