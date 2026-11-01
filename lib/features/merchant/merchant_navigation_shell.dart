import 'package:flutter/material.dart';
import 'package:garage_card/core/branding/app_logo.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_modern_nav_bar.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:go_router/go_router.dart';

class MerchantNavigationShell extends StatelessWidget {
  const MerchantNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = AppResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: AppLogo(size: 42, showBadge: true),
              ),
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              indicatorColor: AppColors.primaryRed.withValues(alpha: 0.12),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(
                    Icons.dashboard_rounded,
                    color: AppColors.primaryRed,
                  ),
                  label: Text(context.tr('overview')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.car_repair_outlined),
                  selectedIcon: const Icon(
                    Icons.car_repair_rounded,
                    color: AppColors.primaryRed,
                  ),
                  label: Text(context.tr('jobs')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.insights_outlined),
                  selectedIcon: const Icon(
                    Icons.insights_rounded,
                    color: AppColors.primaryRed,
                  ),
                  label: Text(context.tr('analytics')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.grid_view_outlined),
                  selectedIcon: const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.primaryRed,
                  ),
                  label: Text(context.tr('more')),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppModernNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        items: [
          AppNavItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: context.tr('overview'),
          ),
          AppNavItem(
            icon: Icons.car_repair_outlined,
            selectedIcon: Icons.car_repair_rounded,
            label: context.tr('jobs'),
          ),
          AppNavItem(
            icon: Icons.insights_outlined,
            selectedIcon: Icons.insights_rounded,
            label: context.tr('analytics'),
          ),
          AppNavItem(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view_rounded,
            label: context.tr('more'),
          ),
        ],
      ),
    );
  }
}
