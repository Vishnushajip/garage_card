import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/account_switcher_list_view.dart';

class CustomerProfilePreferencesCard extends StatelessWidget {
  const CustomerProfilePreferencesCard({
    super.key,
    required this.locale,
    required this.onLanguageChanged,
    required this.onNavigateToWarranties,
    required this.onAccountSwitched,
    required this.onSignOut,
  });

  final Locale locale;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onNavigateToWarranties;
  final ValueChanged<String> onAccountSwitched;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('languagePreference'),
                  style: AppFonts.titleMedium(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('selectPreferredLanguage'),
                  style: AppFonts.labelSmall(color: secondaryTextColor),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _LanguagePill(
                        code: 'en',
                        title: 'English',
                        subtitle: context.tr('defaultTag'),
                        isSelected: locale.languageCode == 'en',
                        isDark: isDark,
                        onTap: () => onLanguageChanged('en'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LanguagePill(
                        code: 'ml',
                        title: 'മലയാളം',
                        subtitle: 'Malayalam',
                        isSelected: locale.languageCode == 'ml',
                        isDark: isDark,
                        onTap: () => onLanguageChanged('ml'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              title: Text(
                context.tr('warrantyVault'),
                style: AppFonts.titleMedium(color: primaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                context.tr('viewReplacementCoverage'),
                style: AppFonts.labelSmall(color: secondaryTextColor),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondaryLight,
              ),
              onTap: onNavigateToWarranties,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.primaryRed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('accountSwitching'),
                            style: AppFonts.titleMedium(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            context.tr('switchToMerchant'),
                            style: AppFonts.labelSmall(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AccountSwitcherListView(onSwitched: onAccountSwitched),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'V-Fix Garage',
                      style: AppFonts.labelSmall(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Version 1.0.0 (Build 2026.1)',
                      style: AppFonts.labelSmall(color: secondaryTextColor)
                          .copyWith(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                onPressed: onSignOut,
                icon: const Icon(
                  Icons.power_settings_new_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
                label: Text(
                  context.tr('signOut'),
                  style: AppFonts.labelSmall(color: AppColors.error)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withValues(alpha: 0.12)
              : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryRed
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style:
                  AppFonts.titleSmall(
                    color: isSelected
                        ? AppColors.primaryRed
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ).copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppFonts.labelSmall(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
