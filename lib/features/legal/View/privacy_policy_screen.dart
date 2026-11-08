import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/branding/app_branding.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=WeFix Privacy & Data Request');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget content,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
  }) {
    return Card(
      color: cardBg,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.accentBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppFonts.titleSmall(color: primaryText)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(
    String boldText,
    String normalText,
    Color primaryText,
    Color secondaryText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 10),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppFonts.bodySmall(color: secondaryText),
                children: [
                  TextSpan(
                    text: boldText,
                    style: AppFonts.bodySmall(color: primaryText)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: normalText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final sectionBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RoutePaths.auth);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('privacyPolicy'),
              style: AppFonts.titleMedium(color: primaryText)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              AppBranding.appName,
              style: AppFonts.labelSmall(color: secondaryText),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              final current = ref.read(localeProvider);
              final next = current.languageCode == 'en' ? 'ml' : 'en';
              ref.read(localeProvider.notifier).setLocale(next);
            },
            icon: const Icon(Icons.translate_rounded, size: 16),
            label: Text(
              ref.watch(localeProvider).languageCode == 'en'
                  ? 'മലയാളം'
                  : 'English',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: AppResponsiveLayout(
          maxWidth: 840,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentBlue.withValues(
                        alpha: isDark ? 0.2 : 0.08,
                      ),
                      AppColors.primaryRed.withValues(
                        alpha: isDark ? 0.15 : 0.05,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('privacyPolicy'),
                                style: AppFonts.titleLarge(color: primaryText)
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                context.tr('privacySubtitle'),
                                style: AppFonts.labelSmall(
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('legalEffectiveDate'),
                      style: AppFonts.labelSmall(color: secondaryText)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'At WeFix Technologies, data privacy and multi-tenant isolation are core architectural commitments. This Privacy Policy details how we collect, process, and protect your information across our mobile and web applications.',
                      style: AppFonts.bodySmall(color: primaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                context: context,
                title: '1. Strict Multi-Tenant SaaS Isolation',
                icon: Icons.shield_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Text(
                  'WeFix operates under an absolute tenant isolation architecture. Every garage merchant\'s operational data—including repair job cards, billing invoices, customer rosters, mechanic labor costs, supplier pricing, and revenue reports—is cryptographically and rule-validated at the database layer. No workshop merchant can ever query, inspect, or modify another garage\'s records.',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '2. Customer Private Data Protection',
                icon: Icons.lock_person_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Text(
                  'Vehicle owners maintain exclusive ownership over their vehicle registration numbers, private phone numbers, service logs, and payment histories. Discovering a garage grants access only to publicly authorized workshop catalog details (e.g. services, verified location, operating hours). It never exposes customer identities to third parties.',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '3. Information We Collect',
                icon: Icons.data_usage_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Column(
                  children: [
                    _buildBullet(
                      'Account Details: ',
                      'Name, authenticated email address, phone number, and account role (Customer or Merchant).',
                      primaryText,
                      secondaryText,
                    ),
                    _buildBullet(
                      'Workshop Information: ',
                      'Garage business name, verified physical address, location coordinates, public contact numbers, and service catalog.',
                      primaryText,
                      secondaryText,
                    ),
                    _buildBullet(
                      'Vehicle Records: ',
                      'Registration plate numbers, make, model, year, fuel type, and odometer readings for maintenance scheduling.',
                      primaryText,
                      secondaryText,
                    ),
                    _buildBullet(
                      'Repair & Billing Data: ',
                      'Digital job cards, itemized estimates, replacement parts, labor charges, and payment transaction logs.',
                      primaryText,
                      secondaryText,
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '4. Zero Sale of Personal Data',
                icon: Icons.verified_user_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Text(
                  'We do not sell, rent, or monetize personal data or garage business records to third-party advertisers, data brokers, or marketing networks. All stored data is utilized exclusively to deliver automotive service management functionality.',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '5. Data Security & Encryption',
                icon: Icons.key_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Text(
                  'All data transmitted between your device and our cloud servers is encrypted using modern TLS 1.3 protocol. Stored records are protected by granular Firestore Security Rules requiring authenticated session validation on every operation.',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '6. Legal Inquiries & Data Deletion',
                icon: Icons.contact_mail_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'If you have questions regarding this Privacy Policy or wish to request complete deletion of your account and vehicle records, please reach out directly to our Data Protection Officer.',
                      style: AppFonts.bodySmall(color: secondaryText),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: sectionBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 18,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppBranding.defaultSupportEmail,
                              style: AppFonts.bodySmall(color: primaryText)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                _sendEmail(AppBranding.defaultSupportEmail),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Contact Us'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
