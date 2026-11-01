import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/constants/app_constants.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';

class GarageProfileBusinessForm extends StatelessWidget {
  const GarageProfileBusinessForm({
    super.key,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.googleAddressCtrl,
    required this.googleMapsUrlCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.taxCtrl,
    required this.hoursCtrl,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.detectedLat,
    required this.detectedLng,
    required this.isGeocoding,
    required this.onDetectCoordinatesFromUrl,
    required this.onGeocodeAddress,
    required this.onTestLocationOnMap,
    required this.onSave,
    required this.isSaving,
    required this.onChanged,
  });

  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController googleAddressCtrl;
  final TextEditingController googleMapsUrlCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController taxCtrl;
  final TextEditingController hoursCtrl;
  final String selectedCurrency;
  final ValueChanged<String?> onCurrencyChanged;
  final double? detectedLat;
  final double? detectedLng;
  final bool isGeocoding;
  final ValueChanged<String> onDetectCoordinatesFromUrl;
  final VoidCallback onGeocodeAddress;
  final VoidCallback onTestLocationOnMap;
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
              required: true,
              onChanged: (_) => onChanged(),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: googleAddressCtrl,
              label: 'Google Address (No Maps API Required)',
              hint: 'Paste Google formatted address or locality...',
              prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: googleMapsUrlCtrl,
              label: 'Google Maps Share Link / URL',
              hint: 'https://maps.app.goo.gl/... or google.com/maps/...',
              prefixIcon: const Icon(Icons.link_rounded, size: 18),
              onChanged: (val) {
                onDetectCoordinatesFromUrl(val);
                onChanged();
              },
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        detectedLat != null && detectedLng != null
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        size: 16,
                        color: detectedLat != null && detectedLng != null
                            ? AppColors.success
                            : AppColors.accentAmber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          detectedLat != null && detectedLng != null
                              ? 'Coordinates: ${detectedLat!.toStringAsFixed(4)}, ${detectedLng!.toStringAsFixed(4)}'
                              : 'No coordinates detected yet',
                          style: AppFonts.labelSmall(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        icon: isGeocoding
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded, size: 14),
                        label: Text(
                          isGeocoding
                              ? 'Detecting...'
                              : 'Auto-Detect Coordinates',
                          style: AppFonts.labelSmall(
                            color: AppColors.accentBlue,
                          ),
                        ),
                        onPressed: isGeocoding ? null : onGeocodeAddress,
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_new_rounded, size: 14),
                        label: Text(
                          'Test Location on Maps',
                          style: AppFonts.labelSmall(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        onPressed: onTestLocationOnMap,
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
            const SizedBox(height: 14),
            AppTextField(
              controller: hoursCtrl,
              label: 'Working Hours',
              hint: '8:30 AM - 7:30 PM',
              onChanged: (_) => onChanged(),
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
