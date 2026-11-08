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

class TermsConditionsScreen extends ConsumerWidget {
  const TermsConditionsScreen({super.key});

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse(
      'mailto:$email?subject=WeFix Terms & Conditions Inquiry',
    );
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
                    color: AppColors.primaryRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primaryRed),
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
              color: AppColors.primaryRed,
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
              context.tr('termsAndConditions'),
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
                      AppColors.primaryRed.withValues(
                        alpha: isDark ? 0.2 : 0.08,
                      ),
                      AppColors.accentBlue.withValues(
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
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.gavel_rounded,
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
                                context.tr('termsAndConditions'),
                                style: AppFonts.titleLarge(color: primaryText)
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                context.tr('termsSubtitle'),
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
                      'Welcome to WeFix. By accessing or using our mobile application, cloud services, or online platform, you agree to comply with and be bound by these Terms and Conditions.',
                      style: AppFonts.bodySmall(color: primaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                context: context,
                title: '1. Scope of the Platform',
                icon: Icons.hub_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Text(
                  'WeFix provides software infrastructure enabling automotive workshops to coordinate repair operations, issue digital job cards and invoices, and communicate with vehicle owners. WeFix operates strictly as a technology SaaS provider and is not itself an automobile repair or maintenance facility.',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '2. Workshop / Merchant Responsibilities',
                icon: Icons.storefront_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Column(
                  children: [
                    _buildBullet(
                      'Accurate Pricing: ',
                      'Garage owners agree to provide transparent, authentic labor rates and parts costs without misleading surcharges.',
                      primaryText,
                      secondaryText,
                    ),
                    _buildBullet(
                      'Repair Quality: ',
                      'Merchants are solely responsible for the technical workmanship, mechanical safety, and warranties of repairs performed in their workshops.',
                      primaryText,
                      secondaryText,
                    ),
                    _buildBullet(
                      'Digital Estimates: ',
                      'Merchants agree to honor digital estimates approved by customers prior to undertaking supplementary repairs.',
                      primaryText,
                      secondaryText,
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '3. Vehicle Owner / Customer Responsibilities',
                icon: Icons.person_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Column(
                  children: [
                    _buildBullet(
                      'Accurate Information: ',
                      'Customers must provide accurate vehicle registration details and contact phone numbers for repair authorizations.',
                      primaryText,
                      secondaryText,
                    ),
                    _buildBullet(
                      'Prompt Review: ',
                      'Vehicle owners agree to review and respond to digital repair estimates in a timely manner to facilitate repair workflows.',
                      primaryText,
                      secondaryText,
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '4. Account Security & Prohibited Activities',
                icon: Icons.security_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Text(
                  'Users must maintain the confidentiality of their credentials. Any automated scraping, unauthorized reverse engineering, intentional disruption, or attempt to breach multi-tenant database security boundaries is strictly prohibited and subject to immediate account termination.',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '5. Limitation of Liability',
                icon: Icons.policy_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Text(
                  'WeFix Technologies shall not be held liable for indirect, incidental, or consequential damages resulting from physical mechanical repairs performed by independent third-party workshops.',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '6. Governing Law & Jurisdiction',
                icon: Icons.balance_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Text(
                  'These terms shall be governed by and construed in accordance with the laws of India. Any legal dispute shall be subject to the exclusive jurisdiction of the competent courts in Kerala, India.',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
              ),
              _buildSectionCard(
                context: context,
                title: '7. Contact & Support',
                icon: Icons.contact_support_rounded,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'For inquiries concerning these Terms and Conditions or partnership contracts, please reach out to our legal department.',
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
                            color: AppColors.primaryRed,
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
                              backgroundColor: AppColors.primaryRed,
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
