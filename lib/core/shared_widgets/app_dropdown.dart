import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../fonts/app_fonts.dart';

class AppDropdownItem<T> {
  const AppDropdownItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String title;
  final String? subtitle;
  final Widget? icon;
}

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.hint = 'Select an option',
    this.errorText,
    this.prefixIcon,
    this.enabled = true,
    this.isLoading = false,
    this.isClearable = false,
    this.required = false,
  });

  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String hint;
  final String? errorText;
  final Widget? prefixIcon;
  final bool enabled;
  final bool isLoading;
  final bool isClearable;
  final bool required;

  void _showSelectionModal(BuildContext context) {
    if (!enabled || isLoading) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final modalBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (modalContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label ?? hint,
                        style: AppFonts.titleLarge(color: primaryTextColor),
                      ),
                      if (isClearable && value != null)
                        TextButton(
                          onPressed: () {
                            Navigator.pop(modalContext);
                            onChanged?.call(null);
                          },
                          child: Text(
                            'Clear',
                            style: AppFonts.labelLarge(color: AppColors.error),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No options available',
                      style: AppFonts.bodyMedium(color: secondaryTextColor),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final item = items[index];
                        final isSelected = item.value == value;

                        return ListTile(
                          onTap: () {
                            Navigator.pop(modalContext);
                            onChanged?.call(item.value);
                          },
                          leading: item.icon,
                          title: Text(
                            item.title,
                            style:
                                AppFonts.bodyLarge(
                                  color: isSelected
                                      ? AppColors.accentBlue
                                      : primaryTextColor,
                                ).copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                          ),
                          subtitle: item.subtitle != null
                              ? Text(
                                  item.subtitle!,
                                  style: AppFonts.labelSmall(
                                    color: secondaryTextColor,
                                  ),
                                )
                              : null,
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.accentBlue,
                                  size: 22,
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final fillBg = isDark ? AppColors.inputFillDark : AppColors.inputFillLight;
    final borderColor = errorText != null
        ? AppColors.error
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final selectedItem = items.cast<AppDropdownItem<T>?>().firstWhere(
      (element) => element?.value == value,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label!, style: AppFonts.labelLarge(color: primaryTextColor)),
              if (required) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
        ],
        InkWell(
          onTap: enabled && !isLoading
              ? () => _showSelectionModal(context)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: enabled ? fillBg : borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: errorText != null ? 1.4 : 1.2,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: selectedItem != null
                      ? Text(
                          selectedItem.title,
                          style: AppFonts.bodyLarge(color: primaryTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          hint,
                          style: AppFonts.bodyMedium(color: secondaryTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: secondaryTextColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
