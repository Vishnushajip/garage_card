import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/merchant/service_jobs/ViewModel/merchant_jobs_view_model.dart';
import 'package:garage_card/features/shared/models/line_item_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:uuid/uuid.dart';

import 'job_whatsapp_share_dialog.dart';

class _PartRowData {
  _PartRowData()
    : nameCtrl = TextEditingController(),
      qtyCtrl = TextEditingController(text: '1'),
      priceCtrl = TextEditingController(text: '0.00'),
      purchaseCostCtrl = TextEditingController(text: '0.00');

  final TextEditingController nameCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController purchaseCostCtrl;

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
    purchaseCostCtrl.dispose();
  }

  int get quantity => int.tryParse(qtyCtrl.text.trim()) ?? 1;
  double get unitPrice => double.tryParse(priceCtrl.text.trim()) ?? 0.0;
  double get purchaseCost =>
      double.tryParse(purchaseCostCtrl.text.trim()) ?? 0.0;
  double get total => quantity * unitPrice;
}

class CompleteJobBillingDialog extends ConsumerStatefulWidget {
  const CompleteJobBillingDialog({super.key, required this.job});

  final ServiceJobModel job;

  @override
  ConsumerState<CompleteJobBillingDialog> createState() =>
      _CompleteJobBillingDialogState();
}

