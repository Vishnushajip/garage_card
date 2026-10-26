import 'package:flutter/material.dart';
import 'package:garage_card/core/branding/app_logo.dart';
import 'package:garage_card/core/colors/app_colors.dart';
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
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: AppColors.primaryRed,
                  ),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(
                    Icons.explore_rounded,
                    color: AppColors.primaryRed,
                  ),
                  label: Text('Garages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.directions_car_outlined),
                  selectedIcon: Icon(
                    Icons.directions_car_rounded,
                    color: AppColors.primaryRed,
                  ),
                  label: Text('Vehicles'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primaryRed,
                  ),
                  label: Text('Invoices'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryRed,
                  ),
                  label: Text('Profile'),
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
        items: const [
          AppNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
          ),
          AppNavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore_rounded,
            label: 'Garages',
          ),
          AppNavItem(
            icon: Icons.directions_car_outlined,
            selectedIcon: Icons.directions_car_rounded,
            label: 'Vehicles',
          ),
          AppNavItem(
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
            label: 'Invoices',
          ),
          AppNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
