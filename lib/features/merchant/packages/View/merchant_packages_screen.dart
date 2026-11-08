import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading_state.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';

import '../ViewModel/service_packages_view_model.dart';
import '../Widgets/create_package_dialog.dart';
import '../Widgets/package_card_widget.dart';

class MerchantPackagesScreen extends ConsumerWidget {
  const MerchantPackagesScreen({super.key});

  Widget _buildMetricCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: AppFonts.titleLarge(color: primaryText)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppFonts.labelSmall(color: secondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(servicePackagesViewModelProvider);
    final vm = ref.read(servicePackagesViewModelProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: context.tr('servicePackages'),
        subtitle: context.tr('packagesSubtitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: context.tr('refresh'),
            onPressed: () => vm.refresh(),
          ),
        ],
      ),
      body: state.isLoading
          ? const AppLoadingState()
          : AppResponsiveLayout(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            label: 'Active Offers',
                            value: '${state.activePackagesCount}',
                            icon: Icons.campaign_rounded,
                            color: AppColors.success,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            label: 'Total Packages',
                            value: '${state.totalPackages}',
                            icon: Icons.card_giftcard_rounded,
                            color: AppColors.accentBlue,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          state.filterActiveOnly
                              ? 'Active Offers (${state.filteredPackages.length})'
                              : 'All Packages (${state.totalPackages})',
                          style: AppFonts.labelMedium(color: primaryText)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: state.filterActiveOnly
                                  ? AppColors.success
                                  : borderColor,
                            ),
                          ),
                          child: PopupMenuButton<bool>(
                            tooltip: 'Filter Packages',
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: borderColor),
                            ),
                            color: cardBg,
                            icon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 16,
                                  color: state.filterActiveOnly
                                      ? AppColors.success
                                      : primaryText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  state.filterActiveOnly
                                      ? 'Active Only'
                                      : 'All',
                                  style: AppFonts.labelSmall(color: primaryText)
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                            onSelected: vm.setFilterActiveOnly,
                            itemBuilder: (ctx) => [
                              PopupMenuItem<bool>(
                                value: false,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.all_inbox_rounded,
                                      size: 18,
                                      color: AppColors.accentBlue,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('All Packages'),
                                    if (!state.filterActiveOnly) ...[
                                      const Spacer(),
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: AppColors.accentBlue,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuItem<bool>(
                                value: true,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 18,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('Active Offers Only'),
                                    if (state.filterActiveOnly) ...[
                                      const Spacer(),
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: AppColors.success,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (state.filteredPackages.isEmpty)
                      AppEmptyState(
                        icon: Icons.local_offer_outlined,
                        title: context.tr('noPackagesCreated'),
                        message: 'Bundle your popular workshop services into high-converting seasonal packages to attract more repair orders.',
                        actionLabel: context.tr('createPackage'),
                        onAction: () => CreatePackageDialog.show(
                          context,
                          onSave:
                              ({
                                required title,
                                required description,
                                required includedServices,
                                required originalPrice,
                                required packagePrice,
                                required vehicleType,
                                required validityDays,
                              }) => vm.createPackage(
                                title: title,
                                description: description,
                                includedServices: includedServices,
                                originalPrice: originalPrice,
                                packagePrice: packagePrice,
                                vehicleType: vehicleType,
                                validityDays: validityDays,
                              ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          final isDesktop = constraints.maxWidth >= 768;
                          if (isDesktop) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.filteredPackages.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.25,
                                  ),
                              itemBuilder: (ctx, index) {
                                final pkg = state.filteredPackages[index];
                                return PackageCardWidget(
                                  package: pkg,
                                  onToggleActive: () => vm.toggleActive(pkg.id),
                                  onDelete: () async {
                                    final confirmed = await AppDialog.confirm(
                                      context,
                                      title: 'Delete Package',
                                      message:
                                          'Are you sure you want to delete ${pkg.title}?',
                                      confirmLabel: 'Delete',
                                      isDestructive: true,
                                    );
                                    if (confirmed == true) {
                                      vm.deletePackage(pkg.id);
                                    }
                                  },
                                );
                              },
                            );
                          }

                          return ListView.builder(
                            itemCount: state.filteredPackages.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (ctx, index) {
                              final pkg = state.filteredPackages[index];
                              return PackageCardWidget(
                                package: pkg,
                                onToggleActive: () => vm.toggleActive(pkg.id),
                                onDelete: () async {
                                  final confirmed = await AppDialog.confirm(
                                    context,
                                    title: 'Delete Package',
                                    message:
                                        'Are you sure you want to delete ${pkg.title}?',
                                    confirmLabel: 'Delete',
                                    isDestructive: true,
                                  );
                                  if (confirmed == true) {
                                    vm.deletePackage(pkg.id);
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreatePackageDialog.show(
          context,
          onSave:
              ({
                required title,
                required description,
                required includedServices,
                required originalPrice,
                required packagePrice,
                required vehicleType,
                required validityDays,
              }) => vm.createPackage(
                title: title,
                description: description,
                includedServices: includedServices,
                originalPrice: originalPrice,
                packagePrice: packagePrice,
                vehicleType: vehicleType,
                validityDays: validityDays,
              ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('createPackage')),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
