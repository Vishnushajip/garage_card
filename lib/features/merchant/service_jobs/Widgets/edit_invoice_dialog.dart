import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/merchant/service_jobs/ViewModel/merchant_jobs_view_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/line_item_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:uuid/uuid.dart';

class _EditablePartRow {
  _EditablePartRow({
    required String name,
    required int qty,
    required double price,
    required double purchaseCost,
  }) : nameCtrl = TextEditingController(text: name),
       qtyCtrl = TextEditingController(text: qty.toString()),
       priceCtrl = TextEditingController(text: price.toStringAsFixed(2)),
       purchaseCostCtrl = TextEditingController(
         text: purchaseCost.toStringAsFixed(2),
       );

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

class EditInvoiceDialog extends ConsumerStatefulWidget {
  const EditInvoiceDialog({
    super.key,
    required this.invoice,
    required this.job,
  });

  final InvoiceModel invoice;
  final ServiceJobModel job;

  @override
  ConsumerState<EditInvoiceDialog> createState() => _EditInvoiceDialogState();
}

class _EditInvoiceDialogState extends ConsumerState<EditInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _laborCtrl;
  late final TextEditingController _discountCtrl;
  final List<_EditablePartRow> _parts = [];
  double _extraWorkCharges = 0.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    double initialLabor = 0.0;
    for (final item in widget.invoice.items) {
      if (item.type.toLowerCase() == 'labor' ||
          item.type.toLowerCase() == 'labour') {
        initialLabor += item.totalPrice;
      } else if (item.type.toLowerCase() == 'extra' ||
          item.type.toLowerCase() == 'supplemental') {
        _extraWorkCharges += item.totalPrice;
      } else if (item.type.toLowerCase() == 'part') {
        final row = _EditablePartRow(
          name: item.description,
          qty: item.quantity,
          price: item.unitPrice,
          purchaseCost: item.purchaseCost,
        );
        row.qtyCtrl.addListener(_onCalculationsChanged);
        row.priceCtrl.addListener(_onCalculationsChanged);
        row.purchaseCostCtrl.addListener(_onCalculationsChanged);
        _parts.add(row);
      }
    }

    _laborCtrl = TextEditingController(text: initialLabor.toStringAsFixed(2));
    _discountCtrl = TextEditingController(
      text: widget.invoice.discountAmount.toStringAsFixed(2),
    );

    _laborCtrl.addListener(_onCalculationsChanged);
    _discountCtrl.addListener(_onCalculationsChanged);
  }

  @override
  void dispose() {
    _laborCtrl.dispose();
    _discountCtrl.dispose();
    for (final p in _parts) {
      p.dispose();
    }
    super.dispose();
  }

  void _onCalculationsChanged() {
    if (mounted) setState(() {});
  }

  void _addPartRow() {
    final row = _EditablePartRow(
      name: '',
      qty: 1,
      price: 0.0,
      purchaseCost: 0.0,
    );
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

  double get _subtotal => _partsTotal + _laborTotal + _extraWorkCharges;

  double get _discount => double.tryParse(_discountCtrl.text.trim()) ?? 0.0;

  double get _finalBill => (_subtotal - _discount).clamp(0.0, double.infinity);

  double get _alreadyPaid => widget.invoice.paidAmount;

  double get _newBalanceDue =>
      (_finalBill - _alreadyPaid).clamp(0.0, double.infinity);

  String get _newPaymentStatus {
    if (_newBalanceDue <= 0.0 && _finalBill > 0.0) {
      return 'paid';
    } else if (_alreadyPaid > 0.0) {
      return 'partially_paid';
    }
    return 'unpaid';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_finalBill <= 0.0) {
      AppNotificationService.warning(
        'Final bill amount must be greater than ₹0',
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

    if (_laborTotal > 0.0) {
      lineItems.add(
        LineItemModel(
          id: const Uuid().v4(),
          description: 'Labour Charges',
          type: 'labor',
          quantity: 1,
          unitPrice: _laborTotal,
        ),
      );
    }

    if (_extraWorkCharges > 0.0) {
      lineItems.add(
        LineItemModel(
          id: const Uuid().v4(),
          description: 'Extra Work Charges',
          type: 'extra',
          quantity: 1,
          unitPrice: _extraWorkCharges,
        ),
      );
    }

    final updatedInvoice = widget.invoice.copyWith(
      items: lineItems,
      subtotal: _subtotal,
      discountAmount: _discount,
      totalAmount: _finalBill,
      paidAmount: _alreadyPaid,
      balanceDue: _newBalanceDue,
      status: _newPaymentStatus,
    );

    final success = await ref
        .read(merchantJobsViewModelProvider.notifier)
        .updateInvoice(updatedInvoice);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
        AppNotificationService.success(
          'Invoice and discounts updated successfully',
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
                            color: AppColors.accentBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_document,
                            color: AppColors.accentBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Invoice & Discounts',
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
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2. Parts Details (${_parts.length})',
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: summaryBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      'No spare parts in this invoice. Tap "+ Add Part" to add parts.',
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
                                      'Line Total',
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
                const SizedBox(height: 18),
                Text(
                  '3. Discount & Total Calculation',
                  style: AppFonts.titleSmall(color: AppColors.accentBlue)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _discountCtrl,
                  label: 'Discount Amount (₹)',
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
                      if (_extraWorkCharges > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Extra Work Charges:',
                              style: AppFonts.bodySmall(
                                color: secondaryTextColor,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(_extraWorkCharges),
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
                              'Discount:',
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
                            'Recalculated Bill Amount:',
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
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Already Paid Amount:',
                            style: AppFonts.bodyMedium(
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(_alreadyPaid),
                            style: AppFonts.bodyMedium(color: primaryTextColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining Balance Due:',
                            style: AppFonts.titleSmall(
                              color: _newBalanceDue > 0
                                  ? AppColors.error
                                  : AppColors.success,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            CurrencyFormatter.format(_newBalanceDue),
                            style: AppFonts.titleSmall(
                              color: _newBalanceDue > 0
                                  ? AppColors.error
                                  : AppColors.success,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                        label: 'Save Updated Invoice',
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
