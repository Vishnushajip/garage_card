import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';

class RecordPaymentDialog extends StatefulWidget {
  const RecordPaymentDialog({
    super.key,
    required this.invoice,
    required this.onRecord,
  });

  final InvoiceModel invoice;
  final Future<bool> Function({
    required double amount,
    required String paymentMethod,
    required String referenceNumber,
    required String notes,
  }) onRecord;

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedMethod = 'upi';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl =
        TextEditingController(text: widget.invoice.balanceDue.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final success = await widget.onRecord(
      amount: amt,
      paymentMethod: _selectedMethod,
      referenceNumber: _refCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return AlertDialog(
      title: Text(
        'Record Payment',
        style: AppFonts.titleLarge(color: primaryTextColor),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Invoice: ${widget.invoice.invoiceNumber} • Balance Due: ${CurrencyFormatter.format(widget.invoice.balanceDue, currencyCode: widget.invoice.currencyCode)}',
                style: AppFonts.labelSmall(color: AppColors.error),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _amountCtrl,
                label: 'Payment Amount',
                keyboardType: TextInputType.number,
                required: true,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Enter a valid amount';
                  if (val > widget.invoice.balanceDue) {
                    return 'Amount exceeds remaining balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Payment Method',
                value: _selectedMethod,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedMethod = val);
                  }
                },
                items: const [
                  AppDropdownItem(value: 'upi', title: 'UPI / GooglePay / PhonePe'),
                  AppDropdownItem(value: 'cash', title: 'Cash at Counter'),
                  AppDropdownItem(value: 'card', title: 'Credit / Debit Card (POS)'),
                  AppDropdownItem(value: 'bank_transfer', title: 'Bank NEFT / IMPS'),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _refCtrl,
                label: 'Transaction / UTR Reference',
                hint: 'e.g. UPI/20261024/9988 or POS slip #',
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _notesCtrl,
                label: 'Payment Notes',
                hint: 'Optional notes...',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          label: 'Confirm Payment',
          onPressed: _submit,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
