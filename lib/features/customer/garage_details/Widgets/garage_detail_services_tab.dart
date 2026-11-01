import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_cached_image.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_button.dart';
import 'package:garage_card/features/customer/appointments/View/customer_appointments_screen.dart';
import 'package:garage_card/features/customer/inquiry/customer_inquiry_service.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';
import 'package:garage_card/features/shared/pricing/smart_pricing_engine.dart';

import '../Model/customer_garage_detail_state.dart';
import '../ViewModel/customer_garage_detail_view_model.dart';

class GarageDetailServicesTab extends ConsumerWidget {
  const GarageDetailServicesTab({
    super.key,
    required this.garageId,
    required this.state,
    required this.vm,
    required this.garage,
  });

  final String garageId;
  final CustomerGarageDetailState state;
  final CustomerGarageDetailViewModel vm;
  final GarageModel garage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final isWide = MediaQuery.sizeOf(context).width >= 640;

    final vehicleTypes = [
      {
        'id': 'All',
        'label': 'All Vehicles',
        'icon': Icons.directions_car_rounded,
      },
      {
        'id': 'car',
        'label': 'Cars',
        'icon': Icons.directions_car_filled_rounded,
      },
      {
        'id': 'motorcycle',
        'label': 'Motorcycles',
        'icon': Icons.two_wheeler_rounded,
      },
      {'id': 'scooter', 'label': 'Scooters', 'icon': Icons.moped_rounded},
      {
        'id': 'electric_scooter',
        'label': 'EV Scooters',
        'icon': Icons.electric_moped_rounded,
      },
      {
        'id': 'electric_motorcycle',
        'label': 'EV Motorcycles',
        'icon': Icons.electric_bike_rounded,
      },
    ];

    final currentVehicle = vehicleTypes.firstWhere(
      (v) => v['id'] == state.selectedVehicleType,
      orElse: () => vehicleTypes.first,
    );

