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
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showAccountSwitch = false,
    this.showNotifications = false,
    this.unreadNotificationCount = 0,
    this.onNotificationTap,
    this.bottom,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showAccountSwitch;
  final bool showNotifications;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationTap;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  @override
  Size get preferredSize =>
      Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final canPop = Navigator.of(context).canPop();
    final authState = ref.watch(authViewModelProvider);
    final isMerchant = authState.activeExperience == 'merchant';

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && canPop) {
      effectiveLeading = Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: primaryTextColor,
            ),
          ),
        ),
      );
    }

    final effectiveActions = <Widget>[...?actions];

    if (showAccountSwitch) {
      effectiveActions.insert(
        0,
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                final target = isMerchant ? 'customer' : 'merchant';
                await ref
                    .read(authViewModelProvider.notifier)
                    .switchExperience(target);
                if (context.mounted) {
                  context.go(
                    target == 'merchant'
                        ? RoutePaths.merchant
                        : RoutePaths.customer,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isMerchant
                      ? AppColors.accentAmber.withValues(alpha: 0.12)
                      : AppColors.primaryRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isMerchant
                        ? AppColors.accentAmber.withValues(alpha: 0.4)
                        : AppColors.primaryRed.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMerchant
                          ? Icons.storefront_rounded
                          : Icons.directions_car_rounded,
                      size: 14,
                      color: isMerchant
                          ? AppColors.accentAmber
                          : AppColors.primaryRed,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isMerchant ? 'Merchant' : 'Customer',
                      style: AppFonts.labelSmall(
                        color: isMerchant
                            ? AppColors.accentAmber
                            : AppColors.primaryRed,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: isMerchant
                          ? AppColors.accentAmber
                          : AppColors.primaryRed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

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
                height: 63,
                child: NavigationToolbar(
                  leading: effectiveLeading,
                  middle: Column(
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
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: effectiveActions,
                  ),
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
