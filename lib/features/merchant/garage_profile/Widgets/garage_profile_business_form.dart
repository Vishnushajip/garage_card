import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/constants/app_constants.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/working_hours_model.dart';

import 'working_hours_selector.dart';

class GarageProfileBusinessForm extends StatelessWidget {
  const GarageProfileBusinessForm({
    super.key,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.taxCtrl,
    required this.hoursCtrl,
    required this.workingSchedule,
    required this.onScheduleChanged,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.detectedLat,
    required this.detectedLng,
    required this.isLocatingGps,
    required this.onOpenMapPicker,
    required this.onAutoDetectGps,
    required this.onSave,
    required this.isSaving,
    required this.onChanged,
  });

  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController taxCtrl;
  final TextEditingController hoursCtrl;
  final List<DayWorkingHours> workingSchedule;
  final ValueChanged<List<DayWorkingHours>> onScheduleChanged;
  final String selectedCurrency;
  final ValueChanged<String?> onCurrencyChanged;
  final double? detectedLat;
  final double? detectedLng;
  final bool isLocatingGps;
  final VoidCallback onOpenMapPicker;
  final VoidCallback onAutoDetectGps;
  final VoidCallback onSave;
  final bool isSaving;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final hasCoordinates = detectedLat != null && detectedLng != null;

    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: nameCtrl,
              label: 'Garage Trading Name',
              required: true,
              onChanged: (_) => onChanged(),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: addressCtrl,
              label: 'Business Address & City',
              hint: 'Building name, street, area, city, pincode',
              prefixIcon: const Icon(Icons.location_city_rounded, size: 18),
              required: true,
              onChanged: (_) => onChanged(),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasCoordinates
                      ? AppColors.primaryGreen.withValues(alpha: 0.4)
                      : borderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (hasCoordinates
                                      ? AppColors.primaryGreen
                                      : AppColors.accentBlue)
                                  .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.map_rounded,
                          size: 18,
                          color: hasCoordinates
                              ? AppColors.primaryGreen
                              : AppColors.accentBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workshop Map Location',
                              style: AppFonts.labelMedium(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasCoordinates
                                  ? 'Coordinates: ${detectedLat!.toStringAsFixed(5)}, ${detectedLng!.toStringAsFixed(5)}'
                                  : 'Pin your exact location on the map so customers can reach you',
                              style: AppFonts.bodySmall(
                                color: hasCoordinates
                                    ? AppColors.primaryGreen
                                    : secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.pin_drop_rounded, size: 16),
                        label: Text(
                          hasCoordinates ? 'Change Map Pin' : 'Select on Map',
                          style: AppFonts.labelSmall(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: onOpenMapPicker,
                      ),
                      OutlinedButton.icon(
                        icon: isLocatingGps
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accentBlue,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded, size: 16),
                        label: Text(
                          isLocatingGps
                              ? 'Locating via GPS...'
                              : 'Auto-Detect GPS',
                          style: AppFonts.labelSmall(
                            color: AppColors.accentBlue,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentBlue,
                          side: const BorderSide(color: AppColors.accentBlue),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: isLocatingGps ? null : onAutoDetectGps,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: phoneCtrl,
                    label: 'Contact Phone',
                    required: true,
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: emailCtrl,
                    label: 'Contact Email',
                    required: true,
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: taxCtrl,
                    label: 'Tax / GSTIN Number',
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Shop Currency',
                    value: selectedCurrency,
                    onChanged: onCurrencyChanged,
                    items: AppConstants.supportedCurrencies
                        .map(
                          (code) => AppDropdownItem(value: code, title: code),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            WorkingHoursSelector(
              schedule: workingSchedule,
              onChanged: (newSchedule) {
                onScheduleChanged(newSchedule);
                onChanged();
              },
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Save Business Profile',
              onPressed: onSave,
              isLoading: isSaving,
              isFullWidth: true,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
