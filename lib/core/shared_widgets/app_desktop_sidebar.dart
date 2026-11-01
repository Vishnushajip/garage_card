import 'package:flutter/material.dart';
import 'package:garage_card/core/branding/app_logo.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';

class AppDesktopSidebarItem {
  const AppDesktopSidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int? badgeCount;
}

class AppDesktopSidebar extends StatelessWidget {
  const AppDesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.items,
    this.portalTitle,
    this.portalSubtitle,
    this.footer,
    this.width = 240,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppDesktopSidebarItem> items;
  final String? portalTitle;
  final String? portalSubtitle;
  final Widget? footer;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            child: Row(
              children: [
                const AppLogo(size: 38, showBadge: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        portalTitle ?? 'WeFix',
                        style: AppFonts.titleMedium(color: primaryTextColor)
                            .copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (portalSubtitle != null)
                        Text(
                          portalSubtitle!,
                          style: AppFonts.labelSmall(color: secondaryTextColor)
                              .copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return _SidebarTile(
                  item: item,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => onDestinationSelected(index),
                );
              },
            ),
          ),
          if (footer != null) ...[
            Divider(height: 1, thickness: 1, color: borderColor),
            Padding(padding: const EdgeInsets.all(12), child: footer!),
          ],
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  const _SidebarTile({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final AppDesktopSidebarItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Border? border;
    Color iconColor;
    Color textColor;
    FontWeight fontWeight;

    if (widget.isSelected) {
      bgColor = widget.isDark
          ? AppColors.primaryRed.withValues(alpha: 0.18)
          : AppColors.primaryRed.withValues(alpha: 0.10);
      border = Border.all(
        color: AppColors.primaryRed.withValues(
          alpha: widget.isDark ? 0.35 : 0.25,
        ),
        width: 1.2,
      );
      iconColor = AppColors.primaryRed;
      textColor = widget.isDark ? Colors.white : AppColors.primaryRed;
      fontWeight = FontWeight.w700;
    } else if (_isHovered) {
      bgColor = widget.isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04);
      border = Border.all(
        color: widget.isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 1,
      );
      iconColor = widget.isDark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimaryLight;
      textColor = widget.isDark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimaryLight;
      fontWeight = FontWeight.w600;
    } else {
      bgColor = Colors.transparent;
      border = Border.all(color: Colors.transparent, width: 1);
      iconColor = widget.isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight;
      textColor = widget.isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight;
      fontWeight = FontWeight.w500;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 3.5,
                height: widget.isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.isSelected ? widget.item.selectedIcon : widget.item.icon,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: AppFonts.labelLarge(color: textColor)
                      .copyWith(fontWeight: fontWeight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.item.badgeCount != null && widget.item.badgeCount! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.item.badgeCount! > 99
                        ? '99+'
                        : widget.item.badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
