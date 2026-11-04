import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/branding/app_logo.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/app_flaticon_icon.dart';
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
    this.showLogo = true,
    this.showAccountSwitch = false,
    this.showNotifications = false,
    this.unreadNotificationCount = 0,
    this.onNotificationTap,
    this.showChat = false,
    this.unreadChatCount = 0,
    this.onChatTap,
    this.bottom,
    this.centerTitle = false,
    this.backgroundColor,
  });

  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLogo;
  final bool showAccountSwitch;
  final bool showNotifications;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationTap;
  final bool showChat;
  final int unreadChatCount;
  final VoidCallback? onChatTap;
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

    Widget? effectiveLeading;
    if (leading != null) {
      effectiveLeading = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
        child: leading!,
      );
    } else if (canPop) {
      effectiveLeading = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
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
          if (showLogo) ...[
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                context.go(
                  isMerchant ? RoutePaths.merchant : RoutePaths.customer,
                );
              },
              child: const AppLogo(size: 28, showBadge: true),
            ),
          ],
        ],
      );
    } else if (showLogo) {
      effectiveLeading = InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          context.go(isMerchant ? RoutePaths.merchant : RoutePaths.customer);
        },
        child: const AppLogo(size: 32, showBadge: true),
      );
    }

    final effectiveActions = <Widget>[];

    if (showChat) {
      effectiveActions.add(
        IconButton(
          tooltip: context.tr('messages'),
          onPressed: onChatTap ?? () => context.push(RoutePaths.chatList),
          icon: Badge(
            isLabelVisible: unreadChatCount > 0,
            label: Text(
              unreadChatCount > 99 ? '99+' : unreadChatCount.toString(),
            ),
            backgroundColor: AppColors.primaryRed,
            child: AppFlaticonIcon(
              url: AppFlaticonIcon.chatUrl,
              fallbackIcon: Icons.chat_bubble_outline_rounded,
              size: 21,
              color: primaryTextColor,
            ),
          ),
        ),
      );
    }

    if (showNotifications) {
      effectiveActions.add(
        IconButton(
          tooltip: context.tr('notifications'),
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
            child: AppFlaticonIcon(
              url: AppFlaticonIcon.notificationUrl,
              fallbackIcon: Icons.notifications_outlined,
              size: 21,
              color: primaryTextColor,
            ),
          ),
        ),
      );
    }

    if (actions != null) {
      effectiveActions.addAll(actions!);
    }

    Widget? effectiveMiddle = titleWidget;
    if (effectiveMiddle == null && title.isNotEmpty) {
      final localizedTitle = context.tr(title);
      final localizedSubtitle = subtitle != null && subtitle!.isNotEmpty
          ? context.tr(subtitle!)
          : null;

      effectiveMiddle = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            localizedTitle,
            style: AppFonts.titleMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (localizedSubtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              localizedSubtitle,
              style: AppFonts.labelSmall(color: secondaryTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    }

    return Container(
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
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppResponsiveLayout.kMaxProjectWidth,
                  ),
                  child: SizedBox(
                    height: 59,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (effectiveLeading != null) ...[
                            effectiveLeading,
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: effectiveMiddle ?? const SizedBox.shrink(),
                          ),
                          if (effectiveActions.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: effectiveActions,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (bottom != null)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppResponsiveLayout.kMaxProjectWidth,
                    ),
                    child: bottom!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
