import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';

class ServiceEditDialog extends StatefulWidget {
  const ServiceEditDialog({
    super.key,
    required this.garageId,
    this.initialService,
    required this.onSave,
  });

  final String garageId;
  final GarageServiceModel? initialService;
  final Future<bool> Function(GarageServiceModel) onSave;

  static Future<bool?> show(
    BuildContext context, {
    required String garageId,
    GarageServiceModel? initialService,
    required Future<bool> Function(GarageServiceModel) onSave,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ServiceEditDialog(
        garageId: garageId,
        initialService: initialService,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ServiceEditDialog> createState() => _ServiceEditDialogState();
}

class _ServiceEditDialogState extends State<ServiceEditDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fixedPriceController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _durationController = TextEditingController();
  final _termsController = TextEditingController();

  final _scooterPriceController = TextEditingController();
  final _motorcyclePriceController = TextEditingController();
  final _carPriceController = TextEditingController();

  final _rule1PriceController = TextEditingController();
  final _rule2PriceController = TextEditingController();
  final _rule3PriceController = TextEditingController();

  String _category = 'General';
  String _pricingMethod = 'fixed';
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.initialService;
    if (s != null) {
      _nameController.text = s.name;
      _descriptionController.text = s.description;
      _category = s.category;
      _pricingMethod = s.pricingMethod;
      _durationController.text = s.estimatedDuration;
      _termsController.text = s.terms ?? '';

      if (s.fixedPrice != null) {
        _fixedPriceController.text = s.fixedPrice!.toStringAsFixed(0);
      }
      if (s.startingPrice != null) {
        _startingPriceController.text = s.startingPrice!.toStringAsFixed(0);
      }

      if (s.categoryPrices.containsKey('scooter')) {
        _scooterPriceController.text = s.categoryPrices['scooter']!
            .toStringAsFixed(0);
      }
      if (s.categoryPrices.containsKey('motorcycle')) {
        _motorcyclePriceController.text = s.categoryPrices['motorcycle']!
            .toStringAsFixed(0);
      }
      if (s.categoryPrices.containsKey('car')) {
        _carPriceController.text = s.categoryPrices['car']!.toStringAsFixed(0);
      }

      if (s.attributeRules.isNotEmpty) {
        _rule1PriceController.text = s.attributeRules[0].price.toStringAsFixed(
          0,
        );
      }
      if (s.attributeRules.length > 1) {
        _rule2PriceController.text = s.attributeRules[1].price.toStringAsFixed(
          0,
        );
      }
      if (s.attributeRules.length > 2) {
        _rule3PriceController.text = s.attributeRules[2].price.toStringAsFixed(
          0,
        );
      }
    } else {
      _durationController.text = '1-2 hrs';
      _scooterPriceController.text = '300';
      _motorcyclePriceController.text = '400';
      _carPriceController.text = '1000';
      _rule1PriceController.text = '350';
      _rule2PriceController.text = '550';
      _rule3PriceController.text = '850';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _fixedPriceController.dispose();
    _startingPriceController.dispose();
    _durationController.dispose();
    _termsController.dispose();
    _scooterPriceController.dispose();
    _motorcyclePriceController.dispose();
    _carPriceController.dispose();
    _rule1PriceController.dispose();
    _rule2PriceController.dispose();
    _rule3PriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: surfaceColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialService != null
                          ? 'Edit Service'
                          : 'Create Garage Service',
                      style: AppFonts.headlineSmall(color: primaryText),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  label: 'Service Name',
                  hint: 'e.g. Engine Oil Service, Brake Pad Lathe',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Detailed scope of work included in this service...',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'Service Category',
                        value: _category,
                        items: const [
                          AppDropdownItem(value: 'General', title: 'General'),
                          AppDropdownItem(
                            value: 'Maintenance',
                            title: 'Maintenance',
                          ),
                          AppDropdownItem(
                            value: 'Mechanical',
                            title: 'Mechanical',
                          ),
                          AppDropdownItem(
                            value: 'Electrical',
                            title: 'Electrical',
                          ),
                          AppDropdownItem(value: 'Bodywork', title: 'Bodywork'),
                          AppDropdownItem(value: 'Washing', title: 'Washing'),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _durationController,
                        label: 'Estimated Duration',
                        hint: 'e.g. 1-2 hrs, 45 mins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Smart Pricing Method',
                  style: AppFonts.labelLarge(color: primaryText),
                ),
                const SizedBox(height: 6),
                AppDropdown<String>(
                  label: 'Select Pricing Model',
                  value: _pricingMethod,
                  items: const [
                    AppDropdownItem(
                      value: 'fixed',
                      title: 'Fixed Price (Same for all vehicles)',
                    ),
                    AppDropdownItem(
                      value: 'category',
                      title: 'Category-Based (Scooter / Bike / Car)',
                    ),
                    AppDropdownItem(
                      value: 'attribute',
                      title: 'Attribute-Based (Engine CC / Capacity rules)',
                    ),
                    AppDropdownItem(
                      value: 'startingPrice',
                      title: 'Starting Price (Final on inspection)',
                    ),
                    AppDropdownItem(
                      value: 'quotation',
                      title: 'Quotation Required (Inspection first)',
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _pricingMethod = val);
                  },
                ),
                const SizedBox(height: 14),
                if (_pricingMethod == 'fixed') ...[
                  AppTextField(
                    controller: _fixedPriceController,
                    label: 'Fixed Price (₹ INR)',
                    hint: '250',
                    keyboardType: TextInputType.number,
                  ),
                ] else if (_pricingMethod == 'startingPrice') ...[
                  AppTextField(
                    controller: _startingPriceController,
                    label: 'Starting Price From (₹ INR)',
                    hint: '500',
                    keyboardType: TextInputType.number,
                  ),
                ] else if (_pricingMethod == 'category') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category Pricing Rules (INR)',
                          style: AppFonts.labelMedium(color: primaryText),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _scooterPriceController,
                                label: 'Scooter (₹)',
                                hint: '300',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppTextField(
                                controller: _motorcyclePriceController,
                                label: 'Motorcycle (₹)',
                                hint: '400',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppTextField(
                                controller: _carPriceController,
                                label: 'Car (₹)',
                                hint: '1000',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else if (_pricingMethod == 'attribute') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Engine Capacity (CC) Rules',
                          style: AppFonts.labelMedium(color: primaryText),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _rule1PriceController,
                                label: 'Up to 150cc (₹)',
                                hint: '350',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppTextField(
                                controller: _rule2PriceController,
                                label: '151cc - 350cc (₹)',
                                hint: '550',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppTextField(
                                controller: _rule3PriceController,
                                label: '351cc+ (₹)',
                                hint: '850',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else if (_pricingMethod == 'quotation') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primaryAmber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Customers will be requested to bring vehicle for physical assessment and digital estimate preparation.',
                            style: AppFonts.bodySmall(color: secondaryText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                AppTextField(
                  controller: _termsController,
                  label: 'Terms & Conditions / Inclusions',
                  hint: 'e.g. Includes coolant check; excludes external part costs',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: AppFonts.bodySmall(color: AppColors.primaryRed),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: AppFonts.labelLarge(color: secondaryText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Save Service',
                        isLoading: _isSaving,
                        onPressed: () async {
                          if (_nameController.text.trim().isEmpty) {
                            setState(
                              () => _error = 'Please enter service name.',
                            );
                            return;
                          }

                          setState(() {
                            _isSaving = true;
                            _error = null;
                          });

                          final serviceId =
                              widget.initialService?.id ??
                              'srv_${const Uuid().v4().substring(0, 8)}';

                          final catPrices = <String, double>{};
                          if (_pricingMethod == 'category') {
                            catPrices['scooter'] =
                                double.tryParse(_scooterPriceController.text) ??
                                300.0;
                            catPrices['motorcycle'] =
                                double.tryParse(
                                  _motorcyclePriceController.text,
                                ) ??
                                400.0;
                            catPrices['car'] =
                                double.tryParse(_carPriceController.text) ??
                                1000.0;
                          }

                          final attrRules = <PricingAttributeRule>[];
                          if (_pricingMethod == 'attribute') {
                            attrRules.addAll([
                              PricingAttributeRule(
                                label: 'Up to 150cc',
                                vehicleType: 'motorcycle',
                                minCc: 0,
                                maxCc: 150,
                                price:
                                    double.tryParse(
                                      _rule1PriceController.text,
                                    ) ??
                                    350.0,
                              ),
                              PricingAttributeRule(
                                label: '151cc to 350cc',
                                vehicleType: 'motorcycle',
                                minCc: 151,
                                maxCc: 350,
                                price:
                                    double.tryParse(
                                      _rule2PriceController.text,
                                    ) ??
                                    550.0,
                              ),
                              PricingAttributeRule(
                                label: 'Above 350cc',
                                vehicleType: 'motorcycle',
                                minCc: 351,
                                maxCc: 2000,
                                price:
                                    double.tryParse(
                                      _rule3PriceController.text,
                                    ) ??
                                    850.0,
                              ),
                            ]);
                          }

                          final newService = GarageServiceModel(
                            id: serviceId,
                            garageId: widget.garageId,
                            name: _nameController.text.trim(),
                            description: _descriptionController.text.trim(),
                            category: _category,
                            pricingMethod: _pricingMethod,
                            fixedPrice: double.tryParse(
                              _fixedPriceController.text,
                            ),
                            startingPrice: double.tryParse(
                              _startingPriceController.text,
                            ),
                            categoryPrices: catPrices,
                            attributeRules: attrRules,
                            estimatedDuration:
                                _durationController.text.trim().isNotEmpty
                                ? _durationController.text.trim()
                                : '1-2 hrs',
                            terms: _termsController.text.trim().isNotEmpty
                                ? _termsController.text.trim()
                                : null,
                            isActive: widget.initialService?.isActive ?? true,
                            createdAt:
                                widget.initialService?.createdAt ??
                                DateTime.now(),
                          );

                          final nav = Navigator.of(context);
                          final ok = await widget.onSave(newService);
                          if (!mounted) return;
                          if (ok) {
                            nav.pop(true);
                          } else {
                            setState(() {
                              _isSaving = false;
                              _error = 'Failed to save service.';
                            });
                          }
                        },
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
