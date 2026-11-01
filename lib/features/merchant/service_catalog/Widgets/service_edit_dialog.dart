import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/services/image_upload_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_image_picker_box.dart';
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
  final _durationController = TextEditingController();
  final _includedController = TextEditingController();
  final _excludedController = TextEditingController();
  final _requiredPartsController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _termsController = TextEditingController();

  final _fixedPriceController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  final Map<String, TextEditingController> _tierFixedPriceControllers = {};
  final Map<String, TextEditingController> _tierMinPriceControllers = {};
  final Map<String, TextEditingController> _tierMaxPriceControllers = {};
  final Map<String, String> _tierPricingTypes = {};

  String _category = 'Periodic Service';
  String _pricingType = 'fixed';
  final Set<String> _selectedVehicles = {'car', 'motorcycle', 'scooter'};
  bool _isActive = true;
  bool _isSaving = false;
  String? _error;
  String? _imageUrl;
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  ImageUploadProgress? _uploadProgress;

  static const List<Map<String, String>> _availableVehicleTypes = [
    {'id': 'car', 'label': 'Car'},
    {'id': 'motorcycle', 'label': 'Motorcycle'},
    {'id': 'scooter', 'label': 'Scooter'},
    {'id': 'electric_scooter', 'label': 'EV Scooter'},
    {'id': 'electric_motorcycle', 'label': 'EV Motorcycle'},
    {'id': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    for (final v in _availableVehicleTypes) {
      final id = v['id']!;
      _tierFixedPriceControllers[id] = TextEditingController();
      _tierMinPriceControllers[id] = TextEditingController();
      _tierMaxPriceControllers[id] = TextEditingController();
      _tierPricingTypes[id] = 'fixed';
    }

    final s = widget.initialService;
    if (s != null) {
      _imageUrl = s.imageUrl;
      _nameController.text = s.name;
      _descriptionController.text = s.description;
      _category = s.category;
      _durationController.text = s.estimatedDuration;
      _termsController.text = s.terms ?? '';
      _specialInstructionsController.text = s.specialInstructions ?? '';
      _includedController.text = s.includedItems.join(', ');
      _excludedController.text = s.excludedItems.join(', ');
      _requiredPartsController.text = s.requiredParts.join(', ');
      _isActive = s.isActive;

      _pricingType = s.pricingType.isNotEmpty && s.pricingType != 'fixed'
          ? s.pricingType
          : (s.pricingMethod.isNotEmpty ? s.pricingMethod : 'fixed');
      if (_pricingType == 'category') {
        _pricingType = 'vehicle_specific';
      }

      if (s.fixedPrice != null) {
        _fixedPriceController.text = s.fixedPrice!.toStringAsFixed(0);
      }
      if (s.minPrice != null) {
        _minPriceController.text = s.minPrice!.toStringAsFixed(0);
      }
      if (s.maxPrice != null) {
        _maxPriceController.text = s.maxPrice!.toStringAsFixed(0);
      }

      _selectedVehicles.clear();
      _selectedVehicles.addAll(s.applicableVehicleTypes);
      if (_selectedVehicles.isEmpty) {
        _selectedVehicles.addAll(['car', 'motorcycle', 'scooter']);
      }

      for (final tier in s.vehiclePricing) {
        final vType = tier.vehicleType.toLowerCase();
        if (_tierPricingTypes.containsKey(vType)) {
          _tierPricingTypes[vType] = tier.pricingType;
          if (tier.fixedPrice != null) {
            _tierFixedPriceControllers[vType]?.text = tier.fixedPrice!
                .toStringAsFixed(0);
          }
          if (tier.minPrice != null) {
            _tierMinPriceControllers[vType]?.text = tier.minPrice!
                .toStringAsFixed(0);
          }
          if (tier.maxPrice != null) {
            _tierMaxPriceControllers[vType]?.text = tier.maxPrice!
                .toStringAsFixed(0);
          }
        }
      }

      for (final entry in s.categoryPrices.entries) {
        final vType = entry.key.toLowerCase();
        if (_tierFixedPriceControllers.containsKey(vType)) {
          _tierFixedPriceControllers[vType]?.text = entry.value.toStringAsFixed(
            0,
          );
          _tierPricingTypes[vType] = 'fixed';
        }
      }
    } else {
      _durationController.text = '1-2 hrs';
      _fixedPriceController.text = '499';
      _minPriceController.text = '350';
      _maxPriceController.text = '750';
      _tierFixedPriceControllers['car']?.text = '1499';
      _tierFixedPriceControllers['motorcycle']?.text = '499';
      _tierFixedPriceControllers['scooter']?.text = '349';
      _tierFixedPriceControllers['electric_scooter']?.text = '349';
      _tierFixedPriceControllers['electric_motorcycle']?.text = '499';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _includedController.dispose();
    _excludedController.dispose();
    _requiredPartsController.dispose();
    _specialInstructionsController.dispose();
    _termsController.dispose();
    _fixedPriceController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();

    for (final c in _tierFixedPriceControllers.values) {
      c.dispose();
    }
    for (final c in _tierMinPriceControllers.values) {
      c.dispose();
    }
    for (final c in _tierMaxPriceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _parseCsv(String text) {
    return text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
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
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: surfaceColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
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
                          ? 'Edit Garage Service'
                          : 'Add New Service',
                      style: AppFonts.headlineSmall(color: primaryText)
                          .copyWith(fontWeight: FontWeight.bold),
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
                AppImagePickerBox(
                  existingImageUrl: _imageUrl,
                  selectedBytes: _selectedImageBytes,
                  selectedFile: _selectedImageFile,
                  height: 150,
                  label: 'Package Image',
                  helperText: 'Select an image for this package. It will be compressed & optimized automatically.',
                  uploadProgress: _uploadProgress,
                  onPickImage: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 90,
                    );
                    if (picked != null) {
                      final bytes = await picked.readAsBytes();
                      if (mounted) {
                        setState(() {
                          _selectedImageFile = picked;
                          _selectedImageBytes = bytes;
                        });
                      }
                    }
                  },
                  onRemoveImage:
                      (_selectedImageBytes != null ||
                          (_imageUrl != null && _imageUrl!.isNotEmpty))
                      ? () {
                          setState(() {
                            _selectedImageFile = null;
                            _selectedImageBytes = null;
                            _imageUrl = null;
                          });
                        }
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  label: 'Service Name',
                  hint: 'e.g. Periodic Service, Foam Wash, Brake Overhaul',
                  required: true,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Service Description',
                  hint: 'Detailed scope of work included in this service...',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'Category',
                        value: _category,
                        items: const [
                          AppDropdownItem(
                            value: 'Periodic Service',
                            title: 'Periodic Maintenance',
                          ),
                          AppDropdownItem(
                            value: 'Water Service & Wash',
                            title: 'Wash & Detailing',
                          ),
                          AppDropdownItem(
                            value: 'Inspections & Diagnostics',
                            title: 'Diagnostics & Scan',
                          ),
                          AppDropdownItem(
                            value: 'Mechanical',
                            title: 'Mechanical Repair',
                          ),
                          AppDropdownItem(
                            value: 'Electrical & Battery',
                            title: 'Electrical & EV',
                          ),
                          AppDropdownItem(
                            value: 'AC & Heating',
                            title: 'AC & Cooling',
                          ),
                          AppDropdownItem(
                            value: 'Tires & Wheels',
                            title: 'Tires & Alignment',
                          ),
                          AppDropdownItem(
                            value: 'General',
                            title: 'General Workshop',
                          ),
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
                const SizedBox(height: 18),
                Text(
                  'Vehicle Compatibility',
                  style: AppFonts.labelLarge(color: primaryText)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select all vehicle types compatible with this service:',
                  style: AppFonts.bodySmall(color: secondaryText),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableVehicleTypes.map((v) {
                    final id = v['id']!;
                    final label = v['label']!;
                    final isSelected = _selectedVehicles.contains(id);
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppColors.accentBlue.withValues(
                        alpha: 0.15,
                      ),
                      checkmarkColor: AppColors.accentBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.accentBlue : primaryText,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedVehicles.add(id);
                          } else {
                            if (_selectedVehicles.length > 1) {
                              _selectedVehicles.remove(id);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Text(
                  'Dynamic Pricing Model',
                  style: AppFonts.labelLarge(color: primaryText)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppDropdown<String>(
                  label: 'Pricing Structure',
                  value: _pricingType,
                  items: const [
                    AppDropdownItem(
                      value: 'fixed',
                      title: 'Option A: Fixed Price (Same for all vehicles)',
                    ),
                    AppDropdownItem(
                      value: 'range',
                      title: 'Option B: Price Range (Min – Max Price)',
                    ),
                    AppDropdownItem(
                      value: 'vehicle_specific',
                      title: 'Option C: Vehicle-Specific Pricing',
                    ),
                    AppDropdownItem(
                      value: 'contact',
                      title: 'Option D: Contact for Price',
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _pricingType = val);
                  },
                ),
                const SizedBox(height: 14),
                if (_pricingType == 'fixed') ...[
                  AppTextField(
                    controller: _fixedPriceController,
                    label: 'Fixed Price (₹ INR)',
                    hint: '499',
                    keyboardType: TextInputType.number,
                  ),
                ] else if (_pricingType == 'range') ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _minPriceController,
                          label: 'Minimum Price (₹)',
                          hint: '300',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _maxPriceController,
                          label: 'Maximum Price (₹)',
                          hint: '600',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ] else if (_pricingType == 'vehicle_specific') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle-Specific Price Tiers (₹ INR)',
                          style: AppFonts.labelMedium(color: primaryText)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ..._selectedVehicles.map((vId) {
                          final vLabel = _availableVehicleTypes.firstWhere(
                            (x) => x['id'] == vId,
                            orElse: () => {'label': vId},
                          )['label']!;
                          final currentMode = _tierPricingTypes[vId] ?? 'fixed';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      vId == 'car'
                                          ? Icons.directions_car_rounded
                                          : Icons.two_wheeler_rounded,
                                      size: 16,
                                      color: AppColors.accentBlue,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        vLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.labelMedium(
                                          color: primaryText,
                                        ).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    DropdownButton<String>(
                                      value: currentMode,
                                      isDense: true,
                                      underline: const SizedBox.shrink(),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'fixed',
                                          child: Text('Fixed'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'range',
                                          child: Text('Range'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'contact',
                                          child: Text('Contact'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(
                                            () => _tierPricingTypes[vId] = val,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (currentMode == 'fixed') ...[
                                  AppTextField(
                                    controller: _tierFixedPriceControllers[vId],
                                    label: '$vLabel Price (₹)',
                                    hint: '500',
                                    keyboardType: TextInputType.number,
                                  ),
                                ] else if (currentMode == 'range') ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          controller:
                                              _tierMinPriceControllers[vId],
                                          label: 'Min Price (₹)',
                                          hint: '350',
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AppTextField(
                                          controller:
                                              _tierMaxPriceControllers[vId],
                                          label: 'Max Price (₹)',
                                          hint: '650',
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Text(
                                    'Contact workshop for customized $vLabel quote.',
                                    style: AppFonts.bodySmall(
                                      color: secondaryText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ] else if (_pricingType == 'contact') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_in_talk_rounded,
                          color: AppColors.accentAmber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Customers will see "Contact for Price" and request custom inspection quotes.',
                            style: AppFonts.bodySmall(color: secondaryText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  controller: _includedController,
                  label: 'Included Items (Comma-Separated)',
                  hint: 'e.g. Engine oil change, OEM oil filter, 25-point scan',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _excludedController,
                  label: 'Excluded Items (Comma-Separated)',
                  hint: 'e.g. Major engine overhaul, Body painting',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _requiredPartsController,
                  label: 'Required Parts (Comma-Separated)',
                  hint: 'e.g. Synthetic Engine Oil, Oil Filter Cartridge',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _specialInstructionsController,
                  label: 'Special Instructions / Terms',
                  hint: 'e.g. Please bring vehicle 10 mins prior to slot',
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Active Service',
                    style: AppFonts.labelLarge(color: primaryText),
                  ),
                  subtitle: Text(
                    'When active, customers can discover and book this service.',
                    style: AppFonts.bodySmall(color: secondaryText),
                  ),
                  value: _isActive,
                  activeColor: AppColors.primaryRed,
                  onChanged: (val) => setState(() => _isActive = val),
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

                          final nav = Navigator.of(context);

                          setState(() {
                            _isSaving = true;
                            _error = null;
                          });

                          final serviceId =
                              widget.initialService?.id ??
                              'srv_${const Uuid().v4().substring(0, 8)}';

                          String? finalImageUrl = _imageUrl;

                          if (_selectedImageBytes != null ||
                              _selectedImageFile != null) {
                            try {
                              final imageService = ImageUploadService();
                              final uploadResult = await imageService
                                  .uploadImage(
                                    file:
                                        _selectedImageBytes ??
                                        _selectedImageFile,
                                    folder:
                                        'garages/${widget.garageId}/services',
                                    entityId: serviceId,
                                    profile: ImageProfile.card,
                                    previousImageUrl:
                                        widget.initialService?.imageUrl,
                                    onProgress: (p) {
                                      if (mounted) {
                                        setState(() => _uploadProgress = p);
                                      }
                                    },
                                  );
                              finalImageUrl = uploadResult.downloadUrl;
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _isSaving = false;
                                  _error =
                                      'Failed to optimize or upload package image: $e';
                                });
                              }
                              return;
                            }
                          } else if (_imageUrl == null &&
                              widget.initialService?.imageUrl != null) {
                            unawaited(
                              ImageUploadService().safeCleanupPreviousImage(
                                previousUrl: widget.initialService?.imageUrl,
                              ),
                            );
                          }

                          final tiers = <VehiclePricingTier>[];
                          final catPrices = <String, double>{};

                          if (_pricingType == 'vehicle_specific') {
                            for (final vId in _selectedVehicles) {
                              final mode = _tierPricingTypes[vId] ?? 'fixed';
                              if (mode == 'fixed') {
                                final p = double.tryParse(
                                  _tierFixedPriceControllers[vId]?.text ?? '',
                                );
                                if (p != null) {
                                  tiers.add(
                                    VehiclePricingTier(
                                      vehicleType: vId,
                                      pricingType: 'fixed',
                                      fixedPrice: p,
                                    ),
                                  );
                                  catPrices[vId] = p;
                                }
                              } else if (mode == 'range') {
                                final minP = double.tryParse(
                                  _tierMinPriceControllers[vId]?.text ?? '',
                                );
                                final maxP = double.tryParse(
                                  _tierMaxPriceControllers[vId]?.text ?? '',
                                );
                                if (minP != null && maxP != null) {
                                  tiers.add(
                                    VehiclePricingTier(
                                      vehicleType: vId,
                                      pricingType: 'range',
                                      minPrice: minP,
                                      maxPrice: maxP,
                                    ),
                                  );
                                  catPrices[vId] = minP;
                                }
                              } else {
                                tiers.add(
                                  VehiclePricingTier(
                                    vehicleType: vId,
                                    pricingType: 'contact',
                                  ),
                                );
                              }
                            }
                          }

                          final newService = GarageServiceModel(
                            id: serviceId,
                            garageId: widget.garageId,
                            name: _nameController.text.trim(),
                            description: _descriptionController.text.trim(),
                            category: _category,
                            imageUrl: finalImageUrl,
                            pricingMethod: _pricingType,
                            pricingType: _pricingType,
                            fixedPrice: double.tryParse(
                              _fixedPriceController.text,
                            ),
                            minPrice: double.tryParse(_minPriceController.text),
                            maxPrice: double.tryParse(_maxPriceController.text),
                            vehiclePricing: tiers,
                            categoryPrices: catPrices,
                            supportedVehicleTypes: _selectedVehicles.toList(),
                            estimatedDuration:
                                _durationController.text.trim().isNotEmpty
                                ? _durationController.text.trim()
                                : '1-2 hrs',
                            includedItems: _parseCsv(_includedController.text),
                            excludedItems: _parseCsv(_excludedController.text),
                            requiredParts: _parseCsv(
                              _requiredPartsController.text,
                            ),
                            specialInstructions:
                                _specialInstructionsController.text
                                    .trim()
                                    .isNotEmpty
                                ? _specialInstructionsController.text.trim()
                                : null,
                            terms: _termsController.text.trim().isNotEmpty
                                ? _termsController.text.trim()
                                : null,
                            isActive: _isActive,
                            createdAt:
                                widget.initialService?.createdAt ??
                                DateTime.now(),
                            updatedAt: DateTime.now(),
                          );

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
