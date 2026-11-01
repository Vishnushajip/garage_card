import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/features/customer/profile/Widgets/preference_tile.dart';

class GarageProfilePreferencesCard extends StatelessWidget {
  const GarageProfilePreferencesCard({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.isDoorstepRepairAvailable,
    required this.onDoorstepRepairChanged,
    required this.isRoadsideAssistanceAvailable,
    required this.onRoadsideAssistanceChanged,
    required this.onEnablePushNotifications,
  });

  final String languageCode;
  final ValueChanged<String?> onLanguageChanged;
  final bool isDoorstepRepairAvailable;
  final ValueChanged<bool> onDoorstepRepairChanged;
  final bool isRoadsideAssistanceAvailable;
  final ValueChanged<bool> onRoadsideAssistanceChanged;
  final VoidCallback onEnablePushNotifications;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('Application Preferences'),
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
        const SizedBox(height: 12),
        Card(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: AppDropdown<String>(
                  label: context.tr('language'),
                  value: languageCode,
                  onChanged: onLanguageChanged,
                  items: const [
                    AppDropdownItem(value: 'en', title: 'English'),
                    AppDropdownItem(value: 'ml', title: 'മലയാളം (Malayalam)'),
                  ],
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  'Doorstep Repair / Pickup',
                  style: AppFonts.bodyMedium(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Mechanics travel to customer home or pickup vehicle',
                  style: AppFonts.bodySmall(color: secondaryTextColor),
                ),
                value: isDoorstepRepairAvailable,
                activeColor: AppColors.primaryRed,
                onChanged: onDoorstepRepairChanged,
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  'On-Road Breakdown Assistance',
                  style: AppFonts.bodyMedium(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Mechanics reach stranded vehicles on the road for emergency fixes',
                  style: AppFonts.bodySmall(color: secondaryTextColor),
                ),
                value: isRoadsideAssistanceAvailable,
                activeColor: AppColors.primaryRed,
                onChanged: onRoadsideAssistanceChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Push Notifications & Alerts',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
        const SizedBox(height: 12),
        Card(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor),
          ),
          child: PreferenceTile(
            icon: Icons.notifications_active_rounded,
            title: 'Enable Push Notifications',
            subtitle:
                'Receive customer bookings, status updates and approval alerts',
            onTap: onEnablePushNotifications,
          ),
        ),
      ],
    );
  }
}
