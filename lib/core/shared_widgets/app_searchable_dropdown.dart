import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../fonts/app_fonts.dart';
import 'app_dropdown.dart';

class AppSearchableDropdown<T> extends StatefulWidget {
  const AppSearchableDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.hint = 'Select an option',
    this.searchHint = 'Search...',
    this.errorText,
    this.prefixIcon,
    this.enabled = true,
    this.required = false,
  });

  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String hint;
  final String searchHint;
  final String? errorText;
  final Widget? prefixIcon;
  final bool enabled;
  final bool required;

  @override
  State<AppSearchableDropdown<T>> createState() =>
      _AppSearchableDropdownState<T>();
}

class _AppSearchableDropdownState<T> extends State<AppSearchableDropdown<T>> {
  void _openSearchDialog(BuildContext context) {
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
      isScrollControlled: true,
      backgroundColor: modalBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _SearchSheetContent<T>(
          items: widget.items,
          selectedValue: widget.value,
          title: widget.label ?? widget.hint,
          searchHint: widget.searchHint,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
          isDark: isDark,
          onSelected: (val) {
            Navigator.pop(ctx);
            widget.onChanged?.call(val);
          },
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
    final borderColor = widget.errorText != null
        ? AppColors.error
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final selectedItem = widget.items.cast<AppDropdownItem<T>?>().firstWhere(
      (e) => e?.value == widget.value,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label!,
                style: AppFonts.labelLarge(color: primaryTextColor),
              ),
              if (widget.required) ...[
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
          onTap: widget.enabled ? () => _openSearchDialog(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? fillBg
                  : borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: widget.errorText != null ? 1.4 : 1.2,
              ),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  widget.prefixIcon!,
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
                          widget.hint,
                          style: AppFonts.bodyMedium(color: secondaryTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                Icon(Icons.search_rounded, color: secondaryTextColor, size: 20),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _SearchSheetContent<T> extends StatefulWidget {
  const _SearchSheetContent({
    required this.items,
    required this.selectedValue,
    required this.title,
    required this.searchHint,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.isDark,
    required this.onSelected,
  });

  final List<AppDropdownItem<T>> items;
  final T? selectedValue;
  final String title;
  final String searchHint;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final bool isDark;
  final ValueChanged<T> onSelected;

  @override
  State<_SearchSheetContent<T>> createState() => _SearchSheetContentState<T>();
}

class _SearchSheetContentState<T> extends State<_SearchSheetContent<T>> {
  late List<AppDropdownItem<T>> _filtered;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  void _onFilter(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filtered = widget.items.where((item) {
        final titleMatch = item.title.toLowerCase().contains(lower);
        final subMatch = item.subtitle?.toLowerCase().contains(lower) ?? false;
        return titleMatch || subMatch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.cardDark
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: AppFonts.titleLarge(color: widget.primaryTextColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: _onFilter,
                style: AppFonts.bodyLarge(color: widget.primaryTextColor),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: AppFonts.bodyMedium(
                    color: widget.secondaryTextColor,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: widget.isDark
                      ? AppColors.inputFillDark
                      : AppColors.inputFillLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 16),
            Flexible(
              child: _filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No matching results found',
                        style: AppFonts.bodyMedium(
                          color: widget.secondaryTextColor,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final item = _filtered[index];
                        final isSelected = item.value == widget.selectedValue;

                        return ListTile(
                          onTap: () => widget.onSelected(item.value),
                          leading: item.icon,
                          title: Text(
                            item.title,
                            style:
                                AppFonts.bodyLarge(
                                  color: isSelected
                                      ? AppColors.accentBlue
                                      : widget.primaryTextColor,
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
                                    color: widget.secondaryTextColor,
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
