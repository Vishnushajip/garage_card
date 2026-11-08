import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_date_text.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/merchant/service_jobs/ViewModel/merchant_jobs_view_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

import 'job_whatsapp_share_dialog.dart';

class UpdatePaymentDialog extends ConsumerStatefulWidget {
  const UpdatePaymentDialog({
    super.key,
    required this.invoice,
    required this.job,
  });

  final InvoiceModel invoice;
  final ServiceJobModel job;

  @override
  ConsumerState<UpdatePaymentDialog> createState() =>
      _UpdatePaymentDialogState();
}

class _UpdatePaymentDialogState extends ConsumerState<UpdatePaymentDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountCtrl;
  final TextEditingController _refCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  String _paymentMethod = 'UPI';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.invoice.balanceDue > 0
          ? widget.invoice.balanceDue.toStringAsFixed(2)
          : '0.00',
    );
    _amountCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _enteredAmount => double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

  double get _remainingAfterPayment =>
      (widget.invoice.balanceDue - _enteredAmount).clamp(0.0, double.infinity);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_enteredAmount <= 0.0) {
      AppNotificationService.warning('Payment amount must be greater than ₹0');
      return;
    }

    if (_enteredAmount > widget.invoice.balanceDue + 0.01) {
      AppNotificationService.warning(
        'Payment amount cannot exceed the remaining balance due',
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await ref
        .read(merchantJobsViewModelProvider.notifier)
        .recordPayment(
          invoiceId: widget.invoice.id,
          amount: _enteredAmount,
          paymentMethod: _paymentMethod,
          reference: _refCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          invoice: widget.invoice,
          garageId: widget.invoice.garageId,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
        AppNotificationService.success('Payment recorded successfully');

        if (widget.job.customerPhone.isNotEmpty) {
          final newPaid = widget.invoice.paidAmount + _enteredAmount;
          final newBalance = _remainingAfterPayment;
          showDialog(
            context: context,
            builder: (ctx) => JobWhatsAppShareDialog(
              type: WhatsAppNotificationType.invoiceSharing,
              customerName: widget.job.customerName,
              customerPhone: widget.job.customerPhone,
              bikeNumber: widget.job.vehicleDisplay,
              invoiceNumber: widget.invoice.invoiceNumber,
              finalBillAmount: widget.invoice.totalAmount,
              paidAmount: newPaid,
              balanceDue: newBalance,
              paymentStatus: newBalance <= 0.0 ? 'paid' : 'partially_paid',
            ),
          );
        }
      } else {
        final err = ref.read(merchantJobsViewModelProvider).errorMessage;
        AppNotificationService.error(
          err != null && err.isNotEmpty
              ? err
              : 'Failed to record payment. Please try again.',
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
    final summaryBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
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
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.payment_rounded,
                            color: AppColors.success,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Record Customer Payment',
                              style: AppFonts.titleLarge(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${widget.invoice.invoiceNumber} • ${widget.job.vehicleDisplay}',
                              style: AppFonts.bodySmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: summaryBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Final Bill Total:',
                            style: AppFonts.bodyMedium(
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(
                              widget.invoice.totalAmount,
                            ),
                            style: AppFonts.titleSmall(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Already Paid:',
                            style: AppFonts.bodyMedium(
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(widget.invoice.paidAmount),
                            style: AppFonts.titleSmall(color: AppColors.success)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Balance Due:',
                            style: AppFonts.titleSmall(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            CurrencyFormatter.format(widget.invoice.balanceDue),
                            style: AppFonts.titleMedium(
                              color: widget.invoice.balanceDue > 0
                                  ? AppColors.error
                                  : AppColors.success,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _amountCtrl,
                  label: 'Payment Amount Received (₹)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  required: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final num = double.tryParse(v.trim());
                    if (num == null || num <= 0) {
                      return 'Must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppDropdown<String>(
                  label: 'Payment Method',
                  value: _paymentMethod,
                  items: const [
                    AppDropdownItem(value: 'Cash', title: 'Cash'),
                    AppDropdownItem(
                      value: 'UPI',
                      title: 'UPI / GPay / PhonePe',
                    ),
                    AppDropdownItem(
                      value: 'Bank Transfer',
                      title: 'Bank Transfer',
                    ),
                    AppDropdownItem(value: 'Other', title: 'Other'),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _paymentMethod = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _refCtrl,
                  label: 'Transaction ID / Reference (Optional)',
                  hint: 'e.g. UPI Ref 382910482',
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _notesCtrl,
                  label: 'Payment Notes (Optional)',
                  hint: 'e.g. Collected by front desk',
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _remainingAfterPayment <= 0.0
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.accentAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining Balance After This Payment:',
                        style: AppFonts.labelSmall(color: primaryTextColor),
                      ),
                      Text(
                        CurrencyFormatter.format(_remainingAfterPayment),
                        style: AppFonts.titleSmall(
                          color: _remainingAfterPayment <= 0.0
                              ? AppColors.success
                              : AppColors.accentAmber,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (widget.invoice.paymentRecords.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Previous Payment History (${widget.invoice.paymentRecords.length})',
                    style: AppFonts.labelLarge(color: primaryTextColor)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (final p in widget.invoice.paymentRecords) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: summaryBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${p.method.toUpperCase()} • ${CurrencyFormatter.format(p.amount)}',
                                style: AppFonts.labelMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (p.reference != null &&
                                  p.reference!.isNotEmpty)
                                Text(
                                  'Ref: ${p.reference}',
                                  style: AppFonts.bodySmall(
                                    color: secondaryTextColor,
                                  ),
                                ),
                            ],
                          ),
                          AppDateText(
                            date: p.recordedAt,
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        variant: AppButtonVariant.outline,
                        onPressed: () => Navigator.of(context).pop(),
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Record Payment & Notify',
                        icon: const Icon(Icons.check_rounded, size: 18),
                        onPressed: _isSaving ? null : _submit,
                        isLoading: _isSaving,
                        height: 48,
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
