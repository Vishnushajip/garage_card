import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_icon.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

enum WhatsAppNotificationType {
  jobCreated,
  extraWorkAdded,
  workCompleted,
  invoiceSharing,
}

class JobWhatsAppShareDialog extends ConsumerStatefulWidget {
  const JobWhatsAppShareDialog({
    super.key,
    required this.type,
    required this.customerName,
    required this.customerPhone,
    required this.bikeNumber,
    this.bikeModel,
    this.problem = '',
    this.jobNumber = '',
    this.mechanic = '',
    this.extraWorkTitle = '',
    this.extraWork = '',
    this.estimatedCharge = 0.0,
    this.finalBillAmount = 0.0,
    this.paidAmount = 0.0,
    this.balanceDue = 0.0,
    this.invoiceNumber = '',
    this.paymentStatus = 'unpaid',
  });

  final WhatsAppNotificationType type;
  final String customerName;
  final String customerPhone;
  final String bikeNumber;
  final String? bikeModel;
  final String problem;
  final String jobNumber;
  final String mechanic;
  final String extraWorkTitle;
  final String extraWork;
  final double estimatedCharge;
  final double finalBillAmount;
  final double paidAmount;
  final double balanceDue;
  final String invoiceNumber;
  final String paymentStatus;

  @override
  ConsumerState<JobWhatsAppShareDialog> createState() =>
      _JobWhatsAppShareDialogState();
}

class _JobWhatsAppShareDialogState
    extends ConsumerState<JobWhatsAppShareDialog> {
  String _selectedLanguage = 'english';
  late final TextEditingController _phoneCtrl;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.customerPhone);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _getGarageName() {
    final garage = ref.read(merchantDashboardViewModelProvider).garage;
    if (garage != null && garage.name.isNotEmpty) {
      return garage.name;
    }
    return 'Authorized Bike Service Center';
  }

  String _buildMessage() {
    final garageName = _getGarageName();
    switch (widget.type) {
      case WhatsAppNotificationType.jobCreated:
        return WhatsAppShareService.composeJobCreatedNotification(
          customerName: widget.customerName,
          garageName: garageName,
          bikeNumber: widget.bikeNumber,
          bikeModel: widget.bikeModel,
          problem: widget.problem,
          jobNumber: widget.jobNumber,
          mechanic: widget.mechanic,
          language: _selectedLanguage,
        );
      case WhatsAppNotificationType.extraWorkAdded:
        return WhatsAppShareService.composeExtraWorkNotification(
          customerName: widget.customerName,
          garageName: garageName,
          bikeNumber: widget.bikeNumber,
          extraWorkTitle: widget.extraWorkTitle,
          estimatedCharge: widget.estimatedCharge,
          language: _selectedLanguage,
        );
      case WhatsAppNotificationType.workCompleted:
        return WhatsAppShareService.composeWorkCompletedNotification(
          customerName: widget.customerName,
          garageName: garageName,
          bikeNumber: widget.bikeNumber,
          bikeModel: widget.bikeModel,
          originalWork: widget.problem,
          extraWork: widget.extraWork,
          finalBillAmount: widget.finalBillAmount,
          language: _selectedLanguage,
        );
      case WhatsAppNotificationType.invoiceSharing:
        return WhatsAppShareService.composeJobInvoiceNotification(
          customerName: widget.customerName,
          garageName: garageName,
          bikeNumber: widget.bikeNumber,
          invoiceNumber: widget.invoiceNumber,
          finalAmount: widget.finalBillAmount,
          paidAmount: widget.paidAmount,
          balanceDue: widget.balanceDue,
          paymentStatus: widget.paymentStatus,
          language: _selectedLanguage,
        );
    }
  }

  String _getTypeTitle() {
    switch (widget.type) {
      case WhatsAppNotificationType.jobCreated:
        return 'Job Created Notification';
      case WhatsAppNotificationType.extraWorkAdded:
        return 'Extra Work Notification';
      case WhatsAppNotificationType.workCompleted:
        return 'Work Completed Notification';
      case WhatsAppNotificationType.invoiceSharing:
        return 'Invoice & Bill Share';
    }
  }

  Future<void> _send() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      AppNotificationService.warning('Please enter customer WhatsApp number');
      return;
    }

    setState(() => _isSending = true);
    final message = _buildMessage();
    final ok = await WhatsAppShareService.sendWhatsAppMessage(
      phoneNumber: phone,
      message: message,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (ok) {
        Navigator.of(context).pop();
        AppNotificationService.success(
          'WhatsApp opened with notification text',
        );
      } else {
        AppNotificationService.warning(
          'Could not launch WhatsApp. Verify app is installed.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final dialogBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final previewBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final messageText = _buildMessage();

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const AppWhatsAppIcon(
                            color: Color(0xFF25D366),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _getTypeTitle(),
                            style: AppFonts.titleLarge(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _phoneCtrl,
                label: 'Customer WhatsApp Number',
                hint: 'e.g. 9847123456',
                prefixIcon: const Icon(Icons.phone_android_rounded, size: 18),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppDropdown<String>(
                label: 'Message Language',
                value: _selectedLanguage,
                items: const [
                  AppDropdownItem(value: 'english', title: 'English'),
                  AppDropdownItem(
                    value: 'malayalam',
                    title: 'മലയാളം (Malayalam)',
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedLanguage = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Message Preview',
                style: AppFonts.labelMedium(color: secondaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: previewBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: SelectableText(
                  messageText,
                  style: AppFonts.bodySmall(color: primaryTextColor)
                      .copyWith(height: 1.5),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Navigator.of(context).pop(),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const AppWhatsAppIcon(
                              size: 18,
                              color: Colors.white,
                            ),
                      label: const Text('Send on WhatsApp'),
                      onPressed: _isSending ? null : _send,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
