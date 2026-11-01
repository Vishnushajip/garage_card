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
    this.iconUrl,
    this.selectedIconUrl,
    this.tintNetworkIcon = true,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int? badgeCount;
  final String? iconUrl;
  final String? selectedIconUrl;
  final bool tintNetworkIcon;
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
    this.width = 248,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.04),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryRed.withValues(
                      alpha: isDark ? 0.20 : 0.09,
                    ),
                    AppColors.primaryRed.withValues(
                      alpha: isDark ? 0.06 : 0.02,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primaryRed.withValues(
                    alpha: isDark ? 0.28 : 0.16,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const AppLogo(size: 40, showBadge: true),
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
                                letterSpacing: -0.4,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (portalSubtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              portalSubtitle!,
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ).copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
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
            Padding(padding: const EdgeInsets.all(14), child: footer!),
          ],
        ],
      ),
    );
  }
}

class _SidebarIcon extends StatelessWidget {
  const _SidebarIcon({
    required this.url,
    required this.fallback,
    required this.color,
    required this.tint,
    this.size = 20,
  });

  final String? url;
  final IconData fallback;
  final Color color;
  final bool tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Icon(fallback, size: size, color: color);
    final source = url;

    if (source == null || source.trim().isEmpty) {
      return fallbackIcon;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        source,
        key: ValueKey(source),
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: tint ? color : null,
        colorBlendMode: tint ? BlendMode.srcIn : null,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => fallbackIcon,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallbackIcon;
        },
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
    final primaryText = widget.isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = widget.isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    Color? bgColor;
    Gradient? gradient;
    Border border;
    Color iconColor;
    Color iconBoxColor;
    Color textColor;
    FontWeight fontWeight;
    List<BoxShadow>? shadows;

    if (widget.isSelected) {
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryRed,
          Color.lerp(AppColors.primaryRed, Colors.black, 0.22)!,
        ],
      );
      border = Border.all(color: Colors.transparent, width: 1);
      iconColor = Colors.white;
      iconBoxColor = Colors.white.withValues(alpha: 0.2);
      textColor = Colors.white;
      fontWeight = FontWeight.w700;
      shadows = [
        BoxShadow(
          color: AppColors.primaryRed.withValues(
            alpha: widget.isDark ? 0.4 : 0.32,
          ),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
    } else if (_isHovered) {
      bgColor = widget.isDark
          ? Colors.white.withValues(alpha: 0.06)
          : AppColors.primaryRed.withValues(alpha: 0.05);
      border = Border.all(
        color: AppColors.primaryRed.withValues(alpha: 0.18),
        width: 1,
      );
      iconColor = AppColors.primaryRed;
      iconBoxColor = AppColors.primaryRed.withValues(alpha: 0.12);
      textColor = primaryText;
      fontWeight = FontWeight.w600;
    } else {
      bgColor = Colors.transparent;
      border = Border.all(color: Colors.transparent, width: 1);
      iconColor = secondaryText;
      iconBoxColor = widget.isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04);
      textColor = secondaryText;
      fontWeight = FontWeight.w500;
    }

    final hasBadge =
        widget.item.badgeCount != null && widget.item.badgeCount! > 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: gradient == null ? bgColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            border: border,
            boxShadow: shadows,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBoxColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: _SidebarIcon(
                  url: widget.isSelected
                      ? (widget.item.selectedIconUrl ?? widget.item.iconUrl)
                      : widget.item.iconUrl,
                  fallback: widget.isSelected
                      ? widget.item.selectedIcon
                      : widget.item.icon,
                  color: iconColor,
                  tint: widget.item.tintNetworkIcon,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: AppFonts.labelLarge(color: textColor)
                      .copyWith(fontWeight: fontWeight, letterSpacing: -0.1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasBadge)
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white
                        : AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.item.badgeCount! > 99
                        ? '99+'
                        : widget.item.badgeCount.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.isSelected
                          ? AppColors.primaryRed
                          : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
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
