import 'package:flutter/material.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_desktop_sidebar.dart';
import 'package:garage_card/core/shared_widgets/app_modern_nav_bar.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:go_router/go_router.dart';

class CustomerNavigationShell extends StatelessWidget {
  const CustomerNavigationShell({super.key, required this.navigationShell});

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
              portalTitle: 'WeFix Care',
              portalSubtitle: 'Vehicle Owner Portal',
              items: [
                AppDesktopSidebarItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: context.tr('home'),
                ),
                AppDesktopSidebarItem(
                  icon: Icons.storefront_outlined,
                  selectedIcon: Icons.storefront_rounded,
                  label: context.tr('garages'),
                ),
                AppDesktopSidebarItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long_rounded,
                  label: context.tr('invoices'),
                ),
                AppDesktopSidebarItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: context.tr('profile'),
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
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: context.tr('home'),
          ),
          AppNavItem(
            icon: Icons.storefront_outlined,
            selectedIcon: Icons.storefront_rounded,
            label: context.tr('garages'),
          ),
          AppNavItem(
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
            label: context.tr('invoices'),
          ),
          AppNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: context.tr('profile'),
          ),
        ],
      ),
    );
  }
}
