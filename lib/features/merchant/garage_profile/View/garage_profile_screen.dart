import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/constants/app_constants.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/notifications/notification_event_matrix.dart';
import 'package:garage_card/core/notifications/push_notification_service.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/customer/profile/Widgets/preference_tile.dart';

import '../ViewModel/garage_profile_view_model.dart';

class GarageProfileScreen extends ConsumerStatefulWidget {
  const GarageProfileScreen({super.key});

  @override
  ConsumerState<GarageProfileScreen> createState() =>
      _GarageProfileScreenState();
}

class _GarageProfileScreenState extends ConsumerState<GarageProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _taxCtrl;
  late final TextEditingController _hoursCtrl;

  String _selectedCurrency = 'INR';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Apex Precision Automotive');
    _phoneCtrl = TextEditingController(text: '+91 98460 12345');
    _emailCtrl = TextEditingController(text: 'service@apexprecision.com');
    _addressCtrl = TextEditingController(
      text: 'Near MG Road, Ravipuram, Kochi, Kerala',
    );
    _taxCtrl = TextEditingController(text: '32AAACH7890Q1ZS');
    _hoursCtrl = TextEditingController(text: '8:30 AM - 7:30 PM');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _taxCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(garageProfileViewModelProvider.notifier)
        .updateProfile(
          name: _nameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          taxNumber: _taxCtrl.text.trim(),
          currencyCode: _selectedCurrency,
          openHours: _hoursCtrl.text.trim(),
        )
        .then((success) {
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Garage profile updated successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageProfileViewModelProvider);
    final vm = ref.read(garageProfileViewModelProvider.notifier);
    final locale = ref.watch(localeProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    if (state.isLoading) {
      return const Scaffold(
        body: AppLoading(message: 'Loading garage settings...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Garage Profile & Settings',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: SingleChildScrollView(
          child: AppResponsiveLayout(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.accentBlue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameCtrl.text,
                                  style: AppFonts.titleLarge(
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const AppStatusBadge(
                                      status: 'approved',
                                      customLabel: 'VERIFIED GARAGE',
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.infoBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'PLAN: PRO TIER',
                                        style: AppFonts.labelSmall(
                                          color: AppColors.info,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Business Information',
                    style: AppFonts.titleLarge(color: primaryTextColor),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Garage Trading Name',
                            required: true,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _addressCtrl,
                            label: 'Business Address & City',
                            required: true,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _phoneCtrl,
                                  label: 'Contact Phone',
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _emailCtrl,
                                  label: 'Contact Email',
                                  required: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _taxCtrl,
                                  label: 'Tax / GSTIN Number',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppDropdown<String>(
                                  label: 'Shop Currency',
                                  value: _selectedCurrency,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedCurrency = val);
                                    }
                                  },
                                  items: AppConstants.supportedCurrencies
                                      .map(
                                        (code) => AppDropdownItem(
                                          value: code,
                                          title: code,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _hoursCtrl,
                            label: 'Working Hours',
                            hint: '8:30 AM - 7:30 PM',
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Save Business Profile',
                            onPressed: _save,
                            isLoading: state.isSaving,
                            isFullWidth: true,
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Application Preferences',
                    style: AppFonts.titleLarge(color: primaryTextColor),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: AppDropdown<String>(
                            label: 'Interface Language',
                            value: locale.languageCode,
                            onChanged: (code) {
                              if (code != null) {
                                ref
                                    .read(localeProvider.notifier)
                                    .setLocale(code);
                              }
                            },
                            items: const [
                              AppDropdownItem(value: 'en', title: 'English'),
                              AppDropdownItem(
                                value: 'ml',
                                title: 'മലയാളം (Malayalam)',
                              ),
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
                            style: AppFonts.bodySmall(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          value:
                              state.garage?.isDoorstepRepairAvailable ?? true,
                          activeColor: AppColors.primaryRed,
                          onChanged: (val) => vm.setDoorstepRepair(val),
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
                            style: AppFonts.bodySmall(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          value:
                              state.garage?.isRoadsideAssistanceAvailable ??
                              true,
                          activeColor: AppColors.primaryRed,
                          onChanged: (val) => vm.setRoadsideAssistance(val),
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
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        PreferenceTile(
                          icon: Icons.notifications_active_rounded,
                          title: 'Enable Push Notifications',
                          subtitle: 'Receive customer bookings, status updates and approval alerts',
                          onTap: () async {
                            final service = ref.read(
                              pushNotificationServiceProvider,
                            );
                            final settings = await service.requestPermission();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    settings != null
                                        ? 'Notification permissions updated.'
                                        : 'Push notification service initialized.',
                                  ),
                                  backgroundColor: AppColors.accentBlue,
                                ),
                              );
                            }
                          },
                        ),
                        const Divider(height: 1),
                        PreferenceTile(
                          icon: Icons.image_rounded,
                          title: 'Send Test Alert with Image',
                          subtitle: 'Preview a rich merchant alert with estimate breakdown image',
                          onTap: () async {
                            final service = ref.read(
                              pushNotificationServiceProvider,
                            );
                            await service.triggerEventNotification(
                              eventType: NotificationEventType.estimateApproved,
                              recipientUid: 'user_merchant_1',
                              entityId: 'est_m_1',
                              qualifier:
                                  'test_${DateTime.now().millisecondsSinceEpoch}',
                              title: 'Test: Estimate Approved by Customer',
                              body: 'Customer approved estimate EST-2024-001 (₹4,500). Ready to begin work.',
                              customImageUrl:
                                  NotificationEventMatrix.fallbackEstimateImage,
                              customDeepLink: '/merchant/estimates',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Merchant test alert dispatched with image!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Account Experience',
                    style: AppFonts.titleLarge(color: primaryTextColor),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        PreferenceTile(
                          icon: Icons.person_rounded,
                          title: 'Switch to Customer View',
                          subtitle: 'View garage discovery and customer vehicle dashboard',
                          onTap: () {
                            ref
                                .read(authViewModelProvider.notifier)
                                .switchExperience('customer');
                          },
                        ),
                        const Divider(height: 1),
                        PreferenceTile(
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          subtitle: 'Securely exit merchant workspace',
                          onTap: () async {
                            final confirm = await AppDialog.confirm(
                              context,
                              title: 'Sign Out?',
                              message: 'Are you sure you want to exit your merchant account?',
                              confirmLabel: 'Sign Out',
                              isDestructive: true,
                            );
                            if (confirm == true) {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .signOut();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
