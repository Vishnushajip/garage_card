import 'package:flutter/material.dart';
import 'package:garage_card/core/branding/app_logo.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:go_router/go_router.dart';

class MerchantNavigationShell extends StatelessWidget {
  const MerchantNavigationShell({
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
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: AppLogo(size: 42, showBadge: true),
              ),
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              indicatorColor: AppColors.primaryRed.withValues(alpha: 0.12),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon:
                      Icon(Icons.dashboard_rounded, color: AppColors.primaryRed),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.car_repair_outlined),
                  selectedIcon:
                      Icon(Icons.car_repair_rounded, color: AppColors.primaryRed),
                  label: Text('Jobs'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon:
                      Icon(Icons.insights_rounded, color: AppColors.primaryRed),
                  label: Text('Analytics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  selectedIcon:
                      Icon(Icons.people_rounded, color: AppColors.primaryRed),
                  label: Text('Clients'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded,
                      color: AppColors.primaryRed),
                  label: Text('Invoices'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon:
                      Icon(Icons.storefront_rounded, color: AppColors.primaryRed),
                  label: Text('Garage'),
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
        indicatorColor: AppColors.primaryRed.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon:
                Icon(Icons.dashboard_rounded, color: AppColors.primaryRed),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.car_repair_outlined),
            selectedIcon:
                Icon(Icons.car_repair_rounded, color: AppColors.primaryRed),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon:
                Icon(Icons.insights_rounded, color: AppColors.primaryRed),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon:
                Icon(Icons.people_rounded, color: AppColors.primaryRed),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long_rounded, color: AppColors.primaryRed),
            label: 'Invoices',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon:
                Icon(Icons.storefront_rounded, color: AppColors.primaryRed),
            label: 'Garage',
          ),
        ],
      ),
    );
  }
}
