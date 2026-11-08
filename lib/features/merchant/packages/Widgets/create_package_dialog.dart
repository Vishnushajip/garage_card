import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';

class CreatePackageDialog extends StatefulWidget {
  const CreatePackageDialog({super.key, required this.onSave});

  final void Function({
    required String title,
    required String description,
    required List<String> includedServices,
    required double originalPrice,
    required double packagePrice,
    required String vehicleType,
    required int validityDays,
  })
  onSave;

  static Future<void> show(
    BuildContext context, {
    required void Function({
      required String title,
      required String description,
      required List<String> includedServices,
      required double originalPrice,
      required double packagePrice,
      required String vehicleType,
      required int validityDays,
    })
    onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => CreatePackageDialog(onSave: onSave),
    );
  }

  @override
  State<CreatePackageDialog> createState() => _CreatePackageDialogState();
}

class _CreatePackageDialogState extends State<CreatePackageDialog> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _origPriceCtrl = TextEditingController();
  final TextEditingController _offerPriceCtrl = TextEditingController();
  final TextEditingController _taskInputCtrl = TextEditingController();

  String _vehicleType = 'all';
  final int _validityDays = 30;
  final List<String> _services = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _origPriceCtrl.dispose();
    _offerPriceCtrl.dispose();
    _taskInputCtrl.dispose();
    super.dispose();
  }

  void _addTask() {
    final text = _taskInputCtrl.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _services.add(text);
        _taskInputCtrl.clear();
      });
    }
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final orig = double.tryParse(_origPriceCtrl.text.trim()) ?? 0.0;
    final offer = double.tryParse(_offerPriceCtrl.text.trim()) ?? 0.0;

    if (title.isNotEmpty && offer > 0) {
      widget.onSave(
        title: title,
        description: _descCtrl.text.trim(),
        includedServices: _services,
        originalPrice: orig > 0 ? orig : offer,
        packagePrice: offer,
        vehicleType: _vehicleType,
        validityDays: _validityDays,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return AlertDialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.loyalty_rounded, color: AppColors.accentBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr('createPackage'),
              style: AppFonts.titleMedium(color: primaryTextColor),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: context.tr('packageTitle'),
                hint: 'e.g. Monsoon Care Package',
                controller: _titleCtrl,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: context.tr('packageDescription'),
                hint: 'Short description of the offer',
                controller: _descCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: context.tr('originalPrice'),
                      hint: '850',
                      controller: _origPriceCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                      label: context.tr('offerPrice'),
                      hint: '499',
                      controller: _offerPriceCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppDropdown<String>(
                label: 'Vehicle Category',
                value: _vehicleType,
                items: const [
                  AppDropdownItem(
                    value: 'all',
                    title: 'All Vehicles',
                    icon: Icon(Icons.directions_car_filled_rounded),
                  ),
                  AppDropdownItem(
                    value: 'twoWheeler',
                    title: 'Two Wheeler (Bikes & Scooters)',
                    icon: Icon(Icons.two_wheeler_rounded),
                  ),
                  AppDropdownItem(
                    value: 'fourWheeler',
                    title: 'Four Wheeler (Cars & SUVs)',
                    icon: Icon(Icons.directions_car_rounded),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _vehicleType = val);
                },
              ),
              const SizedBox(height: 14),
              Text(
                context.tr('includedTasks'),
                style: AppFonts.labelSmall(color: secondaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hint: 'e.g. Full Water Wash',
                      controller: _taskInputCtrl,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: AppButton(
                      label: 'Add',
                      onPressed: _addTask,
                      height: 42,
                    ),
                  ),
                ],
              ),
              if (_services.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _services.map((s) {
                    return Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(() => _services.remove(s));
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        SizedBox(
          width: 100,
          child: AppButton(
            label: context.tr('save'),
            onPressed: _submit,
            height: 38,
          ),
        ),
      ],
    );
  }
}
