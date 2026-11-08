import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_cached_image.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading_overlay.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_skeleton_loader.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';

import '../Model/merchant_services_state.dart';
import '../ViewModel/merchant_services_view_model.dart';
import '../Widgets/service_edit_dialog.dart';

class MerchantServicesScreen extends ConsumerWidget {
  const MerchantServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantServicesViewModelProvider);
    final vm = ref.read(merchantServicesViewModelProvider.notifier);
    final authUser = ref.watch(authViewModelProvider).userProfile;
    final garageId =
        authUser?.garageId != null && authUser!.garageId!.isNotEmpty
        ? authUser.garageId!
        : '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: 'Services & Smart Pricing',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Service',
            onPressed: () => ServiceEditDialog.show(
              context,
              garageId: garageId,
              onSave: vm.saveService,
            ),
          ),
        ],
      ),
      body: AppLoadingOverlay(
        isLoading: state.isSaving,
        message: 'Saving service details...',
        child: AppResponsiveLayout(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: AppRefresh(
            onRefresh: vm.loadServices,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 768;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSidebarFilter(
                        context,
                        state,
                        vm,
                        cardBg,
                        borderColor,
                        primaryText,
                        secondaryText,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildServiceList(
                          context,
                          state,
                          vm,
                          garageId,
                          primaryText,
                          secondaryText,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildMobileFilterHeader(
                      context,
                      state,
                      vm,
                      cardBg,
                      borderColor,
                      primaryText,
                      secondaryText,
                    ),
                    Expanded(
                      child: _buildServiceList(
                        context,
                        state,
                        vm,
                        garageId,
                        primaryText,
                        secondaryText,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Service', style: TextStyle(color: Colors.white)),
        onPressed: () => ServiceEditDialog.show(
          context,
          garageId: garageId,
          onSave: vm.saveService,
        ),
      ),
    );
  }

  int _getCategoryCount(String cat, List<GarageServiceModel> services) {
    if (cat == 'All') return services.length;
    return services.where((s) => s.category == cat).length;
  }

  IconData _getCategoryIcon(String cat) {
    final lower = cat.toLowerCase();
    if (lower == 'all') return Icons.all_inclusive_rounded;
    if (lower.contains('air') || lower.contains('ac')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('brake')) return Icons.disc_full_rounded;
    if (lower.contains('detail') || lower.contains('wash')) {
      return Icons.local_car_wash_rounded;
    }
    if (lower.contains('diagnos')) return Icons.insights_rounded;
    if (lower.contains('period') || lower.contains('service')) {
      return Icons.build_circle_outlined;
    }
    if (lower.contains('wheel') ||
        lower.contains('tyre') ||
        lower.contains('tire')) {
      return Icons.tire_repair_rounded;
    }
    if (lower.contains('engine') || lower.contains('oil')) {
      return Icons.oil_barrel_rounded;
    }
    if (lower.contains('battery') || lower.contains('electric')) {
      return Icons.electric_bolt_rounded;
    }
    return Icons.miscellaneous_services_rounded;
  }

  Widget _buildSidebarFilter(
    BuildContext context,
    MerchantServicesState state,
    MerchantServicesViewModel vm,
    Color cardBg,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
  ) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.category_rounded,
                  size: 18,
                  color: AppColors.primaryRed,
                ),
                const SizedBox(width: 8),
                Text(
                  'Categories',
                  style: AppFonts.titleSmall(color: primaryText)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${state.services.length}',
                    style: AppFonts.labelSmall(color: AppColors.primaryRed)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: state.categories.length,
              itemBuilder: (ctx, i) {
                final cat = state.categories[i];
                final isSelected = state.selectedCategory == cat;
                final count = _getCategoryCount(cat, state.services);
                final icon = _getCategoryIcon(cat);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: isSelected
                        ? AppColors.primaryRed.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => vm.filterCategory(cat),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primaryRed.withValues(
                                    alpha: 0.4,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : secondaryText,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cat,
                                style:
                                    AppFonts.bodySmall(
                                      color: isSelected
                                          ? AppColors.primaryRed
                                          : primaryText,
                                    ).copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryRed
                                    : borderColor.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count',
                                style:
                                    AppFonts.labelSmall(
                                      color: isSelected
                                          ? Colors.white
                                          : secondaryText,
                                    ).copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilterHeader(
    BuildContext context,
    MerchantServicesState state,
    MerchantServicesViewModel vm,
    Color cardBg,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 16,
                  color: AppColors.primaryRed,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    state.selectedCategory == 'All'
                        ? 'All Services (${state.services.length})'
                        : '${state.selectedCategory} (${state.filteredServices.length})',
                    style: AppFonts.labelMedium(color: primaryText)
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (state.selectedCategory != 'All') ...[
            InkWell(
              onTap: () => vm.filterCategory('All'),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Clear',
                      style: AppFonts.labelSmall(color: AppColors.primaryRed)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppColors.primaryRed,
                    ),
                  ],
                ),
              ),
            ),
          ],
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: state.selectedCategory != 'All'
                    ? AppColors.primaryRed
                    : borderColor,
              ),
            ),
            child: PopupMenuButton<String>(
              tooltip: 'Filter Category',
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
                    size: 18,
                    color: state.selectedCategory != 'All'
                        ? AppColors.primaryRed
                        : primaryText,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down_rounded, size: 18),
                ],
              ),
              onSelected: vm.filterCategory,
              itemBuilder: (ctx) => state.categories.map((cat) {
                final isSelected = state.selectedCategory == cat;
                final count = _getCategoryCount(cat, state.services);
                final icon = _getCategoryIcon(cat);

                return PopupMenuItem<String>(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isSelected
                            ? AppColors.primaryRed
                            : secondaryText,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cat,
                          style:
                              AppFonts.bodySmall(
                                color: isSelected
                                    ? AppColors.primaryRed
                                    : primaryText,
                              ).copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                      Text(
                        '($count)',
                        style: AppFonts.labelSmall(color: secondaryText),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.primaryRed,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList(
    BuildContext context,
    MerchantServicesState state,
    MerchantServicesViewModel vm,
    String garageId,
    Color primaryText,
    Color secondaryText,
  ) {
    if (state.isLoading && state.services.isEmpty) {
      return AppSkeletonLoader.list(itemCount: 4);
    }
    if (state.errorMessage != null) {
      return AppErrorState(
        message: state.errorMessage!,
        onRetry: vm.loadServices,
      );
    }
    if (state.filteredServices.isEmpty) {
      return Center(
        child: AppEmptyState(
          title: state.services.isEmpty
              ? 'You haven\'t added any services yet'
              : 'No services in "${state.selectedCategory}"',
          description: state.services.isEmpty
              ? 'Add your workshop services with vehicle-specific pricing to showcase in discovery searches.'
              : 'Try choosing another category or tap below to add a service in this category.',
          icon: Icons.miscellaneous_services_rounded,
          actionLabel: 'Add Service',
          onAction: () => ServiceEditDialog.show(
            context,
            garageId: garageId,
            onSave: vm.saveService,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.filteredServices.length,
      itemBuilder: (ctx, index) {
        final service = state.filteredServices[index];
        return _buildServiceTile(
          context,
          service,
          garageId,
          vm,
          primaryText,
          secondaryText,
        );
      },
    );
  }

  Widget _buildServiceTile(
    BuildContext context,
    GarageServiceModel service,
    String garageId,
    MerchantServicesViewModel vm,
    Color primaryText,
    Color secondaryText,
  ) {
    String pricingSummary;
    switch (service.pricingMethod) {
      case 'fixed':
        pricingSummary =
            'Fixed: ₹${service.fixedPrice?.toStringAsFixed(0) ?? '0'}';
        break;
      case 'startingPrice':
        pricingSummary =
            'Starting from: ₹${service.startingPrice?.toStringAsFixed(0) ?? '0'}';
        break;
      case 'category':
        pricingSummary =
            'Category rules (${service.categoryPrices.length} types)';
        break;
      case 'attribute':
        pricingSummary =
            'Engine CC rules (${service.attributeRules.length} tiers)';
        break;
      case 'quotation':
        pricingSummary = 'Custom Quotation on Inspection';
        break;
      default:
        pricingSummary = 'Configured';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.imageUrl != null && service.imageUrl!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: AppCachedImage(
                    imageUrl: service.imageUrl,
                    height: 140,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10),
                    memCacheHeight: 280,
                  ),
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              service.name,
                              style: AppFonts.titleMedium(color: primaryText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              service.category,
                              style: AppFonts.labelSmall(
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (service.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: AppFonts.bodySmall(color: secondaryText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: service.isActive,
                  activeColor: AppColors.primaryRed,
                  onChanged: (val) => vm.toggleActive(service.id, val),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pricingSummary,
                    style: AppFonts.labelSmall(color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${service.estimatedDuration}',
                  style: AppFonts.labelSmall(color: secondaryText),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => ServiceEditDialog.show(
                    context,
                    garageId: garageId,
                    initialService: service,
                    onSave: vm.saveService,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.primaryRed,
                  ),
                  onPressed: () async {
                    final confirmed = await AppDialog.confirm(
                      context,
                      title: 'Delete Service',
                      message:
                          'Are you sure you want to remove "${service.name}" from your catalog?',
                      confirmLabel: 'Delete',
                      isDestructive: true,
                    );
                    if (confirmed == true) {
                      await vm.deleteService(service.id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
