import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_icon.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

import '../Model/service_package_model.dart';

class PackageWhatsAppShareDialog extends ConsumerStatefulWidget {
  const PackageWhatsAppShareDialog({super.key, required this.package});

  final ServicePackageModel package;

  static Future<void> show(
    BuildContext context, {
    required ServicePackageModel package,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => PackageWhatsAppShareDialog(package: package),
    );
  }

  @override
  ConsumerState<PackageWhatsAppShareDialog> createState() =>
      _PackageWhatsAppShareDialogState();
}

class _PackageWhatsAppShareDialogState
    extends ConsumerState<PackageWhatsAppShareDialog> {
  String _selectedLanguage = 'english';
  final TextEditingController _phoneCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _buildMessage(String garageName, String garagePhone) {
    final pkg = widget.package;
    final offerStr = CurrencyFormatter.format(pkg.packagePrice);
    final origStr = CurrencyFormatter.format(pkg.originalPrice);
    final savingsStr = CurrencyFormatter.format(pkg.savingsAmount);

    final serviceList = pkg.includedServices.isNotEmpty
        ? pkg.includedServices.map((s) => '• $s').join('\n')
        : '• Comprehensive Multi-point checkup & wash';

    if (_selectedLanguage == 'malayalam') {
      return '🔥 പ്രത്യേക സർവീസ് ഓഫർ! — $garageName 🔥\n\n'
          '${pkg.title}\n'
          '${pkg.description}\n\n'
          'ഉൾപ്പെടുത്തിയിരിക്കുന്ന സേവനങ്ങൾ:\n'
          '$serviceList\n\n'
          '💰 ഓഫർ വില: $offerStr (യഥാർത്ഥ വില: $origStr)\n'
          '✨ ലാഭിക്കുക: $savingsStr (${pkg.savingsPercentage}% കിഴിവ്)\n'
          '⏳ സാധുത: ${pkg.validityDays} ദിവസത്തേക്ക് മാത്രം!\n\n'
          'ഇന്നുതന്നെ ബുക്ക് ചെയ്യൂ: ${garagePhone.isNotEmpty ? garagePhone : "ഞങ്ങളുടെ വർക്ക്‌ഷോപ്പ്"}\n'
          'ടീം $garageName';
    }

    return '🔥 Exclusive Service Offer! — $garageName 🔥\n\n'
        '${pkg.title}\n'
        '${pkg.description}\n\n'
        'Included Services:\n'
        '$serviceList\n\n'
        '💰 Special Price: $offerStr (Regular: $origStr)\n'
        '✨ You Save: $savingsStr (${pkg.savingsPercentage}% OFF)\n'
        '⏳ Limited Offer: Valid for ${pkg.validityDays} days!\n\n'
        'Book your slot now: ${garagePhone.isNotEmpty ? garagePhone : "Contact Us"}\n'
        'Warm regards,\n$garageName';
  }

  Future<void> _send(String garageName, String garagePhone) async {
    final phone = _phoneCtrl.text.trim();
    setState(() => _isSending = true);
    final message = _buildMessage(garageName, garagePhone);

    final ok = await WhatsAppShareService.sendWhatsAppMessage(
      phoneNumber: phone,
      message: message,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (ok) {
        Navigator.of(context).pop();
        AppNotificationService.success('WhatsApp promo opened');
      } else {
        AppNotificationService.error('Could not launch WhatsApp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final sectionBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final garage = ref.watch(merchantDashboardViewModelProvider).garage;
    final garageName = garage?.name.isNotEmpty == true
        ? garage!.name
        : 'WeFix Garage';
    final garagePhone = garage?.phone ?? '';

    final preview = _buildMessage(garageName, garagePhone);

    return AlertDialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const AppWhatsAppIcon(size: 20, color: Color(0xFF25D366)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Share Promotional Offer',
              style: AppFonts.titleMedium(color: primaryTextColor)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Broadcast Language',
                style: AppFonts.labelSmall(color: secondaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('English')),
                      selected: _selectedLanguage == 'english',
                      selectedColor: AppColors.accentBlue.withValues(
                        alpha: 0.15,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedLanguage = 'english');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('മലയാളം')),
                      selected: _selectedLanguage == 'malayalam',
                      selectedColor: AppColors.accentBlue.withValues(
                        alpha: 0.15,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedLanguage = 'malayalam');
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Direct Phone / Customer (Optional)',
                hint: 'Leave empty for general WhatsApp share',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_rounded),
              ),
              const SizedBox(height: 14),
              Text(
                'Promotional Message Preview',
                style: AppFonts.labelSmall(color: secondaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sectionBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  preview,
                  style: AppFonts.bodySmall(color: primaryTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton.icon(
          onPressed: _isSending ? null : () => _send(garageName, garagePhone),
          icon: const AppWhatsAppIcon(size: 16, color: Colors.white),
          label: Text(_isSending ? 'Launching...' : 'Share on WhatsApp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
