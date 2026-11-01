import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
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

    return AppRefresh(
      onRefresh: () => vm.loadGarage(garageId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'OFFERS & PACKAGES',
                        style: AppFonts.labelSmall(color: Colors.white)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.accentAmber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Genuine Workshop Services',
                      style: AppFonts.labelSmall(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore transparent service packages with fixed charges, comprehensive checkups, and genuine spares.',
                  style: AppFonts.bodySmall(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    {'id': 'All', 'label': 'All Vehicles'},
                    {'id': 'car', 'label': 'Cars'},
                    {'id': 'motorcycle', 'label': 'Motorcycles'},
                    {'id': 'scooter', 'label': 'Scooters'},
                    {'id': 'electric_scooter', 'label': 'EV Scooters'},
                    {'id': 'electric_motorcycle', 'label': 'EV Motorcycles'},
                  ].map((v) {
                    final id = v['id']!;
                    final label = v['label']!;
                    final isSelected = state.selectedVehicleType == id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppColors.accentBlue.withValues(
                          alpha: 0.15,
                        ),
                        checkmarkColor: AppColors.accentBlue,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.accentBlue
                              : primaryText,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (_) => vm.selectVehicleType(id),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.availableCategories.map((cat) {
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
                    onSelected: (_) => vm.selectCategory(cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (state.filteredServices.isEmpty)
            const AppEmptyState(
              title: 'No Services Available',
              message: 'This garage has not published services in this category yet.',
              icon: Icons.miscellaneous_services_rounded,
            )
          else
            ...state.filteredServices.map((service) {
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
            }),
          const SizedBox(height: 80),
        ],
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
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
