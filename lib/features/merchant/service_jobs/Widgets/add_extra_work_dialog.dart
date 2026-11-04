import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/merchant/service_jobs/ViewModel/merchant_jobs_view_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

import 'job_whatsapp_share_dialog.dart';

class AddExtraWorkDialog extends ConsumerStatefulWidget {
  const AddExtraWorkDialog({super.key, required this.job});

  final ServiceJobModel job;

  @override
  ConsumerState<AddExtraWorkDialog> createState() => _AddExtraWorkDialogState();
}

class _AddExtraWorkDialogState extends ConsumerState<AddExtraWorkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _chargeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _chargeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final charge = double.tryParse(_chargeCtrl.text.trim()) ?? 0.0;
    if (charge <= 0.0) {
      AppNotificationService.warning('Please enter a valid extra work charge');
      return;
    }

    setState(() => _isSaving = true);
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    final success = await ref
        .read(merchantJobsViewModelProvider.notifier)
        .addExtraWork(
          jobId: widget.job.id,
          title: title,
          charge: charge,
          description: desc.isNotEmpty ? desc : title,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
        AppNotificationService.success('Extra work added successfully');

        if (widget.job.customerPhone.isNotEmpty) {
          showDialog(
            context: context,
            builder: (ctx) => JobWhatsAppShareDialog(
              type: WhatsAppNotificationType.extraWorkAdded,
              customerName: widget.job.customerName,
              customerPhone: widget.job.customerPhone,
              bikeNumber: widget.job.vehicleDisplay,
              extraWorkTitle: title,
              estimatedCharge: charge,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final dialogBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentAmber.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_task_rounded,
                            color: AppColors.accentAmber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add Extra Work',
                          style: AppFonts.titleLarge(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _titleCtrl,
                  label: 'Extra Work Title',
                  hint: 'e.g. Brake pad replacement, Chain sprocket change',
                  required: true,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _chargeCtrl,
                  label: 'Extra Work Charge (₹)',
                  hint: 'e.g. 450',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  required: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Charge is required';
                    }
                    final num = double.tryParse(v.trim());
                    if (num == null || num <= 0) {
                      return 'Must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _descCtrl,
                  label: 'Problem Details / Reason (Optional)',
                  hint: 'Describe reason for extra work to inform customer...',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
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
                      child: AppButton(
                        label: 'Save & Notify Customer',
                        icon: const Icon(Icons.check_rounded, size: 18),
                        onPressed: _isSaving ? null : _submit,
                        isLoading: _isSaving,
                        height: 46,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
