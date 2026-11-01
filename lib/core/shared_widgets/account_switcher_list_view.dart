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

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: accounts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = accounts[index];
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  context.loc.locale.languageCode == 'ml'
                      ? '${context.tr(item.id)} അക്കൗണ്ടിലേക്ക് മാറണോ?'
                      : 'Switch to ${item.badgeLabel} Account?',
                  style: AppFonts.titleMedium(color: primaryTextColor),
                ),
                content: Text(
                  context.tr('switchAccountDesc'),
                  style: AppFonts.bodyMedium(color: secondaryTextColor),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(context.tr('cancel')),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: item.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
        ? item.accentColor.withValues(alpha: 0.4)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final tileBg = item.isActive
        ? item.accentColor.withValues(alpha: 0.08)
        : cardBg;

    return Material(
      color: tileBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: item.isActive ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(
                          item.title,
                          style: AppFonts.titleSmall(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: item.accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.badgeLabel,
                            style: AppFonts.labelSmall(color: item.accentColor)
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.email,
                      style: AppFonts.labelSmall(color: secondaryTextColor)
                          .copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (item.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('active'),
                        style: AppFonts.labelSmall(
                          color: AppColors.success,
                        ).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item.accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('switch'),
                        style: AppFonts.labelSmall(
                          color: Colors.white,
                        ).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
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
      backgroundColor: Colors.transparent,
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

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primaryRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Switch Account Experience',
                      style: AppFonts.titleMedium(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Select an experience to transition your workspace',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
    );
  }
}
