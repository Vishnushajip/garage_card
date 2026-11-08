import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_icon.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';
import 'package:intl/intl.dart';

import '../Model/service_recall_model.dart';

class RecallWhatsAppShareDialog extends ConsumerStatefulWidget {
  const RecallWhatsAppShareDialog({super.key, required this.item});

  final ServiceRecallItem item;

  static Future<void> show(
    BuildContext context, {
    required ServiceRecallItem item,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => RecallWhatsAppShareDialog(item: item),
    );
  }

  @override
  ConsumerState<RecallWhatsAppShareDialog> createState() =>
      _RecallWhatsAppShareDialogState();
}

class _RecallWhatsAppShareDialogState
    extends ConsumerState<RecallWhatsAppShareDialog> {
  String _selectedLanguage = 'english';
  late final TextEditingController _phoneCtrl;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.item.customerPhone);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _buildMessage(String garageName, String garagePhone) {
    final dateStr = DateFormat('dd MMM yyyy')
        .format(widget.item.lastServiceDate);
    final days = widget.item.daysSinceLastService;
    final customer = widget.item.customerName.isNotEmpty
        ? widget.item.customerName
        : 'Customer';
    final vehicle = widget.item.vehicleDisplay;

    if (_selectedLanguage == 'malayalam') {
      return 'നമസ്കാരം $customer,\n\n'
          'താങ്കളുടെ $vehicle അവസാനമായി സർവീസ് ചെയ്തത് $dateStr-ൽ ആണ് ($garageName).\n'
          'ഇപ്പോൾ $days ദിവസങ്ങൾ കഴിഞ്ഞിരിക്കുന്നു, അടുത്ത പീരിയോഡിക് സർവീസ് ചെയ്യേണ്ട സമയമായിരിക്കുന്നു.\n\n'
          'സുരക്ഷിതവും സുഗമവുമായ യാത്രയ്ക്കായി ഉടൻ തന്നെ സർവീസ് സ്ലോട്ട് ബുക്ക് ചെയ്യുക.\n\n'
          'ബന്ധപ്പെടാൻ: ${garagePhone.isNotEmpty ? garagePhone : "വർക്ക്‌ഷോപ്പ്"}\n'
          'ടീം $garageName';
    }

    return 'Hello $customer,\n\n'
        'Your $vehicle was last serviced on $dateStr at $garageName.\n'
        'It has been $days days and your vehicle is now due for its periodic maintenance check.\n\n'
        'Keep your ride smooth and safe by booking your service appointment today!\n\n'
        'Call/WhatsApp us: ${garagePhone.isNotEmpty ? garagePhone : "Our Workshop"}\n'
        'Warm regards,\n$garageName';
  }

  Future<void> _send(String garageName, String garagePhone) async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      AppNotificationService.warning('Please enter customer WhatsApp number');
      return;
    }

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
        AppNotificationService.success('WhatsApp recall opened');
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
              context.tr('sendRecallWhatsApp'),
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
                context.tr('chooseRecallLanguage'),
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
                label: 'Customer Phone',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_rounded),
              ),
              const SizedBox(height: 14),
              Text(
                context.tr('recallMessagePreview'),
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
          label: Text(_isSending ? 'Launching...' : 'Send WhatsApp'),
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
