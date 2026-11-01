import 'package:flutter/material.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_desktop_sidebar.dart';
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
    final isDesktop = AppResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            AppDesktopSidebar(
              currentIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              portalTitle: 'WeFix Workshop',
              portalSubtitle: 'Merchant Workspace',
              items: [
                AppDesktopSidebarItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  label: context.tr('overview'),
                ),
                AppDesktopSidebarItem(
                  icon: Icons.car_repair_outlined,
                  selectedIcon: Icons.car_repair_rounded,
                  label: context.tr('jobs'),
                ),
                AppDesktopSidebarItem(
                  icon: Icons.insights_outlined,
                  selectedIcon: Icons.insights_rounded,
                  label: context.tr('analytics'),
                ),
                AppDesktopSidebarItem(
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                  label: context.tr('more'),
                ),
              ],
            ),
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
