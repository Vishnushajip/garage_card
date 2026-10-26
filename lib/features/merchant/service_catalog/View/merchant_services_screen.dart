import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';

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
        : 'garage_demo_1';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Services & Smart Pricing',
          style: AppFonts.titleLarge(color: primaryText),
        ),
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
      body: AppResponsiveLayout(
        child: AppRefresh(
          onRefresh: vm.loadServices,
          child: Column(
            children: [
              if (state.categories.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.categories.map((cat) {
                        final isSelected = state.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppColors.primaryRed,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : primaryText,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) => vm.filterCategory(cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              Expanded(
                child: state.isLoading && state.services.isEmpty
                    ? const Center(child: AppLoading())
                    : state.filteredServices.isEmpty
                    ? const Center(
                        child: AppEmptyState(
                          title: 'No Services Found',
                          message: 'Add your garage services with flexible pricing models (Fixed, Category, Engine CC attributes).',
                          icon: Icons.miscellaneous_services_rounded,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
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
                      ),
              ),
            ],
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
