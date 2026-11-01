import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';

class AccountSwitcherListView extends ConsumerWidget {
  const AccountSwitcherListView({
    super.key,
    this.onSwitched,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final ValueChanged<String>? onSwitched;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
    final currentExperience = authState.activeExperience;
    final isMerchant = currentExperience == 'merchant';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final customerName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Customer Account';
    final customerEmail = user?.email.isNotEmpty == true
        ? user!.email
        : 'Personal Vehicle Owner';

    final merchantName = (user?.garageId != null && user!.garageId!.isNotEmpty)
        ? 'Registered Garage'
        : 'Merchant Workspace';
    final merchantEmail = user?.email.isNotEmpty == true
        ? user!.email
        : 'garage.operations@wefix.com';

    final accounts = [
      _AccountItemData(
        id: 'customer',
        title: customerName,
        badgeLabel: context.tr('customer'),
        email: customerEmail,
        description: context.tr('customerAccountDesc'),
        icon: Icons.directions_car_rounded,
        isActive: !isMerchant,
        accentColor: AppColors.accentBlue,
      ),
      _AccountItemData(
        id: 'merchant',
        title: merchantName,
        badgeLabel: context.tr('merchant'),
        email: merchantEmail,
        description: context.tr('merchantAccountDesc'),
        icon: Icons.storefront_rounded,
        isActive: isMerchant,
        accentColor: AppColors.primaryRed,
      ),
    ];

    Widget buildTile(_AccountItemData item) {
      return _AccountTileItem(
        item: item,
        isDark: isDark,
        cardBg: cardBg,
        primaryTextColor: primaryTextColor,
        secondaryTextColor: secondaryTextColor,
        onTap: () async {
          if (item.isActive) return;
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: cardBg,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              icon: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.accentColor.withValues(alpha: 0.24),
                      item.accentColor.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Icon(item.icon, color: item.accentColor, size: 26),
              ),
              title: Text(
                context.loc.locale.languageCode == 'ml'
                    ? '${context.tr(item.id)} അക്കൗണ്ടിലേക്ക് മാറണോ?'
                    : 'Switch to ${item.badgeLabel} Account?',
                textAlign: TextAlign.center,
                style: AppFonts.titleMedium(color: primaryTextColor)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Text(
                  context.tr('switchAccountDesc'),
                  textAlign: TextAlign.center,
                  style: AppFonts.bodyMedium(color: secondaryTextColor),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsOverflowAlignment: OverflowBarAlignment.center,
              actionsOverflowButtonSpacing: 8,
              actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: secondaryTextColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(context.tr('cancel')),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: item.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(context.tr('confirmSwitch')),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await ref
                .read(authViewModelProvider.notifier)
                .switchExperience(item.id);
            onSwitched?.call(item.id);
          }
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final isWide = width >= 600;

        if (isWide) {
          final textScale = MediaQuery.textScalerOf(context)
              .scale(1.0)
              .clamp(1.0, 1.6);
          return GridView.builder(
            shrinkWrap: shrinkWrap,
            physics: physics,
            itemCount: accounts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 132 * textScale,
            ),
            itemBuilder: (context, index) => buildTile(accounts[index]),
          );
        }

        return ListView.separated(
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: accounts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => buildTile(accounts[index]),
        );
      },
    );
  }
}

class _AccountItemData {
  const _AccountItemData({
    required this.id,
    required this.title,
    required this.badgeLabel,
    required this.email,
    required this.description,
    required this.icon,
    required this.isActive,
    required this.accentColor,
  });

  final String id;
  final String title;
  final String badgeLabel;
  final String email;
  final String description;
  final IconData icon;
  final bool isActive;
  final Color accentColor;
}

class _AccountTileItem extends StatelessWidget {
  const _AccountTileItem({
    required this.item,
    required this.isDark,
    required this.cardBg,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  final _AccountItemData item;
  final bool isDark;
  final Color cardBg;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = item.isActive
        ? item.accentColor.withValues(alpha: 0.55)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final radius = BorderRadius.circular(20);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: item.isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.accentColor.withValues(alpha: isDark ? 0.22 : 0.14),
                      item.accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
                    ],
                  )
                : null,
            color: item.isActive ? null : cardBg,
            border: Border.all(
              color: borderColor,
              width: item.isActive ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: item.isActive
                    ? item.accentColor.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: item.isActive ? 20 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              splashColor: item.accentColor.withValues(alpha: 0.12),
              highlightColor: item.accentColor.withValues(alpha: 0.06),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: compact ? 46 : 54,
                      height: compact ? 46 : 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            item.accentColor,
                            item.accentColor.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: item.accentColor.withValues(alpha: 0.32),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: compact ? 22 : 26,
                      ),
                    ),
                    SizedBox(width: compact ? 10 : 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * 0.55,
                                ),
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppFonts.titleSmall(
                                        color: primaryTextColor,
                                      ).copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: item.accentColor.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.badgeLabel,
                                  style:
                                      AppFonts.labelSmall(
                                        color: item.accentColor,
                                      ).copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                        letterSpacing: 0.3,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.alternate_email_rounded,
                                size: 12,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.labelSmall(
                                    color: secondaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.labelSmall(
                              color: secondaryTextColor,
                            ).copyWith(height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutBack,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: item.isActive
                          ? _ActiveIndicator(
                              compact: compact,
                              key: const ValueKey('active'),
                            )
                          : _SwitchButton(
                              item: item,
                              compact: compact,
                              key: const ValueKey('switch'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveIndicator extends StatelessWidget {
  const _ActiveIndicator({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success.withValues(alpha: 0.14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.success,
          size: 18,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            context.tr('active'),
            style: AppFonts.labelSmall(color: AppColors.success)
                .copyWith(fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  const _SwitchButton({super.key, required this.item, required this.compact});

  final _AccountItemData item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.accentColor,
          boxShadow: [
            BoxShadow(
              color: item.accentColor.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.accentColor, item.accentColor.withValues(alpha: 0.82)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr('switch'),
            style: AppFonts.labelSmall(color: Colors.white)
                .copyWith(fontWeight: FontWeight.w800, fontSize: 11),
          ),
          const SizedBox(width: 5),
          const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class AccountSwitcherBottomSheet extends StatelessWidget {
  const AccountSwitcherBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => const AccountSwitcherBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final media = MediaQuery.of(context);
    final horizontal = media.size.width < 360 ? 16.0 : 24.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: media.size.height * 0.92,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: horizontal,
              right: horizontal,
              top: 12,
              bottom: media.viewInsets.bottom + media.padding.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryRed.withValues(alpha: 0.22),
                            AppColors.primaryRed.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.primaryRed,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Switch Account Experience',
                            style: AppFonts.titleMedium(color: primaryTextColor)
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select an experience to transition your workspace',
                            style: AppFonts.labelSmall(
                              color: secondaryTextColor,
                            ).copyWith(height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: secondaryTextColor,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                AccountSwitcherListView(
                  onSwitched: (target) {
                    Navigator.of(context).pop();
                    context.go(
                      target == 'merchant'
                          ? RoutePaths.merchant
                          : RoutePaths.customer,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
