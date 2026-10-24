import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:go_router/go_router.dart';

class CustomerNavigationShell extends StatelessWidget {
  const CustomerNavigationShell({
    super.key,
    required this.navigationShell,
  });

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
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              indicatorColor: AppColors.accentBlue.withValues(alpha: 0.15),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon:
                      Icon(Icons.home_rounded, color: AppColors.accentBlue),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon:
                      Icon(Icons.explore_rounded, color: AppColors.accentBlue),
                  label: Text('Garages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.directions_car_outlined),
                  selectedIcon: Icon(Icons.directions_car_rounded,
                      color: AppColors.accentBlue),
                  label: Text('Vehicles'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded,
                      color: AppColors.accentBlue),
                  label: Text('Invoices'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon:
                      Icon(Icons.person_rounded, color: AppColors.accentBlue),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: AppColors.accentBlue.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.accentBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon:
                Icon(Icons.explore_rounded, color: AppColors.accentBlue),
            label: 'Garages',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car_rounded,
                color: AppColors.accentBlue),
            label: 'Vehicles',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long_rounded, color: AppColors.accentBlue),
            label: 'Invoices',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon:
                Icon(Icons.person_rounded, color: AppColors.accentBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