    return AppRefresh(
      onRefresh: () => vm.loadGarage(garageId),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (garage.description.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              garage.description,
                              style: AppFonts.bodySmall(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterDropdown(
                          context: context,
                          label: 'Vehicle Type',
                          selectedTitle: currentVehicle['label'] as String,
                          prefixIcon: currentVehicle['icon'] as IconData,
                          isDark: isDark,
                          primaryText: primaryText,
                          menuItems: vehicleTypes.map((v) {
                            final id = v['id'] as String;
                            final label = v['label'] as String;
                            final icon = v['icon'] as IconData;
                            final isSelected = state.selectedVehicleType == id;
                            return PopupMenuItem<String>(
                              value: id,
                              child: Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.primaryRed
                                        : primaryText,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primaryRed
                                            : primaryText,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: AppColors.primaryRed,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onSelected: (id) => vm.selectVehicleType(id),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFilterDropdown(
                          context: context,
                          label: 'Service Category',
                          selectedTitle: state.selectedCategory,
                          prefixIcon: Icons.category_rounded,
                          isDark: isDark,
                          primaryText: primaryText,
                          menuItems: state.availableCategories.map((cat) {
                            final isSelected = state.selectedCategory == cat;
                            return PopupMenuItem<String>(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.build_circle_outlined,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.primaryRed
                                        : primaryText,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primaryRed
                                            : primaryText,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: AppColors.primaryRed,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onSelected: (cat) => vm.selectCategory(cat),
                        ),
                      ),
                    ],
                  ),
                  if (state.filteredServices.isEmpty) ...[
                    const SizedBox(height: 24),
                    const AppEmptyState(
                      title: 'No Services Available',
                      message: 'This garage has not published services in this category yet.',
                      icon: Icons.miscellaneous_services_rounded,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (state.filteredServices.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: isWide
                  ? _buildWideServiceGrid(state, garage)
                  : _buildNarrowServiceList(state, garage),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildWideServiceGrid(
    CustomerGarageDetailState state,
    GarageModel garage,
  ) {
    final chunks = <List<GarageServiceModel>>[];
    for (var i = 0; i < state.filteredServices.length; i += 2) {
      chunks.add(
        state.filteredServices.sublist(
          i,
          i + 2 > state.filteredServices.length
              ? state.filteredServices.length
              : i + 2,
        ),
      );
    }

    return SliverList.separated(
      itemCount: chunks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final pair = chunks[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GarageDetailServiceCard(
                service: pair[0],
                evaluated: SmartPricingEngine.evaluate(
                  service: pair[0],
                  vehicle: state.selectedVehicle,
                  vehicleType: state.selectedVehicleType != 'All'
                      ? state.selectedVehicleType
                      : null,
                  currencyCode: garage.currencyCode,
                ),
                garage: garage,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: pair.length > 1
                  ? GarageDetailServiceCard(
                      service: pair[1],
                      evaluated: SmartPricingEngine.evaluate(
                        service: pair[1],
                        vehicle: state.selectedVehicle,
                        vehicleType: state.selectedVehicleType != 'All'
                            ? state.selectedVehicleType
                            : null,
                        currencyCode: garage.currencyCode,
                      ),
                      garage: garage,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNarrowServiceList(
    CustomerGarageDetailState state,
    GarageModel garage,
  ) {
    return SliverList.separated(
      itemCount: state.filteredServices.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final service = state.filteredServices[index];
        final evaluated = SmartPricingEngine.evaluate(
          service: service,
          vehicle: state.selectedVehicle,
          vehicleType: state.selectedVehicleType != 'All'
              ? state.selectedVehicleType
              : null,
          currencyCode: garage.currencyCode,
        );

        return GarageDetailServiceCard(
          service: service,
          evaluated: evaluated,
          garage: garage,
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required BuildContext context,
    required String label,
    required String selectedTitle,
    required IconData prefixIcon,
    required List<PopupMenuEntry<String>> menuItems,
    required ValueChanged<String> onSelected,
    required bool isDark,
    required Color primaryText,
  }) {
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor),
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        onSelected: onSelected,
        itemBuilder: (context) => menuItems,
        tooltip: label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(prefixIcon, size: 18, color: AppColors.accentBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppFonts.labelSmall(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ).copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      selectedTitle,
                      style: AppFonts.labelMedium(color: primaryText)
                          .copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.accentBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GarageDetailServiceCard extends ConsumerWidget {
  const GarageDetailServiceCard({
    super.key,
    required this.service,
    required this.evaluated,
    required this.garage,
  });

  final GarageServiceModel service;
  final EvaluatedPrice evaluated;
  final GarageModel garage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    Color priceBadgeColor;
    if (evaluated.isQuotationRequired) {
      priceBadgeColor = AppColors.primaryAmber;
    } else if (evaluated.isStartingPrice) {
      priceBadgeColor = AppColors.accentBlue;
    } else {
      priceBadgeColor = AppColors.primaryGreen;
    }

    final whatsappMsg =
        'Hello ${garage.name}, I would like to inquire about the "${service.name}" package (${evaluated.formattedDisplay}) at your workshop.';

    return Card(
      color: cardBg,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.imageUrl != null && service.imageUrl!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCachedImage(
                  imageUrl: service.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(10),
                  memCacheHeight: 280,
                ),
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              service.category,
                              style:
                                  AppFonts.labelSmall(
                                    color: AppColors.accentBlue,
                                  ).copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service.name,
                        style: AppFonts.titleMedium(color: primaryText)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (service.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: AppFonts.bodySmall(color: secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: priceBadgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: priceBadgeColor),
                  ),
                  child: Text(
                    evaluated.formattedDisplay,
                    style: AppFonts.labelLarge(color: priceBadgeColor)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: secondaryText),
                const SizedBox(width: 4),
                Text(
                  service.estimatedDuration,
                  style: AppFonts.labelSmall(color: secondaryText),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: secondaryText,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    evaluated.pricingSubtitle,
                    style: AppFonts.labelSmall(color: secondaryText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (service.vehiclePricing.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: service.vehiclePricing.map((tier) {
                  String display;
                  if (tier.pricingType == 'range' &&
                      tier.minPrice != null &&
                      tier.maxPrice != null) {
                    display =
                        '${tier.vehicleType.toUpperCase()}: ₹${tier.minPrice!.toStringAsFixed(0)}–₹${tier.maxPrice!.toStringAsFixed(0)}';
                  } else if (tier.fixedPrice != null) {
                    display =
                        '${tier.vehicleType.toUpperCase()}: ₹${tier.fixedPrice!.toStringAsFixed(0)}';
                  } else {
                    display = '${tier.vehicleType.toUpperCase()}: Quote';
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryText.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      display,
                      style: AppFonts.labelSmall(color: secondaryText)
                          .copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (service.includedItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: service.includedItems.map((item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 12,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item,
                        style: AppFonts.labelSmall(color: secondaryText),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
            if (service.terms != null && service.terms!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Includes: ${service.terms}',
                style: AppFonts.labelSmall(color: secondaryText),
              ),
            ],
            const Divider(height: 20),
            Row(
              children: [
                AppWhatsAppButton(
                  phoneNumber: garage.phone,
                  message: whatsappMsg,
                  variant: WhatsAppButtonVariant.iconOnly,
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(
                    Icons.forum_outlined,
                    size: 16,
                    color: AppColors.accentBlue,
                  ),
                  label: Text(
                    'Inquire',
                    style: AppFonts.labelSmall(color: AppColors.accentBlue)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.accentBlue.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => CustomerInquiryService.startInquiry(
                    context,
                    ref,
                    garage: garage,
                    package: service,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Book Service',
                    variant: AppButtonVariant.primary,
                    height: 36,
                    fontSize: 12,
                    onPressed: () =>
                        CustomerAppointmentsScreen.showBookingSheet(
                          context,
                          garageId: garage.id,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
