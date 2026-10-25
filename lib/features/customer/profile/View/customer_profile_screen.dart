import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/notifications/notification_event_matrix.dart';
import 'package:garage_card/core/notifications/push_notification_service.dart';
import 'package:garage_card/core/theme/theme_controller.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';

import '../Widgets/preference_tile.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
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
