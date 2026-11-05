import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/merchant/service_jobs/ViewModel/merchant_jobs_view_model.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/job_whatsapp_share_dialog.dart';
import 'package:garage_card/features/shared/models/line_item_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:uuid/uuid.dart';

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

class MerchantCompleteJobScreen extends ConsumerStatefulWidget {
  const MerchantCompleteJobScreen({super.key, required this.job});

  final ServiceJobModel job;

  @override
  ConsumerState<MerchantCompleteJobScreen> createState() =>
      _MerchantCompleteJobScreenState();
}

class _MerchantCompleteJobScreenState
    extends ConsumerState<MerchantCompleteJobScreen> {
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
    row.nameCtrl.addListener(_onCalculationsChanged);
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
      AppNotificationService.warning(context.tr('validFinalBillRequired'));
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
          context.tr('repairCompletedInvoiceSuccess'),
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
    ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final sectionBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: context.tr('completeJobAndBill'),
        subtitle: '${widget.job.jobNumber} • ${widget.job.vehicleDisplay}',
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppResponsiveLayout.kMaxFormWidth,
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.job.vehicleDisplay,
                                style: AppFonts.titleLarge(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppStatusBadge(status: widget.job.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${context.tr("customerLabel")}${widget.job.customerName}${widget.job.customerPhone.isNotEmpty ? " • ${widget.job.customerPhone}" : ""}',
                          style: AppFonts.bodyMedium(color: secondaryTextColor),
                        ),
                        if (widget.job.technicianName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${context.tr("assignedMechanicLabel")}${widget.job.technicianName}',
                            style: AppFonts.bodySmall(
                              color: AppColors.accentBlue,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.build_circle_outlined,
                                color: AppColors.accentBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr('laborServiceCharges'),
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _laborCtrl,
                          label: context.tr('laborCharges'),
                          hint: '300.00',
                          prefixIcon: const Icon(
                            Icons.currency_rupee_rounded,
                            size: 18,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          required: true,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return context.tr('chargeRequired');
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return context.tr('mustBeGreaterThanZero');
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  if (widget.job.supplementalItems.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  context.tr('extraWorkDetails'),
                                  style: AppFonts.titleMedium(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (final supp in widget.job.supplementalItems)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sectionBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      supp.title,
                                      style: AppFonts.bodyMedium(
                                        color: primaryTextColor,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(supp.totalAmount),
                                    style: AppFonts.labelLarge(
                                      color: AppColors.accentBlue,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('extraWorkTotal'),
                                style: AppFonts.bodySmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(_extraWorkTotal),
                                style: AppFonts.bodyMedium(
                                  color: AppColors.accentBlue,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 360;
                            if (isNarrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentBlue
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.hardware_rounded,
                                          color: AppColors.accentBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          context.tr('replacementParts'),
                                          style:
                                              AppFonts.titleMedium(
                                                color: primaryTextColor,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _addPartRow,
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        size: 16,
                                      ),
                                      label: Text(context.tr('addPart')),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.accentBlue,
                                        textStyle: AppFonts.bodySmall(
                                          color: AppColors.accentBlue,
                                        ).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentBlue
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.hardware_rounded,
                                          color: AppColors.accentBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          context.tr('replacementParts'),
                                          style:
                                              AppFonts.titleMedium(
                                                color: primaryTextColor,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: _addPartRow,
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: Text(context.tr('addPart')),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.accentBlue,
                                    textStyle: AppFonts.bodySmall(
                                      color: AppColors.accentBlue,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_parts.isEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: sectionBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: AppColors.accentBlue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.tr('noPartsAdded'),
                                    style: AppFonts.bodySmall(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          for (int i = 0; i < _parts.length; i++) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sectionBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: LayoutBuilder(
                                builder: (ctx, constraints) {
                                  final isStacked = constraints.maxWidth < 520;
                                  if (isStacked) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AppTextField(
                                                controller: _parts[i].nameCtrl,
                                                label: context.tr('partName'),
                                                hint: 'e.g. Engine Oil, Brake Shoe',
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: AppColors.error,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _removePartRow(i),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: AppTextField(
                                                controller: _parts[i].qtyCtrl,
                                                label: context.tr('qty'),
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 4,
                                              child: AppTextField(
                                                controller: _parts[i].priceCtrl,
                                                label: context.tr('unitPrice'),
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Total',
                                                    style: AppFonts.bodySmall(
                                                      color: secondaryTextColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    CurrencyFormatter.format(
                                                      _parts[i].total,
                                                    ),
                                                    style:
                                                        AppFonts.bodyMedium(
                                                          color:
                                                              primaryTextColor,
                                                        ).copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: AppTextField(
                                          controller: _parts[i].nameCtrl,
                                          label: context.tr('partName'),
                                          hint: 'e.g. Engine Oil, Brake Shoe',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: AppTextField(
                                          controller: _parts[i].qtyCtrl,
                                          label: context.tr('qty'),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 3,
                                        child: AppTextField(
                                          controller: _parts[i].priceCtrl,
                                          label: context.tr('unitPrice'),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Total',
                                              style: AppFonts.bodySmall(
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatter.format(
                                                _parts[i].total,
                                              ),
                                              style:
                                                  AppFonts.bodyMedium(
                                                    color: primaryTextColor,
                                                  ).copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                        onPressed: () => _removePartRow(i),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('partsTotal'),
                                style: AppFonts.bodySmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(_partsTotal),
                                style: AppFonts.bodyMedium(
                                  color: AppColors.accentBlue,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.accentBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr('billingSummary'),
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _discountCtrl,
                          label: context.tr('discount'),
                          hint: '0.00',
                          prefixIcon: const Icon(
                            Icons.discount_outlined,
                            size: 18,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: sectionBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.tr('partsTotal'),
                                    style: AppFonts.bodyMedium(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(_partsTotal),
                                    style: AppFonts.bodyMedium(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.tr('laborTotal'),
                                    style: AppFonts.bodyMedium(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(_laborTotal),
                                    style: AppFonts.bodyMedium(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (_extraWorkTotal > 0) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.tr('extraWorkTotal'),
                                      style: AppFonts.bodyMedium(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(_extraWorkTotal),
                                      style: AppFonts.bodyMedium(
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.tr('subtotal'),
                                    style: AppFonts.bodyMedium(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(_subtotal),
                                    style: AppFonts.bodyMedium(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (_discount > 0) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.tr('discount'),
                                      style: AppFonts.bodyMedium(
                                        color: AppColors.error,
                                      ),
                                    ),
                                    Text(
                                      '-${CurrencyFormatter.format(_discount)}',
                                      style: AppFonts.bodyMedium(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.tr('finalPayableBill'),
                                    style: AppFonts.titleMedium(
                                      color: primaryTextColor,
                                    ).copyWith(fontWeight: FontWeight.bold),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.payments_rounded,
                                color: AppColors.success,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr('paymentSettlement'),
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _paidCtrl,
                          label: context.tr('amountPaid'),
                          hint: '0.00',
                          prefixIcon: const Icon(
                            Icons.currency_rupee_rounded,
                            size: 18,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            ActionChip(
                              label: Text(context.tr('paidInFull')),
                              avatar: const Icon(Icons.check_rounded, size: 14),
                              onPressed: _setPaidFull,
                            ),
                            ActionChip(
                              label: Text(context.tr('unpaid')),
                              onPressed: _setPaidZero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('balanceDueLabel'),
                              style: AppFonts.titleSmall(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _balanceDue <= 0
                                    ? AppColors.success.withValues(alpha: 0.12)
                                    : AppColors.accentAmber.withValues(
                                        alpha: 0.12,
                                      ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                CurrencyFormatter.format(_balanceDue),
                                style: AppFonts.labelLarge(
                                  color: _balanceDue <= 0
                                      ? AppColors.success
                                      : AppColors.accentAmber,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppDropdown<String>(
                          label: context.tr('paymentMethod'),
                          value: _paymentMethod,
                          items: const [
                            AppDropdownItem(value: 'Cash', title: 'Cash'),
                            AppDropdownItem(
                              value: 'UPI',
                              title: 'UPI / QR Code',
                            ),
                            AppDropdownItem(
                              value: 'Card',
                              title: 'Debit / Credit Card',
                            ),
                            AppDropdownItem(
                              value: 'Bank Transfer',
                              title: 'Bank Transfer',
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _paymentMethod = val);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _paymentNotesCtrl,
                          label: context.tr('paymentNotesOptional'),
                          hint: 'e.g. GPay UPI Txn #12345678',
                          prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: context.tr('cancel'),
                          variant: AppButtonVariant.outline,
                          onPressed: () => Navigator.of(context).pop(),
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: context.tr('generateBillCompleteJob'),
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                          ),
                          onPressed: _isSaving ? null : _submit,
                          isLoading: _isSaving,
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
