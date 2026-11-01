import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/supplemental_work_model.dart';
import 'package:uuid/uuid.dart';

class AddSupplementalWorkDialog extends StatefulWidget {
  const AddSupplementalWorkDialog({
    super.key,
    required this.jobId,
    required this.onAdd,
  });

  final String jobId;
  final Future<bool> Function(SupplementalWorkItem item) onAdd;

  @override
  State<AddSupplementalWorkDialog> createState() =>
      _AddSupplementalWorkDialogState();
}

class _AddSupplementalWorkDialogState extends State<AddSupplementalWorkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _partsCtrl = TextEditingController(text: '0.00');
  final _laborCtrl = TextEditingController(text: '0.00');
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _reasonCtrl.dispose();
    _partsCtrl.dispose();
    _laborCtrl.dispose();
    super.dispose();
  }

  double get _partsCost => double.tryParse(_partsCtrl.text.trim()) ?? 0.0;
  double get _laborCost => double.tryParse(_laborCtrl.text.trim()) ?? 0.0;
  double get _totalCost => _partsCost + _laborCost;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_totalCost <= 0.0) {
      AppNotificationService.warning(
        'Total additional cost must be greater than zero.',
      );
      return;
    }

    setState(() => _isSaving = true);
    final item = SupplementalWorkItem(
      id: const Uuid().v4(),
      jobId: widget.jobId,
      title: _titleCtrl.text.trim(),
      reason: _reasonCtrl.text.trim(),
      partsCost: _partsCost,
      laborCost: _laborCost,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final success = await widget.onAdd(item);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
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

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
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
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add_alert_rounded,
                              color: AppColors.accentAmber,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Supplemental Work Request',
                              style: AppFonts.titleMedium(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Request customer authorization for unexpected damage or additional repairs discovered mid-repair.',
                  style: AppFonts.bodySmall(color: secondaryTextColor),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _titleCtrl,
                  label: 'Work / Part Title',
                  hint: 'e.g. Rear Brake Rotor Resurfacing',
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _reasonCtrl,
                  label: 'Technical Reason & Finding',
                  hint: 'e.g. Discovered heavy grooves on discs during pad replacement',
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Reason is required'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _partsCtrl,
                        label: 'Parts Cost (₹)',
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _laborCtrl,
                        label: 'Labor Cost (₹)',
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Total Additional Amount',
                          style: AppFonts.titleSmall(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        CurrencyFormatter.format(_totalCost),
                        style: AppFonts.titleMedium(color: AppColors.accentBlue)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondaryLight,
                          side: BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: _isSaving ? 'Submitting...' : 'Send to Customer',
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        variant: AppButtonVariant.primary,
                        onPressed: _isSaving ? null : _submit,
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
