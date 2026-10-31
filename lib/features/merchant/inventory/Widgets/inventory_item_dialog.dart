import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/inventory_item_model.dart';

import '../Model/merchant_inventory_state.dart';

class InventoryItemDialog extends StatefulWidget {
  const InventoryItemDialog({
    super.key,
    this.initialItem,
    required this.onSave,
  });

  final InventoryItemModel? initialItem;
  final Future<bool> Function(InventoryItemModel item) onSave;

  @override
  State<InventoryItemDialog> createState() => _InventoryItemDialogState();
}

class _InventoryItemDialogState extends State<InventoryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _unitCostCtrl;
  late final TextEditingController _sellingPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _minStockCtrl;
  late final TextEditingController _supplierCtrl;
  late final TextEditingController _locationCtrl;

  late String _selectedCategory;
  late String _selectedUnit;
  bool _isSaving = false;

  static const List<String> _units = [
    'Pcs',
    'Liters',
    'Sets',
    'Bottles',
    'Cans',
    'Metres',
    'Kg',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _skuCtrl = TextEditingController(text: item?.sku ?? '');
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _unitCostCtrl = TextEditingController(
      text: item != null ? item.unitCost.toStringAsFixed(2) : '',
    );
    _sellingPriceCtrl = TextEditingController(
      text: item != null ? item.sellingPrice.toStringAsFixed(2) : '',
    );
    _stockCtrl = TextEditingController(
      text: item != null ? item.currentStock.toString() : '0',
    );
    _minStockCtrl = TextEditingController(
      text: item != null ? item.minStockAlert.toString() : '5',
    );
    _supplierCtrl = TextEditingController(text: item?.supplier ?? '');
    _locationCtrl = TextEditingController(text: item?.location ?? '');

    _selectedCategory = item?.category ?? 'General Parts';
    if (!MerchantInventoryState.categories.contains(_selectedCategory) ||
        _selectedCategory == 'All') {
      _selectedCategory = 'General Parts';
    }

    _selectedUnit = item?.unit ?? 'Pcs';
    if (!_units.contains(_selectedUnit)) {
      _selectedUnit = 'Pcs';
    }
  }

  @override
  void dispose() {
    _skuCtrl.dispose();
    _nameCtrl.dispose();
    _unitCostCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    _supplierCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final unitCost = double.tryParse(_unitCostCtrl.text.trim()) ?? 0.0;
    final sellingPrice = double.tryParse(_sellingPriceCtrl.text.trim()) ?? 0.0;
    final currentStock = int.tryParse(_stockCtrl.text.trim()) ?? 0;
    final minAlert = int.tryParse(_minStockCtrl.text.trim()) ?? 5;

    final item = InventoryItemModel(
      id: widget.initialItem?.id ?? '',
      garageId: widget.initialItem?.garageId ?? '',
      sku: _skuCtrl.text.trim().toUpperCase(),
      name: _nameCtrl.text.trim(),
      category: _selectedCategory,
      unitCost: unitCost,
      sellingPrice: sellingPrice,
      currentStock: currentStock,
      minStockAlert: minAlert,
      unit: _selectedUnit,
      supplier: _supplierCtrl.text.trim().isNotEmpty
          ? _supplierCtrl.text.trim()
          : null,
      location: _locationCtrl.text.trim().isNotEmpty
          ? _locationCtrl.text.trim()
          : null,
      createdAt: widget.initialItem?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await widget.onSave(item);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
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
    final isEditing = widget.initialItem != null;

    final categoryOptions = MerchantInventoryState.categories
        .where((c) => c != 'All')
        .map((c) => AppDropdownItem<String>(value: c, title: c))
        .toList();

    final unitOptions = _units
        .map((u) => AppDropdownItem<String>(value: u, title: u))
        .toList();

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.accentBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing
                            ? 'Edit Inventory Item'
                            : 'New Spare Part / Consumable',
                        style: AppFonts.titleMedium(color: primaryTextColor)
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
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppTextField(
                              controller: _skuCtrl,
                              label: 'SKU / Part Code',
                              hint: 'e.g. OIL-SYN-5W30',
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'SKU required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: AppDropdown<String>(
                              label: 'Category',
                              items: categoryOptions,
                              value: _selectedCategory,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _nameCtrl,
                        label: 'Part / Item Name',
                        hint: 'e.g. Castrol Magnatec 5W-30 Full Synthetic Oil',
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Name required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _unitCostCtrl,
                              label: 'Unit Purchase Cost (₹)',
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Cost required';
                                }
                                if (double.tryParse(v.trim()) == null) {
                                  return 'Invalid cost';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _sellingPriceCtrl,
                              label: 'Retail Selling Price (₹)',
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Price required';
                                }
                                if (double.tryParse(v.trim()) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _stockCtrl,
                              label: 'Current On-Hand Stock',
                              hint: '0',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Stock required';
                                }
                                if (int.tryParse(v.trim()) == null) {
                                  return 'Invalid count';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _minStockCtrl,
                              label: 'Low-Stock Reorder Threshold',
                              hint: '5',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'Unit',
                              items: unitOptions,
                              value: _selectedUnit,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedUnit = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _supplierCtrl,
                              label: 'Supplier / Distributor',
                              hint: 'e.g. Bosch India Distribution',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _locationCtrl,
                              label: 'Storage Bin / Rack Location',
                              hint: 'e.g. Rack B-1 / Bin 4',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondaryLight,
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: isEditing ? 'Save Changes' : 'Create Item',
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    onPressed: _isSaving ? null : _submit,
                    variant: AppButtonVariant.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