class _CompleteJobBillingDialogState
    extends ConsumerState<CompleteJobBillingDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _laborCtrl = TextEditingController(
    text: '300.00',
  );
  final TextEditingController _discountCtrl = TextEditingController(
    text: '0.00',
  );
  final TextEditingController _paidCtrl = TextEditingController(text: '0.00');
  final TextEditingController _paymentNotesCtrl = TextEditingController();

  String _paymentMethod = 'Cash';
  final List<_PartRowData> _parts = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _laborCtrl.addListener(_onCalculationsChanged);
    _discountCtrl.addListener(_onCalculationsChanged);
    _paidCtrl.addListener(_onCalculationsChanged);
  }

  @override
  void dispose() {
    _laborCtrl.dispose();
    _discountCtrl.dispose();
    _paidCtrl.dispose();
    _paymentNotesCtrl.dispose();
    for (final p in _parts) {
      p.dispose();
    }
    super.dispose();
  }

  void _onCalculationsChanged() {
    if (mounted) setState(() {});
  }

  void _addPartRow() {
    final row = _PartRowData();
    row.qtyCtrl.addListener(_onCalculationsChanged);
    row.priceCtrl.addListener(_onCalculationsChanged);
    row.purchaseCostCtrl.addListener(_onCalculationsChanged);
    setState(() => _parts.add(row));
  }

  void _removePartRow(int index) {
    if (index >= 0 && index < _parts.length) {
      _parts[index].dispose();
      setState(() => _parts.removeAt(index));
    }
  }

  double get _partsTotal => _parts.fold(0.0, (acc, item) => acc + item.total);

  double get _laborTotal => double.tryParse(_laborCtrl.text.trim()) ?? 0.0;

  double get _extraWorkTotal => widget.job.supplementalItems.fold(
    0.0,
    (acc, item) => acc + item.totalAmount,
  );

  double get _subtotal => _partsTotal + _laborTotal + _extraWorkTotal;

  double get _discount => double.tryParse(_discountCtrl.text.trim()) ?? 0.0;

  double get _finalBill => (_subtotal - _discount).clamp(0.0, double.infinity);

  double get _amountPaid => double.tryParse(_paidCtrl.text.trim()) ?? 0.0;

  double get _balanceDue =>
      (_finalBill - _amountPaid).clamp(0.0, double.infinity);

  String get _paymentStatus {
    if (_balanceDue <= 0.0 && _finalBill > 0.0) {
      return 'Paid';
    } else if (_amountPaid > 0.0) {
      return 'Partially Paid';
    }
    return 'Unpaid';
  }

  void _setPaidFull() {
    setState(() {
      _paidCtrl.text = _finalBill.toStringAsFixed(2);
    });
  }

  void _setPaidZero() {
    setState(() {
      _paidCtrl.text = '0.00';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_finalBill <= 0.0) {
      AppNotificationService.warning(
        'A job cannot be marked as Completed without a valid final bill amount (> ₹0)',
      );
      return;
    }

    setState(() => _isSaving = true);

    final lineItems = <LineItemModel>[];
    for (final p in _parts) {
      final name = p.nameCtrl.text.trim();
      if (name.isNotEmpty && p.unitPrice > 0.0) {
        lineItems.add(
          LineItemModel(
            id: const Uuid().v4(),
            description: name,
            type: 'part',
            quantity: p.quantity,
            unitPrice: p.unitPrice,
            purchaseCost: p.purchaseCost,
          ),
        );
      }
    }

    final success = await ref
        .read(merchantJobsViewModelProvider.notifier)
        .completeJobWithBilling(
          jobId: widget.job.id,
          laborCharges: _laborTotal,
          parts: lineItems,
          extraWorkCharges: _extraWorkTotal,
          discountAmount: _discount,
          paidAmount: _amountPaid,
          paymentMethod: _paymentMethod,
          paymentNotes: _paymentNotesCtrl.text.trim(),
        );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
        AppNotificationService.success(
          'Repair completed and invoice generated successfully',
        );

        if (widget.job.customerPhone.isNotEmpty) {
          showDialog(
            context: context,
            builder: (ctx) => JobWhatsAppShareDialog(
              type: WhatsAppNotificationType.workCompleted,
              customerName: widget.job.customerName,
              customerPhone: widget.job.customerPhone,
              bikeNumber: widget.job.vehicleDisplay,
              problem: widget.job.complaints.isNotEmpty
                  ? widget.job.complaints.first
                  : 'Bike Repair & Service',
              extraWork: widget.job.supplementalItems.isNotEmpty
                  ? widget.job.supplementalItems.map((e) => e.title).join(', ')
                  : '',
              finalBillAmount: _finalBill,
              paidAmount: _amountPaid,
              balanceDue: _balanceDue,
              paymentStatus: _paymentStatus,
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
        constraints: const BoxConstraints(maxWidth: 680),
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
                            Icons.receipt_long_rounded,
                            color: AppColors.success,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete Job & Generate Bill',
                              style: AppFonts.titleLarge(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${widget.job.jobNumber} • ${widget.job.vehicleDisplay}',
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
                const SizedBox(height: 20),
                Text(
                  '1. Labour Charges',
                  style: AppFonts.titleSmall(color: AppColors.accentBlue)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _laborCtrl,
                  label: 'Labour / Service Charges (₹)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  required: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Labour charge is required';
                    }
                    if (double.tryParse(v.trim()) == null) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2. Spare Parts (${_parts.length})',
                      style: AppFonts.titleSmall(color: AppColors.accentBlue)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _addPartRow,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Part'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
                if (_parts.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: summaryBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      'No spare parts added. Tap "+ Add Part" if parts were replaced.',
                      style: AppFonts.bodySmall(color: secondaryTextColor),
                    ),
                  ),
                ] else ...[
                  for (int i = 0; i < _parts.length; i++) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: summaryBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: AppTextField(
                                  controller: _parts[i].nameCtrl,
                                  label: 'Part Name',
                                  hint: 'e.g. Engine Oil 1L, Brake Shoe',
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                onPressed: () => _removePartRow(i),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: _parts[i].qtyCtrl,
                                  label: 'Qty',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  controller: _parts[i].priceCtrl,
                                  label: 'Sell Price (₹)',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  controller: _parts[i].purchaseCostCtrl,
                                  label: 'Cost (₹)',
                                  hint: 'Expense',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total',
                                      style: AppFonts.labelSmall(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      CurrencyFormatter.format(_parts[i].total),
                                      style: AppFonts.labelLarge(
                                        color: primaryTextColor,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                if (_extraWorkTotal > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentAmber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Extra Work Included (${widget.job.supplementalItems.length} items):',
                          style: AppFonts.labelMedium(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          CurrencyFormatter.format(_extraWorkTotal),
                          style: AppFonts.titleSmall(
                            color: AppColors.accentAmber,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  '3. Discount & Bill Calculation',
                  style: AppFonts.titleSmall(color: AppColors.accentBlue)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _discountCtrl,
                  label: 'Discount (₹)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 14),
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
                            'Parts Amount:',
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(_partsTotal),
                            style: AppFonts.bodySmall(color: primaryTextColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Labour Charges:',
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(_laborTotal),
                            style: AppFonts.bodySmall(color: primaryTextColor),
                          ),
                        ],
                      ),
                      if (_extraWorkTotal > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Extra Work:',
                              style: AppFonts.bodySmall(
                                color: secondaryTextColor,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(_extraWorkTotal),
                              style: AppFonts.bodySmall(
                                color: primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_discount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount Applied:',
                              style: AppFonts.bodySmall(color: AppColors.error),
                            ),
                            Text(
                              '-${CurrencyFormatter.format(_discount)}',
                              style: AppFonts.bodySmall(color: AppColors.error),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Final Bill Amount:',
                            style: AppFonts.titleMedium(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            CurrencyFormatter.format(_finalBill),
                            style: AppFonts.titleLarge(
                              color: AppColors.accentBlue,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '4. Payment Details',
                  style: AppFonts.titleSmall(color: AppColors.accentBlue)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: AppTextField(
                        controller: _paidCtrl,
                        label: 'Amount Paid (₹)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _setPaidFull,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Full'),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: _setPaidZero,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Unpaid'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: summaryBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Outstanding Balance',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(_balanceDue),
                              style: AppFonts.titleSmall(
                                color: _balanceDue > 0
                                    ? AppColors.error
                                    : AppColors.success,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Status: $_paymentStatus',
                              style: AppFonts.labelSmall(
                                color: _balanceDue <= 0
                                    ? AppColors.success
                                    : AppColors.accentAmber,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _paymentNotesCtrl,
                  label: 'Payment Reference / Notes (Optional)',
                  hint: 'e.g. GPay UPI Ref, Paid in cash at counter...',
                ),
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
                        label: 'Save',
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
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
