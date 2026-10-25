import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/notifications/notification_event_matrix.dart';
import 'package:garage_card/core/notifications/push_notification_service.dart';
import 'package:garage_card/core/theme/theme_controller.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';

import '../ViewModel/customer_profile_view_model.dart';
import '../Widgets/preference_tile.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
    final profileState = ref.watch(customerProfileViewModelProvider);
    final profileVm = ref.read(customerProfileViewModelProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile & Preferences',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
      ),
      body: SingleChildScrollView(
        child: AppResponsiveLayout(
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
                          color: AppColors.accentBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (user?.fullName.isNotEmpty ?? false)
                                ? user!.fullName[0].toUpperCase()
                                : 'U',
                            style: AppFonts.displayMedium(
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Valued Customer',
                              style: AppFonts.titleLarge(
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: AppFonts.bodyMedium(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.phoneNumber ?? '',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: profileState.isProfileComplete
                        ? (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight)
                        : AppColors.accentBlue.withValues(alpha: 0.5),
                    width: profileState.isProfileComplete ? 1 : 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: profileState.isProfileComplete
                                      ? AppColors.successBg
                                      : AppColors.accentBlue.withValues(
                                          alpha: 0.12,
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  profileState.isProfileComplete
                                      ? Icons.verified_user_rounded
                                      : Icons.contact_page_rounded,
                                  color: profileState.isProfileComplete
                                      ? AppColors.success
                                      : AppColors.accentBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Complete Your Profile',
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: profileState.isProfileComplete
                                  ? AppColors.successBg
                                  : AppColors.warningBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              profileState.isProfileComplete
                                  ? '100% Complete'
                                  : '${(profileState.completionPercentage * 100).toInt()}% Complete',
                              style: AppFonts.labelSmall(
                                color: profileState.isProfileComplete
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: profileState.completionPercentage,
                          backgroundColor: isDark
                              ? AppColors.borderDark.withValues(alpha: 0.3)
                              : AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            profileState.isProfileComplete
                                ? AppColors.success
                                : AppColors.accentBlue,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      if (!profileState.isProfileComplete) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Enter your name and phone number to receive repair updates, digital job sheets, and invoices directly.',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                      ],
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        initialValue: profileState.nameInput,
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                        ),
                        onChanged: profileVm.setName,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Phone Number',
                        hint: '+91 98765 43210',
                        initialValue: profileState.phoneInput,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        onChanged: profileVm.setPhone,
                      ),
                      if (profileState.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          profileState.errorMessage!,
                          style: AppFonts.labelSmall(color: AppColors.error),
                        ),
                      ],
                      if (profileState.successMessage != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              profileState.successMessage!,
                              style: AppFonts.labelSmall(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Save Profile Details',
                        icon: const Icon(Icons.save_rounded, size: 18),
                        isLoading: profileState.isSaving,
                        isFullWidth: true,
                        onPressed: profileVm.saveProfile,
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
                        label: 'Application Language',
                        value: locale.languageCode,
                        onChanged: (code) {
                          if (code != null) {
                            ref.read(localeProvider.notifier).setLocale(code);
                          }
                        },
                        items: const [
                          AppDropdownItem(
                            value: 'en',
                            title: 'English',
                            subtitle: 'Default Application Language',
                          ),
                          AppDropdownItem(
                            value: 'ml',
                            title: 'മലയാളം (Malayalam)',
                            subtitle: 'കേരളത്തിലെ പ്രാദേശിക ഭാഷ',
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: AppDropdown<ThemeMode>(
                        label: 'Appearance & Theme',
                        value: themeMode,
                        onChanged: (mode) {
                          if (mode != null) {
                            ref
                                .read(themeModeProvider.notifier)
                                .setThemeMode(mode);
                          }
                        },
                        items: const [
                          AppDropdownItem(
                            value: ThemeMode.system,
                            title: 'System Default',
                            subtitle:
                                'Follows operating system dark/light mode',
                          ),
                          AppDropdownItem(
                            value: ThemeMode.light,
                            title: 'Light Theme',
                            subtitle: 'Clean high contrast daytime interface',
                          ),
                          AppDropdownItem(
                            value: ThemeMode.dark,
                            title: 'Dark Theme',
                            subtitle: 'OLED midnight dark automotive theme',
                          ),
                        ],
                      ),
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
                      subtitle: 'Receive instant repair status updates, estimates and photos',
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
                      title: 'Send Test Notification with Image',
                      subtitle: 'Preview a rich notification with vehicle image and deep link',
                      onTap: () async {
                        final service = ref.read(
                          pushNotificationServiceProvider,
                        );
                        await service.triggerEventNotification(
                          eventType: NotificationEventType.readyForCollection,
                          recipientUid: user?.uid ?? 'customer_demo_uid',
                          entityId: 'job_demo_1',
                          qualifier:
                              'test_${DateTime.now().millisecondsSinceEpoch}',
                          title: 'Test: Vehicle Ready for Pickup!',
                          body: 'This is a test alert with an automotive vehicle photo.',
                          customImageUrl:
                              NotificationEventMatrix.fallbackCarImage,
                          customDeepLink: '/customer/jobs/job_demo_1',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Test notification dispatched with image!',
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
                'Account Actions',
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
                      icon: Icons.storefront_rounded,
                      title: 'Switch to Merchant Experience',
                      subtitle: 'Open garage management tools if you own or manage a shop',
                      onTap: () {
                        ref
                            .read(authViewModelProvider.notifier)
                            .switchExperience('merchant');
                      },
                    ),
                    const Divider(height: 1),
                    PreferenceTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'Securely end your current session',
                      onTap: () async {
                        final confirm = await AppDialog.confirm(
                          context,
                          title: 'Sign Out?',
                          message: 'Are you sure you want to sign out of your WeFix account?',
                          confirmLabel: 'Sign Out',
                          isDestructive: true,
                        );
                        if (confirm == true) {
                          ref.read(authViewModelProvider.notifier).signOut();
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
    );
  }
}
