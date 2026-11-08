import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/account_switcher_list_view.dart';
import 'package:garage_card/core/shared_widgets/app_cached_image.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:go_router/go_router.dart';

class MerchantMoreScreen extends ConsumerWidget {
  const MerchantMoreScreen({super.key});

  Widget _buildLogoFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentBlue, AppColors.primaryRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppFonts.titleLarge(color: Colors.white)
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppFonts.titleSmall(color: primaryColor)
                .copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItemData> items,
    required Color cardBg,
    required Color borderColor,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context.tr(title), primaryColor),
        Card(
          color: cardBg,
          elevation: 0,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 72,
                    endIndent: 16,
                    color: borderColor,
                  ),
                _buildListTile(
                  context,
                  data: items[i],
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required _MenuItemData data,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return InkWell(
      onTap: () => data.onTap(context),
      hoverColor: data.color.withValues(alpha: 0.04),
      splashColor: data.color.withValues(alpha: 0.08),
      highlightColor: data.color.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.color.withValues(alpha: 0.2),
                    data.color.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(data.icon, color: data.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(data.title),
                    style: AppFonts.bodyMedium(color: primaryColor)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr(data.subtitle),
                    style: AppFonts.labelSmall(color: secondaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
    final dashState = ref.watch(merchantDashboardViewModelProvider);
    final garage = dashState.garage;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final rawGarageName = garage?.name ?? '';
    final garageName =
        (rawGarageName.isNotEmpty &&
            !rawGarageName.contains('Vishnu') &&
            !rawGarageName.endsWith('\'s Garage'))
        ? rawGarageName
        : 'Workshop Management';
    final garageEmail = garage?.email ?? user?.email ?? '';

    final operationsItems = [
      _MenuItemData(
        title: 'Clients & Customers',
        subtitle: 'Manage registered vehicle owners & contacts',
        icon: Icons.people_alt_rounded,
        color: AppColors.accentBlue,
        onTap: (ctx) => ctx.push(RoutePaths.merchantCustomers),
      ),
      _MenuItemData(
        title: 'Invoices & Billing',
        subtitle: 'Track receipts, payments & outstanding invoices',
        icon: Icons.receipt_long_rounded,
        color: AppColors.success,
        onTap: (ctx) => ctx.push(RoutePaths.merchantInvoices),
      ),
      _MenuItemData(
        title: 'Digital Estimates',
        subtitle: 'Create, revise and send repair quotes',
        icon: Icons.request_quote_rounded,
        color: AppColors.accentAmber,
        onTap: (ctx) => ctx.push(RoutePaths.merchantEstimates),
      ),
      _MenuItemData(
        title: 'Services & Labor Rates',
        subtitle: 'Workshop service catalog & overhaul packages',
        icon: Icons.miscellaneous_services_rounded,
        color: AppColors.primaryRed,
        onTap: (ctx) => ctx.push(RoutePaths.merchantServices),
      ),
      _MenuItemData(
        title: 'Spare Parts & Inventory',
        subtitle: 'Track workshop stock, margins & reorder levels',
        icon: Icons.inventory_2_rounded,
        color: AppColors.accentBlue,
        onTap: (ctx) => ctx.push(RoutePaths.merchantInventory),
      ),
      _MenuItemData(
        title: 'Customer Support Tickets',
        subtitle: 'Resolve vehicle inquiries, repair delays & disputes',
        icon: Icons.support_agent_rounded,
        color: AppColors.primaryRed,
        onTap: (ctx) => ctx.push(RoutePaths.merchantSupport),
      ),
      _MenuItemData(
        title: 'Mechanics & Staff',
        subtitle: 'Staff workload, efficiency & commission tracking',
        icon: Icons.badge_rounded,
        color: AppColors.accentBlue,
        onTap: (ctx) => ctx.push(RoutePaths.merchantMechanics),
      ),
      _MenuItemData(
        title: 'Workshop Bays & Lifts',
        subtitle: 'Ramps, hydraulic lifts & floor capacity planner',
        icon: Icons.garage_rounded,
        color: AppColors.primaryRed,
        onTap: (ctx) => ctx.push(RoutePaths.merchantBays),
      ),
      _MenuItemData(
        title: 'Service Due & Recalls',
        subtitle: 'Predictive periodic maintenance & WhatsApp re-engagement',
        icon: Icons.event_repeat_rounded,
        color: AppColors.accentAmber,
        onTap: (ctx) => ctx.push(RoutePaths.merchantRecalls),
      ),
      _MenuItemData(
        title: 'Packages & Offers',
        subtitle: 'Seasonal repair bundles & promotional offers',
        icon: Icons.loyalty_rounded,
        color: AppColors.success,
        onTap: (ctx) => ctx.push(RoutePaths.merchantPackages),
      ),
    ];

    final workshopItems = [
      _MenuItemData(
        title: 'Garage Profile & Settings',
        subtitle: 'Business address, hours, tax info & branding',
        icon: Icons.storefront_rounded,
        color: AppColors.accentBlue,
        onTap: (ctx) => ctx.push(RoutePaths.merchantSettings),
      ),
      _MenuItemData(
        title: 'Notification Center',
        subtitle: 'Customer approvals, job reminders & updates',
        icon: Icons.notifications_active_rounded,
        color: AppColors.warning,
        onTap: (ctx) => ctx.push(RoutePaths.merchantNotifications),
      ),
      _MenuItemData(
        title: 'Customer Conversations',
        subtitle: 'Real-time chat & service inquiries',
        icon: Icons.chat_bubble_outline_rounded,
        color: AppColors.success,
        onTap: (ctx) => ctx.push(RoutePaths.chatList),
      ),
    ];

    return Scaffold(
      appBar: const AppCustomAppBar(title: 'More Operations'),
      body: SingleChildScrollView(
        child: AppResponsiveLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentBlue.withValues(
                        alpha: isDark ? 0.22 : 0.1,
                      ),
                      AppColors.primaryRed.withValues(
                        alpha: isDark ? 0.16 : 0.06,
                      ),
                    ],
                  ),
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: AppCachedImage(
                          imageUrl: garage?.logoUrl,
                          width: 58,
                          height: 58,
                          borderRadius: BorderRadius.circular(18),
                          errorWidget: _buildLogoFallback(garageName),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              garageName,
                              style:
                                  AppFonts.titleMedium(color: primaryTextColor)
                                      .copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              garageEmail,
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 12,
                                    color: AppColors.accentBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Merchant Workspace',
                                    style: AppFonts.labelSmall(
                                      color: AppColors.accentBlue,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: cardBg,
                        shape: CircleBorder(
                          side: BorderSide(color: borderColor),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                          ),
                          color: secondaryTextColor,
                          onPressed: () =>
                              context.push(RoutePaths.merchantSettings),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuSection(
                context,
                title: 'Operations & Records',
                items: operationsItems,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryColor: primaryTextColor,
                secondaryColor: secondaryTextColor,
              ),
              _buildMenuSection(
                context,
                title: 'Workshop & Settings',
                items: workshopItems,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryColor: primaryTextColor,
                secondaryColor: secondaryTextColor,
              ),
              _buildSectionTitle('Account Switching', primaryTextColor),
              Card(
                color: cardBg,
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AccountSwitcherListView(
                    onSwitched: (target) {
                      if (context.mounted) {
                        context.go(
                          target == 'merchant'
                              ? RoutePaths.merchant
                              : RoutePaths.customer,
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.build_circle_rounded,
                            size: 20,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WeFix Garage',
                                style: AppFonts.labelSmall(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                'Version 1.0.0 (Build 2026.1)',
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor,
                                ).copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(height: 1, color: borderColor),
                    const SizedBox(height: 14),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              backgroundColor: AppColors.error.withValues(
                                alpha: 0.06,
                              ),
                              side: BorderSide(
                                color: AppColors.error.withValues(alpha: 0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(
                              Icons.power_settings_new_rounded,
                              size: 18,
                            ),
                            label: Text(
                              context.tr('signOut'),
                              style: AppFonts.labelSmall(color: AppColors.error)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            onPressed: () async {
                              final confirm = await AppDialog.confirm(
                                context,
                                title: context.tr('signOut'),
                                message: 'Are you sure you want to securely exit your merchant workspace?',
                                confirmLabel: context.tr('signOut'),
                                isDestructive: true,
                              );
                              if (confirm == true) {
                                ref
                                    .read(authViewModelProvider.notifier)
                                    .signOut();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => context.push(RoutePaths.privacy),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              context.tr('privacyPolicy'),
                              style: AppFonts.labelSmall(
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '•',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                        InkWell(
                          onTap: () => context.push(RoutePaths.terms),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              context.tr('termsAndConditions'),
                              style: AppFonts.labelSmall(
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context) onTap;
}
