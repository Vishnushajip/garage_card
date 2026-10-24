import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/line_item_model.dart';

class EstimateFormDialog extends StatefulWidget {
  const EstimateFormDialog({
    super.key,
    required this.onSave,
  });

  final Future<bool> Function({
    required String estimateNumber,
    required List<LineItemModel> items,
    required double taxRate,
    required double discountAmount,
  }) onSave;

  @override
  State<EstimateFormDialog> createState() => _EstimateFormDialogState();
}

class _EstimateFormDialogState extends State<EstimateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _estNumberCtrl = TextEditingController(
      text: 'EST-2026-${DateTime.now().millisecondsSinceEpoch % 1000}');
  final _taxCtrl = TextEditingController(text: '18');
  final _discountCtrl = TextEditingController(text: '0');

  final List<LineItemModel> _items = [
    const LineItemModel(
      id: '1',
      description: 'Periodic Engine Oil Change & Filter',
      type: 'part',
      quantity: 1,
      unitPrice: 2800.0,
    ),
    const LineItemModel(
      id: '2',
      description: 'Brake Inspection & Cleaning Labor',
      type: 'labor',
      quantity: 1,
      unitPrice: 800.0,
    ),
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _estNumberCtrl.dispose();
    _taxCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await widget.onSave(
      estimateNumber: _estNumberCtrl.text.trim(),
      items: _items,
      taxRate: double.tryParse(_taxCtrl.text.trim()) ?? 18.0,
      discountAmount: double.tryParse(_discountCtrl.text.trim()) ?? 0.0,
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
        'Generate Digital Estimate',
        style: AppFonts.titleLarge(color: primaryTextColor),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _estNumberCtrl,
                label: 'Estimate Number',
                required: true,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _taxCtrl,
                      label: 'Tax / GST (%)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _discountCtrl,
                      label: 'Discount',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Line Items (${_items.length})',
                style: AppFonts.labelLarge(color: primaryTextColor),
              ),
              const SizedBox(height: 6),
              ..._items.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(item.description),
                    subtitle: Text('${item.quantity} x ₹${item.unitPrice}'),
                    trailing: Text('₹${item.totalPrice}'),
                  )),
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
          label: 'Create & Send Estimate',
          onPressed: _submit,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
