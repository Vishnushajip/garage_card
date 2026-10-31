import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:go_router/go_router.dart';

class AppCustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppCustomAppBar({
    super.key,
    this.title = '',
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.actions,
    this.showAccountSwitch = false,
    this.showNotifications = false,
    this.unreadNotificationCount = 0,
    this.onNotificationTap,
    this.bottom,
    this.centerTitle = false,
    this.backgroundColor,
  });

  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showAccountSwitch;
  final bool showNotifications;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationTap;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final Color? backgroundColor;

  @override
  Size get preferredSize =>
      Size.fromHeight(60 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor =
        backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final canPop = Navigator.of(context).canPop();
    final authState = ref.watch(authViewModelProvider);
    final isMerchant = authState.activeExperience == 'merchant';

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && canPop) {
      effectiveLeading = Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: primaryTextColor,
              ),
            ),
          ),
        ),
      );
    }

    final effectiveActions = <Widget>[...?actions];

    if (showNotifications) {
      effectiveActions.add(
        IconButton(
          tooltip: 'Notifications',
          onPressed:
              onNotificationTap ??
              () {
                context.push(
                  isMerchant
                      ? RoutePaths.merchantNotifications
                      : RoutePaths.customerNotifications,
                );
              },
          icon: Badge(
            isLabelVisible: unreadNotificationCount > 0,
            label: Text(
              unreadNotificationCount > 99
                  ? '99+'
                  : unreadNotificationCount.toString(),
            ),
            backgroundColor: AppColors.primaryRed,
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
      );
    }

    Widget? effectiveMiddle = titleWidget;
    if (effectiveMiddle == null && title.isNotEmpty) {
      effectiveMiddle = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.titleMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              subtitle!,
              style: AppFonts.labelSmall(color: secondaryTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    }

    final Widget? effectiveTrailing = effectiveActions.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: effectiveActions,
            ),
          )
        : null;

    final barWidget = Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: ClipRect(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 59,
                child: NavigationToolbar(
                  leading: effectiveLeading,
                  middle: effectiveMiddle,
                  trailing: effectiveTrailing,
                  centerMiddle: centerTitle,
                  middleSpacing: 12,
                ),
              ),
              ?bottom,
            ],
          ),
        ),
      ),
    );

    return AppResponsiveLayout(
      maxWidth: 1200,
      padding: EdgeInsets.zero,
      child: barWidget,
    );
  }
}
